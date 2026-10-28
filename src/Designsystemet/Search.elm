module Designsystemet.Search exposing
    ( Search, new, view
    , withButton, ButtonVariant(..)
    )

{-| A search input with a magnifying glass, a button that empties it, and
optionally a search button.

Mirrors `Search` from `@digdir/designsystemet-react`.

    Html.form [ Attr.attribute "role" "search", Events.onSubmit Searched ]
        [ Search.new { clearLabel = "Tøm søket" }
            |> Search.withButton { variant = Search.Primary, label = "Søk" }
            |> Search.view
                [ Attr.attribute "aria-label" "Søk i saker"
                , Attr.value model.query
                , Events.onInput ChangedQuery
                ]
        ]

The attributes you give `view` go on the `<input type="search">`, like the
props of React's `Search.Input`. Name it with `aria-label`, or put the whole
search in a [`Field`](Designsystemet-Field) with a
[`Label`](Designsystemet-Label). Pass `Attr.type_ "text"` to drop the
magnifying glass.

The clear button sends the input an `input` event with an empty value, so
`Events.onInput` sees it like any other edit.


# React → Elm

  - `<Search>` + `<Search.Input>` + `<Search.Clear>` → `Search.new { clearLabel = "…" } |> Search.view [ … ]`
  - `data-sr-clear` / `--dsc-suggestion-sr-clear` → `clearLabel`
  - `<Search.Button>` → `Search.withButton { variant = Search.Primary, label = "Søk" }`
  - `<Search.Button variant="secondary">` → `Search.withButton { variant = Search.Secondary, label = "Søk" }`
  - `<Search.Input type="text">` → `Search.view [ Attr.type_ "text" ]`

React has Norwegian defaults for both button texts. Here they are required.


# Managed by designsystemet-web

`Search` renders `<ds-suggestion>`, the same custom element as
[`Suggestion`](Designsystemet-Suggestion). It writes:

  - `hidden`, `aria-label`, `aria-hidden` and `tabindex` on the clear button
    (Elm only renders the initial `hidden`, like React, and never changes it)
  - the other `data-sr-*` texts on `<ds-suggestion>`, from the CSS

@docs Search, new, view


# Search button

@docs withButton, ButtonVariant

-}

import Designsystemet.Button as Button
import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr


{-| A search being configured. Start with [`new`](#new), end with
[`view`](#view).
-}
type Search msg
    = Search
        { clearLabel : String
        , button : Maybe ( ButtonVariant, String )
        }


{-| A search field. `clearLabel` is the screen reader name of the × button
that empties it.
-}
new : { clearLabel : String } -> Search msg
new { clearLabel } =
    Search { clearLabel = clearLabel, button = Nothing }


{-| The two looks a search button can have.
-}
type ButtonVariant
    = Primary
    | Secondary


{-| Add a submit button with the text `label` after the input. Put the search in
a `<form>` and handle `Events.onSubmit` there.
-}
withButton : { variant : ButtonVariant, label : String } -> Search msg -> Search msg
withButton { variant, label } (Search config) =
    Search { config | button = Just ( variant, label ) }


{-| Render the search. The attributes go on the `<input>`.
-}
view : List (Html.Attribute msg) -> Search msg -> Html msg
view attributes (Search config) =
    Html.node "ds-suggestion"
        [ Attr.class "ds-search"
        , Internal.data "sr-clear" config.clearLabel
        ]
        ([ Html.input (Attr.class "ds-input" :: Attr.type_ "search" :: attributes) []
         , Html.button [ Attr.hidden True, Attr.type_ "reset" ] []
         ]
            ++ searchButton config.button
        )


searchButton : Maybe ( ButtonVariant, String ) -> List (Html msg)
searchButton maybeButton =
    case maybeButton of
        Just ( Primary, text ) ->
            [ Button.view [ Attr.type_ "submit" ] [ Html.text text ] ]

        Just ( Secondary, text ) ->
            [ Button.view [ Button.secondary, Attr.type_ "submit" ] [ Html.text text ] ]

        Nothing ->
            []
