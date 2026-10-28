module Designsystemet exposing
    ( version
    , size, color
    , ColorScheme(..), colorScheme
    , Label, label, labelHtml, ariaLabel, labelledBy
    )

{-| Designsystemet for Elm: the components of
[`@digdir/designsystemet-react`](https://www.npmjs.com/package/@digdir/designsystemet-react),
as plain Elm view functions.

The markup matches the React components. Styling comes from
`@digdir/designsystemet-css` plus your theme. Behaviour (tabs, popovers, dialog
invokers, field wiring, tooltips) comes from `@digdir/designsystemet-web`,
loaded by the npm package `@ensolabs/designsystemet-elm`. Import both once in
your JavaScript entry point:

    import "@digdir/designsystemet-css";
    import "@digdir/designsystemet-css/theme"; // or your own generated theme
    import "@ensolabs/designsystemet-elm";

Most modules are imported qualified by their short name:

    import Designsystemet as Ds
    import Designsystemet.Button as Button
    import Designsystemet.Color as Color

    Button.view [ Ds.color Color.danger, Events.onClick Delete ] [ Html.text "Slett" ]


# Port version

@docs version


# Size and color

`data-size` and `data-color` apply to the element and every Designsystemet
component inside it, so you can set them on a single component or on a `div`
around a whole form.

@docs size, color


# Color scheme

@docs ColorScheme, colorScheme


# Accessible names

@docs Label, label, labelHtml, ariaLabel, labelledBy

-}

import Designsystemet.Color as Color exposing (Color)
import Designsystemet.Internal.Label as Internal
import Designsystemet.Size as Size exposing (Size)
import Html exposing (Html)
import Html.Attributes as Attr



-- VERSION


{-| The version of this port, `"1.23.0"`.

This is the `@digdir/designsystemet-react` version it mirrors, and the
`-css` and `-web` versions it expects at runtime. Fixes to the port alone add
a suffix: `"1.23.0-1"`, `"1.23.0-2"`.

The npm package `@ensolabs/designsystemet-elm` shares this version. The Elm
package has its own, since the registry only accepts plain semver.

-}
version : String
version =
    "1.23.0"



-- SIZE AND COLOR


{-| Set `data-size` on an element.

    Html.form [ Ds.size Size.sm ] [{- every field in here is small -}]

-}
size : Size -> Html.Attribute msg
size =
    Attr.attribute "data-size" << Size.toString


{-| Set `data-color` on an element.

    Html.section [ Ds.color Color.neutral ] [{- buttons, tags, ... -}]

-}
color : Color -> Html.Attribute msg
color =
    Attr.attribute "data-color" << Color.toString



-- COLOR SCHEME


{-| Light, dark, or whatever the user's system prefers.
-}
type ColorScheme
    = Light
    | Dark
    | Auto


{-| Set `data-color-scheme` on an element, typically the root of your app.
-}
colorScheme : ColorScheme -> Html.Attribute msg
colorScheme scheme =
    Attr.attribute "data-color-scheme" <|
        case scheme of
            Light ->
                "light"

            Dark ->
                "dark"

            Auto ->
                "auto"



-- ACCESSIBLE NAMES


{-| How a form control gets its accessible name.

React accepts exactly one of `label`, `aria-label` and `aria-labelledby`.
Here a control with no name, or two, does not compile.

Opaque (the docs show the internal module it lives in). Build one with [`label`](#label), [`labelHtml`](#labelHtml), [`ariaLabel`](#ariaLabel)
or [`labelledBy`](#labelledBy).

-}
type alias Label msg =
    Internal.Label msg


{-| A visible text label.
-}
label : String -> Label msg
label text =
    Internal.Visible [ Html.text text ]


{-| A visible label with markup in it.
-}
labelHtml : List (Html msg) -> Label msg
labelHtml =
    Internal.Visible


{-| An invisible label, read by screen readers only.
-}
ariaLabel : String -> Label msg
ariaLabel =
    Internal.AriaLabel


{-| The `id` of another element on the page that names the control.

A plain `String` rather than a typed id like `Dialog.Id`, because the target
is usually not rendered by this package.

-}
labelledBy : String -> Label msg
labelledBy =
    Internal.LabelledBy
