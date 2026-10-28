module Stories.Pagination exposing (chapter)

{-| `pagination.stories.tsx`, story for story.

React's stories assemble the list, items and buttons by hand, with
`usePagination` working out which pages to show. Here `Pagination.view` does
both, with the same algorithm.

-}

import Designsystemet.Pagination as Pagination
import Html exposing (Html)
import Showcase.Story as Story exposing (Chapter)
import Stories.Interactive.State exposing (Model, Msg(..))


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Pagination", module_ = "Stories.Pagination", storybook = "komponenter-pagination" }
        [ Story.story "Preview" (preview model)
        , Story.story "WithAnchor" withAnchor
        , Story.story "Mobile" (mobile model)
        ]


{-| The texts, defined once for the app.
-}
labels : Pagination.Labels
labels =
    { navigation = "Bla i sider"
    , previous = "Forrige"
    , next = "Neste"
    , page = \page -> "Side " ++ String.fromInt page
    }


preview : Model -> List (Html Msg)
preview model =
    [ Pagination.buttons
        { current = model.paginationPage
        , total = 10
        , onSelect = PageSelected
        , labels = labels
        }
        |> Pagination.view []
    ]


withAnchor : List (Html msg)
withAnchor =
    -- Links for pages with their own URL. Here the current page is fixed; in
    -- an app it comes from the URL.
    [ Pagination.links
        { current = 2
        , total = 10
        , toHref = \page -> "#side-" ++ String.fromInt page
        , labels = { labels | navigation = "Sidenavigering" }
        }
        |> Pagination.view []
    ]


mobile : Model -> List (Html Msg)
mobile model =
    [ Pagination.buttons
        { current = model.mobilePaginationPage
        , total = 10
        , onSelect = MobilePageSelected
        , labels = { labels | previous = "Forrige side", next = "Neste side" }
        }
        |> Pagination.withMaxVisible 3
        |> Pagination.withArrowsOnly
        |> Pagination.view []
    ]
