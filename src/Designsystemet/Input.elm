module Designsystemet.Input exposing (view, indeterminate)

{-| A native `<input>` with Designsystemet styling.

Mirrors `Input` from `@digdir/designsystemet-react`.

    Input.view [ Attr.value model.email, Attr.type_ "email", Events.onInput ChangedEmail ]

An input has no label of its own. Put it in a [`Field`](Designsystemet-Field)
with a [`Label`](Designsystemet-Label), or use
[`Textfield`](Designsystemet-Textfield).

An input is `type="text"` unless you pass another `Attr.type_`.


# React → Elm

  - `<Input />` → `Input.view []`
  - `type="email"` → `Input.view [ Attr.type_ "email" ]`
  - `size={10}` → `Input.view [ Attr.size 10 ]`
  - `readOnly` → `Input.view [ Attr.readonly True ]`
  - `role="switch"` → `Input.view [ Attr.attribute "role" "switch" ]`
  - `data-indeterminate` → `Input.indeterminate`


# Read-only

React blocks `onChange` and clicks on a read-only input.
`@digdir/designsystemet-web` does the same for every `readonly` input on the
page, including checkboxes and radios, so `Attr.readonly True` is enough.

@docs view, indeterminate

-}

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as Encode


{-| An `<input class="ds-input" type="text">`.
-}
view : List (Html.Attribute msg) -> Html msg
view attributes =
    Html.input (Attr.class "ds-input" :: Attr.type_ "text" :: attributes) []


{-| Show a checkbox as partly checked, e.g. a "select all" box when only some
rows are selected.

    selectAll : List Row -> Html Msg
    selectAll rows =
        let
            selected =
                List.filter .selected rows
        in
        Input.view <|
            [ Attr.type_ "checkbox"
            , Attr.checked (List.length selected == List.length rows)
            , Events.onCheck SelectedAll
            ]
                ++ (if List.isEmpty selected || selected == rows then
                        []

                    else
                        [ Input.indeterminate ]
                   )

React sets `data-indeterminate` and lets `<ds-field>` copy it to the DOM
property. This sets the property directly, so it works with or without a
`Field`. Drop the attribute to clear it.

-}
indeterminate : Html.Attribute msg
indeterminate =
    Attr.property "indeterminate" (Encode.bool True)
