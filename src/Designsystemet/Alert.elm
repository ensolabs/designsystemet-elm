module Designsystemet.Alert exposing (view)

{-| A message to the user: information, a warning, an error or a success.

Mirrors `Alert` from `@digdir/designsystemet-react`.

    import Designsystemet.Alert as Alert
    import Designsystemet.Color exposing (Severity(..))
    import Designsystemet.Heading as Heading
    import Designsystemet.Paragraph as Paragraph

    Alert.view Warning
        []
        [ Heading.h2 [ Heading.size Heading.ExtraSmall ] [ Html.text "Fristen nærmer seg" ]
        , Paragraph.view [] [ Html.text "Søknaden må sendes innen fredag." ]
        ]

The CSS adds an icon for the severity, aligned with the heading if the alert
starts with one.

Screen readers don't announce an alert by default. If it appears in response
to a user action, add `Attr.attribute "role" "alert"` (for
errors) or `Attr.attribute "role" "status"`, and render the container before
its content changes.


# React → Elm

  - `<Alert>` (defaults to info) → `Alert.view Info []`
  - `data-color="danger"` → `Alert.view Danger []`

The CSS only styles the four severities, so the color is a required
[`Severity`](Designsystemet-Color#Severity) rather than any
[`Color`](Designsystemet-Color#Color).

@docs view

-}

import Designsystemet.Color as Color exposing (Severity)
import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr


{-| A `<div class="ds-alert">` in a severity color.

The severity overrides any `data-color` in the attributes.

-}
view : Severity -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
view severity attributes =
    Html.div
        (Attr.class "ds-alert"
            :: attributes
            ++ [ Internal.data "color" (Color.toString (Color.fromSeverity severity)) ]
        )
