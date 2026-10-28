module Designsystemet.TextareaTest exposing (suite)

import Designsystemet.Textarea as Textarea
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.Textarea"
        [ test "renders a textarea with the input class" <|
            \() ->
                Textarea.view [ Attr.rows 4 ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "textarea", Selector.class "ds-input", Selector.attribute (Attr.rows 4) ]
        ]
