'' frej/macos.bi - a small AppKit surface for FrejBASIC programs
''
'' GFA had the OS in the language (AES, VDI, BIOS, XEMDOS).  This is the
'' modern equivalent for the calls a GUI program actually needs: a message
'' box, open and save panels, the window title, the clipboard, and open a
'' URL.  Everything is objc_msgSend from BASIC - no Objective-C in user code
'' and no compiler feature.
''
''     #include once "frej/macos.bi"
''
''     if FrejMacReady() then
''         FrejClipboardSet "hello"
''         print FrejClipboardGet()
''         FrejAlert "Saved.", "FrejBASIC"
''     end if
''
'' Rules:
''
''  - Call these from the main thread, the one that runs the graphics loop.
''    AppKit is a main-thread API; every function checks with
''    FrejMacIsMainThread() and refuses to touch the UI otherwise.
''  - The UI calls need an NSApplication.  In a graphics program the driver
''    already made one; a console program gets a minimal one on first use.
''    Panels are modal and therefore block until the user answers.
''  - Each call establishes an autorelease pool, so repeated calls do not
''    grow the process.  Objects created with alloc/init are released.
''  - FrejOpenFile and FrejSaveFile return "" when the user cancels.
''  - File type filters are semicolon-separated extensions: "bas;bi".
''
'' This header is macOS-only.  On other platforms the same names exist and
'' report "not ready", so a portable program can include it and branch on
'' FrejMacReady() instead of on compiler platform macros.
''
'' Copyright (c) 2026 the FrejBASIC contributors
'' Distributed under the same terms as the FreeBASIC runtime library.

#ifndef __FREJ_MACOS_BI__
#define __FREJ_MACOS_BI__

#pragma once

#ifdef __FB_DARWIN__

'' ------------------------------------------------------------- runtime --
''
'' The Objective-C runtime is reached through dylibload, not #inclib: these
'' are framework services, not a library the program should have to link,
'' and the graphics driver may already have loaded both images.

type FrejMacGetClass   as function cdecl(byval name as const zstring ptr) as any ptr
type FrejMacSelReg     as function cdecl(byval name as const zstring ptr) as any ptr
type FrejMacPoolPush   as function cdecl() as any ptr
type FrejMacPoolPop    as sub cdecl(byval pool as any ptr)

'' objc_msgSend is variadic, and a variadic call cannot be declared in a way
'' that is correct on both x86_64 and arm64: arm64 passes variadic arguments
'' on the stack.  The portable form is to cast the symbol to the exact
'' signature of each message, which is what these types are for.
type FrejMacMsg0P as function cdecl(byval self as any ptr, byval sel as any ptr) as any ptr
type FrejMacMsg1P as function cdecl(byval self as any ptr, byval sel as any ptr, byval a1 as any ptr) as any ptr
type FrejMacMsg2P as function cdecl(byval self as any ptr, byval sel as any ptr, byval a1 as any ptr, byval a2 as any ptr) as any ptr
type FrejMacMsg0I as function cdecl(byval self as any ptr, byval sel as any ptr) as integer
type FrejMacMsg0B as function cdecl(byval self as any ptr, byval sel as any ptr) as byte
type FrejMacMsg1B as function cdecl(byval self as any ptr, byval sel as any ptr, byval a1 as any ptr) as byte
type FrejMacMsg0V as sub cdecl(byval self as any ptr, byval sel as any ptr)
type FrejMacMsg1V as sub cdecl(byval self as any ptr, byval sel as any ptr, byval a1 as any ptr)
type FrejMacMsg2V as sub cdecl(byval self as any ptr, byval sel as any ptr, byval a1 as any ptr, byval a2 as any ptr)

dim shared frej_mac_state      as integer = 0   '' 0 = untouched, 1 = ready, 2 = failed
dim shared frej_mac_objc_lib   as any ptr
dim shared frej_mac_appkit_lib as any ptr

dim shared frej_mac_getclass   as FrejMacGetClass
dim shared frej_mac_selreg     as FrejMacSelReg
dim shared frej_mac_pool_push  as FrejMacPoolPush
dim shared frej_mac_pool_pop   as FrejMacPoolPop

dim shared frej_mac_msg0p as FrejMacMsg0P
dim shared frej_mac_msg1p as FrejMacMsg1P
dim shared frej_mac_msg2p as FrejMacMsg2P
dim shared frej_mac_msg0i as FrejMacMsg0I
dim shared frej_mac_msg0b as FrejMacMsg0B
dim shared frej_mac_msg1b as FrejMacMsg1B
dim shared frej_mac_msg0v as FrejMacMsg0V
dim shared frej_mac_msg1v as FrejMacMsg1V
dim shared frej_mac_msg2v as FrejMacMsg2V

