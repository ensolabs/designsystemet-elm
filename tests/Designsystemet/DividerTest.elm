module Designsystemet.DividerTest exposing (suite)

import Designsystemet.Divider as Divider
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


suite : Test
suite =
    describe "Designsystemet.Divider"
        [ test "renders a decorative hr.ds-divider" <|
            \() ->
                Divider.view []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "hr", Selector.class "ds-divider", attr "aria-hidden" "true" ]
        ]
