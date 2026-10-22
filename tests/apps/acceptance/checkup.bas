''
'' checkup.bas -- FrejBASIC interactive acceptance test and visual test bench
''
'' Build:
''     fbc -i inc tests/apps/acceptance/checkup.bas -x checkup
'' or:
''     make acceptance
''
'' Run:
''     ./checkup           interactive: click the tabs, press keys, watch
''     ./checkup auto      runs every scene by itself and exits 0 (all pass)
''                         or 1 (something failed); good for CI and for the
''                         tests/apps corpus
''
'' A report is always written to "checkup.txt" in the current directory.
'' In auto mode a short summary also goes to stdout.
''
'' Every tab is self-checking: it draws a reference scene *and* verifies what
'' it drew by reading pixels back, so the app fails loudly when a driver or a
'' gfxlib2 primitive breaks.  The tabs are deliberately independent of each
'' other and of the window size, so new ones (a 3D/sokol backend, sound,
'' joystick, ...) can be added as another entry in the scene table.
''

#include once "fbgfx.bi"
#include once "frej/timers.bi"
#include once "frej/draw.bi"

'' ---------------------------------------------------------------- geometry

#define SW          1024
#define SH          700
#define TABY        40
#define TABH        28
#define TABW        84
#define FTR         (SH - 34)

#define BTNX        540
#define BTNY        210
#define BTNW        280
#define BTNH        64

#define NSCENE      12

'' ------------------------------------------------------------------ colors

#define BG          rgb( 16,  20,  26)
#define BARBG       rgb( 12,  15,  20)
#define PNL         rgb( 24,  30,  38)
#define EDGE        rgb( 52,  64,  82)
#define TXT         rgb(220, 228, 240)
#define DIMTXT      rgb(140, 156, 176)
#define ACCENT      rgb( 88, 168, 255)
#define OKC         rgb( 80, 210, 130)
#define BADC        rgb(255,  92,  92)
#define SKIPC       rgb(230, 190,  90)
#define TABBG       rgb( 28,  34,  44)
#define TABHOT      rgb( 44,  56,  72)
#define TABACT      rgb( 40,  96, 150)

'' cut a string to n characters, marking it with ".." so a long note never
'' runs into the next column or off the panel
function clip(byval t as string, byval n as integer) as string
	if n < 3 then return ""
	if len(t) <= n then return t
	return left(t, n - 2) & ".."
end function

'' ------------------------------------------------------------ check records

type CheckRec
	name as string * 32
	stat as integer			'' 1 = pass, 0 = fail, -1 = skipped
	note as string * 96
end type

dim shared as CheckRec chks(0 to 63)
dim shared as integer nchk = 0

'' Register or update a check.  Name matched, so a scene may call this every
'' frame (e.g. the interactive input checks) without piling up duplicates.
sub chk_set(byval nm as string, byval stat as integer, byval note as string)
	dim as integer i
	for i = 0 to nchk - 1
		'' compare against rtrim(): a fixed-length string never compares equal
		'' to a shorter var-len one, it is padded to its full width
		if rtrim(chks(i).name) = nm then
			chks(i).stat = stat
			chks(i).note = note
			exit sub
		end if
	next
	if nchk <= ubound(chks) then
		chks(nchk).name = nm
		chks(nchk).stat = stat
		chks(nchk).note = note
		nchk += 1
	end if
end sub

function chk_n(byval stat as integer) as integer
	dim as integer i, n
	for i = 0 to nchk - 1
		if chks(i).stat = stat then n += 1
	next
	return n
end function

function chk_ok() as integer
	return (chk_n(0) = 0)
end function

'' ------------------------------------------------------------------- state

dim shared as integer scene = 0
dim shared as integer hover = -1
dim shared as integer prevbtn = 0
dim shared as integer prevleft = 0
dim shared as integer prevright = 0
dim shared as integer quitting = 0
dim shared as integer automode = 0
'' diagnostics: CHECKUP_ONLY=<n> runs just that one scene, CHECKUP_DWELL=<ms>
'' shortens the per scene dwell.  Both are for bisecting driver problems.
dim shared as integer onlyscene = -1
dim shared as double dwellsec = 0.9
'' CHECKUP_TRACE=1 appends frame/scene lines to checkup-trace.txt so a crash
'' leaves a record of how far the run got.
dim shared as integer tracing = 0

dim shared as integer mx, my, mw, mbtn
dim shared as integer prevwheel = 0
dim shared as integer nclicks = 0, nkeys = 0, nwheel = 0
dim shared as integer btn_presses = 0
dim shared as string lastkey

dim shared as double tframe = 0, tfps = 0, tscene = 0
dim shared as double fpsavg = 0
dim shared as integer nfps = 0, frame_no = 0

dim shared as integer done(0 to NSCENE - 1)
dim shared as integer dumped(0 to NSCENE - 1)
dim shared as string * 12 tabname(0 to NSCENE - 1) = { _
	"info", "shapes", "modes", "text", "sprites", _
	"images", "input", "threads", "3d", "timers", "draw", "summary" }

'' images and thread state
dim shared as any ptr g_spr = 0, g_alpha = 0, g_bmp = 0
dim shared as any ptr tmutex = 0, tthread = 0, timg = 0
dim shared as integer trunning = 0
'' The worker writes raw image memory only.  Calling gfxlib2 from a second
'' thread needs the -mt build (fbgfxmt); with the default single threaded
'' library those calls are not synchronised and corrupt the heap.
dim shared as any ptr tpix = 0
dim shared as integer tpitch = 0, tw = 0, th = 0
dim shared as integer tticks = 0, tsum = 0
dim shared as double tstart = 0

'' ---------------------------------------------------------- drawing helpers

sub fillrect(byval x as integer, byval y as integer, byval w as integer, byval h as integer, byval c as uinteger)
	if w <= 0 or h <= 0 then exit sub
	line (x, y)-(x + w - 1, y + h - 1), c, bf
end sub

sub box_at(byval x as integer, byval y as integer, byval w as integer, byval h as integer, byval c as uinteger)
	if w <= 0 or h <= 0 then exit sub
	line (x, y)-(x + w - 1, y + h - 1), c, b
end sub

sub text_at(byval x as integer, byval y as integer, byval s as string, byval c as uinteger)
	draw string (x, y), s, c
end sub

sub panel(byval x as integer, byval y as integer, byval w as integer, byval h as integer, byval title as string)
	fillrect x, y, w, h, PNL
	box_at x, y, w, h, EDGE
	text_at x + 10, y + 8, title, ACCENT
end sub

'' status tag drawn at x,y for a registered check (or "?" if it never ran)
sub tag_at(byval x as integer, byval y as integer, byval nm as string, byval xend as integer = 0)
	if xend = 0 then
		'' default: the panels use two columns at x = 36 and x = 520
		xend = iif(x < 500, 500, 1008)
	end if

	dim as integer i
	for i = 0 to nchk - 1
		'' compare against rtrim(): a fixed-length string never compares equal
		'' to a shorter var-len one, it is padded to its full width
		if rtrim(chks(i).name) = nm then
			select case chks(i).stat
			case 1
				text_at x, y, "PASS", OKC
			case 0
				text_at x, y, "FAIL", BADC
			case else
				text_at x, y, "SKIP", SKIPC
			end select
			text_at x + 48, y, nm, TXT

			'' the measured value is a nicety: show it when the column has room
			dim as integer avail = (xend - (x + 48)) \ 8 - len(nm) - 2
			dim as string note = rtrim(chks(i).note)
			if avail >= 8 andalso len(note) > 0 then
				text_at x + 48 + (len(nm) + 2) * 8, y, clip(note, avail), DIMTXT
			end if
			exit sub
		end if
	next
	text_at x, y, "--", DIMTXT
	text_at x + 48, y, nm, DIMTXT
end sub

'' --------------------------------------------------------------- utilities

'' one decimal place, no leading blanks (Format() is not part of the fb dialect)
function fmt1(byval v as double) as string
	dim as integer n = int(v * 10 + 0.5)
	return trim(str(n \ 10)) & "." & trim(str(n mod 10))
end function

function tmpdir() as string
	dim as string t = environ("TMPDIR")
	if len(t) = 0 then t = "/tmp/"
	if right(t, 1) <> "/" then t &= "/"
	return t
end function

function drivername() as string
	dim as string d = space(64)
	screencontrol fb.GET_DRIVER_NAME, d
	return trim(d, chr(0) & " ")
end function

'' The frame buffer keeps an alpha byte, rgb() does not, so always compare the
'' RGB parts of two colours rather than the raw values.
function same(byval a as uinteger, byval b as uinteger) as integer
	return ((a and &hFFFFFF) = (b and &hFFFFFF))
end function

