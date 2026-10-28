module Designsystemet.Dialog exposing
    ( Id, id, idToString
    , Dialog, new, withCloseButton, view
    , block
    , drawer, Side(..)
    , open, nonModal
    , closedByAny, closedByCloseRequest, closedByNone
    , onClose
    , trigger
    , showModal, showNonModal, close, requestClose
    )

{-| A dialog over the page, for a task or message the user must deal with
before continuing.

Mirrors `Dialog` from `@digdir/designsystemet-react`.

    import Designsystemet.Button as Button
    import Designsystemet.Dialog as Dialog

    confirmDelete : Dialog.Id
    confirmDelete =
        Dialog.id "confirm-delete"

    view : Html Msg
    view =
        Html.div []
            [ Dialog.trigger confirmDelete [] [ Html.text "Slett sak" ]
            , Dialog.new confirmDelete
                |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
                |> Dialog.view [ Dialog.onClose DeleteDialogClosed ]
                    [ Dialog.block [] [ Heading.h2 [] [ Html.text "Slette saken?" ] ]
                    , Dialog.block []
                        [ Button.view [ Events.onClick Delete ] [ Html.text "Slett" ]
                        , Button.view (Button.secondary :: Dialog.close confirmDelete)
                            [ Html.text "Avbryt" ]
                        ]
                    ]
            ]

The dialog is a native [`<dialog>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dialog).
Open it in one of two ways:

  - From a button, with an [invoker](#invokers) (`command`/`commandfor`,
    polyfilled by `designsystemet-web`). No message or model field needed.
  - From your model, with [`open`](#open) and a `Bool`. This is React's `open`
    prop, for dialogs opened by an event (a timeout, a failed save) rather
    than a click.


# React → Elm

  - `<Dialog id="x">` → `Dialog.new (Dialog.id "x") |> Dialog.view [] […]`
  - `closeButton="Lukk"` (the default) → `Dialog.withCloseButton { label = "Lukk" }`
  - `closeButton={false}` → leave out `withCloseButton`
  - `<Dialog.Block>` → `Dialog.block []`
  - `<Dialog.TriggerContext>` → not needed: share a `Dialog.Id`
  - `<Dialog.Trigger>` → `Dialog.trigger id []`
  - `<Button command="show-modal" commandfor="x">` → `Button.view (Dialog.showModal id)`
  - `modal={false}` → `Dialog.nonModal`, or open with `Dialog.showNonModal id`
  - `placement="right"` → `Dialog.drawer Dialog.Right`
  - `closedby="any"` → `Dialog.closedByAny`
  - `onClose` → `Dialog.onClose msg`
  - `open={isOpen}` + `onClose` → `Dialog.open model.isOpen`, `Dialog.onClose Closed`


# Differences from React

  - The close button is opt-in and its label is required. There is no
    Norwegian default.


# Managed by designsystemet-web

  - `aria-haspopup="dialog"` on every button that opens a dialog, set on
    focus. [`trigger`](#trigger) also renders it up front, as React's
    `Dialog.Trigger` does. The value is the same, so they don't conflict.
  - the `closedby="any"` light dismiss, in browsers without native support.


# Opening from your model

Opening a dialog takes a method call (`showModal()`), which Elm can't make.
[`open`](#open) renders the state as `data-open`, and the package's
JavaScript syncs the element:

```js
import "@ensolabs/designsystemet-elm"; // once, in your entry point
```

    Dialog.new sessionExpired
        |> Dialog.view
            [ Dialog.open model.sessionExpired
            , Dialog.onClose SessionDialogClosed
            ]
            [{- … -}]

When the user closes the dialog (Esc, a close button), it closes and sends
[`onClose`](#onClose). Set your state back to closed there. Until you do,
`open True` won't reopen it, since the attribute hasn't changed.


# Ids

@docs Id, id, idToString


# Dialog

@docs Dialog, new, withCloseButton, view


# Content

@docs block


# Placement

@docs drawer, Side


# Open state

@docs open, nonModal


# Light dismiss

How the user can close the dialog without a close button. The default is
`closedByCloseRequest` for modal dialogs (Esc closes it).

@docs closedByAny, closedByCloseRequest, closedByNone


# Events

@docs onClose


# Triggers

@docs trigger


# Invokers

`command` and `commandfor` for any `<button>`: a
[`Button`](Designsystemet-Button), a [`Dropdown`](Designsystemet-Dropdown)
item or a plain button. They are lists because the browser needs two
attributes. Concatenate them with your own:

    Button.view (Button.secondary :: Dialog.close confirmDelete) [ Html.text "Avbryt" ]

@docs showModal, showNonModal, close, requestClose

-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Decode



-- ID


{-| The `id` that links a dialog to the buttons that open and close it.

Make one per dialog, as a top-level value, and use it in both places. A
`Dialog.Id` can't be given to a [`Popover`](Designsystemet-Popover) by
mistake.

-}
type Id
    = Id String


{-| Name a dialog. The string becomes its DOM `id`, so it must be unique on
the page.

    confirmDelete : Dialog.Id
    confirmDelete =
        Dialog.id "confirm-delete"

-}
id : String -> Id
id =
    Id


{-| The DOM `id`, for ports and tests.
-}
idToString : Id -> String
idToString (Id value) =
    value



-- DIALOG


{-| A dialog being configured. Start with [`new`](#new), finish with
[`view`](#view).
-}
type Dialog
    = Dialog
        { id : Id
        , closeButton : Maybe String
        }


{-| A dialog with no close button.
-}
new : Id -> Dialog
new dialogId =
    Dialog { id = dialogId, closeButton = Nothing }


{-| Add an "×" close button in the top corner. It has no visible text, so
`label` is what screen readers announce.

    Dialog.new confirmDelete
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [] [{- … -}]

-}
withCloseButton : { label : String } -> Dialog -> Dialog
withCloseButton { label } (Dialog config) =
    Dialog { config | closeButton = Just label }


{-| A `<dialog class="ds-dialog">`, closed unless you give it [`open`](#open).

Put content directly in it, or split it into [`block`](#block)s with their own
padding and dividers.

The `id` always comes from the [`Id`](#Id) given to [`new`](#new), so triggers
keep pointing at it. An `Attr.id` in the attributes is ignored.

-}
view : List (Html.Attribute msg) -> List (Html msg) -> Dialog -> Html msg
view attributes children (Dialog config) =
    Html.node "dialog"
        (Attr.class "ds-dialog"
            :: Internal.data "placement" "center"
            :: Internal.data "modal" "true"
            :: attributes
            ++ [ Attr.id (idToString config.id) ]
        )
        (case config.closeButton of
            Just label ->
                closeButton label config.id :: children

            Nothing ->
                children
        )


{-| No children: the CSS draws the "×" into an empty button.
-}
closeButton : String -> Id -> Html msg
closeButton label dialogId =
    Button.view
        (Attr.attribute "aria-label" label
            :: Ds.color Color.neutral
            :: Internal.data "icon" "true"
            :: Button.tertiary
            :: close dialogId
        )
        []



-- CONTENT


{-| A section of the dialog, like a header, the body or a footer of buttons.

    Dialog.view []
        [ Dialog.block [] [ Heading.h2 [] [ Html.text "Endre adresse" ] ]
        , Dialog.block [] [ addressForm ]
        , Dialog.block [] [ saveButton, cancelButton ]
        ]
        dialog

-}
block : List (Html.Attribute msg) -> List (Html msg) -> Html msg
block attributes =
    Html.div (Attr.class "ds-dialog__block" :: attributes)



-- PLACEMENT


{-| The edge of the screen a drawer slides in from.
-}
type Side
    = Left
    | Right
    | Top
    | Bottom


{-| Show the dialog as a drawer along one edge of the screen instead of in the
center.

    Dialog.view [ Dialog.drawer Dialog.Right ] [ filterForm ] filters

-}
drawer : Side -> Html.Attribute msg
drawer side =
    Internal.data "placement" <|
        case side of
            Left ->
                "left"

            Right ->
                "right"

            Top ->
                "top"

            Bottom ->
                "bottom"



-- LIGHT DISMISS


{-| Close on Esc and on a backdrop click. Good for dialogs that only show
information.
-}
closedByAny : Html.Attribute msg
closedByAny =
    Attr.attribute "closedby" "any"


{-| Close on Esc (or the Android back gesture), but not on a click
outside.
-}
closedByCloseRequest : Html.Attribute msg
closedByCloseRequest =
    Attr.attribute "closedby" "closerequest"


{-| Close only from a button in the dialog. Use sparingly, since the user has
no other way out.
-}
closedByNone : Html.Attribute msg
closedByNone =
    Attr.attribute "closedby" "none"



-- EVENTS


{-| Whether the dialog is open, from your model. Needs the companion script
(see [Opening from your model](#opening-from-your-model)), and an
[`onClose`](#onClose) that sets your state back when the user closes it.

    Dialog.view [ Dialog.open model.confirming, Dialog.onClose ConfirmClosed ] [{- … -}]

-}
open : Bool -> Html.Attribute msg
open isOpen =
    Internal.data "open"
        (if isOpen then
            "true"

         else
            "false"
        )


{-| No backdrop, and the page behind stays usable, when opened with
[`open`](#open). React's `modal={false}`. Invoker buttons choose for
themselves with [`showNonModal`](#showNonModal).
-}
nonModal : Html.Attribute msg
nonModal =
    Internal.data "modal" "false"


{-| Sent when the dialog closes, by a close button, Esc, a backdrop click or
code.

    Dialog.view [ Dialog.onClose EditDialogClosed ] [{- … -}] editDialog

The native `close` event. It doesn't bubble, so a nested dialog never
triggers it.

-}
onClose : msg -> Html.Attribute msg
onClose msg =
    Events.on "close" (Decode.succeed msg)



-- TRIGGERS


{-| A [`Button`](Designsystemet-Button) that opens the dialog as a modal
(React's `Dialog.Trigger`).

    Dialog.trigger editAddress [ Button.secondary ] [ Html.text "Endre adresse" ]

For a non-modal dialog, use [`showNonModal`](#showNonModal) on a button
instead.

-}
trigger : Id -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
trigger dialogId attributes =
    Button.view (Attr.attribute "aria-haspopup" "dialog" :: showModal dialogId ++ attributes)



-- INVOKERS


{-| Open the dialog as a modal: the rest of the page is inert behind a
backdrop until it closes.
-}
showModal : Id -> List (Html.Attribute msg)
showModal =
    command "show-modal"


{-| Open the dialog without a backdrop, leaving the rest of the page usable.
-}
showNonModal : Id -> List (Html.Attribute msg)
showNonModal =
    command "--show-non-modal"


{-| Close the dialog immediately, as a "Cancel" button does.
-}
close : Id -> List (Html.Attribute msg)
close =
    command "close"


{-| Ask the dialog to close, as Esc does. It fires a cancelable `cancel` event
first, for example to warn about unsaved changes.
-}
requestClose : Id -> List (Html.Attribute msg)
requestClose =
    command "request-close"


command : String -> Id -> List (Html.Attribute msg)
command name (Id dialogId) =
    [ Attr.attribute "command" name
    , Attr.attribute "commandfor" dialogId
    ]
