module Stories.Spinner exposing (chapter)

{-| `spinner.stories.tsx`, story for story.
-}

import Designsystemet as Ds
import Designsystemet.Color as Color
import Designsystemet.Spinner as Spinner
import Html exposing (Html)
import Showcase.Story as Story exposing (Chapter)
import Theme


chapter : Chapter msg
chapter =
    Story.chapter { title = "Spinner", module_ = "Stories.Spinner", storybook = "komponenter-spinner" }
        [ Story.story "Preview" preview
        , Story.story "Variants" variants
        , Story.story "Sizes" sizes
        ]
        |> Story.withCustomStyles
            [ ( "display", "flex" )
            , ( "gap", "1rem" )
            , ( "flex-wrap", "wrap" )
            , ( "justify-content", "center" )
            , ( "align-items", "center" )
            ]


preview : List (Html msg)
preview =
    [ Spinner.view { label = "Henter kaffi" } [] ]


variants : List (Html msg)
variants =
    List.map
        (\color ->
            Spinner.view { label = "Henter " ++ Color.toString color ++ " kaffi" }
                [ Ds.color color, Spinner.size Spinner.ExtraLarge ]
        )
        Theme.all


sizes : List (Html msg)
sizes =
    List.map
        (\size -> Spinner.view { label = "Henter kaffi" } [ Spinner.size size ])
        [ Spinner.TwoExtraSmall
        , Spinner.ExtraSmall
        , Spinner.Small
        , Spinner.Medium
        , Spinner.Large
        , Spinner.ExtraLarge
        ]
