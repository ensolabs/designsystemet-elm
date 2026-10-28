module Stories.Alert exposing (Model, Msg, Visibility, chapter, init, update)

{-| `alert.stories.tsx`, story for story.

The two live-region stories show or hide an alert, so this chapter keeps
state.

-}

import Designsystemet as Ds
import Designsystemet.Alert as Alert
import Designsystemet.Button as Button
import Designsystemet.Color exposing (Severity(..))
import Designsystemet.Heading as Heading
import Designsystemet.Link as Link
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Size as Size
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Showcase.Story as Story exposing (Chapter)



-- STATE


type Visibility
    = Shown
    | Hidden


type alias Model =
    { wrongLiveRegion : Visibility
    , correctLiveRegion : Visibility
    }


type Msg
    = ToggledWrongLiveRegion
    | ToggledCorrectLiveRegion


init : Model
init =
    { wrongLiveRegion = Hidden, correctLiveRegion = Hidden }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggledWrongLiveRegion ->
            { model | wrongLiveRegion = toggle model.wrongLiveRegion }

        ToggledCorrectLiveRegion ->
            { model | correctLiveRegion = toggle model.correctLiveRegion }


toggle : Visibility -> Visibility
toggle visibility =
    case visibility of
        Shown ->
            Hidden

        Hidden ->
            Shown



-- STORIES


chapter : Model -> Chapter Msg
chapter model =
    let
        liveRegionStyles : List ( String, String )
        liveRegionStyles =
            [ ( "display", "flex" ), ( "flex-direction", "column" ), ( "gap", "var(--ds-size-2)" ), ( "align-items", "start" ) ]
    in
    Story.chapter { title = "Alert", module_ = "Stories.Alert", storybook = "komponenter-alert" }
        [ Story.story "Preview" preview
        , Story.story "VariantInfo" variantInfo
        , Story.story "VariantSuccess" variantSuccess
        , Story.story "VariantWarning" variantWarning
        , Story.story "VariantDanger" variantDanger
        , Story.story "MedHeading" medHeading
        , Story.story "MedKunHeading" medKunHeading
        , Story.story "MedLenke" medLenke
        , Story.story "UtenAria" utenAria
        , Story.story "WrongLiveRegionReact" (wrongLiveRegionReact model.wrongLiveRegion)
            |> Story.withStoryCustomStyles liveRegionStyles
        , Story.story "CorrectLiveRegionReact" (correctLiveRegionReact model.correctLiveRegion)
            |> Story.withStoryCustomStyles liveRegionStyles
        , Story.story "MedAria" medAria
        ]
        |> Story.withLayout Story.Padded


preview : List (Html msg)
preview =
    [ Alert.view Info [] [ Html.text "En beskjed det er viktig at brukeren ser" ] ]


variantInfo : List (Html msg)
variantInfo =
    [ Alert.view Info
        [ Attr.attribute "role" "status" ]
        [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "Har du husket å bestille passtime?" ]
        , Paragraph.view []
            [ Html.text "Det er lange køer for å bestille pass om dagen, det kan være lurt å bestille i god tid før du skal reise." ]
        ]
    ]


variantSuccess : List (Html msg)
variantSuccess =
    [ Alert.view Success
        [ Attr.attribute "role" "status" ]
        [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "Gratulerer! Du kan nå starte selskapet ditt" ]
        , Paragraph.view []
            [ Html.text "Det ser ut til at regnestykket går i pluss og at du har det som skal til for å starte selskapet ditt." ]
        ]
    ]


variantWarning : List (Html msg)
variantWarning =
    [ Alert.view Warning
        [ Attr.attribute "role" "status" ]
        [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "Vi har tekniske problemer" ]
        , Paragraph.view []
            [ Html.text "Det gjør at du kan bli avbrutt mens du fyller ut skjemaet. Vi jobber med å rette problemene." ]
        ]
    ]


