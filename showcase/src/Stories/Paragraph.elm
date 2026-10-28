module Stories.Paragraph exposing (chapter)

{-| `paragraph.stories.tsx`, story for story.

React writes `variant="default"` as `data-variant="default"`; here the
default is no variant attribute.

-}

import Designsystemet.Paragraph as Paragraph
import Html exposing (Html)
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Paragraph", module_ = "Stories.Paragraph", storybook = "komponenter-typography-paragraph" }
        [ Story.story "Preview" preview
        ]


preview : List (Html msg)
preview =
    -- React's variant="default" is what you get without a variant attribute.
    [ Paragraph.view []
        [ Html.text "Personvernerklæringen gir informasjon om hvilke personopplysninger vi behandler, hvordan disse blir behandlet og hvilke rettigheter du har." ]
    ]
