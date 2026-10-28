module Stories.Card exposing (chapter)

{-| `card.stories.tsx`, story for story.

Differences from the React stories (they show up in the markup diff):

  - Variants: React writes `data-variant="default"`, which looks the same as
    no variant; the package only has `Card.tinted`.
  - Media and Video: the `iframe`s leave out upstream's Chromatic-only
    `data-chromatic="ignore"`.

-}

import Designsystemet as Ds
import Designsystemet.Card as Card
import Designsystemet.Color as Color exposing (Color)
import Designsystemet.Heading as Heading
import Designsystemet.Link as Link
import Designsystemet.Paragraph as Paragraph
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)
import Theme


chapter : Chapter msg
chapter =
    Story.chapter { title = "Card", module_ = "Stories.Card", storybook = "komponenter-card" }
        [ Story.story "Preview" preview
        , Story.story "Variants" variants
        , Story.story "Media" media
        , Story.story "Video" video
        , Story.story "WithLink" withLink
        , Story.story "AsLink" asLink
        , Story.story "AsButton" asButton
        , Story.story "AsGrid" asGrid
        ]
        |> Story.withCustomStyles
            [ ( "width", "100%" )
            , ( "max-width", "800px" )
            , ( "align-items", "center" )
            , ( "display", "grid" )
            , ( "gap", "var(--ds-size-4)" )
            , ( "grid-template-columns", "repeat(auto-fit, minmax(280px , 1fr))" )
            ]
        |> Story.withLayout Story.Fullscreen


preview : List (Html msg)
preview =
    [ Card.view [ Ds.color Color.neutral, Attr.style "max-width" "320px" ]
        [ Heading.h2 [] [ Html.text "Card" ]
        , Paragraph.view []
            [ Html.text "Most provide as with carried business are much better more the perfected designer. Writing slightly explain desk unable at supposedly about this" ]
        , Paragraph.view [ Paragraph.size Paragraph.Small ] [ Html.text "Footer text" ]
        ]
    ]


variants : List (Html msg)
variants =
    let
        card : ( String, List (Html.Attribute msg) ) -> Color -> Html msg
        card ( variant, variantAttributes ) color =
            Card.view (Ds.color color :: variantAttributes)
                [ Card.block []
                    [ Paragraph.view [] [ Html.text (variant ++ ": " ++ Color.toString color) ] ]
                ]
    in
    List.concatMap
        (\variant -> List.map (card variant) Theme.all)
        [ ( "default", [] ), ( "tinted", [ Card.tinted ] ) ]


media : List (Html msg)
media =
    [ Card.view [ Ds.color Color.neutral ]
        [ Card.block []
            [ Html.iframe
                [ Attr.src "https://player.vimeo.com/video/863563441?app_id=122963&title=0&byline=0&portrait=0&dnt=1"
                , Attr.attribute "width" "320px"
                , Attr.attribute "height" "179px"
                , Attr.attribute "allow" "autoplay; fullscreen; picture-in-picture"
                , Attr.title "30 år med digitalt innsyn"
                ]
                []
            ]
        , Card.block []
            [ Heading.h2 [] [ Html.text "Card Neutral" ]
            , Paragraph.view []
                [ Html.text "Most provide as with carried business are much better more the perfected designer. Writing slightly explain desk unable at supposedly about this" ]
            ]
        ]
    , Card.view [ Ds.color Color.neutral ]
        [ Card.block []
            [ Heading.h2 [] [ Html.text "Card Neutral" ]
            , Paragraph.view []
                [ Html.text "Most provide as with carried business are much better more the perfected designer. Writing slightly explain desk unable at supposedly about this" ]
            ]
        , Card.block [] [ Html.img [ Attr.src "/assets/cat1Img.webp", Attr.alt "cute cat 1" ] [] ]
        ]
    ]