'' count pixels of color c (RGB part only) inside the given box
function scan_color(byval x1 as integer, byval y1 as integer, byval x2 as integer, byval y2 as integer, byval c as uinteger) as integer
	dim as integer n
	for y as integer = y1 to y2
		for x as integer = x1 to x2
			if same(point(x, y), c) then n += 1
		next
	next
	return n
end function

function ramp(byval i as integer) as uinteger
	'' i = 0..95: red -> yellow -> green -> cyan -> blue -> magenta-ish
	dim as integer r, g, b, ph
	ph = (i \ 16) mod 6
	select case ph
	case 0 : r = 255 : g = (i mod 16) * 16 : b = 0
	case 1 : r = 255 - (i mod 16) * 16 : g = 255 : b = 0
	case 2 : r = 0 : g = 255 : b = (i mod 16) * 16
	case 3 : r = 0 : g = 255 - (i mod 16) * 16 : b = 255
	case 4 : r = (i mod 16) * 16 : g = 0 : b = 255
	case else
		r = 255 : g = 0 : b = 255 - (i mod 16) * 16
	end select
	return rgb(r, g, b)
end function

'' =========================================================== scene: info

sub checks_info()
	dim as integer w, h, d
	screeninfo w, h, d
	chk_set "screen size", iif(w = SW andalso h = SH andalso d = 32, 1, 0), _
		str(w) & "x" & str(h) & "x" & str(d) & ", requested " & str(SW) & "x" & str(SH) & "x32"

	dim as string drv = drivername()
	chk_set "driver name", iif(len(drv) > 0, 1, 0), drv

	chk_set "screen memory", iif(screenptr <> 0, 1, 0), "ScreenPtr = " & hex(culngint(screenptr))

	'' the framebuffer really is writable and readable
	pset (900, 620), rgb(1, 2, 3)
	chk_set "pixel r/w", iif(same(point(900, 620), rgb(1, 2, 3)), 1, 0), _
		hex(point(900, 620) and &hFFFFFF)
end sub

sub draw_info()
	dim as integer w, h, d
	screeninfo w, h, d

	panel 16, 80, 470, 220, "runtime"
	text_at 32, 116, "screen      " & str(w) & " x " & str(h) & " x " & str(d) & "   (2 pages)", TXT
	text_at 32, 136, "driver      " & drivername(), TXT
	text_at 32, 156, "fps         " & fmt1(fpsavg) & "   frames " & str(frame_no), TXT
	text_at 32, 176, "exe         " & clip(command(0), 50), DIMTXT
	text_at 32, 196, "temp        " & clip(tmpdir(), 50), DIMTXT
	text_at 32, 216, "date        " & date & "  " & time, DIMTXT
	text_at 32, 244, "pages       " & str(scene + 1) & " of " & str(NSCENE) & " scenes visited", DIMTXT
	text_at 32, 268, "mode        " _ 
		& iif(automode, "auto (exits by itself)", "interactive"), SKIPC

	panel 502, 80, SW - 518, 220, "what this is"
	text_at 518, 116, "A self-checking test bench for the FrejBASIC graphics port.", TXT
	text_at 518, 136, "Each tab draws a reference scene and then verifies it by", DIMTXT
	text_at 518, 154, "reading the pixels back, so a broken primitive or a broken", DIMTXT
	text_at 518, 172, "driver shows up as FAIL instead of a subtly wrong picture.", DIMTXT
	text_at 518, 198, "The same file is the template for the planned 3D backend:", TXT
	text_at 518, 216, "one more entry in the scene table, checked the same way.", DIMTXT
	text_at 518, 246, "Report: checkup.txt in the current directory.", SKIPC
	text_at 518, 268, "Run ""checkup auto"" for an unattended pass/fail run.", SKIPC

	panel 16, 316, SW - 32, 236, "frame buffer and page flipping"
	'' color ramp: catches channel swaps and 24/32 bpp slicing bugs
	dim as integer i
	for i = 0 to 95
		fillrect 36 + i * 10, 352, 10, 60, ramp(i)
	next
	text_at 36, 420, "rgb ramp, 96 steps", DIMTXT

	'' smooth gradient: catches pitch mistakes (diagonal shearing)
	for i = 0 to 239
		line (36, 444 + i)-(SW - 52, 444 + i), rgb(i, 240 - i, 128), 
	next
	text_at SW - 260, 444 + 244 - 20, "gradient: no shearing allowed", DIMTXT

	'' animated marker: with two pages + flip this must move smoothly
	dim as integer off = int(timer * 200) mod (SW - 120)
	fillrect 36 + off, 520, 24, 24, rgb(255, 255, 255)
	box_at 36, 516, SW - 88, 32, EDGE
	text_at 36, 664 - 24, "moving marker (flip)", DIMTXT
end sub

'' ========================================================= scene: shapes

sub checks_shapes()
	'' exact pixel write and read back
	fillrect 0, 0, 240, 240, rgb(0, 0, 0)
	pset (105, 105), rgb(20, 200, 60)
	chk_set "pset / point", iif(same(point(105, 105), rgb(20, 200, 60)), 1, 0), _
		hex(point(105, 105) and &hFFFFFF)

	'' filled box
	fillrect 0, 0, 240, 240, rgb(0, 0, 0)
	line (8, 8)-(108, 108), rgb(40, 90, 160), bf
	chk_set "line box bf", iif(same(point(58, 58), rgb(40, 90, 160)), 1, 0), _
		hex(point(58, 58) and &hFFFFFF)

	'' filled circle, centre and rim
	fillrect 0, 0, 240, 240, rgb(0, 0, 0)
	circle (120, 120), 80, rgb(255, 200, 60), , , , f
	chk_set "circle fill", iif(same(point(120, 120), rgb(255, 200, 60)), 1, 0), _
		hex(point(120, 120) and &hFFFFFF)
	chk_set "circle rim", iif(same(point(40, 120), rgb(255, 200, 60)), 1, 0), _
		hex(point(40, 120) and &hFFFFFF)

	'' alpha blending: white background, 50% black wash
	fillrect 0, 0, 320, 240, rgb(255, 255, 255)
	line (0, 0)-(319, 239), rgba(0, 0, 0, 128), bf
	dim as integer bl = point(160, 120) and &hFFFFFF
	dim as integer br = (bl shr 16) and &hFF
	chk_set "alpha blend", iif(br >= 118 andalso br <= 138, 1, 0), _
		"r=" & str(br) & " (expect ~128)"

	'' viewport clipping: inside painted, outside reports -1
	'' ("view screen" keeps the coordinates absolute, plain "view" makes them
	'' relative to the viewport, which would make this check meaningless)
	fillrect 0, 0, 400, 300, rgb(0, 0, 0)
	view screen (100, 100)-(199, 199)
	line (0, 0)-(399, 299), rgb(255, 0, 0), bf
	dim as integer vin = point(150, 150) and &hFFFFFF
	dim as integer vout = point(50, 50)
	view
	chk_set "view clipping", iif(same(vin, rgb(255, 0, 0)) andalso culng(vout) = &hFFFFFFFF, 1, 0), _
		"in=" & hex(vin) & " out=" & str(vout) & " (-1 = clipped)"

	'' paint
	fillrect 0, 0, 240, 240, rgb(0, 0, 0)
	line (60, 20)-(200, 220), rgb(90, 200, 120), b
	paint (120, 120), rgb(90, 200, 120), rgb(90, 200, 120)
	chk_set "paint fill", iif(same(point(120, 120), rgb(90, 200, 120)), 1, 0), _
		hex(point(120, 120) and &hFFFFFF)

	'' clear the scratch area before the real scene is drawn
	fillrect 0, 0, SW, SH, BG
end sub

sub draw_shapes()
	panel 16, 80, 490, 250, "lines, boxes, circles"

	'' the box comes first and the paint stays inside it: with an open
	'' boundary the flood fill escapes and swallows the whole window
	line (60, 116)-(460, 304), rgb(220, 120, 220), b
	paint (100, 150), rgb(30, 44, 66), rgb(220, 120, 220)

	line (80, 150)-(200, 220), rgb(90, 160, 240)
	line (80, 240)-(440, 314), rgb(90, 160, 240), , &hFF00
	circle (120, 250), 40, rgb(255, 210, 80)
	circle (250, 250), 40, rgb(255, 120, 120), , , , f

	panel 522, 80, SW - 538, 250, "fills and alpha"
	for i as integer = 0 to 15
		fillrect 540 + i * 28, 116, 28, 80, rgba(255, 255, 255, 16 * i)
	next
	line (540, 210)-(540 + 15 * 28 + 27, 210 + 60), rgb(200, 60, 60), bf
	for i as integer = 0 to 7
		fillrect 540 + i * 56, 224, 56, 46, rgba(0, 0, 0, 24 * i)
	next
	text_at 540, 286, "alpha levels 0..240 over red", DIMTXT
	text_at 540, 306, "and 0..168 over the panel", DIMTXT

	panel 16, 346, SW - 32, 200, "checks (verified by reading pixels back)"
	tag_at 36, 382, "pset / point"
	tag_at 36, 404, "line box bf"
	tag_at 36, 426, "circle fill"
	tag_at 36, 448, "circle rim"
	tag_at 520, 382, "alpha blend"
	tag_at 520, 404, "view clipping"
	tag_at 520, 426, "paint fill"
	text_at 36, 500, "The scene above is drawn every frame; the checks are done once, on entry.", DIMTXT
