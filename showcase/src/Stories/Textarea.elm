module Stories.Textarea exposing (Model, Msg, chapter, init, update)

{-| `textarea.stories.tsx`, story for story.

These stories use a `Label` with `for` next to a bare `Textarea`, without a
`Field` around them, so the label is linked by hand.

-}

import Designsystemet.Button as Button
import Designsystemet.Divider as Divider
import Designsystemet.Label as Label
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Textarea as Textarea
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
    { value = "" }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ValueChanged value ->
            ( { model | value = value }, Cmd.none )


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Textarea", module_ = "Stories.Textarea", storybook = "komponenter-textarea" }
        [ Story.story "Preview" preview
        , Story.story "FullWidth" fullWidth |> Story.withStoryCustomStyles [ ( "width", "auto" ) ] |> Story.withStoryLayout Story.Padded
        , Story.story "Controlled" (controlled model)
        ]
        -- Upstream wraps every story in a decorator with these styles.
        |> Story.withCustomStyles
            [ ( "display", "flex" ), ( "flex-direction", "column" ), ( "gap", "var(--ds-size-2)" ), ( "max-width", "100%" ), ( "width", "20rem" ) ]


preview : List (Html msg)
preview =
    [ Label.view [ Attr.for "my-textarea" ] [ Html.text "Label" ]
    , Textarea.view [ Attr.id "my-textarea", Attr.cols 40 ]
    ]


fullWidth : List (Html msg)
fullWidth =
    [ Label.view [ Attr.for "my-textarea-full" ] [ Html.text "Label" ]
    , Textarea.view [ Attr.id "my-textarea-full", Attr.cols 40 ]
    ]


controlled : Model -> List (Html Msg)
controlled model =
    [ Label.view [ Attr.for "my-textarea-controlled" ] [ Html.text "Kontroller meg!" ]
    , Textarea.view
        [ Attr.id "my-textarea-controlled"
        , Attr.cols 40
        , Attr.value model.value
        , Events.onInput ValueChanged
        ]
    , Divider.view [ Attr.style "margin-top" "var(--ds-size-4)" ]
    , Paragraph.view [ Attr.style "margin" "var(--ds-size-2) 0" ]
        [ Html.text "Du har skrevet inn: ", Html.text model.value ]
    , Button.view [ Events.onClick (ValueChanged "Pizza") ] [ Html.text "Jeg vil ha Pizza" ]
    ]
