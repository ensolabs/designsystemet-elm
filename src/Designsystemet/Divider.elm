module Designsystemet.Divider exposing (view)

{-| A horizontal line between pieces of content.

Mirrors `Divider` from `@digdir/designsystemet-react`.

    Card.view []
        [ Card.block [] [ Html.text "Søker" ]
        , Divider.view []
        , Card.block [] [ Html.text "Vedlegg" ]
        ]


# React → Elm

  - `<Divider />` → `Divider.view []`

@docs view

-}

import Html exposing (Html)
import Html.Attributes as Attr


{-| An `<hr class="ds-divider" aria-hidden="true">`. Hidden from screen
readers as decoration. Use headings if the separation matters.
-}
view : List (Html.Attribute msg) -> Html msg
view attributes =
    Html.hr (Attr.attribute "aria-hidden" "true" :: Attr.class "ds-divider" :: attributes) []