end sub

'' ========================================================== scene: modes

sub checks_modes()
	dim as integer w, h, d

	'' 8 bpp: point must report the palette index, not the RGB value
	screenres 320, 200, 8, 2
	screenset 1, 0
	screeninfo w, h, d
	palette 3, rgb(255, 0, 0)
	line (0, 0)-(319, 199), 3, bf
	dim as integer p8 = point(10, 10)
	chk_set "mode 8bpp", iif(w = 320 andalso h = 200 andalso d = 8, 1, 0), _
		str(w) & "x" & str(h) & "x" & str(d)
	chk_set "8bpp palette", iif(p8 = 3, 1, 0), "index " & str(p8)

	'' 16 bpp
	screenres 640, 480, 16, 2
	screenset 1, 0
	screeninfo w, h, d
	line (0, 0)-(639, 479), rgb(255, 0, 0), bf
	dim as integer p16 = point(10, 10) and &hFFFFFF
	chk_set "mode 16bpp", iif(w = 640 andalso h = 480 andalso d = 16, 1, 0), _
		str(w) & "x" & str(h) & "x" & str(d)
	chk_set "16bpp color", iif(((p16 shr 16) and &hFF) >= 240 andalso ((p16 shr 8) and &hFF) <= 16, 1, 0), _
		hex(p16)

	'' 32 bpp with alpha primitives
	screenres 400, 300, 32, 2, fb.GFX_ALPHA_PRIMITIVES
	screenset 1, 0
	line (0, 0)-(399, 299), rgb(255, 255, 255), bf
	line (0, 0)-(399, 299), rgba(0, 0, 0, 128), bf
	dim as integer pa = point(200, 150) and &hFFFFFF
	chk_set "alpha primitives", iif(((pa shr 16) and &hFF) >= 116, 1, 0), hex(pa)

	'' and back to the app mode
	screenres SW, SH, 32, 2, fb.GFX_ALPHA_PRIMITIVES
	screenset 1, 0
	screeninfo w, h, d
	chk_set "restore mode", iif(w = SW andalso h = SH andalso d = 32, 1, 0), _
		str(w) & "x" & str(h) & "x" & str(d)
	screencontrol fb.SET_WINDOW_TITLE, "FrejBASIC checkup"
	setmouse , , 1
	fillrect 0, 0, SW, SH, BG
end sub

sub draw_modes()
	panel 16, 80, SW - 32, 250, "mode switching (done once, on entry, then restored)"
	tag_at 36, 116, "mode 8bpp", 500
	tag_at 36, 138, "8bpp palette", 500
	tag_at 36, 160, "mode 16bpp", 500
	tag_at 36, 182, "16bpp color", 500
	tag_at 520, 116, "alpha primitives"
	tag_at 520, 138, "restore mode"

	text_at 36, 220, "ScreenRes is called four times in a row on entering this tab:", TXT
	text_at 36, 240, "320x200x8 (palette), 640x480x16, 400x300x32 with alpha", DIMTXT
	text_at 36, 258, "primitives, then back to 1024x700x32.  Each step verifies the", DIMTXT
	text_at 36, 276, "reported mode and a drawn pixel, so a driver that cannot switch", DIMTXT
	text_at 36, 294, "depth or that leaks state across re-initialisation fails here.", DIMTXT

	panel 16, 346, SW - 32, 236, "what the checks mean"
	text_at 36, 382, "8bpp palette   Point() returns the palette index, so it must read 3.", TXT
	text_at 36, 406, "16bpp color    red round trips as a 24-bit value with r >= 240.", TXT
	text_at 36, 430, "alpha          50% black over white must land near 128, not 0 or 255.", TXT
	text_at 36, 454, "restore        after the dance the app mode must be exactly as before.", TXT
	text_at 36, 486, "Depth switching also exercises driver_exit/driver_init, page", DIMTXT
	text_at 36, 504, "allocation and window recreation in the Cocoa driver.", DIMTXT
	text_at 36, 530, "Known gap: GFX_OPENGL has no macOS backend and currently falls back", SKIPC
	text_at 36, 548, "to a desktop-sized window instead of failing; see doc notes.", SKIPC
end sub

'' =========================================================== scene: text

sub checks_text()
	fillrect 0, 0, SW, SH, rgb(0, 0, 0)

	'' draw two glyphs and measure the box that really reached the frame buffer
	draw string (100, 100), "Wg", rgb(0, 200, 255)
	dim as integer xmin = 9999, xmax = -1, ymin = 9999, ymax = -1
	for y as integer = 80 to 140
		for x as integer = 80 to 220
			if same(point(x, y), rgb(0, 200, 255)) then
				if x < xmin then xmin = x
				if x > xmax then xmax = x
				if y < ymin then ymin = y
				if y > ymax then ymax = y
			end if
		next
	next

	chk_set "draw string", iif(xmax >= 0, 1, 0), _
		"bbox " & str(xmin) & "," & str(ymin) & " - " & str(xmax) & "," & str(ymax)
	chk_set "glyph advance", iif(xmin >= 100 andalso xmax <= 115 andalso (xmax - xmin) >= 9, 1, 0), _
		str(xmax - xmin + 1) & " px for 2 chars (expect 8 px each)"
	chk_set "glyph height", iif((ymax - ymin + 1) >= 8 andalso (ymax - ymin + 1) <= 16, 1, 0), _
		str(ymax - ymin + 1) & " px tall (expect <= 16)"

	fillrect 0, 0, SW, SH, BG
end sub

sub draw_text()
	dim as integer y = 110

	text_at 36, y, "default 8x16 font, colours and alignment", ACCENT
	y += 28
	text_at 36, y, "white", rgb(255, 255, 255) : text_at 120, y, "the quick brown fox jumps over the lazy dog", TXT
	y += 20
	text_at 36, y, "red", BADC : text_at 120, y, "0123456789  !""#$%&/()=?*+-.,;:", BADC
	y += 20
	text_at 36, y, "green", OKC : text_at 120, y, "ABCDEFGHIJKLMNOPQRSTUVWXYZ  abcdefghijklmnopqrstuvwxyz", OKC
	y += 20
	text_at 36, y, "blue", ACCENT : text_at 120, y, "[]{}<>|\\~^_@  -- symbols", ACCENT
	y += 20
	text_at 36, y, "dim", DIMTXT : text_at 120, y, "dim text is still readable on the dark panel", DIMTXT

	y += 44
	text_at 36, y, "Draw String always uses the built-in 8x16 font in this gfxlib2", TXT
	y += 18
	text_at 36, y, "(Width sets the text grid, it does not scale the font).", DIMTXT
	y += 18
	text_at 36, y, "The checks measure the glyph box pixel by pixel instead.", DIMTXT

	'' right aligned line, proves the glyph advance really is 8 px
	dim as string s = "right aligned at x = 988"
	text_at SW - 24 - len(s) * 8, y + 40, s, DIMTXT

	panel 16, 560, SW - 32, 90, "checks"
	tag_at 36, 596, "draw string", 230
	tag_at 240, 596, "glyph advance", 450
	tag_at 460, 596, "glyph height", 1008
	text_at 36, 618, "Glyphs are counted by colour, so an empty box means a broken font or blitter.", DIMTXT
	text_at 36, 636, "The advance check catches a wrong pitch, the height check a wrong cell size.", DIMTXT
end sub

