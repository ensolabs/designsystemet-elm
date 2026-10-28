module Designsystemet.AvatarStackTest exposing (suite)

import Designsystemet.AvatarStack as AvatarStack
import Expect
import Html
import Html.Attributes as Attr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


attr : String -> String -> Selector.Selector
attr name value =
    Selector.attribute (Attr.attribute name value)


suite : Test
suite =
    describe "Designsystemet.AvatarStack"
        [ test "wraps every avatar in an li inside ul.ds-avatar-stack" <|
            \() ->
                AvatarStack.new
                    |> AvatarStack.view [] [ Html.text "a", Html.text "b", Html.text "c" ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.tag "ul", Selector.class "ds-avatar-stack" ]
                        , Query.findAll [ Selector.tag "li" ] >> Query.count (Expect.equal 3)
                        , Query.hasNot [ Selector.attribute (Attr.tabindex 0) ]
                        ]
        , test "Grow is data-expandable=true and focusable" <|
            \() ->
                AvatarStack.new
                    |> AvatarStack.withExpand AvatarStack.Grow
                    |> AvatarStack.view [] []
                    |> Query.fromHtml
                    |> Query.has [ attr "data-expandable" "true", Selector.attribute (Attr.tabindex 0) ]
        , test "ReserveSpace is data-expandable=fixed" <|
            \() ->
                AvatarStack.new
                    |> AvatarStack.withExpand AvatarStack.ReserveSpace
                    |> AvatarStack.view [] []
                    |> Query.fromHtml
                    |> Query.has [ attr "data-expandable" "fixed", Selector.attribute (Attr.tabindex 0) ]
        , test "the caller's tabindex wins, as in React" <|
            \() ->
                AvatarStack.new
                    |> AvatarStack.withExpand AvatarStack.Grow
                    |> AvatarStack.view [ Attr.tabindex -1 ] []
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.attribute (Attr.tabindex -1) ]
                        , Query.hasNot [ Selector.attribute (Attr.tabindex 0) ]
                        ]
        , test "overflow text is a trailing li after the avatars" <|
            \() ->
                AvatarStack.new
                    |> AvatarStack.withOverflow "+5"
                    |> AvatarStack.view [] [ Html.text "a" ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "li" ]
                    |> Expect.all
                        [ Query.count (Expect.equal 2)
                        , Query.index -1 >> Query.has [ Selector.text "+5" ]
                        ]
        ]
