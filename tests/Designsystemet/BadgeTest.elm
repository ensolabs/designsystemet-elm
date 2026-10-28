module Designsystemet.BadgeTest exposing (suite)

import Designsystemet.Badge as Badge exposing (Content(..), Corner(..), Overlap(..))
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


{-| `( count, maxCount, data-count )`, computed by evaluating the `data-count`
expression from `@digdir/designsystemet-react` 1.23.0's `badge.js` with node.
-}
reactFixture : List ( Int, Int, String )
reactFixture =
    [ ( 0, 0, "0" )
    , ( 0, 1, "0" )
    , ( 0, 9, "0" )
    , ( 0, 10, "0" )
    , ( 0, 99, "0" )
    , ( 0, -1, "0" )
    , ( 1, 0, "1" )
    , ( 1, 1, "1" )
    , ( 1, 9, "1" )
    , ( 1, 10, "1" )
    , ( 1, 99, "1" )
    , ( 1, -1, "-1+" )
    , ( 5, 0, "5" )
    , ( 5, 1, "1+" )
    , ( 5, 9, "5" )
    , ( 5, 10, "5" )
    , ( 5, 99, "5" )
    , ( 5, -1, "-1+" )
    , ( 9, 0, "9" )
    , ( 9, 1, "1+" )
    , ( 9, 9, "9" )
    , ( 9, 10, "9" )
    , ( 9, 99, "9" )
    , ( 9, -1, "-1+" )
    , ( 10, 0, "10" )
    , ( 10, 1, "1+" )
    , ( 10, 9, "9+" )
    , ( 10, 10, "10" )
    , ( 10, 99, "10" )
    , ( 10, -1, "-1+" )
    , ( 11, 0, "11" )
    , ( 11, 1, "1+" )
    , ( 11, 9, "9+" )
    , ( 11, 10, "10+" )
    , ( 11, 99, "11" )
    , ( 11, -1, "-1+" )
    , ( 99, 0, "99" )
    , ( 99, 1, "1+" )
    , ( 99, 9, "9+" )
    , ( 99, 10, "10+" )
    , ( 99, 99, "99" )
    , ( 99, -1, "-1+" )
    , ( 100, 0, "100" )
    , ( 100, 1, "1+" )
    , ( 100, 9, "9+" )
    , ( 100, 10, "10+" )
    , ( 100, 99, "99+" )
    , ( 100, -1, "-1+" )
    , ( 150, 0, "150" )
    , ( 150, 1, "1+" )
    , ( 150, 9, "9+" )
    , ( 150, 10, "10+" )
    , ( 150, 99, "99+" )
    , ( 150, -1, "-1+" )
    , ( -3, 0, "-3" )
    , ( -3, 1, "-3" )
    , ( -3, 9, "-3" )
    , ( -3, 10, "-3" )
    , ( -3, 99, "-3" )
    , ( -3, -1, "-3" )
    ]


suite : Test
suite =
    describe "Designsystemet.Badge"
        [ describe "toLabel"
            [ test "a dot has no label" <|
                \() -> Badge.toLabel Dot |> Expect.equal Nothing
            , test "a count is its number" <|
                \() -> Badge.toLabel (Count 5) |> Expect.equal (Just "5")
            , test "a count of zero is still shown, as in React" <|
                \() -> Badge.toLabel (Count 0) |> Expect.equal (Just "0")
            , test "a capped count over its max shows max+" <|
                \() -> Badge.toLabel (Capped { count = 10, max = 9 }) |> Expect.equal (Just "9+")
            , test "a capped count at its max is shown as is" <|
                \() -> Badge.toLabel (Capped { count = 9, max = 9 }) |> Expect.equal (Just "9")
            , describe "Capped matches React's count/maxCount for every fixture"
                (List.map
                    (\( count, max, expected ) ->
                        test (String.fromInt count ++ " / " ++ String.fromInt max) <|
                            \() ->
                                Badge.toLabel (Capped { count = count, max = max })
                                    |> Expect.equal (Just expected)
                    )
                    reactFixture
                )
            ]
        , describe "view"
            [ test "a dot is span.ds-badge with no data-count and no children" <|
                \() ->
                    Badge.view Dot []
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.has [ Selector.tag "span", Selector.class "ds-badge" ]
                            , Query.hasNot [ Selector.attribute (Attr.attribute "data-count" "") ]
                            , Query.children [] >> Query.count (Expect.equal 0)
                            ]
            , test "a capped count writes the capped label to data-count" <|
                \() ->
                    Badge.view (Capped { count = 120, max = 99 }) []
                        |> Query.fromHtml
                        |> Query.has [ attr "data-count" "99+" ]
            , test "variants are data-variant" <|
                \() ->
                    Html.div [] [ Badge.view Dot [ Badge.tinted ], Badge.view Dot [ Badge.base ] ]
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.findAll [ attr "data-variant" "tinted" ] >> Query.count (Expect.equal 1)
                            , Query.findAll [ attr "data-variant" "base" ] >> Query.count (Expect.equal 1)
                            ]
            ]
        , describe "position"
            [ test "always renders both placement and overlap" <|
                \() ->
                    Badge.position { placement = TopRight, overlap = Rectangle } [] [ Badge.view Dot [], Html.text "Innboks" ]
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.has
                                [ Selector.tag "span"
                                , Selector.class "ds-badge--position"
                                , attr "data-placement" "top-right"
                                , attr "data-overlap" "rectangle"
                                , Selector.text "Innboks"
                                ]
                            , Query.find [ Selector.class "ds-badge" ] >> Query.has [ Selector.tag "span" ]
                            ]
            , describe "placements"
                (List.map
                    (\( placement, value ) ->
                        test value <|
                            \() ->
                                Badge.position { placement = placement, overlap = Circle } [] []
                                    |> Query.fromHtml
                                    |> Query.has [ attr "data-placement" value, attr "data-overlap" "circle" ]
                    )
                    [ ( TopRight, "top-right" ), ( TopLeft, "top-left" ), ( BottomRight, "bottom-right" ), ( BottomLeft, "bottom-left" ) ]
                )
            ]
        ]
