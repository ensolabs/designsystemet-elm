module Designsystemet.Popover exposing
    ( Id, id, idToString
    , view
    , tinted, placement, noAutoPlacement
    , trigger, inlineTrigger
    , toggle, show, hide
    , open, State(..), onToggle
    )

{-| A small box of content floating next to the button that opened it.

Mirrors `Popover` from `@digdir/designsystemet-react`.

    import Designsystemet.Popover as Popover

    deleteInfo : Popover.Id
    deleteInfo =
        Popover.id "delete-info"

    view : Html Msg
    view =
        Html.div []
            [ Popover.trigger deleteInfo [] [ Html.text "Hva skjer når jeg sletter?" ]
            , Popover.view deleteInfo
                [ Popover.placement Placement.Bottom ]
                [ Html.text "Saken flyttes til papirkurven i 30 dager." ]
            ]

It's a native [`popover`](https://developer.mozilla.org/en-US/docs/Web/API/Popover_API):
the browser opens it on a trigger click and closes it on Esc or a click
outside, and `designsystemet-web` positions it next to the trigger. Your model
doesn't have to track whether it's open. Use [`onToggle`](#onToggle) to find
out, or [`open`](#open) to open it from your model.


# React → Elm

  - `<Popover id="x">` → `Popover.view (Popover.id "x") []`
  - `<Popover.TriggerContext>` → not needed: share a `Popover.Id`
  - `<Popover.Trigger>` → `Popover.trigger id []`
  - `<Popover.Trigger inline>` → `Popover.inlineTrigger id []`
  - `<Button popovertarget="x">` → `Button.view (Popover.toggle id)`
  - `variant="tinted"` → `Popover.tinted`
  - `placement="bottom"` → `Popover.placement Placement.Bottom`
  - `autoPlacement={false}` → `Popover.noAutoPlacement`
  - `onOpen` / `onClose` → `Popover.onToggle`
  - `open={isOpen}` + `onOpen`/`onClose` → `Popover.open model.isOpen`, `Popover.onToggle Toggled`


# Differences from React

  - The popover is `popover="auto"`. React uses `"manual"` and implements
    light dismiss (Esc, click outside) in JavaScript, which the browser does
    for `"auto"` popovers anyway. Pass `Attr.attribute "popover" "manual"` for
    a popover that stays open while others open.
  - `Popover.inlineTrigger` is `type="button"`, so it never submits a form.
  - React accepts `autoPlacement={false}` but never renders it, so it has no
    effect there. [`noAutoPlacement`](#noAutoPlacement) writes the
    `data-autoplacement="false"` that `designsystemet-web` reads.


# Managed by designsystemet-web

While it is open, `designsystemet-web` positions the popover by writing
inline styles (`translate`, `scroll-margin-bottom`, and for lists that scroll
`max-height` and `width`), the arrow's `--_ds-floating-arrow-x`/`-y`
properties, and `data-floating`. Don't set those yourself, and style the
popover with classes rather than `Attr.style`.


# Opening from your model

To open a popover from your model (say, a hint after a save), use
[`open`](#open). Only `showPopover()` can open a popover, so `open` renders
`data-open` and the package's JavaScript (`@ensolabs/designsystemet-elm`,
imported once) syncs the element. `designsystemet-web` positions the popover
next to the element whose `popovertarget` points at it, so you still need a
trigger.

    Popover.view saveHint
        [ Popover.open model.showSaveHint
        , Popover.onToggle SaveHintToggled
        ]
        [ Html.text "Lagret!" ]

The browser still closes it on Esc or a click outside, so handle
[`onToggle`](#onToggle) and set your state to `Closed`.


# Ids

@docs Id, id, idToString


# Popover

@docs view


# Appearance

@docs tinted, placement, noAutoPlacement


# Triggers

A trigger is any button with one of the invoker attribute lists below.
[`trigger`](#trigger) is a Designsystemet `Button` that toggles the popover.

@docs trigger, inlineTrigger


# Invokers

These put `popovertarget` (and `popovertargetaction`) on any `<button>`, be it
a [`Button`](Designsystemet-Button), a [`Chip`](Designsystemet-Chip) or a plain
one. They are lists because the browser needs two attributes. Concatenate them
with your own:

    Button.view (Button.secondary :: Popover.toggle filters) [ Html.text "Filter" ]

@docs toggle, show, hide


# State

@docs open, State, onToggle

-}

import Designsystemet.Button as Button
import Designsystemet.Internal.Attributes as Internal
import Designsystemet.Placement as Placement exposing (Placement)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Decode



-- ID


{-| The `id` that links a popover to the buttons that open it.

Make one per popover as a top-level value and use it in both places. The type
keeps you from passing it to a [`Dialog`](Designsystemet-Dialog) by mistake.

-}
type Id
    = Id String


{-| Name a popover. The string becomes its DOM `id`, so it must be unique on
the page.

    filters : Popover.Id
    filters =
        Popover.id "case-list-filters"

-}
id : String -> Id
id =
    Id


{-| The DOM `id`, for ports and tests.
-}
idToString : Id -> String
idToString (Id value) =
    value



-- VIEW


{-| A `<div class="ds-popover" popover>`, placed above its trigger by default.

The `id` always comes from the [`Id`](#Id) so the triggers keep pointing at it.
An `Attr.id` in the attributes is ignored.

-}
view : Id -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
view (Id popoverId) attributes =
    Html.div
        (Attr.class "ds-popover"
            :: Attr.attribute "popover" "auto"
            :: placement Placement.Top
            :: attributes
            ++ [ Attr.id popoverId ]
        )



-- APPEARANCE


{-| A tinted background instead of the default surface color.
-}
tinted : Html.Attribute msg
tinted =
    Internal.data "variant" "tinted"


{-| Which side of the trigger the popover appears on. Defaults to
`Placement.Top`.
-}
placement : Placement -> Html.Attribute msg
placement =
    Internal.data "placement" << Placement.toString


{-| Keep the popover on the requested side even when there is no room. By
default `designsystemet-web` flips it to the opposite side.
-}
noAutoPlacement : Html.Attribute msg
noAutoPlacement =
    Internal.data "autoplacement" "false"



-- TRIGGERS


{-| A [`Button`](Designsystemet-Button) that opens and closes the popover.

    Popover.trigger help [ Button.tertiary ] [ Html.text "Hjelp" ]

-}
trigger : Id -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
trigger popoverId attributes =
    Button.view (toggle popoverId ++ attributes)


{-| A trigger styled as a word in running text, with a dotted underline:

    Html.p []
        [ Html.text "Søknaden må ha "
        , Popover.inlineTrigger orgNumberHelp [] [ Html.text "organisasjonsnummer" ]
        , Html.text "."
        ]

-}
inlineTrigger : Id -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
inlineTrigger popoverId attributes =
    Html.button
        (Attr.type_ "button"
            :: Internal.data "popover" "inline"
            :: (toggle popoverId ++ attributes)
        )



-- INVOKERS


{-| Open the popover if closed, close it if open. This is what a trigger does.
-}
toggle : Id -> List (Html.Attribute msg)
toggle (Id popoverId) =
    [ Attr.attribute "popovertarget" popoverId ]


{-| Open the popover, or leave it open.
-}
show : Id -> List (Html.Attribute msg)
show =
    withAction "show"


{-| Close the popover, or leave it closed. Use it for a "close" button inside
the popover:

    Button.view (Button.tertiary :: Popover.hide filters) [ Html.text "Lukk" ]

-}
hide : Id -> List (Html.Attribute msg)
hide =
    withAction "hide"


withAction : String -> Id -> List (Html.Attribute msg)
withAction action popoverId =
    toggle popoverId ++ [ Attr.attribute "popovertargetaction" action ]



-- EVENTS


{-| Whether a popover is showing.
-}
type State
    = Open
    | Closed


{-| Whether the popover is open, from your model. See
[Opening from your model](#opening-from-your-model).
-}
open : Bool -> Html.Attribute msg
open isOpen =
    Internal.data "open"
        (if isOpen then
            "true"

         else
            "false"
        )


{-| Get a message when the popover opens or closes, for any reason: the
trigger, Esc, a click outside, or code.

    Popover.view filters [ Popover.onToggle FiltersToggled ] [{- … -}]

The native `toggle` event, covering React's `onOpen` and `onClose`.

-}
onToggle : (State -> msg) -> Html.Attribute msg
onToggle toMsg =
    Events.on "toggle" (Decode.map toMsg stateDecoder)


stateDecoder : Decode.Decoder State
stateDecoder =
    Decode.field "newState" Decode.string
        |> Decode.andThen
            (\state ->
                case state of
                    "open" ->
                        Decode.succeed Open

                    "closed" ->
                        Decode.succeed Closed

                    _ ->
                        Decode.fail ("Unknown popover state: " ++ state)
            )
