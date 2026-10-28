module Stories.Dialog exposing (chapter)

{-| `dialog.stories.tsx`, story for story.

React's `Dialog.TriggerContext` isn't needed: a `Dialog.Id` links the trigger
and the dialog. React's dialogs have a close button labelled "Lukk
dialogvindu" unless told otherwise; here it is opt-in with
`Dialog.withCloseButton`.

-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Dialog as Dialog
import Designsystemet.Field as Field
import Designsystemet.Heading as Heading
import Designsystemet.Label as Label
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Suggestion as Suggestion
import Designsystemet.Textfield as Textfield
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Showcase.Story as Story exposing (Chapter)
import Stories.Interactive.State exposing (Model, Msg(..))


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Dialog", module_ = "Stories.Dialog", storybook = "komponenter-dialog" }
        [ Story.story "Preview" preview
        , Story.story "WithoutDialogTriggerContext" withoutDialogTriggerContext
        , Story.story "DialogWithOpenProp" (dialogWithOpenProp model)
        , Story.story "BackdropClosedbyAny" backdropClosedbyAny
        , Story.story "WithHeaderAndFooter" withHeaderAndFooter
        , Story.story "DialogWithForm" (dialogWithForm model)
        , Story.story "DialogWithMaxWidth" dialogWithMaxWidth
        , Story.story "DialogWithSuggestion" (dialogWithSuggestion model)
        , Story.story "DialogNonModal" dialogNonModal
            |> Story.withStoryCustomStyles [ ( "padding", "var(--ds-size-18)" ) ]
        , Story.story "DialogNonModalTrigger" dialogNonModalTrigger
        , Story.story "DialogNonModalRef" dialogNonModalRef
        , Story.story "DialogPlacementTop" dialogPlacementTop
        , Story.story "DialogPlacementBottom" dialogPlacementBottom
        , Story.story "DialogPlacementLeft" dialogPlacementLeft
        , Story.story "DialogPlacementRight" dialogPlacementRight
        ]
        |> Story.withCustomStyles [ ( "display", "grid" ), ( "align-items", "start" ), ( "justify-items", "center" ) ]
        |> Story.withLayout Story.Fullscreen


preview : List (Html msg)
preview =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-preview"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view []
            [ Heading.h2 [ Attr.style "margin-bottom" "var(--ds-size-2)" ] [ Html.text "Dialog header" ]
            , Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-2)" ]
                [ Html.text "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Blanditiis doloremque obcaecati assumenda odio ducimus sunt et." ]
            , Paragraph.view [ Paragraph.size Paragraph.Small ] [ Html.text "Dialog footer" ]
            ]
    ]


withoutDialogTriggerContext : List (Html msg)
withoutDialogTriggerContext =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-without-trigger-context"
    in
    -- Any button can open a dialog: give it the invoker attributes.
    [ Button.view (Dialog.showModal dialog) [ Html.text "Open Dialog with ref" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view []
            [ Paragraph.view [ Paragraph.size Paragraph.Small ] [ Html.text "Dialog subtittel" ]
            , Heading.h2 [ Attr.style "margin-bottom" "var(--ds-size-2)" ] [ Html.text "Dialog header" ]
            , Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-2)" ]
                [ Html.text "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Blanditiis doloremque obcaecati assumenda odio ducimus sunt et." ]
            , Html.text "Dialog footer"
            ]
    ]


{-| The dialog is open while `model.dialogOpen` is: `Dialog.open` renders the
state, and the companion script (`js/open-state.js`) calls
`showModal()` and `close()` to match. Closing it with <kbd>Esc</kbd> or the
close button fires `close`, and `Dialog.onClose` brings the model along.
-}
dialogWithOpenProp : Model -> List (Html Msg)
dialogWithOpenProp model =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-with-open-prop"
    in
    [ Button.view [ Events.onClick DialogOpenToggled ] [ Html.text "Open Dialog with prop" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Dialog.open model.dialogOpen, Dialog.onClose DialogClosed ]
            [ Paragraph.view [ Paragraph.size Paragraph.Small ] [ Html.text "Dialog subtittel" ]
            , Heading.h2 [ Attr.style "margin-bottom" "var(--ds-size-2)" ] [ Html.text "Dialog header" ]
            , Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-2)" ]
                [ Html.text "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Blanditiis doloremque obcaecati assumenda odio ducimus sunt et." ]
            , Html.text "Dialog footer"
            ]
    ]


