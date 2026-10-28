module Designsystemet.LinkTest exposing (suite)

import Designsystemet.Link as Link
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
    describe "Designsystemet.Link"
        [ test "renders a.ds-link with the caller's href" <|
            \() ->
                Link.view [ Attr.href "/saker" ] [ Html.text "Saker" ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "a", Selector.class "ds-link", Selector.attribute (Attr.href "/saker"), Selector.text "Saker" ]
        , test "viewAs renders another element with the link class" <|
            \() ->
                Link.viewAs Html.button [ Events.onClick "clicked" ] []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "button", Selector.class "ds-link" ]
                        , Event.simulate Event.click >> Event.expect "clicked"
                        ]
        ]
