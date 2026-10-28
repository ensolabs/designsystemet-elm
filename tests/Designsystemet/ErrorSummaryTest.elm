module Designsystemet.ErrorSummaryTest exposing (suite)

import Designsystemet.ErrorSummary as ErrorSummary exposing (Level(..))
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


email : ErrorSummary.FieldId
email =
    ErrorSummary.fieldId "email"


phone : ErrorSummary.FieldId
phone =
    ErrorSummary.fieldId "phone"


summary : Level -> ErrorSummary.Error -> List ErrorSummary.Error -> Query.Single msg
summary level first rest =
    ErrorSummary.view { heading = "Rett feilene", level = level, errors = first :: rest } []
        |> Query.fromHtml


suite : Test
suite =
    describe "Designsystemet.ErrorSummary"
        [ test "ds-error-summary > h2.ds-heading + ul.ds-list" <|
            \() ->
                summary H2 { field = email, message = "Ugyldig e-post" } []
                    |> Expect.all
                        [ Query.has [ Selector.tag "ds-error-summary", Selector.class "ds-error-summary" ]
                        , Query.children [] >> Query.count (Expect.equal 2)
                        , Query.children [] >> Query.index 0 >> Query.has [ Selector.tag "h2", Selector.class "ds-heading", Selector.text "Rett feilene" ]
                        , Query.children [] >> Query.index 1 >> Query.has [ Selector.tag "ul", Selector.class "ds-list" ]
                        ]
        , describe "the heading level is the caller's, h2 to h6"
            (List.map
                (\( level, tag ) ->
                    test tag <|
                        \() ->
                            summary level { field = email, message = "Ugyldig e-post" } []
                                |> Query.has [ Selector.containing [ Selector.tag tag, Selector.class "ds-heading" ] ]
                )
                [ ( H2, "h2" ), ( H3, "h3" ), ( H4, "h4" ), ( H5, "h5" ), ( H6, "h6" ) ]
            )
        , test "each error is a neutral link to its field's id" <|
            \() ->
                summary H2 { field = email, message = "Ugyldig e-post" } [ { field = phone, message = "8 siffer" } ]
                    |> Query.findAll [ Selector.tag "li" ]
                    |> Expect.all
                        [ Query.count (Expect.equal 2)
                        , Query.index 1
                            >> Query.find [ Selector.tag "a" ]
                            >> Query.has
                                [ Selector.class "ds-link"
                                , Selector.attribute (Attr.attribute "data-color" "neutral")
                                , Selector.attribute (Attr.href "#phone")
                                , Selector.text "8 siffer"
                                ]
                        ]
        , test "the link target is the id the link points at" <|
            \() ->
                Html.input [ ErrorSummary.linkTarget phone ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.id (ErrorSummary.fieldIdToString phone), Selector.id "phone" ]
        , test "no errors, no summary (so it never takes focus for nothing)" <|
            \() ->
                Html.div [] [ ErrorSummary.view { heading = "Rett feilene", level = H2, errors = [] } [] ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "ds-error-summary" ]
                    |> Query.count (Expect.equal 0)
        , describe "messageFor"
            [ test "finds the field's message" <|
                \() ->
                    ErrorSummary.messageFor phone [ { field = email, message = "a" }, { field = phone, message = "b" } ]
                        |> Expect.equal (Just "b")
            , test "the first message wins" <|
                \() ->
                    ErrorSummary.messageFor email [ { field = email, message = "a" }, { field = email, message = "b" } ]
                        |> Expect.equal (Just "a")
            , test "no error for the field is Nothing" <|
                \() ->
                    ErrorSummary.messageFor phone [ { field = email, message = "a" } ]
                        |> Expect.equal Nothing
            ]
        , test "role and tabindex are left to the web layer" <|
            \() ->
                summary H2 { field = email, message = "Ugyldig e-post" } []
                    |> Query.hasNot [ Selector.attribute (Attr.attribute "role" "group"), Selector.attribute (Attr.tabindex -1) ]
        ]