backdropClosedbyAny : List (Html msg)
backdropClosedbyAny =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-closedby-any"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Dialog.closedByAny ]
            [ Heading.h2 []
                [ Html.text "Dialog med "
                , Html.code [] [ Html.text "closedby=\"any\"" ]
                , Html.text " og en veldig lang tittel"
                ]
            , Paragraph.view []
                [ Html.text "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Blanditiis doloremque obcaecati assumenda odio ducimus sunt et." ]
            , Paragraph.view [ Paragraph.size Paragraph.Small ] [ Html.text "Dialog footer" ]
            ]
    ]


withHeaderAndFooter : List (Html msg)
withHeaderAndFooter =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-with-header-and-footer"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view []
            [ Dialog.block []
                [ Paragraph.view [ Paragraph.size Paragraph.Small ] [ Html.text "Her er det også divider" ]
                , Heading.h2 [] [ Html.text "Vi kan legge divider under header" ]
                ]
            , Dialog.block []
                [ Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-2)" ]
                    [ Html.text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur sodales eros justo. Aenean non mi ipsum. Cras viverra elit nec vulputate mattis. Nunc placerat euismod pulvinar. Sed nec fringilla nulla, sit amet ultricies ante. Morbi egestas venenatis massa, eu interdum leo rutrum eu. Nulla varius, mi ac feugiat lacinia, magna eros ullamcorper arcu, vel tincidunt erat leo nec tortor. Sed ut dui arcu. Morbi commodo ipsum hendrerit est imperdiet imperdiet. Etiam sed maximus nisi. Quisque posuere posuere orci, non egestas risus facilisis a. Vivamus non tempus felis, in maximus lorem. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos." ]
                , Paragraph.view []
                    [ Html.text "Etiam nec tincidunt est. Integer semper sodales efficitur. Pellentesque pellentesque varius leo id congue. Integer lacinia porttitor massa id euismod. Maecenas porta, magna nec interdum eleifend, risus magna condimentum neque, a gravida nisl risus a elit. Donec accumsan metus et lectus placerat varius. Donec tristique odio arcu. Donec cursus leo a dui auctor pulvinar. Sed in elit urna. Nunc vitae magna sed nibh elementum dignissim et ut massa." ]
                ]
            , Dialog.block [] [ Html.text "Og over footer" ]
            ]
    ]


{-| React shows the submitted name in an `alert()`; here it is shown under the
trigger instead. Closing the dialog, however it happens, clears the field.
-}
dialogWithForm : Model -> List (Html Msg)
dialogWithForm model =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-with-form"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , case model.dialogFormSubmitted of
        Just name ->
            Paragraph.view [] [ Html.text ("Du har sendt inn skjema med navn: " ++ name) ]

        Nothing ->
            Html.text ""
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Dialog.closedByAny, Dialog.onClose DialogFormClosed ]
            [ Heading.h2 [ Attr.style "margin-bottom" "var(--ds-size-2)" ] [ Html.text "Dialog med skjema" ]
            , Textfield.new (Ds.label "Navn")
                |> Textfield.view
                    [ Attr.autofocus True
                    , Attr.value model.dialogFormName
                    , Events.onInput DialogFormNameChanged
                    ]
            , Html.div [ Attr.style "display" "flex", Attr.style "gap" "var(--ds-size-4)", Attr.style "margin-top" "var(--ds-size-4)" ]
                [ Button.view (Events.onClick DialogFormSubmitted :: Dialog.close dialog) [ Html.text "Send inn skjema" ]
                , Button.view (Button.secondary :: Dialog.close dialog) [ Html.text "Avbryt" ]
                ]
            ]
    ]


dialogWithMaxWidth : List (Html msg)
dialogWithMaxWidth =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-with-max-width"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Attr.style "max-width" "1200px" ]
            [ Heading.h2 [ Attr.style "margin-bottom" "var(--ds-size-2)" ] [ Html.text "Dialog med en veldig lang bredde" ]
            , Paragraph.view []
                [ Html.text "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Blanditiis doloremque obcaecati assumenda odio ducimus sunt et." ]
            ]
    ]


