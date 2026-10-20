#!/bin/sh
#
# run-apps.sh - build and run the application corpus
#
# The corpus is a list of real, complete FreeBASIC programs (not unit tests)
# kept in manifest.txt.  Each one is compiled with the compiler under test and
# then run for a few seconds, so that a platform port can be checked against
# programs that behave like the ones users write: they open screens, draw,
# read keys, animate and wait for input.
#
# A program passes when it compiles and then either exits with status 0, or is
# still running when the timeout expires.  The second case is the normal
# outcome for interactive examples (they end with SLEEP or an event loop), so
# a timeout is not a failure by itself - but a crash, a runtime error, a
# non-zero exit or a signal is.
#
# Usage: run-apps.sh [options] [PROGRAM...]
#
# PROGRAM arguments replace the manifest, so one demo, a few demos or a glob
# can be checked without editing the list:
#
#     tests/apps/run-apps.sh --screens examples/graphics/*.bas
#
#   --fbc PATH          compiler to test        (default: ../../bin/fbc)
#   --inc PATH          include directory       (default: ../../inc)
#   --manifest FILE     corpus list             (default: manifest.txt here)
#   --timeout SECONDS   how long one program may run (default: 5)
#   --build-timeout S   how long one build may take  (default: 60)
#   --only PATTERN      run only entries containing PATTERN
#   --report FILE       write a tab separated report (path, status, rc, secs)
#   --compare FILE      compare against a report from another run/platform
#   --sweep             compile every example under examples/ and report,
#                       without running anything (breadth check, not a gate)
#   --screens           also check that the program put something on screen:
#                       the driver writes the frame it presents to a PPM and
#                       a single-colour frame is reported as blank (macOS
#                       Cocoa driver; other drivers report "none")
#   --keep              keep the temporary binaries and logs
#   -v, --verbose       also show the compiler output of passing programs
#   -h, --help          this text
#
# Exit status is 0 when every program in the manifest passed.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$script_dir/../.." && pwd)

FBC=$ROOT/bin/fbc
INC=$ROOT/inc
MANIFEST=$script_dir/manifest.txt
RUN_TIMEOUT=5
BUILD_TIMEOUT=60
ONLY=
REPORT=
COMPARE=
SWEEP=0
SCREENS=0
KEEP=0
VERBOSE=0

usage() {
	awk 'NR > 2 && /^#/ { sub(/^# ?/, ""); print; next } NR > 2 { exit }' "$0"
}

while [ $# -gt 0 ]; do
	case $1 in
		--fbc)           FBC=$2; shift 2 ;;
		--inc)           INC=$2; shift 2 ;;
		--manifest)      MANIFEST=$2; shift 2 ;;
		--timeout)       RUN_TIMEOUT=$2; shift 2 ;;
		--build-timeout) BUILD_TIMEOUT=$2; shift 2 ;;
		--only)          ONLY=$2; shift 2 ;;
		--report)        REPORT=$2; shift 2 ;;
		--compare)       COMPARE=$2; shift 2 ;;
		--sweep)         SWEEP=1; shift ;;
		--screens)       SCREENS=1; shift ;;
		--keep)          KEEP=1; shift ;;
		-v|--verbose)    VERBOSE=1; shift ;;
		-h|--help)       usage; exit 0 ;;
		--)              shift; break ;;
		-*) echo "run-apps: unknown option '$1' (try --help)" >&2; exit 2 ;;
		*) break ;;      # first PROGRAM argument; the rest are programs too
	esac
done

if [ ! -x "$FBC" ]; then
	echo "run-apps: no compiler at $FBC" >&2
	exit 2
fi

TMP=${TMPDIR:-/tmp}/frej-apps.$$
mkdir -p "$TMP/bin" "$TMP/log" || exit 1
cleanup() {
	[ "$KEEP" = 1 ] || rm -rf "$TMP"
}
trap cleanup EXIT INT TERM

