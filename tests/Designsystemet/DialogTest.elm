module Designsystemet.DialogTest exposing (suite)

import Designsystemet.Button as Button
import Designsystemet.Dialog as Dialog
import Expect
import Html
import Html.Attributes as Attr
import Json.Encode as Encode
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


confirm : Dialog.Id
confirm =
    Dialog.id "confirm"


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


suite : Test
suite =
    describe "Designsystemet.Dialog"
        [ test "the typed id wins over an id in the attributes, so triggers keep pointing at it" <|
            \() ->
                Dialog.new confirm
                    |> Dialog.view [ Attr.id "something-else" ] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.id "confirm" ]
        , test "a dialog is modal by default, like React's data-modal" <|
            \() ->
                Dialog.new (Dialog.id "d")
                    |> Dialog.view [] []
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "dialog", attr "data-modal" "true" ]
        , test "nonModal overrides it" <|
            \() ->
                Dialog.new (Dialog.id "d")
                    |> Dialog.view [ Dialog.nonModal ] []
                    |> Query.fromHtml
                    |> Query.has [ attr "data-modal" "false" ]
        , test "open renders the model's state as data-open, for the companion script" <|
            \() ->
                Expect.all
                    [ \_ -> Dialog.new (Dialog.id "d") |> Dialog.view [ Dialog.open True ] [] |> Query.fromHtml |> Query.has [ attr "data-open" "true" ]
                    , \_ -> Dialog.new (Dialog.id "d") |> Dialog.view [ Dialog.open False ] [] |> Query.fromHtml |> Query.has [ attr "data-open" "false" ]
                    , \_ -> Dialog.new (Dialog.id "d") |> Dialog.view [] [] |> Query.fromHtml |> Query.hasNot [ attr "data-open" "false", attr "data-open" "true" ]
                    ]
                    ()
        , test "renders a centered ds-dialog with the id" <|
            \() ->
                Dialog.new confirm
                    |> Dialog.view [] [ Html.text "Innhold" ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "dialog"
                        , Selector.class "ds-dialog"
                        , Selector.id "confirm"
                        , attr "data-placement" "center"
                        , Selector.text "Innhold"
                        ]
        , test "has no close button unless asked for" <|
            \() ->
                Dialog.new confirm
                    |> Dialog.view [] []
                    |> Query.fromHtml
                    |> Query.hasNot [ Selector.tag "button" ]
        , test "the close button comes first, is empty, labelled and closes this dialog" <|
            \() ->
                Dialog.new confirm
                    |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
                    |> Dialog.view [] [ Html.p [] [ Html.text "Innhold" ] ]
                    |> Query.fromHtml
                    |> Query.children []
                    |> Query.first
                    |> Expect.all
                        [ Query.has
                            [ Selector.tag "button"
                            , Selector.class "ds-button"
                            , attr "type" "button"
                            , attr "aria-label" "Lukk dialogvindu"
                            , attr "data-color" "neutral"
                            , attr "data-icon" "true"
                            , attr "data-variant" "tertiary"
                            , attr "command" "close"
                            , attr "commandfor" "confirm"
                            ]
                        , Query.children [] >> Query.count (Expect.equal 0)
                        ]
        , test "drawer sets data-placement and overrides center" <|
            \() ->
                Dialog.new confirm
                    |> Dialog.view [ Dialog.drawer Dialog.Right ] []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ attr "data-placement" "right" ]
                        , Query.hasNot [ attr "data-placement" "center" ]
                        ]
        , test "closedby variants" <|
            \() ->
                Expect.all
                    [ \_ -> Dialog.new confirm |> Dialog.view [ Dialog.closedByAny ] [] |> Query.fromHtml |> Query.has [ attr "closedby" "any" ]
                    , \_ -> Dialog.new confirm |> Dialog.view [ Dialog.closedByNone ] [] |> Query.fromHtml |> Query.has [ attr "closedby" "none" ]
                    , \_ -> Dialog.new confirm |> Dialog.view [ Dialog.closedByCloseRequest ] [] |> Query.fromHtml |> Query.has [ attr "closedby" "closerequest" ]
                    ]
                    ()
        , test "the native close event becomes onClose" <|
            \() ->
                Dialog.new confirm
                    |> Dialog.view [ Dialog.onClose "closed" ] []
                    |> Query.fromHtml
                    |> Event.simulate (Event.custom "close" (Encode.object []))
                    |> Event.expect "closed"
        , test "block is a ds-dialog__block div" <|
            \() ->
                Dialog.block [] [ Html.text "Topp" ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "div", Selector.class "ds-dialog__block", Selector.text "Topp" ]
        , test "invokers carry command and commandfor" <|
            \() ->
                Expect.all
                    (List.map
                        (\( invoker, command ) ->
                            \_ ->
                                Button.view (invoker confirm) []
                                    |> Query.fromHtml
                                    |> Query.has [ attr "command" command, attr "commandfor" "confirm" ]
                        )
                        [ ( Dialog.showModal, "show-modal" )
                        , ( Dialog.showNonModal, "--show-non-modal" )
                        , ( Dialog.close, "close" )
                        , ( Dialog.requestClose, "request-close" )
                        ]
                    )
                    ()
        , test "trigger is a Button that opens the dialog modally" <|
            \() ->
                Dialog.trigger confirm [ Button.secondary ] [ Html.text "Slett" ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "button"
                        , Selector.class "ds-button"
                        , attr "command" "show-modal"
                        , attr "commandfor" "confirm"
                        , attr "data-variant" "secondary"
                        , Selector.text "Slett"
                        ]
        , test "trigger seeds aria-haspopup, like React's Dialog.Trigger" <|
            \() ->
                Dialog.trigger confirm [] []
                    |> Query.fromHtml
                    |> Query.has [ attr "aria-haspopup" "dialog" ]
        , test "idToString round-trips" <|
            \() -> Dialog.idToString confirm |> Expect.equal "confirm"
        ]
