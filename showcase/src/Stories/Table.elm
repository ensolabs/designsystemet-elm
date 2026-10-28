module Stories.Table exposing (Column, Model, Msg, chapter, init, update)

{-| `table.stories.tsx`, story for story.

Sortable and WithFormElements keep state: the table's `Sort`, and which
employees are checked.

Differences from the React stories (they show up in the markup diff):

  - WithFormElements: `checked` is a DOM property, not an attribute, and the
    "select all" box has no `name`/`value` (React's `useCheckboxGroup` adds
    empty ones).

-}

import Designsystemet as Ds
import Designsystemet.Checkbox as Checkbox
import Designsystemet.Input as Input
import Designsystemet.Size as Size
import Designsystemet.Table as Table exposing (Direction(..), Sort(..))
import Designsystemet.Textfield as Textfield
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Showcase.Story as Story exposing (Chapter)



-- STATE


{-| The sortable columns of the Sortable story. Epost isn't one, so it can't
be sorted by.
-}
type Column
    = Navn
    | Telefon


type alias Person =
    { id : Int, navn : String, epost : String, telefon : String }


type alias Model =
    { sort : Sort Column
    , checked : List String
    }


type Msg
    = SortChanged (Sort Column)
    | EmployeeChecked String Bool
    | AllEmployeesChecked Bool


init : Model
init =
    { sort = Unsorted, checked = [ "Kari Nordmann" ] }


update : Msg -> Model -> Model
update msg model =
    case msg of
        SortChanged next ->
            -- Like the React story, a third click on a column unsorts it:
            -- `Table.nextSort` would flip it back to ascending.
            case ( model.sort, next ) of
                ( SortedBy current Descending, SortedBy column Ascending ) ->
                    if current == column then
                        { model | sort = Unsorted }

                    else
                        { model | sort = next }

                _ ->
                    { model | sort = next }

        EmployeeChecked name True ->
            { model | checked = List.filter (\employee -> List.member employee (name :: model.checked)) employees }

        EmployeeChecked name False ->
            { model | checked = List.filter ((/=) name) model.checked }

        AllEmployeesChecked True ->
            { model | checked = employees }

        AllEmployeesChecked False ->
            { model | checked = [] }



-- STORIES


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Table", module_ = "Stories.Table", storybook = "komponenter-table" }
        [ Story.story "Preview" preview
        , Story.story "Numbers" numbers
        , Story.story "Sortable" (sortable model.sort)
        , Story.story "StickyHeader" stickyHeader
        , Story.story "WithFormElements" (withFormElements model.checked)
        , Story.story "FixedTable" fixedTable
        , Story.story "MultipleHeaderRows" multipleHeaderRows
        , Story.story "WithBorder" withBorder
            |> Story.withStoryCustomStyles [ ( "display", "grid" ), ( "gap", "1rem" ) ]
        ]


preview : List (Html msg)
preview =
    [ Table.view []
        [ Html.caption [] [ Html.text "Table caption" ]
        , Table.head []
            [ Table.row []
                [ Table.headerCell [] [ Html.text "Header 1" ]
                , Table.headerCell [] [ Html.text "Header 2" ]
                , Table.headerCell [] [ Html.text "Header 3" ]
                ]
            ]
        , Table.body []
            [ Table.row []
                [ Table.cell [] [ Html.text "Cell 1" ]
                , Table.cell [] [ Html.text "Cell 2" ]
                , Table.cell [] [ Html.text "Cell 3" ]
                ]
            , Table.row []
                [ Table.cell [] [ Html.text "Cell 4" ]
                , Table.cell [] [ Html.text "Cell 5" ]
                , Table.cell [] [ Html.text "Cell 6" ]
                ]
            ]
        , Table.foot []
            [ Table.row []
                [ Table.headerCell [] [ Html.text "Footer 1" ]
                , Table.headerCell [] [ Html.text "Footer 2" ]
                , Table.headerCell [] [ Html.text "Footer 3" ]
                ]
            ]
        ]
    ]


