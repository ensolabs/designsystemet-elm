module Stories.List exposing (chapter)

{-| `list.stories.tsx`, story for story.

`Designsystemet.List` is imported as `DsList`, so it doesn't shadow `elm/core`'s
`List`.

-}

import Designsystemet as Ds
import Designsystemet.Heading as Heading
import Designsystemet.Link as Link
import Designsystemet.List as DsList
import Designsystemet.Size as Size
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "List", module_ = "Stories.List", storybook = "komponenter-list" }
        [ Story.story "Preview" preview
        , Story.story "Sortert" sortert
        , Story.story "Usortert" usortert
        , Story.story "Innrykk" innrykk
        , Story.story "ListeMedLenker" listeMedLenker
        , Story.story "ListeMedOverskrift" listeMedOverskrift
            |> Story.withStoryCustomStyles [ ( "display", "flex" ), ( "gap", "2rem" ), ( "flex-wrap", "wrap" ) ]
        ]
        |> Story.withCustomStyles []


preview : List (Html msg)
preview =
    [ DsList.unordered []
        [ DsList.item [] [ Html.text "Bøyabreen" ]
        , DsList.item [] [ Html.text "Briksdalsbreen" ]
        , DsList.item [] [ Html.text "Nigardsbreen" ]
        ]
    ]


sortert : List (Html msg)
sortert =
    [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
        [ Html.text "Slik gjør du:" ]
    , DsList.ordered []
        [ DsList.item []
            [ Html.text "Tørk over kyllingfiletene før du krydrer og steker. Dette vil gi en finere stekeskorpe på kjøttet. Ikke bruk kjøkkenpapir som loer. Papirbiter i maten er ikke noe særlig." ]
        , DsList.item []
            [ Html.text "Ha salt og pepper på filetene og eventuelt annet krydder for ekstra smak. Hvitløkpepper, paprika eller provence kan gi en god smak!" ]
        , DsList.item []
            [ Html.text "Stek filetene på sterk varme i to minutter på hver side. Sett deretter på lokk og stek videre på svak varme i syv minutter på hver side." ]
        ]
    ]


usortert : List (Html msg)
usortert =
    [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
        [ Html.text "Foreningen har plikt til å ha revisor hvis de har" ]
    , DsList.unordered []
        [ DsList.item [] [ Html.text "et gjennomsnittlig antall ansatte som tilsvarer ti årsverk eller mer" ]
        , DsList.item [] [ Html.text "balansesum som er 27 millioner kroner eller mer" ]
        , DsList.item [] [ Html.text "driftsinntekter for sin samlede virksomhet på 7 millioner kroner eller mer" ]
        ]
    ]


innrykk : List (Html msg)
innrykk =
    let
        step : String -> Html msg -> Html msg
        step title subList =
            DsList.item []
                [ Heading.h3 [ Heading.size Heading.ExtraSmall, Attr.style "margin-block" "var(--ds-size-2)" ]
                    [ Html.text title ]
                , subList
                ]
    in
    [ Heading.h2 [ Attr.style "margin-block-end" "var(--ds-size-3)" ] [ Html.text "Slik søker du:" ]
    , DsList.unordered []
        [ step "Forbered dokumentasjon"
            (DsList.ordered []
                [ DsList.item [] [ Html.text "Pass eller annen gyldig ID" ]
                , DsList.item [] [ Html.text "Dokumentasjon på adresse" ]
                , DsList.item [] [ Html.text "Eventuell tilleggsdokumentasjon" ]
                ]
            )
        , step "Fyll ut søknadsskjema"
            (DsList.unordered []
                [ DsList.item [] [ Html.text "Oppgi personopplysninger" ]
                , DsList.item [] [ Html.text "Beskriv formålet med søknaden" ]
                , DsList.item [] [ Html.text "Last opp dokumentasjon" ]
                ]
            )
        , step "Send inn og følg opp"
            (DsList.unordered []
                [ DsList.item [] [ Html.text "Kontroller opplysningene før innsending" ]
                , DsList.item [] [ Html.text "Send inn søknaden" ]
                , DsList.item [] [ Html.text "Følg med på svar i innboksen din" ]
                ]
            )
        ]
    ]


listeMedLenker : List (Html msg)
listeMedLenker =
    [ DsList.unordered [ Attr.style "list-style" "none", Attr.style "padding" "0" ]
        [ DsList.item []
            [ Link.view [ Attr.href "https://www.designsystemet.no/no/fundamentals", Attr.target "_blank" ]
                [ Html.text "Grunnleggende" ]
            ]
        , DsList.item []
            [ Link.view [ Attr.href "https://www.designsystemet.no/no/best-practices", Attr.target "_blank" ]
                [ Html.text "God praksis" ]
            ]
        , DsList.item []
            [ Link.view [ Attr.href "https://www.designsystemet.no/no/patterns", Attr.target "_blank" ]
                [ Html.text "Mønstre" ]
            ]
        ]
    ]


listeMedOverskrift : List (Html msg)
listeMedOverskrift =
    let
        links : List (Html msg)
        links =
            [ DsList.item []
                [ Link.view [ Attr.href "https://www.designsystemet.no/no/fundamentals", Attr.target "_blank" ]
                    [ Html.text "Grunnleggende" ]
                ]
            , DsList.item []
                [ Link.view [ Attr.href "https://www.designsystemet.no/no/best-practices", Attr.target "_blank" ]
                    [ Html.text "God praksis" ]
                ]
            , DsList.item []
                [ Link.view [ Attr.href "https://www.designsystemet.no/no/patterns", Attr.target "_blank" ]
                    [ Html.text "Mønstre" ]
                ]
            ]
    in
    [ Html.div []
        [ Heading.h2 [ Heading.size Heading.TwoExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "List sm og Heading 2xs" ]
        , DsList.unordered [ Ds.size Size.sm ] links
        ]
    , Html.div []
        [ Heading.h2 [ Heading.size Heading.ExtraSmall, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "List md og Heading xs" ]
        , DsList.unordered [ Ds.size Size.md ] links
        ]
    , Html.div []
        [ Heading.h2 [ Heading.size Heading.Small, Attr.style "margin-bottom" "var(--ds-size-2)" ]
            [ Html.text "List lg og Heading sm" ]
        , DsList.unordered [ Ds.size Size.lg ] links
        ]
    ]
