module Designsystemet.PopoverTest exposing (suite)

import Designsystemet.Button as Button
import Designsystemet.Placement as Placement exposing (Placement(..))
import Designsystemet.Popover as Popover exposing (State(..))
import Expect
import Html
import Html.Attributes as Attr
import Json.Encode as Encode
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


help : Popover.Id
help =
    Popover.id "help"


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


toggleEvent : String -> ( String, Encode.Value )
toggleEvent newState =
    Event.custom "toggle" (Encode.object [ ( "newState", Encode.string newState ) ])


suite : Test
suite =
    describe "Designsystemet.Popover"
        [ test "the typed id wins over an id in the attributes, so triggers keep pointing at it" <|
            \() ->
                Popover.view help [ Attr.id "something-else" ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.id "help" ]
        , test "open renders the model's state as data-open, for the companion script" <|
            \() ->
                Popover.view (Popover.id "p") [ Popover.open True ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.attribute "data-open" "true") ]
        , test "renders a native auto popover placed on top" <|
            \() ->
                Popover.view help [] [ Html.text "Hjelp" ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "div"
                        , Selector.class "ds-popover"
                        , Selector.id "help"
                        , attr "popover" "auto"
                        , attr "data-placement" "top"
                        , Selector.text "Hjelp"
                        ]
        , test "placement, tinted and noAutoPlacement are data attributes" <|
            \() ->
                Popover.view help [ Popover.placement BottomStart, Popover.tinted, Popover.noAutoPlacement ] []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has
                            [ attr "data-placement" "bottom-start"
                            , attr "data-variant" "tinted"
                            , attr "data-autoplacement" "false"
                            ]
                        , Query.hasNot [ attr "data-placement" "top" ]
                        ]
        , test "invokers use popovertarget and popovertargetaction" <|
            \() ->
                Expect.all
                    [ \_ ->
                        Button.view (Popover.toggle help) []
                            |> Query.fromHtml
                            |> Expect.all
                                [ Query.has [ attr "popovertarget" "help" ]
                                , Query.hasNot [ Selector.attribute (Attr.attribute "popovertargetaction" "show") ]
                                ]
                    , \_ -> Button.view (Popover.show help) [] |> Query.fromHtml |> Query.has [ attr "popovertarget" "help", attr "popovertargetaction" "show" ]
                    , \_ -> Button.view (Popover.hide help) [] |> Query.fromHtml |> Query.has [ attr "popovertarget" "help", attr "popovertargetaction" "hide" ]
                    ]
                    ()
        , test "trigger is a ds-button toggling the popover" <|
            \() ->
                Popover.trigger help [ Button.tertiary ] [ Html.text "?" ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "button"
                        , Selector.class "ds-button"
                        , attr "type" "button"
                        , attr "popovertarget" "help"
                        , attr "data-variant" "tertiary"
                        ]
        , test "inlineTrigger is an unstyled inline button that never submits" <|
            \() ->
                Popover.inlineTrigger help [] [ Html.text "org.nr." ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has
                            [ Selector.tag "button"
                            , attr "type" "button"
                            , attr "data-popover" "inline"
                            , attr "popovertarget" "help"
                            , Selector.text "org.nr."
                            ]
                        , Query.hasNot [ Selector.class "ds-button" ]
                        ]
        , test "onToggle decodes newState open" <|
            \() ->
                Popover.view help [ Popover.onToggle identity ] []
                    |> Query.fromHtml
                    |> Event.simulate (toggleEvent "open")
                    |> Event.expect Open
        , test "onToggle decodes newState closed" <|
            \() ->
                Popover.view help [ Popover.onToggle identity ] []
                    |> Query.fromHtml
                    |> Event.simulate (toggleEvent "closed")
                    |> Event.expect Closed
        , test "onToggle ignores unknown states" <|
            \() ->
                Popover.view help [ Popover.onToggle identity ] []
                    |> Query.fromHtml
                    |> Event.simulate (toggleEvent "half-open")
                    |> Event.toResult
                    |> Expect.err
        , test "Placement.toString covers Floating UI's placements" <|
            \() ->
                List.map Placement.toString
                    [ Top, TopStart, TopEnd, Right, RightStart, RightEnd, Bottom, BottomStart, BottomEnd, Left, LeftStart, LeftEnd, None ]
                    |> Expect.equal
                        [ "top", "top-start", "top-end", "right", "right-start", "right-end", "bottom", "bottom-start", "bottom-end", "left", "left-start", "left-end", "none" ]
        ]
