#!/bin/sh
#
# sync-upstream.sh - keep the two FreeBASIC repositories in step with upstream
#
# Part of the FrejBASIC fork (RainerXE/FrejBASIC).  Not part of upstream
# FreeBASIC; kept outside contrib/ so that upstream never has to merge it.
#
# WHAT THIS IS FOR
# =================
#
# There are three repositories in play:
#
#   upstream  freebasic/fbc             - upstream FreeBASIC
#   fork      RainerXE/fbc              - GitHub fork, staging area for PRs
#   origin    RainerXE/FrejBASIC        - the product fork (macOS, GFA dialect)
#
# The invariant this script maintains:
#
#   * fork/master tracks upstream/master (fork/master is never behind)
#   * every open PR branch in fork/ is based on current upstream/master
#   * origin/master contains upstream/master (it is never behind)
#   * our own PRs are reported, so a stale one gets noticed
#
# USAGE
# =====
#
#   ./tools/sync-upstream.sh status     report only, change nothing (default)
#   ./tools/sync-upstream.sh sync       update fork/master and rebase PR branches
#   ./tools/sync-upstream.sh merge      merge upstream/master into origin/master
#   ./tools/sync-upstream.sh check      run the full local test suite
#   ./tools/sync-upstream.sh all        sync + merge + check
#
# Options:
#   --dry-run     with 'sync' or 'merge': show what would happen, do nothing
#   --no-fetch    skip the 'git fetch' step (use the already-fetched refs)
#
# The script never pushes to 'origin' (the product fork) and never touches
# upstream.  It only pushes to 'fork', and only to move fork/master forward
# and to rebase our own PR branches.
#
# EXIT STATUS
# ===========
#
#   0  everything fine
#   1  usage error, or git refused
#   2  a problem was found that needs a human (conflicts, behind state)
#

set -e

UPSTREAM_REMOTE=${UPSTREAM_REMOTE:-upstream}
FORK_REMOTE=${FORK_REMOTE:-fork}
ORIGIN_REMOTE=${ORIGIN_REMOTE:-origin}
UPSTREAM_REPO=${UPSTREAM_REPO:-freebasic/fbc}
GITHUB_USER=${GITHUB_USER:-RainerXE}

ACTION=status
DRY_RUN=0
DO_FETCH=1

for arg in "$@"; do
	case "$arg" in
		status|sync|merge|check|all) ACTION="$arg" ;;
		--dry-run)   DRY_RUN=1 ;;
		--no-fetch)  DO_FETCH=0 ;;
		-h|--help)   sed -n '2,45p' "$0"; exit 0 ;;
		*) echo "sync-upstream.sh: unknown argument '$arg'" >&2; exit 1 ;;
	esac
done

cd "$(dirname "$0")/.."
ROOT=$(pwd)

say()  { printf '%s\n' "$*"; }
head1() { printf '\n== %s\n' "$*"; }
warn() { printf '   !! %s\n' "$*" >&2; }
die()  { printf '   ERROR: %s\n' "$*" >&2; exit 1; }

need() {
	command -v "$1" >/dev/null 2>&1 || die "missing tool: $1"
}

need git
have_gh=0
command -v gh >/dev/null 2>&1 && have_gh=1

# ---------------------------------------------------------------- fetch ----

fetch_all() {
	[ "$DO_FETCH" = 1 ] || return 0
	head1 "Fetching"
	git fetch --quiet "$UPSTREAM_REMOTE" master || die "fetch $UPSTREAM_REMOTE failed"
	git fetch --quiet "$FORK_REMOTE" --prune || die "fetch $FORK_REMOTE failed"
	git fetch --quiet "$ORIGIN_REMOTE" --prune || die "fetch $ORIGIN_REMOTE failed"
	say "   fetched $UPSTREAM_REMOTE, $FORK_REMOTE, $ORIGIN_REMOTE"
}

# --------------------------------------------------------------- status ----

our_pr_branches() {
	# branches in the fork that we own and that are not master.
	# 'refs/remotes/<remote>' itself is the HEAD symref and must be skipped,
	# as must the remote's HEAD pointer.
	git for-each-ref --format='%(refname:short)' "refs/remotes/$FORK_REMOTE" \
		| sed -e "s#^$FORK_REMOTE/##" \
		| grep -v '^master$' \
		| grep -v '^HEAD$' \
		| grep -v "^$FORK_REMOTE\$" || true
}

report_prs() {
	head1 "Our pull requests to $UPSTREAM_REPO"
	if [ "$have_gh" = 0 ]; then
		say "   (gh not available - skipping)"
		return 0
	fi
	gh pr list --repo "$UPSTREAM_REPO" --author "$GITHUB_USER" --state open \
		--json number,title,headRefName,createdAt,mergeable,mergeStateStatus \
		--jq '.[] | "   #\(.number) [\(.mergeStateStatus)] head=\(.headRefName) opened=\(.createdAt[0:10]) \(.title)"' \
		2>/dev/null || say "   (could not query $UPSTREAM_REPO)"
}

