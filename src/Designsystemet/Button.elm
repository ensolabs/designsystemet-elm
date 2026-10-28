module Designsystemet.Button exposing
    ( view, viewAs
    , primary, secondary, tertiary
    , loading, Loading(..)
    , icon, iconLoading
    )

{-| Buttons start actions.

Mirrors `Button` from `@digdir/designsystemet-react`.

    Button.view [ Events.onClick Save ] [ Html.text "Lagre" ]

    Button.view [ Button.secondary, Ds.color Color.danger, Events.onClick Delete ]
        [ Html.text "Slett" ]

Buttons default to `type="button"` so they never submit a form by accident.
Pass `Attr.type_ "submit"` for a submit button.


# React → Elm

  - `<Button>` → `Button.view []`
  - `variant="secondary"` → `Button.secondary`
  - `loading` → `Button.loading Busy []`
  - `icon` + `aria-label` → `Button.icon { label = "…", icon = … } []`
  - `asChild` + `<a>` → `Button.viewAs Html.a [ Attr.href "…" ]`
  - `command` / `commandfor` → `Dialog.showModal id`, `Popover.toggle id`, …

@docs view, viewAs


# Variants

@docs primary, secondary, tertiary


# Busy buttons

@docs loading, Loading


# Icon buttons

@docs icon, iconLoading

-}

import Designsystemet.Internal.Attributes as Internal
import Designsystemet.Spinner as Spinner
import Html exposing (Html)
import Html.Attributes as Attr



-- VIEW


{-| A `<button class="ds-button" type="button">`.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view attributes =
    Html.button (Attr.class "ds-button" :: Attr.type_ "button" :: attributes)


{-| A button rendered as another element than `<button>` (React's `asChild`).

    Button.viewAs Html.a [ Attr.href "/ny" ] [ Html.text "Ny sak" ]

-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewAs element attributes =
    element (Attr.class "ds-button" :: attributes)



-- VARIANTS


{-| The default, for the main action in a context.
-}
primary : Html.Attribute msg
primary =
    Internal.data "variant" "primary"


{-| For actions next to a primary one.
-}
secondary : Html.Attribute msg
secondary =
    Internal.data "variant" "secondary"


{-| For low-emphasis actions.
-}
tertiary : Html.Attribute msg
tertiary =
    Internal.data "variant" "tertiary"



-- LOADING


{-| Whether a button is waiting for something.

`BusyWith` replaces the spinner with your own loader.

-}
type Loading msg
    = Idle
    | Busy
    | BusyWith (Html msg)


{-| A button that can be busy. While busy it gets `aria-busy="true"` and a
spinner before its label.

    Button.loading
        (if model.saving then
            Busy

         else
            Idle
        )
        [ Events.onClick Save ]
        [ Html.text "Lagre" ]

Prefer mapping your own state to `Loading` over an `if`:

    Button.loading (Request.toLoading model.save) [ Events.onClick Save ] [ Html.text "Lagre" ]

-}
loading : Loading msg -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
loading state attributes children =
    case loader state of
        Just indicator ->
            view (Attr.attribute "aria-busy" "true" :: attributes) (indicator :: children)

        Nothing ->
            view attributes children


loader : Loading msg -> Maybe (Html msg)
loader state =
    case state of
        Idle ->
            Nothing

        Busy ->
            Just (Spinner.decorative [])

        BusyWith custom ->
            Just custom



-- ICON BUTTONS


{-| An icon-only button. The label is required and becomes the `aria-label`,
since screen readers can't read the icon.

    Button.icon { label = "Lukk", icon = FeatherIcons.x |> FeatherIcons.toHtml [] }
        [ Button.tertiary, Events.onClick Close ]

-}
icon : { label : String, icon : Html msg } -> List (Html.Attribute msg) -> Html msg
icon config attributes =
    iconLoading Idle config attributes


{-| An icon button that can be busy. While busy, the spinner takes the icon's
place.
-}
iconLoading : Loading msg -> { label : String, icon : Html msg } -> List (Html.Attribute msg) -> Html msg
iconLoading state config attributes =
    let
        iconAttributes : List (Html.Attribute msg)
        iconAttributes =
            Internal.data "icon" "true" :: Attr.attribute "aria-label" config.label :: attributes
    in
    case loader state of
        Just indicator ->
            view (Attr.attribute "aria-busy" "true" :: iconAttributes) [ indicator ]

        Nothing ->
            view iconAttributes [ config.icon ]
