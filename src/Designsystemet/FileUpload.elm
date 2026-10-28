module Designsystemet.FileUpload exposing (view)

{-| **Experimental.** A drop zone: a large dashed area around a native
`<input type="file">`.

Mirrors `EXPERIMENTAL_FileUpload` from `@digdir/designsystemet-react`. Markup
and styling may change in any release, as upstream.

    Field.view []
        [ Label.view [] [ Html.text "Last opp vedlegg" ]
        , FileUpload.view []
            [ Field.description [] [ Html.text "Slipp filen her" ]
            , Field.description [] [ Html.text "PDF, maks 2 MB" ]
            , Button.viewAs Html.span [ Button.secondary ] [ Html.text "Velg fil" ]
            , Html.input
                [ Attr.type_ "file"
                , Attr.accept ".pdf"
                , Events.on "change" (Decode.map PickedFiles filesDecoder)
                ]
                []
            ]
        ]

The file input is stretched invisibly over the area, so clicks and drops land
on it. The button is a `<span>` styled as one. Read the files with
`elm/file`:

    filesDecoder : Decode.Decoder (List File)
    filesDecoder =
        Decode.at [ "target", "files" ] (Decode.list File.decoder)

The CSS draws an upload icon unless the first child is your own `<svg>`.


# React → Elm

  - `<EXPERIMENTAL_FileUpload>` → `FileUpload.view []`

@docs view

-}

import Html exposing (Html)
import Html.Attributes as Attr


{-| A `<div class="ds-file-upload">`. Put it in a
[`Field`](Designsystemet-Field) so the label and descriptions connect to the
file input.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view attributes =
    Html.div (Attr.class "ds-file-upload" :: attributes)
