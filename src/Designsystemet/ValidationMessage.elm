module Designsystemet.ValidationMessage exposing (view, viewAs, severity)

{-| A message about what the user typed: usually an error, sometimes a warning
or a confirmation.

Mirrors `ValidationMessage` from `@digdir/designsystemet-react`.

    ValidationMessage.view [] [ Html.text "Skriv inn et gyldig fødselsnummer" ]

    ValidationMessage.view [ ValidationMessage.severity Color.Success ]
        [ Html.text "Brukernavnet er ledig" ]

A message is an error unless you give it another severity.

Inside a [`Field`](Designsystemet-Field), `<ds-field>` links the message to the
input with `aria-describedby`, and an error also makes the input
`aria-invalid="true"`. Messages of other severities are linked but don't make
the input invalid. As a direct child of a
[`Fieldset`](Designsystemet-Fieldset), the message is linked to every field in
the group.

The composites ([`Textfield`](Designsystemet-Textfield),
[`Checkbox`](Designsystemet-Checkbox), …) render this from `withError`.


# React → Elm

  - `<ValidationMessage>` → `ValidationMessage.view []`
  - `data-color="warning"` → `ValidationMessage.severity Color.Warning`
  - `asChild` + `<div>` → `ValidationMessage.viewAs Html.div []`

@docs view, viewAs, severity

-}

import Designsystemet.Color as Color
import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr


{-| A `<p class="ds-validation-message" data-field="validation">`.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view =
    viewAs Html.p


{-| The message on another element (React's `asChild`).
-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewAs element attributes =
    element
        (Attr.class "ds-validation-message"
            :: Internal.data "field" "validation"
            :: attributes
        )


{-| How serious the message is. Defaults to `Danger`. The CSS has an icon and a
color for each of the four.
-}
severity : Color.Severity -> Html.Attribute msg
severity =
    Internal.data "color" << Color.toString << Color.fromSeverity
