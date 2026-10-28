module Stories.Checkbox exposing (Channel, Education, Model, Msg, chapter, init, update)

{-| `checkbox.stories.tsx`, story for story.

React's `useCheckboxGroup` hook isn't needed in Elm: a group is a list of
values in the model, and each checkbox's `checked` and `onCheck` come from it.
The stories that only start with "E-post" checked leave the boxes to the
browser, like React's `defaultChecked`. (The hook also renders an empty,
hidden `ValidationMessage` when there is no error; here there is none.)

-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Checkbox as Checkbox
import Designsystemet.Chip as Chip
import Designsystemet.Divider as Divider
import Designsystemet.Field as Field
import Designsystemet.Fieldset as Fieldset
import Designsystemet.Input as Input
import Designsystemet.Pagination as Pagination
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Table as Table
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icons
import Showcase.Story as Story exposing (Chapter)



-- MODEL


type Education
    = Kindergarten
    | PrimarySchool
    | HighSchool


type Channel
    = Email
    | Phone
    | Sms


type alias Person =
    { id : Int
    , name : String
    , email : String
    , phone : String
    }


type alias Model =
    { education : List Education
    , selectedPeople : List Int
    , editingChannels : Bool
    , channels : List Channel
    , page : Int
    , selectedOnPages : List Int
    }


init : Model
init =
    { education = [ Kindergarten, HighSchool ]
    , selectedPeople = [ 2, 3 ]
    , editingChannels = False
    , channels = [ Email ]
    , page = 1
    , selectedOnPages = []
    }


type Msg
    = EducationChecked Education Bool
    | EducationCleared
    | PersonChecked Int Bool
    | AllPeopleChecked Bool
    | EditingChannels Bool
    | ChannelChecked Channel Bool
    | PageSelected Int
    | PersonOnPageChecked Int Bool
    | PageChecked (List Int) Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EducationChecked education isChecked ->
            ( { model | education = toggle education isChecked model.education }, Cmd.none )

        EducationCleared ->
            ( { model | education = [] }, Cmd.none )

        PersonChecked id isChecked ->
            ( { model | selectedPeople = toggle id isChecked model.selectedPeople }, Cmd.none )

        AllPeopleChecked isChecked ->
            ( { model
                | selectedPeople =
                    if isChecked then
                        List.map .id people

                    else
                        []
              }
            , Cmd.none
            )

        EditingChannels isEditing ->
            ( { model | editingChannels = isEditing }, Cmd.none )

        ChannelChecked channel isChecked ->
            ( { model | channels = toggle channel isChecked model.channels }, Cmd.none )

        PageSelected page ->
            ( { model | page = page }, Cmd.none )

        PersonOnPageChecked id isChecked ->
            ( { model | selectedOnPages = toggle id isChecked model.selectedOnPages }, Cmd.none )

        PageChecked ids isChecked ->
            ( { model | selectedOnPages = List.foldl (\id -> toggle id isChecked) model.selectedOnPages ids }, Cmd.none )


{-| Add or remove a value, keeping each value at most once.
-}
toggle : a -> Bool -> List a -> List a
toggle value isChecked values =
    List.filter ((/=) value) values
        ++ (if isChecked then
                [ value ]

            else
                []
           )



-- CHAPTER


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Checkbox", module_ = "Stories.Checkbox", storybook = "komponenter-checkbox" }
        [ Story.story "Preview" preview
        , Story.story "AriaLabel" ariaLabel
        , Story.story "Group" group
        , Story.story "OneOption" oneOption
        , Story.story "WithError" withError
        , Story.story "Controlled" (controlled model) |> Story.withStoryCustomStyles [ ( "display", "flex" ), ( "gap", "var(--ds-size-4)" ), ( "flex-direction", "column" ) ] |> Story.withStoryLayout Story.Padded
        , Story.story "ReadOnly" readOnly
        , Story.story "Disabled" disabled
        , Story.story "InTable" (inTable model)
        , Story.story "Conditional" (conditional model)
        , Story.story "InTableWithPagination" (inTableWithPagination model)
        , Story.story "ContentEx1" contentEx1
        , Story.story "ContentEx2" contentEx2
        , Story.story "ContentEx3" contentEx3
        , Story.story "hiddenLegend" hiddenLegend
        , Story.story "Outline" outline
        , Story.story "End" end
        ]


