module Designsystemet.BreadcrumbsTest exposing (suite)

import Designsystemet.Breadcrumbs as Breadcrumbs
import Expect
import Html exposing (Html)
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


trail : List (Breadcrumbs.Link msg)
trail =
    [ Breadcrumbs.link [ Attr.href "/" ] [ Html.text "Forside" ]
    , Breadcrumbs.link [ Attr.href "/saker" ] [ Html.text "Saker" ]
    , Breadcrumbs.link [ Attr.href "/saker/42" ] [ Html.text "Sak 42" ]
    ]


withBack : List (Breadcrumbs.Link msg) -> Html msg
withBack links =
    Breadcrumbs.new { label = "Du er her:" }
        |> Breadcrumbs.withBackLink { label = "Tilbake til Saker" }
        |> Breadcrumbs.view [] links


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


suite : Test
suite =
    describe "Designsystemet.Breadcrumbs"
        [ test "a labelled ds-breadcrumbs with an ol of ds-link items" <|
            \() ->
                Breadcrumbs.new { label = "Du er her:" }
                    |> Breadcrumbs.view [] trail
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "ds-breadcrumbs", Selector.class "ds-breadcrumbs", attr "aria-label" "Du er her:" ]
                        , Query.children [] >> Query.count (Expect.equal 1)
                        , Query.find [ Selector.tag "ol" ]
                            >> Query.children [ Selector.tag "li" ]
                            >> Expect.all
                                [ Query.count (Expect.equal 3)
                                , Query.each (Query.children [ Selector.tag "a", Selector.class "ds-link" ] >> Query.count (Expect.equal 1))
                                ]
                        ]
        , test "aria-current and role are left to designsystemet-web" <|
            \() ->
                withBack trail
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.hasNot [ attr "role" "navigation" ]
                        , Query.findAll [ attr "aria-current" "page" ] >> Query.count (Expect.equal 0)
                        ]
        , test "the back link comes first and goes to the level above the current page" <|
            \() ->
                withBack trail
                    |> Query.fromHtml
                    |> Query.children []
                    |> Expect.all
                        [ Query.count (Expect.equal 2)
                        , Query.first
                            >> Query.has
                                [ Selector.tag "a"
                                , Selector.class "ds-link"
                                , Selector.attribute (Attr.href "/saker")
                                , attr "aria-label" "Tilbake til Saker"
                                , Selector.text "Saker"
                                ]
                        , Query.index 1 >> Query.has [ Selector.tag "ol" ]
                        ]
        , test "no back link without a level above" <|
            \() ->
                withBack [ Breadcrumbs.link [ Attr.href "/" ] [ Html.text "Forside" ] ]
                    |> Query.fromHtml
                    |> Query.children []
                    |> Query.count (Expect.equal 1)
        , test "backOnly is a lone labelled link in ds-breadcrumbs" <|
            \() ->
                Breadcrumbs.backOnly { label = "Tilbake til Saker" } [ Attr.href "/saker" ] [ Html.text "Saker" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "ds-breadcrumbs", Selector.class "ds-breadcrumbs" ]
                        , Query.children [] >> Query.count (Expect.equal 1)
                        , Query.children []
                            >> Query.first
                            >> Query.has
                                [ Selector.tag "a"
                                , Selector.class "ds-link"
                                , Selector.attribute (Attr.href "/saker")
                                , attr "aria-label" "Tilbake til Saker"
                                , Selector.text "Saker"
                                ]
                        ]
        ]
