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
'' This file supplies the GFA names; the registry lives in inc/fbtimer.bi,
'' which is also offered upstream in this neutral form.
''
'' Copyright (c) 2026 the FrejBASIC contributors
'' Distributed under the same terms as the FreeBASIC runtime library.

#ifndef __FREJ_TIMERS_BI__
#define __FREJ_TIMERS_BI__

#pragma once

#include once "fbtimer.bi"

const FREJ_TIMERS_MAX = FBTIMER_MAX

'' Call cb every msecs milliseconds.  Returns the timer id, or 0 on failure.
function Every(byval msecs as integer, byval cb as sub()) as integer
	return FBTimerEvery( msecs, cb )
end function

'' Call cb once, msecs milliseconds from now.  The timer removes itself.
function After(byval msecs as integer, byval cb as sub()) as integer
	return FBTimerAfter( msecs, cb )
end function

'' GFA's EVERY STOP.  id 0 stops every timer.
sub TimerStop(byval id as integer)
	FBTimerStop( id )
end sub

'' GFA's EVERY CONT.  The next fire is a full interval from now, so a timer
'' that was stopped for a long time does not fire immediately.
sub TimerGo(byval id as integer)
	FBTimerGo( id )
end sub

'' Forget a timer.  id 0 removes every timer.
sub TimerRemove(byval id as integer)
	FBTimerRemove( id )
end sub

'' Non-zero while the timer exists and has not been stopped.
function TimerActive(byval id as integer) as integer
	return FBTimerActive( id )
end function

'' Fire everything that is due, then return.
sub ServiceTimers()
	FBTimerService()
end sub

'' Service, then wait up to msecs milliseconds, servicing as it goes.
sub WaitTimers(byval msecs as integer)
	FBTimerWait( msecs )
end sub

#endif '' __FREJ_TIMERS_BI__
