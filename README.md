# Designsystemet for Elm

[Designsystemet](https://designsystemet.no), the Norwegian public sector's
design system, as Elm view functions. A 1:1 port of
[`@digdir/designsystemet-react@1.23.0`](https://www.npmjs.com/package/@digdir/designsystemet-react/v/1.23.0):
same components, markup and CSS. Rules React only documents are enforced by
types here. The example below is compiled in `tests/ReadmeTest.elm`.

All components are in the [showcase](https://ensolabs.github.io/designsystemet-elm/).

```elm
import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Size as Size
import Designsystemet.Textfield as Textfield

view : Model -> Html Msg
view model =
    Html.form [ Ds.size Size.sm, Events.onSubmit Save ]
        [ Textfield.new (Ds.label "Navn")
            |> Textfield.withError model.nameError
            |> Textfield.view [ Attr.value model.name, Events.onInput NameChanged ]
        , Button.view [ Attr.type_ "submit" ] [ Html.text "Lagre" ]
        , Button.view [ Button.tertiary, Ds.color Color.danger, Events.onClick Delete ]
            [ Html.text "Slett" ]
        ]
```

## How it works

- This Elm package, `ensolabs/designsystemet-elm`, renders the same markup as
  the React components.
- [`@digdir/designsystemet-css`](https://www.npmjs.com/package/@digdir/designsystemet-css)
  and a theme style it: every `ds-*` class and `data-*` attribute.
- [`@digdir/designsystemet-web`](https://www.npmjs.com/package/@digdir/designsystemet-web)
  adds behaviour (tabs, popovers, dialogs, field wiring, tooltips) as web
  components and polyfills.

React also gets its behaviour from `@digdir/designsystemet-web` and leaves the
CSS to you. Here the npm package `@ensolabs/designsystemet-elm` brings `-web`
along. Nothing is reimplemented.

Each module lists the attributes the web layer manages, and never renders
them. With one owner per attribute, Elm's virtual DOM and the web components
can share elements.

## Setup

You need the Elm package and the npm package `@ensolabs/designsystemet-elm`,
plus a bundler (Vite, esbuild, Bun, …) for the JavaScript.

1. Add the Elm package:

   ```sh
   elm install ensolabs/designsystemet-elm
   ```

2. Add the JavaScript and the CSS, pinned exactly:

   ```sh
   npm install -E @ensolabs/designsystemet-elm@1.23.0 @digdir/designsystemet-css@1.23.0
   ```

3. Import both once in your JavaScript entry point:

   ```js
   import "@digdir/designsystemet-css";
   import "@digdir/designsystemet-css/theme"; // or your own theme from theme.designsystemet.no
   import "@ensolabs/designsystemet-elm";
   ```

   The last line loads `@digdir/designsystemet-web` at the version this port
   mirrors, plus a small script that opens dialogs and popovers from the
   model (`Dialog.open model.isOpen`), which needs a method call Elm can't
   make. Don't install or import `-web` yourself.

   The stylesheets must load before Elm first renders: some web components,
   like `<ds-suggestion>`, read their texts from CSS when they connect.
   Static CSS imports in a bundled entry point load in that order.

   **Bun:** don't import the CSS. Bun's CSS bundler can't parse
   Designsystemet's CSS (`sibling-index()`). Serve the two stylesheets as
   files and link them from JavaScript before starting Elm. The showcase's
   [front page](https://ensolabs.github.io/designsystemet-elm/) has a tested
   Bun setup, with and without Tailwind, from an empty folder to `bun run dev`
   and `bun run build`.

4. Load your theme's font. The default theme uses
   [Inter](https://fonts.google.com/specimen/Inter).

## Using with Tailwind

Tailwind v4 can use the theme's tokens, so `bg-accent-surface-tinted`, `p-4`
and `shadow-md` come from Designsystemet. Start your main stylesheet with:

```css
@layer theme, base, ds, components, utilities;
@import "tailwindcss";
@theme { --color-*: initial; --spacing: initial; } /* optional */
@import "@digdir/designsystemet-css/theme/designsystemet.tailwind.css" theme(inline);

/* Tailwind's reset removes list markers; Designsystemet's lists rely on them. */
@layer base {
  .ds-list,
  .ds-list :is(ul, ol) {
    list-style: revert;
  }
}
```

- `@layer` puts Designsystemet's `@layer ds` after Tailwind's reset and
  before its utilities. Without it, component styles beat utilities (`mt-4`
  on a `ds-paragraph` gives 0). Loading Designsystemet's CSS before Tailwind,
  as upstream suggests, lets the reset strip buttons of background and
  padding and shrink headings. The first stylesheet that names a layer fixes
  the order, so this line must be in the first stylesheet the page loads.
- `theme(inline)` makes utilities use the `--ds-*` variables directly (`p-4`
  is `padding: var(--ds-size-4)`), so they resolve on the element and follow
  the data attributes below. Without it they resolve once on `:root`: `p-4`
  stays 16px inside `Ds.size Size.sm` (should be 14px), and a dark section
  stays light.
- Use the string form of `@import`. Tailwind doesn't inline `@import url(…)`.
- The `.ds-list` rule is needed because the reset sets `list-style: none` on
  every list. The rest of the reset leaves components alone: `bun run
  tailwind` checks every story with this stylesheet (`showcase/tailwind.css`)
  on the page.
- The optional `@theme` line removes Tailwind's own palette and spacing
  scale. `bg-red-500`, `bg-white`, `p-16` and `w-64` are gone, and spacing
  utilities (`p`, `m`, `gap`, `w`, `h`, …) take the theme's steps 0–15, 18,
  22, 26 and 30.

Mapped: every theme color (`bg-danger-surface-tinted`,
`text-neutral-text-subtle`, `border-accent-border-default`; the default theme
has `accent`, `neutral`, `brand1`, `brand2`, `info`, `success`, `warning` and
`danger`), the current color without a name (`bg-surface-tinted`,
`text-text-default`), spacing, `rounded-sm` to `rounded-xl`, `shadow-xs` to
`shadow-xl`, `font-sans`, font weights and `opacity-disabled`. Not mapped:
font sizes (`text-sm` is Tailwind's; use `Heading` and `Paragraph` for text),
`rounded`, `rounded-full` and breakpoints.

### Data attributes

`Ds.color`, `Ds.size` and `Ds.colorScheme` set `data-color`, `data-size` and
`data-color-scheme`, which change the `--ds-*` variables for everything
inside, utilities included:

```elm
Html.section [ Ds.color Color.danger, Attr.class "bg-surface-tinted p-4 rounded-md" ]
    [ Paragraph.view [] [ Html.text "Kan ikke angres." ] ]
```

This section is red-tinted. Unnamed colors (`bg-surface-tinted`,
`text-text-default`, …) follow the nearest `data-color`, or `accent` if there
is none. Named colors (`bg-accent-surface-tinted`) ignore it. Inside
`Ds.size Size.sm`, `p-4` shrinks with the components. Inside
`Ds.colorScheme Ds.Dark`, colors turn dark.

To color something from a `Color` value, set `Ds.color` and use an unnamed
class. Don't build class names like `"bg-" ++ Color.toString c ++ "-surface-tinted"`:
Tailwind scans your source for whole class names, so a built one gets no CSS.

### Classes

`Attr.class` goes in the attribute list and adds to the component's own
`ds-*` class:

```elm
Button.view [ Attr.class "mt-4" ] [ Html.text "Lagre" ]

Textfield.new (Ds.label "Navn")
    |> Textfield.withFieldAttributes [ Attr.class "max-w-md" ] -- the field around it
    |> Textfield.view [ Attr.class "font-medium" ] -- the <input>
```

### Bun

Keep Designsystemet's CSS out of the bundle; Bun can't parse it
(`sibling-index()`). Serve `@digdir/designsystemet-css` and your theme as
files, add their `<link>`s after the Tailwind stylesheet, and start Elm once
they've loaded. Only the Tailwind stylesheet goes through
`bun-plugin-tailwind`.

- Don't `@import` the Designsystemet CSS from the Tailwind stylesheet, not
  even by `url(…)` marked external. Bun moves the `@import` above the
  `@layer` line, so Designsystemet's layers come first and the reset wins.
- Don't use `import … with { type: "file" }` for it. Bun 1.3.14 crashes when
  that meets `bun-plugin-tailwind`.

The [showcase's front page](https://ensolabs.github.io/designsystemet-elm/)
has the full tested setup.

### Your own theme

`designsystemet tokens build --experimental-tailwind` (from
[`@digdir/designsystemet`](https://www.npmjs.com/package/@digdir/designsystemet))
writes a `<theme>.tailwind.css` next to each `<theme>.css`; import that
instead. With a `designsystemet.config.json`, a `css` output writes it by
default (`"experimental_tailwind": true`). Upstream marks this experimental.

### Pinning the CSS

With or without Tailwind, your app installs `@digdir/designsystemet-css`
itself. Pin it exactly, never a range. The npm package lists it as a peer
dependency, so npm refuses a mismatch (ERESOLVE) and Bun warns. Upgrade both
in one `npm install -E`, with the CSS at this package's version minus any
`-N`.

## Differences from React

The markup is the same. The API is Elm's:

- **Accessible names are required by type.** React's "`label`, `aria-label`
  or `aria-labelledby`, exactly one" is a `Ds.Label` argument. Icon-only
  buttons take `{ label = … }`.
- **No default texts.** React defaults to Norwegian strings like "Lukk
  dialogvindu" and "%d tegn igjen". Here every user-facing text is a required
  argument, so the package works in any language.
- **Values are your own types.** Tabs, ToggleGroup, Select, Suggestion,
  Pagination and Table sorting take custom types, not strings. A tab carries
  its own panel, so the two can't drift apart.
- **Typed ids.** A `Dialog.Id` can't be given to a popover, and an
  `ErrorSummary.FieldId` ties a summary link to its field.
- **Structure is never a flag.** `Button.view`, `Button.loading` and
  `Button.icon` are separate functions. A `Badge` is `Dot`, `Count` or
  `Capped`, never a `count` and `maxCount` that can disagree.
- **`asChild` is `viewAs`**, which takes the element function:
  `Button.viewAs Html.a [ Attr.href "/" ] [ … ]`.
- **Dialogs and popovers open from a button or from the model.** From a
  button, with typed invoker attributes (`Dialog.showModal id`,
  `Popover.toggle id`) and no state. From the model, with
  `Dialog.open model.isOpen`, like React's `open` prop. No ports.
- **Deprecated React APIs are not ported**, including `Combobox` (replaced by
  `Suggestion`).

Every module's docs start with a React → Elm list.

## Showcase

The [showcase](https://ensolabs.github.io/designsystemet-elm/) mirrors the
official [Storybook](https://storybook.designsystemet.no) story for story,
built with the components themselves. Each story shows its Elm source and
links to the React version.

```sh
bun install
bun run showcase         # http://localhost:5174
bun run showcase:build   # static site in showcase/dist
```

## Versions

The port version follows React: `1.23.0` mirrors React `1.23.0`. Fixes to this
package's own code, with `-css` and `-web` unchanged, add a dash: `1.23.0-1`.
The npm package uses the same version, so it lines up with
`@digdir/designsystemet-css` and `-web`. Pin it exactly: npm treats `1.23.0-1`
as a prerelease, which a range like `^1.23.0` skips.

The Elm registry only accepts plain semver and derives it from the API, so the
Elm package has its own version, named in each changelog section. The
experimental modules (`AvatarStack`, `FileUpload` and `Suggestion`) follow
upstream, so a breaking change in them is a major Elm version too. See
[CHANGELOG.md](https://github.com/ensolabs/designsystemet-elm/blob/HEAD/CHANGELOG.md),
and [UPGRADING.md](https://github.com/ensolabs/designsystemet-elm/blob/HEAD/UPGRADING.md)
for how upstream releases are ported.

## Contributing

See [CONTRIBUTING.md](https://github.com/ensolabs/designsystemet-elm/blob/HEAD/CONTRIBUTING.md).
`bun run check` runs what CI runs.

## License

MIT. Designsystemet itself is © Digitaliseringsdirektoratet (Digdir), MIT.
This is a community port, not affiliated with or endorsed by Digdir. The
showcase's icons are from [`@navikt/aksel-icons`](https://www.npmjs.com/package/@navikt/aksel-icons)
(© Nav, MIT).
