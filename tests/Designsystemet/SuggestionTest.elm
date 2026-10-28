module Designsystemet.SuggestionTest exposing (suite)

import Designsystemet.Suggestion as Suggestion exposing (Suggestion)
import Expect
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Encode as Encode
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


type Msg
    = Selected (Maybe String)
    | Changed (List String)
    | Created String
    | Typed String


cities : List String
cities =
    [ "oslo", "bergen", "tromso" ]


label : String -> String
label city =
    case city of
        "oslo" ->
            "Oslo"

        "bergen" ->
            "Bergen"

        _ ->
            "Tromsø"


one : Maybe String -> Suggestion String Msg
one current =
    Suggestion.single { options = cities, selected = current, toValue = identity, toLabel = label, onSelect = Selected }


many : List String -> Suggestion String Msg
many current =
    Suggestion.multiple { options = cities, selected = current, toValue = identity, toLabel = label, onChange = Changed }


{-| What u-combobox dispatches: the `<data>` element about to be added
(not connected) or removed (connected).
-}
beforeSelect : String -> Bool -> ( String, Encode.Value )
beforeSelect value isConnected =
    Event.custom "comboboxbeforeselect"
        (Encode.object
            [ ( "detail"
              , Encode.object
                    [ ( "value", Encode.string value )
                    , ( "isConnected", Encode.bool isConnected )
                    ]
              )
            ]
        )


select : String -> Bool -> Suggestion String Msg -> Result String Msg
select value isConnected suggestion =
    Suggestion.view [] suggestion
        |> Query.fromHtml
        |> Event.simulate (beforeSelect value isConnected)
        |> Event.toResult


