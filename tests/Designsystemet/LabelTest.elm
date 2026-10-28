module Designsystemet.LabelTest exposing (suite)

import Designsystemet.Label as Label
import Expect
import Html
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.Label"
        [ test "renders a ds-label" <|
            \() ->
                Label.view [] [ Html.text "Navn" ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "label", Selector.class "ds-label", Selector.text "Navn" ]
        , test "viewAs keeps the class on another element" <|
            \() ->
                Label.viewAs Html.legend [] [ Html.text "Adresse" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "legend", Selector.class "ds-label" ]
                        , Query.hasNot [ Selector.tag "label" ]
                        ]
        ]
