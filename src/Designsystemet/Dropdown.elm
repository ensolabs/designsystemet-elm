module Designsystemet.Dropdown exposing
    ( Id, id, idToString
    , view, placement
    , heading, list, item, button
    , trigger
    , toggle, show, hide
    , open, onToggle, State(..)
    )

{-| A menu of actions or links that opens from a button.

Mirrors `Dropdown` from `@digdir/designsystemet-react`.

    import Designsystemet.Dropdown as Dropdown

    caseActions : Dropdown.Id
    caseActions =
        Dropdown.id "case-actions"

    view : Html Msg
    view =
        Html.div []
            [ Dropdown.trigger caseActions [ Button.secondary ] [ Html.text "Handlinger" ]
            , Dropdown.view caseActions
                []
                [ Dropdown.heading Heading.H2 [] [ Html.text "Sak 42" ]
                , Dropdown.list []
                    [ Dropdown.item [] [ Dropdown.button [ Events.onClick Archive ] [ Html.text "Arkiver" ] ]
                    , Dropdown.item [] [ Dropdown.button (Dialog.showModal confirmDelete) [ Html.text "Slett" ] ]
                    ]
                ]
            ]

A dropdown is a [`Popover`](Designsystemet-Popover) with menu styling. The
browser opens it from the trigger and closes it on Esc or an outside click;
`designsystemet-web` positions it. `Dropdown.Id` is a separate type, so a
popover's id can't open a dropdown by mistake.


# React → Elm

  - `<Dropdown id="x">` → `Dropdown.view (Dropdown.id "x") []`
  - `<Dropdown.TriggerContext>` → not needed: share a `Dropdown.Id`
  - `<Dropdown.Trigger>` → `Dropdown.trigger id []`
  - `<Dropdown.Heading>` (level 2 by default) → `Dropdown.heading Heading.H2 []`
  - `<Dropdown.List>` → `Dropdown.list []`
  - `<Dropdown.Item>` → `Dropdown.item []`
  - `<Dropdown.Button>` → `Dropdown.button []`
  - `placement="top"` → `Dropdown.placement Placement.Top`
  - `open={isOpen}` (controlled) → `Dropdown.open model.isOpen`
  - `onOpen` / `onClose` → `Dropdown.onToggle`


# Differences from React

Like [`Popover`](Designsystemet-Popover), the dropdown is `popover="auto"`,
so the browser handles light dismiss, which React does in JavaScript.


# Managed by designsystemet-web

As for [`Popover`](Designsystemet-Popover): the position styles
(`translate`, `scroll-margin-bottom`, `max-height`, `width`), the arrow's
`--_ds-floating-arrow-*` properties and `data-floating`. Style the dropdown
with classes instead of `Attr.style`.


# Ids

@docs Id, id, idToString


# Dropdown

@docs view, placement


# Content

@docs heading, list, item, button


# Triggers

@docs trigger


# Invokers

@docs toggle, show, hide


# Events

@docs open, onToggle, State

-}

import Designsystemet.Button as Button
import Designsystemet.Heading as Heading
import Designsystemet.Internal.Attributes as Internal
import Designsystemet.Placement as Placement exposing (Placement)
import Designsystemet.Popover as Popover
import Html exposing (Html)
import Html.Attributes as Attr



-- ID


{-| The `id` that links a dropdown to the buttons that open it.
-}
type Id
    = Id Popover.Id


{-| Name a dropdown. The string becomes its DOM `id`, so it must be unique on
the page.
-}
id : String -> Id
id =
    Popover.id >> Id


{-| The DOM `id`, for ports and tests.
-}
idToString : Id -> String
idToString (Id popoverId) =
    Popover.idToString popoverId



-- DROPDOWN


{-| A `<div class="ds-dropdown" popover>`, by default below its trigger and
aligned to its end edge.

The `id` always comes from the [`Id`](#Id), so triggers keep pointing at it.
An `Attr.id` in the attributes is ignored.

-}
view : Id -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
view dropdownId attributes =
    Html.div
        (Attr.class "ds-dropdown"
            :: Attr.attribute "popover" "auto"
            :: placement Placement.BottomEnd
            :: attributes
            ++ [ Attr.id (idToString dropdownId) ]
        )


{-| Where the dropdown appears relative to its trigger. Defaults to
`Placement.BottomEnd`.
-}
placement : Placement -> Html.Attribute msg
placement =
    Internal.data "placement" << Placement.toString



-- CONTENT


{-| A heading for the menu or a group in it. As with
[`Heading`](Designsystemet-Heading), the level is required. React defaults to
`H2`, but the right level depends on the surrounding page.

    Dropdown.heading Heading.H3 [] [ Html.text "Sortering" ]

-}
heading : Heading.Level -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
heading =
    Heading.view


{-| The `<ul>` of menu items. To group items, use several, each after its own
[`heading`](#heading).
-}
list : List (Html.Attribute msg) -> List (Html msg) -> Html msg
list =
    Html.ul


{-| One `<li>` in a [`list`](#list). Put a [`button`](#button) or a link in it.
-}
item : List (Html.Attribute msg) -> List (Html msg) -> Html msg
item =
    Html.li


{-| A full-width, tertiary [`Button`](Designsystemet-Button) for a menu item.

For a link, use `Button.viewAs Html.a [ Button.tertiary, Attr.href "…" ]`.
The dropdown styles it the same way.

-}
button : List (Html.Attribute msg) -> List (Html msg) -> Html msg
button attributes =
    Button.view (Button.tertiary :: attributes)



-- TRIGGERS


{-| A [`Button`](Designsystemet-Button) that opens and closes the dropdown.

    Dropdown.trigger userMenu [ Button.tertiary ] [ Html.text "Kari Nordmann" ]

-}
trigger : Id -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
trigger (Id popoverId) =
    Popover.trigger popoverId



-- INVOKERS


{-| Open the dropdown if closed, close it if open. Concatenate with your own
attributes on any button:

    Button.icon { label = "Flere valg", icon = moreIcon }
        (Button.tertiary :: Dropdown.toggle rowMenu)

-}
toggle : Id -> List (Html.Attribute msg)
toggle (Id popoverId) =
    Popover.toggle popoverId


{-| Open the dropdown, or leave it open.
-}
show : Id -> List (Html.Attribute msg)
show (Id popoverId) =
    Popover.show popoverId


{-| Close the dropdown, or leave it closed. On a menu item, it closes the menu
when the item is chosen:

    Dropdown.button (Events.onClick Archive :: Dropdown.hide caseActions)
        [ Html.text "Arkiver" ]

-}
hide : Id -> List (Html.Attribute msg)
hide (Id popoverId) =
    Popover.hide popoverId



-- EVENTS


{-| Whether the dropdown is open, from your model (React's `open` prop). Like
[`Popover.open`](Designsystemet-Popover#open), it needs the companion script
and an [`onToggle`](#onToggle) that updates your state when the user closes it.
-}
open : Bool -> Html.Attribute msg
open =
    Popover.open


{-| Whether a dropdown is showing.
-}
type State
    = Open
    | Closed


{-| Sent when the dropdown opens or closes, by the trigger, Esc, an outside
click or code. See
[`Popover.onToggle`](Designsystemet-Popover#onToggle).
-}
onToggle : (State -> msg) -> Html.Attribute msg
onToggle toMsg =
    Popover.onToggle (fromPopoverState >> toMsg)


fromPopoverState : Popover.State -> State
fromPopoverState state =
    case state of
        Popover.Open ->
            Open

        Popover.Closed ->
            Closed
