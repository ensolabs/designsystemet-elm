module Stories.Forms exposing (Model, Msg, chapters, init, update)

{-| The forms chapters, and the state their interactive stories need.

A chapter with interactive stories is a small Elm program of its own (`Model`,
`Msg`, `update`), nested here the usual way.

Reading the parity diffs for these chapters: `Attr.checked`, `Attr.value` and
`Attr.selected` set DOM _properties_, so the `checked=""`, `value="…"` and
`selected=""` attributes React writes don't show in Elm's markup. What's on
screen is the same.

-}

import Showcase.Story as Story exposing (Chapter)
import Stories.Checkbox
import Stories.ErrorSummary
import Stories.Field
import Stories.Fieldset
import Stories.FileUpload
import Stories.Input
import Stories.Label
import Stories.Radio
import Stories.Search
import Stories.Select
import Stories.Suggestion
import Stories.Switch
import Stories.Textarea
import Stories.Textfield
import Stories.ValidationMessage


type alias Model =
    { checkbox : Stories.Checkbox.Model
    , errorSummary : Stories.ErrorSummary.Model
    , field : Stories.Field.Model
    , fileUpload : Stories.FileUpload.Model
    , input : Stories.Input.Model
    , search : Stories.Search.Model
    , select : Stories.Select.Model
    , suggestion : Stories.Suggestion.Model
    , textarea : Stories.Textarea.Model
    , textfield : Stories.Textfield.Model
    }


type Msg
    = CheckboxMsg Stories.Checkbox.Msg
    | ErrorSummaryMsg Stories.ErrorSummary.Msg
    | FieldMsg Stories.Field.Msg
    | FileUploadMsg Stories.FileUpload.Msg
    | InputMsg Stories.Input.Msg
    | SearchMsg Stories.Search.Msg
    | SelectMsg Stories.Select.Msg
    | SuggestionMsg Stories.Suggestion.Msg
    | TextareaMsg Stories.Textarea.Msg
    | TextfieldMsg Stories.Textfield.Msg


init : Model
init =
    { checkbox = Stories.Checkbox.init
    , errorSummary = Stories.ErrorSummary.init
    , field = Stories.Field.init
    , fileUpload = Stories.FileUpload.init
    , input = Stories.Input.init
    , search = Stories.Search.init
    , select = Stories.Select.init
    , suggestion = Stories.Suggestion.init
    , textarea = Stories.Textarea.init
    , textfield = Stories.Textfield.init
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckboxMsg chapterMsg ->
            Stories.Checkbox.update chapterMsg model.checkbox
                |> Tuple.mapBoth (\checkbox -> { model | checkbox = checkbox }) (Cmd.map CheckboxMsg)

        ErrorSummaryMsg chapterMsg ->
            Stories.ErrorSummary.update chapterMsg model.errorSummary
                |> Tuple.mapBoth (\errorSummary -> { model | errorSummary = errorSummary }) (Cmd.map ErrorSummaryMsg)

        FieldMsg chapterMsg ->
            Stories.Field.update chapterMsg model.field
                |> Tuple.mapBoth (\field -> { model | field = field }) (Cmd.map FieldMsg)

        FileUploadMsg chapterMsg ->
            Stories.FileUpload.update chapterMsg model.fileUpload
                |> Tuple.mapBoth (\fileUpload -> { model | fileUpload = fileUpload }) (Cmd.map FileUploadMsg)

        InputMsg chapterMsg ->
            Stories.Input.update chapterMsg model.input
                |> Tuple.mapBoth (\input -> { model | input = input }) (Cmd.map InputMsg)

        SearchMsg chapterMsg ->
            Stories.Search.update chapterMsg model.search
                |> Tuple.mapBoth (\search -> { model | search = search }) (Cmd.map SearchMsg)

        SelectMsg chapterMsg ->
            Stories.Select.update chapterMsg model.select
                |> Tuple.mapBoth (\select -> { model | select = select }) (Cmd.map SelectMsg)

        SuggestionMsg chapterMsg ->
            Stories.Suggestion.update chapterMsg model.suggestion
                |> Tuple.mapBoth (\suggestion -> { model | suggestion = suggestion }) (Cmd.map SuggestionMsg)

        TextareaMsg chapterMsg ->
            Stories.Textarea.update chapterMsg model.textarea
                |> Tuple.mapBoth (\textarea -> { model | textarea = textarea }) (Cmd.map TextareaMsg)

        TextfieldMsg chapterMsg ->
            Stories.Textfield.update chapterMsg model.textfield
                |> Tuple.mapBoth (\textfield -> { model | textfield = textfield }) (Cmd.map TextfieldMsg)


{-| In the order of the Storybook sidebar.
-}
chapters : Model -> List (Chapter Msg)
chapters model =
    [ Stories.Checkbox.chapter model.checkbox |> Story.map CheckboxMsg
    , Stories.ErrorSummary.chapter model.errorSummary |> Story.map ErrorSummaryMsg
    , Stories.Field.chapter model.field |> Story.map FieldMsg
    , Stories.Fieldset.chapter
    , Stories.FileUpload.chapter model.fileUpload |> Story.map FileUploadMsg
    , Stories.Input.chapter model.input |> Story.map InputMsg
    , Stories.Label.chapter
    , Stories.Radio.chapter
    , Stories.Search.chapter model.search |> Story.map SearchMsg
    , Stories.Select.chapter model.select |> Story.map SelectMsg
    , Stories.Suggestion.chapter model.suggestion |> Story.map SuggestionMsg
    , Stories.Switch.chapter
    , Stories.Textarea.chapter model.textarea |> Story.map TextareaMsg
    , Stories.Textfield.chapter model.textfield |> Story.map TextfieldMsg
    , Stories.ValidationMessage.chapter
    ]
