module Designsystemet.Fieldset exposing
    ( Fieldset, new, view
    , withDescription, withError, withLegendAttributes
    )

{-| Related fields under one legend, such as radio buttons for one question
or the parts of an address.

Mirrors `Fieldset` from `@digdir/designsystemet-react`.

    Fieldset.new [ Html.text "Hvor vil du hente pakken?" ]
        |> Fieldset.withDescription [ Html.text "Du får en SMS når den er klar" ]
        |> Fieldset.withError model.pickupError
        |> Fieldset.view [] (List.map (pickupOption model.pickup) [ PickupPoint, HomeDelivery ])

    pickupOption : Maybe Pickup -> Pickup -> Html Msg
    pickupOption selected pickup =
        Radio.new (Ds.label (Pickup.toLabel pickup))
            |> Radio.view
                [ Attr.name "pickup"
                , Attr.checked (selected == Just pickup)
                , Events.onCheck (\_ -> PickedPickup pickup)
                ]

The legend names the group, so it is required.

The error is a [`ValidationMessage`](Designsystemet-ValidationMessage) last
in the group. Every [`Field`](Designsystemet-Field) inside links it to its
input and is marked invalid while it is there. React has no `error` prop; you
add the message as a child, which is what this does.


# React → Elm

  - `<Fieldset>` + `<Fieldset.Legend>…` → `Fieldset.new [ … ] |> Fieldset.view [] [ … ]`
  - `<Fieldset.Description>…` → `Fieldset.withDescription [ … ]`
  - `<ValidationMessage>` as the last child → `Fieldset.withError (Just "…")`
  - `<Fieldset.Legend className="…">` → `Fieldset.withLegendAttributes [ Attr.class "…" ]`


# Managed by designsystemet-web

  - `aria-labelledby` on the `<fieldset>`, pointing at the legend and the
    description
  - `id` on the legend and the description

@docs Fieldset, new, view


# Options

@docs withDescription, withError, withLegendAttributes

-}

import Designsystemet.Internal.Form as Form
import Designsystemet.Label as Label
import Designsystemet.Paragraph as Paragraph
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed as Keyed


{-| A fieldset being configured. Start with [`new`](#new), end with
[`view`](#view).
-}
type Fieldset msg
    = Fieldset
        { legend : List (Html msg)
        , legendAttributes : List (Html.Attribute msg)
        , description : Maybe (List (Html msg))
        , error : Maybe String
        }


{-| A fieldset with this legend.
-}
new : List (Html msg) -> Fieldset msg
new legend =
    Fieldset { legend = legend, legendAttributes = [], description = Nothing, error = Nothing }


{-| Attributes for the `<legend>`. To hide it visually but keep it for screen
readers, use `ds-sr-only`:

    Fieldset.new [ Html.text "Tekst for skjermleser" ]
        |> Fieldset.withLegendAttributes [ Attr.class "ds-sr-only" ]

-}
withLegendAttributes : List (Html.Attribute msg) -> Fieldset msg -> Fieldset msg
withLegendAttributes attributes (Fieldset config) =
    Fieldset { config | legendAttributes = config.legendAttributes ++ attributes }


{-| Help text under the legend, read when the user enters the group.
-}
withDescription : List (Html msg) -> Fieldset msg -> Fieldset msg
withDescription description (Fieldset config) =
    Fieldset { config | description = Just description }


{-| An error for the whole group, like "Velg ett alternativ", or `Nothing`.
-}
withError : Maybe String -> Fieldset msg -> Fieldset msg
withError error (Fieldset config) =
    Fieldset { config | error = error }


{-| A `<fieldset class="ds-fieldset">`. The attributes go on the
`<fieldset>`.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Fieldset msg -> Html msg
view attributes children (Fieldset config) =
    -- Keyed so the fields keep their DOM nodes, and focus, when the
    -- description or error comes and goes.
    Keyed.node "fieldset"
        (Attr.class "ds-fieldset" :: attributes)
        (( "legend", Label.viewAs Html.legend config.legendAttributes config.legend )
            :: List.map (Tuple.pair "description") (viewDescription config.description)
            ++ List.indexedMap (\index child -> ( "child-" ++ String.fromInt index, child )) children
            ++ List.map (Tuple.pair "error") (Form.error config.error)
        )


viewDescription : Maybe (List (Html msg)) -> List (Html msg)
viewDescription maybeChildren =
    case maybeChildren of
        Just children ->
            [ Paragraph.view [] children ]

        Nothing ->
            []
