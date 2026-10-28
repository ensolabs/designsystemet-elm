module Designsystemet.Internal.Form exposing
    ( Toggle
    , description
    , error
    , nameAttributes
    , toggle
    , viewToggle
    , visibleLabel
    )

{-| Pieces shared by the form composites (Textfield, Checkbox, Radio, Switch,
Fieldset). Not exposed.
-}

import Designsystemet.Field as Field
import Designsystemet.Internal.Attributes as Internal
import Designsystemet.Internal.Label exposing (Label(..))
import Designsystemet.Label
import Designsystemet.ValidationMessage as ValidationMessage
import Html exposing (Html)
import Html.Attributes as Attr



-- ACCESSIBLE NAME


{-| The attributes that name the control when there is no visible label.
-}
nameAttributes : Label msg -> List (Html.Attribute msg)
nameAttributes name =
    case name of
        Visible _ ->
            []

        AriaLabel text ->
            [ Attr.attribute "aria-label" text ]

        LabelledBy id ->
            [ Attr.attribute "aria-labelledby" id ]


{-| The `<label>`, if the name is a visible one. `<ds-field>` sets its `for`.
-}
visibleLabel : List (Html.Attribute msg) -> Label msg -> List (Html msg)
visibleLabel attributes name =
    case name of
        Visible children ->
            [ Designsystemet.Label.view attributes children ]

        AriaLabel _ ->
            []

        LabelledBy _ ->
            []



-- DESCRIPTION AND ERROR


description : Maybe (List (Html msg)) -> List (Html msg)
description maybeChildren =
    case maybeChildren of
        Just children ->
            [ Field.description [] children ]

        Nothing ->
            []


error : Maybe String -> List (Html msg)
error maybeMessage =
    case maybeMessage of
        Just message ->
            [ ValidationMessage.view [] [ Html.text message ] ]

        Nothing ->
            []



-- CHECKBOX, RADIO, SWITCH


type alias Toggle msg =
    { label : Label msg
    , description : Maybe (List (Html msg))
    , error : Maybe String
    , fieldAttributes : List (Html.Attribute msg)
    }


toggle : Label msg -> Toggle msg
toggle name =
    { label = name
    , description = Nothing
    , error = Nothing
    , fieldAttributes = []
    }


{-| The markup React's Checkbox, Radio and Switch share: the input first, then
a regular-weight label, the description and the error.
-}
viewToggle : List (Html.Attribute msg) -> Toggle msg -> List (Html.Attribute msg) -> Html msg
viewToggle inputAttributes config attributes =
    Field.view config.fieldAttributes
        (Html.input
            (Attr.class "ds-input"
                :: inputAttributes
                ++ nameAttributes config.label
                ++ attributes
            )
            []
            :: visibleLabel [ Internal.data "weight" "regular" ] config.label
            ++ description config.description
            ++ error config.error
        )
