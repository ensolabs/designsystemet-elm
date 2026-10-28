module Designsystemet.Chip exposing
    ( button, removable
    , checkbox, radio
    , uncontrolledCheckbox, uncontrolledRadio
    , wrap
    )

{-| Small, rounded buttons for filters and choices.

Mirrors `Chip` from `@digdir/designsystemet-react`.

    Html.div []
        [ Chip.checkbox { name = "status", value = "open", checked = model.showOpen, onCheck = ShowOpenChecked }
            []
            [ Html.text "Åpne saker" ]
        , Chip.checkbox { name = "owner", value = "me", checked = model.showMine, onCheck = ShowMineChecked }
            []
            [ Html.text "Mine saker" ]
        ]

    Html.div []
        (List.map
            (\tag ->
                Chip.removable { removeLabel = "Trykk for å fjerne" }
                    [ Events.onClick (TagRemoved tag) ]
                    [ Html.text tag ]
            )
            model.tags
        )


# React → Elm

  - `<Chip.Button>` → `Chip.button []`
  - `<Chip.Removable>` → `Chip.removable { removeLabel = "Trykk for å fjerne" } []`
  - `<Chip.Checkbox checked onChange>` → `Chip.checkbox { name, value, checked, onCheck } []`
  - `<Chip.Radio name checked onChange>` → `Chip.radio { name, value, checked, onSelect } []`
  - `<Chip.Checkbox name value defaultChecked>` → `Chip.uncontrolledCheckbox { name, value, initiallyChecked = True } []`
  - `<Chip.Radio name value defaultChecked>` → `Chip.uncontrolledRadio { name, value, initiallyChecked = True } []`
  - `data-wrap="wrap"` → `Chip.wrap`


# Differences from React

  - `Chip.removable` takes the text screen readers hear for removing the chip.
    React relies on a CSS default (Norwegian, or English for other languages).
    Here you pass it, and it becomes the `--dsc-chip-removable-label` custom
    property.
  - Checkbox and radio chips require a `name` and `value`, so they work in a
    submitted form. React leaves them optional.
  - On `Chip.checkbox` and `Chip.radio`, attributes go on the `<label>` so
    `Ds.color` and `Chip.wrap` work. React puts them on the `<input>`.


# Buttons

@docs button, removable


# Controlled choices

Your model decides whether the chip is checked. Clicking sends a message.

@docs checkbox, radio


# Uncontrolled choices

The browser tracks the checked state. Use these in a plain submitted `<form>`,
such as a search filter that becomes the query string.

@docs uncontrolledCheckbox, uncontrolledRadio


# Wrapping

@docs wrap

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode



-- BUTTONS


{-| A `<button class="ds-chip" type="button">`, for an action.
-}
button : List (Html.Attribute msg) -> List (Html msg) -> Html msg
button attributes =
    Html.button (Attr.class "ds-chip" :: Attr.type_ "button" :: attributes)


{-| A chip with an "×", for removing an active filter or a tag. Handle the
click yourself. `removeLabel` is what screen readers hear after the chip's
text, like `"Trykk for å fjerne"`.

    Chip.removable { removeLabel = "Trykk for å fjerne" }
        [ Events.onClick (FilterRemoved filter) ]
        [ Html.text (Filter.toString filter) ]

The label is set through the chip's `style` attribute, so use classes rather
than `Attr.style` on a removable chip.

-}
removable : { removeLabel : String } -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
removable { removeLabel } attributes =
    button
        (Internal.data "removable" "true"
            :: Attr.attribute "style" ("--dsc-chip-removable-label: " ++ cssString removeLabel)
            :: attributes
        )


{-| A CSS string literal, so any text is safe in a custom property.
-}
cssString : String -> String
cssString text =
    "\""
        ++ (text
                |> String.replace "\\" "\\\\"
                |> String.replace "\"" "\\\""
                |> String.replace "\n" "\\a "
           )
        ++ "\""



-- CHOICES


{-| A checkbox chip, usually one of several filters. Clicking sends `onCheck`
with the requested state.

`name` and `value` are what a plain `<form>` submits when the chip is checked.

-}
checkbox :
    { name : String, value : String, checked : Bool, onCheck : Bool -> msg }
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
checkbox { name, value, checked, onCheck } attributes children =
    Html.label (Attr.class "ds-chip" :: attributes)
        (Html.input
            [ Attr.class "ds-input"
            , Attr.type_ "checkbox"
            , Attr.name name
            , Attr.value value
            , Attr.property "checked" (Encode.bool checked)
            , Events.preventDefaultOn "click" (Decode.succeed ( onCheck (not checked), True ))
            ]
            []
            :: children
        )


{-| A radio chip, for picking one of several. Give the chips in a group the
same `name`; `value` is what a plain `<form>` submits for the
checked one. Clicking an unchecked chip sends `onSelect`.

    Html.div []
        [ Chip.radio { name = "language", value = "nb", checked = model.language == Bokmal, onSelect = LanguageSelected Bokmal }
            []
            [ Html.text "Bokmål" ]
        , Chip.radio { name = "language", value = "nn", checked = model.language == Nynorsk, onSelect = LanguageSelected Nynorsk }
            []
            [ Html.text "Nynorsk" ]
        ]

-}
radio :
    { name : String, value : String, checked : Bool, onSelect : msg }
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
radio { name, value, checked, onSelect } attributes children =
    Html.label (Attr.class "ds-chip" :: attributes)
        (Html.input
            [ Attr.class "ds-input"
            , Attr.type_ "radio"
            , Attr.name name
            , Attr.value value
            , Attr.property "checked" (Encode.bool checked)
            , if checked then
                Internal.none

              else
                Events.preventDefaultOn "click" (Decode.succeed ( onSelect, True ))
            ]
            []
            :: children
        )


{-| A checkbox chip whose state the browser tracks. `initiallyChecked` is the
state on first render.

    Html.form [ Attr.action "/saker", Attr.method "get" ]
        [ Chip.uncontrolledCheckbox { name = "status", value = "open", initiallyChecked = True }
            []
            [ Html.text "Åpne saker" ]
        , Chip.uncontrolledCheckbox { name = "status", value = "closed", initiallyChecked = False }
            []
            [ Html.text "Lukkede saker" ]
        ]

-}
uncontrolledCheckbox : { name : String, value : String, initiallyChecked : Bool } -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
uncontrolledCheckbox config =
    uncontrolled "checkbox" config


{-| A radio chip whose state the browser tracks. Give the chips in a group the
same `name`, and `initiallyChecked = True` to at most one.
-}
uncontrolledRadio : { name : String, value : String, initiallyChecked : Bool } -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
uncontrolledRadio config =
    uncontrolled "radio" config


uncontrolled : String -> { name : String, value : String, initiallyChecked : Bool } -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
uncontrolled type_ { name, value, initiallyChecked } attributes children =
    Html.label (Attr.class "ds-chip" :: attributes)
        (Html.input
            [ Attr.class "ds-input"
            , Attr.type_ type_
            , Attr.name name
            , Attr.value value

            -- The attribute is only the initial state; the browser owns the
            -- property after that.
            , if initiallyChecked then
                Attr.attribute "checked" ""

              else
                Internal.none
            ]
            []
            :: children
        )



-- WRAPPING


{-| Wrap long text instead of truncating it with "…".
-}
wrap : Html.Attribute msg
wrap =
    Internal.data "wrap" "wrap"
