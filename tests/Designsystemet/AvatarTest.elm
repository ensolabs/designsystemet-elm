module Designsystemet.AvatarTest exposing (suite)

import Designsystemet.Avatar as Avatar exposing (Content(..), Name(..))
import Expect
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


suite : Test
suite =
    describe "Designsystemet.Avatar"
        [ test "a labelled avatar is span.ds-avatar role=img with an aria-label" <|
            \() ->
                Avatar.view { name = Label "Kari Nordmann", content = Initials "KN" } []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has
                            [ Selector.tag "span"
                            , Selector.class "ds-avatar"
                            , attr "role" "img"
                            , attr "aria-label" "Kari Nordmann"
                            , Selector.text "KN"
                            ]
                        , Query.hasNot [ Selector.attribute (Attr.tabindex 0) ]
                        , Query.hasNot [ attr "data-tooltip" "Kari Nordmann" ]
                        ]
        , test "a tooltip avatar is labelled by the tooltip and focusable" <|
            \() ->
                Avatar.view { name = Tooltip "Ola Nordmann", content = Placeholder } []
                    |> Query.fromHtml
                    |> Query.has
                        [ attr "data-tooltip" "Ola Nordmann"
                        , attr "aria-label" "Ola Nordmann"
                        , Selector.attribute (Attr.tabindex 0)
                        ]
        , test "a decorative avatar is hidden and has no name" <|
            \() ->
                Avatar.view { name = Decorative, content = Initials "KN" } []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ attr "aria-hidden" "true", attr "role" "img" ]
                        , Query.hasNot [ attr "aria-label" "KN" ]
                        , Query.hasNot [ Selector.attribute (Attr.tabindex 0) ]
                        ]
        , test "an image gets an empty alt, since the avatar is already named" <|
            \() ->
                Avatar.view { name = Label "Kari", content = Image "/kari.jpg" } []
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "img" ]
                    |> Query.has [ Selector.attribute (Attr.src "/kari.jpg"), Selector.attribute (Attr.alt "") ]
        , test "an icon is rendered as the only child" <|
            \() ->
                Avatar.view { name = Label "Firma AS", content = Icon (Html.i [ Attr.class "icon" ] []) } []
                    |> Query.fromHtml
                    |> Query.children []
                    |> Expect.all
                        [ Query.count (Expect.equal 1)
                        , Query.first >> Query.has [ Selector.class "icon" ]
                        ]
        , test "a placeholder is empty, so the CSS draws the silhouette" <|
            \() ->
                Avatar.view { name = Label "Ukjent", content = Placeholder } []
                    |> Query.fromHtml
                    |> Query.children []
                    |> Query.count (Expect.equal 0)
        , describe "sizes"
            (List.map
                (\( size, value ) ->
                    test value <|
                        \() ->
                            Avatar.view { name = Decorative, content = Placeholder } [ Avatar.size size ]
                                |> Query.fromHtml
                                |> Query.has [ attr "data-size" value ]
                )
                [ ( Avatar.ExtraSmall, "xs" ), ( Avatar.Small, "sm" ), ( Avatar.Medium, "md" ), ( Avatar.Large, "lg" ) ]
            )
        , test "viewAs keeps the element's own role and passes events" <|
            \() ->
                Avatar.viewAs Html.button { name = Label "Meny", content = Initials "KN" } [ Events.onClick "open" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "button", Selector.class "ds-avatar", attr "aria-label" "Meny" ]
                        , Query.hasNot [ attr "role" "img" ]
                        , Event.simulate Event.click >> Event.expect "open"
                        ]
        ]
