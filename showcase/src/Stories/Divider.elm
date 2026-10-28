module Stories.Divider exposing (chapter)

{-| `divider.stories.tsx`, story for story.
-}

import Designsystemet.Divider as Divider
import Designsystemet.Paragraph as Paragraph
import Html exposing (Html)
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Divider", module_ = "Stories.Divider", storybook = "komponenter-divider" }
        [ Story.story "Preview" preview
        ]


preview : List (Html msg)
preview =
    [ Paragraph.view [] [ Html.text "Divider er brukt for å dele opp innhold i mindre deler." ]
    , Divider.view []
    , Paragraph.view [] [ Html.text "Den kan også brukes for å skille innhold som er relatert til hverandre." ]
    ]
