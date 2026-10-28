module Designsystemet.Badge exposing
    ( view, Content(..), toLabel
    , base, tinted
    , position, Corner(..), Overlap(..)
    )

{-| A small, non-interactive marker: a dot for "something new", or a count.

Mirrors `Badge` and `Badge.Position` from `@digdir/designsystemet-react`.

    Badge.position { placement = Badge.TopRight, overlap = Badge.Rectangle }
        []
        [ Badge.view (Badge.Capped { count = model.unread, max = 99 }) [ Ds.color Color.danger ]
        , inboxIcon
        ]

The CSS draws the number from `data-count`, so screen readers don't read it.
Put it in words where it matters, for example in the `aria-label` of the
button the badge sits on ("Innboks, 3 uleste").


# React → Elm

  - `<Badge />` → `Badge.view Badge.Dot []`
  - `<Badge count={5} />` → `Badge.view (Badge.Count 5) []`
  - `<Badge count={120} maxCount={99} />` → `Badge.view (Badge.Capped { count = 120, max = 99 }) []`
  - `variant="tinted"` → `Badge.tinted`
  - `<Badge.Position placement overlap>` → `Badge.position { placement = …, overlap = … } []`

React ignores `maxCount` without `count`. Here it can't be written.

@docs view, Content, toLabel


# Variants

@docs base, tinted


# Positioning

@docs position, Corner, Overlap

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr



-- BADGE


{-| What a badge shows.

  - `Dot`: a marker with no number.
  - `Count n`: the number `n`.
  - `Capped { count, max }`: the number, or `"99+"` once `count` passes `max`.

-}
type Content
    = Dot
    | Count Int
    | Capped { count : Int, max : Int }


{-| A `<span class="ds-badge">`. It has no children and shows its
[`Content`](#Content).
-}
view : Content -> List (Html.Attribute msg) -> Html msg
view content attributes =
    Html.span
        (Attr.class "ds-badge"
            :: Internal.whenJust (toLabel content) (Internal.data "count")
            :: attributes
        )
        []


{-| The text a badge shows, or `Nothing` for a dot. Use it for screen-reader
text.

    toLabel Dot == Nothing

    toLabel (Count 5) == Just "5"

    toLabel (Capped { count = 5, max = 9 }) == Just "5"

    toLabel (Capped { count = 10, max = 9 }) == Just "9+"

As in React, a `max` of `0` means no cap. Negative numbers aren't checked, so
keep `count` and `max` at zero or above.

-}
toLabel : Content -> Maybe String
toLabel content =
    case content of
        Dot ->
            Nothing

        Count count ->
            Just (String.fromInt count)

        Capped { count, max } ->
            if count /= 0 && max /= 0 && count > max then
                Just (String.fromInt max ++ "+")

            else
                Just (String.fromInt count)



-- VARIANTS


{-| A solid badge, the default.
-}
base : Html.Attribute msg
base =
    Internal.data "variant" "base"


{-| A softer badge with a tinted background.
-}
tinted : Html.Attribute msg
tinted =
    Internal.data "variant" "tinted"



-- POSITION


{-| The corner of the element the badge sits on. Unlike
[`Designsystemet.Placement`](Designsystemet-Placement), it overlaps the
element.
-}
type Corner
    = TopRight
    | TopLeft
    | BottomRight
    | BottomLeft


{-| The shape of the element under the badge. Over a `Circle`, such as an
[`Avatar`](Designsystemet-Avatar), the badge moves in to the circle's edge
instead of the bounding box corner.
-}
type Overlap
    = Rectangle
    | Circle


{-| A `<span class="ds-badge--position">` that floats the
[`Badge`](#view) inside it over a corner of the other content.

    Badge.position { placement = Badge.TopRight, overlap = Badge.Circle }
        []
        [ Badge.view Badge.Dot [ Ds.color Color.success ]
        , Avatar.view { name = Avatar.Label "Kari Nordmann", content = Avatar.Initials "KN" } []
        ]

React defaults to `TopRight` and `Rectangle`. The CSS needs both, so here they
are required.

-}
position :
    { placement : Corner, overlap : Overlap }
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
position { placement, overlap } attributes =
    Html.span
        (Attr.class "ds-badge--position"
            :: Internal.data "overlap" (overlapToString overlap)
            :: Internal.data "placement" (cornerToString placement)
            :: attributes
        )


cornerToString : Corner -> String
cornerToString placement =
    case placement of
        TopRight ->
            "top-right"

        TopLeft ->
            "top-left"

        BottomRight ->
            "bottom-right"

        BottomLeft ->
            "bottom-left"


overlapToString : Overlap -> String
overlapToString overlap =
    case overlap of
        Rectangle ->
            "rectangle"

        Circle ->
            "circle"
