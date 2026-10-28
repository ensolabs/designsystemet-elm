module Designsystemet.Card exposing
    ( view, viewAs
    , tinted
    , block, blockAs
    , clickable, clickableAs, LinkId, linkId, linkIdToString, mainLink
    )

{-| Cards group content about one thing.

Mirrors `Card` and `Card.Block` from `@digdir/designsystemet-react`.

    Card.view []
        [ Heading.h3 [] [ Html.text "Byggesak 2024/118" ]
        , Paragraph.view [] [ Html.text "Tilbygg, Storgata 4" ]
        ]

Split a card into sections with [`block`](#block). Blocks are separated by
lines, and a block holding only an image or video goes edge to edge:

    Card.view []
        [ Card.block [] [ Html.img [ Attr.src "/bilder/storgata-4.jpg", Attr.alt "" ] [] ]
        , Card.block [] [ Heading.h3 [] [ Html.text "Storgata 4" ] ]
        ]


# React → Elm

  - `<Card>` → `Card.view []`
  - `variant="tinted"` → `Card.tinted`
  - `<Card.Block>` → `Card.block []`
  - `asChild` + `<a href>` → `Card.viewAs Html.a [ Attr.href "…" ]`
  - `<Card.Block asChild>` → `Card.blockAs Html.section []`
  - a `<Heading><a>` inside (auto-detected) → `Card.clickable id []` + `Card.mainLink id` on the link


# Managed by designsystemet-web

In a [`clickable`](#clickable) card, `@digdir/designsystemet-web` forwards
clicks to the main link and adds a `:click-delegate-hover` class to the link
while the pointer is over the card. Keep the main link's `class` stable
between renders, or the hover style flickers.

@docs view, viewAs


# Variants

@docs tinted


# Blocks

@docs block, blockAs


# Clickable cards

@docs clickable, clickableAs, LinkId, linkId, linkIdToString, mainLink

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr



-- CARD


{-| A `<div class="ds-card">`.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view =
    viewAs Html.div


{-| A card rendered as another element than `<div>` (React's `asChild`). Use
it for a semantic container (`Html.article`, `Html.li`), or to make the whole
card one link or button:

    Card.viewAs Html.a
        [ Attr.href "/saker/118" ]
        [ Heading.h3 [] [ Html.text "Byggesak 2024/118" ] ]

A card that is one `<a>` can't contain other links or buttons. Use
[`clickable`](#clickable) for that.

-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewAs element attributes =
    element (Attr.class "ds-card" :: attributes)


{-| A tinted background instead of the default surface.
-}
tinted : Html.Attribute msg
tinted =
    Internal.data "variant" "tinted"



-- BLOCKS


{-| A `<div class="ds-card__block">`: a section of a card, with a line between
it and the next.
-}
block : List (Html.Attribute msg) -> List (Html msg) -> Html msg
block =
    blockAs Html.div


{-| A block rendered as another element (`Card.Block`'s `asChild`).

    Card.blockAs Html.footer [] [ Html.text "Sist endret 3. mars" ]

-}
blockAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
blockAs element attributes =
    element (Attr.class "ds-card__block" :: attributes)



-- CLICKABLE CARDS


{-| The `id` of the link a [`clickable`](#clickable) card sends its clicks to.
A separate type, so it only fits [`mainLink`](#mainLink).
-}
type LinkId
    = LinkId String


{-| Make a `LinkId` from an id that is unique on the page.

    caseLink : Case -> Card.LinkId
    caseLink case_ =
        Card.linkId ("sak-" ++ Case.idToString case_.id)

-}
linkId : String -> LinkId
linkId =
    LinkId


{-| The id as a string, for `Browser.Dom.focus` and the like.
-}
linkIdToString : LinkId -> String
linkIdToString (LinkId id) =
    id


{-| Sets the `id` of the card's main link.
-}
mainLink : LinkId -> Html.Attribute msg
mainLink (LinkId id) =
    Attr.id id


{-| A card where a click anywhere opens its main link. Other links and buttons
inside still work.

The link stays a single `<a>`, so screen readers and keyboard users get one
link with a short name instead of the card's whole text. Put it in the
heading: the CSS underlines the heading and gives the card a hover state.

    viewCase : Case -> Html Msg
    viewCase case_ =
        let
            link =
                caseLink case_
        in
        Card.clickable link
            []
            [ Heading.h3 []
                [ Html.a [ Card.mainLink link, Attr.href (Route.toString (Route.Case case_.id)) ]
                    [ Html.text case_.title ]
                ]
            , Paragraph.view [] [ Html.text case_.address ]
            , Button.view [ Button.tertiary, Events.onClick (Archive case_.id) ] [ Html.text "Arkiver" ]
            ]

React finds the first link in a heading after rendering. Elm doesn't read the
DOM, so you name the link, and the shared `LinkId` keeps card and link in
sync.

`@digdir/designsystemet-web` forwards the clicks (`data-clickdelegatefor`).
Ctrl-, Cmd- and middle-clicks open a new tab, as on the link itself.

-}
clickable : LinkId -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
clickable =
    clickableAs Html.div


{-| A clickable card as another element, such as a list item or an article:

    Html.ul []
        (List.map
            (\case_ ->
                Card.clickableAs Html.li (caseLink case_) [] [{- … -}]
            )
            cases
        )

-}
clickableAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> LinkId
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
clickableAs element (LinkId id) attributes =
    viewAs element (Internal.data "clickdelegatefor" id :: attributes)