private function FrejMacInit() as integer
	if frej_mac_state <> 0 then
		if frej_mac_state = 1 then return 1
		return 0
	end if

	frej_mac_state = 2                     '' failed unless everything resolves

	frej_mac_objc_lib = dylibload("libobjc.dylib")
	if frej_mac_objc_lib = 0 then frej_mac_objc_lib = dylibload("/usr/lib/libobjc.A.dylib")
	if frej_mac_objc_lib = 0 then return 0

	frej_mac_getclass = cast(FrejMacGetClass, dylibsymbol(frej_mac_objc_lib, "objc_getClass"))
	frej_mac_selreg   = cast(FrejMacSelReg,   dylibsymbol(frej_mac_objc_lib, "sel_registerName"))

	dim as any ptr poolpush = dylibsymbol(frej_mac_objc_lib, "objc_autoreleasePoolPush")
	dim as any ptr poolpop  = dylibsymbol(frej_mac_objc_lib, "objc_autoreleasePoolPop")
	dim as any ptr msgsend  = dylibsymbol(frej_mac_objc_lib, "objc_msgSend")

	if frej_mac_getclass = 0 orelse frej_mac_selreg = 0 orelse _
		poolpush = 0 orelse poolpop = 0 orelse msgsend = 0 then return 0

	frej_mac_pool_push = cast(FrejMacPoolPush, poolpush)
	frej_mac_pool_pop  = cast(FrejMacPoolPop,  poolpop)

	frej_mac_msg0p = cast(FrejMacMsg0P, msgsend)
	frej_mac_msg1p = cast(FrejMacMsg1P, msgsend)
	frej_mac_msg2p = cast(FrejMacMsg2P, msgsend)
	frej_mac_msg0i = cast(FrejMacMsg0I, msgsend)
	frej_mac_msg0b = cast(FrejMacMsg0B, msgsend)
	frej_mac_msg1b = cast(FrejMacMsg1B, msgsend)
	frej_mac_msg0v = cast(FrejMacMsg0V, msgsend)
	frej_mac_msg1v = cast(FrejMacMsg1V, msgsend)
	frej_mac_msg2v = cast(FrejMacMsg2V, msgsend)

	'' NSPasteboard, NSAlert, NSOpenPanel and NSWorkspace all live here
	frej_mac_appkit_lib = dylibload("/System/Library/Frameworks/AppKit.framework/AppKit")
	if frej_mac_appkit_lib = 0 then return 0

	frej_mac_state = 1
	return 1
end function

private function FrejMacSel(byval s as string) as any ptr
	return frej_mac_selreg(strptr(s))
end function

private function FrejMacClass(byval s as string) as any ptr
	return frej_mac_getclass(strptr(s))
end function

'' NSString from a BASIC string.  The result is autoreleased, so it must be
'' used inside the pool that the public function established.
private function FrejMacNSString(byval s as string) as any ptr
	dim as any ptr klass = FrejMacClass("NSString")
	if klass = 0 then return 0
	return frej_mac_msg1p(klass, FrejMacSel("stringWithUTF8String:"), strptr(s))
end function

private function FrejMacFbString(byval ns as any ptr) as string
	if ns = 0 then return ""
	dim as zstring ptr z = cast(zstring ptr, frej_mac_msg0p(ns, FrejMacSel("UTF8String")))
	if z = 0 then return ""
	return *z
end function

'' [NSApplication sharedApplication], activated so a panel comes to the
'' front.  A graphics program already has the object; a console program gets
'' a minimal one here.
private function FrejMacApp() as any ptr
	dim as any ptr klass = FrejMacClass("NSApplication")
	if klass = 0 then return 0
	dim as any ptr app = frej_mac_msg0p(klass, FrejMacSel("sharedApplication"))
	if app then frej_mac_msg1v(app, FrejMacSel("activateIgnoringOtherApps:"), cast(any ptr, 1))
	return app
end function

'' The key window if there is one, otherwise the first window.  This is what
'' FrejSetTitle and FrejGetTitle operate on; a console program has none.
private function FrejMacWindow() as any ptr
	dim as any ptr app = FrejMacApp()
	if app = 0 then return 0
	dim as any ptr win = frej_mac_msg0p(app, FrejMacSel("mainWindow"))
	if win = 0 then
		dim as any ptr wins = frej_mac_msg0p(app, FrejMacSel("windows"))
		if wins then
			if frej_mac_msg0i(wins, FrejMacSel("count")) > 0 then
				win = frej_mac_msg1p(wins, FrejMacSel("objectAtIndex:"), cast(any ptr, 0))
			end if
		end if
	end if
	return win
