module Designsystemet.Switch exposing
    ( Switch, new, view
    , withDescription, withFieldAttributes
    )

{-| An on/off switch for a setting that takes effect right away.

Mirrors `Switch` from `@digdir/designsystemet-react`.

    Switch.new (Ds.label "Mørk modus")
        |> Switch.view [ Attr.checked model.darkMode, Events.onCheck ToggledDarkMode ]

It's an `<input type="checkbox" role="switch">`, so `Events.onCheck` and
`Attr.checked` work as for a checkbox. Use a [`Checkbox`](Designsystemet-Checkbox)
when the choice only counts once a form is submitted.

The attributes you give `view` go on the `<input>`, like React's rest props.
Attributes for the field around it go in
[`withFieldAttributes`](#withFieldAttributes).


# React → Elm

  - `<Switch label="…" />` → `Switch.new (Ds.label "…") |> Switch.view []`
  - `aria-label="…"` → `Switch.new (Ds.ariaLabel "…")`
  - `description={…}` → `Switch.withDescription [ … ]`
  - `variant="outline"` → `Switch.withFieldAttributes [ Field.outline ]`
  - `position="end"` → `Switch.withFieldAttributes [ Field.position Field.End ]`
  - `data-size`, `className`, `style` → `Switch.withFieldAttributes [ … ]`
  - `checked`, `onChange`, … → `Switch.view [ Attr.checked …, Events.onCheck … ]`

As in React, a switch has no error message, since a setting that applies
immediately can't be wrong.

@docs Switch, new, view


# Options

@docs withDescription, withFieldAttributes

-}

import Designsystemet exposing (Label)
import Designsystemet.Internal.Form as Form
import Html exposing (Html)
import Html.Attributes as Attr


{-| A switch being configured. Start with [`new`](#new), end with
[`view`](#view).
-}
type Switch msg
    = Switch (Form.Toggle msg)


{-| A switch with this accessible name. With
[`Ds.label`](Designsystemet#label) the label is shown next to it.
-}
new : Label msg -> Switch msg
new label =
    Switch (Form.toggle label)


{-| Help text under the label.
-}
withDescription : List (Html msg) -> Switch msg -> Switch msg
withDescription description (Switch config) =
    Switch { config | description = Just description }


{-| Attributes for the `<ds-field>` around the switch: `Field.outline`,
`Field.position`, `Ds.size`, a class, …
-}
withFieldAttributes : List (Html.Attribute msg) -> Switch msg -> Switch msg
withFieldAttributes attributes (Switch config) =
    Switch { config | fieldAttributes = config.fieldAttributes ++ attributes }


{-| Render the switch. The attributes go on the `<input>`.
-}
view : List (Html.Attribute msg) -> Switch msg -> Html msg
view attributes (Switch config) =
    Form.viewToggle
        [ Attr.type_ "checkbox", Attr.attribute "role" "switch" ]
        config
        attributes
