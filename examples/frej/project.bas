'' project.bas - the main file of a FrejBASIC project
''
'' A project is one main file plus modules under src/.  The include order is
'' the compile order: shared declarations first, then the modules that use
'' them.  See ../../doc/FrejBASIC-project-notes.txt.
''
'' Build from this directory:
''
''     fbc -i ../../inc project.bas -x project
''     ./project
''
'' Close the window or press Escape to stop.

#include once "fbgfx.bi"
#include once "frej/draw.bi"

'' Shared state: a module sees this because it is declared before the
'' #include below.
dim shared as integer g_frame = 0

#include once "src/scene.bas"

screenres 640, 400, 32

dim as fb.EVENT e
dim as integer running = 1
do
	cls
	SceneDraw g_frame
	g_frame += 1

	while screenevent(@e) <> 0
		if e.type = fb.EVENT_KEY_PRESS andalso e.scancode = fb.SC_ESCAPE then running = 0
		if e.type = fb.EVENT_WINDOW_CLOSE then running = 0
	wend

	sleep 16, 1
loop while running
