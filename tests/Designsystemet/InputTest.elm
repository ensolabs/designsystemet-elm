module Designsystemet.InputTest exposing (suite)

import Designsystemet.Input as Input
import Html.Attributes as Attr
import Html.Events as Events
import Json.Encode as Encode
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.Input"
        [ test "renders a text ds-input" <|
            \() ->
                Input.view []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "input", Selector.class "ds-input", Selector.attribute (Attr.type_ "text") ]
        , test "the type can be changed" <|
            \() ->
                Input.view [ Attr.type_ "email" ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.type_ "email") ]
        , test "indeterminate is the DOM property, not a data attribute" <|
            \() ->
                Input.view [ Attr.type_ "checkbox", Input.indeterminate ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.property "indeterminate" (Encode.bool True)) ]
        , test "events pass through" <|
            \() ->
                Input.view [ Events.onInput identity ]
                    |> Query.fromHtml
                    |> Event.simulate (Event.input "hei")
                    |> Event.expect "hei"
        ]
