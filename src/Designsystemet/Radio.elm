module Designsystemet.Radio exposing
    ( Radio, new, view
    , withDescription, withError, withFieldAttributes
    )

{-| A radio button with its label, description and error message.

Mirrors `Radio` from `@digdir/designsystemet-react`.

Radio buttons come in groups, so put them in a
[`Fieldset`](Designsystemet-Fieldset) whose legend asks the question:

    Fieldset.new [ Html.text "Hvordan vil du bli kontaktet?" ]
        |> Fieldset.withError model.contactError
        |> Fieldset.view []
            (List.map (contactOption model.contact) [ Email, Phone ])

    contactOption : Maybe Contact -> Contact -> Html Msg
    contactOption selected contact =
        Radio.new (Ds.label (Contact.toLabel contact))
            |> Radio.view
                [ Attr.name "contact"
                , Attr.checked (selected == Just contact)
                , Events.onCheck (\_ -> PickedContact contact)
                ]

An error on the fieldset is linked to every radio in it, so the radios
usually don't need [`withError`](#withError).

The attributes you give `view` go on the `<input type="radio">`, like React's
rest props. Attributes for the field around it go in
[`withFieldAttributes`](#withFieldAttributes).


# React → Elm

  - `<Radio label="…" />` → `Radio.new (Ds.label "…") |> Radio.view []`
  - `aria-label="…"` → `Radio.new (Ds.ariaLabel "…")`
  - `description={…}` → `Radio.withDescription [ … ]`
  - `error="…"` → `Radio.withError (Just "…")`
  - `variant="outline"` → `Radio.withFieldAttributes [ Field.outline ]`
  - `position="end"` → `Radio.withFieldAttributes [ Field.position Field.End ]`
  - `data-size`, `className`, `style` → `Radio.withFieldAttributes [ … ]`
  - `name`, `checked`, `onChange`, … → `Radio.view [ Attr.name …, Attr.checked …, … ]`

@docs Radio, new, view


# Options

@docs withDescription, withError, withFieldAttributes

-}

import Designsystemet exposing (Label)
import Designsystemet.Internal.Form as Form
import Html exposing (Html)
import Html.Attributes as Attr


{-| A radio button being configured. Start with [`new`](#new), end with
[`view`](#view).
-}
type Radio msg
    = Radio (Form.Toggle msg)


{-| A radio button with this accessible name. With
[`Ds.label`](Designsystemet#label) the label is shown next to it.
-}
new : Label msg -> Radio msg
new label =
    Radio (Form.toggle label)


{-| Help text under the label.
-}
withDescription : List (Html msg) -> Radio msg -> Radio msg
withDescription description (Radio config) =
    Radio { config | description = Just description }


{-| An error message under the radio button, or `Nothing` for none.
-}
withError : Maybe String -> Radio msg -> Radio msg
withError error (Radio config) =
    Radio { config | error = error }


{-| Attributes for the `<ds-field>` around the radio button: `Field.outline`,
`Field.position`, `Ds.size`, a class, …
-}
withFieldAttributes : List (Html.Attribute msg) -> Radio msg -> Radio msg
withFieldAttributes attributes (Radio config) =
    Radio { config | fieldAttributes = config.fieldAttributes ++ attributes }


{-| Render the radio button. The attributes go on the `<input>`.
-}
view : List (Html.Attribute msg) -> Radio msg -> Html msg
view attributes (Radio config) =
    Form.viewToggle [ Attr.type_ "radio" ] config attributes
