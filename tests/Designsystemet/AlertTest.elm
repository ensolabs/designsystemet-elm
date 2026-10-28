module Designsystemet.AlertTest exposing (suite)

import Designsystemet as Ds
import Designsystemet.Alert as Alert
import Designsystemet.Color as Color exposing (Severity(..))
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
    describe "Designsystemet.Alert"
        [ describe "renders div.ds-alert with the severity as data-color"
            (List.map
                (\( severity, value ) ->
                    test value <|
                        \() ->
                            Alert.view severity [] [ Html.text "Melding" ]
                                |> Query.fromHtml
                                |> Query.has
                                    [ Selector.tag "div"
                                    , Selector.class "ds-alert"
                                    , attr "data-color" value
                                    , Selector.text "Melding"
                                    ]
                )
                [ ( Info, "info" ), ( Success, "success" ), ( Warning, "warning" ), ( Danger, "danger" ) ]
            )
        , test "the severity wins over a data-color in the attributes" <|
            \() ->
                Alert.view Danger [ Ds.color Color.accent ] []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ attr "data-color" "danger" ]
                        , Query.hasNot [ attr "data-color" "accent" ]
                        ]
        , test "other attributes pass through" <|
            \() ->
                Alert.view Info [ Attr.attribute "role" "status" ] []
                    |> Query.fromHtml
                    |> Query.has [ attr "role" "status" ]
        ]
