project - a FrejBASIC single-file project
=========================================

project.bas is the main file; src/scene.bas is a module.  Build from this
directory:

    fbc -i ../../inc project.bas -x project
    ./project

Close the window or press Escape to stop.


Why "one file"
--------------

GFA 3.5 kept code, editor state and includes in one tokenised file, and GB32
made that a design principle.  FreeBASIC's #include already gives a single
compilable file; this example is the convention that goes with it:

    project.bas      main program, includes modules in order
    src/*.bas        modules
    frej.cfg         optional: -d flags and include paths for a Makefile

There is no project format.  A Makefile that compiles project.bas is enough,
and a real project file is added only if the include list becomes painful.

The include order is the compile order.  Shared declarations (types,
constants, globals such as g_frame) go before the modules that use them,
which is why src/scene.bas is included after the declarations and before
the main loop.

See doc/FrejBASIC-project-notes.txt for the full convention, including the
#ifdef / Asm pattern for "two implementations of one routine".