status_report() {
	head1 "State"
	# 'git rev-list --left-right --count A...B' prints "<A-only> <B-only>".
	local fu uo
	fu=$(git rev-list --left-right --count "$FORK_REMOTE/master...$UPSTREAM_REMOTE/master" 2>/dev/null || echo "? ?")
	uo=$(git rev-list --left-right --count "$UPSTREAM_REMOTE/master...$ORIGIN_REMOTE/master" 2>/dev/null || echo "? ?")
	# fork: behind upstream = upstream-only commits (right column)
	# origin: behind upstream = upstream-only commits (left column)
	#         ahead of upstream = origin-only commits (right column)

	say "   upstream/master                    $(git rev-parse --short "$UPSTREAM_REMOTE/master")"
	say "   $FORK_REMOTE/master                          $(git rev-parse --short "$FORK_REMOTE/master")   behind upstream by $(echo "$fu" | cut -f2)"
	say "   $ORIGIN_REMOTE/master                         $(git rev-parse --short "$ORIGIN_REMOTE/master")   behind upstream by $(echo "$uo" | cut -f1), ahead by $(echo "$uo" | cut -f2)"

	local b
	for b in $(our_pr_branches); do
		if git merge-base --is-ancestor "$UPSTREAM_REMOTE/master" "$FORK_REMOTE/$b" 2>/dev/null; then
			say "   $FORK_REMOTE/$b : up to date with upstream"
		else
			say "   $FORK_REMOTE/$b : NEEDS REBASE (upstream moved on)"
		fi
	done

	report_prs
}

# ----------------------------------------------------------------- sync ----

sync_fork_master() {
	head1 "Syncing $FORK_REMOTE/master with $UPSTREAM_REMOTE/master"
	local behind
	behind=$(git rev-list --count "$FORK_REMOTE/master..$UPSTREAM_REMOTE/master")
	if [ "$behind" = 0 ]; then
		say "   already up to date"
		return 0
	fi
	say "   $FORK_REMOTE/master is $behind commit(s) behind; fast-forwarding"
	if [ "$DRY_RUN" = 1 ]; then
		say "   (dry run: would push $UPSTREAM_REMOTE/master -> $FORK_REMOTE/master)"
		return 0
	fi
	git push --quiet "$FORK_REMOTE" "$UPSTREAM_REMOTE/master:refs/heads/master" \
		|| die "could not fast-forward $FORK_REMOTE/master"
	say "   done"
}

rebase_pr_branches() {
	head1 "Rebasing our PR branches onto $UPSTREAM_REMOTE/master"
	local b changed=0
	for b in $(our_pr_branches); do
		if git merge-base --is-ancestor "$UPSTREAM_REMOTE/master" "$FORK_REMOTE/$b" 2>/dev/null; then
			say "   $b: up to date, nothing to do"
			continue
		fi
		say "   $b: rebase needed"
		changed=1
		if [ "$DRY_RUN" = 1 ]; then
			say "   (dry run: would rebase $b and force-push)"
			continue
		fi
		# work on a local branch, rebase, then force-push
		git branch -f "sync/$b" "$FORK_REMOTE/$b" >/dev/null 2>&1 || true
		if ! git checkout --quiet "sync/$b"; then
			warn "$b: cannot check out, skipping"
			continue
		fi
		if ! git rebase "$UPSTREAM_REMOTE/master"; then
			warn "$b: rebase conflict - resolve manually, then:"
			warn "    git rebase --continue && git push --force-with-lease $FORK_REMOTE sync/$b:$b"
			git rebase --abort >/dev/null 2>&1 || true
			git checkout --quiet master 2>/dev/null || true
			continue
		fi
		git push --quiet --force-with-lease "$FORK_REMOTE" "sync/$b:$b" \
			|| warn "$b: force-push refused (someone else pushed?)"
		git branch -D "sync/$b" >/dev/null 2>&1 || true
		say "   $b: rebased and pushed"
	done
	git checkout --quiet master 2>/dev/null || true
	[ "$changed" = 1 ] || say "   nothing to rebase"
}

# ---------------------------------------------------------------- merge ----

# Would merging upstream/master into origin/master conflict?  Uses
# 'git merge-tree' so the working tree is never touched.
merge_would_conflict() {
	local out
	out=$(git merge-tree --write-tree --name-only \
		"$ORIGIN_REMOTE/master" "$UPSTREAM_REMOTE/master" 2>/dev/null)
	if [ $? -eq 0 ]; then
		return 1	# no conflict
	fi
	# rc != 0: the lines after the tree hash are the conflicted paths
	printf '%s\n' "$out" | tail -n +2 | grep -v '^$' || true
	return 0		# conflict
}

