module Designsystemet.FileUploadTest exposing (suite)

import Designsystemet.FileUpload as FileUpload
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Designsystemet.FileUpload"
        [ test "renders a ds-file-upload div around its children" <|
            \() ->
                FileUpload.view [] [ Html.input [ Attr.type_ "file" ] [] ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.tag "div"
                        , Selector.class "ds-file-upload"
                        , Selector.containing [ Selector.tag "input", Selector.attribute (Attr.type_ "file") ]
                        ]
        ]
