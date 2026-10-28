module Stories.Field exposing (Model, Msg, chapter, init, update)

{-| `field.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Divider as Divider
import Designsystemet.Field as Field
import Designsystemet.Input as Input
import Designsystemet.Label as Label
import Designsystemet.Tag as Tag
import Designsystemet.Textarea as Textarea
import Designsystemet.ValidationMessage as ValidationMessage
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Showcase.Story as Story exposing (Chapter)


type alias Model =
    { description : String }


type Msg
    = DescriptionChanged String


init : Model
init =
    { description = "Nordmann" }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DescriptionChanged description ->
            ( { model | description = description }, Cmd.none )


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Field", module_ = "Stories.Field", storybook = "komponenter-field" }
        [ Story.story "Preview" preview
        , Story.story "Affix" affix
        , Story.story "Counter" counter
        , Story.story "CounterControlled" (counterControlled model)
        , Story.story "Position" position
        , Story.story "Optional" optional
        ]
        |> Story.withCustomStyles [ ( "max-width", "600px" ), ( "width", "90vw" ) ]


preview : List (Html msg)
preview =
    [ Field.view []
        [ Label.view [] [ Html.text "Etternavn" ]
        , Field.description [] [ Html.text "Etternavn kan ikke inneholde mellomrom" ]
        , Input.view [ Attr.value "Nordmann Svenske" ]
        , ValidationMessage.view [] [ Html.text "Du kan ikke ha mellomrom i etternavnet ditt" ]
        ]
    ]


affix : List (Html msg)
affix =
    [ Field.view []
        [ Label.view [] [ Html.text "Hvor mange kroner koster det per måned?" ]
        , Field.affixes []
            [ Field.affix [] [ Html.text "NOK" ]
            , Input.view []
            , Field.affix [] [ Html.text "pr. mnd." ]
            ]
        ]
    ]


counter : List (Html msg)
counter =
    [ Field.view []
        [ Label.view [] [ Html.text "Legg til en beskrivelse" ]
        , Textarea.view [ Attr.rows 2 ]
        , Field.counter { limit = 10, under = "%d tegn igjen", over = "%d tegn for mye" } []
        ]
    ]


counterControlled : Model -> List (Html Msg)
counterControlled model =
    [ Field.view []
        [ Label.view [] [ Html.text "Legg til en beskrivelse" ]
        , Textarea.view
            [ Attr.rows 2
            , Attr.value model.description
            , Events.onInput DescriptionChanged
            ]
        , Field.counter { limit = 10, under = "%d tegn igjen", over = "%d tegn for mye" } []
        ]
    , Button.view [ Events.onClick (DescriptionChanged "Hei") ] [ Html.text "Set verdi \"hei\"" ]
    ]


position : List (Html msg)
position =
    [ Html.div [ Attr.style "max-width" "200px", Attr.style "margin" "auto" ]
        [ Field.view [ Field.position Field.End ]
            [ Label.view [] [ Html.text "Flymodus" ]
            , Input.view [ Attr.type_ "checkbox", Attr.attribute "role" "switch" ]
            ]
        , Divider.view []
        , Field.view [ Field.position Field.End ]
            [ Label.view [] [ Html.text "Lydløs" ]
            , Input.view [ Attr.type_ "checkbox", Attr.attribute "role" "switch" ]
            ]
        ]
    ]


optional : List (Html msg)
optional =
    [ Field.view []
        [ Label.view []
            [ Html.text "Hvor bor du?"
            , Tag.view [ Ds.color Color.info, Attr.style "margin-inline-start" "var(--ds-size-2)" ]
                [ Html.text "Valgfritt" ]
            ]
        , Input.view []
        ]
    ]
