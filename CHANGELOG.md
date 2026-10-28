# Changelog

Versions follow `@digdir/designsystemet-react`: port `1.23.0` mirrors React
`1.23.0`. Fixes to this package's own Elm or JavaScript, with `-css` and
`-web` unchanged, add a dash and a number: `1.23.0-1`, `1.23.0-2`, … The
current version is in [`VERSION`](VERSION).

The npm package `@ensolabs/designsystemet-elm` uses the same version. The Elm
package's version in `elm.json` is separate, because the Elm registry only
accepts plain `MAJOR.MINOR.PATCH`. It starts at `1.0.0`, `elm bump` sets it
from the API diff, and each section below names it.

## 1.23.0 (unreleased)

Mirrors `@digdir/designsystemet-react@1.23.0`. Elm package `1.0.0`.

### Added

- 41 component modules: every non-deprecated component in the React package,
  plus `Designsystemet` (size, color, color scheme, accessible names),
  `Designsystemet.Color`, `Designsystemet.Size` and `Designsystemet.Placement`.
  `AvatarStack`, `FileUpload` and `Suggestion` are experimental, as upstream.
- The showcase: all 271 upstream component stories, ported or skipped (5,
  with reasons), each linked to its React version.
- `@ensolabs/designsystemet-elm` on npm: one import that loads
  `@digdir/designsystemet-web` and `js/open-state.js`, a small script that
  lets `Dialog.open`, `Popover.open` and `Dropdown.open` open dialogs and
  popovers from the model, like React's `open` prop.
- `bun run parity`, which diffs every story's markup against the live
  Storybook and screenshots both, and `bun run smoke`, which tests the
  showcase's behaviour in a real browser (in CI).
- README section "Using with Tailwind": mapping the theme's tokens into
  Tailwind v4, the layer order that keeps component styles and utilities
  from overriding each other, and how `Ds.color`, `Ds.size` and
  `Ds.colorScheme` reach utilities.
- A tested getting-started recipe for Bun on the showcase's front page, with
  and without Tailwind.
- `bun run tailwind`, which checks that every story looks the same with
  Tailwind's reset on the page (in CI).
- `Skeleton.round`: a circle with no diameter of its own, sized with classes.

### Fixed

- `Dialog.view`, `Popover.view` and `Dropdown.view`: the typed `Id` now wins
  over an `Attr.id` in the attributes, so triggers can't lose their target.

### Documented

- `Spinner`: `Html.Attributes.class` on its `<svg>` throws; use
  `Svg.Attributes.class`.
- `Skeleton`: `rectangle` and `circle` sizes are inline styles and win over
  classes. Size an empty `view`, or `round`, with classes instead.

### Removed

- `Size.custom`. The theme's CSS only defines `sm`, `md` and `lg`, so any
  other `data-size` matched nothing and silently kept the parent's size.
  `Size` now has exactly those three, as in React.

### Not ported

- `Combobox`, deprecated upstream in favour of `Suggestion`.
- Deprecated props, such as `Label` `weight` and `Avatar` `initials`.
- `Suggestion`'s `onBeforeMatch` and custom `filter` function. Filter the
  options in Elm instead.

### Differences from React

Each module documents its own. The main ones:

- Accessible names, heading levels and every user-facing text are required.
  React has Norwegian defaults; this package has none.
- `Popover` and `Dropdown` use `popover="auto"`, the browser's own light
  dismiss, where React reimplements it in JavaScript.
- Attributes managed by `designsystemet-web` (e.g. `aria-invalid` and
  `aria-describedby` inside a `Field`) are left to it.
- Icon-only `ToggleGroup` items name their radio, which React leaves unnamed.
