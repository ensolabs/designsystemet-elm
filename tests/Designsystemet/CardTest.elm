module Designsystemet.CardTest exposing (suite)

import Designsystemet.Card as Card
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


suite : Test
suite =
    describe "Designsystemet.Card"
        [ test "renders div.ds-card with its children" <|
            \() ->
                Card.view [] [ Html.text "Innhold" ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "div", Selector.class "ds-card", Selector.text "Innhold" ]
        , test "tinted is data-variant" <|
            \() ->
                Card.view [ Card.tinted ] []
                    |> Query.fromHtml
                    |> Query.has [ attr "data-variant" "tinted" ]
        , test "viewAs renders another element" <|
            \() ->
                Card.viewAs Html.a [ Attr.href "/saker/1" ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "a", Selector.class "ds-card", Selector.attribute (Attr.href "/saker/1") ]
        , test "block is div.ds-card__block" <|
            \() ->
                Card.view [] [ Card.block [] [ Html.text "Topp" ] ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.class "ds-card__block" ]
                    |> Query.has [ Selector.tag "div", Selector.text "Topp" ]
        , test "blockAs renders another element" <|
            \() ->
                Card.blockAs Html.footer [] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "footer", Selector.class "ds-card__block" ]
        , test "a plain card does not delegate clicks" <|
            \() ->
                Card.view [] []
                    |> Query.fromHtml
                    |> Query.hasNot [ attr "data-clickdelegatefor" "" ]
        , test "a clickable card delegates to the link marked with the same LinkId" <|
            \() ->
                let
                    link : Card.LinkId
                    link =
                        Card.linkId "sak-118"
                in
                Card.clickable link
                    []
                    [ Html.h3 [] [ Html.a [ Card.mainLink link, Attr.href "/saker/118" ] [ Html.text "Sak 118" ] ] ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.class "ds-card", attr "data-clickdelegatefor" "sak-118" ]
                        , Query.find [ Selector.tag "a" ] >> Query.has [ Selector.id "sak-118" ]
                        ]
        , test "clickableAs renders a clickable card on the given element" <|
            \() ->
                Card.clickableAs Html.li (Card.linkId "sak-7") [] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "li", Selector.class "ds-card", attr "data-clickdelegatefor" "sak-7" ]
        ]
