module Stories.SkipLink exposing (chapter)

{-| `skip-link.stories.tsx`, story for story.
-}

import Designsystemet.Paragraph as Paragraph
import Designsystemet.SkipLink as SkipLink
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "SkipLink", module_ = "Stories.SkipLink", storybook = "komponenter-skiplink" }
        [ Story.story "Preview" preview
        , Story.story "Tabbed" tabbed
        ]


preview : List (Html msg)
preview =
    [ Paragraph.view []
        [ Html.text "For å vise skiplinken, tab til dette eksempelet, eller klikk inni eksempelet og trykk "
        , Html.kbd [] [ Html.text "Tab" ]
        , Html.text "."
        , SkipLink.view { href = "#main-content" } [] [ Html.text "Hopp til hovedinnhold" ]
        ]
    , Html.main_ [ Attr.id "main-content", Attr.tabindex -1 ]
        [ Html.text "Region som kan motta fokus fra skiplink." ]
    ]


tabbed : List (Html msg)
tabbed =
    [ Html.div []
        [ Html.text "For å vise skiplinken, tab til dette eksempelet, eller klikk inni eksempelet og trykk "
        , Html.kbd [] [ Html.text "Tab" ]
        , Html.text "."
        , SkipLink.view { href = "#main-content-tabbed" } [] [ Html.text "Hopp til hovedinnhold" ]
        , Html.main_ [ Attr.id "main-content-tabbed", Attr.tabindex -1 ]
            [ Html.text "Region som kan motta fokus fra skiplink." ]
        ]
    ]
