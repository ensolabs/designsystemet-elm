module Designsystemet.SelectTest exposing (suite)

import Designsystemet.Select as Select
import Expect
import Html
import Html.Attributes as Attr
import Json.Encode as Encode
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


type Fruit
    = Apple
    | Pear


fruits : Maybe Fruit -> { options : List Fruit, selected : Maybe Fruit, toValue : Fruit -> String, toLabel : Fruit -> String, onSelect : Fruit -> Fruit, placeholder : String }
fruits selected =
    { options = [ Apple, Pear ]
    , selected = selected
    , toValue =
        \fruit ->
            case fruit of
                Apple ->
                    "apple"

                Pear ->
                    "pear"
    , toLabel =
        \fruit ->
            case fruit of
                Apple ->
                    "Eple"

                Pear ->
                    "Pære"
    , onSelect = identity
    , placeholder = "Velg frukt"
    }


change : String -> ( String, Encode.Value )
change value =
    Event.custom "change" (Encode.object [ ( "target", Encode.object [ ( "value", Encode.string value ) ] ) ])


suite : Test
suite =
    describe "Designsystemet.Select"
        [ test "view renders a select with the input class" <|
            \() ->
                Select.view [ Select.autoWidth ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "select", Selector.class "ds-input", Selector.attribute (Attr.attribute "data-width" "auto") ]
        , test "fullWidth" <|
            \() ->
                Select.view [ Select.fullWidth ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.attribute "data-width" "full") ]
        , test "optgroup carries its label" <|
            \() ->
                Select.optgroup { label = "Bygg A" } [] [ Select.option [ Attr.value "a" ] [ Html.text "A" ] ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "optgroup", Selector.attribute (Attr.attribute "label" "Bygg A"), Selector.text "A" ]
        , test "single with nothing selected shows a disabled, selected prompt first" <|
            \() ->
                Select.single (fruits Nothing) []
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "option" ]
                    |> Expect.all
                        [ Query.count (Expect.equal 3)
                        , Query.first
                            >> Query.has
                                [ Selector.attribute (Attr.value "")
                                , Selector.attribute (Attr.disabled True)
                                , Selector.attribute (Attr.selected True)
                                , Selector.text "Velg frukt"
                                ]
                        ]
        , test "single with a selection drops the prompt and marks the option" <|
            \() ->
                Select.single (fruits (Just Pear)) []
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "option" ]
                    |> Expect.all
                        [ Query.count (Expect.equal 2)
                        , Query.index 1 >> Query.has [ Selector.attribute (Attr.value "pear"), Selector.attribute (Attr.selected True), Selector.text "Pære" ]
                        , Query.index 0 >> Query.has [ Selector.attribute (Attr.selected False) ]
                        ]
        , test "single decodes the chosen value back to your type" <|
            \() ->
                Select.single (fruits Nothing) []
                    |> Query.fromHtml
                    |> Event.simulate (change "pear")
                    |> Event.expect Pear
        , test "single with a selection that isn't among the options shows the prompt" <|
            \() ->
                let
                    pearSelected : { options : List Fruit, selected : Maybe Fruit, toValue : Fruit -> String, toLabel : Fruit -> String, onSelect : Fruit -> Fruit, placeholder : String }
                    pearSelected =
                        fruits (Just Pear)
                in
                Select.single { pearSelected | options = [ Apple ] } []
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "option" ]
                    |> Expect.all
                        [ Query.count (Expect.equal 2)
                        , Query.first >> Query.has [ Selector.attribute (Attr.value ""), Selector.attribute (Attr.selected True) ]
                        , Query.index 1 >> Query.has [ Selector.attribute (Attr.selected False) ]
                        ]
        , test "single is still a ds-input select, attributes included" <|
            \() ->
                Select.single (fruits Nothing) [ Attr.required True ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "select", Selector.class "ds-input", Selector.attribute (Attr.required True) ]
        , test "an unknown value produces no message" <|
            \() ->
                Select.single (fruits Nothing) []
                    |> Query.fromHtml
                    |> Event.simulate (change "banana")
                    |> Event.toResult
                    |> Expect.err
        ]
