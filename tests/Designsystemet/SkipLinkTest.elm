module Designsystemet.SkipLinkTest exposing (suite)

import Designsystemet.SkipLink as SkipLink
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.SkipLink"
        [ test "an a.ds-skip-link to the target" <|
            \() ->
                SkipLink.view { href = "#main-content" } [] [ Html.text "Hopp til hovedinnhold" ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "a"
                        , Selector.class "ds-skip-link"
                        , Selector.attribute (Attr.href "#main-content")
                        , Selector.text "Hopp til hovedinnhold"
                        ]
        ]
