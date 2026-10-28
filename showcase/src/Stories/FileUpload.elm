module Stories.FileUpload exposing (Drag, Model, Msg, chapter, init, update)

{-| `file-upload.stories.tsx`, story for story.

`FileUpload` is experimental, as in React. The files themselves are read with
`elm/file`.

-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Field as Field
import Designsystemet.FileUpload as FileUpload
import Designsystemet.Label as Label
import Designsystemet.Link as Link
import File exposing (File)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icons
import Json.Decode as Decode
import Showcase.Story as Story exposing (Chapter)



-- MODEL


type Drag
    = NotDragging
    | Dragging
    | DraggingWrongType


type alias Model =
    { profilePictures : List File
    , profileDrag : Drag
    , accepted : List File
    , rejected : List File
    , dropZoneDrag : Drag
    }


init : Model
init =
    { profilePictures = []
    , profileDrag = NotDragging
    , accepted = []
    , rejected = []
    , dropZoneDrag = NotDragging
    }


type Msg
    = ProfileDragged Drag
    | ProfilePicturesAdded (List File)
    | ProfilePicturesCleared
    | DropZoneDragged Drag
    | DropZoneFilesAdded (List File)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ProfileDragged drag ->
            ( { model | profileDrag = drag }, Cmd.none )

        ProfilePicturesAdded files ->
            ( { model | profilePictures = model.profilePictures ++ files, profileDrag = NotDragging }, Cmd.none )

        ProfilePicturesCleared ->
            ( { model | profilePictures = [], profileDrag = NotDragging }, Cmd.none )

        DropZoneDragged drag ->
            ( { model | dropZoneDrag = drag }, Cmd.none )

        DropZoneFilesAdded files ->
            let
                ( svgs, others ) =
                    List.partition isSvg files
            in
            ( { model
                | accepted = model.accepted ++ List.take (maxFiles - List.length model.accepted) svgs
                , rejected = model.rejected ++ others
                , dropZoneDrag = NotDragging
              }
            , Cmd.none
            )


maxFiles : Int
maxFiles =
    3


isSvg : File -> Bool
isSvg file =
    File.mime file == "image/svg+xml"



-- CHAPTER


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "FileUpload", module_ = "Stories.FileUpload", storybook = "komponenter-fileupload" }
        [ Story.story "Preview" preview
        , Story.story "Variants" variants
        , Story.story "LinkAlt" linkAlt
        , Story.story "ReadOnly" readOnly
        , Story.story "HiddenLabel" hiddenLabel
        , Story.story "WorkingExample" (workingExample model)
        , Story.story "ReactDropZoneExample" (reactDropZoneExample model)
        ]
        |> Story.withCustomStyles
            [ ( "display", "flex" )
            , ( "flex-direction", "row" )
            , ( "justify-content", "center" )
            , ( "align-items", "center" )
            , ( "flex-wrap", "wrap" )
            , ( "gap", "var(--ds-size-4)" )
            ]


preview : List (Html msg)
preview =
    [ Field.view []
        [ Label.view [] [ Html.text "Upload file" ]
        , FileUpload.view []
            [ Field.description [] [ Html.text "Drop file here" ]
            , Field.description [] [ Html.text "File must be in csv format and less than 2MB" ]
            , Button.viewAs Html.span [ Button.secondary ] [ Html.text "Upload file" ]
            , Html.input [ Attr.type_ "file" ] []
            ]
        ]
    ]


variants : List (Html msg)
variants =
    [ Field.view []
        [ Label.view [] [ Html.text "color variant default" ]
        , FileUpload.view []
            [ Field.description [] [ Html.text "Drop file here" ]
            , Field.description [] [ Html.text "File must be in csv format and less than 2MB" ]
            , Button.viewAs Html.span [ Button.secondary ] [ Html.text "Upload file" ]
            , Html.input [ Attr.type_ "file" ] []
            ]
        ]
    , Field.view []
        [ Label.view [] [ Html.text "color variant neutral" ]
        , FileUpload.view [ Ds.color Color.neutral ]
            [ Field.description [] [ Html.text "Drop file here" ]
            , Field.description [] [ Html.text "File must be in csv format and less than 2MB" ]
            , Button.viewAs Html.span [ Button.secondary ] [ Html.text "Upload file" ]
            , Html.input [ Attr.type_ "file" ] []
            ]
        ]
    ]


