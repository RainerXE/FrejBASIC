'' frej/timers.bi - declarative timers, in the spirit of GFA-BASIC 3.5
''
'' GFA had EVERY <ticks> GOSUB <label> and AFTER <ticks> GOSUB <label>: the
'' program said what should happen and how often, and the runtime did the
'' calling from the vertical-blank interrupt.  This library keeps that shape
'' and drops the two limits GFA had - one EVERY and one AFTER, and labels
'' instead of procedures.
''
'' The important difference is the pump.  FB's Sleep and ScreenEvent are
'' compiler intrinsics, so a library cannot hook them; a timer therefore
'' fires when the program services it:
''
''     ServiceTimers           '' fire everything that is due, return
''     WaitTimers(16)          '' service, then wait up to 16 ms
''
'' Calling WaitTimers instead of Sleep in a loop gives the GFA behaviour:
''
''     dim as integer id = Every(16, @tick)
''     do
''         WaitTimers 16
''         '' ... draw ...
''     loop until done
''
'' Timers that come due while the program is not servicing are not queued:
'' each timer fires once and its next due time moves to now + interval, so a
'' slow frame costs ticks instead of building a backlog that then fires all
'' at once.
''
'' Copyright (c) 2026 the FrejBASIC contributors
'' Distributed under the same terms as the FreeBASIC runtime library.

#ifndef __FREJ_TIMERS_BI__
#define __FREJ_TIMERS_BI__

#pragma once

'' How many timers can exist at once.  Each one is a few dozen bytes, so this
'' is generous; registration fails (returns 0) when the table is full.
const FREJ_TIMERS_MAX = 64

'' ---------------------------------------------------------------- types --

type FrejTimerRec
	used     as integer     '' slot holds a live timer
	active   as integer     '' not stopped with TimerStop
	once     as integer     '' remove after the first fire (After)
	interval as double      '' seconds
	due      as double      '' scheduler seconds
	cb       as sub()
end type

dim shared frej_timers(1 to FREJ_TIMERS_MAX) as FrejTimerRec
dim shared frej_clock_day   as double  = 0    '' whole days added at midnight
dim shared frej_clock_last  as double  = 0    '' last raw Timer reading
dim shared frej_clock_ready as integer = 0    '' first reading taken
dim shared frej_firing      as integer = 0    '' a callback is running

'' ---------------------------------------------------------------- clock --
''
'' Timer is wall-clock seconds since midnight, so it wraps once a day and it
'' can jump when the system clock is corrected.  The wraparound is handled
'' exactly: the scheduler keeps a day counter and shifts every pending due
'' time when the day changes.  A clock correction is not compensated - one
'' service pass may fire early or late, and the timer then continues from
'' there.  Measuring what a timer does in terms of the scheduler clock rather
'' than wall-clock time keeps it usable across midnight.

private function FrejClockNow() as double
	dim as double t = timer
	if frej_clock_ready = 0 then
		frej_clock_last = t
		frej_clock_ready = 1
	elseif t < frej_clock_last then
		'' midnight: keep the scheduler clock moving forwards
		frej_clock_day += 86400.0
		dim as integer i
		for i = 1 to FREJ_TIMERS_MAX
			if frej_timers(i).used then frej_timers(i).due += 86400.0
		next
	end if
	frej_clock_last = t
	return frej_clock_day + t
end function

'' ------------------------------------------------------------ internals --

'' 0 when the id does not name a live timer
private function FrejTimerSlot(byval id as integer) as integer
	if id < 1 orelse id > FREJ_TIMERS_MAX then return 0
	if frej_timers(id).used = 0 then return 0
	return id
end function

private function FrejTimerAdd(byval msecs as integer, byval cb as sub(), byval once as integer) as integer
	'' a timer needs a callback and a positive interval; anything else is a
	'' programming mistake and is reported as failure rather than ignored
	if cb = 0 then return 0
	if msecs <= 0 then return 0

	dim as integer i, slot = 0
	for i = 1 to FREJ_TIMERS_MAX
		if frej_timers(i).used = 0 then
			slot = i
			exit for
		end if
	next
	if slot = 0 then return 0		'' table full

	dim as double now = FrejClockNow()
	with frej_timers(slot)
		.used     = 1
		.active   = 1
		.once     = once
		.interval = msecs / 1000.0
		.due      = now + .interval
		.cb       = cb
	end with
	return slot
