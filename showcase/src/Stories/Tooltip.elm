module Stories.Tooltip exposing (chapter)

{-| `tooltip.stories.tsx`, story for story.

A tooltip is an attribute on the element it explains, not a wrapper.
`designsystemet-web` makes its text the element's `aria-label` (no text of its
own) or `aria-description` (has text).

-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Link as Link
import Designsystemet.Placement as Placement
import Designsystemet.Size as Size
import Designsystemet.Tooltip as Tooltip
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icons
import Showcase.Story as Story exposing (Chapter)
import Stories.Interactive.State exposing (Model, Msg(..))


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Tooltip", module_ = "Stories.Tooltip", storybook = "komponenter-tooltip" }
        [ Story.story "Preview" preview
        , Story.story "WithLink" withLink
        , Story.story "WithSpan" withSpan
        , Story.story "WithPlainText" withPlainText
        , Story.story "WithString" withString
        , Story.story "Placement" placement
        , Story.story "Aria" aria
            |> Story.withStoryCustomStyles [ ( "display", "flex" ), ( "gap", "var(--ds-size-2)" ), ( "align-items", "center" ) ]
        , Story.story "WithDynamicTooltipText" (withDynamicTooltipText model)
        , Story.story "WithCSSTooltipText" withCSSTooltipText
        , Story.story "WithDynamicCSSTooltipText" withDynamicCSSTooltipText
        , Story.story "Sizes" sizes
        ]
        |> Story.withCustomStyles [ ( "margin", "2rem" ), ( "padding", "4rem" ) ]


preview : List (Html msg)
preview =
    -- An icon button needs a label anyway: give the tooltip the same text.
    [ Button.icon { label = "Kopier", icon = Icons.files [] }
        [ Tooltip.content "Kopier", Tooltip.placement Placement.Top ]
    ]


withLink : List (Html msg)
withLink =
    [ Link.view [ Attr.href "#", Tooltip.content "Gå til en annen side...", Tooltip.placement Placement.Top ]
        [ Html.text "En lenke" ]
    ]


withSpan : List (Html msg)
withSpan =
    -- Like upstream, without `tabindex`: keyboard users can't reach this
    -- one, and designsystemet-web warns about it. See `withPlainText`.
    [ Html.span [ Tooltip.content "Innholdet i tooltipen", Tooltip.placement Placement.Top ]
        [ Html.text "Tekst med tooltip" ]
    ]


withPlainText : List (Html msg)
withPlainText =
    [ Tooltip.onText { content = "Innholdet i tooltipen", text = "Tekst med tooltip" }
        [ Tooltip.placement Placement.Top ]
    ]


withString : List (Html msg)
withString =
    [ Tooltip.onText { content = "Organisasjonsnummer", text = "Org.nr." } [] ]


placement : List (Html msg)
placement =
    [ Button.icon { label = "Kopier", icon = Icons.files [] }
        [ Tooltip.content "Kopier", Tooltip.placement Placement.Bottom ]
    ]


aria : List (Html msg)
aria =
    [ Button.view [ Tooltip.content "Beskrivelse for aria-description" ]
        [ Html.text "Eg er aria-description" ]
    , Button.view [ Tooltip.content "Beskrivelse for aria-description" ]
        [ Icons.files [], Html.span [] [ Html.text "Eg er også aria-description" ] ]
    , Button.icon { label = "Eg er aria-label", icon = Icons.files [] }
        [ Tooltip.content "Eg er aria-label" ]
    ]


withDynamicTooltipText : Model -> List (Html Msg)
withDynamicTooltipText model =
    let
        text : String
        text =
            if model.tooltipCopied then
                "Kopiert"

            else
                "Kopier"
    in
    [ Button.icon { label = text, icon = Icons.files [] }
        [ Tooltip.content text
        , Events.onClick Copied
        , Events.onBlur CopyButtonBlurred
        ]
    ]


{-| The tooltip text can come from the `--ds-tooltip` custom property instead
of the attribute. Elm's `Attr.style` can't set custom properties, so the
`style` attribute is set as a whole.
-}
withCSSTooltipText : List (Html msg)
withCSSTooltipText =
    [ Button.view [ Tooltip.content "", Attr.attribute "style" "--ds-tooltip: \"Kopier\"" ]
        [ Icons.files [] ]
    ]


{-| React reads its own `--ds-tooltip-content` property back with
`getComputedStyle` and passes it as the content. Elm views can't read styles,
and don't need to: `designsystemet-web` reads `--ds-tooltip` itself, as in
`withCSSTooltipText`.
-}
withDynamicCSSTooltipText : List (Html msg)
withDynamicCSSTooltipText =
    [ Button.view [ Tooltip.content "", Attr.attribute "style" "--ds-tooltip: \"Kopier\"" ]
        [ Icons.files [] ]
    ]


sizes : List (Html msg)
sizes =
    List.map
        (\size ->
            Button.icon { label = "Kopier", icon = Icons.files [] }
                [ Ds.size size, Tooltip.content "Kopier" ]
        )
        [ Size.sm, Size.md, Size.lg ]
