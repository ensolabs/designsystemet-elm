module Designsystemet.TextfieldTest exposing (suite)

import Designsystemet as Ds
import Designsystemet.Size as Size
import Designsystemet.Textfield as Textfield
import Expect
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.Textfield"
        [ test "a labelled field: ds-field > label, affixes > input" <|
            \() ->
                Textfield.new (Ds.label "E-post")
                    |> Textfield.view []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "ds-field", Selector.class "ds-field" ]
                        , Query.children [] >> Query.count (Expect.equal 2)
                        , Query.children [] >> Query.index 0 >> Query.has [ Selector.tag "label", Selector.class "ds-label", Selector.text "E-post" ]
                        , Query.children [] >> Query.index 1 >> Query.has [ Selector.class "ds-field-affixes" ]
                        , Query.find [ Selector.class "ds-field-affixes" ]
                            >> Query.children []
                            >> Query.first
                            >> Query.has [ Selector.tag "input", Selector.class "ds-input", Selector.attribute (Attr.type_ "text") ]
                        ]
        , test "the label is not wired by hand: no for, no aria-invalid" <|
            \() ->
                Textfield.new (Ds.label "E-post")
                    |> Textfield.withError (Just "Feil")
                    |> Textfield.view [ Attr.id "email" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.find [ Selector.tag "label" ] >> Query.hasNot [ Selector.attribute (Attr.for "email") ]
                        , Query.find [ Selector.tag "input" ] >> Query.hasNot [ Selector.attribute (Attr.attribute "aria-invalid" "true") ]
                        ]
        , test "an aria-label goes on the input and no label is rendered" <|
            \() ->
                Textfield.new (Ds.ariaLabel "Søk")
                    |> Textfield.view []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.hasNot [ Selector.tag "label" ]
                        , Query.find [ Selector.tag "input" ] >> Query.has [ Selector.attribute (Attr.attribute "aria-label" "Søk") ]
                        ]
        , test "labelledBy goes on the input" <|
            \() ->
                Textfield.new (Ds.labelledBy "heading")
                    |> Textfield.view []
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Query.has [ Selector.attribute (Attr.attribute "aria-labelledby" "heading") ]
        , test "multiline renders a textarea" <|
            \() ->
                Textfield.multiline (Ds.label "Begrunnelse")
                    |> Textfield.view []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.find [ Selector.tag "textarea" ] >> Query.has [ Selector.class "ds-input" ]
                        , Query.hasNot [ Selector.tag "input" ]
                        ]
        , test "everything in React's order: label, description, affixes, counter, error" <|
            \() ->
                Textfield.new (Ds.label "Beløp")
                    |> Textfield.withError (Just "Må være et tall")
                    |> Textfield.withCounter { limit = 10, under = "%d igjen", over = "%d for mye" }
                    |> Textfield.withSuffix "pr. mnd."
                    |> Textfield.withPrefix "NOK"
                    |> Textfield.withDescription [ Html.text "Før skatt" ]
                    |> Textfield.view []
                    |> Query.fromHtml
                    |> Query.children []
                    |> Expect.all
                        [ Query.count (Expect.equal 5)
                        , Query.index 0 >> Query.has [ Selector.tag "label" ]
                        , Query.index 1 >> Query.has [ Selector.attribute (Attr.attribute "data-field" "description"), Selector.text "Før skatt" ]
                        , Query.index 2 >> Query.has [ Selector.class "ds-field-affixes" ]
                        , Query.index 3 >> Query.has [ Selector.attribute (Attr.attribute "data-field" "counter"), Selector.attribute (Attr.attribute "data-limit" "10") ]
                        , Query.index 4 >> Query.has [ Selector.attribute (Attr.attribute "data-field" "validation"), Selector.text "Må være et tall" ]
                        ]
        , test "prefix, input, suffix inside the affixes" <|
            \() ->
                Textfield.new (Ds.label "Beløp")
                    |> Textfield.withPrefix "NOK"
                    |> Textfield.withSuffix "kr"
                    |> Textfield.view []
                    |> Query.fromHtml
                    |> Query.find [ Selector.class "ds-field-affixes" ]
                    |> Query.children []
                    |> Expect.all
                        [ Query.count (Expect.equal 3)
                        , Query.index 0 >> Query.has [ Selector.class "ds-field-affix", Selector.text "NOK" ]
                        , Query.index 1 >> Query.has [ Selector.tag "input" ]
                        , Query.index 2 >> Query.has [ Selector.class "ds-field-affix", Selector.text "kr" ]
                        ]
        , test "no error means no validation message" <|
            \() ->
                Textfield.new (Ds.label "E-post")
                    |> Textfield.withError Nothing
                    |> Textfield.view []
                    |> Query.fromHtml
                    |> Query.hasNot [ Selector.class "ds-validation-message" ]
        , test "field attributes land on ds-field, view attributes on the input" <|
            \() ->
                Textfield.new (Ds.label "E-post")
                    |> Textfield.withFieldAttributes [ Ds.size Size.sm ]
                    |> Textfield.view [ Attr.type_ "email", Attr.name "email" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "ds-field", Selector.attribute (Attr.attribute "data-size" "sm") ]
                        , Query.find [ Selector.tag "input" ]
                            >> Query.has [ Selector.attribute (Attr.type_ "email"), Selector.attribute (Attr.name "email") ]
                        ]
        , test "input events reach the caller" <|
            \() ->
                Textfield.new (Ds.label "E-post")
                    |> Textfield.view [ Events.onInput identity ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "input" ]
                    |> Event.simulate (Event.input "a@b.no")
                    |> Event.expect "a@b.no"
        ]
