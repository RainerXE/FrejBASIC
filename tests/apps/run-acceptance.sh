#!/bin/sh
#
# run-acceptance.sh - run the self-checking acceptance bench
#
# tests/apps/acceptance/checkup.bas is a visual test bench: it opens a window,
# walks through ten tabs (info, shapes, modes, text, sprites, images, input,
# threads, 3d, summary), draws a reference scene on each and verifies what it
# drew by reading the pixels back.  Everything it finds goes into a report and
# into the exit code, so a broken primitive or a broken driver shows up as a
# FAIL instead of a subtly wrong picture.
#
# This wrapper runs it unattended ("checkup auto"), keeps the report next to
# the source, and prints the summary the bench wrote.  It needs a window
# server: on a headless machine run the corpus instead (run-apps.sh).
#
# Usage: run-acceptance.sh [EXE]
#
#     EXE         the compiled bench          (default: ./checkup here)
#
# Environment passed through to the bench:
#     CHECKUP_DWELL=ms     per-tab dwell time         (default 900)
#     CHECKUP_ONLY=n       run only tab n
#     CHECKUP_TRACE=1      append frame/scene lines to checkup-trace.txt
#     FB_COCOA_THREAD=1    present from the driver's own thread (Cocoa)
#
exe=${1:-$(dirname "$0")/acceptance/checkup}

if [ ! -x "$exe" ]; then
	echo "run-acceptance: $exe is not built" >&2
	echo "run-acceptance: use 'make acceptance' or 'make acceptance-auto'" >&2
	exit 1
fi

root=$(cd "$(dirname "$0")/../.." && pwd)
case $exe in
/*) ;;
*) exe="$(pwd)/$exe" ;;
esac

outdir=$root/tests/apps/acceptance
tmp=$(mktemp -d "${TMPDIR:-/tmp}/frej-acceptance.XXXXXX") || exit 1

# the bench writes checkup.txt and its PPM dumps into the current directory
cd "$tmp" || exit 1
"$exe" auto
rc=$?

if [ -f checkup.txt ]; then
	cp checkup.txt "$outdir/checkup.txt"
fi
if [ -f checkup-trace.txt ]; then
	cp checkup-trace.txt "$outdir/checkup-trace.txt"
fi

if [ "$rc" -eq 0 ]; then
	rm -rf "$tmp"
	echo "acceptance: all checks passed (report: tests/apps/acceptance/checkup.txt)"
else
	echo "acceptance: FAILED, exit code $rc" >&2
	echo "acceptance: the run directory was left for inspection: $tmp" >&2
fi

exit $rc