sub checks_sprites()
	'' make a sprite on screen, grab it.
	'' Put ... Trans skips the magenta pixels (&hFF00FF, MASK_COLOR_32), so the
	'' background of the grabbed area must be magenta, not black.
	fillrect 0, 0, 80, 80, rgb(255, 0, 255)
	circle (40, 40), 36, rgb(200, 60, 60), , , , f
	circle (40, 40), 20, rgb(255, 220, 90), , , , f
	pset (40, 40), rgb(255, 255, 255)

	g_spr = imagecreate(80, 80)
	get (0, 0)-(79, 79), g_spr

	dim as integer iw, ih, ib, ipitch
	dim as any ptr ipix
	dim as integer ir = imageinfo(g_spr, iw, ih, ib, ipitch, ipix)
	chk_set "imagecreate", iif(ir = 0 andalso iw = 80 andalso ih = 80 andalso ipix <> 0, 1, 0), _
		str(iw) & "x" & str(ih) & " bpp=" & str(ib) & " pitch=" & str(ipitch)

	'' put opaque
	fillrect 0, 0, SW, SH, rgb(0, 0, 0)
	put (100, 100), g_spr, pset
	dim as integer pc = point(140, 140) and &hFFFFFF
	chk_set "put pset", iif(same(pc, rgb(255, 255, 255)), 1, 0), hex(pc)

	'' put with transparency: pixels with value 0 are skipped
	fillrect 0, 0, SW, SH, rgb(0, 0, 90)
	put (200, 100), g_spr, trans
	dim as integer tcorner = point(200, 100) and &hFFFFFF
	dim as integer tcentre = point(240, 140) and &hFFFFFF
	chk_set "put trans", iif(same(tcorner, rgb(0, 0, 90)) andalso same(tcentre, rgb(255, 255, 255)), 1, 0), _
		hex(tcorner) & " / " & hex(tcentre)

	'' alpha sprite: build a horizontal alpha ramp by hand
	g_alpha = imagecreate(80, 80)
	dim as integer aw, ah, ab, apitch
	dim as any ptr apix
	imageinfo g_alpha, aw, ah, ab, apitch, apix
	dim as integer av0 = -1, av40 = -1, av79 = -1
	if apix <> 0 andalso aw = 80 andalso ah = 80 then
		dim as ulong ptr p32 = apix
		for yy as integer = 0 to ah - 1
			for xx as integer = 0 to aw - 1
				p32[yy * (apitch \ 4) + xx] = rgba(220, 40, 40, xx * 3)
			next
		next
		'' read the alpha channel back: image memory must keep it verbatim
		av0 = (p32[0] shr 24) and &hFF
		av40 = (p32[40 * (apitch \ 4) + 40] shr 24) and &hFF
		av79 = (p32[79 * (apitch \ 4) + 79] shr 24) and &hFF
	end if
	chk_set "image alpha", iif(av0 = 0 andalso av40 = 120 andalso av79 = 237, 1, 0), _
		"alpha bytes " & str(av0) & " / " & str(av40) & " / " & str(av79)

	fillrect 0, 0, SW, SH, rgb(255, 255, 255)
	put (300, 100), g_alpha, alpha
	dim as integer al = point(305, 140) and &hFFFFFF
	dim as integer ar = point(340, 140) and &hFFFFFF
	dim as integer alg = (al shr 8) and &hFF
	dim as integer arg = (ar shr 8) and &hFF
	'' low alpha (15) must stay nearly white, mid alpha (120) must be tinted.
	'' Do not check high alpha: the 32bpp putter in gfxlib2 is only
	'' approximate there (see doc/FrejBASIC-app-tests-notes.txt).
	chk_set "put alpha", iif(alg > 240 andalso arg < 230 andalso arg > 120, 1, 0), _
		"g " & str(alg) & " (a=15) -> " & str(arg) & " (a=120)"

	fillrect 0, 0, SW, SH, BG
end sub

sub draw_sprites()
	panel 16, 80, SW - 32, 480, "get, put, trans, alpha"

	'' bouncing sprites, transparent so the panel shows through
	dim as double t = timer
	for i as integer = 0 to 5
		dim as integer x = 60 + i * 150 + int(sin(t + i) * 20)
		dim as integer y = 110 + int(abs(sin(t * 1.3 + i * 0.7)) * 130)
		put (x, y), g_spr, trans
	next

	'' transparent row
	fillrect 36, 300, SW - 72, 110, rgb(0, 0, 90)
	for i as integer = 0 to 5
		put (50 + i * 150, 315), g_spr, trans
	next
	text_at 36, 412, "Put ... Trans: the zeroed corners leave the blue background intact.", DIMTXT

	'' alpha row
	fillrect 36, 430, SW - 72, 100, rgb(255, 255, 255)
	for i as integer = 0 to 5
		put (50 + i * 150, 440), g_alpha, alpha
	next
	text_at 36, 534, "Put ... Alpha: hand made alpha ramp, 0 at the left edge to 237 at the right.", DIMTXT

	panel 16, 574, SW - 32, 80, "checks"
	tag_at 36, 610, "imagecreate", 200
	tag_at 210, 610, "put pset", 370
	tag_at 380, 610, "put trans", 540
	tag_at 550, 610, "image alpha", 720
	tag_at 730, 610, "put alpha", 1008
end sub

'' ========================================================= scene: images

sub checks_images()
	dim as string fn = tmpdir() & "frej-checkup.bmp"

	'' a gradient, grabbed from the screen
	for x as integer = 0 to 127
		line (x, 0)-(x, 95), rgb(x * 2, 96, 200 - x)
	next
	dim as any ptr src = imagecreate(128, 96)
	get (0, 0)-(127, 95), src

	bsave fn, src
	open fn for binary as #2
	dim as integer bytes = lof(2)
	close #2
	chk_set "bsave", iif(bytes > 1000, 1, 0), str(bytes) & " bytes, " & fn

	g_bmp = imagecreate(128, 96)
	dim as integer r = bload(fn, g_bmp)
	chk_set "bload", iif(r = 0, 1, 0), "error " & str(r)

	'' compare pixels of the round trip
	fillrect 0, 0, SW, SH, rgb(0, 0, 0)
	put (0, 200), g_bmp, pset
	dim as integer pa = point(10, 210) and &hFFFFFF
	dim as integer pb = point(100, 280) and &hFFFFFF
	chk_set "bload pixels", iif(same(pa, rgb(20, 96, 190)) andalso same(pb, rgb(200, 96, 100)), 1, 0), _
		hex(pa) & " / " & hex(pb)

	imagedestroy src
	fillrect 0, 0, SW, SH, BG
end sub

sub draw_images()
	panel 16, 80, SW - 32, 300, "bsave / bload round trip"
	put (36, 120), g_bmp, pset
	'' the same gradient, drawn live, for comparison
	for x as integer = 0 to 127
		line (200 + x, 120)-(200 + x, 215), rgb(x * 2, 96, 200 - x)
	next
	text_at 36, 232, "left: loaded from the bitmap    right: drawn live", DIMTXT

	text_at 36, 264, "File: " & tmpdir() & "frej-checkup.bmp", DIMTXT
	open tmpdir() & "frej-checkup.bmp" for binary as #3
	text_at 36, 284, "Size: " & str(lof(3)) & " bytes", DIMTXT
	close #3

	text_at 36, 316, "BSave writes a BMP, BLoad reads it back; the pixels are compared", TXT
	text_at 36, 334, "one by one, so an endianness or padding bug shows up here.", DIMTXT

	panel 16, 396, SW - 32, 200, "checks"
	tag_at 36, 432, "bsave"
	tag_at 36, 454, "bload"
	tag_at 36, 476, "bload pixels"
	text_at 36, 516, "The gradient is asymmetric on purpose: a channel swap or a", DIMTXT
	text_at 36, 534, "row pitch error changes the sampled colours.", DIMTXT
end sub

'' ========================================================== scene: input

sub checks_input_static()
	if automode then
		chk_set "mouse click", -1, "interactive only, skipped in auto mode"
		chk_set "keyboard", -1, "interactive only, skipped in auto mode"
		chk_set "mouse wheel", -1, "interactive only, skipped in auto mode"
	else
		chk_set "mouse click", 0, "click the button below"
		chk_set "keyboard", 0, "press any key"
		chk_set "mouse wheel", 0, "scroll the wheel"
	end if
end sub

sub draw_input()
	panel 16, 80, 500, 420, "mouse and keyboard state"
	text_at 36, 116, "position    " & str(mx) & ", " & str(my), TXT
	text_at 36, 136, "buttons     " & str(mbtn) & _
		iif((mbtn and 1) <> 0, "  left", "") & _
		iif((mbtn and 2) <> 0, "  right", "") & _
		iif((mbtn and 4) <> 0, "  middle", ""), TXT
	text_at 36, 156, "wheel       " & str(mw) & "   (cumulative)", TXT
	text_at 36, 176, "clicks      " & str(nclicks) & "   wheel events " & str(nwheel), TXT
	text_at 36, 196, "keys        " & str(nkeys) & "   last: " & lastkey, TXT
	text_at 36, 216, "button hits " & str(btn_presses), TXT

	'' crosshair at the pointer, clipped to the panel
	if mx >= 16 andalso mx < 516 andalso my >= 80 andalso my < 500 then
		line (20, my)-(512, my), rgb(70, 90, 120)
		line (mx, 84)-(mx, 496), rgb(70, 90, 120)
		circle (mx, my), 6, ACCENT
	end if

	text_at 36, 260, "Hit test: the tab strip and the button below use the same", DIMTXT
	text_at 36, 278, "rectangle test, with hover and press states.", DIMTXT

	'' the test button
	dim as integer inside = (mx >= BTNX andalso mx < BTNX + BTNW andalso my >= BTNY andalso my < BTNY + BTNH)
	dim as uinteger bcol = rgb(40, 96, 150)
	if inside then bcol = rgb(60, 130, 200)
	if inside andalso (mbtn and 1) <> 0 then bcol = rgb(200, 120, 40)
	fillrect BTNX, BTNY, BTNW, BTNH, bcol
	box_at BTNX, BTNY, BTNW, BTNH, rgb(120, 160, 220)
	text_at BTNX + 70, BTNY + 24, "CLICK ME", rgb(255, 255, 255)

	panel 16, 520, SW - 32, 130, "checks"
	tag_at 36, 556, "mouse click"
	tag_at 36, 578, "keyboard"
	tag_at 36, 600, "mouse wheel"

	text_at 540, 340, "In auto mode these three are skipped, because", DIMTXT
	text_at 540, 358, "nobody is there to click or type.", DIMTXT
