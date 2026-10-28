module Designsystemet.ToggleGroup exposing
    ( uncontrolled, controlled
    , Item, item, iconItem
    , disabled, disabledFocusable, readOnly
    , primary, secondary
    )

{-| A row of buttons where exactly one is chosen, like a segmented control.

Mirrors `ToggleGroup` from `@digdir/designsystemet-react`.

    type Layout
        = List
        | Grid

    layoutToString : Layout -> String
    layoutToString layout =
        case layout of
            List ->
                "list"

            Grid ->
                "grid"

    ToggleGroup.controlled
        { name = "layout"
        , label = "Visning"
        , toValue = layoutToString
        , selected = model.layout
        , onSelect = LayoutSelected
        }
        []
        [ ToggleGroup.item List [ Html.text "Liste" ]
        , ToggleGroup.item Grid [ Html.text "Rutenett" ]
        ]

It's a `<fieldset>` of radio buttons, so forms and screen readers treat it like
any radio group. `designsystemet-web` makes the arrow keys move focus without
choosing, and lets Enter choose.


# Controlled or uncontrolled

  - [`uncontrolled`](#uncontrolled): the browser tracks the chosen item, like
    any radio group. Use it in a plain `<form>` that gets submitted, or when
    nothing else on the page depends on the choice.
  - [`controlled`](#controlled): your model says which item is chosen, and
    clicking an item sends a message instead of choosing it.


# React → Elm

  - `<ToggleGroup aria-label="…" defaultValue="a">` → `ToggleGroup.uncontrolled { label = "…", initial = A, … } []`
  - `<ToggleGroup value={v} onChange={f}>` → `ToggleGroup.controlled { selected = v, onSelect = F, … } []`
  - `<ToggleGroup.Item value="a">A</ToggleGroup.Item>` → `ToggleGroup.item A [ Html.text "A" ]`
  - icon-only item + `<Tooltip>` → `ToggleGroup.iconItem { value = A, label = "…", icon = … }`
  - `<ToggleGroup.Item disabled>` → `ToggleGroup.item A […] |> ToggleGroup.disabled`
  - `<ToggleGroup.Item aria-disabled="true">` → `ToggleGroup.item A […] |> ToggleGroup.disabledFocusable`
  - `<ToggleGroup.Item readOnly>` → `ToggleGroup.item A […] |> ToggleGroup.readOnly`
  - `variant="secondary"` → `ToggleGroup.secondary`


# Differences from React

  - An icon item's radio button also gets the label as its `aria-label`, so
    it is named before `designsystemet-web` turns the tooltip into the item's
    `aria-label`.
  - The `name` is required. React generates one with `useId`.


# Managed by designsystemet-web

Never set these yourself: `role` on the fieldset and the radios, and
`tabindex` on the radios (the `focusgroup` polyfill moves it around).

@docs uncontrolled, controlled


# Items

@docs Item, item, iconItem


# Items that can't be chosen

@docs disabled, disabledFocusable, readOnly


# Variants

@docs primary, secondary

-}

import Designsystemet.Internal.Attributes as Internal
import Designsystemet.Tooltip as Tooltip
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed as Keyed
import Json.Decode as Decode
import Json.Encode as Encode



-- ITEMS


{-| One choice in the group.
-}
type Item a msg
    = Item
        { value : a
        , content : Content msg
        , availability : Availability
        }


type Content msg
    = Text (List (Html msg))
    | Icon { label : String, icon : Html msg }


type Availability
    = Enabled
    | Disabled
    | DisabledFocusable
    | ReadOnly


{-| An item with visible content, usually text.

    ToggleGroup.item Archived [ Html.text "Arkiverte" ]

-}
item : a -> List (Html msg) -> Item a msg
item value children =
    Item { value = value, content = Text children, availability = Enabled }


{-| An item showing only an icon. The label is required, since an icon means
nothing to a screen reader or to someone who doesn't recognise it. It names the
radio button and shows as a [tooltip](Designsystemet-Tooltip) on hover and
focus.

    ToggleGroup.iconItem { value = Grid, label = "Rutenett", icon = gridIcon }

-}
iconItem : { value : a, label : String, icon : Html msg } -> Item a msg
iconItem { value, label, icon } =
    Item { value = value, content = Icon { label = label, icon = icon }, availability = Enabled }


{-| An item that can't be chosen right now. It's dimmed and the keyboard skips
it.

    ToggleGroup.item Map [ Html.text "Kart" ]
        |> ToggleGroup.disabled

-}
disabled : Item a msg -> Item a msg
disabled =
    withAvailability Disabled


{-| A dimmed item the keyboard still reaches, so screen reader users find it
and hear that it's unavailable (`aria-disabled`).

In a [`controlled`](#controlled) group it can't be chosen. In an
[`uncontrolled`](#uncontrolled) group it's only marked unavailable, as in
React, and the browser still lets the user choose it.

-}
disabledFocusable : Item a msg -> Item a msg
disabledFocusable =
    withAvailability DisabledFocusable


{-| An item that is shown but can't be switched to, for a value fixed in this
context. The keyboard still reaches it, and `designsystemet-web` stops clicks
on it.
-}
readOnly : Item a msg -> Item a msg
readOnly =
    withAvailability ReadOnly


withAvailability : Availability -> Item a msg -> Item a msg
withAvailability availability (Item config) =
    Item { config | availability = availability }



-- VIEW


{-| A toggle group the browser tracks. `initial` is the item chosen on first
render.

    ToggleGroup.uncontrolled
        { name = "folder"
        , label = "Filtrering"
        , toValue = folderToString
        , initial = Inbox
        }
        []
        [ ToggleGroup.item Inbox [ Html.text "Innboks" ]
        , ToggleGroup.item Drafts [ Html.text "Utkast" ]
        ]

  - `name` is the radio buttons' `name`, which the value is submitted under in
    a form. Unique per form.
  - `label` is the group's accessible name (`aria-label`). To name it with a
    visible heading, also pass `Attr.attribute "aria-labelledby" headingId`,
    which takes precedence.
  - `toValue` turns a value into the radio button's `value`.

If `initial` changes later, that item is chosen. Otherwise Elm leaves the
choice to the browser.

-}
uncontrolled :
    { name : String
    , label : String
    , toValue : a -> String
    , initial : a
    }
    -> List (Html.Attribute msg)
    -> List (Item a msg)
    -> Html msg
uncontrolled config =
    viewGroup
        { name = config.name
        , label = config.label
        , toValue = config.toValue

        -- The property, since browsers ignore the `checked` attribute once the
        -- user has clicked. Elm only writes it when `initial` changes, so the
        -- user's choice stands until then.
        , checked = \value -> Attr.property "checked" (Encode.bool (value == config.initial))
        , onClick = \_ -> Internal.none
        , refuse = Internal.none
        }


{-| A toggle group your model tracks. Clicking an item (or pressing Enter on it)
sends `onSelect` with its value. The chosen item changes only when `selected`
does.

The fields are as in [`uncontrolled`](#uncontrolled), with `selected` and
`onSelect` instead of `initial`.

-}
controlled :
    { name : String
    , label : String
    , toValue : a -> String
    , selected : a
    , onSelect : a -> msg
    }
    -> List (Html.Attribute msg)
    -> List (Item a msg)
    -> Html msg
controlled config =
    viewGroup
        { name = config.name
        , label = config.label
        , toValue = config.toValue
        , checked = \value -> Attr.property "checked" (Encode.bool (value == config.selected))
        , onClick =
            \value ->
                if value == config.selected then
                    Internal.none

                else
                    -- Cancel the browser's own check. The model decides.
                    Events.preventDefaultOn "click" (Decode.succeed ( config.onSelect value, True ))
        , refuse =
            -- Cancelling a click needs a message. Re-selecting the current
            -- item is a no-op.
            Events.preventDefaultOn "click" (Decode.succeed ( config.onSelect config.selected, True ))
        }


type alias Group a msg =
    { name : String
    , label : String
    , toValue : a -> String
    , checked : a -> Html.Attribute msg
    , onClick : a -> Html.Attribute msg
    , refuse : Html.Attribute msg
    }


viewGroup : Group a msg -> List (Html.Attribute msg) -> List (Item a msg) -> Html msg
viewGroup group attributes items =
    Keyed.node "fieldset"
        (Attr.attribute "aria-label" group.label
            :: Attr.class "ds-toggle-group"
            :: Attr.attribute "focusgroup" "radiogroup"
            :: attributes
        )
        (List.map (viewItem group) items)


viewItem : Group a msg -> Item a msg -> ( String, Html msg )
viewItem group (Item { value, content, availability }) =
    let
        valueString : String
        valueString =
            group.toValue value

        input : List (Html.Attribute msg) -> Html msg
        input extra =
            Html.input
                (group.checked value
                    :: Attr.name group.name
                    :: Attr.type_ "radio"
                    :: Attr.value valueString
                    :: inputAvailability availability
                    :: (case availability of
                            Enabled ->
                                group.onClick value

                            DisabledFocusable ->
                                group.refuse

                            _ ->
                                -- The browser (disabled) or designsystemet-web
                                -- (read-only) already stops the click.
                                Internal.none
                       )
                    :: extra
                )
                []

        label : List (Html.Attribute msg) -> List (Html msg) -> Html msg
        label extra =
            Html.label
                (Attr.class "ds-button"
                    :: Internal.data "variant" "tertiary"
                    :: (Attr.attribute "aria-disabled" "true" |> when (availability == Disabled || availability == DisabledFocusable))
                    :: extra
                )
    in
    ( valueString
    , case content of
        Text children ->
            label [] (input [] :: children)

        Icon icon ->
            label [ Tooltip.content icon.label ]
                [ input [ Attr.attribute "aria-label" icon.label ], icon.icon ]
    )


inputAvailability : Availability -> Html.Attribute msg
inputAvailability availability =
    case availability of
        Enabled ->
            Internal.none

        Disabled ->
            Attr.disabled True

        DisabledFocusable ->
            Attr.attribute "aria-disabled" "true"

        ReadOnly ->
            Attr.attribute "readonly" ""


when : Bool -> Html.Attribute msg -> Html.Attribute msg
when condition attribute =
    if condition then
        attribute

    else
        Internal.none



-- VARIANTS


{-| The default. The chosen item is filled with the main color.
-}
primary : Html.Attribute msg
primary =
    Internal.data "variant" "primary"


{-| A quieter look: a tinted track with the chosen item raised on it.
-}
secondary : Html.Attribute msg
secondary =
    Internal.data "variant" "secondary"
