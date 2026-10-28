module Designsystemet.ToggleGroupTest exposing (suite)

import Designsystemet.ToggleGroup as ToggleGroup
import Expect
import Html exposing (Html)
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


type Layout
    = List
    | Grid


layoutToString : Layout -> String
layoutToString layout =
    case layout of
        List ->
            "list"

        Grid ->
            "grid"


group : Html Layout
group =
    ToggleGroup.controlled
        { name = "layout"
        , label = "Visning"
        , toValue = layoutToString
        , selected = List
        , onSelect = identity
        }
        [ ToggleGroup.secondary ]
        [ ToggleGroup.item List [ Html.text "Liste" ]
        , ToggleGroup.iconItem { value = Grid, label = "Rutenett", icon = Html.text "#" }
        ]


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


input : String -> Query.Single Layout
input value =
    group
        |> Query.fromHtml
        |> Query.find [ Selector.tag "input", Selector.attribute (Attr.value value) ]


suite : Test
suite =
    describe "Designsystemet.ToggleGroup"
        [ test "a labelled radiogroup fieldset" <|
            \() ->
                group
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "fieldset"
                        , Selector.class "ds-toggle-group"
                        , attr "aria-label" "Visning"
                        , attr "focusgroup" "radiogroup"
                        , attr "data-variant" "secondary"
                        ]
        , test "role is left to the focusgroup polyfill" <|
            \() ->
                group
                    |> Query.fromHtml
                    |> Query.hasNot [ attr "role" "radiogroup" ]
        , test "items are tertiary ds-button labels around a named radio" <|
            \() ->
                group
                    |> Query.fromHtml
                    |> Query.children [ Selector.tag "label" ]
                    |> Expect.all
                        [ Query.count (Expect.equal 2)
                        , Query.each (Query.has [ Selector.class "ds-button", attr "data-variant" "tertiary" ])
                        , Query.each
                            (Query.find [ Selector.tag "input" ]
                                >> Query.has [ Selector.attribute (Attr.type_ "radio"), Selector.attribute (Attr.name "layout") ]
                            )
                        ]
        , test "the selected item is checked, the others are not" <|
            \() ->
                Expect.all
                    [ \_ -> input "list" |> Query.has [ Selector.attribute (Attr.checked True) ]
                    , \_ -> input "grid" |> Query.has [ Selector.attribute (Attr.checked False) ]
                    ]
                    ()
        , test "clicking another item sends its value and cancels the native check" <|
            \() ->
                Expect.all
                    [ \_ -> input "grid" |> Event.simulate Event.click |> Event.expect Grid
                    , \_ -> input "grid" |> Event.simulate Event.click |> Event.expectPreventDefault
                    ]
                    ()
        , test "clicking the selected item sends nothing" <|
            \() ->
                input "list"
                    |> Event.simulate Event.click
                    |> Event.toResult
                    |> Expect.err
        , test "text items show their content" <|
            \() ->
                group
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "label", Selector.containing [ Selector.text "Liste" ] ]
                    |> Query.hasNot [ attr "data-icon" "true" ]
        , test "a disabled item is aria-disabled, its radio disabled, and it sends nothing" <|
            \() ->
                ToggleGroup.controlled
                    { name = "layout", label = "Visning", toValue = layoutToString, selected = List, onSelect = identity }
                    []
                    [ ToggleGroup.item List [ Html.text "Liste" ]
                    , ToggleGroup.item Grid [ Html.text "Rutenett" ] |> ToggleGroup.disabled
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "label", Selector.containing [ Selector.text "Rutenett" ] ]
                    |> Expect.all
                        [ Query.has [ attr "aria-disabled" "true" ]
                        , Query.find [ Selector.tag "input" ] >> Query.has [ Selector.attribute (Attr.disabled True) ]
                        , Query.find [ Selector.tag "input" ] >> Event.simulate Event.click >> Event.toResult >> Expect.err
                        ]
        , test "enabled items are not aria-disabled" <|
            \() ->
                group
                    |> Query.fromHtml
                    |> Query.findAll [ attr "aria-disabled" "true" ]
                    |> Query.count (Expect.equal 0)
        , test "icon items are named and have a tooltip, and are as wide as React's" <|
            \() ->
                group
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "label", Selector.containing [ Selector.text "#" ] ]
                    |> Expect.all
                        [ Query.has [ attr "data-tooltip" "Rutenett" ]
                        , Query.hasNot [ attr "data-icon" "true" ]
                        , Query.find [ Selector.tag "input" ] >> Query.has [ attr "aria-label" "Rutenett" ]
                        ]
        , test "uncontrolled: the initial item is checked (as a property, so changing initial resets it), and clicks are the browser's" <|
            \() ->
                ToggleGroup.uncontrolled { name = "layout", label = "Visning", toValue = layoutToString, initial = Grid }
                    []
                    [ ToggleGroup.item List [ Html.text "Liste" ], ToggleGroup.item Grid [ Html.text "Rutenett" ] ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.find [ Selector.tag "input", Selector.attribute (Attr.value "grid") ] >> Query.has [ Selector.attribute (Attr.checked True) ]
                        , Query.find [ Selector.tag "input", Selector.attribute (Attr.value "list") ] >> Query.has [ Selector.attribute (Attr.checked False) ]
                        , Query.find [ Selector.tag "input", Selector.attribute (Attr.value "list") ] >> Event.simulate Event.click >> Event.toResult >> Expect.err
                        ]
        , test "a read-only item is readonly and sends nothing" <|
            \() ->
                ToggleGroup.controlled { name = "layout", label = "Visning", toValue = layoutToString, selected = List, onSelect = identity }
                    []
                    [ ToggleGroup.item List [ Html.text "Liste" ], ToggleGroup.item Grid [ Html.text "Rutenett" ] |> ToggleGroup.readOnly ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input", Selector.attribute (Attr.value "grid") ]
                    |> Expect.all
                        [ Query.has [ attr "readonly" "" ]
                        , Event.simulate Event.click >> Event.toResult >> Expect.err
                        ]
        , test "a focusable disabled item is aria-disabled, not disabled, and a controlled click changes nothing" <|
            \() ->
                ToggleGroup.controlled { name = "layout", label = "Visning", toValue = layoutToString, selected = List, onSelect = identity }
                    []
                    [ ToggleGroup.item List [ Html.text "Liste" ], ToggleGroup.item Grid [ Html.text "Rutenett" ] |> ToggleGroup.disabledFocusable ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.find [ Selector.tag "label", Selector.containing [ Selector.text "Rutenett" ] ] >> Query.has [ attr "aria-disabled" "true" ]
                        , Query.find [ Selector.tag "input", Selector.attribute (Attr.value "grid") ]
                            >> Expect.all
                                [ Query.has [ attr "aria-disabled" "true" ]
                                , Query.hasNot [ Selector.attribute (Attr.disabled True) ]
                                , Event.simulate Event.click >> Event.expect List
                                , Event.simulate Event.click >> Event.expectPreventDefault
                                ]
                        ]
        ]
