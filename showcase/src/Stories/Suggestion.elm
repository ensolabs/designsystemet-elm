module Stories.Suggestion exposing (Model, Msg, Person, chapter, init, update)

{-| `suggestion.stories.tsx`, story for story.

`Suggestion` is experimental, as in React, and in Elm it is always
controlled: every story keeps its selection in the model. React's uncontrolled
stories (`Preview`, `DefaultValue`, `Multiple`, …) look and behave the same;
only where the selection lives differs.

The texts React leaves to CSS defaults are given here: "Valg" (the toggle),
"Fjern tekst" (the clear button) and "Tomt" (no matches).

-}

import Designsystemet.Button as Button
import Designsystemet.Details as Details
import Designsystemet.Divider as Divider
import Designsystemet.Field as Field
import Designsystemet.Label as Label
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Spinner as Spinner
import Designsystemet.Suggestion as Suggestion
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Process
import Showcase.Story as Story exposing (Chapter)
import Task
import Url



-- MODEL


type alias Person =
    { label : String
    , value : String
    }


type alias Model =
    { preview : Maybe String
    , controlledSingle : Maybe String
    , controlledCreatable : Maybe String
    , controlledMultiple : List String
    , person : Maybe Person
    , numberQuery : String
    , numberPick : Maybe String
    , numberQuery2 : String
    , numberPick2 : Maybe String
    , alwaysShowAll : Maybe String
    , countryQuery : String
    , countryRequest : Int
    , countries : Maybe (List String)
    , country : Maybe String
    , defaultValue : Maybe String
    , multiple : List String
    , inDetails : Maybe String
    , autoPlacement : Maybe String
    , creatable : List String
    , withoutToggle : List String
    }


init : Model
init =
    { preview = Nothing
    , controlledSingle = Nothing
    , controlledCreatable = Nothing
    , controlledMultiple = [ "Oslo" ]
    , person = List.head people
    , numberQuery = ""
    , numberPick = Nothing
    , numberQuery2 = ""
    , numberPick2 = Nothing
    , alwaysShowAll = Just "Sogndal"
    , countryQuery = ""
    , countryRequest = 0
    , countries = Nothing
    , country = Nothing
    , defaultValue = Just "Sogndal"
    , multiple = []
    , inDetails = Nothing
    , autoPlacement = Nothing
    , creatable = []
    , withoutToggle = []
    }


