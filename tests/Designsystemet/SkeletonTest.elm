module Designsystemet.SkeletonTest exposing (suite)

import Designsystemet.Paragraph as Paragraph
import Designsystemet.Skeleton as Skeleton
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


hidden : List Selector.Selector
hidden =
    [ Selector.class "ds-skeleton", attr "aria-hidden" "true" ]


suite : Test
suite =
    describe "Designsystemet.Skeleton"
        [ test "a rectangle is a hidden span sized by inline style" <|
            \() ->
                Skeleton.rectangle { width = "200px", height = "100px" } []
                    |> Query.fromHtml
                    |> Query.has
                        (Selector.tag "span"
                            :: Selector.style "width" "200px"
                            :: Selector.style "height" "100px"
                            :: hidden
                        )
        , test "a circle uses its diameter for both width and height" <|
            \() ->
                Skeleton.circle { diameter = "3rem" } []
                    |> Query.fromHtml
                    |> Query.has
                        (attr "data-variant" "circle"
                            :: Selector.style "width" "3rem"
                            :: Selector.style "height" "3rem"
                            :: hidden
                        )
        , test "a round skeleton is a circle sized only by its classes" <|
            \() ->
                Skeleton.round [ Attr.class "size-12" ]
                    |> Query.fromHtml
                    |> Query.has (attr "data-variant" "circle" :: Selector.classes [ "ds-skeleton", "size-12" ] :: hidden)
        , test "text is as many dashes in data-text as characters, like React" <|
            \() ->
                Skeleton.text { characters = 5 } []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has (attr "data-variant" "text" :: attr "data-text" "-----" :: hidden)
                        , Query.hasNot [ Selector.style "width" "5" ]
                        ]
        , test "text is at least one character, like React's `Number(width) || 1`" <|
            \() ->
                Skeleton.text { characters = 0 } []
                    |> Query.fromHtml
                    |> Query.has [ attr "data-text" "-" ]
        , test "textLike is a text skeleton holding its (hidden) placeholder, like React's text variant with children" <|
            \() ->
                Skeleton.textLike "En medium tittel" []
                    |> Query.fromHtml
                    |> Query.has (Selector.tag "span" :: attr "data-variant" "text" :: attr "data-text" "-" :: Selector.text "En medium tittel" :: hidden)
        , test "view wraps content without a variant" <|
            \() ->
                Skeleton.view [] [ Html.button [] [ Html.text "Send" ] ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has (Selector.tag "span" :: hidden)
                        , Query.find [ Selector.tag "button" ] >> Query.has [ Selector.text "Send" ]
                        ]
        , test "viewAs puts the skeleton on another element" <|
            \() ->
                Skeleton.viewAs Html.p [] [ Html.text "Tekst" ]
                    |> Query.fromHtml
                    |> Query.has (Selector.tag "p" :: hidden)
        , test "viewAs composes with a component's view, keeping both classes" <|
            \() ->
                Skeleton.viewAs Paragraph.view [] [ Html.text "Tekst" ]
                    |> Query.fromHtml
                    |> Query.has (Selector.tag "p" :: Selector.class "ds-paragraph" :: hidden)
        ]
