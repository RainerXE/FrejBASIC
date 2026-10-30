'' One module of the project.  It sees the declarations that project.bas
'' included before it - fbgfx.bi, frej/draw.bi and g_frame - and nothing
'' else.  Add another file to src/ and include it in project.bas the same
'' way.

sub SceneDraw(byval n as integer)
	drawreset

	defline rgb(120, 170, 255), &h3333
	dline 40, 40, 600, 40

	deffill rgb(40, 80, 220), FILL_SOLID
	dbox 40, 80, 300, 260

	defline rgb(220, 60, 60)
	deffill rgb(0, 0, 0), FILL_NONE
	dbox 340, 80, 600, 260

	deftext rgb(255, 255, 255)
	dtext 40, 300, "frame " & str(n)
	dtext 40, 330, "module: src/scene.bas"
end sub
