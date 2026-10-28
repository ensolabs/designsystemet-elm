module Stories.Badge exposing (chapter)

{-| `badge.stories.tsx`, story for story.

What a badge shows is a `Badge.Content`: a `Dot`, a `Count`, or a count
`Capped` at a maximum ("9+"). React's `maxCount` without a `count` can't be
written.

Differences from the React stories (they show up in the markup diff):

  - InButton: an icon `Button` requires its `label` (its `aria-label`), so
    it is named by the button rather than by the icon's `title`.

-}

import Designsystemet as Ds
import Designsystemet.Badge as Badge exposing (Content(..), Corner(..), Overlap(..))
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Size as Size
import Designsystemet.Tabs as Tabs
import Html exposing (Html)
import Html.Attributes as Attr
import Icons
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Badge", module_ = "Stories.Badge", storybook = "komponenter-badge" }
        [ Story.story "Preview" preview
        , Story.story "Floating" floating
            |> Story.withStoryCustomStyles [ ( "display", "flex" ), ( "gap", "var(--ds-size-4)" ), ( "flex-wrap", "wrap" ) ]
        , Story.story "CustomPlacement" customPlacement
        , Story.story "Status" status
        , Story.story "InTabs" inTabs
        , Story.story "InButton" inButton
        , Story.story "Variants" variants
            |> Story.withStoryCustomStyles
                [ ( "display", "grid" )
                , ( "grid-template-columns", "repeat(4, 1fr)" )
                , ( "gap", "var(--ds-size-2)" )
                , ( "height", "100%" )
                , ( "width", "100%" )
                ]
        , Story.story "Bullet" bullet
        ]
        |> Story.withCustomStyles [ ( "flex-wrap", "wrap" ) ]


preview : List (Html msg)
preview =
    [ Badge.view (Capped { count = 15, max = 9 }) [] ]


floating : List (Html msg)
floating =
    let
        messages : Corner -> Html msg
        messages corner =
            Badge.position { placement = corner, overlap = Rectangle }
                []
                [ Badge.view Dot [ Ds.color Color.accent ], Icons.envelopeClosedFill [ Attr.attribute "title" "Meldinger" ] ]

        circle : Corner -> Html msg
        circle corner =
            Badge.position { placement = corner, overlap = Circle }
                []
                [ Badge.view Dot [ Ds.color Color.accent ]
                , Html.div
                    [ Attr.style "width" "2rem"
                    , Attr.style "height" "2rem"
                    , Attr.style "border-radius" "50%"
                    , Attr.style "background-color" "var(--ds-color-brand2-base-default)"
                    ]
                    []
                ]

        corners : List Corner
        corners =
            [ TopRight, TopLeft, BottomRight, BottomLeft ]
    in
    List.map messages corners ++ List.map circle corners


customPlacement : List (Html msg)
customPlacement =
    [ Badge.position { placement = TopRight, overlap = Rectangle }
        [ Attr.attribute "style" "--dsc-badge-top: 16%; --dsc-badge-right: 10%" ]
        [ Badge.view Dot [ Ds.color Color.accent ], Icons.envelopeClosedFill [ Attr.attribute "title" "Meldinger" ] ]
    ]


status : List (Html msg)
status =
    List.map
        (\size ->
            Badge.position { placement = TopRight, overlap = Rectangle }
                [ Ds.size size ]
                [ Badge.view Dot [ Ds.color Color.danger ], Icons.videoFill [ Attr.attribute "title" "Videokamera" ] ]
        )
        [ Size.sm, Size.md, Size.lg ]


inTabs : List (Html msg)
inTabs =
    [ Tabs.uncontrolled { toId = identity, initial = "value1" }
        []
        [ Tabs.tab
            { value = "value1"
            , label =
                [ Icons.heartFill [ Attr.attribute "aria-hidden" "true" ]
                , Html.text "Favoritter"
                , Badge.view (Capped { count = 64, max = 10 }) [ Ds.color Color.neutral ]
                ]
            , panel = [ Html.text "content 1" ]
            }
        , Tabs.tab { value = "value2", label = [ Html.text "Tab 2" ], panel = [ Html.text "content 2" ] }
        , Tabs.tab
            { value = "value3"
            , label = [ Icons.pencil [ Attr.attribute "aria-hidden" "true" ], Html.text "Nylige", Badge.view (Count 2) [ Ds.color Color.neutral ] ]
            , panel = [ Html.text "content 3" ]
            }
        ]
    ]


inButton : List (Html msg)
inButton =
    -- An icon button carries its name in `label`; the badge sits on the icon.
    [ Button.icon
        { label = "Innboks"
        , icon =
            Badge.position { placement = TopRight, overlap = Rectangle }
                []
                [ Badge.view (Capped { count = 1000, max = 99 }) [ Ds.color Color.danger ], Icons.inbox [] ]
        }
        [ Button.tertiary ]
    , Button.icon
        { label = "Meldinger"
        , icon =
            Badge.position { placement = TopRight, overlap = Rectangle }
                []
                [ Badge.view (Count 10) [ Ds.color Color.danger ], Icons.chat [] ]
        }
        [ Button.tertiary ]
    , Button.icon
        { label = "Skru på video"
        , icon =
            Badge.position { placement = TopRight, overlap = Rectangle }
                []
                [ Badge.view Dot [ Ds.color Color.danger ], Icons.video [] ]
        }
        [ Button.tertiary ]
    , Badge.position { placement = TopRight, overlap = Rectangle }
        []
        [ Badge.view (Count 10) [ Ds.color Color.danger ]
        , Button.view [] [ Icons.inbox [ Attr.attribute "title" "Innboks" ], Html.text " Test" ]
        ]
    ]


variants : List (Html msg)
variants =
    List.concatMap
        (\color ->
            [ Badge.view (Capped { count = 15, max = 9 }) [ Ds.color color ]
            , Badge.view (Capped { count = 15, max = 9 }) [ Ds.color color, Badge.tinted ]
            ]
        )
        [ Color.neutral, Color.danger, Color.info, Color.warning ]


bullet : List (Html msg)
bullet =
    [ Paragraph.view [] [ Badge.view Dot [ Ds.color Color.success ], Html.text " Aktiv" ] ]
