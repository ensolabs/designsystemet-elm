module Designsystemet.Tooltip exposing
    ( content, placement, noAutoPlacement
    , onText
    )

{-| Short text shown when the user hovers over or focuses an element.

Mirrors `Tooltip` from `@digdir/designsystemet-react`.

A tooltip is an attribute on the element it explains. `designsystemet-web`
renders one shared tooltip next to whichever element with
[`content`](#content) is hovered or focused.

    Button.icon { label = "Slett", icon = trashIcon }
        [ Button.tertiary, Tooltip.content "Slett", Events.onClick Delete ]

    Button.view [ Tooltip.content "Lagres som utkast", Tooltip.placement Placement.Bottom ]
        [ Html.text "Lagre" ]

The element must be focusable so keyboard users see the tooltip. Buttons and
links are. For plain text, use [`onText`](#onText).


# Accessible names

`designsystemet-web` also exposes the tooltip text to screen readers:

  - On an element with no text of its own (an icon button), the tooltip becomes
    its `aria-label`. If you already set a label (as `Button.icon` does), use
    the same text for both, or the tooltip replaces it.
  - On an element with text, the tooltip becomes its `aria-description`.


# React → Elm

  - `<Tooltip content="…"><button /></Tooltip>` → `Html.button [ Tooltip.content "…" ] []`
  - `<Tooltip content="…">Some text</Tooltip>` → `Tooltip.onText { content = "…", text = "Some text" } []`
  - `placement="bottom"` → `Tooltip.placement Placement.Bottom`
  - `autoPlacement={false}` → `Tooltip.noAutoPlacement`


# Differences from React

React always renders `data-placement="top"` and `data-autoplacement="true"`.
Those are `designsystemet-web`'s defaults, so they are only rendered when you
ask for something else.


# Managed by designsystemet-web

Never set these yourself on an element with a tooltip: `aria-label` (except
with the same text, see above) and `aria-description`. The tooltip element
itself (`.ds-tooltip`) is created by `designsystemet-web`, so don't render one.


# Attributes

@docs content, placement, noAutoPlacement


# Text with a tooltip

@docs onText

-}

import Designsystemet.Internal.Attributes as Internal
import Designsystemet.Placement as Placement exposing (Placement)
import Html exposing (Html)
import Html.Attributes as Attr



-- ATTRIBUTES


{-| Give an element a tooltip with this text.
-}
content : String -> Html.Attribute msg
content =
    Internal.data "tooltip"


{-| Which side of the element the tooltip appears on. Defaults to
`Placement.Top`.
-}
placement : Placement -> Html.Attribute msg
placement =
    Internal.data "placement" << Placement.toString


{-| Keep the tooltip on the requested side even when there is no room. By
default `designsystemet-web` flips it to the opposite side.
-}
noAutoPlacement : Html.Attribute msg
noAutoPlacement =
    Internal.data "autoplacement" "false"



-- TEXT


{-| Text with a tooltip, like an abbreviation. It's wrapped in a
`<span tabindex="0">` so keyboard users can focus it.

    Html.p []
        [ Html.text "Oppgi "
        , Tooltip.onText { content = "Organisasjonsnummer", text = "org.nr." } []
        ]

-}
onText : { content : String, text : String } -> List (Html.Attribute msg) -> Html msg
onText config attributes =
    Html.span
        (content config.content
            :: Attr.tabindex 0
            :: attributes
        )
        [ Html.text config.text ]