end function

'' ---------------------------------------------------------------- public --

'' Call cb every msecs milliseconds.  Returns the timer id, or 0 on failure
'' (no callback, a non-positive interval, or a full table).
function Every(byval msecs as integer, byval cb as sub()) as integer
	return FrejTimerAdd(msecs, cb, 0)
end function

'' Call cb once, msecs milliseconds from now.  The timer removes itself.
function After(byval msecs as integer, byval cb as sub()) as integer
	return FrejTimerAdd(msecs, cb, 1)
end function

'' GFA's EVERY STOP.  id 0 stops every timer.
sub TimerStop(byval id as integer)
	dim as integer i
	if id = 0 then
		for i = 1 to FREJ_TIMERS_MAX
			if frej_timers(i).used then frej_timers(i).active = 0
		next
	else
		i = FrejTimerSlot(id)
		if i then frej_timers(i).active = 0
	end if
end sub

'' GFA's EVERY CONT.  The next fire is a full interval from now, so a timer
'' that was stopped for a long time does not fire immediately.
sub TimerGo(byval id as integer)
	dim as integer i
	if id = 0 then
		dim as double now = FrejClockNow()
		for i = 1 to FREJ_TIMERS_MAX
			with frej_timers(i)
				if .used then
					.active = 1
					.due = now + .interval
				end if
			end with
		next
	else
		i = FrejTimerSlot(id)
		if i then
			frej_timers(i).active = 1
			frej_timers(i).due = FrejClockNow() + frej_timers(i).interval
		end if
	end if
end sub

'' Forget a timer.  id 0 removes every timer.
sub TimerRemove(byval id as integer)
	dim as integer i
	if id = 0 then
		for i = 1 to FREJ_TIMERS_MAX
			frej_timers(i).used = 0
			frej_timers(i).active = 0
			frej_timers(i).cb = 0
		next
	else
		i = FrejTimerSlot(id)
		if i then
			frej_timers(i).used = 0
			frej_timers(i).active = 0
			frej_timers(i).cb = 0
		end if
	end if
end sub

'' Non-zero while the timer exists and has not been stopped.
function TimerActive(byval id as integer) as integer
	dim as integer i = FrejTimerSlot(id)
	if i = 0 then return 0
	return frej_timers(i).active
end function

'' Fire everything that is due, then return.  Safe to call from a callback:
'' the nested call does nothing, so a callback that services the pump cannot
'' recurse.
sub ServiceTimers()
	if frej_firing then exit sub

	dim as double now = FrejClockNow()

	'' Pick up the callbacks first.  A callback that registers, stops or
	'' removes a timer must not disturb the timers being fired in this pass,
	'' so the list is fixed before any of them runs.
	dim as sub() fire(1 to FREJ_TIMERS_MAX)
	dim as integer n = 0, i
	for i = 1 to FREJ_TIMERS_MAX
		with frej_timers(i)
			if .used andalso .active andalso .due <= now then
				n += 1
				fire(n) = .cb
				if .once then
					.used = 0		'' After: gone before the callback runs
				else
					'' one fire per pass, and missed ticks are dropped
					.due = now + .interval
				end if
			end if
		end with
	next
	if n = 0 then exit sub

	frej_firing = 1
	for i = 1 to n
		fire(i)()
	next
	frej_firing = 0
end sub

'' Service, then wait up to msecs milliseconds, servicing as it goes.  This
'' is the replacement for Sleep in a program that wants timers: it wakes
'' often enough for the shortest interval to be honoured.
sub WaitTimers(byval msecs as integer)
	dim as double deadline = FrejClockNow() + msecs / 1000.0
	do
		ServiceTimers()
		dim as double remaining = deadline - FrejClockNow()
		if remaining <= 0.0005 then exit do
		dim as integer ms = int(remaining * 1000.0)
		if ms < 1 then ms = 1
		if ms > 5 then ms = 5
		sleep ms, 1
	loop
end sub

#endif '' __FREJ_TIMERS_BI__
