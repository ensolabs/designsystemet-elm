module Stories.Link exposing (chapter)

{-| `link.stories.tsx`, story for story.

Differences from the React stories (they show up in the markup diff):

  - AsButton: React passes `href` to the `<button>`, where it means nothing;
    it is left out.

-}

import Designsystemet as Ds
import Designsystemet.Color as Color
import Designsystemet.Link as Link
import Designsystemet.Paragraph as Paragraph
import Html exposing (Html)
import Html.Attributes as Attr
import Icons
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Link", module_ = "Stories.Link", storybook = "komponenter-link" }
        [ Story.story "Normal" normal
        , Story.story "InText" inText
        , Story.story "WithIcon" withIcon
        , Story.story "WithIconRight" withIconRight
        , Story.story "WithMultipleIcons" withMultipleIcons
        , Story.story "WithOnlyIcon" withOnlyIcon
        , Story.story "LongLink" longLink
            |> Story.withStoryCustomStyles [ ( "width", "200px" ) ]
        , Story.story "Neutral" neutral
        , Story.story "AsButton" asButton
        ]
        |> Story.withCustomStyles [ ( "padding", "var(--ds-size-6)" ) ]


normal : List (Html msg)
normal =
    [ Link.view [ Attr.href "https://designsystemet.no/" ] [ Html.text "Gå til designsystemet" ] ]


inText : List (Html msg)
inText =
    [ Paragraph.view []
        [ Html.text "Vi bruker komponenter fra "
        , Link.view [ Attr.href "https://designsystemet.no/" ] [ Html.text "designsystemet.no" ]
        , Html.text "."
        ]
    ]


withIcon : List (Html msg)
withIcon =
    -- Wrap the text in a span, so the CSS puts space between it and the icon.
    -- (Upstream's `mailto:` href is overridden by the story's args.)
    [ Link.view [ Attr.href "https://designsystemet.no/" ]
        [ Icons.envelopeClosed [ Attr.attribute "aria-hidden" "true", Attr.attribute "height" "1.5rem", Attr.attribute "width" "1.5rem" ]
        , Html.span [] [ Html.text "Kontakt oss" ]
        ]
    ]


withIconRight : List (Html msg)
withIconRight =
    [ Link.view [ Attr.href "https://designsystemet.no/" ]
        [ Html.span [] [ Html.text "Kontakt oss" ]
        , Icons.envelopeClosed [ Attr.attribute "aria-hidden" "true", Attr.attribute "height" "1.5rem", Attr.attribute "width" "1.5rem" ]
        ]
    ]


withMultipleIcons : List (Html msg)
withMultipleIcons =
    [ Link.view [ Attr.href "https://designsystemet.no/" ]
        [ Icons.component [ Attr.attribute "aria-hidden" "true", Attr.attribute "height" "1.5rem", Attr.attribute "width" "1.5rem" ]
        , Html.span [] [ Html.text "Komponenter og" ]
        , Icons.book [ Attr.attribute "aria-hidden" "true", Attr.attribute "height" "1.5rem", Attr.attribute "width" "1.5rem" ]
        , Html.span [] [ Html.text "dokumentasjon på designsystemet.no" ]
        , Icons.externalLink [ Attr.attribute "aria-hidden" "true", Attr.attribute "height" "1.5rem", Attr.attribute "width" "1.5rem" ]
        ]
    ]


withOnlyIcon : List (Html msg)
withOnlyIcon =
    -- With a title the icon is no longer decorative: it names the link.
    [ Link.view [ Attr.href "https://designsystemet.no/" ]
        [ Icons.component
            [ Attr.attribute "title" "Designsystemet"
            , Attr.attribute "height" "1.5rem"
            , Attr.attribute "width" "1.5rem"
            ]
        ]
    ]


longLink : List (Html msg)
longLink =
    [ Paragraph.view []
        [ Link.view [ Attr.href "https://designsystemet.no/" ]
            [ Html.text "Dette er en lenke som brekker over flere linjer" ]
        ]
    ]


neutral : List (Html msg)
neutral =
    [ Link.view [ Attr.href "https://designsystemet.no/", Ds.color Color.neutral ]
        [ Html.text "Gå til designsystemet" ]
    ]


asButton : List (Html msg)
asButton =
    [ Link.viewAs Html.button [ Attr.type_ "button" ] [ Html.text "Gå til designsystemet" ] ]
