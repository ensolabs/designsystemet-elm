module Stories.Dropdown exposing (chapter)

{-| `dropdown.stories.tsx`, story for story.

React's `Dropdown.TriggerContext` isn't needed: a `Dropdown.Id` links the
trigger and the dropdown. React's `open` is `Dropdown.open`, kept in step by
the companion script (`js/open-state.js`); `Dropdown.onToggle` covers
`onOpen` and `onClose`.

-}

import Designsystemet.Button as Button
import Designsystemet.Dialog as Dialog
import Designsystemet.Dropdown as Dropdown
import Designsystemet.Heading as Heading
import Designsystemet.Placement as Placement
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icons
import Showcase.Story as Story exposing (Chapter)
import Stories.Interactive.State exposing (Model, Msg(..))


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Dropdown", module_ = "Stories.Dropdown", storybook = "komponenter-dropdown" }
        [ Story.story "Preview" preview
        , Story.story "Icons" icons
        , Story.story "Controlled" (controlled model)
        , Story.story "ControlledExternalTrigger" (controlledExternalTrigger model)
        , Story.story "WithoutTrigger" withoutTrigger
        , Story.story "WithNestedDialog" withNestedDialog
        , Story.story "WithAdjacentDialog" withAdjacentDialog
        , Story.story "WithNestedDropdown" withNestedDropdown
        ]
        |> Story.withCustomStyles [ ( "display", "grid" ), ( "align-items", "start" ), ( "justify-items", "center" ) ]
        |> Story.withLayout Story.Fullscreen


preview : List (Html msg)
preview =
    let
        dropdown : Dropdown.Id
        dropdown =
            Dropdown.id "dropdown-preview"
    in
    [ Dropdown.trigger dropdown [] [ Html.text "Dropdown" ]
    , Dropdown.view dropdown
        [ Dropdown.placement Placement.BottomEnd ]
        [ Dropdown.heading Heading.H2 [] [ Html.text "First heading" ]
        , Dropdown.list []
            [ Dropdown.item [] [ Dropdown.button [] [ Html.text "Button 1.1" ] ]
            , Dropdown.item [] [ Dropdown.button [] [ Html.text "Button 1.2" ] ]
            ]
        , Dropdown.heading Heading.H2 [] [ Html.text "Second heading" ]
        , Dropdown.list []
            [ Dropdown.item [] [ Dropdown.button [] [ Html.text "Button 2.1" ] ]
            , Dropdown.item [] [ Dropdown.button [] [ Html.text "Button 2.2" ] ]
            ]
        ]
    ]


icons : List (Html msg)
icons =
    let
        dropdown : Dropdown.Id
        dropdown =
            Dropdown.id "dropdown-icons"
    in
    -- A menu item that is a link: a tertiary button styled `<a>`.
    [ Dropdown.trigger dropdown [] [ Html.text "Dropdown" ]
    , Dropdown.view dropdown
        []
        [ Dropdown.list []
            [ Dropdown.item []
                [ Button.viewAs Html.a
                    [ Button.tertiary, Attr.href "https://github.com/digdir/designsystemet", Attr.target "_blank", Attr.rel "noreferrer" ]
                    [ Icons.link [], Html.text "Github" ]
                ]
            , Dropdown.item []
                [ Button.viewAs Html.a
                    [ Button.tertiary, Attr.href "https://designsystemet.no", Attr.target "_blank", Attr.rel "noreferrer" ]
                    [ Icons.link [], Html.text "Designsystemet.no" ]
                ]
            ]
        ]
    ]


