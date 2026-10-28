module Designsystemet.ErrorSummary exposing
    ( view, Level(..)
    , Error, messageFor
    , FieldId, fieldId, fieldIdToString, linkTarget
    )

{-| A list of a form's errors after a failed submit, with a link to each
field.

Mirrors `ErrorSummary` from `@digdir/designsystemet-react`.

Each error shows up twice: under its field, and as a link to that field in
the summary. Keep one list of errors and read both from it:

    emailField : ErrorSummary.FieldId
    emailField =
        ErrorSummary.fieldId "email"

    validate : Model -> List ErrorSummary.Error
    validate model =
        if String.contains "@" model.email then
            []

        else
            [ { field = emailField, message = "Skriv inn en gyldig e-postadresse" } ]

    view : Model -> Html Msg
    view model =
        Html.form [ Events.onSubmit Submitted ]
            [ ErrorSummary.view
                { heading = "Du må rette disse feilene før du kan sende inn"
                , level = ErrorSummary.H2
                , errors = model.errors
                }
                []
            , Textfield.new (Ds.label "E-post")
                |> Textfield.withError (ErrorSummary.messageFor emailField model.errors)
                |> Textfield.view
                    [ ErrorSummary.linkTarget emailField
                    , Attr.value model.email
                    , Events.onInput ChangedEmail
                    ]
            ]

The [`FieldId`](#FieldId) ties the link to its field, and
[`messageFor`](#messageFor) gives the field the same message. Set
`model.errors` on submit, not while the user types: `<ds-error-summary>` takes
focus when it appears, so screen readers announce it at once.


# React → Elm

  - `<ErrorSummary>` → `ErrorSummary.view { … } []`
  - `<ErrorSummary.Heading>` → `heading` and `level`
  - `<ErrorSummary.List>` + `.Item` + `.Link` → `errors`
  - `<ErrorSummary.Link href="#email">` → `{ field = ErrorSummary.fieldId "email", … }`


# Managed by designsystemet-web

  - `role="group"`, `tabindex="-1"` and `aria-labelledby` on
    `<ds-error-summary>`
  - `id` on the heading


# Links in `Browser.application`

The links are plain `<a href="#email">` anchors. In a `Browser.application`
every link click goes to your `onUrlRequest`, so the browser won't jump to the
field. Move focus there in `update`:

    LinkClicked (Browser.Internal url) ->
        case url.fragment of
            Just id ->
                ( model, Task.attempt (\_ -> NoOp) (Browser.Dom.focus id) )

            Nothing ->
                ( model, Nav.pushUrl model.key (Url.toString url) )

@docs view, Level


# Errors

@docs Error, messageFor


# Field ids

@docs FieldId, fieldId, fieldIdToString, linkTarget

-}

import Designsystemet as Ds
import Designsystemet.Color as Color
import Designsystemet.Heading as Heading
import Designsystemet.Link as Link
import Designsystemet.List as DsList
import Html exposing (Html)
import Html.Attributes as Attr



-- FIELD IDS


{-| The `id` of a field that can have an error. A separate type, so the
summary's link and its field are built from the same value.
-}
type FieldId
    = FieldId String


{-| Make a `FieldId` from an id that is unique on the page.
-}
fieldId : String -> FieldId
fieldId =
    FieldId


{-| The id as a string, for `Browser.Dom.focus` and the like.
-}
fieldIdToString : FieldId -> String
fieldIdToString (FieldId id) =
    id


{-| Sets the `id` on the input, select or textarea the error is about, so the
summary's link jumps there.

    Checkbox.view [ ErrorSummary.linkTarget termsField, Attr.checked model.terms ]

-}
linkTarget : FieldId -> Html.Attribute msg
linkTarget (FieldId id) =
    Attr.id id



-- ERRORS


{-| A field and what's wrong with it.
-}
type alias Error =
    { field : FieldId
    , message : String
    }


{-| The message for one field, ready for `withError` on a
[`Textfield`](Designsystemet-Textfield), [`Checkbox`](Designsystemet-Checkbox),
[`Radio`](Designsystemet-Radio) or [`Fieldset`](Designsystemet-Fieldset). If a
field has several errors, the first one wins.

    Textfield.withError (ErrorSummary.messageFor emailField model.errors)

-}
messageFor : FieldId -> List Error -> Maybe String
messageFor field errors =
    errors
        |> List.filter (\error -> error.field == field)
        |> List.head
        |> Maybe.map .message



-- VIEW


{-| The summary's heading level. No `H1`: the page already has one, and
`<ds-error-summary>` only takes its name from an `h2`–`h6`.
-}
type Level
    = H2
    | H3
    | H4
    | H5
    | H6


{-| A `<ds-error-summary class="ds-error-summary">` with a heading and a list
of links. The attributes go on `<ds-error-summary>`.

Renders nothing when there are no errors, so you can always call it. The
summary appears, and takes focus, once there is something to fix.

React defaults to `h2`. Here the level is required, as for
[`Heading`](Designsystemet-Heading).

-}
view :
    { heading : String
    , level : Level
    , errors : List Error
    }
    -> List (Html.Attribute msg)
    -> Html msg
view { heading, level, errors } attributes =
    if List.isEmpty errors then
        Html.text ""

    else
        Html.node "ds-error-summary"
            (Attr.class "ds-error-summary" :: attributes)
            [ Heading.view (toHeadingLevel level) [] [ Html.text heading ]
            , DsList.unordered [] (List.map viewError errors)
            ]


toHeadingLevel : Level -> Heading.Level
toHeadingLevel level =
    case level of
        H2 ->
            Heading.H2

        H3 ->
            Heading.H3

        H4 ->
            Heading.H4

        H5 ->
            Heading.H5

        H6 ->
            Heading.H6


viewError : Error -> Html msg
viewError { field, message } =
    DsList.item []
        [ Link.view [ Ds.color Color.neutral, Attr.href ("#" ++ fieldIdToString field) ]
            [ Html.text message ]
        ]
