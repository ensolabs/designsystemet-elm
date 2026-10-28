module Designsystemet.DropdownTest exposing (suite)

import Designsystemet.Dialog as Dialog
import Designsystemet.Dropdown as Dropdown
import Designsystemet.Heading as Heading
import Designsystemet.Placement exposing (Placement(..))
import Expect
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


actions : Dropdown.Id
actions =
    Dropdown.id "actions"


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


menu : Html.Html String
menu =
    Dropdown.view actions
        []
        [ Dropdown.heading Heading.H2 [] [ Html.text "Sak 42" ]
        , Dropdown.list []
            [ Dropdown.item [] [ Dropdown.button [ Events.onClick "archive" ] [ Html.text "Arkiver" ] ]
            , Dropdown.item [] [ Dropdown.button (Dialog.showModal (Dialog.id "confirm")) [ Html.text "Slett" ] ]
            ]
        ]


suite : Test
suite =
    describe "Designsystemet.Dropdown"
        [ test "the typed id wins over an id in the attributes, so triggers keep pointing at it" <|
            \() ->
                Dropdown.view actions [ Attr.id "something-else" ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.id "actions" ]
        , test "is a ds-dropdown popover (not ds-popover), placed bottom-end" <|
            \() ->
                menu
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has
                            [ Selector.tag "div"
                            , Selector.class "ds-dropdown"
                            , Selector.id "actions"
                            , attr "popover" "auto"
                            , attr "data-placement" "bottom-end"
                            ]
                        , Query.hasNot [ Selector.class "ds-popover" ]
                        ]
        , test "placement overrides the default" <|
            \() ->
                Dropdown.view actions [ Dropdown.placement Top ] []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ attr "data-placement" "top" ]
                        , Query.hasNot [ attr "data-placement" "bottom-end" ]
                        ]
        , test "heading is an h2.ds-heading" <|
            \() ->
                menu
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "h2" ]
                    |> Query.has [ Selector.class "ds-heading", Selector.text "Sak 42" ]
        , test "the heading level is the caller's" <|
            \() ->
                Dropdown.view actions [] [ Dropdown.heading Heading.H3 [] [ Html.text "Sak 42" ] ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "h3" ]
                    |> Query.has [ Selector.class "ds-heading" ]
        , test "items are li children of the ul, each with a button" <|
            \() ->
                menu
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "ul" ]
                    |> Query.children [ Selector.tag "li" ]
                    |> Expect.all
                        [ Query.count (Expect.equal 2)
                        , Query.each (Query.children [ Selector.tag "button" ] >> Query.count (Expect.equal 1))
                        ]
        , test "item buttons are tertiary and pass events through" <|
            \() ->
                menu
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "button", Selector.containing [ Selector.text "Arkiver" ] ]
                    |> Expect.all
                        [ Query.has [ Selector.class "ds-button", attr "data-variant" "tertiary" ]
                        , Event.simulate Event.click >> Event.expect "archive"
                        ]
        , test "trigger and invokers target the dropdown" <|
            \() ->
                Expect.all
                    [ \_ -> Dropdown.trigger actions [] [] |> Query.fromHtml |> Query.has [ Selector.class "ds-button", attr "popovertarget" "actions" ]
                    , \_ -> Html.button (Dropdown.toggle actions) [] |> Query.fromHtml |> Query.has [ attr "popovertarget" "actions" ]
                    , \_ -> Html.button (Dropdown.show actions) [] |> Query.fromHtml |> Query.has [ attr "popovertargetaction" "show" ]
                    , \_ -> Html.button (Dropdown.hide actions) [] |> Query.fromHtml |> Query.has [ attr "popovertargetaction" "hide" ]
                    ]
                    ()
        ]