suite : Test
suite =
    describe "Designsystemet.Suggestion"
        [ describe "markup"
            [ test "ds-suggestion: data items, input, list" <|
                \() ->
                    Suggestion.view [] (one (Just "bergen"))
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.has [ Selector.tag "ds-suggestion", Selector.class "ds-suggestion" ]
                            , Query.hasNot [ Selector.attribute (Attr.attribute "data-multiple" "") ]
                            , Query.children [] >> Query.count (Expect.equal 3)
                            , Query.children []
                                >> Query.index 0
                                >> Query.has [ Selector.tag "data", Selector.attribute (Attr.attribute "value" "bergen"), Selector.text "Bergen" ]
                            , Query.children []
                                >> Query.index 1
                                >> Query.has [ Selector.tag "input", Selector.class "ds-input", Selector.attribute (Attr.placeholder "") ]
                            , Query.children []
                                >> Query.index 2
                                >> Query.has
                                    [ Selector.tag "u-datalist"
                                    , Selector.attribute (Attr.attribute "popover" "manual")
                                    , Selector.attribute (Attr.attribute "role" "listbox")
                                    ]
                            ]
            , test "options are u-options with value and label, and never selected by Elm" <|
                \() ->
                    Suggestion.view [] (one (Just "bergen"))
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "u-option" ]
                        |> Expect.all
                            [ Query.count (Expect.equal 3)
                            , Query.index 1 >> Query.has [ Selector.attribute (Attr.attribute "value" "bergen"), Selector.text "Bergen" ]
                            , Query.each (Query.hasNot [ Selector.attribute (Attr.attribute "selected" "") ])
                            ]
            , test "multiple sets data-multiple and renders a chip per selected value" <|
                \() ->
                    Suggestion.view [] (many [ "oslo", "tromso" ])
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.has [ Selector.attribute (Attr.attribute "data-multiple" "") ]
                            , Query.findAll [ Selector.tag "data" ] >> Query.count (Expect.equal 2)
                            ]
            , test "filtering is left to u-datalist unless turned off" <|
                \() ->
                    Expect.all
                        [ \_ ->
                            Suggestion.view [] (one Nothing)
                                |> Query.fromHtml
                                |> Query.find [ Selector.tag "u-datalist" ]
                                |> Query.hasNot [ Selector.attribute (Attr.attribute "data-nofilter" "") ]
                        , \_ ->
                            Suggestion.view [] (one Nothing |> Suggestion.withoutFiltering)
                                |> Query.fromHtml
                                |> Query.find [ Selector.tag "u-datalist" ]
                                |> Query.has [ Selector.attribute (Attr.attribute "data-nofilter" "") ]
                        ]
                        ()
            , test "toggle, clear, empty message and name, in React's order" <|
                \() ->
                    one Nothing
                        |> Suggestion.withToggle { label = "Vis alle" }
                        |> Suggestion.withClear { label = "Tøm" }
                        |> Suggestion.withEmptyMessage [ Html.text "Ingen treff" ]
                        |> Suggestion.withName "city"
                        |> Suggestion.view []
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.has [ Selector.attribute (Attr.attribute "data-sr-clear" "Tøm") ]
                            , Query.children [] >> Query.count (Expect.equal 5)
                            , Query.children []
                                >> Query.index 1
                                >> Query.has
                                    [ Selector.tag "button"
                                    , Selector.attribute (Attr.attribute "aria-expanded" "false")
                                    , Selector.attribute (Attr.attribute "aria-label" "Vis alle")
                                    , Selector.attribute (Attr.type_ "button")
                                    ]
                            , Query.children []
                                >> Query.index 2
                                >> Query.has [ Selector.tag "button", Selector.attribute (Attr.type_ "reset"), Selector.attribute (Attr.hidden True) ]
                            , Query.children []
                                >> Query.index 4
                                >> Query.has [ Selector.tag "select", Selector.attribute (Attr.name "city"), Selector.attribute (Attr.hidden True) ]
                            , Query.find [ Selector.attribute (Attr.attribute "data-empty" "") ]
                                >> Query.has [ Selector.tag "u-option", Selector.text "Ingen treff" ]
                            ]
            , test "the hidden select's multiple is left to the web layer, which sets it from data-multiple" <|
                \() ->
                    Expect.all
                        [ \_ ->
                            Suggestion.view [] (many [] |> Suggestion.withName "c")
                                |> Query.fromHtml
                                |> Query.find [ Selector.tag "select" ]
                                |> Query.hasNot [ Selector.attribute (Attr.multiple True) ]
                        , \_ ->
                            Suggestion.view [] (one Nothing |> Suggestion.withName "c")
                                |> Query.fromHtml
                                |> Query.find [ Selector.tag "select" ]
                                |> Query.hasNot [ Selector.attribute (Attr.multiple True) ]
                        ]
                        ()
            , test "creatable: data-creatable, and an empty option holding the template, with no text" <|
                \() ->
                    one Nothing
                        |> Suggestion.withEmptyMessage [ Html.text "Ingen treff" ]
                        |> Suggestion.withCreatable { template = "Legg til %s", onCreate = Created }
                        |> Suggestion.view []
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.has [ Selector.attribute (Attr.attribute "data-creatable" "") ]
                            , Query.find [ Selector.attribute (Attr.attribute "data-empty" "Legg til %s") ]
                                >> Query.children []
                                >> Query.count (Expect.equal 0)
                            , Query.hasNot [ Selector.text "Ingen treff" ]
                            ]
            , test "option content keeps the label as an attribute" <|
                \() ->
                    one Nothing
                        |> Suggestion.withOptionContent (\city -> [ Html.text (label city), Html.div [] [ Html.text "Kommune" ] ])
                        |> Suggestion.view []
                        |> Query.fromHtml
                        |> Query.find [ Selector.attribute (Attr.attribute "value" "bergen"), Selector.tag "u-option" ]
                        |> Query.has [ Selector.attribute (Attr.attribute "label" "Bergen"), Selector.text "Kommune" ]
            , test "attributes and events go on the input" <|
                \() ->
                    Suggestion.view [ Attr.attribute "aria-label" "By", Events.onInput Typed ] (one Nothing)
                        |> Query.fromHtml
                        |> Query.find [ Selector.tag "input" ]
                        |> Expect.all
                            [ Query.has [ Selector.attribute (Attr.attribute "aria-label" "By") ]
                            , Event.simulate (Event.input "Os") >> Event.expect (Typed "Os")
                            ]
            ]
        , describe "single"
            [ test "the select event is always cancelled, so the web layer never inserts items itself" <|
                \() ->
                    Suggestion.view [] (one Nothing)
                        |> Query.fromHtml
                        |> Event.simulate (beforeSelect "paris" False)
                        |> Event.expectPreventDefault
            , test "picking an option selects it" <|
                \() ->
                    select "oslo" False (one Nothing)
                        |> Expect.equal (Ok (Selected (Just "oslo")))
            , test "picking another option replaces it" <|
                \() ->
                    select "tromso" False (one (Just "oslo"))
                        |> Expect.equal (Ok (Selected (Just "tromso")))
            , test "removing the item clears the selection" <|
                \() ->
                    select "oslo" True (one (Just "oslo"))
                        |> Expect.equal (Ok (Selected Nothing))
            , test "an unknown value keeps the selection" <|
                \() ->
                    select "paris" False (one (Just "oslo"))
                        |> Expect.equal (Ok (Selected (Just "oslo")))
            , test "an unknown value creates when creatable" <|
                \() ->
                    select "Paris" False (one Nothing |> Suggestion.withCreatable { template = "Legg til %s", onCreate = Created })
                        |> Expect.equal (Ok (Created "Paris"))
            ]
        , describe "multiple"
            [ test "picking an option appends it" <|
                \() ->
                    select "bergen" False (many [ "oslo" ])
                        |> Expect.equal (Ok (Changed [ "oslo", "bergen" ]))
            , test "removing a chip removes only that value" <|
                \() ->
                    select "oslo" True (many [ "oslo", "bergen" ])
                        |> Expect.equal (Ok (Changed [ "bergen" ]))
            , test "an unknown value keeps the selection" <|
                \() ->
                    select "paris" False (many [ "oslo" ])
                        |> Expect.equal (Ok (Changed [ "oslo" ]))
            ]
        ]