video : List (Html msg)
video =
    let
        link : Card.LinkId
        link =
            Card.linkId "card-video-link"
    in
    -- React makes a card with a link in its heading clickable after rendering.
    -- In Elm you say which link it is, and the `LinkId` ties the two together.
    [ Card.clickable link
        [ Ds.color Color.neutral, Attr.style "max-width" "320px" ]
        [ Card.block []
            [ Html.iframe
                [ Attr.src "https://player.vimeo.com/video/863563441?app_id=122963&title=0&byline=0&portrait=0&dnt=1"
                , Attr.attribute "width" "320px"
                , Attr.attribute "height" "179px"
                , Attr.attribute "allow" "autoplay; fullscreen; picture-in-picture"
                , Attr.title "30 år med digitalt innsyn"
                ]
                []
            ]
        , Card.block []
            [ Heading.h2 []
                [ Html.a
                    [ Card.mainLink link
                    , Attr.href "https://www.digdir.no/felleslosninger/30-ar-med-digitalt-innsyn/5015"
                    , Attr.target "_blank"
                    , Attr.rel "noreferrer"
                    ]
                    [ Html.text "Vi feira 30 år med digitalt innsyn" ]
                ]
            , Paragraph.view []
                [ Html.text "Det er i år 30 år sidan dei første forsøka med elektronisk postjournal i Noreg. Sjå opptak frå feiringa på Pressens Hus der det både var historiske tilbakeblikk og debatt om innsyn og openheit i forvaltninga." ]
            ]
        ]
    ]


withLink : List (Html msg)
withLink =
    let
        plainLink : Card.LinkId
        plainLink =
            Card.linkId "card-with-link-1"

        dsLink : Card.LinkId
        dsLink =
            Card.linkId "card-with-link-2"
    in
    [ Card.clickable plainLink
        []
        [ Card.block [] [ Html.img [ Attr.src "/assets/cat5Img.webp", Attr.alt "cute cat 5" ] [] ]
        , Card.block []
            [ Heading.h2 []
                [ Html.a
                    [ Card.mainLink plainLink
                    , Attr.href "https://designsystemet.no"
                    , Attr.target "_blank"
                    , Attr.rel "noopener noreferrer"
                    ]
                    [ Html.text "Link Card" ]
                ]
            , Paragraph.view []
                [ Html.text "Most provide as with carried business are much better more the perfected designer. Writing slightly explain desk unable at supposedly about this" ]
            , Paragraph.view [ Paragraph.size Paragraph.Small ] [ Html.text "Footer text" ]
            ]
        ]
    , Card.clickable dsLink
        [ Ds.color Color.neutral ]
        [ Card.block []
            [ Heading.h2 []
                [ Link.view
                    [ Card.mainLink dsLink
                    , Attr.href "https://designsystemet.no"
                    , Attr.target "_blank"
                    , Attr.rel "noopener noreferrer"
                    ]
                    [ Html.text "Link Card" ]
                ]
            , Paragraph.view []
                [ Html.text "Most provide as with carried business are much better more the perfected designer. Writing slightly explain desk unable at supposedly about this" ]
            , Paragraph.view [ Paragraph.size Paragraph.Small ] [ Html.text "Footer text" ]
            ]
        , Card.block [] [ Html.img [ Attr.src "/assets/cat5Img.webp", Attr.alt "cute cat 5" ] [] ]
        ]
    ]


asLink : List (Html msg)
asLink =
    [ Card.viewAs Html.a
        [ Attr.href "https://designsystemet.no", Attr.target "_blank", Attr.rel "noopener noreferrer" ]
        [ Card.block [] [ Paragraph.view [] [ Html.text "Link card with asChild" ] ] ]
    , Card.viewAs Html.a
        [ Ds.color Color.neutral
        , Attr.href "https://designsystemet.no"
        , Attr.target "_blank"
        , Attr.rel "noopener noreferrer"
        ]
        [ Heading.h2 [] [ Html.text "Link Card with asChild" ]
        , Paragraph.view []
            [ Html.text "Most provide as with carried business are much better more the perfected designer." ]
        ]
    ]


asButton : List (Html msg)
asButton =
    [ Card.viewAs Html.button
        [ Attr.type_ "button" ]
        [ Card.block [] [ Heading.h2 [] [ Html.text "Button Card with blocks" ] ]
        , Card.block []
            [ Paragraph.view []
                [ Html.text "Most provide as with carried business are much better more the perfected designer." ]
            ]
        ]
    ]


asGrid : List (Html msg)
asGrid =
    [ Card.view [ Attr.style "display" "grid", Attr.style "grid-template-columns" "1fr 1fr" ]
        [ Card.block [] [ Heading.h2 [] [ Html.text "Button Card with blocks" ] ]
        , Card.block []
            [ Paragraph.view []
                [ Html.text "Most provide as with carried business are much better more the perfected designer." ]
            ]
        ]
    ]