preview : List (Html msg)
preview =
    [ Checkbox.new (Ds.label "Checkbox label")
        |> Checkbox.withDescription [ Html.text "Description" ]
        |> Checkbox.view [ Attr.value "value" ]
    ]


ariaLabel : List (Html msg)
ariaLabel =
    [ Checkbox.new (Ds.ariaLabel "Checkbox") |> Checkbox.view [ Attr.value "value" ] ]


group : List (Html msg)
group =
    [ Fieldset.new [ Html.text "Hvordan vil du helst at vi skal kontakte deg?" ]
        |> Fieldset.withDescription [ Html.text "Velg alle alternativene som er relevante for deg." ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "E-post") |> Checkbox.view [ Attr.name "my-group", Attr.value "epost", Attr.checked True ]
            , Checkbox.new (Ds.label "Telefon") |> Checkbox.view [ Attr.name "my-group", Attr.value "telefon" ]
            , Checkbox.new (Ds.label "SMS") |> Checkbox.view [ Attr.name "my-group", Attr.value "sms" ]
            ]
    ]


oneOption : List (Html msg)
oneOption =
    [ Fieldset.new [ Html.text "Bekreft at du er over 18 år" ]
        |> Fieldset.withDescription
            [ Html.text "For at vi skal kunne sende deg opplysningen du ber om, må du bekrefte at du er myndig." ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "Jeg bekrefter at jeg er over 18 år")
                |> Checkbox.view [ Attr.value "samtykke" ]
            ]
    ]


withError : List (Html msg)
withError =
    [ Fieldset.new [ Html.text "Hvordan vil du helst at vi skal kontakte deg?" ]
        |> Fieldset.withDescription [ Html.text "Velg alle alternativene som er relevante for deg." ]
        |> Fieldset.withError (Just "Du må velge minst to kontaktalternativ")
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "E-post") |> Checkbox.view [ Attr.name "my-error", Attr.value "epost", Attr.checked True ]
            , Checkbox.new (Ds.label "Telefon") |> Checkbox.view [ Attr.name "my-error", Attr.value "telefon" ]
            , Checkbox.new (Ds.label "SMS") |> Checkbox.view [ Attr.name "my-error", Attr.value "sms" ]
            ]
    ]


controlled : Model -> List (Html Msg)
controlled model =
    let
        educationLabel : Education -> String
        educationLabel education =
            case education of
                Kindergarten ->
                    "Barnehage"

                PrimarySchool ->
                    "Grunnskole"

                HighSchool ->
                    "Videregående"

        educationValue : Education -> String
        educationValue education =
            case education of
                Kindergarten ->
                    "barnehage"

                PrimarySchool ->
                    "grunnskole"

                HighSchool ->
                    "videregaende"

        educationCheckbox : Education -> Html Msg
        educationCheckbox education =
            Checkbox.new (Ds.label (educationLabel education))
                |> Checkbox.view
                    [ Attr.name "my-controlled"
                    , Attr.value (educationValue education)
                    , Attr.checked (List.member education model.education)
                    , Events.onCheck (EducationChecked education)
                    ]

        filterChip : Education -> Html Msg
        filterChip education =
            Chip.removable { removeLabel = "Trykk for å fjerne" }
                [ Attr.attribute "aria-label" ("Slett " ++ educationLabel education)
                , Events.onClick (EducationChecked education False)
                ]
                [ Html.text (educationLabel education) ]
    in
    [ Fieldset.new [ Html.text "Utdanningsnivå" ]
        |> Fieldset.view [] (List.map educationCheckbox [ Kindergarten, PrimarySchool, HighSchool ])
    , Divider.view []
    , Paragraph.view [] [ Html.text "(Annet innhold)" ]
    , Divider.view []
    , Html.div [ Attr.style "display" "flex", Attr.style "gap" "var(--ds-size-2)" ]
        (if List.isEmpty model.education then
            [ Paragraph.view [] [ Html.text "Viser alt innhold" ] ]

         else
            Paragraph.view [] [ Html.text "Viser innhold for:" ]
                :: List.map filterChip model.education
        )
    , if List.isEmpty model.education then
        Html.text ""

      else
        Button.view
            [ Button.secondary
            , Attr.style "width" "fit-content"
            , Events.onClick EducationCleared
            ]
            [ Html.text "Tøm filtre" ]
    ]


