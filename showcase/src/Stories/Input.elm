module Stories.Input exposing (Model, Msg, chapter, init, update)

{-| `input.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Divider as Divider
import Designsystemet.Field as Field
import Designsystemet.Heading as Heading
import Designsystemet.Input as Input
import Designsystemet.Label as Label
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Size as Size exposing (Size)
import Designsystemet.ValidationMessage as ValidationMessage
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
    Story.chapter { title = "Input", module_ = "Stories.Input", storybook = "komponenter-input" }
        [ Story.story "Preview" preview
        , Story.story "HtmlSize" htmlSize
        , Story.story "Controlled" (controlled model)
        , Story.story "Text" text
        , Story.story "Radio" radio
        , Story.story "Checkbox" checkbox
        , Story.story "Switch" switch
        ]
        -- Upstream wraps every story in a decorator with these styles. (The
        -- Checkbox and Switch stories also set `display: grid` around it,
        -- which has no visible effect on a single child.)
        |> Story.withCustomStyles [ ( "display", "flex" ), ( "gap", "var(--ds-size-2)" ), ( "flex-direction", "column" ) ]


preview : List (Html msg)
preview =
    [ Input.view [ Attr.name "inputs", Attr.attribute "aria-label" "input" ] ]


htmlSize : List (Html msg)
htmlSize =
    [ Field.view []
        [ Label.view [] [ Html.text "Input with size" ]
        , Input.view [ Attr.size 10 ]
        ]
    ]


controlled : Model -> List (Html Msg)
controlled model =
    [ Field.view []
        [ Label.view [] [ Html.text "Kontroller meg!" ]
        , Input.view [ Attr.value model.value, Events.onInput ValueChanged ]
        ]
    , Html.div []
        [ Divider.view []
        , Paragraph.view [ Attr.style "margin" "var(--ds-size-2) 0" ]
            [ Html.text "Du har skrevet inn: ", Html.text model.value ]
        , Button.view [ Events.onClick (ValueChanged "Kake") ] [ Html.text "Jeg vil ha Kake" ]
        ]
    ]


text : List (Html msg)
text =
    let
        states : List ( String, List (Html.Attribute msg) )
        states =
            [ ( "Default", [] )
            , ( "Disabled", [ Attr.disabled True ] )
            , ( "Invalid", [ Attr.attribute "aria-invalid" "true" ] )
            , ( "Read-only", [ Attr.readonly True ] )
            ]

        field : Size -> ( String, List (Html.Attribute msg) ) -> Html msg
        field size ( label, attributes ) =
            Field.view []
                (Label.view [] [ Html.text label ]
                    :: Input.view
                        (Attr.value "Value"
                            :: Attr.name (Size.toString size ++ "-" ++ String.toLower label)
                            :: Ds.size size
                            :: attributes
                        )
                    :: (if label == "Invalid" then
                            [ ValidationMessage.view [] [ Html.text "Feilmelding" ] ]

                        else
                            []
                       )
                )
    in
    [ Html.div [] (List.map (statesInSize 4 (\size -> List.map (field size) states)) sizes) ]


radio : List (Html msg)
radio =
    let
        states : List ( String, List (Html.Attribute msg) )
        states =
            [ ( "Default", [] )
            , ( "Checked", [ Attr.checked True ] )
            , ( "Disabled", [ Attr.disabled True ] )
            , ( "Disabled checked", [ Attr.disabled True, Attr.checked True ] )
            , ( "Invalid", [ Attr.attribute "aria-invalid" "true" ] )
            , ( "Invalid checked", [ Attr.attribute "aria-invalid" "true", Attr.checked True ] )
            , ( "Read-only", [ Attr.readonly True ] )
            , ( "Read-only checked", [ Attr.readonly True, Attr.checked True ] )
            ]

        -- The states come in pairs, so each pair shares a name.
        field : Size -> ( String, List (Html.Attribute msg) ) -> Html msg
        field size ( label, attributes ) =
            Field.view []
                [ Input.view
                    (Attr.type_ "radio"
                        :: Attr.name (Size.toString size ++ "-" ++ firstWord label)
                        :: attributes
                    )
                , Label.view [] [ Html.text label ]
                ]
    in
    [ Html.div [] (List.map (statesInSize 2 (\size -> List.map (field size) states)) sizes) ]


checkbox : List (Html msg)
checkbox =
    let
        states : List ( String, List (Html.Attribute msg) )
        states =
            [ ( "Default", [] )
            , ( "Checked", [ Attr.checked True ] )
            , ( "Indeterminate", [ Input.indeterminate ] )
            , ( "Disabled", [ Attr.disabled True ] )
            , ( "Disabled checked", [ Attr.disabled True, Attr.checked True ] )
            , ( "Disabled indeterminate", [ Attr.disabled True, Input.indeterminate ] )
            , ( "Invalid", [ Attr.attribute "aria-invalid" "true" ] )
            , ( "Invalid checked", [ Attr.attribute "aria-invalid" "true", Attr.checked True ] )
            , ( "Invalid indeterminate", [ Attr.attribute "aria-invalid" "true", Input.indeterminate ] )
            , ( "Read-only", [ Attr.readonly True ] )
            , ( "Read-only checked", [ Attr.readonly True, Attr.checked True ] )
            , ( "Read-only indeterminate", [ Attr.readonly True, Input.indeterminate ] )
            ]

        field : Size -> ( String, List (Html.Attribute msg) ) -> Html msg
        field size ( label, attributes ) =
            Field.view []
                [ Input.view
                    (Attr.type_ "checkbox"
                        :: Attr.name (Size.toString size ++ "-" ++ kebab label)
                        :: attributes
                    )
                , Label.view [] [ Html.text label ]
                ]
    in
    List.map (statesInSize 3 (\size -> List.map (field size) states)) sizes


switch : List (Html msg)
switch =
    let
        states : List ( String, List (Html.Attribute msg) )
        states =
            [ ( "Default", [] )
            , ( "Checked", [ Attr.checked True ] )
            , ( "Disabled", [ Attr.disabled True ] )
            , ( "Disabled checked", [ Attr.disabled True, Attr.checked True ] )
            , ( "Read-only", [ Attr.readonly True ] )
            , ( "Read-only checked", [ Attr.readonly True, Attr.checked True ] )
            ]

        field : Size -> ( String, List (Html.Attribute msg) ) -> Html msg
        field size ( label, attributes ) =
            Field.view []
                [ Input.view
                    (Attr.type_ "checkbox"
                        :: Attr.attribute "role" "switch"
                        :: Attr.name (Size.toString size ++ "-" ++ kebab label)
                        :: attributes
                    )
                , Label.view [] [ Html.text label ]
                ]
    in
    List.map (statesInSize 2 (\size -> List.map (field size) states)) sizes



-- HELPERS


sizes : List ( Size, String )
sizes =
    [ ( Size.sm, "Small" ), ( Size.md, "Medium" ), ( Size.lg, "Large" ) ]


{-| One size's heading and fields, in a grid with this many columns.
-}
statesInSize : Int -> (Size -> List (Html msg)) -> ( Size, String ) -> Html msg
statesInSize columns fields ( size, name ) =
    Html.div
        [ Ds.size size
        , Attr.style "display" "grid"
        , Attr.style "grid-template-columns" ("repeat(" ++ String.fromInt columns ++ ", 1fr)")
        , Attr.style "gap" "1rem"
        , Attr.style "max-width" "90vw"
        ]
        (Heading.h2 [ Heading.size Heading.TwoExtraSmall, Attr.style "grid-column" "1 / -1" ] [ Html.text name ]
            :: fields size
        )


firstWord : String -> String
firstWord =
    String.words >> List.head >> Maybe.withDefault ""


{-| `"Disabled checked"` → `"disabled-checked"`
-}
kebab : String -> String
kebab =
    String.toLower >> String.replace " " "-"
