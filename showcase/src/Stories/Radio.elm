module Stories.Radio exposing (chapter)

{-| `radio.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Field as Field
import Designsystemet.Fieldset as Fieldset
import Designsystemet.Radio as Radio
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Radio", module_ = "Stories.Radio", storybook = "komponenter-radio" }
        [ Story.story "Preview" preview
        , Story.story "AriaLabel" ariaLabel
        , Story.story "Group" group
        , Story.story "WithError" withError
        , Story.story "ReadOnly" readOnly
        , Story.story "Inline" inline
        , Story.story "Outline" outline
        , Story.story "End" end
        ]


preview : List (Html msg)
preview =
    [ Radio.new (Ds.label "Radio")
        |> Radio.withDescription [ Html.text "Description" ]
        |> Radio.view [ Attr.value "value", Attr.name "name" ]
    ]


ariaLabel : List (Html msg)
ariaLabel =
    [ Radio.new (Ds.ariaLabel "Radio")
        |> Radio.view [ Attr.value "value" ]
    ]


group : List (Html msg)
group =
    [ Fieldset.new [ Html.text "Hvilken iskremsmak er best?" ]
        |> Fieldset.withDescription [ Html.text "Velg din favorittsmak blant alternativene." ]
        |> Fieldset.view []
            [ Radio.new (Ds.label "Vanilje")
                |> Radio.view [ Attr.value "vanilje", Attr.name "icecream" ]
            , Radio.new (Ds.label "Jordbær")
                |> Radio.withDescription [ Html.text "Jordbær er best" ]
                |> Radio.view [ Attr.value "jordbær", Attr.name "icecream" ]
            , Radio.new (Ds.label "Sjokolade")
                |> Radio.view [ Attr.value "sjokolade", Attr.name "icecream" ]
            , Radio.new (Ds.label "Jeg spiser ikke iskrem")
                |> Radio.view [ Attr.value "spiser-ikke-is", Attr.name "icecream" ]
            ]
    ]


{-| The error belongs to the whole group, so it goes on the fieldset.
`<ds-field>` links it to every radio and marks them `aria-invalid`, which React
does by hand here.
-}
withError : List (Html msg)
withError =
    [ Fieldset.new [ Html.text "Hvilken bydel bor du i?" ]
        |> Fieldset.withDescription [ Html.text "Trondheim er delt inn i fire bydeler" ]
        |> Fieldset.withError (Just "Du må velge en bydel før du kan fortsette.")
        |> Fieldset.view []
            [ Radio.new (Ds.label "Østbyen") |> Radio.view [ Attr.value "ostbyen", Attr.name "city" ]
            , Radio.new (Ds.label "Lerkendal") |> Radio.view [ Attr.value "lerkendal", Attr.name "city" ]
            , Radio.new (Ds.label "Heimdal") |> Radio.view [ Attr.value "heimdal", Attr.name "city" ]
            , Radio.new (Ds.label "Midtbyen") |> Radio.view [ Attr.value "midtbyen", Attr.name "city" ]
            ]
    ]


readOnly : List (Html msg)
readOnly =
    [ Fieldset.new [ Html.text "Hvilken bydel bor du i?" ]
        |> Fieldset.withDescription [ Html.text "Trondheim er delt inn i fire bydeler" ]
        |> Fieldset.view []
            [ Radio.new (Ds.label "Østbyen") |> Radio.view [ Attr.value "ostbyen", Attr.name "city", Attr.readonly True ]
            , Radio.new (Ds.label "Lerkendal") |> Radio.view [ Attr.value "lerkendal", Attr.name "city", Attr.readonly True ]
            , Radio.new (Ds.label "Heimdal") |> Radio.view [ Attr.value "heimdal", Attr.name "city", Attr.readonly True, Attr.checked True ]
            , Radio.new (Ds.label "Midtbyen") |> Radio.view [ Attr.value "midtbyen", Attr.name "city", Attr.readonly True ]
            ]
    ]


inline : List (Html msg)
inline =
    [ Fieldset.new [ Html.text "Kontaktes på e-post?" ]
        |> Fieldset.withDescription [ Html.text "Bekreft om du ønsker å bli kontaktet per e-post." ]
        |> Fieldset.view []
            [ Html.div
                [ Attr.style "display" "flex"
                , Attr.style "flex-wrap" "wrap"
                , Attr.style "gap" "var(--ds-size-6)"
                ]
                [ Radio.new (Ds.label "Ja") |> Radio.view [ Attr.name "my-inline", Attr.value "ja" ]
                , Radio.new (Ds.label "Nei") |> Radio.view [ Attr.name "my-inline", Attr.value "nei" ]
                ]
            ]
    ]


outline : List (Html msg)
outline =
    [ Fieldset.new [ Html.text "Using variant=\"outline\"" ]
        |> Fieldset.view []
            [ Radio.new (Ds.label "with description")
                |> Radio.withDescription [ Html.text "description text" ]
                |> Radio.withFieldAttributes [ Field.outline ]
                |> Radio.view [ Attr.value "description" ]
            , Radio.new (Ds.label "Checked")
                |> Radio.withFieldAttributes [ Field.outline ]
                |> Radio.view [ Attr.value "checked", Attr.checked True ]
            , Radio.new (Ds.label "with error state")
                |> Radio.withError (Just "the error message")
                |> Radio.withFieldAttributes [ Field.outline ]
                |> Radio.view [ Attr.value "error" ]
            , Radio.new (Ds.label "disabled")
                |> Radio.withFieldAttributes [ Field.outline ]
                |> Radio.view [ Attr.value "disabled", Attr.disabled True ]
            , Radio.new (Ds.label "readonly checked")
                |> Radio.withFieldAttributes [ Field.outline ]
                |> Radio.view [ Attr.value "readonly", Attr.readonly True, Attr.checked True ]
            ]
    ]


end : List (Html msg)
end =
    [ Fieldset.new [ Html.text "Hvilken iskremsmak er best?" ]
        |> Fieldset.withDescription [ Html.text "Velg din favorittsmak blant alternativene." ]
        |> Fieldset.view []
            [ Radio.new (Ds.label "Vanilje")
                |> Radio.withFieldAttributes [ Field.position Field.End ]
                |> Radio.view [ Attr.value "vanilje", Attr.name "icecream" ]
            , Radio.new (Ds.label "Jordbær")
                |> Radio.withDescription [ Html.text "Jordbær er best" ]
                |> Radio.withFieldAttributes [ Field.position Field.End ]
                |> Radio.view [ Attr.value "jordbær", Attr.name "icecream" ]
            , Radio.new (Ds.label "Sjokolade")
                |> Radio.withFieldAttributes [ Field.position Field.End ]
                |> Radio.view [ Attr.value "sjokolade", Attr.name "icecream" ]
            , Radio.new (Ds.label "Jeg spiser ikke iskrem")
                |> Radio.withFieldAttributes [ Field.position Field.End ]
                |> Radio.view [ Attr.value "spiser-ikke-is", Attr.name "icecream" ]
            ]
    ]
