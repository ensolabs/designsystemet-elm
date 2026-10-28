module Designsystemet.SearchTest exposing (suite)

import Designsystemet.Search as Search
import Expect
import Html.Attributes as Attr
import Html.Events as Events
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.Search"
        [ test "ds-suggestion.ds-search with the clear label for the web layer" <|
            \() ->
                Search.new { clearLabel = "Tøm" }
                    |> Search.view []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "ds-suggestion", Selector.class "ds-search", Selector.attribute (Attr.attribute "data-sr-clear" "Tøm") ]
                        , Query.children [] >> Query.count (Expect.equal 2)
                        , Query.children [] >> Query.index 0 >> Query.has [ Selector.tag "input", Selector.class "ds-input", Selector.attribute (Attr.type_ "search") ]
                        , Query.children []
                            >> Query.index 1
                            >> Query.has [ Selector.tag "button", Selector.attribute (Attr.type_ "reset"), Selector.attribute (Attr.hidden True) ]
                        ]
        , test "the clear button gets no aria-label from Elm" <|
            \() ->
                Search.new { clearLabel = "Tøm" }
                    |> Search.view []
                    |> Query.fromHtml
                    |> Query.find [ Selector.attribute (Attr.type_ "reset") ]
                    |> Query.hasNot [ Selector.attribute (Attr.attribute "aria-label" "Tøm") ]
        , test "a primary search button submits" <|
            \() ->
                Search.new { clearLabel = "Tøm" }
                    |> Search.withButton { variant = Search.Primary, label = "Søk" }
                    |> Search.view []
                    |> Query.fromHtml
                    |> Query.children []
                    |> Query.index 2
                    |> Expect.all
                        [ Query.has [ Selector.class "ds-button", Selector.attribute (Attr.type_ "submit"), Selector.text "Søk" ]
                        , Query.hasNot [ Selector.attribute (Attr.attribute "data-variant" "secondary") ]
                        ]
        , test "a secondary search button" <|
            \() ->
                Search.new { clearLabel = "Tøm" }
                    |> Search.withButton { variant = Search.Secondary, label = "Søk" }
                    |> Search.view []
                    |> Query.fromHtml
                    |> Query.find [ Selector.class "ds-button" ]
                    |> Query.has [ Selector.attribute (Attr.attribute "data-variant" "secondary") ]
        , test "attributes and events go on the input" <|
            \() ->
                Search.new { clearLabel = "Tøm" }
                    |> Search.view [ Attr.attribute "aria-label" "Søk i saker", Events.onInput identity ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Expect.all
                        [ Query.has [ Selector.attribute (Attr.attribute "aria-label" "Søk i saker") ]
                        , Event.simulate (Event.input "brann") >> Event.expect "brann"
                        ]
        , test "type text drops the magnifying glass" <|
            \() ->
                Search.new { clearLabel = "Tøm" }
                    |> Search.view [ Attr.type_ "text" ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Query.has [ Selector.attribute (Attr.type_ "text") ]
        ]