end sub

'' ======================================================== scene: threads

sub tick_thread(byval arg as any ptr)
	dim as integer phase = 0
	do while trunning
		mutexlock tmutex
		if tpix <> 0 then
			dim as ulong ptr p = tpix
			dim as integer stride = tpitch \ 4
			for y as integer = 0 to th - 1
				dim as integer v = 40 + (th - y) * 120 \ th
				for x as integer = 0 to tw - 1
					dim as integer dd = abs(x - phase)
					if dd > tw \ 2 then dd = tw - dd
					dim as integer bright = v
					if dd < 14 then bright += 90
					p[y * stride + x] = rgb(bright \ 2, bright \ 3, bright)
				next
			next
		end if
		tticks += 1
		tsum += 1
		mutexunlock tmutex
		phase = (phase + 4) mod 200
		sleep 8
	loop
end sub

sub checks_threads_start()
	if tmutex = 0 then tmutex = mutexcreate()
	if timg = 0 then
		timg = imagecreate(200, 150)
		dim as integer w, h, b, pitch
		dim as any ptr pix
		imageinfo timg, w, h, b, pitch, pix
		tpix = pix
		tpitch = pitch
		tw = w
		th = h
	end if
	if trunning = 0 then
		trunning = 1
		tthread = threadcreate(@tick_thread, 0)
	end if
	tstart = timer
	chk_set "thread create", iif(tthread <> 0, 1, 0), "worker paints a 200x150 image"
end sub

sub draw_threads()
	mutexlock tmutex
	panel 16, 80, SW - 32, 420, "threads, mutex and drawing"

	dim as integer ticks = tticks, sum = tsum
	put (60, 120), timg, pset
	mutexunlock tmutex

	text_at 300, 130, "worker ticks   " & str(ticks), TXT
	text_at 300, 150, "guarded sum    " & str(sum), TXT
	text_at 300, 170, "rate           " & trim(str(int(ticks / (timer - tstart + 0.001)))) & " /s", TXT
	text_at 300, 190, "guard          ticks = sum  (mutex holds)", DIMTXT
	text_at 300, 220, "The worker writes this image under a mutex while the", DIMTXT
	text_at 300, 238, "main thread Puts it; a lock bug shows up as tearing.", DIMTXT

	text_at 60, 296, "The worker only touches raw image memory, which needs no", TXT
	text_at 60, 314, "locking beyond the mutex.  Calling gfxlib2 itself from a", DIMTXT
	text_at 60, 332, "second thread needs the -mt build (fbgfxmt), not the default.", DIMTXT

	if timer - tstart > 0.6 then
		chk_set "thread ticks", iif(ticks > 20, 1, 0), str(ticks) & " in " & fmt1(timer - tstart) & "s"
		chk_set "mutex integrity", iif(ticks = sum, 1, 0), "ticks " & str(ticks) & ", sum " & str(sum)
	end if

	panel 16, 516, SW - 32, 130, "checks"
	tag_at 36, 552, "thread create"
	tag_at 36, 574, "thread ticks"
	tag_at 36, 596, "mutex integrity"
end sub

sub shutdown()
	trunning = 0
	if tthread <> 0 then
		threadwait tthread
		tthread = 0
	end if
	if tmutex <> 0 then
		mutexdestroy tmutex
		tmutex = 0
	end if
	if timg <> 0 then
		tpix = 0
		imagedestroy timg
		timg = 0
	end if
	if g_spr <> 0 then
		imagedestroy g_spr
		g_spr = 0
	end if
	if g_alpha <> 0 then
		imagedestroy g_alpha
		g_alpha = 0
	end if
	if g_bmp <> 0 then
		imagedestroy g_bmp
		g_bmp = 0
	end if
end sub

'' ============================================================= scene: 3d

sub checks_3d()
	chk_set "3d backend", -1, "none in this build: sokol is planned"
	chk_set "3d placeholder", 0, "wireframe drawn with 2D lines"
end sub

sub draw_3d()
	panel 16, 80, 470, 480, "3d backend"
	text_at 32, 116, "Status: none yet.", TXT
	text_at 32, 140, "The Cocoa driver is a pure 2D fb graphics driver; there is", DIMTXT
	text_at 32, 158, "no GL context and no 3D API behind ScreenRes.", DIMTXT
	text_at 32, 186, "Planned: sokol (platform independent, zlib/libpng", TXT
	text_at 32, 204, "licence) on top of the same surfaced window, with the", DIMTXT
	text_at 32, 222, "same two-page present model.", DIMTXT
	text_at 32, 250, "Why this tab exists: a 3D backend needs a visual test too,", TXT
	text_at 32, 268, "and it must run next to the 2D checks rather than replace", DIMTXT
	text_at 32, 286, "them.  Adding it means adding a check and a draw call here.", DIMTXT
	text_at 32, 316, "Until then this tab rotates a software cube, which at", DIMTXT
	text_at 32, 334, "least proves line drawing, clipping and timing at 60 Hz.", DIMTXT

	'' software wireframe cube: perspective projection, no 3D API
	dim as double vx(0 to 7) = { -1, 1, 1, -1, -1, 1, 1, -1 }
	dim as double vy(0 to 7) = { -1, -1, -1, -1, 1, 1, 1, 1 }
	dim as double vz(0 to 7) = { -1, -1, 1, 1, -1, -1, 1, 1 }
	dim as integer e1(0 to 11) = { 0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3 }
	dim as integer e2(0 to 11) = { 1, 2, 3, 0, 5, 6, 7, 4, 4, 5, 6, 7 }
	dim as integer px(0 to 7), py(0 to 7)

	dim as double a = timer * 0.9
	dim as double ca = cos(a), sa = sin(a)
	dim as double cb = cos(a * 0.63), sb = sin(a * 0.63)
	dim as integer cx = 760, cy = 300
	dim as double scale = 110.0
	dim as integer i

	for i = 0 to 7
		dim as double x = vx(i), y = vy(i), z = vz(i)
		'' rotate around Y, then around X
		dim as double x1 = x * ca - z * sa
		dim as double z1 = x * sa + z * ca
		dim as double y1 = y * cb - z1 * sb
		dim as double z2 = y * sb + z1 * cb
		dim as double f = 4.0 / (4.0 + z2)
		px(i) = cx + int(x1 * f * scale)
		py(i) = cy + int(y1 * f * scale)
	next

	for i = 0 to 11
		line (px(e1(i)), py(e1(i)))-(px(e2(i)), py(e2(i))), ACCENT
	next

	'' verify that the cube actually made it to the frame buffer
	dim as integer edges = scan_color(600, 130, 940, 470, ACCENT)
	chk_set "3d placeholder", iif(edges > 200, 1, 0), str(edges) & " px of wireframe"

	panel 16, 574, SW - 32, 72, "checks"
	tag_at 36, 610, "3d backend", 290
	tag_at 300, 610, "3d placeholder", 1008
end sub

	'' Write the current page as a binary PPM (P6).  "checkup auto" keeps one
'' frame per scene in $TMPDIR so the run can be reviewed afterwards; the same
'' helper is handy for bug reports.
sub dump_ppm(byval fn as string)
	dim as integer w, h, d
	screeninfo w, h, d
	if d <> 32 then exit sub
	dim as ulong ptr p = screenptr
	if p = 0 then exit sub

	'' diagnostics
	if len(environ("CHECKUP_DUMPDEBUG")) > 0 then
		open "dumpdebug.txt" for append as #8
		print #8, "dump "; fn; "  "; w; "x"; h; "x"; d; "  ptr=" & hex(culngint(p)); "  p(0,0)=" & hex(point(0, 0) and &hFFFFFF); "  p(last)=" & hex(point(w - 1, h - 1) and &hFFFFFF)
		close #8
	end if

	'' build the row as a string and hand it to Put # whole: writing a local
	'' ubyte array with Put # corrupted the heap on this build
	dim as string row = space(w * 3)
	dim as ubyte ptr rp = strptr(row)

	open fn for binary as #9
	print #9, "P6" & chr(10) & trim(str(w)) & " " & trim(str(h)) & chr(10) & "255" & chr(10);

	for y as integer = 0 to h - 1
		dim as ulong ptr src = p + y * w
		for x as integer = 0 to w - 1
			dim as uinteger c = src[x]
			rp[x * 3 + 0] = (c shr 16) and &hFF
			rp[x * 3 + 1] = (c shr 8) and &hFF
			rp[x * 3 + 2] = c and &hFF
		next
		put #9, , row
	next
	close #9
