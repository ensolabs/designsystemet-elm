module Designsystemet.Spinner exposing
    ( view, decorative
    , Size(..), size
    )

{-| A spinning loading indicator.

Mirrors `Spinner` from `@digdir/designsystemet-react`.

    Spinner.view { label = "Henter saker" } [ Spinner.size Spinner.Large ]


# React → Elm

  - `<Spinner aria-label="…" />` → `Spinner.view { label = "…" } []`
  - `<Spinner aria-hidden />` → `Spinner.decorative []`
  - `data-size="lg"` → `Spinner.size Spinner.Large`

The spinner is an `<svg>`, so add classes with `Svg.Attributes.class`, never
`Html.Attributes.class`. The latter sets the `className` property, which is
read-only on SVG elements, so the browser throws a `TypeError` and your whole
view stops rendering.

    Spinner.view { label = "Henter saker" } [ SvgAttr.class "size-6 shrink-0" ]

@docs view, decorative


# Sizes

@docs Size, size

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr
import Svg
import Svg.Attributes as SvgAttr


{-| A spinner announced to screen readers. As in React, `aria-label` is
required unless the spinner is hidden.

Add classes with `Svg.Attributes.class`, never `Html.Attributes.class` (it
throws on an `<svg>`).

-}
view : { label : String } -> List (Html.Attribute msg) -> Html msg
view { label } attributes =
    spinner (Attr.attribute "aria-label" label :: attributes)


{-| A spinner hidden from screen readers, for when something nearby already
says work is in progress (like a busy [`Button`](Designsystemet-Button)).

Add classes with `Svg.Attributes.class`, never `Html.Attributes.class` (it
throws on an `<svg>`).

-}
decorative : List (Html.Attribute msg) -> Html msg
decorative attributes =
    spinner (Attr.attribute "aria-hidden" "true" :: attributes)


spinner : List (Html.Attribute msg) -> Html msg
spinner attributes =
    Svg.svg
        (SvgAttr.class "ds-spinner"
            :: Attr.attribute "role" "img"
            :: SvgAttr.viewBox "0 0 50 50"
            :: attributes
        )
        [ circle "ds-spinner__background"
        , circle "ds-spinner__circle"
        ]


circle : String -> Html msg
circle class =
    Svg.circle
        [ SvgAttr.class class
        , SvgAttr.cx "25"
        , SvgAttr.cy "25"
        , SvgAttr.r "20"
        , SvgAttr.fill "none"
        , SvgAttr.strokeWidth "5"
        ]
        []



-- SIZE


{-| Spinners have their own size scale, wider than
[`Designsystemet.Size`](Designsystemet-Size).
-}
type Size
    = TwoExtraSmall
    | ExtraSmall
    | Small
    | Medium
    | Large
    | ExtraLarge


{-| Set the spinner's `data-size`.
-}
size : Size -> Html.Attribute msg
size s =
    Internal.data "size" <|
        case s of
            TwoExtraSmall ->
                "2xs"

            ExtraSmall ->
                "xs"

            Small ->
                "sm"

            Medium ->
                "md"

            Large ->
                "lg"

            ExtraLarge ->
                "xl"