linkAlt : List (Html msg)
linkAlt =
    [ Field.view []
        [ Label.view [] [ Html.text "Upload file" ]
        , FileUpload.view []
            [ Field.description []
                [ Html.text "Drop files or "
                , Link.viewAs Html.span [] [ Html.text "click to browse" ]
                ]
            , Field.description [] [ Html.text "File must be in csv format and less than 2MB" ]
            , Html.input [ Attr.type_ "file" ] []
            ]
        ]
    ]


readOnly : List (Html msg)
readOnly =
    [ Field.view []
        [ Label.view [] [ Html.text "Upload file" ]
        , Field.description [] [ Html.text "description text" ]
        , FileUpload.view []
            [ Field.description [] [ Html.text "Upload limit reached" ]
            , Button.viewAs Html.span [ Button.secondary ] [ Html.text "Upload file" ]
            , Html.input [ Attr.type_ "file", Attr.readonly True ] []
            ]
        ]
    ]


hiddenLabel : List (Html msg)
hiddenLabel =
    [ Field.view []
        [ Label.view [ Attr.class "ds-sr-only" ] [ Html.text "Upload file" ]
        , Field.description [] [ Html.text "description text" ]
        , FileUpload.view []
            [ Field.description [] [ Html.text "Drop file here" ]
            , Field.description [] [ Html.text "File must be in csv format and less than 2MB" ]
            , Button.viewAs Html.span [ Button.secondary ] [ Html.text "Upload file" ]
            , Html.input [ Attr.type_ "file" ] []
            ]
        ]
    ]


{-| Files dropped on the area or picked with the file input both end up in
`ProfilePicturesAdded`. After one upload the input is read-only.
-}
workingExample : Model -> List (Html Msg)
workingExample model =
    let
        isReadOnly : Bool
        isReadOnly =
            not (List.isEmpty model.profilePictures)
    in
    [ Html.div [ Attr.style "min-width" "300px" ]
        (Field.view []
            [ Label.view [] [ Html.text "Upload profile picture" ]
            , FileUpload.view
                [ onDragOver (ProfileDragged Dragging)
                , Events.on "dragleave" (Decode.succeed (ProfileDragged NotDragging))
                , onDrop ProfilePicturesAdded
                ]
                ((if isReadOnly then
                    [ Icons.circleSlash []
                    , Field.description [] [ Html.text "You can not upload more files" ]
                    ]

                  else
                    [ Field.description []
                        [ Html.text
                            (if model.profileDrag == Dragging then
                                "Drop file to upload"

                             else
                                "Drop file here"
                            )
                        ]
                    , Field.description [] [ Html.text "File must be in svg format" ]
                    , Button.viewAs Html.span [ Button.secondary ] [ Html.text "Upload file" ]
                    ]
                 )
                    ++ [ Html.input
                            [ Attr.type_ "file"
                            , Attr.accept ".svg"
                            , Attr.readonly isReadOnly
                            , onFilesPicked ProfilePicturesAdded
                            ]
                            []
                       ]
                )
            ]
            :: (if isReadOnly then
                    [ Html.ul [] (List.map (\file -> Html.li [] [ Html.text (File.name file) ]) model.profilePictures)
                    , Button.view [ Events.onClick ProfilePicturesCleared ] [ Html.text "Clear file" ]
                    ]

                else
                    []
               )
        )
    ]


