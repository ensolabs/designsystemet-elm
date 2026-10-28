module Designsystemet.Size exposing (Size, sm, md, lg, toString)

{-| The size scale behind `data-size`. Use it with
[`Designsystemet.size`](Designsystemet#size).

Three sizes, as in React, because the theme's CSS defines only `sm`, `md` and
`lg`. Any other value matches no rule, and everything inside (Tailwind's
spacing utilities included) silently keeps the parent's size.

@docs Size, sm, md, lg, toString

-}


{-| A size. Unset means `md`.
-}
type Size
    = Sm
    | Md
    | Lg


{-| Small.
-}
sm : Size
sm =
    Sm


{-| Medium, the default.
-}
md : Size
md =
    Md


{-| Large.
-}
lg : Size
lg =
    Lg


{-| The value written to `data-size`.
-}
toString : Size -> String
toString size =
    case size of
        Sm ->
            "sm"

        Md ->
            "md"

        Lg ->
            "lg"