variantDanger : List (Html msg)
variantDanger =
    [ Alert.view Danger
        [ Attr.attribute "role" "alert" ]
        [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "Det har skjedd en feil" ]
        , Paragraph.view []
            [ Html.text "Vi klarer ikke å hente informasjonen du ser etter akkurat nå. Prøv igjen litt senere. Hvis vi fortsatt ikke klarer å vise informasjonen du trenger, tar du kontakt med kundeservice på telefon 85 44 32 66." ]
        ]
    ]


medHeading : List (Html msg)
medHeading =
    [ Alert.view Info
        [ Attr.attribute "role" "status" ]
        [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "Har du husket å bestille passtime?" ]
        , Paragraph.view []
            [ Html.text "Det er lange køer for å bestille pass om dagen, det kan være lurt å bestille i god tid om du trenger pass til sommeren." ]
        ]
    ]


medKunHeading : List (Html msg)
medKunHeading =
    [ Alert.view Warning
        [ Attr.attribute "role" "status" ]
        [ Paragraph.view [] [ Html.text "Du har 7 dager igjen på å fullføre søknaden." ] ]
    ]


medLenke : List (Html msg)
medLenke =
    [ Alert.view Warning
        [ Attr.attribute "role" "status" ]
        [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "Søknadsfristen går ut om 3 dager" ]
        , Paragraph.view []
            [ Html.text "Fristen for å søke opptak til utdanning er 15. april. "
            , Link.view [ Attr.href "https://designsystemet.no/" ] [ Html.text "Søk nå" ]
            ]
        ]
    ]


utenAria : List (Html msg)
utenAria =
    [ Alert.view Warning
        [ Attr.attribute "role" "status" ]
        [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "Nedetid" ]
        , Paragraph.view []
            [ Html.text "I natt klokken 00:00 til 02:00 vil nettsiden være nede på grunn av vedlikehold." ]
        ]
    ]


wrongLiveRegionReact : Visibility -> List (Html Msg)
wrongLiveRegionReact visibility =
    [ case visibility of
        Shown ->
            -- Wrong: role="alert" is on the alert itself, which appears with
            -- its content already in it, so screen readers may stay silent.
            Alert.view Warning
                [ Attr.attribute "role" "alert" ]
                [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
                    [ Html.text "Vi klarer ikke lagre skjemaet" ]
                , Paragraph.view []
                    [ Html.text "Vi har mistet forbindelsen med serveren og får ikke lagret skjemaet. Vent litt og prøv en gang til." ]
                ]

        Hidden ->
            Html.text ""
    , Button.view [ Ds.size Size.sm, Button.secondary, Events.onClick ToggledWrongLiveRegion ]
        [ Html.text (toggleLabel visibility) ]
    ]


correctLiveRegionReact : Visibility -> List (Html Msg)
correctLiveRegionReact visibility =
    [ -- Right: role="alert" is on a container that is always there, and the
      -- alert appears inside it.
      Html.div [ Attr.attribute "role" "alert" ]
        [ case visibility of
            Shown ->
                Alert.view Warning
                    []
                    [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
                        [ Html.text "Vi klarer ikke lagre skjemaet" ]
                    , Paragraph.view []
                        [ Html.text "Vi har mistet forbindelsen med serveren og får ikke lagret skjemaet. Vent litt og prøv en gang til." ]
                    ]

            Hidden ->
                Html.text ""
        ]
    , Button.view [ Ds.size Size.sm, Button.secondary, Events.onClick ToggledCorrectLiveRegion ]
        [ Html.text (toggleLabel visibility) ]
    ]


toggleLabel : Visibility -> String
toggleLabel visibility =
    case visibility of
        Shown ->
            "Skjul varsel"

        Hidden ->
            "Handling som fører til varsel"


medAria : List (Html msg)
medAria =
    [ Alert.view Danger
        [ Attr.attribute "role" "alert" ]
        [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "Vi klarer ikke lagre skjemaet" ]
        , Paragraph.view []
            [ Html.text "Vi har mistet forbindelsen med serveren og får ikke lagret skjemaet. Vent litt og prøv en gang til." ]
        ]
    ]
