module Stories.Tag exposing (chapter)

{-| `tag.stories.tsx`, story for story.

Differences from the React stories (they show up in the markup diff):

  - Preview: React writes `data-variant="default"`; here the default is no
    variant attribute.

-}

import Designsystemet as Ds
import Designsystemet.Color as Color
import Designsystemet.Size as Size
import Designsystemet.Tag as Tag
import Html exposing (Html)
import Html.Attributes as Attr
import Icons
import Showcase.Story as Story exposing (Chapter)
import Theme


chapter : Chapter msg
chapter =
    let
        fourColumns : List ( String, String )
        fourColumns =
            [ ( "display", "grid" )
            , ( "grid-template-columns", "repeat(4, 1fr)" )
            , ( "gap", "var(--ds-size-2)" )
            , ( "height", "100%" )
            , ( "width", "100%" )
            , ( "place-items", "center" )
            ]
    in
    Story.chapter { title = "Tag", module_ = "Stories.Tag", storybook = "komponenter-tag" }
        [ Story.story "Preview" preview
        , Story.story "Sizes" sizes
            |> Story.withStoryCustomStyles [ ( "display", "flex" ), ( "align-items", "center" ), ( "gap", "var(--ds-size-2)" ) ]
        , Story.story "Colors" colors
            |> Story.withStoryCustomStyles fourColumns
        , Story.story "Icons" icons
            |> Story.withStoryCustomStyles
                [ ( "display", "flex" )
                , ( "gap", "var(--ds-size-2)" )
                , ( "height", "100%" )
                , ( "width", "100%" )
                , ( "place-items", "center" )
                ]
        , Story.story "VariantOutline" variantOutline
            |> Story.withStoryCustomStyles fourColumns
        , Story.story "AsButtonAndLink" asButtonAndLink
        ]
        |> Story.withCustomStyles [ ( "justify-content", "start" ) ]


preview : List (Html msg)
preview =
    [ Tag.view [] [ Html.text "New" ] ]


sizes : List (Html msg)
sizes =
    List.map
        (\size -> Tag.view [ Ds.size size ] [ Html.text (Size.toString size) ])
        [ Size.sm, Size.md, Size.lg ]


colors : List (Html msg)
colors =
    List.map
        (\color -> Tag.view [ Ds.color color ] [ Html.text (Color.toString color) ])
        Theme.all


icons : List (Html msg)
icons =
    [ Tag.view
        [ Ds.color Color.neutral
        , Ds.size Size.md
        , Attr.style "padding-inline-start" "var(--ds-size-1)"
        ]
        [ Icons.robot [ Attr.attribute "aria-hidden" "true", Attr.style "margin-inline-end" "var(--ds-size-1)" ]
        , Html.text "Teksten er KI-generert"
        ]
    , Tag.view
        [ Ds.color Color.info
        , Ds.size Size.md
        , Attr.style "padding-inline-start" "var(--ds-size-1)"
        ]
        [ Icons.paragraph [ Attr.attribute "aria-hidden" "true", Attr.style "margin-inline-end" "var(--ds-size-1)" ]
        , Html.text "Forvaltningsloven §1"
        ]
    ]


variantOutline : List (Html msg)
variantOutline =
    List.map
        (\color -> Tag.view [ Ds.color color, Tag.outline ] [ Html.text (Color.toString color) ])
        Theme.themeColors


asButtonAndLink : List (Html msg)
asButtonAndLink =
    [ Tag.viewAs Html.button [ Attr.type_ "button" ] [ Html.text "Button" ]
    , Html.text " "
    , Tag.viewAs Html.a [ Attr.href "#none" ] [ Html.text "Link" ]
    ]