type Msg
    = PreviewPicked (Maybe String)
    | ControlledSinglePicked (Maybe String)
    | ControlledCreatablePicked (Maybe String)
    | ControlledMultiplePicked (List String)
    | PersonPicked (Maybe Person)
    | NumberTyped String
    | NumberPicked (Maybe String)
    | NumberTyped2 String
    | NumberPicked2 (Maybe String)
    | AlwaysShowAllPicked (Maybe String)
    | CountryTyped String
    | CountrySearchDue Int
    | CountriesFound (Result Http.Error (List String))
    | CountryPicked (Maybe String)
    | DefaultValuePicked (Maybe String)
    | MultiplePicked (List String)
    | InDetailsPicked (Maybe String)
    | AutoPlacementPicked (Maybe String)
    | CreatablePicked (List String)
    | WithoutTogglePicked (List String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PreviewPicked place ->
            ( { model | preview = place }, Cmd.none )

        ControlledSinglePicked place ->
            ( { model | controlledSingle = place }, Cmd.none )

        ControlledCreatablePicked place ->
            ( { model | controlledCreatable = place }, Cmd.none )

        ControlledMultiplePicked places ->
            ( { model | controlledMultiple = places }, Cmd.none )

        PersonPicked person ->
            ( { model | person = person }, Cmd.none )

        NumberTyped query ->
            ( { model | numberQuery = query }, Cmd.none )

        NumberPicked place ->
            ( { model | numberPick = place }, Cmd.none )

        NumberTyped2 query ->
            ( { model | numberQuery2 = query }, Cmd.none )

        NumberPicked2 place ->
            ( { model | numberPick2 = place }, Cmd.none )

        AlwaysShowAllPicked place ->
            ( { model | alwaysShowAll = place }, Cmd.none )

        CountryTyped query ->
            -- Wait until the user stops typing for half a second before asking.
            let
                request : Int
                request =
                    model.countryRequest + 1
            in
            ( { model | countryQuery = query, countryRequest = request, countries = Nothing }
            , Process.sleep 500 |> Task.perform (\_ -> CountrySearchDue request)
            )

        CountrySearchDue request ->
            if request == model.countryRequest && String.trim model.countryQuery /= "" then
                ( model, searchCountries model.countryQuery )

            else
                ( model, Cmd.none )

        CountriesFound result ->
            ( { model | countries = Just (Result.withDefault [] result) }, Cmd.none )

        CountryPicked country ->
            ( { model | country = country }, Cmd.none )

        DefaultValuePicked place ->
            ( { model | defaultValue = place }, Cmd.none )

        MultiplePicked places ->
            ( { model | multiple = places }, Cmd.none )

        InDetailsPicked place ->
            ( { model | inDetails = place }, Cmd.none )

        AutoPlacementPicked place ->
            ( { model | autoPlacement = place }, Cmd.none )

        CreatablePicked places ->
            ( { model | creatable = places }, Cmd.none )

        WithoutTogglePicked places ->
            ( { model | withoutToggle = places }, Cmd.none )


searchCountries : String -> Cmd Msg
searchCountries query =
    Http.get
        { url = "https://restcountries.com/v2/name/" ++ Url.percentEncode (String.trim query) ++ "?fields=name"
        , expect = Http.expectJson CountriesFound (Decode.list (Decode.field "name" Decode.string))
        }



-- CHAPTER


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Suggestion", module_ = "Stories.Suggestion", storybook = "komponenter-suggestion" }
        [ Story.story "Preview" (preview model)
        , Story.story "ControlledSingle" (controlledSingle model)
        , Story.story "ControlledCreatable" (controlledCreatable model)
        , Story.story "ControlledMultiple" (controlledMultiple model)
        , Story.story "ControlledIndependentLabelValue" (controlledIndependentLabelValue model)
        , Story.story "CustomFilterAlt1" (customFilterAlt1 model)
        , Story.story "CustomFilterAlt2" (customFilterAlt2 model)
        , Story.story "AlwaysShowAll" (alwaysShowAll model)
        , Story.story "FetchExternal" (fetchExternal model)
        , Story.story "DefaultValue" (defaultValue model)
        , Story.story "Multiple" (multiple model)
        , Story.story "InDetails" (inDetails model)
        , Story.story "AutoPlacementOnXAxis" (autoPlacementOnXAxis model)
        , Story.story "Creatable" (creatable model)
        , Story.story "WithoutToggleButton" (withoutToggleButton model)
        ]
        -- Upstream wraps every story in a decorator with this style.
        |> Story.withCustomStyles [ ( "min-height", "300px" ) ]


preview : Model -> List (Html Msg)
preview model =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg en destinasjon" ]
        , Suggestion.single
            { options = destinations
            , selected = model.preview
            , toValue = identity
            , toLabel = identity
            , onSelect = PreviewPicked
            }
            |> Suggestion.withOptionContent (\place -> [ Html.text place, Html.div [] [ Html.text "Kommune" ] ])
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
            |> Suggestion.view []
        ]
    ]


controlledSingle : Model -> List (Html Msg)
controlledSingle model =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg destinasjon" ]
        , Suggestion.single
            { options = destinations
            , selected = model.controlledSingle
            , toValue = identity
            , toLabel = identity
            , onSelect = ControlledSinglePicked
            }
            |> Suggestion.withOptionContent (\place -> [ Html.text place, Html.div [] [ Html.text "Kommune" ] ])
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
            |> Suggestion.view []
        ]
    , Divider.view [ Attr.style "margin-top" "var(--ds-size-4)" ]
    , Paragraph.view [ Attr.style "margin" "var(--ds-size-2) 0" ]
        [ Html.text "Valgte reisemål: ", Html.text (Maybe.withDefault "" model.controlledSingle) ]
    , Button.view [ Events.onClick (ControlledSinglePicked (Just "Sogndal")) ]
        [ Html.text "Sett reisemål til Sogndal" ]
    ]


{-| A typed place that isn't in the list becomes the selection itself.
-}
controlledCreatable : Model -> List (Html Msg)
controlledCreatable model =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg destinasjon" ]
        , Suggestion.single
            { options = destinations
            , selected = model.controlledCreatable
            , toValue = identity
            , toLabel = identity
            , onSelect = ControlledCreatablePicked
            }
            |> Suggestion.withOptionContent (\place -> [ Html.text place, Html.div [] [ Html.text "Kommune" ] ])
            |> Suggestion.withCreatable { template = "Legg til \"%s\"", onCreate = ControlledCreatablePicked << Just }
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.view []
        ]
    , Divider.view [ Attr.style "margin-top" "var(--ds-size-4)" ]
    , Paragraph.view [ Attr.style "margin" "var(--ds-size-2) 0" ]
        [ Html.text "Valgte reisemål: ", Html.text (Maybe.withDefault "" model.controlledCreatable) ]
    , Button.view [ Events.onClick (ControlledCreatablePicked (Just "Sogndal")) ]
        [ Html.text "Sett reisemål til Sogndal" ]
    ]