controlled : Model -> List (Html Msg)
controlled model =
    let
        dropdown : Dropdown.Id
        dropdown =
            Dropdown.id "dropdown-controlled"
    in
    [ Dropdown.trigger dropdown
        []
        [ Html.text "Dropdown"
        , if model.dropdownOpen then
            Icons.chevronDown []

          else
            Icons.chevronUp []
        ]
    , Dropdown.view dropdown
        [ Dropdown.open model.dropdownOpen
        , Dropdown.onToggle (\state -> DropdownOpenChanged (state == Dropdown.Open))
        ]
        [ Dropdown.list []
            [ Dropdown.item [] [ Dropdown.button [ Events.onClick (DropdownOpenChanged False) ] [ Html.text "Trykk på meg lukker" ] ]
            , Dropdown.item [] [ Dropdown.button [ Events.onClick (DropdownOpenChanged False) ] [ Html.text "Eg lukker også" ] ]
            ]
        ]
    ]


controlledExternalTrigger : Model -> List (Html Msg)
controlledExternalTrigger model =
    let
        dropdown : Dropdown.Id
        dropdown =
            Dropdown.id "dropdown-external-trigger"
    in
    [ Button.view (Dropdown.toggle dropdown) [ Html.text "Dropdown" ]
    , Dropdown.view dropdown
        [ Dropdown.open model.dropdownExternalOpen
        , Dropdown.onToggle (\state -> DropdownExternalOpenChanged (state == Dropdown.Open))
        ]
        [ Dropdown.list []
            [ Dropdown.item [] [ Dropdown.button [] [ Html.text "Item" ] ] ]
        ]
    ]


withoutTrigger : List (Html msg)
withoutTrigger =
    let
        dropdown : Dropdown.Id
        dropdown =
            Dropdown.id "dropdown-without-trigger"
    in
    [ Button.view (Dropdown.toggle dropdown) [ Html.text "Dropdown" ]
    , Dropdown.view dropdown
        []
        [ Dropdown.list []
            [ Dropdown.item [] [ Dropdown.button [] [ Html.text "Item" ] ] ]
        ]
    ]


withNestedDialog : List (Html msg)
withNestedDialog =
    let
        dropdown : Dropdown.Id
        dropdown =
            Dropdown.id "dropdown-nested-dialog"

        dialog : Dialog.Id
        dialog =
            Dialog.id "dropdown-nested-dialog-dialog"
    in
    [ Dropdown.trigger dropdown [] [ Html.text "Dropdown" ]
    , Dropdown.view dropdown
        []
        [ Dropdown.list []
            [ Dropdown.item []
                [ Dropdown.button (Dialog.showModal dialog) [ Html.text "Dialog" ]
                , Dialog.new dialog
                    |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
                    |> Dialog.view [] [ Html.text "Min dialog" ]
                ]
            ]
        ]
    ]


withAdjacentDialog : List (Html msg)
withAdjacentDialog =
    let
        dropdown : Dropdown.Id
        dropdown =
            Dropdown.id "dropdown-adjacent-dialog"

        dialog : Dialog.Id
        dialog =
            Dialog.id "adjacent-modal"
    in
    [ Dropdown.trigger dropdown [] [ Html.text "Dropdown" ]
    , Dropdown.view dropdown
        []
        [ Dropdown.list []
            [ Dropdown.item [] [ Dropdown.button (Dialog.showModal dialog) [ Html.text "Dialog" ] ] ]
        ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [] [ Html.text "Min dialog" ]
    ]


withNestedDropdown : List (Html msg)
withNestedDropdown =
    let
        outer : Dropdown.Id
        outer =
            Dropdown.id "dropdown-nested-outer"

        inner : Dropdown.Id
        inner =
            Dropdown.id "dropdown-nested-inner"
    in
    [ Dropdown.trigger outer [] [ Html.text "Dropdown" ]
    , Dropdown.view outer
        []
        [ Dropdown.list []
            [ Dropdown.item []
                [ Dropdown.trigger inner [ Button.tertiary ] [ Html.text "Dropdown" ]
                , Dropdown.view inner
                    []
                    [ Dropdown.list []
                        [ Dropdown.item [] [ Dropdown.button [] [ Html.text "Nested" ] ] ]
                    ]
                ]
            ]
        ]
    ]
