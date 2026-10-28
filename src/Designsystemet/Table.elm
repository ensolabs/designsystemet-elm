module Designsystemet.Table exposing
    ( view
    , zebra, stickyHeader, border, hover
    , head, body, keyedBody, foot, row, cell, headerCell
    , Sort(..), Direction(..), sortableHeaderCell, nextSort
    )

{-| Data in rows and columns.

Mirrors `Table` and its parts (`Table.Head`, `Table.Body`, …) from
`@digdir/designsystemet-react`. Each part is a function with the same shape as
`Html`, so a table reads like the HTML it renders:

    Table.view [ Table.zebra, Table.border ]
        [ Html.caption [] [ Html.text "Byggesaker" ]
        , Table.head []
            [ Table.row []
                [ Table.headerCell [] [ Html.text "Saksnummer" ]
                , Table.headerCell [] [ Html.text "Adresse" ]
                ]
            ]
        , Table.body []
            (List.map
                (\case_ ->
                    Table.row []
                        [ Table.cell [] [ Html.text case_.number ]
                        , Table.cell [] [ Html.text case_.address ]
                        ]
                )
                cases
            )
        ]


# React → Elm

  - `<Table>` → `Table.view []`
  - `zebra` / `stickyHeader` / `border` / `hover` → `Table.zebra` / `Table.stickyHeader` / `Table.border` / `Table.hover`
  - `<Table.Head>` / `Body` / `Foot` → `Table.head []` / `Table.body []` / `Table.foot []`
  - `<Table.Row>` / `Cell` / `HeaderCell` → `Table.row []` / `Table.cell []` / `Table.headerCell []`
  - `<Table.HeaderCell sort="ascending" onClick>` → `Table.sortableHeaderCell { sort, column, onSort } []`

@docs view


# Options

@docs zebra, stickyHeader, border, hover


# Parts

@docs head, body, keyedBody, foot, row, cell, headerCell


# Sorting

In React each header cell has its own `sort` prop, so two columns can both
claim to be sorted. Here the sort is one [`Sort`](#Sort) value in your model,
shared by every sortable header. At most one column is sorted, and each
header's `aria-sort` and button follow from it.

    type Column
        = Number
        | Address

    type alias Model =
        { sort : Table.Sort Column, cases : List Case }

    type Msg
        = SortChanged (Table.Sort Column)

    viewHeader : Table.Sort Column -> Html Msg
    viewHeader sort =
        Table.head []
            [ Table.row []
                [ Table.sortableHeaderCell { sort = sort, column = Number, onSort = SortChanged }
                    []
                    [ Html.text "Saksnummer" ]
                , Table.sortableHeaderCell { sort = sort, column = Address, onSort = SortChanged }
                    []
                    [ Html.text "Adresse" ]
                ]
            ]

Sorting the rows is up to you. The table only shows which column is sorted and
asks for a new sort when a header is clicked.

@docs Sort, Direction, sortableHeaderCell, nextSort

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed as Keyed



-- TABLE


{-| A `<table class="ds-table">`. Put an `Html.caption` first to give it a
visible name, styled as a heading.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view attributes =
    Html.table (Attr.class "ds-table" :: attributes)



-- OPTIONS


{-| Stripe every other row.
-}
zebra : Html.Attribute msg
zebra =
    Internal.data "zebra" "true"


{-| Keep the header in view while the body scrolls. Give the table a
`max-height` for it to scroll within.
-}
stickyHeader : Html.Attribute msg
stickyHeader =
    Internal.data "sticky-header" "true"


{-| A rounded border around the table.
-}
border : Html.Attribute msg
border =
    Internal.data "border" "true"


{-| Highlight the body row under the pointer.
-}
hover : Html.Attribute msg
hover =
    Internal.data "hover" "true"



-- PARTS


{-| A `<thead>`.
-}
head : List (Html.Attribute msg) -> List (Html msg) -> Html msg
head =
    Html.thead


{-| A `<tbody>`.
-}
body : List (Html.Attribute msg) -> List (Html msg) -> Html msg
body =
    Html.tbody


{-| A `<tbody>` with keyed rows, for rows that get sorted, filtered, added or
removed. Each row keeps its DOM node as it moves, so focus and input state stay
with the right row.

    Table.keyedBody []
        (List.map (\case_ -> ( case_.number, viewRow case_ )) (sortCases model.sort model.cases))

-}
keyedBody : List (Html.Attribute msg) -> List ( String, Html msg ) -> Html msg
keyedBody =
    Keyed.node "tbody"


{-| A `<tfoot>`, for sums and totals.
-}
foot : List (Html.Attribute msg) -> List (Html msg) -> Html msg
foot =
    Html.tfoot


{-| A `<tr>`.
-}
row : List (Html.Attribute msg) -> List (Html msg) -> Html msg
row =
    Html.tr


{-| A `<td>`.
-}
cell : List (Html.Attribute msg) -> List (Html msg) -> Html msg
cell =
    Html.td


{-| A `<th>`. In the body, add `Attr.scope "row"` to make it a row header.
For a header that sorts its column, use
[`sortableHeaderCell`](#sortableHeaderCell).
-}
headerCell : List (Html.Attribute msg) -> List (Html msg) -> Html msg
headerCell =
    Html.th



-- SORTING


{-| How the table is sorted: not at all, or by one column in one direction.
`column` is your own type for the table's columns.
-}
type Sort column
    = Unsorted
    | SortedBy column Direction


{-| Which way a sorted column is ordered: `aria-sort="ascending"` or
`"descending"`.
-}
type Direction
    = Ascending
    | Descending


{-| A header cell with a sort button in it: `<th aria-sort="…"><button
type="button">…</button></th>`.

  - `sort` is the table's current sort, the same value for every header.
  - `column` is the column this header is for.
  - `onSort` gets the sort from [`nextSort`](#nextSort) when the header is
    clicked.

`aria-sort` is `"ascending"` or `"descending"` on the sorted column and
`"none"` on the other sortable ones. The attributes go on the `<th>`.

-}
sortableHeaderCell :
    { sort : Sort column, column : column, onSort : Sort column -> msg }
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
sortableHeaderCell { sort, column, onSort } attributes children =
    Html.th (Attr.attribute "aria-sort" (ariaSort column sort) :: attributes)
        [ Html.button
            [ Attr.type_ "button"
            , Events.onClick (onSort (nextSort column sort))
            ]
            children
        ]


ariaSort : column -> Sort column -> String
ariaSort column sort =
    case sort of
        SortedBy sortedColumn Ascending ->
            if sortedColumn == column then
                "ascending"

            else
                "none"

        SortedBy sortedColumn Descending ->
            if sortedColumn == column then
                "descending"

            else
                "none"

        Unsorted ->
            "none"


{-| The sort after a click on a column's header: a new column starts
ascending, and clicking the sorted column again flips its direction.

    nextSort Address Unsorted == SortedBy Address Ascending

    nextSort Address (SortedBy Number Descending) == SortedBy Address Ascending

    nextSort Address (SortedBy Address Ascending) == SortedBy Address Descending

    nextSort Address (SortedBy Address Descending) == SortedBy Address Ascending

To have a third click go back to `Unsorted`, handle it in `update`. The
message carries the column either way.

-}
nextSort : column -> Sort column -> Sort column
nextSort column sort =
    case sort of
        SortedBy sortedColumn Ascending ->
            if sortedColumn == column then
                SortedBy column Descending

            else
                SortedBy column Ascending

        _ ->
            SortedBy column Ascending
