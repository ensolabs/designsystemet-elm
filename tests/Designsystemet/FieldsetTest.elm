module Designsystemet.FieldsetTest exposing (suite)

import Designsystemet.Fieldset as Fieldset
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.Fieldset"
        [ test "fieldset > legend.ds-label, then the fields" <|
            \() ->
                Fieldset.new [ Html.text "Adresse" ]
                    |> Fieldset.view [ Attr.name "adresse" ] [ Html.div [ Attr.id "felt" ] [] ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "fieldset", Selector.class "ds-fieldset", Selector.attribute (Attr.name "adresse") ]
                        , Query.children [] >> Query.count (Expect.equal 2)
                        , Query.children [] >> Query.index 0 >> Query.has [ Selector.tag "legend", Selector.class "ds-label", Selector.text "Adresse" ]
                        , Query.children [] >> Query.index 1 >> Query.has [ Selector.id "felt" ]
                        ]
        , test "legend attributes land on the legend" <|
            \() ->
                Fieldset.new [ Html.text "Skjult" ]
                    |> Fieldset.withLegendAttributes [ Attr.class "ds-sr-only" ]
                    |> Fieldset.view [] []
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "legend" ]
                    |> Query.has [ Selector.classes [ "ds-label", "ds-sr-only" ] ]
        , test "the description is a ds-paragraph right after the legend" <|
            \() ->
                Fieldset.new [ Html.text "Adresse" ]
                    |> Fieldset.withDescription [ Html.text "Der du bor" ]
                    |> Fieldset.view [] []
                    |> Query.fromHtml
                    |> Query.children []
                    |> Query.index 1
                    |> Query.has [ Selector.tag "p", Selector.class "ds-paragraph", Selector.text "Der du bor" ]
        , test "the error is a direct child validation message after the fields" <|
            \() ->
                Fieldset.new [ Html.text "Kontakt" ]
                    |> Fieldset.withError (Just "Velg ett alternativ")
                    |> Fieldset.view [] [ Html.div [] [] ]
                    |> Query.fromHtml
                    |> Query.children []
                    |> Expect.all
                        [ Query.count (Expect.equal 3)
                        , Query.index 2
                            >> Query.has
                                [ Selector.class "ds-validation-message"
                                , Selector.attribute (Attr.attribute "data-field" "validation")
                                , Selector.text "Velg ett alternativ"
                                ]
                        ]
        ]