readOnly : List (Html msg)
readOnly =
    [ Fieldset.new [ Html.text "Hvordan vil du helst at vi skal kontakte deg?" ]
        |> Fieldset.withDescription [ Html.text "Velg alle alternativene som er relevante for deg." ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "E-post") |> Checkbox.view [ Attr.name "my-readonly", Attr.value "epost", Attr.readonly True, Attr.checked True ]
            , Checkbox.new (Ds.label "Telefon") |> Checkbox.view [ Attr.name "my-readonly", Attr.value "telefon", Attr.readonly True ]
            , Checkbox.new (Ds.label "SMS") |> Checkbox.view [ Attr.name "my-readonly", Attr.value "sms", Attr.readonly True ]
            ]
    ]


disabled : List (Html msg)
disabled =
    [ Fieldset.new [ Html.text "Hvordan vil du helst at vi skal kontakte deg?" ]
        |> Fieldset.withDescription [ Html.text "Velg alle alternativene som er relevante for deg." ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "E-post") |> Checkbox.view [ Attr.name "my-disabled", Attr.value "epost", Attr.disabled True, Attr.checked True ]
            , Checkbox.new (Ds.label "Telefon") |> Checkbox.view [ Attr.name "my-disabled", Attr.value "telefon", Attr.disabled True ]
            , Checkbox.new (Ds.label "SMS") |> Checkbox.view [ Attr.name "my-disabled", Attr.value "sms", Attr.disabled True ]
            ]
    ]


inTable : Model -> List (Html Msg)
inTable model =
    let
        nameId : Person -> String
        nameId person =
            "in-table-" ++ String.fromInt person.id ++ "-name"

        personRow : Person -> Html Msg
        personRow person =
            Table.row []
                [ Table.cell []
                    [ Checkbox.new (Ds.labelledBy (nameId person))
                        |> Checkbox.view
                            [ Attr.name "in-table"
                            , Attr.value (String.fromInt person.id)
                            , Attr.checked (List.member person.id model.selectedPeople)
                            , Events.onCheck (PersonChecked person.id)
                            ]
                    ]
                , Table.cell [ Attr.id (nameId person) ] [ Html.text person.name ]
                , Table.cell [] [ Html.text person.email ]
                ]
    in
    [ Table.view []
        [ Html.colgroup []
            -- The first column only takes up the space it needs.
            [ Html.col [ Attr.style "width" "1px" ] []
            , Html.col [] []
            , Html.col [] []
            ]
        , Table.head []
            [ Table.row []
                [ Table.headerCell []
                    [ Checkbox.new (Ds.ariaLabel "Velg alle")
                        |> Checkbox.view (Attr.name "in-table" :: Attr.value "all" :: selectAll (List.map .id people) model.selectedPeople AllPeopleChecked)
                    ]
                , Table.headerCell [] [ Html.text "Navn" ]
                , Table.headerCell [] [ Html.text "E-post" ]
                ]
            ]
        , Table.body [] (List.map personRow people)
        ]
    ]


conditional : Model -> List (Html Msg)
conditional model =
    let
        channelValue : Channel -> String
        channelValue channel =
            case channel of
                Email ->
                    "epost"

                Phone ->
                    "telefon"

                Sms ->
                    "sms"

        channelCheckbox : ( Channel, String ) -> Html Msg
        channelCheckbox ( channel, label ) =
            Checkbox.new (Ds.label label)
                |> Checkbox.view
                    [ Attr.checked (List.member channel model.channels)
                    , Events.onCheck (ChannelChecked channel)
                    ]
    in
    Html.text "Dine kommunikasjonskanaler: "
        :: Html.text (String.join ", " (List.map channelValue model.channels))
        :: (if model.editingChannels then
                [ Button.view [ Events.onClick (EditingChannels False) ] [ Icons.floppydisk [], Html.text "Lagre" ]
                , Fieldset.new [ Html.text "Hvordan vil du helst at vi skal kontakte deg?" ]
                    |> Fieldset.withDescription [ Html.text "Velg alle alternativene som er relevante for deg." ]
                    |> Fieldset.view []
                        (List.map channelCheckbox [ ( Email, "E-post" ), ( Phone, "Telefon" ), ( Sms, "SMS" ) ])
                ]

            else
                [ Button.view [ Button.secondary, Events.onClick (EditingChannels True) ]
                    [ Icons.pencil [], Html.text "Rediger" ]
                ]
           )


