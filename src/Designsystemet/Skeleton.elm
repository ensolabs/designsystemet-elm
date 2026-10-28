module Designsystemet.Skeleton exposing
    ( rectangle, circle, round, text, textLike
    , view, viewAs
    )

{-| Grey, pulsing placeholders shown while content loads.

Mirrors `Skeleton` from `@digdir/designsystemet-react`.

    viewLoadingCase : Html msg
    viewLoadingCase =
        Card.view []
            [ Skeleton.circle { diameter = "3rem" } []
            , Heading.h3 [] [ Skeleton.text { characters = 24 } [] ]
            , Skeleton.rectangle { width = "100%", height = "8rem" } []
            ]

Each shape takes only the measurements it needs: a circle has a diameter, text
a length in characters. Skeletons are hidden from screen readers
(`aria-hidden="true"`), so signal loading another way, e.g. `aria-busy="true"`
on the region.


# React → Elm

  - `<Skeleton width={200} height={100} />` → `Skeleton.rectangle { width = "200px", height = "100px" } []`
  - `<Skeleton variant="circle" width="3rem" … />` → `Skeleton.circle { diameter = "3rem" } []`
  - `<Skeleton variant="circle" className="size-12" />` → `Skeleton.round [ Attr.class "size-12" ]`
  - `<Skeleton variant="text" width={24} />` → `Skeleton.text { characters = 24 } []`
  - `<Skeleton variant="text">En tittel</Skeleton>` → `Skeleton.textLike "En tittel" []`
  - `<Skeleton><Button>…</Button></Skeleton>` → `Skeleton.view [] [ Button.view [] [ … ] ]`
  - `<Skeleton asChild><Paragraph>…` → `Skeleton.viewAs Paragraph.view [] [ … ]`

React's `characters` prop is deprecated and does nothing, so it isn't ported.
React also syncs the pulse of all skeletons on the page in JavaScript. Elm
can't, so skeletons that appear at different times pulse slightly out of step.

@docs rectangle, circle, round, text, textLike


# Shaped like content

@docs view, viewAs

-}

import Designsystemet.Internal.Attributes as Internal
import Html exposing (Html)
import Html.Attributes as Attr



-- SHAPES


{-| A rounded rectangle for images, text blocks and other boxes. Width and
height are CSS lengths: `"100%"`, `"12rem"`, `"200px"`.

They are inline styles, like React's `width` and `height`, so they win over any
class. To size with classes instead (Tailwind's `w-full h-32`, say), use an
empty [`view`](#view). Unsized, a skeleton is a full-width block one line high.

    Skeleton.view [ Attr.class "h-32 w-full" ] []

-}
rectangle : { width : String, height : String } -> List (Html.Attribute msg) -> Html msg
rectangle { width, height } attributes =
    skeleton Html.span
        (Attr.style "width" width
            :: Attr.style "height" height
            :: attributes
        )
        []


{-| A circle, for avatars and icons. The diameter is a CSS length.

React takes a width and a height. A single diameter means it can't come out
oval. It's an inline style, so it wins over classes that set a width or
height. To size a circle with classes, use [`round`](#round).

-}
circle : { diameter : String } -> List (Html.Attribute msg) -> Html msg
circle { diameter } attributes =
    skeleton Html.span
        (Internal.data "variant" "circle"
            :: Attr.style "width" diameter
            :: Attr.style "height" diameter
            :: attributes
        )
        []


{-| A circle with no diameter, for sizing with classes. Unsized, it's one line
of the surrounding text tall. Give it both a width and a height (Tailwind's
`size-12`, not `w-12` alone).

    Skeleton.round [ Attr.class "size-12" ]

-}
round : List (Html.Attribute msg) -> Html msg
round attributes =
    skeleton Html.span (Internal.data "variant" "circle" :: attributes) []


{-| A line of text about `characters` characters long. It sits inline and takes
on the surrounding text's size, so put it where the text will go: a heading, a
paragraph or a table cell.

    Paragraph.view [] [ Skeleton.text { characters = 40 } [] ]

-}
text : { characters : Int } -> List (Html.Attribute msg) -> Html msg
text { characters } attributes =
    skeleton Html.span
        (Internal.data "text" (String.repeat (max 1 characters) "-")
            :: Internal.data "variant" "text"
            :: attributes
        )
        []


{-| A line of text exactly as long as `placeholder`. Like [`text`](#text) it
sits inline and takes the surrounding text's size. The placeholder is rendered
but invisible.

Use it when you know roughly what will be there, like a title:

    Heading.h2 [] [ Skeleton.textLike "En medium tittel" [] ]

-}
textLike : String -> List (Html.Attribute msg) -> Html msg
textLike placeholder attributes =
    skeleton Html.span
        (Internal.data "text" "-"
            :: Internal.data "variant" "text"
            :: attributes
        )
        [ Html.text placeholder ]



-- SHAPED LIKE CONTENT


{-| A skeleton the size of its content, which is rendered but hidden. Use it
when the size is easiest to give by example: a button, a tag, a name.

    Skeleton.view [] [ Button.view [] [ Html.text "Send inn" ] ]

-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view =
    viewAs Html.span


{-| A content-shaped skeleton on another element (React's `asChild`). The
element keeps its layout.

    Skeleton.viewAs Paragraph.view [] [ Html.text "Et avsnitt med plassholdertekst." ]

Any `view` in this package with that shape works as the element.

-}
viewAs :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewAs =
    skeleton


skeleton :
    (List (Html.Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
skeleton element attributes =
    element (Attr.attribute "aria-hidden" "true" :: Attr.class "ds-skeleton" :: attributes)
