module Designsystemet.Link exposing (view, viewAs)

{-| A styled link.

Mirrors `Link` from `@digdir/designsystemet-react`.

    Link.view [ Attr.href "/saker/42" ] [ Html.text "Se saken" ]

With an icon, wrap the text in a `<span>` so the CSS can space them:

    Link.view [ Attr.href "mailto:post@example.no" ]
        [ mailIcon, Html.span [] [ Html.text "Send e-post" ] ]


# React → Elm

  - `<Link href="…">` → `Link.view [ Attr.href "…" ]`
  - `data-color="neutral"` → `Ds.color Color.neutral`
  - `asChild` + `<button>` → `Link.viewAs Html.button [ Attr.type_ "button" ]`

@docs view, viewAs

-}

import Html exposing (Html)
import Html.Attributes as Attr


{-| An `<a class="ds-link">`. Give it an `href`, or keyboards and assistive
technology won't treat it as a link.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view =
    viewAs Html.a


{-| Link styling on another element (React's `asChild`).

    Link.viewAs Html.button
        [ Attr.type_ "button", Events.onClick ShowTerms ]
        [ Html.text "Vilkår" ]

Use a real `<a href>` for navigation. A button is for actions styled as links.

-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewAs element attributes =
    element (Attr.class "ds-link" :: attributes)
