module Stories.ValidationMessage exposing (chapter)

{-| `validation-message.stories.tsx`, story for story.
-}

import Designsystemet.ValidationMessage as ValidationMessage
import Html exposing (Html)
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter
        { title = "ValidationMessage"
        , module_ = "Stories.ValidationMessage"
        , storybook = "komponenter-typography-validationmessage"
        }
        [ Story.story "Preview" preview
        ]


preview : List (Html msg)
preview =
    [ ValidationMessage.view [] [ Html.text "Dette er en valideringsmelding." ] ]
