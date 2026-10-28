module Stories.Details exposing (chapter)

{-| `details.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Card as Card
import Designsystemet.Color as Color
import Designsystemet.Details as Details
import Designsystemet.Heading as Heading
import Designsystemet.Link as Link
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Size as Size
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icons
import Showcase.Story as Story exposing (Chapter)
import Stories.Interactive.State exposing (Company(..), Model, Msg(..))


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Details", module_ = "Stories.Details", storybook = "komponenter-details" }
        [ Story.story "Preview" preview
        , Story.story "InCard" inCard
        , Story.story "InCardNested" inCardNested
        , Story.story "InCardWithColor" inCardWithColor
        , Story.story "Controlled" (controlled model)
        , Story.story "WithDirectContent" withDirectContent
        ]
        |> Story.withLayout Story.Padded


preview : List (Html msg)
preview =
    [ Details.view
        { summary = [ Html.text "Hvem kan registrere seg i Frivillighetsregisteret?" ]
        , content =
            [ Html.text "For å kunne bli registrert i Frivillighetsregisteret, må organisasjonen drive frivillig virksomhet. Det er bare foreninger, stiftelser og aksjeselskap som kan registreres. Virksomheten kan ikke dele ut midler til fysiske personer. Virksomheten må ha et styre." ]
        }
        []
    ]


inCard : List (Html msg)
inCard =
    [ Card.view [ Ds.color Color.neutral ]
        [ Details.view
            { summary = [ Html.text "Vedlegg" ]
            , content =
                [ Heading.h2 []
                    [ Html.a [ Attr.href "https://designsystemet.no", Attr.target "_blank", Attr.rel "noopener noreferrer" ]
                        [ Html.text "Heading with link" ]
                    ]
                , Html.p [] [ Html.text "Vedlegg 1, vedlegg 2, vedlegg 3" ]
                ]
            }
            []
        ]
    ]


inCardNested : List (Html msg)
inCardNested =
    [ Card.view [ Card.tinted ]
        [ Heading.h2 [] [ Html.text "Test-kort" ]
        , Card.view []
            [ Details.view { summary = [ Html.text "Test" ], content = [ Html.text "Test 2" ] } [] ]
        ]
    ]


inCardWithColor : List (Html msg)
inCardWithColor =
    let
        hunterNumber : List (Html msg)
        hunterNumber =
            [ Details.view
                { summary = [ Html.text "Hvordan får jeg tildelt et jegernummer?" ]
                , content = [ Html.text "Du vil automatisk få tildelt jegernummer og bli registrert i Jegerregisteret når du har bestått jegerprøven." ]
                }
                []
            , Details.view
                { summary = [ Html.text "Jeg har glemt jegernummeret mitt. Hvor finner jeg dette?" ]
                , content =
                    [ Paragraph.view []
                        [ Html.text "Du kan finne dette ved å logge inn på "
                        , Link.view [ Attr.href "https://minjegerside.brreg.no/" ] [ Html.text "Min side" ]
                        ]
                    ]
                }
                []
            ]
    in
    [ Card.view [ Ds.color Color.accent ] hunterNumber
    , Html.br [] []
    , Card.view [ Ds.color Color.accent, Card.tinted ] hunterNumber
    ]


{-| React toggles each one from its `onToggle`; here `onToggle` says which
state the user asked for, so `update` stores it.
-}
controlled : Model -> List (Html Msg)
controlled model =
    let
        allOpen : Bool
        allOpen =
            List.length model.openCompanies == 3

        company : Company -> String -> String -> Html Msg
        company value summary content =
            Details.controlled
                { open = List.member value model.openCompanies
                , onToggle = CompanyToggled value
                , summary = [ Html.text summary ]
                , content = [ Html.text content ]
                }
                []
    in
    [ Button.view [ Button.tertiary, Ds.size Size.sm, Events.onClick (AllCompaniesToggled (not allOpen)) ]
        (if allOpen then
            [ Icons.chevronDownUp [], Html.text "Lukk alle" ]

         else
            [ Icons.chevronUpDown [], Html.text "Åpne alle" ]
        )
    , Html.br [] []
    , company SoleProprietorship
        "Enkeltpersonforetak"
        "Skal du starte for deg selv? Enkeltpersonforetak er ofte den enkleste måten å etablere bedrift på. Denne organisasjonsformen har både fordeler og ulemper. Det gir deg stor grad av frihet, men kan også gi betydelig risiko fordi du har personlig ansvar for økonomien."
    , company LimitedCompany
        "Aksjeselskap (AS)"
        "Planlegger du å starte næringsvirksomhet alene eller sammen med andre? Innebærer næringsvirksomheten en økonomisk risiko? Vil du ha rettigheter som arbeidstaker og muligheten til at andre kan investere i selskapet ditt? Da kan aksjeselskap være en hensiktsmessig organisasjonsform."
    , company Partnership
        "Ansvarlig selskap (ANS/DA)"
        "Er dere minst to personer som skal starte opp egen virksomhet? Samarbeider du godt med den/de som du skal starte opp sammen med? Krever virksomheten få investeringer og tar du liten økonomisk risiko? Da kan du vurdere å etablere et ansvarlig selskap."
    ]


withDirectContent : List (Html msg)
withDirectContent =
    -- React puts the button straight in the details, without
    -- `Details.Content`. `content` always gets its own wrapper here.
    [ Card.view []
        [ Details.view { summary = [ Html.text "Vedlegg" ], content = [ Button.view [] [ Html.text "Knapp" ] ] } [] ]
    ]