end function

'' Semicolon-separated extensions to an NSArray for setAllowedFileTypes:.
'' Deprecated on macOS 12 in favour of UTType, but still honoured by the
'' panels; moving to UTType would mean another dozen runtime classes.
private sub FrejMacSetTypes(byval panel as any ptr, byval types as string)
	if len(types) = 0 then exit sub
	dim as any ptr arr = frej_mac_msg0p(FrejMacClass("NSMutableArray"), FrejMacSel("array"))
	if arr = 0 then exit sub
	dim as string rest = types
	do
		dim as integer p = instr(rest, ";")
		dim as string one = iif(p > 0, left(rest, p - 1), rest)
		if len(one) then frej_mac_msg1v(arr, FrejMacSel("addObject:"), FrejMacNSString(one))
		if p = 0 then exit do
		rest = mid(rest, p + 1)
	loop
	frej_mac_msg1v(panel, FrejMacSel("setAllowedFileTypes:"), arr)
end sub

'' ----------------------------------------------------------------- public --

'' 1 when the Objective-C runtime and AppKit are usable on this machine.
function FrejMacReady() as integer
	return FrejMacInit()
end function

'' 1 when the caller is the main thread.  The UI calls require it.
function FrejMacIsMainThread() as integer
	if FrejMacInit() = 0 then return 0
	dim as any ptr klass = FrejMacClass("NSThread")
	if klass = 0 then return 0
	return frej_mac_msg0b(klass, FrejMacSel("isMainThread"))
end function

'' A modal message box.  Blocks until the user clicks OK; the caller is
'' expected to be drawing, not in the middle of a frame.
sub FrejAlert(byval text as string, byval title as string = "FrejBASIC")
	if FrejMacInit() = 0 then exit sub
	if FrejMacIsMainThread() = 0 then exit sub
	dim as any ptr pool = frej_mac_pool_push()
	if FrejMacApp() then
		dim as any ptr klass = FrejMacClass("NSAlert")
		if klass then
			dim as any ptr a = frej_mac_msg0p(klass, FrejMacSel("alloc"))
			if a then
				a = frej_mac_msg0p(a, FrejMacSel("init"))
				frej_mac_msg1v(a, FrejMacSel("setMessageText:"), FrejMacNSString(title))
				frej_mac_msg1v(a, FrejMacSel("setInformativeText:"), FrejMacNSString(text))
				frej_mac_msg1v(a, FrejMacSel("addButtonWithTitle:"), FrejMacNSString("OK"))
				frej_mac_msg0i(a, FrejMacSel("runModal"))
				frej_mac_msg0v(a, FrejMacSel("release"))
			end if
		end if
	end if
	frej_mac_pool_pop(pool)
end sub

'' Modal open panel.  types is a semicolon-separated extension list ("bas;bi")
'' or "" for everything.  Returns "" when cancelled.
function FrejOpenFile(byval types as string = "") as string
	dim as string result = ""
	if FrejMacInit() = 0 then return ""
	if FrejMacIsMainThread() = 0 then return ""
	dim as any ptr pool = frej_mac_pool_push()
	if FrejMacApp() then
		dim as any ptr panel = frej_mac_msg0p(FrejMacClass("NSOpenPanel"), FrejMacSel("openPanel"))
		if panel then
			frej_mac_msg1v(panel, FrejMacSel("setCanChooseFiles:"), cast(any ptr, 1))
			frej_mac_msg1v(panel, FrejMacSel("setCanChooseDirectories:"), cast(any ptr, 0))
			frej_mac_msg1v(panel, FrejMacSel("setAllowsMultipleSelection:"), cast(any ptr, 0))
			FrejMacSetTypes(panel, types)
			if frej_mac_msg0i(panel, FrejMacSel("runModal")) = 1 then     '' NSModalResponseOK
				dim as any ptr url = frej_mac_msg0p(panel, FrejMacSel("URL"))
				if url then result = FrejMacFbString(frej_mac_msg0p(url, FrejMacSel("path")))
			end if
		end if
	end if
	frej_mac_pool_pop(pool)
	return result
end function

