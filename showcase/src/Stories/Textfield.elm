module Stories.Textfield exposing (Model, Msg, chapter, init, update)

{-| `textfield.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Divider as Divider
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Tag as Tag
import Designsystemet.Textfield as Textfield
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Showcase.Story as Story exposing (Chapter)


type alias Model =
    { value : String }


type Msg
    = ValueChanged String


init : Model
init =
    { value = "Ost" }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ValueChanged value ->
            ( { model | value = value }, Cmd.none )


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Textfield", module_ = "Stories.Textfield", storybook = "komponenter-textfield" }
        [ Story.story "Preview" preview
        , Story.story "Rows" rows
        , Story.story "Affix" affix
        , Story.story "Counter" counter
        , Story.story "Controlled" (controlled model)
        , Story.story "DateInputs" dateInputs
        , Story.story "Required" required
        ]


preview : List (Html msg)
preview =
    [ Textfield.new (Ds.label "Label") |> Textfield.view [] ]


rows : List (Html msg)
rows =
    [ Textfield.multiline (Ds.label "Label") |> Textfield.view [ Attr.rows 4 ] ]


affix : List (Html msg)
affix =
    [ Textfield.new (Ds.label "Hvor mange kroner koster det per måned?")
        |> Textfield.withPrefix "NOK"
        |> Textfield.withSuffix "pr. mnd"
        |> Textfield.view []
    ]


counter : List (Html msg)
counter =
    [ Textfield.new (Ds.label "Hvor mange kroner koster det per måned?")
        |> Textfield.withCounter { limit = 10, under = "%d tegn igjen", over = "%d tegn for mye" }
        |> Textfield.view []
    ]


controlled : Model -> List (Html Msg)
controlled model =
    [ Textfield.new (Ds.label "Kontroller meg!")
        |> Textfield.withCounter { limit = 5, under = "%d tegn igjen", over = "%d tegn for mye" }
        |> Textfield.view [ Attr.value model.value, Events.onInput ValueChanged ]
    , Divider.view [ Attr.style "margin-top" "var(--ds-size-4)" ]
    , Paragraph.view [ Attr.style "margin" "var(--ds-size-2) 0" ]
        [ Html.text "Du har skrevet inn: ", Html.text model.value ]
    , Button.view [ Events.onClick (ValueChanged "Kake") ] [ Html.text "Jeg vil ha Kake" ]
    ]


dateInputs : List (Html msg)
dateInputs =
    List.map
        (\inputType -> Textfield.new (Ds.label inputType) |> Textfield.view [ Attr.type_ inputType ])
        [ "text", "tel", "time", "date", "datetime-local", "month", "week" ]


required : List (Html msg)
required =
    [ Textfield.new
        (Ds.labelHtml
            [ Html.text "Hvor bor du?"
            , Tag.view [ Ds.color Color.warning, Attr.style "margin-inline-start" "var(--ds-size-2)" ]
                [ Html.text "Må fylles ut" ]
            ]
        )
        |> Textfield.view [ Attr.required True ]
    ]
