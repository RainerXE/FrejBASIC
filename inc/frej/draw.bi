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
'' This file supplies the GFA names; the state and the drawing live in
'' inc/fbdraw.bi, which is also offered upstream in this neutral form.
''
'' Copyright (c) 2026 the FrejBASIC contributors
'' Distributed under the same terms as the FreeBASIC runtime library.

#ifndef __FREJ_DRAW_BI__
#define __FREJ_DRAW_BI__

#pragma once

#include once "fbdraw.bi"

'' The GFA spellings of the neutral constants.
const FILL_SOLID = FBDRAW_FILL_SOLID
const FILL_NONE  = FBDRAW_FILL_NONE
const OUTLINE    = FBDRAW_OUTLINE

const FREJ_DRAW_MAXDEPTH = FBDRAW_MAXDEPTH

'' ---------------------------------------------------------------- state --

sub DrawReset()
	FBDrawReset()
end sub

sub DrawPush()
	FBDrawPush()
end sub

sub DrawPop()
	FBDrawPop()
end sub

sub DefLine(byval colour as ulong, byval style as ulong = 0)
	FBDrawSetLine( colour, style )
end sub

sub DefFill(byval colour as ulong, byval mode as integer = FILL_SOLID)
	FBDrawSetFill( colour, mode )
end sub

sub DefText(byval colour as ulong)
	FBDrawSetText( colour )
end sub

'' ------------------------------------------------------------- geometry --

sub DLine(byval x1 as integer, byval y1 as integer, byval x2 as integer, byval y2 as integer)
	FBDrawLine( x1, y1, x2, y2 )
end sub

sub DBox(byval x1 as integer, byval y1 as integer, byval x2 as integer, byval y2 as integer, byval mode as integer = -1)
	FBDrawBox( x1, y1, x2, y2, mode )
end sub

sub DCircle(byval x as integer, byval y as integer, byval radius as integer, byval mode as integer = -1)
	FBDrawCircle( x, y, radius, mode )
end sub

sub DPaint(byval x as integer, byval y as integer)
	FBDrawPaint( x, y )
end sub

sub DText(byval x as integer, byval y as integer, byval s as string)
	FBDrawText( x, y, s )
end sub

#endif '' __FREJ_DRAW_BI__
