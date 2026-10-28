module Designsystemet.ChipTest exposing (suite)

import Designsystemet.Chip as Chip
import Expect
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


suite : Test
suite =
    describe "Designsystemet.Chip"
        [ test "button is a button.ds-chip that never submits" <|
            \() ->
                Chip.button [ Events.onClick "clicked" ] [ Html.text "Filter" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "button", Selector.class "ds-chip", attr "type" "button", Selector.text "Filter" ]
                        , Event.simulate Event.click >> Event.expect "clicked"
                        ]
        , test "removable is data-removable with the remove label as the CSS label" <|
            \() ->
                Chip.removable { removeLabel = "Trykk for å fjerne" } [] [ Html.text "Norsk" ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.class "ds-chip"
                        , attr "data-removable" "true"
                        , attr "style" "--dsc-chip-removable-label: \"Trykk for å fjerne\""
                        ]
        , test "the remove label is escaped as a CSS string" <|
            \() ->
                Chip.removable { removeLabel = "Si \"fjern\" \\ nå" } [] []
                    |> Query.fromHtml
                    |> Query.has [ attr "style" "--dsc-chip-removable-label: \"Si \\\"fjern\\\" \\\\ nå\"" ]
        , test "wrap is data-wrap" <|
            \() ->
                Chip.button [ Chip.wrap ] []
                    |> Query.fromHtml
                    |> Query.has [ attr "data-wrap" "wrap" ]
        , test "checkbox is a label.ds-chip with a ds-input checkbox first" <|
            \() ->
                Chip.checkbox { name = "status", value = "open", checked = True, onCheck = identity } [ Chip.wrap ] [ Html.text "Åpne" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "label", Selector.class "ds-chip", attr "data-wrap" "wrap", Selector.text "Åpne" ]
                        , Query.children [] >> Query.first >> Query.has [ Selector.tag "input", Selector.class "ds-input", Selector.attribute (Attr.type_ "checkbox"), Selector.attribute (Attr.checked True), Selector.attribute (Attr.name "status"), Selector.attribute (Attr.value "open") ]
                        ]
        , test "checkbox clicks ask for the other state and cancel the native check" <|
            \() ->
                Chip.checkbox { name = "status", value = "open", checked = True, onCheck = identity } [] []
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Expect.all
                        [ Event.simulate Event.click >> Event.expect False
                        , Event.simulate Event.click >> Event.expectPreventDefault
                        ]
        , test "radio is a named radio in a label.ds-chip" <|
            \() ->
                Chip.radio { name = "language", value = "nn", checked = False, onSelect = "nynorsk" } [] [ Html.text "Nynorsk" ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Expect.all
                        [ Query.has [ Selector.class "ds-input", Selector.attribute (Attr.type_ "radio"), Selector.attribute (Attr.name "language"), Selector.attribute (Attr.checked False), Selector.attribute (Attr.value "nn") ]
                        , Event.simulate Event.click >> Event.expect "nynorsk"
                        , Event.simulate Event.click >> Event.expectPreventDefault
                        ]
        , test "a checked radio sends nothing" <|
            \() ->
                Chip.radio { name = "language", value = "nn", checked = True, onSelect = "nynorsk" } [] []
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Event.simulate Event.click
                    |> Event.toResult
                    |> Expect.err
        , test "uncontrolled chips seed the checked attribute and send nothing" <|
            \() ->
                Chip.uncontrolledCheckbox { name = "status", value = "open", initiallyChecked = True } [] [ Html.text "Åpne" ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Expect.all
                        [ Query.has [ attr "checked" "", Selector.attribute (Attr.type_ "checkbox"), Selector.attribute (Attr.name "status"), Selector.attribute (Attr.value "open") ]
                        , Event.simulate Event.click >> Event.toResult >> Expect.err
                        ]
        , test "an uncontrolled radio that isn't initially checked has no checked attribute" <|
            \() ->
                Chip.uncontrolledRadio { name = "language", value = "nn", initiallyChecked = False } [] []
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Expect.all
                        [ Query.has [ Selector.attribute (Attr.type_ "radio"), Selector.attribute (Attr.name "language") ]
                        , Query.hasNot [ attr "checked" "" ]
                        ]
        ]
