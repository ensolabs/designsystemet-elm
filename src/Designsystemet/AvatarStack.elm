module Designsystemet.AvatarStack exposing
    ( AvatarStack, new, view
    , withExpand, Expand(..)
    , withOverflow
    )

{-| **Experimental.** A row of overlapping [avatars](Designsystemet-Avatar),
showing who is involved.

Mirrors `EXPERIMENTAL_AvatarStack` from `@digdir/designsystemet-react`. The
API may change in a minor version, as it may upstream.

    AvatarStack.new
        |> AvatarStack.withExpand AvatarStack.Grow
        |> AvatarStack.withOverflow "+3"
        |> AvatarStack.view [ Attr.attribute "aria-label" "Saksbehandlere" ]
            (List.map viewCaseworker (List.take 4 caseworkers))

Each avatar gets its own `<li>`.


# React → Elm

  - `<EXPERIMENTAL_AvatarStack>` → `AvatarStack.new |> AvatarStack.view []`
  - `expandable` → `AvatarStack.withExpand AvatarStack.Grow`
  - `expandable="fixed"` → `AvatarStack.withExpand AvatarStack.ReserveSpace`
  - trailing `<li>+5</li>` → `AvatarStack.withOverflow "+5"`
  - `style={{ '--dsc-avatar-stack-size': … }}` → `Attr.attribute "style" "--dsc-avatar-stack-size: …"`

The deprecated `gap`, `avatarSize`, `overlap` and `suffix` props are not
ported: use the CSS variables `--dsc-avatar-stack-gap`,
`--dsc-avatar-stack-size` and `--dsc-avatar-stack-overlap`, and
[`withOverflow`](#withOverflow).

Set CSS variables with `Attr.attribute "style"`, since `Attr.style` can't set
custom properties (names starting with `--`).

@docs AvatarStack, new, view


# Options

@docs withExpand, Expand
@docs withOverflow

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr


{-| Stack options. Start with [`new`](#new), add `with*` options, then
[`view`](#view).
-}
type AvatarStack
    = AvatarStack
        { expand : Maybe Expand
        , overflow : Maybe String
        }


{-| A stack that doesn't expand and has no overflow text.
-}
new : AvatarStack
new =
    AvatarStack { expand = Nothing, overflow = Nothing }


{-| How the avatars spread out to their full size on hover and keyboard focus.

  - `Grow`: the stack widens as the avatars spread, pushing its neighbours.
  - `ReserveSpace`: the stack always takes the expanded width, so nothing
    around it moves.

-}
type Expand
    = Grow
    | ReserveSpace


{-| Spread the avatars out on hover and focus. Adds `tabindex="0"` so
keyboard users can expand it too.
-}
withExpand : Expand -> AvatarStack -> AvatarStack
withExpand expand (AvatarStack config) =
    AvatarStack { config | expand = Just expand }


{-| Text after the avatars for the ones not shown, such as `"+5"`.
-}
withOverflow : String -> AvatarStack -> AvatarStack
withOverflow text (AvatarStack config) =
    AvatarStack { config | overflow = Just text }


{-| A `<ul class="ds-avatar-stack">` with each avatar in an `<li>`.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> AvatarStack -> Html msg
view attributes avatars (AvatarStack config) =
    Html.ul
        (Attr.class "ds-avatar-stack"
            :: Internal.whenJust config.expand (Internal.data "expandable" << expandToString)
            :: Internal.whenJust config.expand (\_ -> Attr.tabindex 0)
            :: attributes
        )
        (List.map (\avatar -> Html.li [] [ avatar ]) avatars
            ++ (case config.overflow of
                    Just text ->
                        [ Html.li [] [ Html.text text ] ]

                    Nothing ->
                        []
               )
        )


expandToString : Expand -> String
expandToString expand =
    case expand of
        Grow ->
            "true"

        ReserveSpace ->
            "fixed"
