module Designsystemet.Details exposing
    ( view, initiallyOpen
    , controlled
    , tinted
    )

{-| A heading that shows or hides the content below it when clicked.

Mirrors `Details` from `@digdir/designsystemet-react`.

    Details.view
        { summary = [ Html.text "Hvem kan søke?" ]
        , content = [ Html.p [] [ Html.text "Alle som er registrert i Enhetsregisteret." ] ]
        }
        []

A native [`<details>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/details):
it opens and closes without Elm, and the browser opens it when find-in-page
matches text inside. Stack several for an accordion.


# Native or controlled

  - [`view`](#view): the browser tracks whether it is open. Nothing goes in
    your model.
  - [`controlled`](#controlled): your model decides, and clicking the summary
    sends a message. Use it to open details from code, or to keep only one
    open at a time.


# React → Elm

  - `<Details>` + `Summary` + `Content` → `Details.view { summary = […], content = […] } []`
  - `defaultOpen` → `Details.initiallyOpen`
  - `open` + `onToggle` → `Details.controlled { open, onToggle, summary, content } []`
  - `variant="tinted"` → `Details.tinted`


# Managed by designsystemet-web

Don't set `role` or `aria-expanded` on the summary: a polyfill sets them in
browsers that announce `<details>` badly (Firefox with TalkBack).

@docs view, initiallyOpen
@docs controlled


# Variants

@docs tinted

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode


{-| A `<details class="ds-details">` that the browser opens and closes. Starts
closed.
-}
view : { summary : List (Html msg), content : List (Html msg) } -> List (Html.Attribute msg) -> Html msg
view { summary, content } attributes =
    details attributes [] summary content


{-| Start a [`view`](#view) open.

    Details.view { summary = summary, content = content } [ Details.initiallyOpen ]

-}
initiallyOpen : Html.Attribute msg
initiallyOpen =
    Attr.attribute "open" ""


{-| A `<details class="ds-details">` that is open when `open` is `True`.
Clicking the summary, or pressing Enter or Space on it, sends `onToggle` with
the requested state. So does the browser opening it for find-in-page.

Handle every `onToggle`. Elm can't undo the browser opening it for
find-in-page: if your model stays closed, the details stays open on screen
until `open` changes.

    Details.controlled
        { open = model.expanded == Just Eligibility
        , onToggle = EligibilityToggled
        , summary = [ Html.text "Hvem kan søke?" ]
        , content = [ eligibility ]
        }
        []

-}
controlled :
    { open : Bool
    , onToggle : Bool -> msg
    , summary : List (Html msg)
    , content : List (Html msg)
    }
    -> List (Html.Attribute msg)
    -> Html msg
controlled { open, onToggle, summary, content } attributes =
    details
        (Attr.property "open" (Encode.bool open)
            :: Events.on "toggle" (browserToggle open onToggle)
            :: attributes
        )
        [ Events.preventDefaultOn "click" (Decode.succeed ( onToggle (not open), True )) ]
        summary
        content


{-| The browser can still open a controlled details by itself (find-in-page).
Report that, but not the `toggle` events caused by Elm setting `open`.
-}
browserToggle : Bool -> (Bool -> msg) -> Decode.Decoder msg
browserToggle open onToggle =
    Decode.field "newState" Decode.string
        |> Decode.andThen
            (\state ->
                if (state == "open") /= open then
                    Decode.succeed (onToggle (state == "open"))

                else
                    Decode.fail "Elm already knows"
            )


details : List (Html.Attribute msg) -> List (Html.Attribute msg) -> List (Html msg) -> List (Html msg) -> Html msg
details attributes summaryAttributes summary content =
    Html.details (Attr.class "ds-details" :: attributes)
        [ Html.summary summaryAttributes summary
        , Html.div [] content
        ]



-- VARIANTS


{-| A tinted background instead of the default surface color.
-}
tinted : Html.Attribute msg
tinted =
    Internal.data "variant" "tinted"
