module Designsystemet.Textfield exposing
    ( Textfield, new, multiline, view
    , withDescription, withPrefix, withSuffix, withCounter, withError
    , withFieldAttributes
    )

{-| A text input wired up with its label, description, prefix, suffix,
character counter and error message.

Mirrors `Textfield` from `@digdir/designsystemet-react`.

    Textfield.new (Ds.label "E-post")
        |> Textfield.withDescription [ Html.text "Vi sender kvitteringen hit" ]
        |> Textfield.withError model.emailError
        |> Textfield.view
            [ Attr.type_ "email"
            , Attr.value model.email
            , Events.onInput ChangedEmail
            ]

    Textfield.multiline (Ds.label "Begrunnelse")
        |> Textfield.withCounter { limit = 500, under = "%d tegn igjen", over = "%d tegn for mye" }
        |> Textfield.view [ Attr.value model.reason, Events.onInput ChangedReason ]

The attributes you give `view` go on the `<input>` or `<textarea>`, like
React's rest props. Attributes for the field around it go in
[`withFieldAttributes`](#withFieldAttributes).

It's built on [`Field`](Designsystemet-Field), so `<ds-field>` links the label,
description, counter and error to the input and sets `aria-invalid` while there
is an error. For anything this module doesn't do, build the field yourself from
the same parts.


# React → Elm

  - `<Textfield label="…" />` → `Textfield.new (Ds.label "…") |> Textfield.view []`
  - `aria-label="…"` → `Textfield.new (Ds.ariaLabel "…")`
  - `multiline` → `Textfield.multiline (Ds.label "…")`
  - `description={…}` → `Textfield.withDescription [ … ]`
  - `prefix="NOK"` → `Textfield.withPrefix "NOK"`
  - `suffix="kr"` → `Textfield.withSuffix "kr"`
  - `counter={140}` → `Textfield.withCounter { limit = 140, under = "…", over = "…" }`
  - `error="…"` → `Textfield.withError (Just "…")`
  - `className`, `style`, `data-size` → `Textfield.withFieldAttributes [ … ]`
  - `type`, `value`, `onChange`, … → `Textfield.view [ Attr.type_ …, Attr.value …, Events.onInput … ]`

React's counter falls back to Norwegian texts. Here you give both, in your
app's language.

@docs Textfield, new, multiline, view


# Options

@docs withDescription, withPrefix, withSuffix, withCounter, withError
@docs withFieldAttributes

-}

import Designsystemet exposing (Label)
import Designsystemet.Field as Field
import Designsystemet.Input as Input
import Designsystemet.Internal.Form as Form
import Designsystemet.Textarea as Textarea
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed as Keyed


{-| A text field being configured. Start with [`new`](#new) or
[`multiline`](#multiline), end with [`view`](#view).
-}
type Textfield msg
    = Textfield
        { label : Label msg
        , lines : Lines
        , description : Maybe (List (Html msg))
        , prefix : Maybe String
        , suffix : Maybe String
        , counter : Maybe Field.Counter
        , error : Maybe String
        , fieldAttributes : List (Html.Attribute msg)
        }


type Lines
    = SingleLine
    | MultiLine


init : Lines -> Label msg -> Textfield msg
init lines label =
    Textfield
        { label = label
        , lines = lines
        , description = Nothing
        , prefix = Nothing
        , suffix = Nothing
        , counter = Nothing
        , error = Nothing
        , fieldAttributes = []
        }


{-| A one-line text field (an `<input>`) with this accessible name. With
[`Ds.label`](Designsystemet#label) the label is shown above it.
-}
new : Label msg -> Textfield msg
new =
    init SingleLine


{-| A text field for longer text (a `<textarea>`) with this accessible name.
-}
multiline : Label msg -> Textfield msg
multiline =
    init MultiLine


{-| Help text between the label and the input.
-}
withDescription : List (Html msg) -> Textfield msg -> Textfield msg
withDescription description (Textfield config) =
    Textfield { config | description = Just description }


{-| A short text in front of the input, like `"NOK"` or `"https://"`. Screen
readers skip it, so make sure the label says the same thing.
-}
withPrefix : String -> Textfield msg -> Textfield msg
withPrefix prefix (Textfield config) =
    Textfield { config | prefix = Just prefix }


{-| A short text after the input, like `"kr"` or `"pr. mnd."`. Screen readers
skip it, so make sure the label says the same thing.
-}
withSuffix : String -> Textfield msg -> Textfield msg
withSuffix suffix (Textfield config) =
    Textfield { config | suffix = Just suffix }


{-| Count characters against a limit. See
[`Field.counter`](Designsystemet-Field#counter).
-}
withCounter : Field.Counter -> Textfield msg -> Textfield msg
withCounter counter (Textfield config) =
    Textfield { config | counter = Just counter }


{-| An error message under the input, or `Nothing` for none:

    |> Textfield.withError (Dict.get "email" model.errors)

It's a `String` because an error is read aloud with the input, and the same
text usually goes in an [`ErrorSummary`](Designsystemet-ErrorSummary) too. Keep
one list of errors for both and get this field's message with
[`ErrorSummary.messageFor`](Designsystemet-ErrorSummary#messageFor).

-}
withError : Maybe String -> Textfield msg -> Textfield msg
withError error (Textfield config) =
    Textfield { config | error = error }


{-| Attributes for the `<ds-field>` around everything: `Ds.size`, a class, …
-}
withFieldAttributes : List (Html.Attribute msg) -> Textfield msg -> Textfield msg
withFieldAttributes attributes (Textfield config) =
    Textfield { config | fieldAttributes = config.fieldAttributes ++ attributes }


{-| Render the field. The attributes go on the `<input>` or `<textarea>`.

Leave out `aria-describedby` and `aria-invalid`. The field sets them.

-}
view : List (Html.Attribute msg) -> Textfield msg -> Html msg
view attributes (Textfield config) =
    let
        inputAttributes : List (Html.Attribute msg)
        inputAttributes =
            Form.nameAttributes config.label ++ attributes

        control : Html msg
        control =
            case config.lines of
                SingleLine ->
                    Input.view inputAttributes

                MultiLine ->
                    Textarea.view inputAttributes
    in
    -- Keyed, so the input keeps its DOM node (and focus) when the
    -- description, counter or error come and go.
    Field.viewKeyed config.fieldAttributes
        (List.map (Tuple.pair "label") (Form.visibleLabel [] config.label)
            ++ List.map (Tuple.pair "description") (Form.description config.description)
            ++ [ ( "affixes"
                 , Keyed.node "div"
                    [ Attr.class "ds-field-affixes" ]
                    (List.map (Tuple.pair "prefix") (viewAffix config.prefix)
                        ++ ( "control", control )
                        :: List.map (Tuple.pair "suffix") (viewAffix config.suffix)
                    )
                 )
               ]
            ++ List.map (Tuple.pair "counter") (viewCounter config.counter)
            ++ List.map (Tuple.pair "error") (Form.error config.error)
        )


viewAffix : Maybe String -> List (Html msg)
viewAffix maybeText =
    case maybeText of
        Just text ->
            [ Field.affix [] [ Html.text text ] ]

        Nothing ->
            []


viewCounter : Maybe Field.Counter -> List (Html msg)
viewCounter maybeCounter =
    case maybeCounter of
        Just config ->
            [ Field.counter config [] ]

        Nothing ->
            []
