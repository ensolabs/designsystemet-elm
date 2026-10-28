module Designsystemet.Tag exposing (view, viewAs, outline)

{-| A label for a category or status.

Mirrors `Tag` from `@digdir/designsystemet-react`.

    Tag.view [ Ds.color Color.success ] [ Html.text "Godkjent" ]

A tag is not interactive. For something the user can click to filter or
remove, use a `Chip`.


# React → Elm

  - `<Tag>` → `Tag.view []`
  - `variant="outline"` → `Tag.outline`
  - `data-color="success"` → `Ds.color Color.success`
  - `asChild` + `<a>` → `Tag.viewAs Html.a [ Attr.href "…" ]`

@docs view, viewAs, outline

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr


{-| A `<span class="ds-tag">`.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view =
    viewAs Html.span


{-| Tag styling on another element (React's `asChild`).

    Tag.viewAs Html.a [ Attr.href "/saker?status=apen" ] [ Html.text "Åpen" ]

-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewAs element attributes =
    element (Attr.class "ds-tag" :: attributes)


{-| Border and no fill, for tags that should draw less attention.
-}
outline : Html.Attribute msg
outline =
    Internal.data "variant" "outline"
