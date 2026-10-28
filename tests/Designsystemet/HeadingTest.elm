module Designsystemet.HeadingTest exposing (suite)

import Designsystemet.Heading as Heading exposing (Level(..), Size(..))
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
    describe "Designsystemet.Heading"
        [ describe "each level function renders its own element with ds-heading"
            (List.map
                (\( name, fn ) ->
                    test name <|
                        \() ->
                            fn [] [ Html.text "Tittel" ]
                                |> Query.fromHtml
                                |> Query.has [ Selector.tag name, Selector.class "ds-heading", Selector.text "Tittel" ]
                )
                [ ( "h1", Heading.h1 ), ( "h2", Heading.h2 ), ( "h3", Heading.h3 ), ( "h4", Heading.h4 ), ( "h5", Heading.h5 ), ( "h6", Heading.h6 ) ]
            )
        , test "view picks the element from a computed level" <|
            \() ->
                Heading.view H4 [] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "h4", Selector.class "ds-heading" ]
        , test "no data-size unless asked for" <|
            \() ->
                Heading.h2 [] []
                    |> Query.fromHtml
                    |> Query.hasNot [ Selector.attribute (Attr.attribute "data-size" "md") ]
        , describe "sizes map to the CSS scale"
            (List.map
                (\( size, value ) ->
                    test value <|
                        \() ->
                            Heading.h2 [ Heading.size size ] []
                                |> Query.fromHtml
                                |> Query.has [ attr "data-size" value ]
                )
                [ ( TwoExtraSmall, "2xs" ), ( ExtraSmall, "xs" ), ( Small, "sm" ), ( Medium, "md" ), ( Large, "lg" ), ( ExtraLarge, "xl" ), ( TwoExtraLarge, "2xl" ) ]
            )
        , test "viewAs puts heading styles on another element" <|
            \() ->
                Heading.viewAs Html.legend [ Attr.id "x" ] [ Html.text "Kontakt" ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "legend", Selector.class "ds-heading", Selector.id "x" ]
        , test "caller classes are kept alongside ds-heading" <|
            \() ->
                Heading.h1 [ Attr.class "mine" ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.classes [ "ds-heading", "mine" ] ]
        , test "events pass straight through" <|
            \() ->
                Heading.h2 [ Events.onClick "clicked" ] []
                    |> Query.fromHtml
                    |> Event.simulate Event.click
                    |> Event.expect "clicked"
        ]