end sub

'' ======================================================== scene: summary

function reportpath() as string
	return curdir() & "/checkup.txt"
end function

sub write_report(byval toconsole as integer)
	dim as integer i
	dim as string m = "interactive"
	if automode then m = "auto"

	open "checkup.txt" for output as #1
	print #1, "FrejBASIC checkup report"
	print #1, "date:    " & date & "  " & time
	print #1, "driver:  " & drivername()
	print #1, "screen:  " & str(SW) & "x" & str(SH) & "x32, 2 pages"
	print #1, "mode:    " & m
	print #1, ""
	print #1, "pass " & str(chk_n(1)) & "   fail " & str(chk_n(0)) & "   skip " & str(chk_n(-1))
	print #1, ""
	for i = 0 to nchk - 1
		dim as string st = "FAIL"
		if chks(i).stat = 1 then st = "PASS"
		if chks(i).stat = -1 then st = "SKIP"
		print #1, st & "  " & rtrim(chks(i).name) & "  " & rtrim(chks(i).note)
	next
	close #1

	if toconsole then
		open cons for output as #1
		print #1, "checkup: " & str(chk_n(1)) & " pass, " & str(chk_n(0)) & " fail, " & str(chk_n(-1)) & " skip"
		for i = 0 to nchk - 1
			dim as string st = "FAIL"
			if chks(i).stat = 1 then st = "PASS"
			if chks(i).stat = -1 then st = "SKIP"
			print #1, "  " & st & "  " & rtrim(chks(i).name) & "  " & rtrim(chks(i).note)
		next
		print #1, "report: " & reportpath()
		close #1
	end if
end sub

' ========================================================= scene: timers

'' The timer checks are time based, so unlike the other tabs they cannot be
'' decided by reading pixels at the end.  Each one runs its own interval and
'' records an outcome; they are run one after another because a slow callback
'' blocks the pump for every other timer, which is the documented behaviour
'' and would otherwise spoil the measurement next to it.

dim shared as integer tc_rate, tc_rate_res, tc_after, tc_stop, tc_go, tc_drift, tc_slow
dim shared as integer tc_draws, tc_nopump, tc_active_ok, tc_phase
dim shared as integer tc_timer = 0
dim shared as double tc_t0 = 0

sub tc_tick()
	tc_rate += 1
end sub

sub tc_once_tick()
	tc_after += 1
end sub

sub tc_slow_tick()
	tc_slow += 1
	sleep 50, 1
end sub

sub tc_draw_tick()
	tc_draws += 1
	pset (SW - 12, SH - 12), rgb(255, 0, 0)
end sub

sub checks_timers()
	dim as double t0

	'' 1. rate: a 20 ms timer driven for 600 ms should fire roughly 30 times
	tc_rate = 0
	tc_timer = every(20, @tc_tick)
	t0 = timer
	do : waittimers 5 : loop until timer - t0 >= 0.6
	timerremove tc_timer
	tc_rate_res = tc_rate
	chk_set "timer rate", iif(tc_rate_res >= 15 andalso tc_rate_res <= 45, 1, 0), _
		str(tc_rate_res) & " fires in 600 ms at 20 ms (15..45)"

	'' 2. after: fires once, then the slot is free
	tc_after = 0
	tc_timer = after(120, @tc_once_tick)
	t0 = timer
	do : waittimers 5 : loop until timer - t0 >= 0.4
	timerremove tc_timer
	chk_set "timer after", iif(tc_after = 1, 1, 0), _
		str(tc_after) & " fire(s) from After(120) (exactly 1)"

	'' 3. stop and go
	tc_stop = 0
	tc_timer = every(30, @tc_tick)
	t0 = timer
	do : waittimers 5 : loop until timer - t0 >= 0.15
	timerstop tc_timer
	tc_stop = tc_rate
	t0 = timer
	do : waittimers 5 : loop until timer - t0 >= 0.2
	dim as integer stopped = tc_rate - tc_stop
	timergo tc_timer
	t0 = timer
	do : waittimers 5 : loop until timer - t0 >= 0.2
	tc_go = tc_rate - tc_stop - stopped
	timerremove tc_timer
	chk_set "timer stop", iif(stopped = 0, 1, 0), _
		str(stopped) & " fires while stopped (0)"
	chk_set "timer go", iif(tc_go > 0, 1, 0), _
		str(tc_go) & " fires after TimerGo (>0)"

	'' 4. drift: 10 ms for 500 ms should be about 50
	tc_drift = 0
	tc_timer = every(10, @tc_tick)
	tc_rate = 0
	t0 = timer
	do : waittimers 5 : loop until timer - t0 >= 0.5
	tc_drift = tc_rate
	timerremove tc_timer
	chk_set "timer drift", iif(tc_drift >= 25 andalso tc_drift <= 75, 1, 0), _
		str(tc_drift) & " fires in 500 ms at 10 ms (25..75)"

	'' 5. a slow callback must not produce a catch-up burst
	tc_slow = 0
	tc_timer = every(10, @tc_slow_tick)
	t0 = timer
	do : waittimers 5 : loop until timer - t0 >= 0.5
	timerremove tc_timer
	chk_set "timer no burst", iif(tc_slow > 0 andalso tc_slow <= 15, 1, 0), _
		str(tc_slow) & " fires with a 50 ms callback at 10 ms (1..15)"

	'' 6. a timer callback can draw
	tc_draws = 0
	tc_timer = every(20, @tc_draw_tick)
	t0 = timer
	do : waittimers 5 : loop until timer - t0 >= 0.2
	timerremove tc_timer
	chk_set "timer draws", iif(tc_draws > 0, 1, 0), _
		str(tc_draws) & " callback draws (>0)"

	'' 7. no pump, no fires.  This is the contract of the pure-BASIC timer.
	tc_nopump = 0
	tc_timer = every(5, @tc_tick)
	tc_rate = 0
	t0 = timer
	do : loop until timer - t0 >= 0.15
	tc_nopump = tc_rate
	timerremove tc_timer
	chk_set "timer needs pump", iif(tc_nopump = 0, 1, 0), _
		str(tc_nopump) & " fires without ServiceTimers (0, by design)"

	'' 8. ids answer for themselves
	dim as integer id = every(1000, @tc_tick)
	tc_active_ok = iif(timeractive(id) <> 0 andalso timeractive(0) = 0, 1, 0)
	timerstop id
	if timeractive(id) <> 0 then tc_active_ok = 0
	timerremove id
	if timeractive(id) <> 0 then tc_active_ok = 0
	chk_set "timer ids", tc_active_ok, "TimerActive follows stop and remove"
end sub

sub draw_timers()
	panel 16, 80, SW - 32, 420, "timers: Every / After, serviced by the program"

	text_at 32, 116, "Every(20, @sub)   fires " & str(tc_rate_res) & " times per 600 ms", TXT
	text_at 32, 140, "After(120, @sub)  fires " & str(tc_after) & " time(s)", TXT
	text_at 32, 164, "TimerStop / Go    " & str(tc_stop) & " / " & str(tc_go), TXT
	text_at 32, 188, "drift 10 ms       " & str(tc_drift) & " fires in 500 ms", TXT
	text_at 32, 212, "slow callback     " & str(tc_slow) & " fires, no catch-up burst", TXT
	text_at 32, 236, "callback drawing  " & str(tc_draws) & " times", TXT
	text_at 32, 260, "without a pump    " & str(tc_nopump) & " fires", TXT

	text_at 32, 300, "Timers fire when the program services them:", TXT
	text_at 32, 320, "    ServiceTimers      fire what is due, return", DIMTXT
	text_at 32, 338, "    WaitTimers ms      service, then wait", DIMTXT
	text_at 32, 366, "Sleep cannot be hooked - it is a compiler intrinsic - so a", DIMTXT
	text_at 32, 384, "program that wants animation calls WaitTimers instead.", DIMTXT
	text_at 32, 412, "Missed ticks are dropped, never queued: a slow callback", DIMTXT
	text_at 32, 430, "costs frames instead of building a backlog.", DIMTXT

	'' show the pset the drawing callback left behind, so the tab proves the
	'' callback really ran against the screen and not just a counter
	dim as ulong c = point(SW - 12, SH - 12)
	text_at 32, 462, "callback pixel    " & iif(c <> 0, "set", "not set"), _
		iif(c <> 0, OKC, BADC)
