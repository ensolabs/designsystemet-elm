module Designsystemet.Heading exposing
    ( h1, h2, h3, h4, h5, h6
    , Level(..), view, viewAs
    , Size(..), size
    )

{-| Headings: `<h1>` to `<h6>` with Designsystemet's heading text styles.

Mirrors `Heading` from `@digdir/designsystemet-react`.

    Heading.h2 [ Heading.size Heading.Large ] [ Html.text "Mine saker" ]

Screen readers and the document outline only see the level. Pick it from the
page structure, and the size from the design.


# React → Elm

  - `<Heading level={1}>` → `Heading.h1 []`
  - `<Heading>` (level defaults to 2) → `Heading.h2 []`
  - `level={level}` computed at runtime → `Heading.view level []`
  - `data-size="lg"` → `Heading.size Heading.Large`
  - `asChild` + `<legend>` → `Heading.viewAs Html.legend []`

React defaults to `<h2>`. Here the level is always explicit, since a heading
at the wrong level is an accessibility bug you can't see on screen.

@docs h1, h2, h3, h4, h5, h6


# Computed levels

@docs Level, view, viewAs


# Sizes

@docs Size, size

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr



-- LEVELS


{-| A top-level heading: usually one per page.
-}
h1 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h1 =
    view H1


{-| A section heading.
-}
h2 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h2 =
    view H2


{-| A sub-section heading.
-}
h3 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h3 =
    view H3


{-| An `<h4 class="ds-heading">`.
-}
h4 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h4 =
    view H4


{-| An `<h5 class="ds-heading">`.
-}
h5 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h5 =
    view H5


{-| An `<h6 class="ds-heading">`.
-}
h6 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h6 =
    view H6


{-| A heading level decided at runtime, e.g. in a section component used at
different depths.
-}
type Level
    = H1
    | H2
    | H3
    | H4
    | H5
    | H6


{-| A heading at a level you computed.

    sectionHeading : Heading.Level -> String -> Html msg
    sectionHeading level title =
        Heading.view level [ Heading.size Heading.Small ] [ Html.text title ]

-}
view : Level -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
view level attributes =
    viewAs (element level) attributes


{-| Heading styles on another element (React's `asChild`).

    Html.fieldset []
        [ Heading.viewAs Html.legend
            [ Heading.size Heading.ExtraSmall ]
            [ Html.text "Kontaktinformasjon" ]
        ]

Use it only on elements that aren't headings in the outline, like `<legend>`,
`<caption>` or `<summary>`. Real headings should use [`h1`](#h1)–[`h6`](#h6)
so assistive technology can navigate by them.

-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewAs toElement attributes =
    toElement (Attr.class "ds-heading" :: attributes)


element : Level -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
element level =
    case level of
        H1 ->
            Html.h1

        H2 ->
            Html.h2

        H3 ->
            Html.h3

        H4 ->
            Html.h4

        H5 ->
            Html.h5

        H6 ->
            Html.h6



-- SIZE


{-| Headings have their own size scale, wider than
[`Designsystemet.Size`](Designsystemet-Size). Without a size, a heading is
`1.3em` of the surrounding text.
-}
type Size
    = TwoExtraSmall
    | ExtraSmall
    | Small
    | Medium
    | Large
    | ExtraLarge
    | TwoExtraLarge


{-| Set the heading's `data-size`.
-}
size : Size -> Html.Attribute msg
size s =
    Internal.data "size" <|
        case s of
            TwoExtraSmall ->
                "2xs"

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

            TwoExtraLarge ->
                "2xl"
