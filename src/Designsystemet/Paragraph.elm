module Designsystemet.Paragraph exposing
    ( view, viewAs
    , long, short
    , Size(..), size
    )

{-| Body text: a `<p>` with Designsystemet's paragraph styles.

Mirrors `Paragraph` from `@digdir/designsystemet-react`.

    Paragraph.view [ Paragraph.long ]
        [ Html.text "Saken er sendt til behandling. Du får svar innen tre uker." ]


# React → Elm

  - `<Paragraph>` → `Paragraph.view []`
  - `variant="long"` → `Paragraph.long`
  - `variant="short"` → `Paragraph.short`
  - `data-size="xl"` → `Paragraph.size Paragraph.ExtraLarge`
  - `asChild` + `<div>` → `Paragraph.viewAs Html.div []`

@docs view, viewAs


# Length

Line height for long or short text. Leave it out for the default.

@docs long, short


# Sizes

@docs Size, size

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr


{-| A `<p class="ds-paragraph">`.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view =
    viewAs Html.p


{-| Paragraph styles on another element (React's `asChild`), e.g. when the text
contains block elements that can't go in a `<p>`.

    Paragraph.viewAs Html.div [] [ Html.text "Vedlegg:", attachmentList ]

-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewAs element attributes =
    element (Attr.class "ds-paragraph" :: attributes)



-- LENGTH


{-| More line height, for long running text like articles.
-}
long : Html.Attribute msg
long =
    Internal.data "variant" "long"


{-| Less line height, for short text like an ingress or a card summary.
-}
short : Html.Attribute msg
short =
    Internal.data "variant" "short"



-- SIZE


{-| Paragraphs have their own size scale, wider than
[`Designsystemet.Size`](Designsystemet-Size).
-}
type Size
    = ExtraSmall
    | Small
    | Medium
    | Large
    | ExtraLarge


{-| Set the paragraph's `data-size`.
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

            ExtraLarge ->
                "xl"
