module Stories.Breadcrumbs exposing (chapter)

{-| `breadcrumbs.stories.tsx`, story for story.

The last link is the current page. The back link, shown on narrow screens, is
the level above it: `withBackLink` only needs its label.

-}

import Designsystemet.Breadcrumbs as Breadcrumbs
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Breadcrumbs", module_ = "Stories.Breadcrumbs", storybook = "komponenter-breadcrumbs" }
        [ Story.story "Preview" preview
        , Story.story "ListOnly" listOnly
        , Story.story "BackOnly" backOnly
        , Story.story "LongItems" longItems
        , Story.story "MobileViewport" mobileViewport
        ]


preview : List (Html msg)
preview =
    [ Breadcrumbs.new { label = "Du er her:" }
        |> Breadcrumbs.withBackLink { label = "Tilbake til Nivå 3" }
        |> Breadcrumbs.view []
            [ Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 1" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 2" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 3" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 4" ]
            ]
    ]


listOnly : List (Html msg)
listOnly =
    [ Breadcrumbs.new { label = "Du er her:" }
        |> Breadcrumbs.view []
            [ Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 1" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 2" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 3" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 4" ]
            ]
    ]


backOnly : List (Html msg)
backOnly =
    [ Breadcrumbs.backOnly { label = "Tilbake til Nivå 3" } [ Attr.href "#" ] [ Html.text "Nivå 3" ] ]


longItems : List (Html msg)
longItems =
    [ Breadcrumbs.new { label = "Du er her:" }
        |> Breadcrumbs.withBackLink { label = "Tilbake til helsesertifikat for sjømat" }
        |> Breadcrumbs.view []
            [ Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Hjem" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Eksport til land utenfor EU/EØS" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Eksport av mat og drikke" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Eksport av fisk og sjømat" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Veiledning om helsesertifikat for sjømat" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Slik søker du om helsesertifikat for sjømat" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Slik søker du om helsesertifikat i ny eksportløsning" ]
            ]
    ]


{-| Upstream shows this story in a 375px wide viewport, where only the back
link is visible. The CSS switches on the viewport's width, so narrow the
browser window to see it here.
-}
mobileViewport : List (Html msg)
mobileViewport =
    [ Breadcrumbs.new { label = "Du er her:" }
        |> Breadcrumbs.withBackLink { label = "Tilbake til Nivå 3" }
        |> Breadcrumbs.view []
            [ Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 1" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 2" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 3" ]
            , Breadcrumbs.link [ Attr.href "#" ] [ Html.text "Nivå 4" ]
            ]
    ]
