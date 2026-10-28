module Designsystemet.Internal.Attributes exposing (data, none, whenJust)

{-| Small attribute helpers shared by the components. Not exposed.
-}

import Html
import Html.Attributes as Attr
import Json.Encode as Encode


{-| A `data-*` attribute: `data "variant" "secondary"` is `data-variant="secondary"`.
-}
data : String -> String -> Html.Attribute msg
data name =
    Attr.attribute ("data-" ++ name)


{-| An attribute that does nothing, for conditionally rendered attributes.
Unlike `Attr.classList []` it never touches `class` (which matters on SVG).
-}
none : Html.Attribute msg
none =
    Attr.property "__ds_none" Encode.null


whenJust : Maybe a -> (a -> Html.Attribute msg) -> Html.Attribute msg
whenJust maybe toAttribute =
    case maybe of
        Just a ->
            toAttribute a

        Nothing ->
            none
