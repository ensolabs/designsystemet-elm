module Designsystemet.Pagination exposing
    ( Pagination, buttons, links, Labels
    , withMaxVisible, withArrowsOnly
    , view
    , Item(..), items
    )

{-| Navigation between the pages of a long list or table.

Mirrors `Pagination` and `usePagination` from `@digdir/designsystemet-react`.

    Pagination.buttons
        { current = model.page
        , total = model.pageCount
        , onSelect = PageSelected
        , labels = paginationLabels
        }
        |> Pagination.view []

    paginationLabels : Pagination.Labels
    paginationLabels =
        { navigation = "Bla i sider"
        , previous = "Forrige"
        , next = "Neste"
        , page = \page -> "Side " ++ String.fromInt page
        }

which renders

    Forrige  1  …  4  [5]  6  …  12  Neste

Visible pages are picked with the same algorithm as `designsystemet-web`, so
the output matches React. Pages are numbered from 1.


# Buttons or links

  - [`buttons`](#buttons) send a message. Use them when the page number lives
    only in your model.
  - [`links`](#links) are `<a href>`s. Use them when the page number is in the
    URL, so pages can be bookmarked and opened in new tabs.


# React → Elm

  - `usePagination({ currentPage, totalPages, onChange })` → `Pagination.buttons { current, total, onSelect, … }`
  - `<Pagination.Button asChild><a href>` → `Pagination.links { current, total, toHref, … }`
  - `showPages={5}` → `Pagination.withMaxVisible 5`
  - empty `Pagination.Button` with `aria-label` at the ends → `Pagination.withArrowsOnly`
  - `aria-label="Bla i sider"` → `labels.navigation`
  - `<Pagination>` + `List` + `Item` + `Button` → all rendered by `Pagination.view`
  - `pagination({ current, total, show })` (web) → `Pagination.items`


# Differences from React

`data-current`, `data-total` and `data-href` are never set. With them,
`designsystemet-web` would render the pages itself and fight Elm over the
markup.

The previous and next buttons always have `aria-hidden` (`"true"` when there
is no such page), as with React's `usePagination`. Their visible text is also
their accessible name. The upstream stories give them a longer `aria-label`
("Forrige side" next to "Forrige"), which hides the visible text from screen
readers. With [`withArrowsOnly`](#withArrowsOnly) the text becomes the
`aria-label`, as in the upstream mobile story.


# Managed by designsystemet-web

Never set `role` on the pagination yourself.

@docs Pagination, buttons, links, Labels
@docs withMaxVisible, withArrowsOnly
@docs view


# The algorithm

@docs Item, items

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed as Keyed



-- PAGINATION


{-| A pagination being configured. Start with [`buttons`](#buttons) or
[`links`](#links), finish with [`view`](#view).
-}
type Pagination msg
    = Pagination
        { current : Int
        , total : Int
        , maxVisible : Int
        , ends : Ends
        , labels : Labels
        , target : Target msg
        }


type Ends
    = TextAndArrow
    | ArrowOnly


type Target msg
    = Buttons (Int -> msg)
    | Links (Int -> String)


{-| The texts in a pagination. Define them once per app or language.

  - `navigation` names the whole thing for screen readers (`aria-label`).
  - `previous` and `next` are shown next to the arrow on the end buttons.
  - `page` names one page button for screen readers. The button shows only the
    number.

-}
type alias Labels =
    { navigation : String
    , previous : String
    , next : String
    , page : Int -> String
    }


{-| Page buttons that send `onSelect` with the page number.
-}
buttons : { current : Int, total : Int, onSelect : Int -> msg, labels : Labels } -> Pagination msg
buttons { current, total, onSelect, labels } =
    Pagination
        { current = current
        , total = total
        , maxVisible = 7
        , ends = TextAndArrow
        , labels = labels
        , target = Buttons onSelect
        }


{-| Page links that go to `toHref` of the page number.

    Pagination.links
        { current = model.page
        , total = model.pageCount
        , toHref = \page -> "/saker?side=" ++ String.fromInt page
        , labels = paginationLabels
        }
        |> Pagination.view []

-}
links : { current : Int, total : Int, toHref : Int -> String, labels : Labels } -> Pagination msg
links { current, total, toHref, labels } =
    Pagination
        { current = current
        , total = total
        , maxVisible = 7
        , ends = TextAndArrow
        , labels = labels
        , target = Links toHref
        }


{-| Max page items to show, counting each "…" but not the previous and next
buttons. Defaults to 7. Use 5 or fewer on narrow screens.
-}
withMaxVisible : Int -> Pagination msg -> Pagination msg
withMaxVisible maxVisible (Pagination config) =
    Pagination { config | maxVisible = maxVisible }


{-| Show only the arrows on the previous and next buttons, for narrow screens.
`labels.previous` and `labels.next` become their `aria-label`s.

    Pagination.buttons { current = model.page, total = 10, onSelect = PageSelected, labels = labels }
        |> Pagination.withMaxVisible 3
        |> Pagination.withArrowsOnly
        |> Pagination.view []

-}
withArrowsOnly : Pagination msg -> Pagination msg
withArrowsOnly (Pagination config) =
    Pagination { config | ends = ArrowOnly }


{-| Render the `<ds-pagination class="ds-pagination">`.
-}
view : List (Html.Attribute msg) -> Pagination msg -> Html msg
view attributes (Pagination config) =
    Html.node "ds-pagination"
        (Attr.class "ds-pagination"
            :: Attr.attribute "aria-label" config.labels.navigation
            :: attributes
        )
        [ Keyed.ul []
            (( "previous", viewEnd config (previousPage config) config.labels.previous )
                :: List.indexedMap (viewItem config) (items { current = config.current, total = config.total, show = config.maxVisible })
                ++ [ ( "next", viewEnd config (nextPage config) config.labels.next ) ]
            )
        ]


previousPage : { a | current : Int } -> Maybe Int
previousPage { current } =
    if current > 1 then
        Just (current - 1)

    else
        Nothing


nextPage : { a | current : Int, total : Int } -> Maybe Int
nextPage { current, total } =
    if current < total then
        Just (current + 1)

    else
        Nothing


{-| Rendered hidden when there is no such page, so the numbers don't shift.
-}
viewEnd : { a | target : Target msg, ends : Ends } -> Maybe Int -> String -> Html msg
viewEnd { target, ends } page text =
    let
        hidden : Html.Attribute msg
        hidden =
            Attr.attribute "aria-hidden"
                (if page == Nothing then
                    "true"

                 else
                    "false"
                )
    in
    Html.li []
        [ case ends of
            TextAndArrow ->
                viewTarget target page [ hidden ] [ Html.text text ]

            ArrowOnly ->
                -- The CSS draws the arrow into an empty button.
                viewTarget target page [ hidden, Attr.attribute "aria-label" text ] []
        ]


viewItem : { a | current : Int, labels : Labels, target : Target msg } -> Int -> Item -> ( String, Html msg )
viewItem { current, labels, target } index item =
    case item of
        Page page ->
            ( "page-" ++ String.fromInt page
            , Html.li []
                [ viewTarget target
                    (Just page)
                    [ if page == current then
                        Attr.attribute "aria-current" "true"

                      else
                        Internal.none
                    , Attr.attribute "aria-label" (labels.page page)
                    ]
                    [ Html.text (String.fromInt page) ]
                ]
            )

        Ellipsis ->
            ( "ellipsis-" ++ String.fromInt index, Html.li [] [] )


viewTarget : Target msg -> Maybe Int -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
viewTarget target page attributes =
    case target of
        Buttons onSelect ->
            Html.button
                (Attr.class "ds-button"
                    :: Attr.type_ "button"
                    :: (case page of
                            Just number ->
                                Events.onClick (onSelect number)

                            Nothing ->
                                Internal.none
                       )
                    :: attributes
                )

        Links toHref ->
            Html.a
                (Attr.class "ds-button"
                    :: (case page of
                            Just number ->
                                Attr.href (toHref number)

                            Nothing ->
                                Internal.none
                       )
                    :: attributes
                )



-- ALGORITHM


{-| One item between the previous and next buttons.
-}
type Item
    = Page Int
    | Ellipsis


{-| Which items to show. A port of `pagination()` from `designsystemet-web`:

    items { current = 5, total = 12, show = 7 }
    --> [ Page 1, Ellipsis, Page 4, Page 5, Page 6, Ellipsis, Page 12 ]

The first and last page are always included (when `show` is at least 5 and 4
respectively), and the current page is kept in the middle when possible. Use it
to render your own pagination.

-}
items : { current : Int, total : Int, show : Int } -> List Item
items { current, total, show } =
    let
        half : Float
        half =
            toFloat (show - 1) / 2

        start : Int
        start =
            max (min (current - floor half) (total - show + 1)) 1

        end : Int
        end =
            min (max (current + ceiling half) show) total

        withFirst : List Int -> List Int
        withFirst pages =
            if show > 4 && start > 1 then
                1 :: 0 :: List.drop 2 pages

            else
                pages

        withLast : List Int -> List Int
        withLast pages =
            if show > 3 && end < total then
                List.take (List.length pages - 2) pages ++ [ 0, total ]

            else
                pages
    in
    List.range start end
        |> withFirst
        |> withLast
        |> List.map
            (\page ->
                if page == 0 then
                    Ellipsis

                else
                    Page page
            )
