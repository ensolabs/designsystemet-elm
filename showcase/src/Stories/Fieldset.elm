module Stories.Fieldset exposing (chapter)

{-| `fieldset.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Checkbox as Checkbox
import Designsystemet.Fieldset as Fieldset
import Designsystemet.Radio as Radio
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Fieldset", module_ = "Stories.Fieldset", storybook = "komponenter-fieldset" }
        [ Story.story "Preview" preview
        , Story.story "WithCheckbox" withCheckbox
        , Story.story "LegendAsHeading" legendAsHeading
        ]


preview : List (Html msg)
preview =
    [ Fieldset.new [ Html.text "Hvilken fjordarm bor du ved?" ]
        |> Fieldset.withDescription [ Html.text "Valget vil hjelpe oss å forbedre innholdet vi viser deg." ]
        |> Fieldset.view []
            [ Radio.new (Ds.label "Barsnesfjorden") |> Radio.view [ Attr.name "radio", Attr.value "barsnesfjorden" ]
            , Radio.new (Ds.label "Eidsfjorden") |> Radio.view [ Attr.name "radio", Attr.value "eidsfjorden" ]
            , Radio.new (Ds.label "Ingen av de") |> Radio.view [ Attr.name "radio", Attr.value "ingen-av-de" ]
            ]
    ]


withCheckbox : List (Html msg)
withCheckbox =
    [ Fieldset.new [ Html.text "Godtar du vilkårene?" ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "Ja, jeg godtar") |> Checkbox.view [] ]
    ]


legendAsHeading : List (Html msg)
legendAsHeading =
    [ Fieldset.new [ Html.h1 [] [ Html.text "Hvor skal du reise?" ] ]
        |> Fieldset.view [] []
    ]
