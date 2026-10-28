module Designsystemet.Label exposing (view, viewAs)

{-| The `<label>` of a form control.

Mirrors `Label` from `@digdir/designsystemet-react`.

[`Textfield`](Designsystemet-Textfield), [`Checkbox`](Designsystemet-Checkbox)
and friends render their own label from a
[`Designsystemet.Label`](Designsystemet#Label). Use this module when you build a
field by hand with [`Field`](Designsystemet-Field):

    Field.view []
        [ Label.view [] [ Html.text "Saksnummer" ]
        , Input.view [ Attr.value model.caseNumber, Events.onInput ChangedCaseNumber ]
        ]

Inside a `Field`, leave out `for`. `<ds-field>` connects the label to the
input.


# React → Elm

  - `<Label>` → `Label.view []`
  - `asChild` + `<legend>` → `Label.viewAs Html.legend []`
  - `weight` → not ported: deprecated in React

@docs view, viewAs

-}

import Html exposing (Html)
import Html.Attributes as Attr


{-| A `<label class="ds-label">`.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view =
    viewAs Html.label


{-| Label styling on another element (React's `asChild`).

    Label.viewAs Html.span [] [ Html.text "Velg dato" ]

-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewAs element attributes =
    element (Attr.class "ds-label" :: attributes)
