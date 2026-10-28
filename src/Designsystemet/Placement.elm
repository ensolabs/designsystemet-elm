module Designsystemet.Placement exposing (Placement(..), toString)

{-| Where a floating element sits next to the element it belongs to.

[`Popover`](Designsystemet-Popover), [`Dropdown`](Designsystemet-Dropdown)
and [`Tooltip`](Designsystemet-Tooltip) each have a `placement` attribute that
takes one of these:

    Popover.view helpId [ Popover.placement Placement.Right ] [ Html.text "…" ]

`designsystemet-web` positions the element with Floating UI and flips it to the
other side when there is no room, unless you turn that off.

Same as React's `Placement`: Floating UI's placements plus `'none'`.


# React → Elm

  - `placement="top"` → `Placement.Top`
  - `placement="bottom-end"` → `Placement.BottomEnd`
  - `placement="none"` → `Placement.None`

@docs Placement, toString

-}


{-| A side, and optionally which end of that side to align to.

`TopStart` sits above the trigger with the start edges aligned (left edges in
a left-to-right language). `TopEnd` aligns the end edges.

`None` turns off positioning, for when you do it in CSS.

-}
type Placement
    = Top
    | TopStart
    | TopEnd
    | Right
    | RightStart
    | RightEnd
    | Bottom
    | BottomStart
    | BottomEnd
    | Left
    | LeftStart
    | LeftEnd
    | None


{-| The value written to `data-placement`, like `"bottom-end"`.
-}
toString : Placement -> String
toString placement =
    case placement of
        Top ->
            "top"

        TopStart ->
            "top-start"

        TopEnd ->
            "top-end"

        Right ->
            "right"

        RightStart ->
            "right-start"

        RightEnd ->
            "right-end"

        Bottom ->
            "bottom"

        BottomStart ->
            "bottom-start"

        BottomEnd ->
            "bottom-end"

        Left ->
            "left"

        LeftStart ->
            "left-start"

        LeftEnd ->
            "left-end"

        None ->
            "none"