'' Modal save panel.  suggested is the initial file name ("" for the panel's
'' default); types is as in FrejOpenFile.  Returns "" when cancelled.
function FrejSaveFile(byval suggested as string = "", byval types as string = "") as string
	dim as string result = ""
	if FrejMacInit() = 0 then return ""
	if FrejMacIsMainThread() = 0 then return ""
	dim as any ptr pool = frej_mac_pool_push()
	if FrejMacApp() then
		dim as any ptr panel = frej_mac_msg0p(FrejMacClass("NSSavePanel"), FrejMacSel("savePanel"))
		if panel then
			if len(suggested) then
				frej_mac_msg1v(panel, FrejMacSel("setNameFieldStringValue:"), FrejMacNSString(suggested))
			end if
			FrejMacSetTypes(panel, types)
			if frej_mac_msg0i(panel, FrejMacSel("runModal")) = 1 then     '' NSModalResponseOK
				dim as any ptr url = frej_mac_msg0p(panel, FrejMacSel("URL"))
				if url then result = FrejMacFbString(frej_mac_msg0p(url, FrejMacSel("path")))
			end if
		end if
	end if
	frej_mac_pool_pop(pool)
	return result
end function

'' The window title.  A console program, or a graphics program before the
'' window exists, gets "".
function FrejGetTitle() as string
	if FrejMacInit() = 0 then return ""
	if FrejMacIsMainThread() = 0 then return ""
	dim as string result = ""
	dim as any ptr pool = frej_mac_pool_push()
	dim as any ptr win = FrejMacWindow()
	if win then result = FrejMacFbString(frej_mac_msg0p(win, FrejMacSel("title")))
	frej_mac_pool_pop(pool)
	return result
end function

'' Set the window title; no-op when there is no window (console program).
sub FrejSetTitle(byval s as string)
	if FrejMacInit() = 0 then exit sub
	if FrejMacIsMainThread() = 0 then exit sub
	dim as any ptr pool = frej_mac_pool_push()
	dim as any ptr win = FrejMacWindow()
	if win then frej_mac_msg1v(win, FrejMacSel("setTitle:"), FrejMacNSString(s))
	frej_mac_pool_pop(pool)
end sub

'' The general pasteboard as text; "" when it holds no plain text.
function FrejClipboardGet() as string
	if FrejMacInit() = 0 then return ""
	dim as string result = ""
	dim as any ptr pool = frej_mac_pool_push()
	dim as any ptr pb = frej_mac_msg0p(FrejMacClass("NSPasteboard"), FrejMacSel("generalPasteboard"))
	if pb then
		dim as any ptr typ = FrejMacNSString("public.utf8-plain-text")
		result = FrejMacFbString(frej_mac_msg1p(pb, FrejMacSel("stringForType:"), typ))
	end if
	frej_mac_pool_pop(pool)
	return result
end function

'' Replace the general pasteboard with plain text.
sub FrejClipboardSet(byval s as string)
	if FrejMacInit() = 0 then exit sub
	dim as any ptr pool = frej_mac_pool_push()
	dim as any ptr pb = frej_mac_msg0p(FrejMacClass("NSPasteboard"), FrejMacSel("generalPasteboard"))
	if pb then
		frej_mac_msg0i(pb, FrejMacSel("clearContents"))
		frej_mac_msg2v(pb, FrejMacSel("setString:forType:"), _
			FrejMacNSString(s), FrejMacNSString("public.utf8-plain-text"))
	end if
	frej_mac_pool_pop(pool)
end sub

'' Open a URL with the system's default handler.  Returns 1 when the URL was
'' handed over, 0 when it was rejected.  Note that this really does launch the
'' handler (browser, mail client, ...).
function FrejOpenURL(byval url as string) as integer
	if FrejMacInit() = 0 then return 0
	dim as integer ok = 0
	dim as any ptr pool = frej_mac_pool_push()
	dim as any ptr nsurl = frej_mac_msg1p(FrejMacClass("NSURL"), FrejMacSel("URLWithString:"), FrejMacNSString(url))
	if nsurl then
		dim as any ptr ws = frej_mac_msg0p(FrejMacClass("NSWorkspace"), FrejMacSel("sharedWorkspace"))
		if ws then ok = frej_mac_msg1b(ws, FrejMacSel("openURL:"), nsurl)
	end if
	frej_mac_pool_pop(pool)
	return ok
end function

#else

'' The same names on other platforms, so a portable program can include this
'' header everywhere and branch on FrejMacReady() once.

function FrejMacReady() as integer
	return 0
end function

function FrejMacIsMainThread() as integer
	return 0
end function

sub FrejAlert(byval text as string, byval title as string = "FrejBASIC")
end sub

function FrejOpenFile(byval types as string = "") as string
	return ""
end function

function FrejSaveFile(byval suggested as string = "", byval types as string = "") as string
	return ""
end function

function FrejGetTitle() as string
	return ""
end function

sub FrejSetTitle(byval s as string)
end sub

function FrejClipboardGet() as string
	return ""
end function

sub FrejClipboardSet(byval s as string)
end sub

function FrejOpenURL(byval url as string) as integer
	return 0
end function

#endif '' __FB_DARWIN__

#endif '' __FREJ_MACOS_BI__
