module Designsystemet.Suggestion exposing
    ( Suggestion, single, multiple, view
    , withToggle, withClear, withEmptyMessage, withOptionContent
    , withoutFiltering, withCreatable, withName
    )

{-| **Experimental.** A combobox: a text input that suggests values from a list
as you type, for picking one or several.

Mirrors `EXPERIMENTAL_Suggestion` from `@digdir/designsystemet-react`. As there,
the API and markup may change in any release.

    Field.view []
        [ Label.view [] [ Html.text "Kommune" ]
        , Suggestion.single
            { options = Municipality.all
            , selected = model.municipality
            , toValue = Municipality.toCode
            , toLabel = Municipality.toName
            , onSelect = PickedMunicipality
            }
            |> Suggestion.withClear { label = "Tøm" }
            |> Suggestion.withEmptyMessage [ Html.text "Ingen treff" ]
            |> Suggestion.view []
        ]

    Suggestion.multiple
        { options = Tag.all
        , selected = model.tags
        , toValue = Tag.toId
        , toLabel = Tag.toName
        , onChange = ChangedTags
        }
        |> Suggestion.withToggle { label = "Vis alle" }
        |> Suggestion.view [ Attr.attribute "aria-label" "Stikkord" ]

The attributes you give `view` go on the text `<input>`. Add `Events.onInput`
there to get the typed text, e.g. to fetch options from a server.


# Controlled only

Elm owns the selection. When the user picks or removes a value, the web
component fires `comboboxbeforeselect`. The module cancels it and sends
`onSelect` or `onChange` with the new selection, so nothing changes on screen
until your model does.

React also has an uncontrolled mode (`defaultSelected`) where the web component
adds and removes selected items itself. That would insert nodes among Elm's, so
it isn't ported.

If a value isn't in `options` (or in `selected`, when removing), you get your
current selection back unchanged and the event is still cancelled.


# React → Elm

  - `<Suggestion selected onSelectedChange>` → `Suggestion.single { … }`
  - `<Suggestion multiple selected onSelectedChange>` → `Suggestion.multiple { … }`
  - `<Suggestion.Input>` → the attributes of `Suggestion.view`
  - `<Suggestion.Option value>` → `options`, `toValue`, `toLabel`
  - `<Suggestion.Toggle aria-label>` → `Suggestion.withToggle { label = "…" }`
  - `<Suggestion.Clear>` + `data-sr-clear` → `Suggestion.withClear { label = "…" }`
  - `<Suggestion.Empty>` → `Suggestion.withEmptyMessage [ … ]`
  - `<Suggestion.Option label>` with markup in it → `Suggestion.withOptionContent (\a -> [ … ])`
  - `filter={false}` → `Suggestion.withoutFiltering`
  - `filter={fn}` → filter `options` yourself + `withoutFiltering`
  - `creatable` + `<Suggestion.Empty data-empty="…">` → `Suggestion.withCreatable { … }`
  - `name` → `Suggestion.withName "…"`
  - `renderSelected` → `toLabel`
  - `defaultSelected` → not ported: controlled only
  - `onBeforeMatch` → not ported


# Filtering

By default the web component shows the options whose label contains the typed
text, ignoring case, like React's default `filter`. With
[`withoutFiltering`](#withoutFiltering) every option you pass is shown, so you
can filter `options` yourself or show what a server sent back.


# Managed by designsystemet-web

`<ds-suggestion>` (built on `u-combobox` and `u-datalist` from u-elements)
writes these, so the module never renders them:

  - on the input: `role`, `list`, `popovertarget`, `autocomplete`,
    `enterkeyhint`, `aria-autocomplete`, `aria-controls`, `aria-expanded`,
    `aria-activedescendant`, `aria-description`, and its `value` in single
    mode (it shows the selected label)
  - on the selected `<data>` items: `aria-label`, `role`, `slot`, `tabindex`,
    `hidden`
  - on the options: `selected`, `aria-selected`, `aria-disabled`,
    `aria-hidden`, `role`, `id`
  - on the list: `hidden`, `tabindex`, `aria-label`, `data-sr-*`,
    `data-is-floating`
  - on the empty option: `hidden`, `label`, `value`, `disabled`,
    `data-create`
  - on the clear and toggle buttons: `hidden`, `aria-hidden`, `tabindex`,
    and `aria-expanded` on the toggle (Elm renders the initial `hidden` and
    `aria-expanded="false"`, like React, and never changes them)
  - the `<option>`s of the hidden `<select>` from [`withName`](#withName),
    and its `multiple` (set from `data-multiple`)
  - the screen reader texts (`data-sr-*`) other than the clear label, from
    the CSS custom properties `--dsc-suggestion-sr-*`

@docs Suggestion, single, multiple, view


# Buttons and messages

@docs withToggle, withClear, withEmptyMessage, withOptionContent


# Behaviour

@docs withoutFiltering, withCreatable, withName

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed as Keyed
import Json.Decode as Decode



-- SUGGESTION


{-| A suggestion field being configured. Start with [`single`](#single) or
[`multiple`](#multiple), end with [`view`](#view).
-}
type Suggestion a msg
    = Suggestion (Config a msg)


type alias Config a msg =
    { selection : Selection a msg
    , options : List a
    , toValue : a -> String
    , toLabel : a -> String
    , toggle : Maybe String
    , clear : Maybe String
    , emptyMessage : Maybe (List (Html msg))
    , optionContent : Maybe (a -> List (Html msg))
    , filtering : Filtering
    , create : Maybe { template : String, onCreate : String -> msg }
    , name : Maybe String
    }


type Selection a msg
    = One (Maybe a) (Maybe a -> msg)
    | Many (List a) (List a -> msg)


type Filtering
    = ByLabel
    | Unfiltered


init : Selection a msg -> { r | options : List a, toValue : a -> String, toLabel : a -> String } -> Suggestion a msg
init selection { options, toValue, toLabel } =
    Suggestion
        { selection = selection
        , options = options
        , toValue = toValue
        , toLabel = toLabel
        , toggle = Nothing
        , clear = Nothing
        , emptyMessage = Nothing
        , optionContent = Nothing
        , filtering = ByLabel
        , create = Nothing
        , name = Nothing
        }


{-| Pick at most one value. The input shows the selected label.

  - `toValue` must give every option a different string.
  - `toLabel` is what the user sees and types to find it.
  - `onSelect` gets `Nothing` when the user clears the field.

-}
single :
    { options : List a
    , selected : Maybe a
    , toValue : a -> String
    , toLabel : a -> String
    , onSelect : Maybe a -> msg
    }
    -> Suggestion a msg
single config =
    init (One config.selected config.onSelect) config


{-| Pick any number of values. They are shown as removable chips before the
input, in the order of `selected`.
-}
multiple :
    { options : List a
    , selected : List a
    , toValue : a -> String
    , toLabel : a -> String
    , onChange : List a -> msg
    }
    -> Suggestion a msg
multiple config =
    init (Many config.selected config.onChange) config



-- BUTTONS AND MESSAGES


{-| A button, shown as an arrow, that opens and closes the list. `label` is its
accessible name.
-}
withToggle : { label : String } -> Suggestion a msg -> Suggestion a msg
withToggle { label } (Suggestion config) =
    Suggestion { config | toggle = Just label }


{-| A button, shown as an ×, that empties the input (and in single mode the
selection). `label` is its accessible name.
-}
withClear : { label : String } -> Suggestion a msg -> Suggestion a msg
withClear { label } (Suggestion config) =
    Suggestion { config | clear = Just label }


{-| What the list shows when nothing matches, like
`[ Html.text "Ingen treff" ]`. While fetching options from a server, show
`[ Spinner.decorative [], Html.text "Laster..." ]` instead.
-}
withEmptyMessage : List (Html msg) -> Suggestion a msg -> Suggestion a msg
withEmptyMessage message (Suggestion config) =
    Suggestion { config | emptyMessage = Just message }


{-| Show more than the label in each option, like a second line of detail.
`toLabel` is still what the user types to find it, what the input shows once
picked, and what a chip says.

    |> Suggestion.withOptionContent
        (\place -> [ Html.text place.name, Html.div [] [ Html.text place.county ] ])

-}
withOptionContent : (a -> List (Html msg)) -> Suggestion a msg -> Suggestion a msg
withOptionContent toContent (Suggestion config) =
    Suggestion { config | optionContent = Just toContent }



-- BEHAVIOUR


{-| Show every option you pass, instead of only those matching the typed text.
-}
withoutFiltering : Suggestion a msg -> Suggestion a msg
withoutFiltering (Suggestion config) =
    Suggestion { config | filtering = Unfiltered }


{-| Let the user add a value that isn't among the options.

  - `template` is the text of the "add" option in the list; `%s` is replaced by
    what the user typed: `"Legg til «%s»"`.
  - `onCreate` gets the typed text when the user picks it. Turn it into one of
    your values, add it to `options` and to the selection.

The "add" option replaces the [`withEmptyMessage`](#withEmptyMessage) message.

-}
withCreatable : { template : String, onCreate : String -> msg } -> Suggestion a msg -> Suggestion a msg
withCreatable create (Suggestion config) =
    Suggestion { config | create = Just create }


{-| Submit the selected values with a surrounding `<form>`, under this name. A
hidden `<select>` holds them.
-}
withName : String -> Suggestion a msg -> Suggestion a msg
withName name (Suggestion config) =
    Suggestion { config | name = Just name }



-- VIEW


{-| Render the field. The attributes go on the text `<input>`.

It has no visible label. Put it in a [`Field`](Designsystemet-Field) with a
[`Label`](Designsystemet-Label), or give the input an `aria-label`.

-}
view : List (Html.Attribute msg) -> Suggestion a msg -> Html msg
view attributes (Suggestion config) =
    Keyed.node "ds-suggestion"
        ([ Attr.class "ds-suggestion"
         , Events.preventDefaultOn "comboboxbeforeselect" (decodeSelect config)
         ]
            ++ isMultiple config.selection [ Internal.data "multiple" "" ]
            ++ ifJust config.create (\_ -> Internal.data "creatable" "")
            ++ ifJust config.clear (Internal.data "sr-clear")
        )
        (List.map (viewSelected config) (selected config.selection)
            ++ ( "input"
               , Html.input
                    (Attr.class "ds-input" :: Attr.type_ "text" :: Attr.placeholder "" :: attributes)
                    []
               )
            :: ifJust config.toggle viewToggle
            ++ ifJust config.clear (\_ -> ( "clear", Html.button [ Attr.hidden True, Attr.type_ "reset" ] [] ))
            ++ [ ( "list", viewList config ) ]
            ++ ifJust config.name viewSelect
        )


selected : Selection a msg -> List a
selected selection =
    case selection of
        One maybe _ ->
            Maybe.withDefault [] (Maybe.map List.singleton maybe)

        Many list _ ->
            list


isMultiple : Selection a msg -> List b -> List b
isMultiple selection items =
    case selection of
        One _ _ ->
            []

        Many _ _ ->
            items


ifJust : Maybe a -> (a -> b) -> List b
ifJust maybe toItem =
    case maybe of
        Just a ->
            [ toItem a ]

        Nothing ->
            []


viewSelected : Config a msg -> a -> ( String, Html msg )
viewSelected config value =
    let
        string : String
        string =
            config.toValue value
    in
    ( "data-" ++ string
    , Html.node "data" [ Attr.attribute "value" string ] [ Html.text (config.toLabel value) ]
    )


viewToggle : String -> ( String, Html msg )
viewToggle label =
    ( "toggle"
    , Html.button
        [ Attr.attribute "aria-expanded" "false"
        , Attr.attribute "aria-label" label
        , Attr.type_ "button"
        ]
        []
    )


viewList : Config a msg -> Html msg
viewList config =
    Keyed.node "u-datalist"
        ((case config.filtering of
            ByLabel ->
                []

            Unfiltered ->
                [ Internal.data "nofilter" "" ]
         )
            ++ [ Attr.attribute "popover" "manual"
               , Attr.attribute "role" "listbox"
               ]
        )
        (viewEmpty config ++ List.map (viewOption config) config.options)


viewEmpty : Config a msg -> List ( String, Html msg )
viewEmpty config =
    case ( config.create, config.emptyMessage ) of
        ( Just { template }, _ ) ->
            [ ( "empty", Html.node "u-option" [ Internal.data "empty" template ] [] ) ]

        ( Nothing, Just message ) ->
            [ ( "empty", Html.node "u-option" [ Internal.data "empty" "" ] message ) ]

        ( Nothing, Nothing ) ->
            []


viewOption : Config a msg -> a -> ( String, Html msg )
viewOption config value =
    let
        string : String
        string =
            config.toValue value
    in
    ( "option-" ++ string
    , case config.optionContent of
        Just toContent ->
            Html.node "u-option"
                [ Attr.attribute "value" string, Attr.attribute "label" (config.toLabel value) ]
                (toContent value)

        Nothing ->
            Html.node "u-option" [ Attr.attribute "value" string ] [ Html.text (config.toLabel value) ]
    )


viewSelect : String -> ( String, Html msg )
viewSelect name =
    ( "select"
    , Html.select
        [ Attr.name name, Attr.hidden True ]
        []
    )



-- EVENTS


{-| `comboboxbeforeselect` carries the `<data>` element about to be added or
removed. It is being removed when it is already in the document.
-}
decodeSelect : Config a msg -> Decode.Decoder ( msg, Bool )
decodeSelect config =
    Decode.map2 (\value isRemoval -> ( toMsg config value isRemoval, True ))
        (Decode.at [ "detail", "value" ] Decode.string)
        (Decode.at [ "detail", "isConnected" ] Decode.bool)


toMsg : Config a msg -> String -> Bool -> msg
toMsg config value isRemoval =
    let
        find : List a -> Maybe a
        find =
            List.filter (\option -> config.toValue option == value) >> List.head

        created : msg -> msg
        created unchanged =
            case config.create of
                Just { onCreate } ->
                    onCreate value

                Nothing ->
                    unchanged
    in
    case config.selection of
        One current onSelect ->
            if isRemoval then
                onSelect Nothing

            else
                case find config.options of
                    Just option ->
                        onSelect (Just option)

                    Nothing ->
                        created (onSelect current)

        Many current onChange ->
            if isRemoval then
                onChange (List.filter (\option -> config.toValue option /= value) current)

            else
                case find config.options of
                    Just option ->
                        onChange (current ++ [ option ])

                    Nothing ->
                        created (onChange current)