numbers : List (Html msg)
numbers =
    let
        month : String -> String -> String -> Html msg
        month name year2023 year2024 =
            Table.row []
                [ Table.headerCell [ Attr.scope "row" ] [ Html.text name ]
                , Table.cell [ Attr.style "text-align" "right" ] [ Html.text year2023 ]
                , Table.cell [ Attr.style "text-align" "right" ] [ Html.text year2024 ]
                ]
    in
    [ Table.view
        [ Table.zebra
        , Table.border
        , Attr.style "table-layout" "fixed"
        , Attr.style "font-variant-numeric" "tabular-nums"
        ]
        [ Html.caption [] [ Html.text "Antall søknader per måned" ]
        , Table.head []
            [ Table.row []
                [ Table.headerCell [ Attr.scope "col" ] [ Html.text "Måned" ]
                , Table.headerCell [ Attr.scope "col", Attr.style "text-align" "right" ] [ Html.text "2023" ]
                , Table.headerCell [ Attr.scope "col", Attr.style "text-align" "right" ] [ Html.text "2024" ]
                ]
            ]
        , Table.body []
            [ month "Januar" "1 230" "1 450"
            , month "Februar" "980" "1 120"
            , month "Mars" "1 150" "1 300"
            ]
        ]
    ]


sortable : Sort Column -> List (Html Msg)
sortable sort =
    let
        people : List Person
        people =
            [ { id = 1, navn = "Lise Nordmann", epost = "lise@nordmann.no", telefon = "22345678" }
            , { id = 2, navn = "Kari Nordmann", epost = "kari@nordmann.no", telefon = "87654321" }
            , { id = 3, navn = "Ola Nordmann", epost = "ola@nordmann.no", telefon = "32345678" }
            , { id = 4, navn = "Per Nordmann", epost = "per@nordmann.no", telefon = "12345678" }
            ]

        sorted : List Person
        sorted =
            case sort of
                Unsorted ->
                    people

                SortedBy column Ascending ->
                    List.sortBy (field column) people

                SortedBy column Descending ->
                    List.reverse (List.sortBy (field column) people)

        field : Column -> Person -> String
        field column =
            case column of
                Navn ->
                    .navn

                Telefon ->
                    .telefon
    in
    -- Every sortable header looks at the same `sort`, so only one column can
    -- be sorted, and its aria-sort and sort button follow from it.
    [ Table.view []
        [ Table.head []
            [ Table.row []
                [ Table.sortableHeaderCell { sort = sort, column = Navn, onSort = SortChanged } [] [ Html.text "Navn" ]
                , Table.headerCell [] [ Html.text "Epost" ]
                , Table.sortableHeaderCell { sort = sort, column = Telefon, onSort = SortChanged } [] [ Html.text "Telefon" ]
                ]
            ]
        , Table.keyedBody []
            (List.map
                (\person ->
                    ( String.fromInt person.id
                    , Table.row []
                        [ Table.cell [] [ Html.text person.navn ]
                        , Table.cell [] [ Html.text person.epost ]
                        , Table.cell [] [ Html.text person.telefon ]
                        ]
                    )
                )
                sorted
            )
        ]
    ]


stickyHeader : List (Html msg)
stickyHeader =
    [ Html.div [ Attr.style "height" "280px", Attr.style "overflow" "auto" ]
        [ Table.view [ Table.stickyHeader, Attr.tabindex 0 ]
            [ Table.head []
                [ Table.row []
                    [ Table.headerCell [] [ Html.text "Header 1" ]
                    , Table.headerCell [] [ Html.text "Header 2" ]
                    , Table.headerCell [] [ Html.text "Header 3" ]
                    ]
                ]
            , Table.body [] (List.map numberedRow (List.range 1 50))
            ]
        ]
    ]


