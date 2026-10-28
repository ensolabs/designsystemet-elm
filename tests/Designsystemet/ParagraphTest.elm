module Designsystemet.ParagraphTest exposing (suite)

import Designsystemet.Paragraph as Paragraph
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
    describe "Designsystemet.Paragraph"
        [ test "renders a p.ds-paragraph without a variant by default" <|
            \() ->
                Paragraph.view [] [ Html.text "Tekst" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "p", Selector.class "ds-paragraph", Selector.text "Tekst" ]
                        , Query.hasNot [ attr "data-variant" "long" ]
                        , Query.hasNot [ attr "data-variant" "short" ]
                        ]
        , test "long and short are data-variant" <|
            \() ->
                Html.div [] [ Paragraph.view [ Paragraph.long ] [], Paragraph.view [ Paragraph.short ] [] ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.findAll [ attr "data-variant" "long" ] >> Query.count (Expect.equal 1)
                        , Query.findAll [ attr "data-variant" "short" ] >> Query.count (Expect.equal 1)
                        ]
        , describe "sizes map to the paragraph scale"
            (List.map
                (\( size, value ) ->
                    test value <|
                        \() ->
                            Paragraph.view [ Paragraph.size size ] []
                                |> Query.fromHtml
                                |> Query.has [ attr "data-size" value ]
                )
                [ ( Paragraph.ExtraSmall, "xs" )
                , ( Paragraph.Small, "sm" )
                , ( Paragraph.Medium, "md" )
                , ( Paragraph.Large, "lg" )
                , ( Paragraph.ExtraLarge, "xl" )
                ]
            )
        , test "viewAs keeps the class on another element" <|
            \() ->
                Paragraph.viewAs Html.div [] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "div", Selector.class "ds-paragraph" ]
        ]