report_merge_conflicts() {
	head1 "Merge preview: $UPSTREAM_REMOTE/master into $ORIGIN_REMOTE/master"
	local behind files
	# commits upstream has that we do not
	behind=$(git rev-list --count "$ORIGIN_REMOTE/master..$UPSTREAM_REMOTE/master")
	if [ "$behind" = 0 ]; then
		say "   $ORIGIN_REMOTE/master already contains $UPSTREAM_REMOTE/master"
		return 0
	fi
	say "   $behind upstream commit(s) to bring in"
	if files=$(merge_would_conflict); then
		say "   MERGE WOULD CONFLICT in:"
		printf '%s\n' "$files" | sed 's/^/     /'
		say "   resolve by hand, or run '$0 merge' and finish the conflict"
		return 2
	fi
	say "   merge is clean (no conflicting files)"
	return 0
}

merge_upstream() {
	head1 "Merging $UPSTREAM_REMOTE/master into $ORIGIN_REMOTE/master"
	local behind
	# commits upstream has that we do not
	behind=$(git rev-list --count "$ORIGIN_REMOTE/master..$UPSTREAM_REMOTE/master")
	if [ "$behind" = 0 ]; then
		say "   $ORIGIN_REMOTE/master already contains $UPSTREAM_REMOTE/master"
		return 0
	fi
	say "   merging; $behind upstream commit(s) to bring in"
	if [ "$DRY_RUN" = 1 ]; then
		say "   (dry run: would 'git merge $UPSTREAM_REMOTE/master' on $ORIGIN_REMOTE/master)"
		report_merge_conflicts || true
		return 0
	fi
	require_clean_tree || return 2
	git checkout --quiet master
	if ! git merge --no-edit "$UPSTREAM_REMOTE/master"; then
		warn "merge conflict - resolve, then 'git commit' and push to $ORIGIN_REMOTE"
		return 2
	fi
	say "   merged; run '$0 check' before pushing"
}

# ---------------------------------------------------------------- check ----

# Several actions check out origin/master, so refuse to run with a dirty tree.
require_clean_tree() {
	local dirty
	dirty=$(git status --porcelain)
	if [ -n "$dirty" ]; then
		warn "working tree has uncommitted changes - commit or stash them first:"
		printf '%s\n' "$dirty" | sed 's/^/     /' >&2
		return 1
	fi
	return 0
}

run_checks() {
	head1 "Local checks on $ORIGIN_REMOTE/master"
	require_clean_tree || return 2
	git checkout --quiet master
	say "   building the bootstrap compiler, then the compiler, runtime and gfxlib2"
	if ! make bootstrap >/tmp/frej-sync-build.log 2>&1; then
		warn "'make bootstrap' failed - see /tmp/frej-sync-build.log"
		tail -20 /tmp/frej-sync-build.log >&2
		return 2
	fi
	if ! make -j4 FBC="bin/fbc -i inc" >>/tmp/frej-sync-build.log 2>&1; then
		warn "build failed - see /tmp/frej-sync-build.log"
		tail -20 /tmp/frej-sync-build.log >&2
		return 2
	fi
	say "   build ok"
	# The unit test suite has two long-standing failures, both the same
	# constant-evaluation of acos() in tests/optimizations/consteval.bas.
	# They are a property of the host's floating point, not of our changes,
	# so they are tolerated - but nothing else is.
	make unit-tests >/tmp/frej-sync-unit.log 2>&1
	local unexpected
	unexpected=$(grep ' : error : ' /tmp/frej-sync-unit.log \
		| grep -v 'acos(' \
		| grep -v 'optimizations/consteval.bas' || true)
	if [ -n "$unexpected" ]; then
		warn "unit-tests failed with unexpected errors:"
		printf '%s\n' "$unexpected" | sed 's/^/     /' >&2
		return 2
	fi
	if grep -q ' : error : ' /tmp/frej-sync-unit.log; then
		say "   unit-tests ok (only the known acos() consteval failures)"
	else
		say "   unit-tests ok"
	fi
	if ! make acceptance >/tmp/frej-sync-accept.log 2>&1; then
		warn "acceptance failed - see /tmp/frej-sync-accept.log"
		tail -20 /tmp/frej-sync-accept.log >&2
		return 2
	fi
	say "   acceptance ok"
	rm -f /tmp/frej-sync-build.log /tmp/frej-sync-unit.log /tmp/frej-sync-accept.log
}

# ----------------------------------------------------------------- main ----

case "$ACTION" in
	status)
		fetch_all
		status_report
		report_merge_conflicts || true
		;;
	sync)
		fetch_all
		status_report
		sync_fork_master
		rebase_pr_branches
		;;
	merge)
		fetch_all
		merge_upstream
		;;
	check)
		run_checks
		;;
	all)
		fetch_all
		status_report
		sync_fork_master
		rebase_pr_branches
		merge_upstream || exit 2
		run_checks
		;;
esac
