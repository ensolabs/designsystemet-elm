module Designsystemet.ValidationMessageTest exposing (suite)

import Designsystemet.Color as Color
import Designsystemet.ValidationMessage as ValidationMessage
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.ValidationMessage"
        [ test "renders a p that ds-field recognises as validation" <|
            \() ->
                ValidationMessage.view [] [ Html.text "Feil" ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "p"
                        , Selector.class "ds-validation-message"
                        , Selector.attribute (Attr.attribute "data-field" "validation")
                        , Selector.text "Feil"
                        ]
        , test "danger is the default, so no data-color is set" <|
            \() ->
                ValidationMessage.view [] []
                    |> Query.fromHtml
                    |> Query.hasNot [ Selector.attribute (Attr.attribute "data-color" "danger") ]
        , test "severity sets data-color" <|
            \() ->
                ValidationMessage.view [ ValidationMessage.severity Color.Success ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.attribute "data-color" "success") ]
        , test "viewAs renders another element" <|
            \() ->
                ValidationMessage.viewAs Html.div [] []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "div", Selector.class "ds-validation-message" ]
                        , Query.hasNot [ Selector.tag "p" ]
                        ]
        ]
