'' frej/draw.bi - drawing state, in the spirit of GFA-BASIC 3.5
''
'' GFA set the style once and then drew:
''
''     DEFLINE pattern,colour
''     DEFFILL style,colour,pattern
''     DEFTEXT colour,font,effects
''
'' and every LINE, BOX, CIRCLE and TEXT that followed used that state until
'' it was changed.  Geometry calls carried coordinates only, and changing a
'' theme was three lines instead of one per call.
''
''     #include once "frej/draw.bi"
''
''     DefLine rgb(200, 0, 0), 3
''     DefFill rgb(0, 0, 255), FILL_SOLID
''     DefText rgb(255, 255, 255)
''
''     DLine 10, 10, 300, 200
''     DBox  20, 20, 120, 120
''     DBox  140, 20, 240, 120, OUTLINE
''     DCircle 320, 200, 60
''     DText 40, 40, "hello"
''
'' The state is a plain record, so a future GPU backend can translate it into
'' pipeline state instead of re-deriving it: colour, dash pattern, fill mode
'' and text colour are the same things a pipeline describes.
''
'' Copyright (c) 2026 the FrejBASIC contributors
'' Distributed under the same terms as the FreeBASIC runtime library.

#ifndef __FREJ_DRAW_BI__
#define __FREJ_DRAW_BI__

#pragma once

'' Fill modes.  GFA had a richer set; these two are what the software
'' rasteriser can honestly do - a patterned fill would need a Paint that takes
'' a pattern, which gfxlib2 does not have.
const FILL_SOLID = 0
const FILL_NONE  = 1

'' GFA called the outline form BOX and the filled form PBOX; the same choice
'' is spelled OUTLINE here, for the calls that read better that way.
const OUTLINE = FILL_NONE

'' How deep DrawPush/DrawPop may nest.  A dialog or a library routine takes
'' one level; sixteen is far more than anything needs, and it is a fixed
'' array so pushing costs nothing.
const FREJ_DRAW_MAXDEPTH = 16

type FrejDrawStyle
	line_colour as ulong
	line_style  as ulong    '' 0 = solid, otherwise a 16-bit dash pattern
	fill_colour as ulong
	fill_mode   as integer  '' FILL_SOLID or FILL_NONE
	text_colour as ulong
end type

dim shared frej_draw as FrejDrawStyle
dim shared frej_draw_stack(1 to FREJ_DRAW_MAXDEPTH) as FrejDrawStyle
dim shared frej_draw_depth as integer = 0

'' ---------------------------------------------------------------- state --

'' Back to the defaults: white line, solid, white fill, white text.  Call it
'' at the start of a scene so a tab cannot inherit the previous one's theme.
sub DrawReset()
	frej_draw.line_colour = rgb(255, 255, 255)
	frej_draw.line_style  = 0
	frej_draw.fill_colour = rgb(255, 255, 255)
	frej_draw.fill_mode   = FILL_SOLID
	frej_draw.text_colour = rgb(255, 255, 255)
end sub

'' Save the current state and restore it later.  Any routine that changes the
'' state and returns to a caller should bracket itself with these.
sub DrawPush()
	if frej_draw_depth >= FREJ_DRAW_MAXDEPTH then exit sub   '' overflow: keep the current state
	frej_draw_depth += 1
	frej_draw_stack(frej_draw_depth) = frej_draw
end sub

sub DrawPop()
	if frej_draw_depth = 0 then exit sub                  '' underflow: do nothing
	frej_draw = frej_draw_stack(frej_draw_depth)
	frej_draw_depth -= 1
end sub

'' style 0 is solid.  There is a trap here worth knowing: passing style 0 to
'' Line draws *nothing*, so the solid case has to leave the argument out
'' entirely.  That is why every call below branches on the style.
sub DefLine(byval colour as ulong, byval style as ulong = 0)
	frej_draw.line_colour = colour
	frej_draw.line_style  = style
end sub

sub DefFill(byval colour as ulong, byval mode as integer = FILL_SOLID)
	frej_draw.fill_colour = colour
	frej_draw.fill_mode   = mode
end sub

sub DefText(byval colour as ulong)
	frej_draw.text_colour = colour
end sub

'' ------------------------------------------------------------- geometry --
''
'' Each routine takes a mode that defaults to the state, so
''     DBox 20, 20, 120, 120
'' uses DefFill's mode, and
''     DBox 20, 20, 120, 120, OUTLINE
'' overrides it for this call without touching the state.

sub DLine(byval x1 as integer, byval y1 as integer, byval x2 as integer, byval y2 as integer)
	if frej_draw.line_style = 0 then
		line (x1, y1)-(x2, y2), frej_draw.line_colour
	else
		line (x1, y1)-(x2, y2), frej_draw.line_colour, , frej_draw.line_style
	end if
end sub

sub DBox(byval x1 as integer, byval y1 as integer, byval x2 as integer, byval y2 as integer, byval mode as integer = -1)
	dim as integer m = mode
	if m < 0 then m = frej_draw.fill_mode

	if m = FILL_SOLID then
		line (x1, y1)-(x2, y2), frej_draw.fill_colour, BF
	else
		if frej_draw.line_style = 0 then
			line (x1, y1)-(x2, y2), frej_draw.line_colour, B
		else
			line (x1, y1)-(x2, y2), frej_draw.line_colour, B, frej_draw.line_style
		end if
	end if
end sub

sub DCircle(byval x as integer, byval y as integer, byval radius as integer, byval mode as integer = -1)
	dim as integer m = mode
	if m < 0 then m = frej_draw.fill_mode

	if m = FILL_SOLID then
		circle (x, y), radius, frej_draw.fill_colour, , , , F
	else
		circle (x, y), radius, frej_draw.line_colour
	end if
end sub

'' Flood fill in the fill colour, stopping at the line colour, which is what
'' GFA's PAINT did with the current DEF FILL and DEF LINE.
sub DPaint(byval x as integer, byval y as integer)
	paint (x, y), frej_draw.fill_colour, frej_draw.line_colour
end sub

sub DText(byval x as integer, byval y as integer, byval s as string)
	draw string (x, y), s, frej_draw.text_colour
end sub

'' The library starts at the defaults, so a program that only calls the D*
'' routines still gets sane colours.
DrawReset

#endif '' __FREJ_DRAW_BI__