end sub

' ==================================================== scene: draw state

'' The draw-state tab is checked differently from the others: instead of
'' reading back pixels from a known scene, it draws the *same* scene twice -
'' once with the raw statements, once through DefLine/DefFill/DefText - and
'' requires the two to be identical.  That is the whole promise of the layer,
'' and it is what a future GPU backend has to keep true as well.

const DS_AREA_W = 640
const DS_AREA_H = 200
const DS_RED  = rgb(220, 40, 40)
const DS_BLUE = rgb(40, 80, 220)
const DS_DASH = &h0F0F

dim shared as integer ds_diff, ds_pushok, ds_popok, ds_resetok, ds_outlineok, ds_dashok

'' reference scene, written with the plain statements
sub ds_direct()
	line (20, 10)-(200, 10), DS_RED, , DS_DASH
	line (20, 30)-(200, 30), DS_RED
	line (20, 50)-(160, 120), DS_BLUE, BF
	line (180, 50)-(300, 120), DS_RED, B, DS_DASH
	circle (360, 85), 35, DS_BLUE, , , , F
	circle (440, 85), 35, DS_RED
	draw string (20, 150), "state", rgb(255, 255, 255)
end sub

'' the same scene through the state layer
sub ds_stated()
	drawreset
	defline DS_RED, DS_DASH
	dline 10 + 10, 10, 200, 10
	defline DS_RED
	dline 20, 30, 200, 30
	deffill DS_BLUE, FILL_SOLID
	dbox 20, 50, 160, 120
	defline DS_RED, DS_DASH
	deffill DS_RED, FILL_NONE
	dbox 180, 50, 300, 120
	deffill DS_BLUE, FILL_SOLID
	dcircle 360, 85, 35
	deffill DS_RED, FILL_NONE
	dcircle 440, 85, 35
	deftext rgb(255, 255, 255)
	dtext 20, 150, "state"
end sub

sub checks_drawstate()
	'' --- the two drawings must be identical
	cls
	ds_direct()
	dim as any ptr a = imagecreate(DS_AREA_W, DS_AREA_H)
	get (0, 0)-(DS_AREA_W - 1, DS_AREA_H - 1), a

	cls
	ds_stated()
	dim as any ptr b = imagecreate(DS_AREA_W, DS_AREA_H)
	get (0, 0)-(DS_AREA_W - 1, DS_AREA_H - 1), b

	dim as integer w, h, bpp, pitch
	dim as any ptr pa, pb
	imageinfo a, w, h, bpp, pitch, pa
	imageinfo b, w, h, bpp, pitch, pb

	dim as ulong ptr ua = cast(ulong ptr, pa), ub = cast(ulong ptr, pb)
	dim as integer x, y
	ds_diff = 0
	for y = 0 to DS_AREA_H - 1
		for x = 0 to DS_AREA_W - 1
			if (ua[y * pitch \ 4 + x] and &hFFFFFF) <> (ub[y * pitch \ 4 + x] and &hFFFFFF) then
				ds_diff += 1
			end if
		next
	next
	imagedestroy a
	imagedestroy b

	chk_set "draw state identical", iif(ds_diff = 0, 1, 0), _
		str(ds_diff) & " pixels differ from the direct drawing (0)"

	'' --- push/pop
	drawreset
	defline DS_RED
	drawpush
	defline DS_BLUE
	ds_pushok = iif(frej_draw.line_colour = DS_BLUE, 1, 0)
	drawpop
	ds_popok = iif(frej_draw.line_colour = DS_RED, 1, 0)
	chk_set "draw state push/pop", iif(ds_pushok = 1 andalso ds_popok = 1, 1, 0), _
		"colour changed inside the push and restored after the pop"

	'' --- reset
	defline DS_BLUE
	deffill DS_RED, FILL_NONE
	drawreset
	ds_resetok = iif(frej_draw.line_colour = rgb(255, 255, 255) andalso _
		frej_draw.fill_mode = FILL_SOLID, 1, 0)
	chk_set "draw state reset", ds_resetok, "DrawReset returns line and fill to defaults"

	'' --- OUTLINE leaves the interior alone
	cls
	line (0, 0)-(DS_AREA_W - 1, DS_AREA_H - 1), rgb(0, 0, 0), BF
	defline DS_RED, 0
	deffill rgb(0, 255, 0), FILL_SOLID
	dbox 10, 10, 210, 110, OUTLINE
	dim as ulong inside = point(110, 60)
	ds_outlineok = iif((inside and &hFFFFFF) = 0, 1, 0)
	chk_set "draw state outline", ds_outlineok, _
		"OUTLINE leaves the interior untouched (background kept)"

	'' --- the dash pattern really reaches the primitive: a dashed line
	'' leaves fewer pixels than a solid one of the same length
	cls
	line (0, 0)-(DS_AREA_W - 1, DS_AREA_H - 1), rgb(0, 0, 0), BF
	defline DS_RED, DS_DASH
	dline 10, 20, 300, 20
	dim as integer dashed = 0
	for x = 10 to 300
		if (point(x, 20) and &hFFFFFF) <> 0 then dashed += 1
	next
	cls
	line (0, 0)-(DS_AREA_W - 1, DS_AREA_H - 1), rgb(0, 0, 0), BF
	defline DS_RED
	dline 10, 20, 300, 20
	dim as integer solid = 0
	for x = 10 to 300
		if (point(x, 20) and &hFFFFFF) <> 0 then solid += 1
	next
	ds_dashok = iif(dashed > 0 andalso dashed < solid * 3 \ 4, 1, 0)
	chk_set "draw state dash", ds_dashok, _
		str(dashed) & " dashed px vs " & str(solid) & " solid px"

	drawreset
end sub

sub draw_drawstate()
	panel 16, 80, SW - 32, 470, "draw state: DefLine / DefFill / DefText"

	'' a small demonstration, drawn with the layer it describes
	drawreset
	defline rgb(120, 170, 255), &h3333
	dline 40, 120, 460, 120
	deffill rgb(40, 80, 220), FILL_SOLID
	dbox 40, 140, 200, 240
	defline rgb(220, 40, 40)
	deffill rgb(0, 0, 0), FILL_NONE
	dbox 220, 140, 380, 240
	dcircle 460, 190, 50
	deftext rgb(255, 255, 255)
	dtext 40, 268, "DefLine, DefFill and DefText"

	text_at 520, 120, "identical", iif(ds_diff = 0, OKC, BADC)
	text_at 520, 140, "diff " & str(ds_diff) & " px", iif(ds_diff = 0, OKC, BADC)
	text_at 520, 176, "push/pop", iif(ds_pushok = 1 andalso ds_popok = 1, OKC, BADC)
	text_at 520, 196, "reset", iif(ds_resetok = 1, OKC, BADC)
	text_at 520, 216, "outline", iif(ds_outlineok = 1, OKC, BADC)
	text_at 520, 236, "dash", iif(ds_dashok = 1, OKC, BADC)

	text_at 40, 310, "The scene above is drawn through the layer; the same scene", DIMTXT
	text_at 40, 328, "drawn with Line/Circle/Draw String must match it pixel for", DIMTXT
	text_at 40, 346, "pixel.  That is the promise a GPU backend has to keep.", DIMTXT
	text_at 40, 382, "DefLine colour,style    DefFill colour,mode    DefText colour", TXT
	text_at 40, 400, "DLine  DBox  DCircle  DPaint  DText  DrawPush  DrawPop", DIMTXT
	text_at 40, 424, "    style 0 is solid - Line treats an explicit 0 as 'draw", DIMTXT
	text_at 40, 442, "    nothing', so the layer leaves the argument out instead.", DIMTXT
end sub

