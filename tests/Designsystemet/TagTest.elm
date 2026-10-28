module Designsystemet.TagTest exposing (suite)

import Designsystemet as Ds
import Designsystemet.Color as Color
import Designsystemet.Tag as Tag
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
    describe "Designsystemet.Tag"
        [ test "renders span.ds-tag" <|
            \() ->
                Tag.view [ Ds.color Color.success ] [ Html.text "Godkjent" ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "span", Selector.class "ds-tag", attr "data-color" "success", Selector.text "Godkjent" ]
        , test "outline is data-variant" <|
            \() ->
                Tag.view [ Tag.outline ] []
                    |> Query.fromHtml
                    |> Query.has [ attr "data-variant" "outline" ]
        , test "viewAs renders another element" <|
            \() ->
                Tag.viewAs Html.a [ Attr.href "/" ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "a", Selector.class "ds-tag" ]
        ]
