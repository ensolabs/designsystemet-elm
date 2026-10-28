module Designsystemet.Avatar exposing
    ( view, viewAs
    , Name(..), Content(..)
    , Size(..), size
    )

{-| A person or organisation shown as initials, a picture or an icon in a
circle.

Mirrors `Avatar` from `@digdir/designsystemet-react`.

    Avatar.view { name = Avatar.Label "Kari Nordmann", content = Avatar.Initials "KN" } []

    Avatar.view
        { name = Avatar.Tooltip "Ola Nordmann"
        , content = Avatar.Image "/profiles/ola.jpg"
        }
        [ Avatar.size Avatar.Small ]

The config has two parts:

  - [`Name`](#Name), what screen readers announce: a label, a label that also
    shows as a tooltip, or nothing when the name is already next to it.
  - [`Content`](#Content), what it shows: initials, a picture, an icon, or the
    default person silhouette.


# React → Elm

  - `<Avatar aria-label="Kari">KN</Avatar>` → `Avatar.view { name = Label "Kari", content = Initials "KN" } []`
  - `<Avatar data-tooltip="Kari">…` → `{ name = Tooltip "Kari", … }`
  - `<Avatar aria-hidden>…` → `{ name = Decorative, … }`
  - `<Avatar …><img src="…" alt="" /></Avatar>` → `{ content = Image "…", … }`
  - `<Avatar …><Icon /></Avatar>` → `{ content = Icon icon, … }`
  - `<Avatar … />` (no children) → `{ content = Placeholder, … }`
  - `data-size="xs"` → `Avatar.size Avatar.ExtraSmall`
  - `asChild` + `<a>` → `Avatar.viewAs Html.a { … } [ Attr.href "…" ]`

React's deprecated `initials`, `data-initials` and `variant` props are not
ported. For a square avatar, set the CSS variable:
`Attr.attribute "style" "--dsc-avatar-radius: var(--ds-border-radius-md)"`.
(`Attr.style` can't set custom properties, the names starting with `--`.)


# Managed by designsystemet-web

With a `Tooltip` name, `@digdir/designsystemet-web` shows the tooltip popover
and keeps the accessible name in sync with `data-tooltip`. On
[`view`](#view) (`role="img"`) that is the `aria-label` this module already
renders, so nothing changes. On [`viewAs`](#viewAs) with `Initials` the element
has its own text, so the web layer moves the name from `aria-label` to
`aria-description`: the link or button is announced by its initials, with the
name as description. Use a `Label` name if the name must be the accessible
name.

@docs view, viewAs


# Name and content

@docs Name, Content


# Sizes

@docs Size, size

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr



-- NAME AND CONTENT


{-| Who the avatar is, for assistive technology.

  - `Label name`: the avatar's `aria-label`.
  - `Tooltip name`: the `aria-label`, also shown as a tooltip on hover and
    focus. Adds `tabindex="0"` so keyboard users can reach the tooltip.
  - `Decorative`: `aria-hidden="true"`, for when the name is written next to
    the avatar.

-}
type Name
    = Label String
    | Tooltip String
    | Decorative


{-| What the avatar shows.

  - `Initials "KN"`: one to three letters, upper-cased by the CSS.
  - `Image src`: `<img src="…" alt="">`. The `alt` is empty because the
    [`Name`](#Name) already names the avatar.
  - `Icon icon`: for example a building for an organisation.
  - `Placeholder`: the default person silhouette from the CSS.

-}
type Content msg
    = Initials String
    | Image String
    | Icon (Html msg)
    | Placeholder



-- VIEW


{-| A `<span class="ds-avatar" role="img">`.
-}
view : { name : Name, content : Content msg } -> List (Html.Attribute msg) -> Html msg
view config attributes =
    avatar Html.span (Attr.attribute "role" "img") config attributes


{-| An avatar rendered as another element than `<span>` (React's `asChild`),
typically a profile link or a menu button. The element keeps its own role, so
there is no `role="img"`.

    Avatar.viewAs Html.a
        { name = Avatar.Label "Min profil", content = Avatar.Initials "KN" }
        [ Attr.href "/profil" ]

-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> { name : Name, content : Content msg }
    -> List (Html.Attribute msg)
    -> Html msg
viewAs element config attributes =
    avatar element Internal.none config attributes


avatar :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> Html.Attribute msg
    -> { name : Name, content : Content msg }
    -> List (Html.Attribute msg)
    -> Html msg
avatar element role { name, content } attributes =
    element
        (Attr.class "ds-avatar"
            :: role
            :: nameAttributes name
            ++ attributes
        )
        (contentToHtml content)


nameAttributes : Name -> List (Html.Attribute msg)
nameAttributes name =
    case name of
        Label label ->
            [ Attr.attribute "aria-label" label ]

        Tooltip tooltip ->
            [ Attr.attribute "aria-label" tooltip
            , Internal.data "tooltip" tooltip
            , Attr.tabindex 0
            ]

        Decorative ->
            [ Attr.attribute "aria-hidden" "true" ]


contentToHtml : Content msg -> List (Html msg)
contentToHtml content =
    case content of
        Initials initials ->
            [ Html.text initials ]

        Image src ->
            [ Html.img [ Attr.src src, Attr.alt "" ] [] ]

        Icon icon ->
            [ icon ]

        Placeholder ->
            []



-- SIZE


{-| [`Designsystemet.Size`](Designsystemet-Size) plus `ExtraSmall`.
-}
type Size
    = ExtraSmall
    | Small
    | Medium
    | Large


{-| Set the avatar's `data-size`.
-}
size : Size -> Html.Attribute msg
size s =
    Internal.data "size" <|
        case s of
            ExtraSmall ->
                "xs"

            Small ->
                "sm"

            Medium ->
                "md"

            Large ->
                "lg"
