module Stories.Button exposing (chapter)

{-| `button.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Button as Button exposing (Loading(..))
import Designsystemet.Color as Color
import Html exposing (Html)
import Html.Attributes as Attr
import Icons
import Showcase.Story as Story exposing (Chapter)
import Theme


chapter : Chapter msg
chapter =
    Story.chapter { title = "Button", module_ = "Stories.Button", storybook = "komponenter-button" }
        [ Story.story "Preview" preview
        , Story.story "Variants" variants
        , Story.story "Colors" colors
        , Story.story "Icons" icons
        , Story.story "CombinedColors" combinedColors
        , Story.story "AsLink" asLink
        , Story.story "Loading" loading
        ]
        |> Story.withCustomStyles
            [ ( "display", "flex" )
            , ( "flex-direction", "row" )
            , ( "justify-content", "center" )
            , ( "align-items", "center" )
            , ( "flex-wrap", "wrap" )
            , ( "gap", "var(--ds-size-4)" )
            ]


preview : List (Html msg)
preview =
    [ Button.view [ Button.primary ] [ Html.text "Knapp" ] ]


variants : List (Html msg)
variants =
    [ Button.view [ Button.primary ] [ Html.text "Primary" ]
    , Button.view [ Button.secondary ] [ Html.text "Secondary" ]
    , Button.view [ Button.tertiary ] [ Html.text "Teritiary" ]
    ]


colors : List (Html msg)
colors =
    List.map
        (\color -> Button.view [ Ds.color color, Button.primary ] [ Html.text (Color.toString color) ])
        (Theme.themeColors ++ [ Color.danger ])


icons : List (Html msg)
icons =
    [ Button.icon { label = "Rediger", icon = Icons.pencilWriting [] } []
    , Button.view [] [ Icons.pencilWriting [], Html.text "Rediger" ]
    ]


combinedColors : List (Html msg)
combinedColors =
    [ Button.view [ Button.primary, Ds.color Color.neutral ] [ Html.text "Publiser" ]
    , Button.view [ Button.secondary, Ds.color Color.neutral ] [ Html.text "Lagre kladd" ]
    , Button.view [ Button.tertiary, Ds.color Color.danger ] [ Html.text "Slett" ]
    ]


asLink : List (Html msg)
asLink =
    [ Button.viewAs Html.a
        [ Attr.target "_blank"
        , Attr.rel "noreferrer"
        , Attr.href "https://www.designsystemet.no"
        ]
        [ Html.text "Gå til designsystemet.no" ]
    ]


loading : List (Html msg)
loading =
    [ Button.loading Busy [ Button.primary ] [ Html.text "Laster..." ]
    , Button.loading Busy [ Button.secondary ] [ Html.text "Laster..." ]
    , Button.loading Busy [ Button.tertiary ] [ Html.text "Laster..." ]

    -- While busy, the spinner takes the icon's place.
    , Button.iconLoading Busy { label = "Rediger", icon = Icons.pencilWriting [] } []
    ]
