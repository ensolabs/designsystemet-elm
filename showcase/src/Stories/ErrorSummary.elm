module Stories.ErrorSummary exposing (Model, Msg, chapter, init, update)

{-| `error-summary.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.ErrorSummary as ErrorSummary
import Designsystemet.Textfield as Textfield
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Showcase.Story as Story exposing (Chapter)


type alias Model =
    { submitted : Bool }


type Msg
    = SubmitToggled


init : Model
init =
    { submitted = False }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitToggled ->
            ( { model | submitted = not model.submitted }, Cmd.none )


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "ErrorSummary", module_ = "Stories.ErrorSummary", storybook = "komponenter-errorsummary" }
        [ Story.story "Preview" preview
        , Story.story "WithForm" withForm
            -- Upstream wraps this story in a decorator with these styles.
            |> Story.withStoryCustomStyles [ ( "display", "grid" ), ( "align-items", "stretch" ), ( "gap", "var(--ds-size-4)" ) ]
        , Story.story "ShowHideReact" (showHideReact model)
        ]


{-| React links these to `#`. A summary is only useful when every error
points at its field, so here each has a field id.
-}
preview : List (Html msg)
preview =
    [ ErrorSummary.view
        { heading = "For å gå videre må du rette opp følgende feil:"
        , level = ErrorSummary.H2
        , errors =
            [ { field = ErrorSummary.fieldId "fodselsdato", message = "Fødselsdato kan ikke være etter år 2005" }
            , { field = ErrorSummary.fieldId "telefonnummer", message = "Telefonnummer kan kun inneholde siffer" }
            , { field = ErrorSummary.fieldId "epost", message = "E-post må være gyldig" }
            ]
        }
        []
    ]


{-| The same `FieldId` makes the summary's link and the input's `id`, and the
same list of errors feeds both the summary and each field's message.
-}
withForm : List (Html msg)
withForm =
    let
        firstName : ErrorSummary.FieldId
        firstName =
            ErrorSummary.fieldId "fornavn"

        phone : ErrorSummary.FieldId
        phone =
            ErrorSummary.fieldId "telefon"

        errors : List ErrorSummary.Error
        errors =
            [ { field = firstName, message = "Fornavn må være minst 2 tegn" }
            , { field = phone, message = "Telefonnummer kan kun inneholde siffer" }
            ]
    in
    [ Textfield.new (Ds.label "Fornavn")
        |> Textfield.withError (ErrorSummary.messageFor firstName errors)
        |> Textfield.view [ ErrorSummary.linkTarget firstName ]
    , Textfield.new (Ds.label "Telefon")
        |> Textfield.withError (ErrorSummary.messageFor phone errors)
        |> Textfield.view [ ErrorSummary.linkTarget phone, Attr.type_ "tel" ]
    , ErrorSummary.view
        { heading = "For å gå videre må du rette opp følgende feil:"
        , level = ErrorSummary.H2
        , errors = errors
        }
        []
    ]


{-| With no errors the summary renders nothing. When it appears,
`<ds-error-summary>` moves focus to itself, so there is no focus code here.
-}
showHideReact : Model -> List (Html Msg)
showHideReact model =
    [ Html.div
        [ Attr.style "display" "grid"
        , Attr.style "place-items" "center"
        , Attr.style "margin-bottom" "var(--ds-size-4)"
        ]
        [ Button.view [ Events.onClick SubmitToggled ]
            [ Html.text
                (if model.submitted then
                    "Skjul"

                 else
                    "Send inn skjema"
                )
            ]
        ]
    , ErrorSummary.view
        { heading = "For å gå videre må du rette opp følgende feil:"
        , level = ErrorSummary.H2
        , errors =
            if model.submitted then
                [ { field = ErrorSummary.fieldId "fornavn", message = "Fornavn må være minst 2 tegn" }
                , { field = ErrorSummary.fieldId "telefon", message = "Telefonnummer kan kun inneholde siffer" }
                ]

            else
                []
        }
        []
    ]
