module Designsystemet.Breadcrumbs exposing
    ( Breadcrumbs, new, withBackLink, view
    , backOnly
    , Link, link
    )

{-| The current page's place in the site hierarchy, with links to each level
above it.

Mirrors `Breadcrumbs` from `@digdir/designsystemet-react`.

    Breadcrumbs.new { label = "Du er her:" }
        |> Breadcrumbs.withBackLink { label = "Tilbake til Saker" }
        |> Breadcrumbs.view []
            [ Breadcrumbs.link [ Attr.href "/" ] [ Html.text "Forside" ]
            , Breadcrumbs.link [ Attr.href "/saker" ] [ Html.text "Saker" ]
            , Breadcrumbs.link [ Attr.href "/saker/42" ] [ Html.text "Sak 42" ]
            ]

The last link is the current page. `designsystemet-web` marks it with
`aria-current="page"`.

Wide screens show the whole trail. Narrow screens show only the back link from
[`withBackLink`](#withBackLink), if there is one.


# React → Elm

  - `<Breadcrumbs aria-label="Du er her:">` → `Breadcrumbs.new { label = "Du er her:" }`
  - `<Breadcrumbs.List>` + `Item` + `Link` → `Breadcrumbs.link [ Attr.href "…" ] […]` in `view`
  - `<Breadcrumbs.Link aria-label="Tilbake til …">` → `Breadcrumbs.withBackLink { label = "Tilbake til …" }`
  - a lone `<Breadcrumbs.Link aria-label="…">` → `Breadcrumbs.backOnly { label = "…" } [ Attr.href "…" ] […]`


# Differences from React

  - The `aria-label` is required: there is no Norwegian default.
  - The back link is built from the second-to-last link and your label, so it
    can't point at the wrong place.


# Managed by designsystemet-web

Don't set `role`, `aria-current` on the links, or (after the first render)
`aria-label`. The web layer removes `aria-label` on narrow screens, where only
the back link shows, and Elm only writes it again if you change it.

@docs Breadcrumbs, new, withBackLink, view
@docs backOnly
@docs Link, link

-}

import Html exposing (Html)
import Html.Attributes as Attr



-- BREADCRUMBS


{-| Breadcrumbs being configured. Start with [`new`](#new), finish with
[`view`](#view).
-}
type Breadcrumbs
    = Breadcrumbs
        { label : String
        , backLink : Maybe String
        }


{-| Breadcrumbs with a name for screen readers, like `"Du er her:"`.
-}
new : { label : String } -> Breadcrumbs
new { label } =
    Breadcrumbs { label = label, backLink = Nothing }


{-| Add a link to the level above the current page (the second-to-last link).
Narrow screens show it instead of the trail. It has that link's text; `label`
is what screen readers announce, like `"Tilbake til Saker"`.

With fewer than two links, no back link is rendered.

-}
withBackLink : { label : String } -> Breadcrumbs -> Breadcrumbs
withBackLink { label } (Breadcrumbs config) =
    Breadcrumbs { config | backLink = Just label }


{-| A `<ds-breadcrumbs class="ds-breadcrumbs">`. List the links from the top
level down to the current page.
-}
view : List (Html.Attribute msg) -> List (Link msg) -> Breadcrumbs -> Html msg
view attributes links (Breadcrumbs config) =
    Html.node "ds-breadcrumbs"
        (Attr.class "ds-breadcrumbs"
            :: Attr.attribute "aria-label" config.label
            :: attributes
        )
        (case ( config.backLink, parent links ) of
            ( Just label, Just (Link parentAttributes parentChildren) ) ->
                [ viewLink (parentAttributes ++ [ Attr.attribute "aria-label" label ]) parentChildren
                , viewTrail links
                ]

            _ ->
                [ viewTrail links ]
        )


parent : List (Link msg) -> Maybe (Link msg)
parent links =
    case List.reverse links of
        _ :: above :: _ ->
            Just above

        _ ->
            Nothing


viewTrail : List (Link msg) -> Html msg
viewTrail links =
    Html.ol []
        (List.map
            (\(Link attributes children) -> Html.li [] [ viewLink attributes children ])
            links
        )


viewLink : List (Html.Attribute msg) -> List (Html msg) -> Html msg
viewLink attributes =
    Html.a (Attr.class "ds-link" :: attributes)


{-| Only a link to the level above, on every screen size, for pages without a
trail.

    Breadcrumbs.backOnly { label = "Tilbake til Saker" }
        [ Attr.href "/saker" ]
        [ Html.text "Saker" ]

The attributes and children go on the link. `label` is its screen-reader name.

-}
backOnly : { label : String } -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
backOnly { label } attributes children =
    Html.node "ds-breadcrumbs"
        [ Attr.class "ds-breadcrumbs" ]
        [ viewLink (attributes ++ [ Attr.attribute "aria-label" label ]) children ]



-- LINKS


{-| One level in the trail.
-}
type Link msg
    = Link (List (Html.Attribute msg)) (List (Html msg))


{-| A link to one level, an `<a class="ds-link">`. Give it an `href`.

    Breadcrumbs.link [ Attr.href "/saker" ] [ Html.text "Saker" ]

-}
link : List (Html.Attribute msg) -> List (Html msg) -> Link msg
link =
    Link
