module Stories.Select exposing (Model, Mountain, Msg, chapter, init, update)

{-| `select.stories.tsx`, story for story.
-}

import Designsystemet.Field as Field
import Designsystemet.Label as Label
import Designsystemet.Select as Select
import Designsystemet.ValidationMessage as ValidationMessage
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)



-- MODEL


type Mountain
    = Everest
    | Aconcagua
    | Denali
    | Kilimanjaro
    | Elbrus
    | Vinson
    | PuncakJaya
    | Kosciuszko


type alias Model =
    { mountain : Maybe Mountain }


type Msg
    = PickedMountain Mountain


init : Model
init =
    { mountain = Nothing }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PickedMountain mountain ->
            ( { model | mountain = Just mountain }, Cmd.none )



-- CHAPTER


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Select", module_ = "Stories.Select", storybook = "komponenter-select" }
        [ Story.story "Preview" (preview model)
        , Story.story "Disabled" disabled
        , Story.story "ReadOnly" readOnly
        , Story.story "WithError" withError
        , Story.story "WithOptgroup" withOptgroup
        ]
        |> Story.withLayout Story.Padded


{-| The select holds one of your own values. While nothing is picked it shows
the placeholder, like the disabled first option in React's story.
-}
preview : Model -> List (Html Msg)
preview model =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg et fjell" ]
        , Select.single
            { options = [ Everest, Aconcagua, Denali, Kilimanjaro, Elbrus, Vinson, PuncakJaya, Kosciuszko ]
            , selected = model.mountain
            , toValue = mountainId
            , toLabel = mountainName
            , onSelect = PickedMountain
            , placeholder = "Velg et fjell …"
            }
            []
        ]
    ]


disabled : List (Html msg)
disabled =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg et fjell" ]
        , Select.view [ Attr.disabled True ] (mountainOptions ( "blank", "Velg …" ))
        ]
    ]


readOnly : List (Html msg)
readOnly =
    [ Field.view []
        [ Label.view [] [ Html.text "Kommune" ]
        , Select.view [ Attr.attribute "aria-readonly" "true" ]
            [ Select.option [ Attr.value "blank" ] [ Html.text "Velg …" ]
            , Select.option [ Attr.value "sogndal", Attr.selected True ] [ Html.text "Sogndal" ]
            ]
        ]
    ]


withError : List (Html msg)
withError =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg et fjell" ]
        , Select.view [ Attr.attribute "aria-invalid" "true" ] (mountainOptions ( "blank", "Velg …" ))
        , ValidationMessage.view [] [ Html.text "Velg et fjell" ]
        ]
    ]


withOptgroup : List (Html msg)
withOptgroup =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg en park" ]
        , Select.view []
            [ Select.optgroup { label = "Grünerløkka" }
                []
                [ Select.option [ Attr.value "sofienbergparken" ] [ Html.text "Sofienbergparken" ]
                , Select.option [ Attr.value "birkelunden" ] [ Html.text "Birkelunden" ]
                , Select.option [ Attr.value "olafryesplass" ] [ Html.text "Olaf Ryes plass" ]
                ]
            , Select.optgroup { label = "Sentrum" }
                []
                [ Select.option [ Attr.value "slottsparken" ] [ Html.text "Slottsparken" ]
                , Select.option [ Attr.value "studenterlunden" ] [ Html.text "Studenterlunden" ]
                ]
            , Select.optgroup { label = "Gamle Oslo" }
                []
                [ Select.option [ Attr.value "botsparken" ] [ Html.text "Botsparken" ]
                , Select.option [ Attr.value "klosterenga" ] [ Html.text "Klosterenga park" ]
                ]
            ]
        ]
    ]



-- MOUNTAINS


mountainId : Mountain -> String
mountainId mountain =
    case mountain of
        Everest ->
            "everest"

        Aconcagua ->
            "aconcagua"

        Denali ->
            "denali"

        Kilimanjaro ->
            "kilimanjaro"

        Elbrus ->
            "elbrus"

        Vinson ->
            "vinson"

        PuncakJaya ->
            "puncakjaya"

        Kosciuszko ->
            "kosciuszko"


mountainName : Mountain -> String
mountainName mountain =
    case mountain of
        Everest ->
            "Mount Everest"

        Aconcagua ->
            "Aconcagua"

        Denali ->
            "Denali"

        Kilimanjaro ->
            "Kilimanjaro"

        Elbrus ->
            "Elbrus"

        Vinson ->
            "Mount Vinson"

        PuncakJaya ->
            "Puncak Jaya"

        Kosciuszko ->
            "Mount Kosciuszko"


{-| A first option with this value and text, then one option per mountain, as
plain strings.
-}
mountainOptions : ( String, String ) -> List (Html msg)
mountainOptions ( firstValue, firstText ) =
    Select.option [ Attr.value firstValue ] [ Html.text firstText ]
        :: List.map
            (\mountain -> Select.option [ Attr.value (mountainId mountain) ] [ Html.text (mountainName mountain) ])
            [ Everest, Aconcagua, Denali, Kilimanjaro, Elbrus, Vinson, PuncakJaya, Kosciuszko ]
