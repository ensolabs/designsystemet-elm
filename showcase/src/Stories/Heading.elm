module Stories.Heading exposing (chapter)

{-| `heading.stories.tsx`, story for story.

The React stories' `play` tests (equal margins, nested size modes) are not
ported: they test the CSS, which is the same here.

The stories' `data-testid` hooks are left out.

-}

import Designsystemet as Ds
import Designsystemet.Heading as Heading
import Designsystemet.Size as Size exposing (Size)
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Heading", module_ = "Stories.Heading", storybook = "komponenter-typography-heading" }
        [ Story.story "Preview" preview
        , Story.story "HeadingsInVariousSizes" headingsInVariousSizes
        , Story.story "NestedSizeModes" nestedSizeModes
        ]


preview : List (Html msg)
preview =
    -- React defaults to level 2; here the level is always explicit.
    [ Heading.h2 [] [ Html.text "Tittel tekst" ] ]


headingsInVariousSizes : List (Html msg)
headingsInVariousSizes =
    [ Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        , Attr.style "gap" "var(--ds-size-6)"
        , Attr.style "white-space" "nowrap"
        ]
        [ Html.div [ Ds.size Size.sm ] (Html.div [] [ Html.text "Size mode small" ] :: headings)
        , Html.div [ Attr.style "display" "flex", Attr.style "gap" "var(--ds-size-3)" ]
            [ Html.div [] (Html.text "Implicit size mode medium" :: headings)
            , Html.div [ Ds.size Size.md ] (Html.text "Explicit size mode medium" :: headings)
            ]
        , Html.div [ Ds.size Size.lg ] (Html.text "Size mode large" :: headings)
        ]
    ]


nestedSizeModes : List (Html msg)
nestedSizeModes =
    let
        -- Headings inside nested size modes, outermost first: the innermost
        -- one wins.
        nested : List Size -> String -> Html msg
        nested sizes title =
            case List.reverse sizes of
                innermost :: outer ->
                    List.foldl
                        (\size inner -> Html.div [ Ds.size size ] [ inner ])
                        (Html.div [ Ds.size innermost ] (Html.text title :: headings))
                        outer

                [] ->
                    Html.div [] (Html.text title :: headings)

        row : List (Html msg) -> Html msg
        row =
            Html.div [ Attr.style "display" "flex", Attr.style "gap" "var(--ds-size-3)" ]
    in
    [ Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        , Attr.style "gap" "var(--ds-size-6)"
        , Attr.style "white-space" "nowrap"
        ]
        [ row
            [ nested [ Size.sm ] "Small"
            , nested [ Size.md, Size.sm ] "Medium › Small"
            , nested [ Size.lg, Size.sm ] "Large › Small"
            , nested [ Size.lg, Size.md, Size.sm ] "Large › Medium › Small"
            , nested [ Size.md, Size.lg, Size.sm ] "Medium › Large › Small"
            ]
        , row
            [ nested [ Size.md ] "Medium"
            , nested [ Size.sm, Size.md ] "Small › Medium"
            , nested [ Size.lg, Size.md ] "Large › Medium"
            , nested [ Size.lg, Size.sm, Size.md ] "Large › Small › Medium"
            , nested [ Size.sm, Size.lg, Size.md ] "Small › Large › Medium"
            ]
        , row
            [ nested [ Size.lg ] "Large"
            , nested [ Size.sm, Size.lg ] "Small › Large"
            , nested [ Size.md, Size.lg ] "Medium › Large"
            , nested [ Size.sm, Size.md, Size.lg ] "Small › Medium › Large"
            , nested [ Size.md, Size.sm, Size.lg ] "Small › Large › Medium"
            ]
        ]
    ]


{-| The seven heading sizes the two size-mode stories repeat.
-}
headings : List (Html msg)
headings =
    List.map
        (\( size, text ) ->
            Heading.h2 [ Heading.size size, Attr.style "margin-bottom" "var(--ds-size-4)" ]
                [ Html.text text ]
        )
        [ ( Heading.TwoExtraLarge, "This is a 2xl heading" )
        , ( Heading.ExtraLarge, "This is an xl heading" )
        , ( Heading.Large, "This is a lg heading" )
        , ( Heading.Medium, "This is a md heading" )
        , ( Heading.Small, "This is a sm heading" )
        , ( Heading.ExtraSmall, "This is an xs heading" )
        , ( Heading.TwoExtraSmall, "This is a 2xs heading" )
        ]
