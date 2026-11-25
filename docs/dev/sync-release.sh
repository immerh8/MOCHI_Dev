#!/usr/bin/env bash
# Copy the MOCHI_Dev tree (development) into a checkout of Sepiolina/MOCHI
# (release), leaving out the files that stay in development only.
#
#   docs/dev/sync-release.sh <path-to-Sepiolina-MOCHI-checkout>
#
# Run it from a clean MOCHI_Dev checkout of the commit to release. It mirrors
# tracked files only, deletes in the release checkout whatever development no
# longer has, and leaves the result uncommitted for review. Commit messages in
# the release repository carry no Claude-Session: trailer.
set -euo pipefail

# Paths that exist only in MOCHI_Dev.
EXCLUDE=(
  AGENTS.md
  docs/README.md
  docs/dev/
  docs/ratification/
  # Checks the drafts in docs/ratification/ against the code, so it stays too.
  crates/mochi-cli/tests/ratification_drafts.rs
)

dest=${1:?usage: $0 <path-to-Sepiolina-MOCHI-checkout>}
src=$(git rev-parse --show-toplevel)
[ -d "$dest/.git" ] || { echo "$dest is not a git checkout" >&2; exit 1; }
[ -z "$(git -C "$src" status --porcelain)" ] || { echo "MOCHI_Dev has uncommitted changes" >&2; exit 1; }

is_excluded() {
  local p
  for p in "${EXCLUDE[@]}"; do
    case $p in
      */) [[ $1 == "$p"* ]] && return 0 ;;
      *)  [[ $1 == "$p" ]] && return 0 ;;
    esac
  done
  return 1
}

# Remove release files that development no longer tracks (and excluded ones).
git -C "$dest" ls-files -z | while IFS= read -r -d '' f; do
  if is_excluded "$f" || ! git -C "$src" cat-file -e "HEAD:$f" 2>/dev/null; then
    git -C "$dest" rm -q --cached -- "$f"; rm -f -- "$dest/$f"
  fi
done

# Copy every tracked development file that is not excluded.
git -C "$src" ls-files -z | while IFS= read -r -d '' f; do
  is_excluded "$f" && continue
  mkdir -p -- "$dest/$(dirname -- "$f")"
  cp -p -- "$src/$f" "$dest/$f"
done

git -C "$dest" add -A
echo "Synced MOCHI_Dev $(git -C "$src" rev-parse --short HEAD) into $dest; review with: git -C $dest status"
