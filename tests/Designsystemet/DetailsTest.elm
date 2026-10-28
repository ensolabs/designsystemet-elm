module Designsystemet.DetailsTest exposing (suite)

import Designsystemet.Details as Details
import Expect
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as Encode
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


parts : { summary : List (Html msg), content : List (Html msg) }
parts =
    { summary = [ Html.text "Hvem kan søke?" ], content = [ Html.text "Alle." ] }


controlled : Bool -> Html Bool
controlled open =
    Details.controlled
        { open = open
        , onToggle = identity
        , summary = parts.summary
        , content = parts.content
        }
        []


toggle : String -> ( String, Encode.Value )
toggle newState =
    Event.custom "toggle" (Encode.object [ ( "newState", Encode.string newState ) ])


suite : Test
suite =
    describe "Designsystemet.Details"
        [ test "details.ds-details > summary + div" <|
            \() ->
                Details.view parts [ Details.tinted ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "details", Selector.class "ds-details", Selector.attribute (Attr.attribute "data-variant" "tinted") ]
                        , Query.children [] >> Query.count (Expect.equal 2)
                        , Query.children [] >> Query.first >> Query.has [ Selector.tag "summary", Selector.text "Hvem kan søke?" ]
                        , Query.children [] >> Query.index 1 >> Query.has [ Selector.tag "div", Selector.text "Alle." ]
                        ]
        , test "native details start closed and leave clicks alone" <|
            \() ->
                Details.view parts []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.hasNot [ Selector.attribute (Attr.attribute "open" "") ]
                        , Query.find [ Selector.tag "summary" ] >> Event.simulate Event.click >> Event.toResult >> Expect.err
                        ]
        , test "initiallyOpen renders the open attribute" <|
            \() ->
                Details.view parts [ Details.initiallyOpen ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.attribute "open" "") ]
        , test "controlled details reflect the model" <|
            \() ->
                Expect.all
                    [ \_ -> controlled True |> Query.fromHtml |> Query.has [ Selector.attribute (Attr.property "open" (Encode.bool True)) ]
                    , \_ -> controlled False |> Query.fromHtml |> Query.has [ Selector.attribute (Attr.property "open" (Encode.bool False)) ]
                    ]
                    ()
        , test "clicking the summary asks for the other state and cancels the native toggle" <|
            \() ->
                Expect.all
                    [ \_ -> controlled False |> Query.fromHtml |> Query.find [ Selector.tag "summary" ] |> Event.simulate Event.click |> Event.expect True
                    , \_ -> controlled True |> Query.fromHtml |> Query.find [ Selector.tag "summary" ] |> Event.simulate Event.click |> Event.expect False
                    , \_ -> controlled False |> Query.fromHtml |> Query.find [ Selector.tag "summary" ] |> Event.simulate Event.click |> Event.expectPreventDefault
                    ]
                    ()
        , test "the browser opening it (find-in-page) is reported" <|
            \() ->
                controlled False
                    |> Query.fromHtml
                    |> Event.simulate (toggle "open")
                    |> Event.expect True
        , test "toggle events that match the model are not reported" <|
            \() ->
                controlled True
                    |> Query.fromHtml
                    |> Event.simulate (toggle "open")
                    |> Event.toResult
                    |> Expect.err
        ]
