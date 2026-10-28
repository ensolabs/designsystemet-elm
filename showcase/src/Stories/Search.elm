module Stories.Search exposing (Model, Msg, chapter, init, update)

{-| `search.stories.tsx`, story for story.

React's clear and search buttons fall back to Norwegian texts; here the
texts are always given.

-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Divider as Divider
import Designsystemet.Field as Field
import Designsystemet.Label as Label
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Search as Search
import Designsystemet.Size as Size
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Showcase.Story as Story exposing (Chapter)


type alias Model =
    { query : String
    , formQuery : String
    , submitted : String
    }


type Msg
    = QueryChanged String
    | FormQueryChanged String
    | FormSubmitted


init : Model
init =
    { query = "", formQuery = "", submitted = "" }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        QueryChanged query ->
            ( { model | query = query }, Cmd.none )

        FormQueryChanged query ->
            ( { model | formQuery = query }, Cmd.none )

        FormSubmitted ->
            ( { model | submitted = model.formQuery }, Cmd.none )


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Search", module_ = "Stories.Search", storybook = "komponenter-search" }
        [ Story.story "Preview" preview
        , Story.story "Controlled" (controlled model)
        , Story.story "Variants" variants
        , Story.story "WithLabel" withLabel
        , Story.story "Form" (form model)
        ]


preview : List (Html msg)
preview =
    [ Search.new { clearLabel = "Fjern tekst" }
        |> Search.withButton { variant = Search.Primary, label = "Søk" }
        |> Search.view [ Attr.attribute "aria-label" "Søk", Attr.type_ "text" ]
    ]


controlled : Model -> List (Html Msg)
controlled model =
    [ Search.new { clearLabel = "Fjern tekst" }
        |> Search.withButton { variant = Search.Primary, label = "Søk" }
        |> Search.view
            [ Attr.type_ "text"
            , Attr.attribute "aria-label" "Søk"
            , Attr.value model.query
            , Events.onInput QueryChanged
            ]
    , Divider.view [ Attr.style "margin-top" "var(--ds-size-4)" ]
    , Paragraph.view [ Attr.style "margin" "var(--ds-size-2) 0" ]
        [ Html.text "Du har skrevet inn: ", Html.text model.query ]
    , Button.view [ Events.onClick (QueryChanged "Pizza") ] [ Html.text "Jeg vil ha Pizza" ]
    ]


variants : List (Html msg)
variants =
    [ Search.new { clearLabel = "Fjern tekst" }
        |> Search.view [ Attr.attribute "aria-label" "Søk" ]
    , Divider.view [ Attr.style "margin-top" "var(--ds-size-4)" ]
    , Search.new { clearLabel = "Fjern tekst" }
        |> Search.withButton { variant = Search.Primary, label = "Søk" }
        |> Search.view [ Attr.attribute "aria-label" "Søk", Attr.type_ "text" ]
    , Divider.view [ Attr.style "margin-top" "var(--ds-size-4)" ]
    , Search.new { clearLabel = "Fjern tekst" }
        |> Search.withButton { variant = Search.Secondary, label = "Søk" }
        |> Search.view [ Attr.attribute "aria-label" "Søk", Attr.type_ "text" ]
    ]


withLabel : List (Html msg)
withLabel =
    [ Field.view []
        [ Label.view [] [ Html.text "Søk etter katter" ]
        , Search.new { clearLabel = "Fjern tekst" }
            |> Search.withButton { variant = Search.Primary, label = "Søk" }
            |> Search.view [ Attr.name "cat-search", Attr.type_ "text" ]
        ]
    ]


form : Model -> List (Html Msg)
form model =
    [ Html.form [ Events.onSubmit FormSubmitted ]
        [ Search.new { clearLabel = "Fjern tekst" }
            |> Search.withButton { variant = Search.Primary, label = "Søk" }
            |> Search.view
                [ Attr.type_ "text"
                , Attr.attribute "aria-label" "Søk"
                , Attr.value model.formQuery
                , Events.onInput FormQueryChanged
                ]
        ]
    , Paragraph.view [ Ds.size Size.md, Attr.style "margin-top" "var(--ds-size-2)" ]
        [ Html.text "Submitted value: ", Html.text model.submitted ]
    ]