inTableWithPagination : Model -> List (Html Msg)
inTableWithPagination model =
    let
        perPage : Int
        perPage =
            3

        totalPages : Int
        totalPages =
            ceiling (toFloat (List.length people) / toFloat perPage)

        onPage : List Person
        onPage =
            people |> List.drop ((model.page - 1) * perPage) |> List.take perPage

        personRow : Person -> Html Msg
        personRow person =
            Table.row []
                [ Table.cell []
                    [ Checkbox.new (Ds.ariaLabel ("Check " ++ String.fromInt person.id))
                        |> Checkbox.view
                            [ Attr.name "in-table-with-pagination"
                            , Attr.value (String.fromInt person.id)
                            , Attr.checked (List.member person.id model.selectedOnPages)
                            , Events.onCheck (PersonOnPageChecked person.id)
                            ]
                    ]
                , Table.cell [] [ Html.text person.name ]
                , Table.cell [] [ Html.text person.email ]
                , Table.cell [] [ Html.text person.phone ]
                ]
    in
    [ Html.div []
        [ Table.view []
            [ Table.head []
                [ Table.row []
                    [ Table.headerCell []
                        [ Checkbox.new (Ds.ariaLabel "Select all")
                            |> Checkbox.view
                                (Attr.name "in-table-with-pagination"
                                    :: Attr.value "all"
                                    :: selectAll (List.map .id onPage) model.selectedOnPages (PageChecked (List.map .id onPage))
                                )
                        ]
                    , Table.headerCell [] [ Html.text "Navn" ]
                    , Table.headerCell [] [ Html.text "Epost" ]
                    , Table.headerCell [] [ Html.text "Telefon" ]
                    ]
                ]
            , Table.body [] (List.map personRow onPage)
            ]
        , Pagination.buttons
            { current = model.page
            , total = totalPages
            , onSelect = PageSelected
            , labels =
                { navigation = "Bla i sider"
                , previous = "Forrige"
                , next = "Neste"
                , page = \page -> "Side " ++ String.fromInt page
                }
            }
            |> Pagination.withMaxVisible totalPages
            |> Pagination.view []
        ]
    ]


contentEx1 : List (Html msg)
contentEx1 =
    [ Fieldset.new [ Html.text "Hvor lenge har du jobbet i det offentlige?" ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "I under ett år") |> Checkbox.view [ Attr.value "0-3" ]
            , Checkbox.new (Ds.label "Fra 1-3 år") |> Checkbox.view [ Attr.value "1-3" ]
            , Checkbox.new (Ds.label "Mer enn 3 år") |> Checkbox.view [ Attr.value "3+" ]
            ]
    ]


contentEx2 : List (Html msg)
contentEx2 =
    [ Fieldset.new [ Html.text "Hva liker du best med jobben din?" ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "Jeg liker å jobbe med selvstendige oppgaver") |> Checkbox.view [ Attr.value "selvstendige" ]
            , Checkbox.new (Ds.label "Jeg elsker møter") |> Checkbox.view [ Attr.value "moter" ]
            , Checkbox.new (Ds.label "Lunsjen er best") |> Checkbox.view [ Attr.value "lunsj" ]
            , Checkbox.new (Ds.label "Jeg liker å møte kolleger") |> Checkbox.view [ Attr.value "kolleger" ]
            ]
    ]


contentEx3 : List (Html msg)
contentEx3 =
    [ Fieldset.new [ Html.text "Hva liker du best med jobben din?" ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "Selvstendige oppgaver") |> Checkbox.view [ Attr.value "selvstendige" ]
            , Checkbox.new (Ds.label "Møter") |> Checkbox.view [ Attr.value "moter" ]
            , Checkbox.new (Ds.label "Lunsj") |> Checkbox.view [ Attr.value "lunsj" ]
            , Checkbox.new (Ds.label "Kolleger") |> Checkbox.view [ Attr.value "kolleger" ]
            ]
    ]


