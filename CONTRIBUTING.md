# Contributing

This package is a 1:1 port of `@digdir/designsystemet-react` (the version in
[`VERSION`](VERSION)). Every module follows the rules below.
`Designsystemet.Button` and `Designsystemet.Spinner` are the reference
implementations.

## Who does what

- **Elm renders.** Every component is a pure view function that emits the
  same markup as the React component: same element, `ds-*` class, `data-*`
  and ARIA attributes. The React `.js` shows the markup, the `.d.ts` the props.
- **`@digdir/designsystemet-css` styles.** We never ship CSS.
- **`@digdir/designsystemet-web` behaves.** Custom elements (`ds-tabs`,
  `ds-field`, `ds-suggestion`, …) and polyfills (invokers, popover placement,
  `focusgroup`, `data-tooltip`, `closedby`) do the DOM work. The Elm package
  ships no JS. The npm package `@ensolabs/designsystemet-elm` loads `-web`
  and `js/open-state.js`, which handles the one thing `-web` doesn't (below).

## One owner per attribute

Elm's virtual DOM diffs against its previous view, not the live DOM. If Elm
and the web layer both write an attribute, they overwrite each other. So:

- A module never renders an attribute the web layer manages. Exception: a
  constant seed value (the same on every render, like
  `aria-expanded="false"` on a Suggestion toggle) is allowed where React
  renders one too. Elm only patches values that changed, so a constant never
  overwrites what the web layer set later. Each module's docs list these
  under **"Managed by designsystemet-web"**.
- The web layer may only insert nodes into elements where Elm renders no
  children.
- Lists of items that can change use `Html.Keyed`.
- Controlled (Elm owns the state): cancel the native gesture at the target
  (`preventDefaultOn`) and render the state from the model. Uncontrolled: the
  browser or web layer owns it and Elm observes it through events. Offer both
  only where React does, as separate functions or constructors, never a flag.
- `<dialog>` and `[popover]` can only be opened imperatively. Their open state
  is still declarative in Elm: the module renders `data-open="true|false"`
  and `js/open-state.js` calls `showModal()`/`close()`/`showPopover()`/
  `hidePopover()` to match. No ports. Native invokers (`command`/
  `commandfor`, `popovertarget`) still open them from a button with no model
  state.

## API shape

1. **Simple components look like `Html`:**
   `view : List (Html.Attribute msg) -> List (Html msg) -> Html msg`.
   The attributes go on the element React spreads `...rest` onto.
2. **Props that are plain `data-*` attributes are exported
   `Html.Attribute`s**, named for what they mean: `Button.secondary`,
   `Tag.outline`, `Card.tinted`. No Bool arguments.
3. **Props that add, remove or route elements** (a spinner, a close button, a
   label, a counter), or are required, **are typed arguments**: a record if
   everything is required, a builder (`X.new required |> X.withY … |> X.view
   attributes children`) if anything is optional. Builders end in the same
   `view attributes children` shape.
4. **Variants that change structure are separate functions**, not flags:
   `Button.view` / `Button.loading` / `Button.icon`.
5. **`asChild` becomes `viewAs`**, which takes the element function:
   `Button.viewAs Html.a [ Attr.href "/" ] [ … ]`.
6. **`data-size` and `data-color` cascade**, so they're `Designsystemet.size`
   and `Designsystemet.color`, usable on any element. A component gets its own
   size type only when its scale differs (Spinner, Heading, Avatar, …).
7. **Severity-only components** (Alert, ValidationMessage) take
   `Color.Severity`, not `Color`.
8. **Accessible names are required by type.** Form controls take
   `Designsystemet.Label msg` (React's `LabelRequired`). Icon-only things take
   `{ label : String, … }`.
9. **No default UI text.** React defaults to Norwegian strings ("Lukk
   dialogvindu", "%d tegn igjen", "Du er her"). This package is app- and
   language-agnostic, so every such text is required, as a record field named
   for its purpose (`{ label = "Lukk" }`, `{ clearLabel = "Tøm" }`), never a
   bare `String` argument.
10. **Ids that link two elements are typed per module** (`Dialog.Id`,
    `Popover.Id`), so a dialog id can't be given to a popover.
11. **Values are the caller's own types.** Tabs, ToggleGroup, Suggestion,
    Pagination and similar take `a` plus `toString`/`toId`, not strings.
    Compare values with `==`; use `toString`/`toId` only to write a value
    into the DOM (an `id`, a `value`).
12. **Deprecated React props and components are not ported.** `Combobox`
    (deprecated in favour of `Suggestion`) is left out.

## Style

- `elm-format`, qualified imports (`Html.div`, `Attr.class`), no
  `exposing (..)` except for a module's own custom-type constructors.
- Every exposed value has a doc comment. Every module doc has a one-line
  summary, an example, a **React → Elm** list, and the `@docs` groups.
- package.elm-lang.org renders the docs without tables and escapes HTML: use
  lists, and write keys as plain text (Esc, Enter).
- Internal helpers go in `Designsystemet.Internal.*`, which is not exposed.
- `class` on SVG must be `Svg.Attributes.class`.
- `Attr.style` can't set CSS custom properties (`--dsc-…`): elm/virtual-dom
  assigns `element.style[name]`, which ignores them. Use
  `Attr.attribute "style" "--dsc-…: …"`, and remember an element gets only
  one `style` attribute.
- Name conversions `toString`/`fromString`. Prefer custom types to booleans.

## Checks

From this directory:

```sh
elm make --docs=docs.json   # compiles every exposed module in isolation: no app imports possible
elm-format --validate src tests
elm-test
```

`bun run smoke` (in CI) drives the built showcase in a real browser and checks
behaviour that depends on Elm and designsystemet-web together, e.g. a
controlled component whose `update` refuses a change must not change. Adding
a controlled mode or moving an attribute between owners needs a check there.

Every component also has its upstream stories in the showcase. After changing
one, run `bun run showcase:build && bun run parity <chapter>` and look at the
markup diff and the screenshots (see [UPGRADING.md](UPGRADING.md#5-check)).

Tests use `Test.Html` and compare the rendered markup with React's: classes,
`data-*`, ARIA, injected children, and that events produce messages.