controlledMultiple : Model -> List (Html Msg)
controlledMultiple model =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg destinasjoner" ]
        , Suggestion.multiple
            { options = destinations
            , selected = model.controlledMultiple
            , toValue = identity
            , toLabel = identity
            , onChange = ControlledMultiplePicked
            }
            |> Suggestion.withOptionContent (\place -> [ Html.text place, Html.div [] [ Html.text "Kommune" ] ])
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
            |> Suggestion.view []
        ]
    , Divider.view [ Attr.style "margin-top" "var(--ds-size-4)" ]
    , Paragraph.view [ Attr.style "margin" "var(--ds-size-2) 0" ]
        [ Html.text "Valgte reisemål: ", Html.text (String.join ", " model.controlledMultiple) ]
    , Button.view [ Events.onClick (ControlledMultiplePicked [ "Sogndal", "Stavanger" ]) ]
        [ Html.text "Sett reisemål til Sogndal, Stavanger" ]
    ]


{-| The value (`#004`) and the label (`Lars`) differ. The selection is the
whole record.
-}
controlledIndependentLabelValue : Model -> List (Html Msg)
controlledIndependentLabelValue model =
    let
        encodePerson : Person -> Encode.Value
        encodePerson person =
            Encode.object
                [ ( "label", Encode.string person.label )
                , ( "value", Encode.string person.value )
                ]
    in
    [ Field.view []
        [ Label.view [] [ Html.text "Velg person" ]
        , Suggestion.single
            { options = people
            , selected = model.person
            , toValue = .value
            , toLabel = .label
            , onSelect = PersonPicked
            }
            |> Suggestion.withoutFiltering
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
            |> Suggestion.view []
        ]
    , Divider.view [ Attr.style "margin-top" "var(--ds-size-4)" ]
    , Html.div [ Attr.style "margin" "var(--ds-size-2) 0" ]
        [ Html.text "Valgt person:"
        , Html.pre
            [ Attr.style "font-size" "14px"
            , Attr.style "height" "100px"
            , Attr.style "white-space" "pre-wrap"
            ]
            [ Html.text
                (model.person
                    |> Maybe.map encodePerson
                    |> Maybe.withDefault Encode.null
                    |> Encode.encode 0
                )
            ]
        ]
    , Button.view [ Events.onClick (PersonPicked (List.head (List.drop 2 people))) ]
        [ Html.text "Sett Nina" ]
    ]


{-| Filtering is `List.filter` over the options passed in, so any rule works.
-}
customFilterAlt1 : Model -> List (Html Msg)
customFilterAlt1 model =
    [ Field.view []
        [ Label.view [] [ Html.text "Skriv inn et tall mellom 1-6" ]
        , Suggestion.single
            { options = placesAtNumber model.numberQuery
            , selected = model.numberPick
            , toValue = String.toLower
            , toLabel = identity
            , onSelect = NumberPicked
            }
            |> Suggestion.withoutFiltering
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
            |> Suggestion.view [ Events.onInput NumberTyped ]
        ]
    ]


customFilterAlt2 : Model -> List (Html Msg)
customFilterAlt2 model =
    [ Field.view []
        [ Label.view [] [ Html.text "Skriv inn et tall mellom 1-6" ]
        , Suggestion.single
            { options = placesAtNumber model.numberQuery2
            , selected = model.numberPick2
            , toValue = identity
            , toLabel = identity
            , onSelect = NumberPicked2
            }
            |> Suggestion.withoutFiltering
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
            |> Suggestion.view [ Events.onInput NumberTyped2 ]
        ]
    ]


alwaysShowAll : Model -> List (Html Msg)
alwaysShowAll model =
    [ Field.view []
        [ Label.view [] [ Html.text "Viser alle options også når valgt" ]
        , Suggestion.single
            { options = destinations
            , selected = model.alwaysShowAll
            , toValue = identity
            , toLabel = identity
            , onSelect = AlwaysShowAllPicked
            }
            |> Suggestion.withoutFiltering
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
            |> Suggestion.view []
        ]
    ]


{-| The options come from a server: `update` waits until the user stops typing,
fetches, and the list shows what came back. React also sets screen reader
texts for the hit count ("%d country"); here the English defaults from the CSS
apply, through `lang="en"`.
-}
fetchExternal : Model -> List (Html Msg)
fetchExternal model =
    let
        withEmpty : Suggestion.Suggestion String Msg -> Suggestion.Suggestion String Msg
        withEmpty =
            if String.isEmpty model.countryQuery then
                identity

            else
                let
                    emptyMessage : List (Html Msg)
                    emptyMessage =
                        case model.countries of
                            Just _ ->
                                [ Html.text "Ingen treff" ]

                            Nothing ->
                                [ Html.span [ Attr.style "display" "flex", Attr.style "align-items" "center", Attr.style "gap" "8px" ]
                                    [ Spinner.decorative [ Spinner.size Spinner.Small ], Html.text "Laster..." ]
                                ]
                in
                Suggestion.withEmptyMessage emptyMessage
    in
    [ Field.view [ Attr.attribute "lang" "en" ]
        [ Label.view [] [ Html.text "Search for countries (in english)" ]
        , Suggestion.single
            { options = Maybe.withDefault [] model.countries
            , selected = model.country
            , toValue = identity
            , toLabel = identity
            , onSelect = CountryPicked
            }
            |> Suggestion.withoutFiltering
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> withEmpty
            |> Suggestion.view [ Attr.type_ "search", Events.onInput CountryTyped ]
        ]
    ]


