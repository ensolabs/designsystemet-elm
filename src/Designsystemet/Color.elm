module Designsystemet.Color exposing
    ( Color, accent, neutral, custom
    , Severity(..), fromSeverity, info, success, warning, danger
    , toString
    )

{-| The colors behind `data-color`. Use them with
[`Designsystemet.color`](Designsystemet#color).

Your theme decides which colors exist. A theme built at
[theme.designsystemet.no](https://theme.designsystemet.no) has `neutral`,
usually `accent`, your brand colors and the four severity colors, so
[`custom`](#custom) takes any name. Keep those names in one module so a typo
can only happen once:

    module Theme exposing (brand, highlight)

    import Designsystemet.Color as Color exposing (Color)

    brand : Color
    brand =
        Color.custom "brand1"


# Theme colors

@docs Color, accent, neutral, custom


# Severity colors

Some components, such as [`Alert`](Designsystemet-Alert), only make sense in
a severity color. They take a `Severity` instead of a `Color`, so they can't
get a color the CSS doesn't style.

@docs Severity, fromSeverity, info, success, warning, danger


# Conversion

@docs toString

-}


{-| A color name from your theme.
-}
type Color
    = Color String


{-| The main color of the default theme.
-}
accent : Color
accent =
    Color "accent"


{-| Grey tones. Every theme has them.
-}
neutral : Color
neutral =
    Color "neutral"


{-| Any color your theme defines, like `"brand1"` or `"hospital"`.
-}
custom : String -> Color
custom =
    Color


{-| The four severities every theme has.
-}
type Severity
    = Info
    | Success
    | Warning
    | Danger


{-| A severity as a color, for components that take any color.
-}
fromSeverity : Severity -> Color
fromSeverity severity =
    Color <|
        case severity of
            Info ->
                "info"

            Success ->
                "success"

            Warning ->
                "warning"

            Danger ->
                "danger"


{-| `fromSeverity Info`: Neutral information.
-}
info : Color
info =
    fromSeverity Info


{-| `fromSeverity Success`: Something went well.
-}
success : Color
success =
    fromSeverity Success


{-| `fromSeverity Warning`: Something needs attention.
-}
warning : Color
warning =
    fromSeverity Warning


{-| `fromSeverity Danger`: Something went wrong, or can't be undone.
-}
danger : Color
danger =
    fromSeverity Danger


{-| The value written to `data-color`.
-}
toString : Color -> String
toString (Color color) =
    color