# Programs given on the command line replace the manifest.
if [ $# -gt 0 ]; then
	MANIFEST=$TMP/manifest.args
	: >"$MANIFEST"
	for arg in "$@"; do
		printf '%s\n' "$arg" >>"$MANIFEST"
	done
fi

#
# Run a command in a directory with a time limit.
#
# Sets RB_RC to the exit status and RB_TIMED_OUT to 1 when the command had to
# be killed because it was still running when the time ran out.
#
run_bounded() {
	rb_timeout=$1
	rb_log=$2
	rb_dir=$3
	shift 3
	rb_flag=$rb_log.timedout
	rm -f "$rb_flag"

	( cd "$rb_dir" && exec "$@" ) >"$rb_log.out" 2>"$rb_log.err" </dev/null &
	rb_pid=$!

	(
		rb_n=0
		while [ "$rb_n" -lt "$rb_timeout" ]; do
			sleep 1
			kill -0 "$rb_pid" 2>/dev/null || exit 0
			rb_n=$((rb_n + 1))
		done
		: >"$rb_flag"
		kill -TERM "$rb_pid" 2>/dev/null
		sleep 1
		kill -KILL "$rb_pid" 2>/dev/null
		# programs that fork: take their children down too
		pkill -P "$rb_pid" 2>/dev/null
	) &
	rb_watch=$!

	# a shell prints "Segmentation fault" itself when it reaps a job that a
	# signal killed; the runner reports that itself, so keep it quiet
	exec 9>&2
	exec 2>/dev/null
	wait "$rb_pid"
	RB_RC=$?
	exec 2>&9
	exec 9>&-
	kill "$rb_watch" 2>/dev/null
	wait "$rb_watch" 2>/dev/null

	if [ -f "$rb_flag" ]; then
		RB_TIMED_OUT=1
	else
		RB_TIMED_OUT=0
	fi
	rm -f "$rb_flag"
}

slug_of() {
	printf '%s' "$1" | sed 's|^/||; s|[/ ]|_|g'
}

# First thing that looks like the reason, for a one line report.
reason_of() {
	{ cat "$1.err" "$1.out" 2>/dev/null
	  [ -f "$1.c" ] && echo "$1.c"
	} | grep -i -m1 -E 'error|fatal|cannot|not found|segmentation|abort' \
	  | sed "s|$ROOT/||g; s|$TMP/||g" | cut -c1-96
}

REPORT_TMP=$TMP/report.tsv
: >"$REPORT_TMP"

#
# Frame check (--screens).
#
# The Cocoa driver writes the frame it is about to present to a PPM file when
# FB_COCOA_DUMP is set, which is the only way to tell "the program drew" from
# "the window stayed black" without screen recording permission.  A frame with
# a single colour everywhere counts as blank.
#
HAVE_PY=0
command -v python3 >/dev/null 2>&1 && HAVE_PY=1

frame_of() { # ppm-path -> drew:N | blank | none | unreadable | unchecked
	[ -f "$1" ] || { printf 'none'; return; }
	if [ "$HAVE_PY" = 0 ]; then
		printf 'unchecked'
		return
	fi
	python3 - "$1" <<'PY'
import sys

try:
    with open(sys.argv[1], 'rb') as f:
        if f.readline().strip() != b'P6':
            raise ValueError('not a binary PPM')
        dims = f.readline().split()
        while dims and dims[0].startswith(b'#'):
            dims = f.readline().split()
        w, h = int(dims[0]), int(dims[1])
        f.readline()                    # max value
        px = f.read()
except Exception:
    print('unreadable')
    raise SystemExit

count = w * h
stride = max(3, (count // 4000) * 3)    # sample about 4000 pixels
seen = set()
for i in range(0, min(len(px), count * 3) - 2, stride):
    seen.add(px[i:i + 3])
print('blank' if len(seen) == 1 else 'drew:%d' % len(seen))
PY
}

frame_note() { # frame -> "  (frame: ...)" or nothing
	[ "$SCREENS" = 1 ] || return 0
	[ "$1" = "none" ] && return 0
	printf '  (frame: %s)' "$1"
}

pass=0; failed=0; ok=0; ran=0; crash=0; build_err=0
drew=0; blank=0; nodump=0
started_all=$(date +%s)

report_line() { # path status rc secs detail frame
	printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" "$6" >>"$REPORT_TMP"
}

run_one() { # entry extra-fbc-flags
	entry=$1
	entry_flags=${2:-}
	case $entry in
		/*) src=$entry ;;
		*)  src=$ROOT/$entry ;;
	esac

	if [ ! -f "$src" ]; then
		printf '%-8s %s\n' "missing" "$entry"
		report_line "$entry" "missing" "-" "0" "no such file" "-"
		failed=$((failed + 1))
		return
	fi

	slug=$(slug_of "$entry")
	# one directory per entry, and the binary named after the program: the
	# Cocoa driver takes the window title from the executable name, so a demo
	# started this way shows its own name in the title bar
	outdir=$TMP/bin/$slug
	mkdir -p "$outdir"
	out=$outdir/$(basename "$src" .bas)
	srcdir=$(dirname "$src")

	t0=$(date +%s)
	# build from the temporary directory and add the program's own directory
	# to the include path, so that a failed build cannot leave .c files in
	# the examples tree
	run_bounded "$BUILD_TIMEOUT" "$TMP/log/$slug.build" "$TMP" \
		"$FBC" -i "$INC" -i "$srcdir" $entry_flags -x "$out" "$src" || true
	t1=$(date +%s)

	if [ "$RB_RC" -ne 0 ] || [ ! -x "$out" ]; then
		build_err=$((build_err + 1))
		failed=$((failed + 1))
		why=$(reason_of "$TMP/log/$slug.build")
		printf '%-8s %s\n' "build" "$entry"
		[ -n "$why" ] && printf '         %s\n' "$why"
		[ "$VERBOSE" = 1 ] && sed -n '1,12p' "$TMP/log/$slug.build.err" | sed 's/^/         /'
		report_line "$entry" "compile-error" "$RB_RC" "$((t1 - t0))" "$why" "-"
		return
	fi

	t1=$(date +%s)
	# run it where it lives, so relative asset paths and data files work
	frame=none
	if [ "$SCREENS" = 1 ]; then
		FB_COCOA_DUMP=$TMP/log/$slug.ppm
		export FB_COCOA_DUMP
		rm -f "$FB_COCOA_DUMP"
	fi
	run_bounded "$RUN_TIMEOUT" "$TMP/log/$slug.run" "$srcdir" "$out"
	t2=$(date +%s)

	if [ "$SCREENS" = 1 ]; then
		unset FB_COCOA_DUMP
		frame=$(frame_of "$TMP/log/$slug.ppm")
		case $frame in
			drew:*) drew=$((drew + 1)) ;;
			blank)  blank=$((blank + 1)) ;;
			none)   nodump=$((nodump + 1)) ;;
		esac
	fi

	if [ "$RB_TIMED_OUT" = 1 ]; then
		ran=$((ran + 1)); pass=$((pass + 1))
		printf '%-8s %s%s\n' "ran" "$entry" "$(frame_note "$frame")"
		report_line "$entry" "ran" "timeout" "$((t2 - t1))" "" "$frame"
	elif [ "$RB_RC" -eq 0 ]; then
		ok=$((ok + 1)); pass=$((pass + 1))
		printf '%-8s %s%s\n' "ok" "$entry" "$(frame_note "$frame")"
		report_line "$entry" "ok" "0" "$((t2 - t1))" "" "$frame"
	else
		crash=$((crash + 1)); failed=$((failed + 1))
		why=$(reason_of "$TMP/log/$slug.run")
		printf '%-8s %s (exit %s)%s\n' "crash" "$entry" "$RB_RC" "$(frame_note "$frame")"
		[ -n "$why" ] && printf '         %s\n' "$why"
		[ "$VERBOSE" = 1 ] && sed -n '1,12p' "$TMP/log/$slug.run.err" | sed 's/^/         /'
		report_line "$entry" "crash" "$RB_RC" "$((t2 - t1))" "$why" "$frame"
	fi
}

sweep() {
	printf 'Compiling every program under examples/ (no run), this takes a few minutes...\n\n'
	n=0; good=0; bad=0
	for src in $(find "$ROOT/examples" -name '*.bas' | sort); do
		n=$((n + 1))
		slug=$(slug_of "${src#$ROOT/}")
		run_bounded "$BUILD_TIMEOUT" "$TMP/log/$slug.build" "$TMP" \
			"$FBC" -i "$INC" -i "$(dirname "$src")" -c -o "$TMP/bin/x.o" "$src" || true
		if [ "$RB_RC" -eq 0 ]; then
			good=$((good + 1))
			report_line "${src#$ROOT/}" "compiles" "0" "0" "" "-"
		else
			bad=$((bad + 1))
			why=$(reason_of "$TMP/log/$slug.build")
			printf '%-8s %s\n' "no" "${src#$ROOT/}"
			[ -n "$why" ] && printf '         %s\n' "$why"
			report_line "${src#$ROOT/}" "compile-error" "$RB_RC" "0" "$why" "-"
		fi
		[ $((n % 100)) -eq 0 ] && printf '  ... %d of %d\n' "$n" "$(find "$ROOT/examples" -name '*.bas' | wc -l | tr -d ' ')"
	done
	report_line "SUMMARY" "sweep" "$n" "0" "compiles=$good errors=$bad" "-"
	printf '\n%d programs: %d compile, %d do not (fragments, external libraries, other targets)\n' "$n" "$good" "$bad"
	if [ -n "$REPORT" ]; then cp "$REPORT_TMP" "$REPORT"; fi
	[ "$KEEP" = 1 ] && printf 'Kept: %s\n' "$TMP"
	exit 0
}

if [ "$SWEEP" = 1 ]; then
	sweep
fi

if [ ! -f "$MANIFEST" ]; then
	echo "run-apps: no manifest at $MANIFEST" >&2
	exit 2
fi

printf 'Compiler: %s\n' "$FBC"
printf 'Corpus:   %s\n\n' "$MANIFEST"

while IFS= read -r line || [ -n "$line" ]; do
	case $line in
		''|\#*) continue ;;
	esac
	entry=${line%%|*}
	entry_flags=
	case $line in
		*'|'*) entry_flags=${line#*|} ;;
	esac
	entry=$(printf '%s' "$entry" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
	[ -z "$entry" ] && continue
	if [ -n "$ONLY" ]; then
		case $entry in
			*"$ONLY"*) ;;
			*) continue ;;
		esac
	fi
	run_one "$entry" "$entry_flags"
done <"$MANIFEST"

ended_all=$(date +%s)

printf '\n%d programs: %d pass (%d exited, %d ran until timeout), %d fail (%d crashed, %d did not build)\n' \
	"$((pass + failed))" "$pass" "$ok" "$ran" "$failed" "$crash" "$build_err"
if [ "$SCREENS" = 1 ]; then
	printf 'Frames: %d drew something, %d blank, %d no frame (console program or no dump support)\n' \
		"$drew" "$blank" "$nodump"
fi
printf 'Time: %d seconds\n' "$((ended_all - started_all))"

if [ -n "$REPORT" ]; then
	cp "$REPORT_TMP" "$REPORT"
	printf 'Report: %s\n' "$REPORT"
fi

[ "$KEEP" = 1 ] && printf 'Kept: %s (binaries in bin/, frames in log/*.ppm)\n' "$TMP"

if [ -n "$COMPARE" ]; then
	printf '\nCompared with %s:\n' "$COMPARE"
	awk -F'\t' '
		NR == FNR { old[$1] = $2; next }
		{ seen[$1] = 1
		  if (!($1 in old)) print "  new      " $1 " -> " $2
		  else if (old[$1] != $2) print "  changed  " $1 ": " old[$1] " -> " $2 }
		END { for (p in old) if (!(p in seen)) print "  missing  " p }
	' "$COMPARE" "$REPORT_TMP"
fi

[ "$failed" -eq 0 ] || exit 1
exit 0
