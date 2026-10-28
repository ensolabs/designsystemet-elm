module Designsystemet.Textarea exposing (view)

{-| A native `<textarea>` with Designsystemet styling.

Mirrors `Textarea` from `@digdir/designsystemet-react`.

    Textarea.view [ Attr.value model.comment, Events.onInput ChangedComment ]

Like [`Input`](Designsystemet-Input), it needs a label. Put it in a
[`Field`](Designsystemet-Field) or use
[`Textfield.multiline`](Designsystemet-Textfield#multiline).

Inside a `Field` and without `rows`, the textarea grows with its text.


# React → Elm

  - `<Textarea />` → `Textarea.view []`
  - `rows={4}` → `Textarea.view [ Attr.rows 4 ]`
  - `<Textarea>Tekst</Textarea>` → `Textarea.view [ Attr.value "Tekst" ]`

@docs view

-}

import Html exposing (Html)
import Html.Attributes as Attr


{-| A `<textarea class="ds-input">`. Set its text with `Attr.value`.
-}
view : List (Html.Attribute msg) -> Html msg
view attributes =
    Html.textarea (Attr.class "ds-input" :: attributes) []
