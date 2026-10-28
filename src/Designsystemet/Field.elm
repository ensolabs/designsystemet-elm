module Designsystemet.Field exposing
    ( view, viewKeyed
    , description
    , affixes, affix
    , Counter, counter
    , Position(..), position, outline
    )

{-| A form control wired to its label, description and messages.

Mirrors `Field` from `@digdir/designsystemet-react`.

    Field.view []
        [ Label.view [] [ Html.text "Beløp" ]
        , Field.description [] [ Html.text "Oppgi beløpet før skatt" ]
        , Field.affixes []
            [ Field.affix [] [ Html.text "NOK" ]
            , Input.view [ Attr.value model.amount, Events.onInput ChangedAmount ]
            , Field.affix [] [ Html.text "pr. mnd." ]
            ]
        , ValidationMessage.view [] [ Html.text "Beløpet må være et tall" ]
        ]

It renders `<ds-field>`, a custom element from `@digdir/designsystemet-web`
that finds the input, select or textarea inside and connects the rest to it.
You don't write `for`, `id` or `aria-describedby`.

[`Textfield`](Designsystemet-Textfield), [`Checkbox`](Designsystemet-Checkbox),
[`Radio`](Designsystemet-Radio) and [`Switch`](Designsystemet-Switch) build
the field for you. Use this module for anything else, like a
[`Select`](Designsystemet-Select) or a [`Suggestion`](Designsystemet-Suggestion)
with a label.


# React → Elm

  - `<Field>` → `Field.view []`
  - `position="end"` → `Field.position Field.End`
  - `<Field.Description>` → `Field.description []`
  - `<Field.Affixes>` → `Field.affixes []`
  - `<Field.Affix>` → `Field.affix []`
  - `<Field.Counter limit={140} over="…" under="…" />` → `Field.counter { limit = 140, over = "…", under = "…" } []`
  - `asChild` → not ported: deprecated in React


# Managed by designsystemet-web

`<ds-field>` sets these. Don't set them yourself, or Elm and the web
component overwrite each other:

  - `for` on every `<label>` in the field
  - `id` on the input (when you haven't set one), on descriptions, messages and
    the counter
  - `aria-describedby` and `aria-invalid` on the input
  - `data-clickdelegatefor` on the field, so a click anywhere on a checkbox or
    radio field toggles it
  - `data-label`, `data-state` and `data-color` on the counter
  - the `--_ds-field-sizing` style on a `<textarea>`, which grows with its text

Your own `id` on the input is fine; the field uses it.

@docs view, viewKeyed


# Descriptions

@docs description


# Prefix and suffix

@docs affixes, affix


# Character counter

@docs Counter, counter


# Checkboxes, radios and switches

@docs Position, position, outline

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed as Keyed



-- VIEW


{-| A `<ds-field class="ds-field">` holding exactly one input, select or
textarea. Group several fields with a [`Fieldset`](Designsystemet-Fieldset).
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view attributes =
    Html.node "ds-field" (Attr.class "ds-field" :: attributes)


{-| A field whose parts come and go. Give every child a key.

Elm matches children by position. If a description appears before the input
(say, a hint shown once the user starts typing), the input shifts one place
and Elm rebuilds it, so the user loses focus mid-word. Keys prevent that.

    Field.viewKeyed []
        (List.filterMap identity
            [ Just ( "label", Label.view [] [ Html.text "Passord" ] )
            , Maybe.map (\hint -> ( "description", Field.description [] [ Html.text hint ] )) model.hint
            , Just ( "input", Input.view [ Attr.type_ "password", Events.onInput PasswordChanged ] )
            ]
        )

[`Textfield`](Designsystemet-Textfield) does this for you.

-}
viewKeyed : List (Html.Attribute msg) -> List ( String, Html msg ) -> Html msg
viewKeyed attributes =
    Keyed.node "ds-field" (Attr.class "ds-field" :: attributes)



-- DESCRIPTION


{-| Help text, read by screen readers along with the label. Put it between the
label and the input.
-}
description : List (Html.Attribute msg) -> List (Html msg) -> Html msg
description attributes =
    Html.div (Internal.data "field" "description" :: attributes)



-- AFFIXES


{-| Wraps an input with its prefix and suffix so they look like one control.
-}
affixes : List (Html.Attribute msg) -> List (Html msg) -> Html msg
affixes attributes =
    Html.div (Attr.class "ds-field-affixes" :: attributes)


{-| Short text before or after the input, like a currency or unit. Use it
inside [`affixes`](#affixes).

It has `aria-hidden="true"`, so repeat it in the label or description:
"Beløp i kroner", not "Beløp".

-}
affix : List (Html.Attribute msg) -> List (Html msg) -> Html msg
affix attributes =
    Html.span
        (Attr.class "ds-field-affix"
            :: Attr.attribute "aria-hidden" "true"
            :: attributes
        )



-- COUNTER


{-| A character limit and its two texts. `%d` is replaced by the number of
characters.

    { limit = 280
    , under = "%d tegn igjen"
    , over = "%d tegn for mye"
    }

There are no default texts.

-}
type alias Counter =
    { limit : Int
    , under : String
    , over : String
    }


{-| Shows how many characters are left, or how many too many, in the field's
input or textarea. Put it after the input.

    Field.view []
        [ Label.view [] [ Html.text "Begrunnelse" ]
        , Textarea.view [ Events.onInput ChangedReason ]
        , Field.counter { limit = 500, under = "%d tegn igjen", over = "%d tegn for mye" } []
        ]

`<ds-field>` updates the count, text and "too many" state as the user types,
so the element is empty in Elm's view. Going over the limit sets
`aria-invalid` on the input but doesn't stop typing, so check the length in
`update`.

-}
counter : Counter -> List (Html.Attribute msg) -> Html msg
counter { limit, under, over } attributes =
    Html.p
        (Attr.class "ds-validation-message"
            :: Internal.data "field" "counter"
            :: Internal.data "limit" (String.fromInt limit)
            :: Internal.data "under" under
            :: Internal.data "over" over
            :: attributes
        )
        []



-- TOGGLES


{-| Which side of the label a checkbox, radio or switch goes on.
-}
type Position
    = Start
    | End


{-| Put the checkbox, radio or switch at the start (default) or end of the
field. Set it on the field, not the input.

    Switch.new (Ds.label "Varsle meg på e-post")
        |> Switch.withFieldAttributes [ Field.position Field.End ]
        |> Switch.view [ Attr.checked model.notify, Events.onCheck ToggledNotify ]

-}
position : Position -> Html.Attribute msg
position pos =
    Internal.data "position" <|
        case pos of
            Start ->
                "start"

            End ->
                "end"


{-| A border around a checkbox, radio or switch field, showing that the whole
box is clickable. Set it on the field.
-}
outline : Html.Attribute msg
outline =
    Internal.data "variant" "outline"