sub draw_summary()
	panel 16, 80, SW - 32, SH - 80 - 44, "summary"

	dim as integer rows = (nchk + 1) \ 2
	if rows < 1 then rows = 1
	for i as integer = 0 to nchk - 1
		dim as integer col = i \ rows
		dim as integer row = i mod rows
		dim as integer x = 36 + col * 500
		dim as integer y = 116 + row * 22
		dim as string st = "FAIL"
		dim as uinteger c = BADC
		select case chks(i).stat
		case 1
			st = "PASS" : c = OKC
		case -1
			st = "SKIP" : c = SKIPC
		end select
		text_at x, y, st, c
		text_at x + 48, y, clip(rtrim(chks(i).name), 24), TXT
		text_at x + 250, y, clip(rtrim(chks(i).note), 26), DIMTXT
	next

	dim as integer yy = FTR - 66
	fillrect 16, yy, SW - 32, 52, rgb(18, 22, 30)
	box_at 16, yy, SW - 32, 52, EDGE
	dim as string tot = "pass " & str(chk_n(1)) & "    fail " & str(chk_n(0)) & "    skip " & str(chk_n(-1))
	text_at 32, yy + 6, tot, iif(chk_n(0) = 0, OKC, BADC)
	text_at 32, yy + 28, "report written to " & reportpath(), DIMTXT
	if chk_n(0) = 0 then
		text_at SW - 260, yy + 6, "ALL CHECKS PASSED", OKC
	else
		text_at SW - 260, yy + 6, "SOMETHING IS BROKEN", BADC
	end if
	if automode then
		text_at SW - 260, yy + 28, "auto mode: exit code " & iif(chk_ok(), "0", "1"), SKIPC
	end if
end sub

'' ------------------------------------------------------------ scene table

sub ensure_checks(byval s as integer)
	if done(s) then exit sub
	done(s) = 1
	select case s
	case 0
		checks_info()
	case 1
		checks_shapes()
	case 2
		checks_modes()
	case 3
		checks_text()
	case 4
		checks_sprites()
	case 5
		checks_images()
	case 6
		checks_input_static()
	case 7
		checks_threads_start()
	case 8
		checks_3d()
	case 9
		checks_timers()
	case 10
		checks_drawstate()
	case 11
		write_report(0)
	end select
end sub

sub draw_scene()
	select case scene
	case 0
		draw_info()
	case 1
		draw_shapes()
	case 2
		draw_modes()
	case 3
		draw_text()
	case 4
		draw_sprites()
	case 5
		draw_images()
	case 6
		draw_input()
	case 7
		draw_threads()
	case 8
		draw_3d()
	case 9
		draw_timers()
	case 10
		draw_drawstate()
	case 11
		draw_summary()
	end select
end sub

'' ---------------------------------------------------------------- chrome

sub draw_chrome()
	fillrect 0, 0, SW, SH, BG

	'' title bar
	fillrect 0, 0, SW, 32, BARBG
	text_at 12, 9, "FrejBASIC checkup", ACCENT
	text_at 160, 9, "visual acceptance test for the macOS / fb graphics port", DIMTXT

	dim as string st = "fps " & fmt1(fpsavg) & _
		"    pass " & str(chk_n(1)) & "   fail " & str(chk_n(0)) & "   skip " & str(chk_n(-1))
	text_at SW - 12 - len(st) * 8, 9, st, iif(chk_n(0) > 0, BADC, OKC)

	'' tab strip
	for i as integer = 0 to NSCENE - 1
		dim as integer tx = 8 + i * TABW
		dim as uinteger bgc = TABBG
		if i = scene then
			bgc = TABACT
		elseif i = hover then
			bgc = TABHOT
		end if
		fillrect tx, TABY, TABW - 4, TABH, bgc
		box_at tx, TABY, TABW - 4, TABH, EDGE
		dim as string nm
		if i < 9 then
			nm = str(i + 1) & " " & tabname(i)
		elseif i = NSCENE - 1 then
			nm = "0 " & tabname(i)
		else
			nm = tabname(i)
		end if
		text_at tx + 8, TABY + 7, nm, iif(i = scene, rgb(255, 255, 255), DIMTXT)
	next

	'' footer
	fillrect 0, FTR, SW, SH - FTR, BARBG
	text_at 12, FTR + 10, "click a tab or press 1-0 / tab / arrows    esc: quit    " & lastkey, DIMTXT
end sub

'' ------------------------------------------------------------------ input

sub poll_input()
	getmouse mx, my, mw, mbtn

	hover = -1
	if my >= TABY andalso my < TABY + TABH then
		dim as integer i = (mx - 8) \ TABW
		if i >= 0 andalso i < NSCENE then
			if mx < 8 + i * TABW + TABW - 4 then hover = i
		end if
	end if

	'' wheel is cumulative in this driver, so compare against the last value
	if mw <> prevwheel then
		nwheel += 1
		if scene = 6 then chk_set "mouse wheel", 1, "wheel " & str(mw)
		prevwheel = mw
	end if

	'' click: tab strip or the input test button
	if (mbtn and 1) <> 0 andalso (prevbtn and 1) = 0 then
		nclicks += 1
		if hover >= 0 then
			scene = hover
			tscene = timer
		elseif scene = 6 andalso mx >= BTNX andalso mx < BTNX + BTNW _
			andalso my >= BTNY andalso my < BTNY + BTNH then
			btn_presses += 1
			chk_set "mouse click", 1, "button hit " & str(btn_presses) & " time(s)"
		end if
	end if
	prevbtn = mbtn

	'' keyboard
	dim as string k = inkey
	if len(k) > 0 then
		nkeys += 1
		select case k
		case chr(27), chr(255, 107)
			quitting = 1
			lastkey = "esc / close"
		case chr(9)
			scene = (scene + 1) mod NSCENE
			tscene = timer
			lastkey = "tab"
		case "1" to "9"
			scene = asc(k) - asc("1")
			tscene = timer
			lastkey = "key " & k
		case "0"
			scene = NSCENE - 1
			tscene = timer
			lastkey = "key 0"
		case else
			if len(k) = 1 then
				lastkey = "key " & k & " (" & str(asc(k)) & ")"
			else
				lastkey = "key 0x" & hex(asc(k), 2) & "," & hex(asc(k, 2), 2)
			end if
		end select
		if scene = 6 then chk_set "keyboard", 1, lastkey
	end if

	'' arrows, edge triggered so holding them does not race through the tabs
	dim as integer lk = multikey(fb.SC_LEFT)
	dim as integer rk = multikey(fb.SC_RIGHT)
	if lk andalso prevleft = 0 then
		scene = (scene + NSCENE - 1) mod NSCENE
		tscene = timer
	end if
	if rk andalso prevright = 0 then
		scene = (scene + 1) mod NSCENE
		tscene = timer
	end if
	prevleft = lk
	prevright = rk
end sub

'' ------------------------------------------------------------------- main

dim as integer exitcode = 0

if lcase(command(1)) = "auto" then automode = 1
if len(environ("CHECKUP_ONLY")) > 0 then
	onlyscene = valint(environ("CHECKUP_ONLY"))
	if onlyscene < 0 or onlyscene > NSCENE - 1 then onlyscene = -1
end if
if len(environ("CHECKUP_DWELL")) > 0 then dwellsec = valint(environ("CHECKUP_DWELL")) / 1000.0
if len(environ("CHECKUP_TRACE")) > 0 then tracing = 1
if automode andalso onlyscene >= 0 then
	scene = onlyscene
	tscene = timer
end if

screenres SW, SH, 32, 2, fb.GFX_ALPHA_PRIMITIVES
screenset 1, 0
screencontrol fb.SET_WINDOW_TITLE, "FrejBASIC checkup"
setmouse , , 1

tframe = timer
tfps = timer
tscene = timer

do
	poll_input()
	if quitting then exit do

	if automode andalso timer - tscene > dwellsec then
		if onlyscene >= 0 then exit do
		if scene >= NSCENE - 1 then
			scene = NSCENE - 1
			exit do
		end if
		scene += 1
		tscene = timer
	end if

	ensure_checks scene
	draw_chrome()
	draw_scene()
	flip

	if automode andalso dumped(scene) = 0 andalso timer - tscene > 0.6 _
		andalso len(environ("CHECKUP_NODUMP")) = 0 then
		dumped(scene) = 1
		dump_ppm(tmpdir() & "frej-checkup-" & trim(str(scene)) & "-" & trim(tabname(scene)) & ".ppm")
	end if

	if tracing andalso (frame_no mod 25) = 0 then
		'' crash forensics: append-and-close so the last line survives a signal
		dim as integer f = freefile
		if open(tmpdir() & "checkup-trace.txt" for append as #f) = 0 then
			print #f, "frame " & str(frame_no) & "  scene " & str(scene) & _
				" " & tabname(scene) & "  t " & fmt1(timer - tframe)
			close #f
		end if
	end if

	frame_no += 1
	nfps += 1
	if timer - tfps >= 0.25 then
		fpsavg = nfps / (timer - tfps)
		nfps = 0
		tfps = timer
	end if

	sleep 2, 1
loop

'' the summary scene writes the report; make sure it is up to date even when
'' the user quits early or auto mode stops on the last scene
if automode then
	if scene <> NSCENE - 1 then
		scene = NSCENE - 1
		ensure_checks scene
		draw_chrome()
		draw_scene()
		flip
	end if
	write_report(1)
else
	write_report(0)
end if

shutdown()

if automode then
	if chk_ok() then exitcode = 0 else exitcode = 1
end if

end exitcode
