module Designsystemet.SwitchTest exposing (suite)

import Designsystemet as Ds
import Designsystemet.Field as Field
import Designsystemet.Switch as Switch
import Expect
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.Switch"
        ([ test "ds-field > input first, then a regular-weight label" <|
            \() ->
                Switch.new (Ds.label "Ja")
                    |> Switch.view []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "ds-field", Selector.class "ds-field" ]
                        , Query.children [] >> Query.count (Expect.equal 2)
                        , Query.children []
                            >> Query.index 0
                            >> Query.has [ Selector.tag "input", Selector.class "ds-input", Selector.attribute (Attr.type_ "checkbox") ]
                        , Query.children []
                            >> Query.index 1
                            >> Query.has
                                [ Selector.tag "label"
                                , Selector.class "ds-label"
                                , Selector.attribute (Attr.attribute "data-weight" "regular")
                                , Selector.text "Ja"
                                ]
                        ]
         , test "an aria-label names the input and no label is rendered" <|
            \() ->
                Switch.new (Ds.ariaLabel "Velg rad")
                    |> Switch.view []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.hasNot [ Selector.tag "label" ]
                        , Query.find [ Selector.tag "input" ] >> Query.has [ Selector.attribute (Attr.attribute "aria-label" "Velg rad") ]
                        ]
         , test "description follows the label" <|
            \() ->
                Switch.new (Ds.label "Ja")
                    |> Switch.withDescription [ Html.text "Mer info" ]
                    |> Switch.view []
                    |> Query.fromHtml
                    |> Query.children []
                    |> Query.index 2
                    |> Query.has [ Selector.tag "div", Selector.attribute (Attr.attribute "data-field" "description"), Selector.text "Mer info" ]
         , test "field attributes land on ds-field" <|
            \() ->
                Switch.new (Ds.label "Ja")
                    |> Switch.withFieldAttributes [ Field.outline, Field.position Field.End ]
                    |> Switch.view []
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "ds-field"
                        , Selector.attribute (Attr.attribute "data-variant" "outline")
                        , Selector.attribute (Attr.attribute "data-position" "end")
                        ]
         , test "checking sends a message" <|
            \() ->
                Switch.new (Ds.label "Ja")
                    |> Switch.view [ Events.onCheck identity ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Event.simulate (Event.check True)
                    |> Event.expect True
         ]
            ++ extra
        )


extra : List Test
extra =
    [ test "it is a checkbox with the switch role" <|
        \() ->
            Switch.new (Ds.label "Mørk modus")
                |> Switch.view []
                |> Query.fromHtml
                |> Query.find [ Selector.tag "input" ]
                |> Query.has [ Selector.attribute (Attr.attribute "role" "switch") ]
    ]
