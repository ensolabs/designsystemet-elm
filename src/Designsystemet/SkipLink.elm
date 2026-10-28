module Designsystemet.SkipLink exposing (view)

{-| A link for keyboard users to jump past the header and navigation to the
main content.

Mirrors `SkipLink` from `@digdir/designsystemet-react`.

    Html.body []
        [ SkipLink.view { href = "#main-content" } [] [ Html.text "Hopp til hovedinnhold" ]
        , siteHeader
        , Html.main_ [ Attr.id "main-content", Attr.tabindex -1 ] [{- … -}]
        ]

It's invisible until focused, so put it first on the page where the first Tab
reveals it.


# React → Elm

  - `<SkipLink href="#main">Hopp</SkipLink>` → `SkipLink.view { href = "#main" } [] [ … ]`

@docs view

-}

import Html exposing (Html)
import Html.Attributes as Attr


{-| An `<a class="ds-skip-link">` to an element on the same page. `href` is `"#"`
plus the target's `id`. Give the target `tabindex="-1"` so it can take focus.
-}
view : { href : String } -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
view { href } attributes =
    Html.a (Attr.class "ds-skip-link" :: Attr.href href :: attributes)
