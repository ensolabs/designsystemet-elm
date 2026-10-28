module Designsystemet.FieldTest exposing (suite)

import Designsystemet.Field as Field
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.Field"
        [ test "renders the ds-field custom element" <|
            \() ->
                Field.view [] [ Html.text "x" ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "ds-field", Selector.class "ds-field", Selector.text "x" ]
        , test "position and outline are data attributes on the field" <|
            \() ->
                Field.view [ Field.position Field.End, Field.outline ] []
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.attribute (Attr.attribute "data-position" "end")
                        , Selector.attribute (Attr.attribute "data-variant" "outline")
                        ]
        , test "start position" <|
            \() ->
                Field.view [ Field.position Field.Start ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.attribute "data-position" "start") ]
        , test "description is a div marked for ds-field" <|
            \() ->
                Field.description [] [ Html.text "Hjelp" ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "div"
                        , Selector.attribute (Attr.attribute "data-field" "description")
                        , Selector.text "Hjelp"
                        ]
        , test "affixes wrap, and an affix is hidden from screen readers" <|
            \() ->
                Field.affixes [] [ Field.affix [] [ Html.text "NOK" ] ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "div", Selector.class "ds-field-affixes" ]
                        , Query.find [ Selector.class "ds-field-affix" ]
                            >> Query.has
                                [ Selector.tag "span"
                                , Selector.attribute (Attr.attribute "aria-hidden" "true")
                                , Selector.text "NOK"
                                ]
                        ]
        , test "counter carries the limit and both texts, and is empty for the web layer to fill" <|
            \() ->
                Field.counter { limit = 140, under = "%d igjen", over = "%d for mye" } []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has
                            [ Selector.tag "p"
                            , Selector.class "ds-validation-message"
                            , Selector.attribute (Attr.attribute "data-field" "counter")
                            , Selector.attribute (Attr.attribute "data-limit" "140")
                            , Selector.attribute (Attr.attribute "data-under" "%d igjen")
                            , Selector.attribute (Attr.attribute "data-over" "%d for mye")
                            ]
                        , Query.hasNot [ Selector.attribute (Attr.attribute "data-field" "validation") ]
                        , Query.children [] >> Query.count (Expect.equal 0)
                        ]
        ]