defaultValue : Model -> List (Html Msg)
defaultValue model =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg en destinasjon" ]
        , Suggestion.single
            { options = destinations
            , selected = model.defaultValue
            , toValue = identity
            , toLabel = identity
            , onSelect = DefaultValuePicked
            }
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
            |> Suggestion.view []
        ]
    ]


multiple : Model -> List (Html Msg)
multiple model =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg en destinasjon" ]
        , Suggestion.multiple
            { options = destinations
            , selected = model.multiple
            , toValue = identity
            , toLabel = identity
            , onChange = MultiplePicked
            }
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
            |> Suggestion.view []
        ]
    ]


inDetails : Model -> List (Html Msg)
inDetails model =
    [ Details.view
        { summary = [ Html.text "Åpne details som har overflow: clip;" ]
        , content =
            [ Field.view []
                [ Label.view [] [ Html.text "Velg en destinasjon" ]
                , Suggestion.single
                    { options = destinations
                    , selected = model.inDetails
                    , toValue = identity
                    , toLabel = identity
                    , onSelect = InDetailsPicked
                    }
                    |> Suggestion.withToggle { label = "Valg" }
                    |> Suggestion.withClear { label = "Fjern tekst" }
                    |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
                    |> Suggestion.view [ Attr.autofocus True ]
                ]
            ]
        }
        []
    ]


autoPlacementOnXAxis : Model -> List (Html Msg)
autoPlacementOnXAxis model =
    [ Html.div [ Attr.style "padding-top" "700px" ]
        [ Field.view []
            [ Label.view [] [ Html.text "Velg en destinasjon" ]
            , Suggestion.single
                { options = destinations
                , selected = model.autoPlacement
                , toValue = identity
                , toLabel = identity
                , onSelect = AutoPlacementPicked
                }
                |> Suggestion.withToggle { label = "Valg" }
                |> Suggestion.withClear { label = "Fjern tekst" }
                |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
                |> Suggestion.view [ Attr.autofocus True ]
            ]
        ]
    ]


{-| A typed place that isn't in the list is added to the selection.
-}
creatable : Model -> List (Html Msg)
creatable model =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg eller legg til en destinasjon" ]
        , Suggestion.multiple
            { options = destinations
            , selected = model.creatable
            , toValue = identity
            , toLabel = identity
            , onChange = CreatablePicked
            }
            |> Suggestion.withCreatable
                { template = "Legg til \"%s\""
                , onCreate = \place -> CreatablePicked (model.creatable ++ [ place ])
                }
            |> Suggestion.withToggle { label = "Valg" }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.view []
        ]
    ]


withoutToggleButton : Model -> List (Html Msg)
withoutToggleButton model =
    [ Field.view []
        [ Label.view [] [ Html.text "Velg eller legg til en destinasjon" ]
        , Suggestion.multiple
            { options = destinations
            , selected = model.withoutToggle
            , toValue = identity
            , toLabel = identity
            , onChange = WithoutTogglePicked
            }
            |> Suggestion.withCreatable
                { template = "Legg til \"%s\""
                , onCreate = \place -> WithoutTogglePicked (model.withoutToggle ++ [ place ])
                }
            |> Suggestion.withClear { label = "Fjern tekst" }
            |> Suggestion.view []
        ]
    ]



-- DATA


destinations : List String
destinations =
    [ "Sogndal", "Oslo", "Brønnøysund", "Stavanger", "Trondheim", "Bergen", "Lillestrøm" ]


people : List Person
people =
    [ { label = "Lars", value = "#004" }
    , { label = "James", value = "#007" }
    , { label = "Nina", value = "#113" }
    , { label = "Tove", value = "#110" }
    ]


{-| All places while nothing is typed, otherwise the one at that position
(counting from 1).
-}
placesAtNumber : String -> List String
placesAtNumber query =
    case String.toInt (String.trim query) of
        Just number ->
            destinations |> List.drop (number - 1) |> List.take 1

        Nothing ->
            if String.isEmpty (String.trim query) then
                destinations

            else
                []