dialogWithSuggestion : Model -> List (Html Msg)
dialogWithSuggestion model =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-with-suggestion"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Attr.style "overflow" "visible" ]
            [ Dialog.block [] [ Heading.h2 [] [ Html.text "Dialog med suggestion" ] ]
            , Dialog.block []
                [ Field.view []
                    [ Label.view [] [ Html.text "Velg en destinasjon" ]
                    , Suggestion.single
                        { options = [ "Sogndal", "Oslo", "Brønnøysund", "Stavanger", "Trondheim", "Bergen", "Lillestrøm" ]
                        , selected = model.dialogDestination
                        , toValue = identity
                        , toLabel = identity
                        , onSelect = DestinationSelected
                        }
                        |> Suggestion.withClear { label = "Tøm" }
                        |> Suggestion.withEmptyMessage [ Html.text "Tomt" ]
                        |> Suggestion.withOptionContent (\place -> [ Html.text place, Html.div [] [ Html.text "Kommune" ] ])
                        |> Suggestion.view []
                    ]
                ]
            , Dialog.block [] [ Button.view (Button.secondary :: Dialog.close dialog) [ Html.text "Avbryt" ] ]
            ]
    ]


dialogNonModal : List (Html msg)
dialogNonModal =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-non-modal"
    in
    [ Button.view (Dialog.showNonModal dialog) [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view []
            [ Heading.h2 [] [ Html.text "Non-modal dialog" ]
            , Paragraph.view []
                [ Html.text "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Blanditiis doloremque obcaecati assumenda odio ducimus sunt et." ]
            ]
    ]


dialogNonModalTrigger : List (Html msg)
dialogNonModalTrigger =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-non-modal-trigger"
    in
    -- `Dialog.nonModal` is React's `modal={false}`; the button opens it with
    -- the matching invoker.
    [ Button.view (Dialog.showNonModal dialog) [ Html.text "Open non-modal dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Dialog.nonModal ]
            [ Heading.h2 [ Attr.style "margin-bottom" "var(--ds-size-4)" ] [ Html.text "Let us know" ]
            , Paragraph.view [ Attr.style "margin-bottom" "var(--ds-size-4)" ]
                [ Html.text "We’d love to hear your feedback on our new design system. Please let us know what you think!" ]
            , Button.view [ Button.primary ] [ Html.text "Give feedback" ]
            ]
    ]


dialogNonModalRef : List (Html msg)
dialogNonModalRef =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-non-modal-ref"
    in
    -- React calls `dialogRef.current.show()`; the invoker does the same.
    [ Button.view (Dialog.showNonModal dialog) [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Dialog.nonModal ]
            [ Heading.h2 [] [ Html.text "Non-modal dialog" ]
            , Paragraph.view []
                [ Html.text "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Blanditiis doloremque obcaecati assumenda odio ducimus sunt et." ]
            ]
    ]


dialogPlacementTop : List (Html msg)
dialogPlacementTop =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-placement-top"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Dialog.drawer Dialog.Top ]
            [ Dialog.block [] [ Paragraph.view [] [ Html.text "This is a Dialog with placement=\"top\"" ] ] ]
    ]


dialogPlacementBottom : List (Html msg)
dialogPlacementBottom =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-placement-bottom"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Dialog.drawer Dialog.Bottom ]
            [ Dialog.block [] [ Paragraph.view [] [ Html.text "This is a Dialog with placement=\"bottom\"" ] ] ]
    ]


dialogPlacementLeft : List (Html msg)
dialogPlacementLeft =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-placement-left"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Dialog.drawer Dialog.Left ]
            [ Dialog.block [] [ Paragraph.view [] [ Html.text "This is a Dialog with placement=\"left\"" ] ] ]
    ]


{-| Upstream's story opens on the left (a copy-paste slip in the React story);
this one opens on the right, as its name and text say.
-}
dialogPlacementRight : List (Html msg)
dialogPlacementRight =
    let
        dialog : Dialog.Id
        dialog =
            Dialog.id "dialog-placement-right"
    in
    [ Dialog.trigger dialog [] [ Html.text "Open Dialog" ]
    , Dialog.new dialog
        |> Dialog.withCloseButton { label = "Lukk dialogvindu" }
        |> Dialog.view [ Dialog.drawer Dialog.Right ]
            [ Dialog.block [] [ Paragraph.view [] [ Html.text "This is a Dialog with placement=\"right\"" ] ] ]
    ]
