module Designsystemet.List exposing (unordered, ordered, item)

{-| Bulleted and numbered lists with Designsystemet's spacing.

Mirrors `List` from `@digdir/designsystemet-react`.

Import it under another name so it doesn't shadow `List` from `elm/core`:

    import Designsystemet.List as DsList

    DsList.ordered []
        [ DsList.item [] [ Html.text "Fyll ut skjemaet" ]
        , DsList.item [] [ Html.text "Last opp vedlegg" ]
        , DsList.item [] [ Html.text "Send inn" ]
        ]


# React → Elm

  - `<List.Unordered>` → `DsList.unordered []`
  - `<List.Ordered>` → `DsList.ordered []`
  - `<List.Item>` → `DsList.item []`

`asChild` is not ported. The styling is just the `ds-list` class, so
`Html.menu [ Attr.class "ds-list" ]` does the same, and `List.Item` adds no
markup.

@docs unordered, ordered, item

-}

import Html exposing (Html)
import Html.Attributes as Attr


{-| A `<ul class="ds-list">`, for items in no particular order.
-}
unordered : List (Html.Attribute msg) -> List (Html msg) -> Html msg
unordered attributes =
    Html.ul (Attr.class "ds-list" :: attributes)


{-| An `<ol class="ds-list">`, for steps or rankings where the order matters.
`Attr.start` and `Attr.reversed` work as usual.
-}
ordered : List (Html.Attribute msg) -> List (Html msg) -> Html msg
ordered attributes =
    Html.ol (Attr.class "ds-list" :: attributes)


{-| An `<li>`. Nest a list inside it for sub-items; the CSS tightens nested
spacing.
-}
item : List (Html.Attribute msg) -> List (Html msg) -> Html msg
item =
    Html.li
