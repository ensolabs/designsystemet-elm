module Designsystemet.TabsTest exposing (suite)

import Designsystemet.Tabs as Tabs
import Expect
import Html exposing (Html)
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


type Section
    = Overview
    | Documents


sectionId : Section -> String
sectionId section =
    case section of
        Overview ->
            "case-overview"

        Documents ->
            "case-documents"


tabs : List (Tabs.Tab Section msg)
tabs =
    [ Tabs.tab { value = Overview, label = [ Html.text "Oversikt" ], panel = [ Html.text "Oversiktspanel" ] }
    , Tabs.tab { value = Documents, label = [ Html.text "Dokumenter" ], panel = [ Html.text "Dokumentpanel" ] }
    ]


uncontrolled : Html msg
uncontrolled =
    Tabs.uncontrolled { toId = sectionId, initial = Documents } [ Attr.attribute "data-size" "sm" ] tabs


controlled : Html Section
controlled =
    Tabs.controlled { toId = sectionId, selected = Overview, onSelect = identity } [] tabs


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


tab : String -> Html msg -> Query.Single msg
tab label html =
    html
        |> Query.fromHtml
        |> Query.find [ Selector.tag "ds-tab", Selector.containing [ Selector.text label ] ]


suite : Test
suite =
    describe "Designsystemet.Tabs"
        [ test "ds-tabs > ds-tablist, then the panels, like React" <|
            \() ->
                uncontrolled
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "ds-tabs", Selector.class "ds-tabs", attr "data-size" "sm" ]
                        , Query.children []
                            >> Expect.all
                                [ Query.count (Expect.equal 3)
                                , Query.first >> Query.has [ Selector.tag "ds-tablist" ]
                                , Query.index 1 >> Query.has [ Selector.tag "ds-tabpanel", Selector.id "case-overview", Selector.text "Oversiktspanel" ]
                                , Query.index 2 >> Query.has [ Selector.tag "ds-tabpanel", Selector.id "case-documents", Selector.text "Dokumentpanel" ]
                                ]
                        , Query.find [ Selector.tag "ds-tablist" ]
                            >> Query.children [ Selector.tag "ds-tab" ]
                            >> Query.count (Expect.equal 2)
                        ]
        , test "a tab controls its panel and carries its value" <|
            \() ->
                tab "Dokumenter" uncontrolled
                    |> Query.has
                        [ attr "aria-controls" "case-documents"
                        , attr "data-value" "case-documents"
                        , attr "role" "tab"
                        ]
        , test "uncontrolled: the initial tab is selected, the others are not" <|
            \() ->
                Expect.all
                    [ \_ -> tab "Dokumenter" uncontrolled |> Query.has [ attr "aria-selected" "true" ]
                    , \_ -> tab "Oversikt" uncontrolled |> Query.has [ attr "aria-selected" "false" ]
                    ]
                    ()
        , test "uncontrolled: clicks are left to the browser" <|
            \() ->
                tab "Oversikt" uncontrolled
                    |> Event.simulate Event.click
                    |> Event.toResult
                    |> Expect.err
        , test "panels' visibility, tabindex and labelling are left to designsystemet-web" <|
            \() ->
                uncontrolled
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "ds-tabpanel" ]
                    |> Query.each
                        (Expect.all
                            [ Query.hasNot [ Selector.attribute (Attr.hidden True) ]
                            , Query.hasNot [ attr "hidden" "" ]
                            , Query.hasNot [ attr "aria-labelledby" "case-overview" ]
                            ]
                        )
        , test "controlled: selected follows the model" <|
            \() ->
                Expect.all
                    [ \_ -> tab "Oversikt" controlled |> Query.has [ attr "aria-selected" "true" ]
                    , \_ -> tab "Dokumenter" controlled |> Query.has [ attr "aria-selected" "false" ]
                    ]
                    ()
        , test "controlled: clicking another tab sends its value" <|
            \() ->
                tab "Dokumenter" controlled
                    |> Event.simulate Event.click
                    |> Event.expect Documents
        , test "controlled: the click is cancelled so designsystemet-web doesn't switch" <|
            \() ->
                tab "Dokumenter" controlled
                    |> Event.simulate Event.click
                    |> Event.expectPreventDefault
        , test "controlled: clicking the open tab sends nothing" <|
            \() ->
                tab "Oversikt" controlled
                    |> Event.simulate Event.click
                    |> Event.toResult
                    |> Expect.err
        , test "an icon tab is named by its label and shows it as a tooltip" <|
            \() ->
                Tabs.uncontrolled { toId = sectionId, initial = Overview }
                    []
                    [ Tabs.iconTab { value = Overview, label = "Oversikt", icon = Html.text "@", panel = [] } ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "ds-tab" ]
                    |> Query.has
                        [ attr "aria-label" "Oversikt"
                        , attr "data-tooltip" "Oversikt"
                        , attr "aria-controls" "case-overview"
                        , Selector.text "@"
                        ]
        ]
