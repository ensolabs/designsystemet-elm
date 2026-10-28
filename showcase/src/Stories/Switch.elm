module Stories.Switch exposing (chapter)

{-| `switch.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Field as Field
import Designsystemet.Fieldset as Fieldset
import Designsystemet.Switch as Switch
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Switch", module_ = "Stories.Switch", storybook = "komponenter-switch" }
        [ Story.story "Preview" preview
        , Story.story "Checked" checked
        , Story.story "Group" group
        , Story.story "RightAligned" rightAligned
        , Story.story "Outline" outline
        ]


preview : List (Html msg)
preview =
    [ Switch.new (Ds.label "Switch")
        |> Switch.withFieldAttributes [ Field.position Field.Start ]
        |> Switch.view []
    ]


checked : List (Html msg)
checked =
    [ Switch.new (Ds.label "Switch") |> Switch.view [ Attr.checked True ] ]


group : List (Html msg)
group =
    [ Fieldset.new [ Html.text "Skru av/på lys" ]
        |> Fieldset.view []
            [ Switch.new (Ds.label "Stue") |> Switch.view [ Attr.checked True ]
            , Switch.new (Ds.label "Kjøkken") |> Switch.view []
            , Switch.new (Ds.label "Bad") |> Switch.view []
            , Switch.new (Ds.label "Soverom")
                |> Switch.withDescription [ Html.text "Får ikke kontakt med lyspærene" ]
                |> Switch.view [ Attr.readonly True ]
            ]
    ]


rightAligned : List (Html msg)
rightAligned =
    [ Switch.new (Ds.label "Flymodus")
        |> Switch.withFieldAttributes [ Field.position Field.End ]
        |> Switch.view [ Attr.checked True ]
    ]


outline : List (Html msg)
outline =
    [ Fieldset.new [ Html.text "Using variant=\"outline\"" ]
        |> Fieldset.view []
            [ Switch.new (Ds.label "with description")
                |> Switch.withDescription [ Html.text "description text" ]
                |> Switch.withFieldAttributes [ Field.outline ]
                |> Switch.view [ Attr.value "description" ]
            , Switch.new (Ds.label "Checked")
                |> Switch.withFieldAttributes [ Field.outline ]
                |> Switch.view [ Attr.value "checked", Attr.checked True ]
            , Switch.new (Ds.label "disabled")
                |> Switch.withFieldAttributes [ Field.outline ]
                |> Switch.view [ Attr.value "disabled", Attr.disabled True ]
            , Switch.new (Ds.label "readonly checked")
                |> Switch.withFieldAttributes [ Field.outline ]
                |> Switch.view [ Attr.value "readonly", Attr.readonly True, Attr.checked True ]
            ]
    ]
