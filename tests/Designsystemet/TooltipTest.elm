module Designsystemet.TooltipTest exposing (suite)

import Designsystemet.Button as Button
import Designsystemet.Placement exposing (Placement(..))
import Designsystemet.Tooltip as Tooltip
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


suite : Test
suite =
    describe "Designsystemet.Tooltip"
        [ test "content is data-tooltip on the element itself" <|
            \() ->
                Button.icon { label = "Slett", icon = Html.text "x" } [ Tooltip.content "Slett" ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "button", attr "data-tooltip" "Slett", attr "aria-label" "Slett" ]
        , test "placement and noAutoPlacement" <|
            \() ->
                Html.button [ Tooltip.content "Hei", Tooltip.placement Left, Tooltip.noAutoPlacement ] []
                    |> Query.fromHtml
                    |> Query.has [ attr "data-placement" "left", attr "data-autoplacement" "false" ]
        , test "onText wraps text in a focusable span with the tooltip" <|
            \() ->
                Tooltip.onText { content = "Organisasjonsnummer", text = "org.nr." } []
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "span"
                        , Selector.attribute (Attr.tabindex 0)
                        , attr "data-tooltip" "Organisasjonsnummer"
                        , Selector.text "org.nr."
                        ]
        , test "aria-label and aria-description are left to designsystemet-web" <|
            \() ->
                Tooltip.onText { content = "Organisasjonsnummer", text = "org.nr." } []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.hasNot [ attr "aria-label" "Organisasjonsnummer" ]
                        , Query.hasNot [ attr "aria-description" "Organisasjonsnummer" ]
                        ]
        ]
