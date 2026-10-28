module Designsystemet.ButtonTest exposing (suite)

import Designsystemet.Button as Button exposing (Loading(..))
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
    describe "Designsystemet.Button"
        [ test "renders a ds-button that never submits by accident" <|
            \() ->
                Button.view [] [ Html.text "Lagre" ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "button"
                        , Selector.class "ds-button"
                        , Selector.attribute (Attr.type_ "button")
                        , Selector.text "Lagre"
                        ]
        , test "the caller can still make it a submit button" <|
            \() ->
                Button.view [ Attr.type_ "submit" ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.type_ "submit") ]
        , test "variants are data-variant" <|
            \() ->
                Button.view [ Button.secondary ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.attribute "data-variant" "secondary") ]
        , test "a busy button is aria-busy and shows a hidden spinner before the label" <|
            \() ->
                Button.loading Busy [] [ Html.text "Lagre" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.attribute (Attr.attribute "aria-busy" "true"), Selector.text "Lagre" ]
                        , Query.find [ Selector.class "ds-spinner" ]
                            >> Query.has [ Selector.attribute (Attr.attribute "aria-hidden" "true") ]
                        ]
        , test "an idle loading button is just a button" <|
            \() ->
                Button.loading Idle [] [ Html.text "Lagre" ]
                    |> Query.fromHtml
                    |> Query.hasNot [ Selector.attribute (Attr.attribute "aria-busy" "true") ]
        , test "an icon button is labelled and marked data-icon" <|
            \() ->
                Button.icon { label = "Lukk", icon = Html.text "×" } []
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.attribute (Attr.attribute "aria-label" "Lukk")
                        , Selector.attribute (Attr.attribute "data-icon" "true")
                        , Selector.text "×"
                        ]
        , test "a busy icon button swaps the icon for the spinner" <|
            \() ->
                Button.iconLoading Busy { label = "Lukk", icon = Html.text "×" } []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.hasNot [ Selector.text "×" ]
                        , Query.has [ Selector.class "ds-spinner" ]
                        ]
        , test "viewAs renders the given element without a button type" <|
            \() ->
                Button.viewAs Html.a [ Attr.href "/ny" ] [ Html.text "Ny" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "a", Selector.class "ds-button" ]
                        , Query.hasNot [ Selector.attribute (Attr.type_ "button") ]
                        ]
        , test "events pass straight through" <|
            \() ->
                Button.view [ Events.onClick "clicked" ] []
                    |> Query.fromHtml
                    |> Event.simulate Event.click
                    |> Event.expect "clicked"
        ]
