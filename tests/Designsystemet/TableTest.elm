module Designsystemet.TableTest exposing (suite)

import Designsystemet.Table as Table exposing (Direction(..), Sort(..))
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


type Column
    = Number
    | Address


type Msg
    = SortChanged (Sort Column)


header : Sort Column -> Html.Html Msg
header sort =
    Table.view []
        [ Table.head []
            [ Table.row []
                [ Table.sortableHeaderCell { sort = sort, column = Number, onSort = SortChanged } [ Attr.id "number" ] [ Html.text "Nummer" ]
                , Table.sortableHeaderCell { sort = sort, column = Address, onSort = SortChanged } [ Attr.id "address" ] [ Html.text "Adresse" ]
                , Table.headerCell [ Attr.id "plain" ] [ Html.text "Status" ]
                ]
            ]
        ]


suite : Test
suite =
    describe "Designsystemet.Table"
        [ test "renders table.ds-table with the parts as plain elements" <|
            \() ->
                Table.view []
                    [ Table.head [] [ Table.row [] [ Table.headerCell [] [ Html.text "H" ] ] ]
                    , Table.body [] [ Table.row [] [ Table.cell [] [ Html.text "C" ] ] ]
                    , Table.foot [] [ Table.row [] [ Table.cell [] [ Html.text "F" ] ] ]
                    ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "table", Selector.class "ds-table" ]
                        , Query.find [ Selector.tag "thead" ] >> Query.find [ Selector.tag "th" ] >> Query.has [ Selector.text "H" ]
                        , Query.find [ Selector.tag "tbody" ] >> Query.find [ Selector.tag "td" ] >> Query.has [ Selector.text "C" ]
                        , Query.find [ Selector.tag "tfoot" ] >> Query.find [ Selector.tag "td" ] >> Query.has [ Selector.text "F" ]
                        , Query.findAll [ Selector.tag "tr" ] >> Query.count (Expect.equal 3)
                        ]
        , test "options are data attributes set to true, like React" <|
            \() ->
                Table.view [ Table.zebra, Table.stickyHeader, Table.border, Table.hover ] []
                    |> Query.fromHtml
                    |> Query.has
                        [ attr "data-zebra" "true"
                        , attr "data-sticky-header" "true"
                        , attr "data-border" "true"
                        , attr "data-hover" "true"
                        ]
        , test "keyedBody renders a tbody with the rows" <|
            \() ->
                Table.keyedBody [] [ ( "a", Table.row [] [] ), ( "b", Table.row [] [] ) ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "tbody" ]
                        , Query.findAll [ Selector.tag "tr" ] >> Query.count (Expect.equal 2)
                        ]
        , describe "sorting"
            [ test "unsorted: every sortable header says none and has a button" <|
                \() ->
                    header Unsorted
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.findAll [ attr "aria-sort" "none" ] >> Query.count (Expect.equal 2)
                            , Query.findAll [ Selector.tag "button", Selector.attribute (Attr.type_ "button") ] >> Query.count (Expect.equal 2)
                            ]
            , test "only the sorted column has a direction" <|
                \() ->
                    header (SortedBy Address Descending)
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.find [ Selector.id "address" ] >> Query.has [ attr "aria-sort" "descending" ]
                            , Query.find [ Selector.id "number" ] >> Query.has [ attr "aria-sort" "none" ]
                            , Query.findAll [ attr "aria-sort" "descending" ] >> Query.count (Expect.equal 1)
                            ]
            , test "a plain header cell has no aria-sort and no button" <|
                \() ->
                    header (SortedBy Number Ascending)
                        |> Query.fromHtml
                        |> Query.find [ Selector.id "plain" ]
                        |> Expect.all
                            [ Query.hasNot [ attr "aria-sort" "none" ]
                            , Query.findAll [ Selector.tag "button" ] >> Query.count (Expect.equal 0)
                            ]
            , test "the header's children go inside the button" <|
                \() ->
                    header Unsorted
                        |> Query.fromHtml
                        |> Query.find [ Selector.id "number" ]
                        |> Query.find [ Selector.tag "button" ]
                        |> Query.has [ Selector.text "Nummer" ]
            , test "clicking a new column asks for it ascending" <|
                \() ->
                    header (SortedBy Number Descending)
                        |> Query.fromHtml
                        |> Query.find [ Selector.id "address" ]
                        |> Query.find [ Selector.tag "button" ]
                        |> Event.simulate Event.click
                        |> Event.expect (SortChanged (SortedBy Address Ascending))
            , test "clicking the sorted column flips it" <|
                \() ->
                    header (SortedBy Number Ascending)
                        |> Query.fromHtml
                        |> Query.find [ Selector.id "number" ]
                        |> Query.find [ Selector.tag "button" ]
                        |> Event.simulate Event.click
                        |> Event.expect (SortChanged (SortedBy Number Descending))
            , describe "nextSort"
                [ test "unsorted starts ascending" <|
                    \() -> Table.nextSort Address Unsorted |> Expect.equal (SortedBy Address Ascending)
                , test "another column starts ascending" <|
                    \() -> Table.nextSort Address (SortedBy Number Descending) |> Expect.equal (SortedBy Address Ascending)
                , test "ascending becomes descending" <|
                    \() -> Table.nextSort Address (SortedBy Address Ascending) |> Expect.equal (SortedBy Address Descending)
                , test "descending becomes ascending" <|
                    \() -> Table.nextSort Address (SortedBy Address Descending) |> Expect.equal (SortedBy Address Ascending)
                ]
            ]
        ]
