#!/bin/sh
# Usage: scripts/upstream-diff.sh <from-version> <to-version> [workdir]
#
# Downloads @digdir/designsystemet-{react,web,css} at both versions and writes
# a report of only what can matter to the Elm port (see UPGRADING.md):
#
#   <workdir>/report.md        summary: changed exports, components, web, css
#   <workdir>/react.diff       component markup (.js) and props (.d.ts)
#   <workdir>/web.diff         behaviour layer: README and custom elements
#   <workdir>/css.diff         component stylesheets (data attributes, classes)
#   <workdir>/stories.diff     Storybook stories, which the showcase mirrors
#
# Nothing in the downloaded packages is executed.
set -eu

from=${1:?from version, e.g. 1.23.0}
to=${2:?to version, e.g. 1.24.0}
work=${3:-$(mktemp -d)}
mkdir -p "$work"

fetch() { # package version -> directory with the unpacked package
    dir="$work/$1-$2"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        (cd "$dir" && npm pack --silent "@digdir/designsystemet-$1@$2" >/dev/null && tar xzf ./*.tgz)
    fi
    echo "$dir/package"
}

for pkg in react web css; do
    fetch "$pkg" "$from" >/dev/null
    fetch "$pkg" "$to" >/dev/null
done

r1=$(fetch react "$from")/dist/esm
r2=$(fetch react "$to")/dist/esm
w1=$(fetch web "$from")
w2=$(fetch web "$to")
c1=$(fetch css "$from")/dist/src
c2=$(fetch css "$to")/dist/src

# Drop source map comments and the "'use client'" pragma.
clean() { sed -e '/sourceMappingURL/d' -e "/^'use client';/d" "$1"; }

difftree() { # a b glob -> unified diff of matching files
    (cd "$1" && find . -name "$3" | sort) >"$work/.a"
    (cd "$2" && find . -name "$3" | sort) >"$work/.b"
    sort -u "$work/.a" "$work/.b" | while read -r f; do
        a="$1/$f"
        b="$2/$f"
        [ -f "$a" ] || a=/dev/null
        [ -f "$b" ] || b=/dev/null
        diff -u --label "$from/$f" --label "$to/$f" \
            "$( [ "$a" = /dev/null ] && echo /dev/null || { clean "$a" >"$work/.x"; echo "$work/.x"; })" \
            "$( [ "$b" = /dev/null ] && echo /dev/null || { clean "$b" >"$work/.y"; echo "$work/.y"; })" || true
    done
}

exports() { # components/index.d.ts -> one exported name per line
    sed -n 's/^export {\(.*\)};.*/\1/p' "$1" | tr ',' '\n' |
        sed -e 's/^ *//' -e 's/ *$//' -e 's/^type //' -e 's/.* as //' | sort -u
}

{
    difftree "$r1/components" "$r2/components" '*.js'
    difftree "$r1/components" "$r2/components" '*.d.ts'
    difftree "$r1" "$r2" 'types.d.ts'
} >"$work/react.diff"
{
    diff -u --label "$from/README.md" --label "$to/README.md" "$w1/README.md" "$w2/README.md" || true
    difftree "$w1/dist/esm" "$w2/dist/esm" '*.js'
} >"$work/web.diff"
difftree "$c1" "$c2" '*.css' >"$work/css.diff"

# Stories aren't in the npm package: diff them between the release tags of the
# upstream repo. A blobless clone only downloads the files the diff touches.
repo="$work/designsystemet.git"
if [ ! -d "$repo" ]; then
    git clone --quiet --bare --filter=blob:none https://github.com/digdir/designsystemet.git "$repo"
fi
git --git-dir="$repo" fetch --quiet --depth=1 origin "refs/tags/v$from:refs/tags/v$from" "refs/tags/v$to:refs/tags/v$to"
git --git-dir="$repo" diff "v$from" "v$to" -- 'packages/react/src/components/*.stories.tsx' \
    >"$work/stories.diff"

exports "$r1/components/index.d.ts" >"$work/exports-$from"
exports "$r2/components/index.d.ts" >"$work/exports-$to"

{
    echo "# designsystemet $from → $to"
    echo
    echo "## React exports added"
    comm -13 "$work/exports-$from" "$work/exports-$to" | sed 's/^/- /'
    echo
    echo "## React exports removed"
    comm -23 "$work/exports-$from" "$work/exports-$to" | sed 's/^/- /'
    echo
    echo "## Components with changed markup or props"
    grep '^+++ ' "$work/react.diff" | sed -n "s|^+++ $to/\./\([^/]*\)/.*|- \1|p" | sort -u
    echo
    echo "## Newly deprecated (grep @deprecated in added lines)"
    grep -n '^+.*@deprecated' "$work/react.diff" | sed 's/^/- /' || true
    echo
    echo "## Web layer files changed"
    grep '^+++ ' "$work/web.diff" | sed -e 's/^+++ /- /' -e 's|/\./|/|'
    echo
    echo "## Stories added, removed or changed"
    git --git-dir="$repo" diff --name-status "v$from" "v$to" -- 'packages/react/src/components/*.stories.tsx' |
        sed -e 's|packages/react/src/components/||' -e 's/^/- /'
    echo
    echo "## CSS files changed"
    grep '^+++ ' "$work/css.diff" | sed -e 's/^+++ /- /' -e 's|/\./|/|'
    echo
    echo "Diff sizes: react $(wc -l <"$work/react.diff") lines, web $(wc -l <"$work/web.diff"), css $(wc -l <"$work/css.diff"), stories $(wc -l <"$work/stories.diff")."
} >"$work/report.md"

rm -f "$work/.a" "$work/.b" "$work/.x" "$work/.y"
echo "$work/report.md"
