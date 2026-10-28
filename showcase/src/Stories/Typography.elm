module Stories.Typography exposing (Model, Msg, chapter, init, update)

{-| `typography.stories.tsx`, story for story.

Each story has a size picker above the text (React's story decorator), so the
chapter keeps the chosen `data-size` for each.

Differences from the React stories (they show up in the markup diff):

  - EksempelTekstDark and EksempelTekstAutoSize: upstream's `.extend` both
    inherits the size-picker decorator and adds it again, so React renders
    two nested pickers. Here there is one, as intended.
  - The picked size is the `checked` DOM property of its radio button, not an
    attribute.

-}

import Designsystemet as Ds
import Designsystemet.Fieldset as Fieldset
import Designsystemet.Heading as Heading
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Size as Size exposing (Size)
import Designsystemet.ToggleGroup as ToggleGroup
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)



-- STATE


type alias Model =
    { eksempelTekst : Size
    , eksempelTekstDark : Size
    , eksempelTekstAutoSize : Size
    }


type Msg
    = ChangedEksempelTekstSize Size
    | ChangedEksempelTekstDarkSize Size
    | ChangedEksempelTekstAutoSizeSize Size


init : Model
init =
    { eksempelTekst = Size.md, eksempelTekstDark = Size.md, eksempelTekstAutoSize = Size.md }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangedEksempelTekstSize size ->
            { model | eksempelTekst = size }

        ChangedEksempelTekstDarkSize size ->
            { model | eksempelTekstDark = size }

        ChangedEksempelTekstAutoSizeSize size ->
            { model | eksempelTekstAutoSize = size }



-- STORIES


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Typography", module_ = "Stories.Typography", storybook = "komponenter-typography" }
        [ Story.story "EksempelTekst" (eksempelTekst model.eksempelTekst)
        , Story.story "EksempelTekstDark" (eksempelTekstDark model.eksempelTekstDark)
        , Story.story "EksempelTekstAutoSize" (eksempelTekstAutoSize model.eksempelTekstAutoSize)
        ]


eksempelTekst : Size -> List (Html Msg)
eksempelTekst size =
    [ withSizePicker { name = "eksempel-tekst", size = size, onChange = ChangedEksempelTekstSize } sampleText ]


eksempelTekstDark : Size -> List (Html Msg)
eksempelTekstDark size =
    [ Html.div [ Ds.colorScheme Ds.Dark ]
        [ withSizePicker { name = "eksempel-tekst-dark", size = size, onChange = ChangedEksempelTekstDarkSize } sampleText ]
    ]


eksempelTekstAutoSize : Size -> List (Html Msg)
eksempelTekstAutoSize size =
    -- The text follows the viewport width: `--ds-size` is the size mode, and
    -- an empty `data-size` makes the element pick it up.
    [ Html.node "style"
        []
        [ Html.text """.responsive-text {
    --ds-size: var(--ds-size--sm);

    @media (min-width: 600px) {
      --ds-size: var(--ds-size--md);
    }
    @media (min-width: 992px) {
      --ds-size: var(--ds-size--lg);
    }
  }""" ]
    , Html.div [ Attr.class "responsive-text", Attr.attribute "data-size" "" ]
        [ withSizePicker { name = "eksempel-tekst-auto-size", size = size, onChange = ChangedEksempelTekstAutoSizeSize } sampleText ]
    ]


{-| React's story decorator: a size picker, and the story in a `data-size`
of the picked size.
-}
withSizePicker : { name : String, size : Size, onChange : Size -> msg } -> List (Html msg) -> Html msg
withSizePicker { name, size, onChange } content =
    Html.div [ Attr.style "display" "flex", Attr.style "flex-direction" "column", Attr.style "gap" "var(--ds-size-4)" ]
        [ Html.div [ Ds.size Size.sm ]
            [ Fieldset.new [ Html.text "Størrelse ", Html.code [] [ Html.text "(data-size)" ] ]
                |> Fieldset.view []
                    [ ToggleGroup.controlled
                        { name = name
                        , label = "Tekststørrelse"
                        , toValue = Size.toString
                        , selected = size
                        , onSelect = onChange
                        }
                        []
                        (List.map (\option -> ToggleGroup.item option [ Html.text (Size.toString option) ])
                            [ Size.sm, Size.md, Size.lg ]
                        )
                    ]
            ]
        , Html.div [ Ds.size size ] content
        ]


{-| The text all three stories show.
-}
sampleText : List (Html msg)
sampleText =
    [ Heading.h1 [ Heading.size Heading.ExtraLarge, Attr.style "margin-bottom" "var(--ds-size-5)" ]
        [ Html.text "Samordnet registermelding (H1)" ]
    , Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-2)", Paragraph.size Paragraph.Large, Paragraph.long ]
        [ Html.text "Her kan du registrere nye virksomheter, som for eksempel enkeltpersonforetak, foreninger, aksjeselskap, ansvarlige selskap, samvirkeforetak og stiftelser. De aller fleste organisasjonsformene kan bruke denne tjenesten." ]
    , Heading.h2
        [ Heading.size Heading.Large
        , Attr.style "margin-top" "var(--ds-size-10)"
        , Attr.style "margin-bottom" "var(--ds-size-4)"
        ]
        [ Html.text "Når skal du bruke skjemaet? (H2)" ]
    , Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-5)" ]
        [ Html.text "Denne tjenesten kan du bruke for å melde opplysninger til Enhetsregisteret, Foretaksregisteret, Frivillighetsregisteret, NAV Aa-registeret, Virksomhets- og foretaksregisteret hos SSB, Stiftelsesregisteret og Skattedirektoratets register over upersonlige skattytere." ]
    , Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-5)" ]
        [ Html.text "Hvis du for eksempel skal registrere et nytt aksjeselskap, en forening eller et enkeltpersonforetak, er det denne tjenesten du skal bruke. Det samme gjelder når du skal melde endringer av adresse, styremedlemmer, navn eller telefonnummer for en virksomhet som allerede er registrert." ]
    , Heading.h3
        [ Heading.size Heading.Medium
        , Attr.style "margin-top" "var(--ds-size-8)"
        , Attr.style "margin-bottom" "var(--ds-size-3)"
        ]
        [ Html.text "Signering (H3)" ]
    , Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-5)" ]
        [ Html.text "Når du skal signere meldingen vil du motta en signeringsoppgave i meldingsboksen din i Altinn. Meldingen blir ikke sendt til behandling før alle har signert." ]
    , Heading.h4
        [ Heading.size Heading.Small
        , Attr.style "margin-top" "var(--ds-size-7)"
        , Attr.style "margin-bottom" "var(--ds-size-3)"
        ]
        [ Html.text "Krav om rolle for signering (H4)" ]
    , Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-5)" ]
        [ Html.text "For å signere på vegne av en virksomhet, trenger du Altinn-rollen Signerer av Samordnet registermelding. Du kan se hvilke roller du har for en aktør på menypunktet Profil, Skjema og tjenester du har rettighet til. Om du ikke har disse rollene, må du få noen som har rollene til å delegere dem til deg." ]
    , Heading.h5
        [ Heading.size Heading.ExtraSmall
        , Attr.style "margin-top" "var(--ds-size-6)"
        , Attr.style "margin-bottom" "var(--ds-size-2)"
        ]
        [ Html.text "Personvern (H5)" ]
    , Paragraph.view [ Paragraph.short, Attr.style "margin-bottom" "var(--ds-size-5)" ]
        [ Html.text "Personvernerklæringen gir informasjon om hvilke personopplysninger vi behandler, hvordan disse blir behandlet og hvilke rettigheter du har." ]
    ]
