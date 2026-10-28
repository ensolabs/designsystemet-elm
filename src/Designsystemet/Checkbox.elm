module Designsystemet.Checkbox exposing
    ( Checkbox, new, view
    , withDescription, withError, withFieldAttributes
    )

{-| A checkbox with its label, description and error message.

Mirrors `Checkbox` from `@digdir/designsystemet-react`.

    Checkbox.new (Ds.label "Jeg har lest vilkårene")
        |> Checkbox.withError model.termsError
        |> Checkbox.view [ Attr.checked model.acceptedTerms, Events.onCheck AcceptedTerms ]

The attributes you give `view` go on the `<input type="checkbox">`, like
React's rest props. Attributes for the field around it (size, outline, position)
go in [`withFieldAttributes`](#withFieldAttributes).

For a group of checkboxes, put them in a [`Fieldset`](Designsystemet-Fieldset)
with a legend.

For a "select all" checkbox, add
[`Input.indeterminate`](Designsystemet-Input#indeterminate) to the attributes.


# React → Elm

  - `<Checkbox label="…" />` → `Checkbox.new (Ds.label "…") |> Checkbox.view []`
  - `aria-label="…"` → `Checkbox.new (Ds.ariaLabel "…")`
  - `description={…}` → `Checkbox.withDescription [ … ]`
  - `error="…"` → `Checkbox.withError (Just "…")`
  - `variant="outline"` → `Checkbox.withFieldAttributes [ Field.outline ]`
  - `position="end"` → `Checkbox.withFieldAttributes [ Field.position Field.End ]`
  - `data-size`, `className`, `style` → `Checkbox.withFieldAttributes [ … ]`
  - `checked`, `value`, `onChange`, … → `Checkbox.view [ Attr.checked …, Events.onCheck … ]`
  - `data-indeterminate` → `Checkbox.view [ Input.indeterminate ]`

The wrapper is a [`Field`](Designsystemet-Field): `<ds-field>` connects the
label, description and error to the checkbox, so don't set `id`-based ARIA
yourself.

@docs Checkbox, new, view


# Options

@docs withDescription, withError, withFieldAttributes

-}

import Designsystemet exposing (Label)
import Designsystemet.Internal.Form as Form
import Html exposing (Html)
import Html.Attributes as Attr


{-| A checkbox being configured. Start with [`new`](#new), end with
[`view`](#view).
-}
type Checkbox msg
    = Checkbox (Form.Toggle msg)


{-| A checkbox with this accessible name. With
[`Ds.label`](Designsystemet#label) the label is shown next to the box.
-}
new : Label msg -> Checkbox msg
new label =
    Checkbox (Form.toggle label)


{-| Help text under the label.
-}
withDescription : List (Html msg) -> Checkbox msg -> Checkbox msg
withDescription description (Checkbox config) =
    Checkbox { config | description = Just description }


{-| An error message under the checkbox, or `Nothing` for none. Pass your
validation result in:

    |> Checkbox.withError (Dict.get "terms" model.errors)

The checkbox gets `aria-invalid="true"` while there is an error. With an
[`ErrorSummary`](Designsystemet-ErrorSummary), read the message from the same
list with [`ErrorSummary.messageFor`](Designsystemet-ErrorSummary#messageFor).

-}
withError : Maybe String -> Checkbox msg -> Checkbox msg
withError error (Checkbox config) =
    Checkbox { config | error = error }


{-| Attributes for the `<ds-field>` around the checkbox: `Field.outline`,
`Field.position`, `Ds.size`, a class, …
-}
withFieldAttributes : List (Html.Attribute msg) -> Checkbox msg -> Checkbox msg
withFieldAttributes attributes (Checkbox config) =
    Checkbox { config | fieldAttributes = config.fieldAttributes ++ attributes }


{-| The attributes go on the `<input>`.
-}
view : List (Html.Attribute msg) -> Checkbox msg -> Html msg
view attributes (Checkbox config) =
    Form.viewToggle [ Attr.type_ "checkbox" ] config attributes
