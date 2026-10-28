# Following upstream

How to port a new release of `@digdir/designsystemet-react`. Read
[CONTRIBUTING.md](CONTRIBUTING.md) first; every change here follows its rules.

Most upstream changes need nothing from us. React internals, Storybook, build
tooling and TypeScript-only refactors don't touch the markup. CSS and
behaviour fixes in `designsystemet-css` and `designsystemet-web` reach Elm
users at runtime once the peer versions are bumped. What's left is a short
list of markup and API changes to pick out of the diff.

## 1. Get the diff

```sh
scripts/upstream-diff.sh 1.23.0 1.24.0 /tmp/ds-upgrade
```

Output:

- `report.md`: exports added and removed, components whose markup or props
  changed, new `@deprecated` tags, changed web-layer and CSS files, and
  stories added, removed or changed.
- `react.diff`: component `.js` (markup) and `.d.ts` (props and docs).
- `web.diff`: the `designsystemet-web` README and sources (minified; run
  them through a formatter in a scratch directory if a hunk matters).
- `css.diff`: component stylesheets.
- `stories.diff`: the Storybook stories the showcase mirrors.

To skip several releases, diff the whole range in one run, but list every
release in between in the changelog (step 4).

## 2. Triage every hunk

Put each hunk in one category. If unsure, compare what the `.js` renders
before and after: identical markup means no-op.

| Category | Typical signs | What to do |
| --- | --- | --- |
| **No-op: React internals** | `forwardRef`, `useMergeRefs`, `useId`, context, `suppressHydrationWarning`, React 18/19 compatibility, Slot/`asChild` plumbing, event handler wiring that ends in the same DOM | Nothing |
| **No-op: types and docs** | reordered TS unions (`"children" \| "asChild"` → `"asChild" \| "children"`), doc and `@example` rewrites, `MergeRight`/`Omit` refactors | Nothing, unless a doc change reveals a behaviour change. Then update our module docs to match. |
| **Runtime only** | `css.diff`, `web.diff` with no change to the attributes or elements we render | Bump the peers (step 4). Check the showcase visually. |
| **Markup change** | a different element, class, `data-*`, ARIA attribute or default attribute in a `.js` | Change the Elm view until the markup matches again. Update the tests that assert it. |
| **New prop** | a new field in `*Props` | Port it by CONTRIBUTING's API rules: a `data-*` value becomes an exported `Html.Attribute`, something structural or required becomes a typed argument or builder step, a UI string becomes a required argument. |
| **New component** | a name under "React exports added" | Add a module, tests, stories, and a line in the right group of `elm.json` `exposed-modules`. Experimental upstream (`EXPERIMENTAL_`) means experimental here; say so in the module doc. |
| **Deprecated** | `@deprecated` in added lines | Don't port it. If we already have it, mark it deprecated in the doc comment and point to the replacement. Remove it when upstream does. |
| **Removed** | "React exports removed", or a prop gone from `*Props` | Remove it from the Elm API. Breaking change: note it prominently. |
| **Ownership change** | the web layer starts or stops managing an attribute or child nodes (`web.diff`, README) | Apply "one owner per attribute": update the module's **Managed by designsystemet-web** list, and stop rendering what the web layer now owns (or start rendering what it no longer owns). Re-check controlled modes (Tabs, ToggleGroup, Details, Suggestion) in the showcase. |
| **Story change** | `stories.diff` | Add, remove or change the showcase story of the same name. |

Example, 1.22.0 → 1.23.0:

- The Avatar and AvatarStack `@example` blocks moved from `initials="JD"` to
  children. Docs only, but a sign `initials` is going away, so we don't port
  it.
- The `BreadcrumbsLink` and `Card` `.d.ts` hunks are reordered TS unions:
  no-ops.
- `Label` `weight` got `@deprecated`, since the field now picks the weight.
  Not ported.
- `popover-fn.js`, `pagination.js` and `suggestion.js` changed in the web
  layer. Runtime only, unless the README says an attribute changed hands.

## 3. Apply

One component at a time:

1. Read the new `.js` and `.d.ts` in full, not only the hunk.
2. Change the module, its docs (including the React → Elm list) and tests.
3. Update its showcase stories.

## 4. Version and changelog

- Set [`VERSION`](VERSION), `Designsystemet.version` and `package.json`'s
  `version` to the new React version, e.g. `1.24.0`.
- Bump `@digdir/designsystemet-web` (`dependencies`) and
  `@digdir/designsystemet-css` (`peerDependencies` and `devDependencies`) in
  `package.json`, and run `bun install`.
- Apps pin `@digdir/designsystemet-css` exactly, never as a range: CSS from
  another release doesn't match the markup. The peer dependency makes npm
  refuse a mismatch. (`-web` comes with `@ensolabs/designsystemet-elm`.)
- Add a changelog section `## 1.24.0`, with entries under **Added**,
  **Changed**, **Deprecated**, **Removed** and **Fixed**. If the release
  needed nothing, write "No Elm changes; CSS and web fixes via the peer
  bump", so readers know it was checked.
- Run `elm bump`. The Elm registry has its own semver, derived from the API
  diff; name it in the changelog section ("Elm package `1.1.0`").

Fixes to this package's own Elm or JavaScript, with no change to `-css` or
`-web`, get a dash between upstream releases: `1.24.0-1`, `1.24.0-2`. Set it
in `VERSION`, `Designsystemet.version`, `package.json`'s `version` and the
changelog heading. The `-web` and `-css` pins, here and in apps, stay at
`1.24.0`. A fix only in `js/` still needs an Elm release, because
`Designsystemet.version` changes.

## 5. Check

```sh
bun run check            # make (docs), format, review, tests, version sync
bun run showcase:build
bun run smoke            # behaviour in a real browser, with the web layer
bun run parity           # every Elm story against its live React twin
```

`smoke` checks that Elm and designsystemet-web still work together: invokers
open dialogs, controlled tabs refuse a change when `update` refuses it, and
so on. A new web-layer release is when this tends to break, so it must pass.
Add a check when an upgrade changes who owns an attribute.

Parity catches what types and tests miss. For every story, `bun run parity`
diffs the normalized markup of the Elm story against the same story on
storybook.designsystemet.no, and screenshots both into `showcase/parity/`
(gitignored):

- Read `showcase/parity/report.md`. Every story should be "identical", or
  differ only in a way its module documents, such as attributes the web
  layer owns.
- Look at the screenshots. Open each changed component's `.elm.png` next to
  its `.react.png`, in both color schemes if the change touches color. Agents
  use the Read tool on the PNGs. This catches CSS and theme effects a markup
  diff can't.
- `bun run parity tabs dialog` limits the run to some chapters.

The live Storybook shows upstream's latest release, so run parity right after
an upgrade, when it should match `VERSION` exactly.

## 6. Release

Release both packages together, from a clean `master` with `bun run check`
green. The Elm registry needs a git tag that is exactly the Elm version, so
npm releases get a prefixed tag to avoid collisions:

```sh
git tag 1.1.0 && git push origin 1.1.0       # the Elm version, from elm.json
elm publish
git tag npm-v1.24.0 && git push origin npm-v1.24.0
npm publish                                  # public, via publishConfig
```

npm treats a `-N` version (`1.24.0-1`) as a prerelease and won't make it
`latest` on its own, so publish those with `npm publish --tag latest`.
