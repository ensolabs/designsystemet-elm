module Designsystemet.ListTest exposing (suite)

import Designsystemet.List as DsList
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.List"
        [ test "unordered is ul.ds-list with plain li items" <|
            \() ->
                DsList.unordered [] [ DsList.item [] [ Html.text "En" ], DsList.item [] [ Html.text "To" ] ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "ul", Selector.class "ds-list" ]
                        , Query.findAll [ Selector.tag "li" ] >> Query.count (Expect.equal 2)
                        ]
        , test "ordered is ol.ds-list and keeps start" <|
            \() ->
                DsList.ordered [ Attr.start 3 ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "ol", Selector.class "ds-list", Selector.attribute (Attr.start 3) ]
        , test "item has no class of its own" <|
            \() ->
                DsList.item [] []
                    |> Query.fromHtml
                    |> Query.hasNot [ Selector.class "ds-list" ]
        ]