hiddenLegend : List (Html msg)
hiddenLegend =
    [ Fieldset.new [ Html.text "Tekst for skjermleser" ]
        |> Fieldset.withLegendAttributes [ Attr.class "ds-sr-only" ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "Test av skjermleser legend") |> Checkbox.view [ Attr.value "selvstendige" ] ]
    ]


outline : List (Html msg)
outline =
    [ Fieldset.new [ Html.text "Using variant=\"outline\"" ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "with description")
                |> Checkbox.withDescription [ Html.text "description text" ]
                |> Checkbox.withFieldAttributes [ Field.outline ]
                |> Checkbox.view [ Attr.value "description" ]
            , Checkbox.new (Ds.label "Checked")
                |> Checkbox.withFieldAttributes [ Field.outline ]
                |> Checkbox.view [ Attr.value "checked", Attr.checked True ]
            , Checkbox.new (Ds.label "with error state")
                |> Checkbox.withError (Just "the error message")
                |> Checkbox.withFieldAttributes [ Field.outline ]
                |> Checkbox.view [ Attr.value "error" ]
            , Checkbox.new (Ds.label "disabled not checked")
                |> Checkbox.withFieldAttributes [ Field.outline ]
                |> Checkbox.view [ Attr.value "disabled", Attr.disabled True ]
            , Checkbox.new (Ds.label "disabled")
                |> Checkbox.withFieldAttributes [ Field.outline ]
                |> Checkbox.view [ Attr.value "disabled", Attr.disabled True, Attr.checked True ]
            , Checkbox.new (Ds.label "readonly not checked")
                |> Checkbox.withFieldAttributes [ Field.outline ]
                |> Checkbox.view [ Attr.value "readonly2", Attr.readonly True ]
            , Checkbox.new (Ds.label "readonly checked")
                |> Checkbox.withFieldAttributes [ Field.outline ]
                |> Checkbox.view [ Attr.value "readonly", Attr.readonly True, Attr.checked True ]
            ]
    ]


end : List (Html msg)
end =
    [ Fieldset.new [ Html.text "Hvordan vil du helst at vi skal kontakte deg?" ]
        |> Fieldset.withDescription [ Html.text "Velg alle alternativene som er relevante for deg." ]
        |> Fieldset.view []
            [ Checkbox.new (Ds.label "E-post")
                |> Checkbox.withFieldAttributes [ Field.position Field.End ]
                |> Checkbox.view [ Attr.name "my-end", Attr.value "epost", Attr.checked True ]
            , Checkbox.new (Ds.label "Telefon")
                |> Checkbox.withFieldAttributes [ Field.position Field.End ]
                |> Checkbox.view [ Attr.name "my-end", Attr.value "telefon" ]
            , Checkbox.new (Ds.label "SMS")
                |> Checkbox.withFieldAttributes [ Field.position Field.End ]
                |> Checkbox.view [ Attr.name "my-end", Attr.value "sms" ]
            ]
    ]



-- HELPERS


people : List Person
people =
    [ { id = 1, name = "Lise Nordmann", email = "lise@nordmann.no", phone = "68051156" }
    , { id = 2, name = "Kari Nordmann", email = "kari@nordmann.no", phone = "68059679" }
    , { id = 3, name = "Ola Nordmann", email = "ola@nordmann.no", phone = "68055731" }
    , { id = 4, name = "Per Nordmann", email = "per@nordmann.no", phone = "68059631" }
    ]


{-| The attributes of a "select all" checkbox: checked when all are, partly
checked when some are, and clicking it checks or unchecks them all.
-}
selectAll : List a -> List a -> (Bool -> msg) -> List (Html.Attribute msg)
selectAll all selected onCheck =
    let
        selectedCount : Int
        selectedCount =
            List.length (List.filter (\value -> List.member value selected) all)

        isAll : Bool
        isAll =
            not (List.isEmpty all) && selectedCount == List.length all
    in
    Attr.checked isAll
        :: Events.onCheck (\_ -> onCheck (not isAll))
        :: (if selectedCount > 0 && not isAll then
                [ Input.indeterminate ]

            else
                []
           )
