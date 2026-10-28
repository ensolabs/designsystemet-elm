module Designsystemet.Select exposing
    ( single
    , view, option, optgroup
    , autoWidth, fullWidth
    )

{-| A native `<select>` with Designsystemet styling.

Mirrors `Select` from `@digdir/designsystemet-react`.

To pick one of your own values, use [`single`](#single):

    municipalities =
        { options = Municipality.all
        , selected = model.municipality
        , toValue = Municipality.toCode
        , toLabel = Municipality.toName
        , onSelect = PickedMunicipality
        , placeholder = "Velg kommune"
        }

    Select.single municipalities [ Attr.required True ]

[`view`](#view), [`option`](#option) and [`optgroup`](#optgroup) are the
plain elements, for when you need option groups or want to handle the strings
yourself.

A select needs a label. Put it in a [`Field`](Designsystemet-Field):

    Field.view []
        [ Label.view [] [ Html.text "Kommune" ]
        , Select.single municipalities [ Attr.required True ]
        ]


# React → Elm

  - `<Select>` + `<Select.Option>`s for your values → `Select.single { … } []`
  - `<Select>` → `Select.view []`
  - `<Select.Option value="…">` → `Select.option [ Attr.value "…" ]`
  - `<Select.Optgroup label="…">` → `Select.optgroup { label = "…" } []`
  - `width="auto"` → `Select.autoWidth`
  - `aria-readonly` → `Select.view [ Attr.attribute "aria-readonly" "true" ]`
  - `readOnly` → not ported: deprecated in React, use `aria-readonly`

A `<select>` can't be `readonly` in HTML. With `aria-readonly="true"`,
`@digdir/designsystemet-web` stops the user from changing it and the CSS shows
it as read-only.

@docs single


# Plain elements

@docs view, option, optgroup


# Width

@docs autoWidth, fullWidth

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed as Keyed
import Json.Decode as Decode



-- SINGLE


{-| A select for picking one of your own values.

  - `toValue` turns a value into the string the browser keeps in `value`.
    Give every option a different one.
  - `toLabel` is the text the user sees.
  - `onSelect` gets the picked value back as your type.
  - `placeholder` is the prompt shown while `selected` is `Nothing`. It can't
    be picked and disappears once something is selected.

`selected` is a `Maybe` so the screen matches the model. Without a prompt, the
browser would show the first option as chosen while your model has nothing.
If `selected` isn't among `options` (say the list was reloaded without it),
the prompt is shown too.

If "none" is a real choice, make it one of your options:

    Select.single
        { options = Nothing :: List.map Just Team.all
        , selected = Just model.team
        , toValue = Maybe.map Team.toId >> Maybe.withDefault ""
        , toLabel = Maybe.map Team.toName >> Maybe.withDefault "Ingen"
        , onSelect = PickedTeam
        , placeholder = "Velg team"
        }
        []

A `<select>` can't refuse a change. The browser already shows the pick when
`onSelect` arrives, so always store the value. If `update` ignores it, the
screen and the model disagree until `selected` changes.

The attributes go on the `<select>`. The options are keyed by `toValue`, so
the list can change under the user without Elm reusing the wrong `<option>`.

-}
single :
    { options : List a
    , selected : Maybe a
    , toValue : a -> String
    , toLabel : a -> String
    , onSelect : a -> msg
    , placeholder : String
    }
    -> List (Html.Attribute msg)
    -> Html msg
single config attributes =
    let
        selectedValue : Maybe String
        selectedValue =
            config.selected
                |> Maybe.map config.toValue
                |> Maybe.andThen
                    (\value ->
                        if List.any (\candidate -> config.toValue candidate == value) config.options then
                            Just value

                        else
                            Nothing
                    )

        toOption : a -> ( String, Html msg )
        toOption value =
            let
                string : String
                string =
                    config.toValue value
            in
            ( "option-" ++ string
            , option
                -- An attribute, since Elm sets properties before the option
                -- has its text. `.value = ""` is then a no-op and the value
                -- falls back to the label.
                [ Attr.attribute "value" string
                , Attr.selected (selectedValue == Just string)
                ]
                [ Html.text (config.toLabel value) ]
            )

        prompt : List ( String, Html msg )
        prompt =
            case selectedValue of
                Just _ ->
                    []

                Nothing ->
                    [ ( "prompt"
                      , option [ Attr.attribute "value" "", Attr.disabled True, Attr.selected True ]
                            [ Html.text config.placeholder ]
                      )
                    ]
    in
    Keyed.node "select"
        (Attr.class "ds-input" :: Events.on "change" (decodeSelection config) :: attributes)
        (prompt ++ List.map toOption config.options)


decodeSelection : { r | options : List a, toValue : a -> String, onSelect : a -> msg } -> Decode.Decoder msg
decodeSelection { options, toValue, onSelect } =
    Decode.at [ "target", "value" ] Decode.string
        |> Decode.andThen
            (\string ->
                case List.filter (\value -> toValue value == string) options of
                    value :: _ ->
                        Decode.succeed (onSelect value)

                    [] ->
                        Decode.fail ("No option has the value " ++ string)
            )



-- PLAIN ELEMENTS


{-| A `<select class="ds-input">`. Listen with `Events.onInput`, which gives you
the chosen option's `value`.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view attributes =
    Html.select (Attr.class "ds-input" :: attributes)


{-| An `<option>`. Mark the chosen one with `Attr.selected True`. Setting
`value` on the select does nothing on first render, as the options aren't
there yet.
-}
option : List (Html.Attribute msg) -> List (Html msg) -> Html msg
option =
    Html.option


{-| A labelled group of options.

    Select.view [ Events.onInput PickedRoom ]
        [ Select.optgroup { label = "Bygg A" }
            []
            [ Select.option [ Attr.value "a101" ] [ Html.text "A101" ]
            , Select.option [ Attr.value "a102" ] [ Html.text "A102" ]
            ]
        ]

-}
optgroup : { label : String } -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
optgroup { label } attributes =
    Html.optgroup (Attr.attribute "label" label :: attributes)



-- WIDTH


{-| As wide as its longest option.
-}
autoWidth : Html.Attribute msg
autoWidth =
    Internal.data "width" "auto"


{-| As wide as its container. This is the default.
-}
fullWidth : Html.Attribute msg
fullWidth =
    Internal.data "width" "full"