{-| React's story uses the `react-dropzone` library. In Elm the same
behaviour is a few event decoders: accept SVGs only, at most three files, and
warn while something else is dragged over.
-}
reactDropZoneExample : Model -> List (Html Msg)
reactDropZoneExample model =
    let
        remaining : Int
        remaining =
            maxFiles - List.length model.accepted

        isReadOnly : Bool
        isReadOnly =
            remaining <= 0

        fileList : String -> List File -> (File -> String) -> List (Html Msg)
        fileList title files describe =
            if List.isEmpty files then
                []

            else
                [ Html.p [] [ Html.text title ]
                , Html.ul [] (List.map (\file -> Html.li [] [ Html.text (describe file) ]) files)
                ]
    in
    [ Html.div [ Attr.style "min-width" "300px" ]
        (Field.view
            [ onDragOverTyped DropZoneDragged
            , Events.on "dragleave" (Decode.succeed (DropZoneDragged NotDragging))
            , onDrop DropZoneFilesAdded
            ]
            [ Label.view [] [ Html.text "Upload profile picture" ]
            , FileUpload.view []
                ((if isReadOnly then
                    [ Icons.circleSlash []
                    , Field.description [] [ Html.text "You can not upload more files" ]
                    ]

                  else
                    (if model.dropZoneDrag == DraggingWrongType then
                        [ Icons.circleSlash [] ]

                     else
                        []
                    )
                        ++ [ Field.description []
                                [ Html.text
                                    (case model.dropZoneDrag of
                                        DraggingWrongType ->
                                            "File type not accepted"

                                        Dragging ->
                                            "Drop file(s) here"

                                        NotDragging ->
                                            "Drop file(s) or click to upload"
                                    )
                                ]
                           , Field.description []
                                [ Html.text "File must be "
                                , Html.code [] [ Html.text ".svg" ]
                                , Html.text
                                    (", "
                                        ++ String.fromInt remaining
                                        ++ " of "
                                        ++ String.fromInt maxFiles
                                        ++ " files remaining"
                                    )
                                ]
                           , Button.viewAs Html.span [ Button.secondary ] [ Html.text "Upload file" ]
                           ]
                 )
                    ++ [ Html.input
                            [ Attr.type_ "file"
                            , Attr.accept ".svg,image/svg+xml"
                            , Attr.multiple True
                            , Attr.readonly isReadOnly
                            , Attr.attribute "aria-invalid"
                                (if model.dropZoneDrag == DraggingWrongType then
                                    "true"

                                 else
                                    "false"
                                )
                            , onFilesPicked DropZoneFilesAdded
                            ]
                            []
                       ]
                )
            ]
            :: fileList "Accepted files" model.accepted File.name
            ++ fileList "Rejected files" model.rejected (\file -> File.name file ++ " — File type must be image/svg+xml")
        )
    ]



-- EVENTS


onFilesPicked : (List File -> msg) -> Html.Attribute msg
onFilesPicked toMsg =
    Events.on "change" (Decode.map toMsg (Decode.at [ "target", "files" ] (Decode.list File.decoder)))


{-| Dropping must cancel the browser's default, or it opens the file.
-}
onDrop : (List File -> msg) -> Html.Attribute msg
onDrop toMsg =
    Events.preventDefaultOn "drop"
        (Decode.map (\files -> ( toMsg files, True ))
            (Decode.at [ "dataTransfer", "files" ] (Decode.list File.decoder))
        )


{-| The browser only allows a drop where `dragover` is cancelled.
-}
onDragOver : msg -> Html.Attribute msg
onDragOver msg =
    Events.preventDefaultOn "dragover" (Decode.succeed ( msg, True ))


{-| Like `onDragOver`, but tells whether every dragged item is an SVG. While
dragging, only the types of the files can be read, not their names.
-}
onDragOverTyped : (Drag -> msg) -> Html.Attribute msg
onDragOverTyped toMsg =
    let
        itemType : Int -> Decode.Decoder String
        itemType index =
            Decode.at [ "dataTransfer", "items", String.fromInt index, "type" ] Decode.string

        allSvg : Int -> Decode.Decoder Bool
        allSvg count =
            List.range 0 (count - 1)
                |> List.map itemType
                |> List.foldr (Decode.map2 (::)) (Decode.succeed [])
                |> Decode.map (List.all ((==) "image/svg+xml"))
    in
    Events.preventDefaultOn "dragover"
        (Decode.at [ "dataTransfer", "items", "length" ] Decode.int
            |> Decode.andThen allSvg
            |> Decode.map
                (\isAllSvg ->
                    ( toMsg
                        (if isAllSvg then
                            Dragging

                         else
                            DraggingWrongType
                        )
                    , True
                    )
                )
        )
