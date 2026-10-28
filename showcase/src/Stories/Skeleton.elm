module Stories.Skeleton exposing (chapter)

{-| `skeleton.stories.tsx`, story for story.

Each shape takes only the measurements that make sense for it, so the React
`width`/`height`/`variant` props become one function per shape.

Differences from the React stories (they show up in the markup diff):

  - Components and Children: React passes `variant="rectangle"` explicitly;
    `Skeleton.rectangle` and `Skeleton.view` render React's default, which has
    no `data-variant` and looks the same.

-}

import Designsystemet.Button as Button
import Designsystemet.Heading as Heading
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Skeleton as Skeleton
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Skeleton", module_ = "Stories.Skeleton", storybook = "komponenter-skeleton" }
        [ Story.story "Preview" preview
        , Story.story "Components" components
            |> Story.withStoryCustomStyles [ ( "display", "flex" ), ( "flex-wrap", "wrap" ), ( "align-items", "center" ), ( "gap", "20px" ) ]
        , Story.story "UsageExample" usageExample
            |> Story.withStoryCustomStyles [ ( "max-width", "400px" ) ]
        , Story.story "Children" children
        , Story.story "Text" text
            |> Story.withStoryCustomStyles [ ( "display", "flex" ), ( "gap", "20px" ), ( "max-width", "300px" ) ]
        ]


preview : List (Html msg)
preview =
    [ Skeleton.rectangle { width = "200px", height = "100px" } [] ]


components : List (Html msg)
components =
    [ Skeleton.circle { diameter = "50px" } []
    , Skeleton.rectangle { width = "100px", height = "50px" } []
    , Paragraph.view [] [ Skeleton.text { characters = 10 } [] ]
    ]


usageExample : List (Html msg)
usageExample =
    [ Skeleton.rectangle { width = "100%", height = "150px" } []
    , Html.div
        [ Attr.style "display" "flex"
        , Attr.style "gap" "10px"
        , Attr.style "align-items" "center"
        , Attr.style "padding" "5px 0 5px 0"
        ]
        [ Skeleton.circle { diameter = "30px" } []
        , Heading.h2 [] [ Skeleton.textLike "En medium tittel" [] ]
        ]
    , Skeleton.text { characters = 140 } []
    ]


children : List (Html msg)
children =
    [ Skeleton.view []
        [ Paragraph.view [] [ Html.text "Her er en tekst som blir sendt inn som barn av en Skeleton." ]
        , Paragraph.view [] [ Html.text "Se hvordan Skeleton da dekker den samlede bredden og høyden til barna." ]
        , Button.view [] [ Html.text "Knapp" ]
        ]
    ]


text : List (Html msg)
text =
    [ Html.div [ Attr.style "flex" "1 1 200px" ]
        [ Heading.h2 [] [ Html.text "En tittel" ]
        , Paragraph.view [ Paragraph.size Paragraph.Small ]
            [ Html.text "Her er en paragraf som går over flere linjer" ]
        ]
    , Html.div [ Attr.style "flex" "1 1 200px" ]
        [ Heading.h2 [] [ Skeleton.textLike "En tittel" [] ]
        , Paragraph.view [ Paragraph.size Paragraph.Small ] [ Skeleton.text { characters = 40 } [] ]
        ]
    ]