withFormElements : List String -> List (Html Msg)
withFormElements checked =
    let
        allChecked : Bool
        allChecked =
            List.length checked == List.length employees

        someChecked : Bool
        someChecked =
            not (List.isEmpty checked) && not allChecked
    in
    [ Table.view []
        [ Table.head []
            [ Table.row []
                [ Table.headerCell []
                    [ Checkbox.new (Ds.ariaLabel "Velg alle ansatte")
                        |> Checkbox.view
                            (Attr.checked allChecked
                                :: Events.onCheck AllEmployeesChecked
                                :: (if someChecked then
                                        [ Input.indeterminate ]

                                    else
                                        []
                                   )
                            )
                    ]
                , Table.headerCell [] [ Html.text "Navn" ]
                , Table.headerCell [] [ Html.text "Stilling" ]
                , Table.headerCell [] [ Html.text "Kommentar" ]
                ]
            ]
        , Table.keyedBody []
            (List.map
                (\name ->
                    ( name
                    , Table.row []
                        [ Table.cell []
                            [ Checkbox.new (Ds.ariaLabel ("Velg " ++ name))
                                |> Checkbox.view
                                    [ Attr.name "my-checkbox"
                                    , Attr.value name
                                    , Attr.checked (List.member name checked)
                                    , Events.onCheck (EmployeeChecked name)
                                    ]
                            ]
                        , Table.cell [] [ Html.text name ]
                        , Table.cell [] [ Html.text "Rådgiver" ]
                        , Table.cell []
                            [ Textfield.new (Ds.ariaLabel ("Textfield " ++ name))
                                |> Textfield.withFieldAttributes [ Ds.size Size.sm ]
                                |> Textfield.view []
                            ]
                        ]
                    )
                )
                employees
            )
        ]
    ]


fixedTable : List (Html msg)
fixedTable =
    [ Table.view [ Attr.style "table-layout" "fixed" ]
        [ Table.head []
            [ Table.row []
                [ Table.headerCell [] [ Html.text "Header 1" ]
                , Table.headerCell [] [ Html.text "Header 2" ]
                , Table.headerCell [] [ Html.text "Header 3" ]
                ]
            ]
        , Table.body [] (List.map numberedRow (List.range 1 3))
        ]
    ]


multipleHeaderRows : List (Html msg)
multipleHeaderRows =
    [ Table.view []
        [ Table.head []
            [ Table.row []
                [ Table.headerCell [] [ Html.text "Header 1" ]
                , Table.headerCell [ Attr.colspan 2 ] [ Html.text "Header 2" ]
                ]
            , Table.row []
                [ Table.headerCell [] [ Html.text "Header 3" ]
                , Table.headerCell [] [ Html.text "Header 4" ]
                , Table.headerCell [] [ Html.text "Header 5" ]
                ]
            ]
        , Table.body [] (List.map numberedRow (List.range 1 50))
        ]
    ]


withBorder : List (Html msg)
withBorder =
    let
        rows : List (Html msg)
        rows =
            List.map numberedRow (List.range 1 3)
    in
    [ Table.view [ Table.border ]
        [ Table.body [] rows
        , Table.body [] rows
        ]
    , Table.view [ Table.border ]
        [ Table.head []
            [ Table.row []
                [ Table.headerCell [] [ Html.text "Header 3" ]
                , Table.headerCell [] [ Html.text "Header 4" ]
                , Table.headerCell [] [ Html.text "Header 5" ]
                ]
            ]
        , Table.body [] rows
        ]
    , Table.view [ Table.border ]
        [ Table.body [] rows
        , Table.foot []
            [ Table.row []
                [ Table.headerCell [] [ Html.text "Footer 1" ]
                , Table.headerCell [] [ Html.text "Footer 2" ]
                , Table.headerCell [] [ Html.text "Footer 3" ]
                ]
            ]
        ]
    ]



-- HELPERS


{-| Row `n` of the generated tables: "Cell n1", "Cell n2", "Cell n3".
-}
numberedRow : Int -> Html msg
numberedRow n =
    Table.row []
        (List.map
            (\column -> Table.cell [] [ Html.text ("Cell " ++ String.fromInt n ++ String.fromInt column) ])
            [ 1, 2, 3 ]
        )


employees : List String
employees =
    [ "Kari Nordmann", "Ola Nordmann", "Jens Nordmann" ]
