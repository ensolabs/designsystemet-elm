module Stories.Label exposing (chapter)

{-| `label.stories.tsx`, story for story.
-}

import Designsystemet.Label as Label
import Html exposing (Html)
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Label", module_ = "Stories.Label", storybook = "komponenter-typography-label" }
        [ Story.story "Preview" preview
        ]


{-| React's story sets the deprecated `weight="medium"`, which isn't ported:
inside a field, the label's weight follows the input type.
-}
preview : List (Html msg)
preview =
    [ Label.view [] [ Html.text "Fødselsnummer (11 sifre)" ] ]
