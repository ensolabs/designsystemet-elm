module ReadmeTest exposing (suite)

{-| The example at the top of README.md, verbatim, so it keeps compiling.
-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Size as Size
import Designsystemet.Textfield as Textfield
import Expect
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Test exposing (Test, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


type alias Model =
    { name : String, nameError : Maybe String }


type Msg
    = Save
    | NameChanged String
    | Delete


view : Model -> Html Msg
view model =
    Html.form [ Ds.size Size.sm, Events.onSubmit Save ]
        [ Textfield.new (Ds.label "Navn")
            |> Textfield.withError model.nameError
            |> Textfield.view [ Attr.value model.name, Events.onInput NameChanged ]
        , Button.view [ Attr.type_ "submit" ] [ Html.text "Lagre" ]
        , Button.view [ Button.tertiary, Ds.color Color.danger, Events.onClick Delete ]
            [ Html.text "Slett" ]
        ]


suite : Test
suite =
    test "the README example renders a field and two buttons" <|
        \() ->
            view { name = "Kari", nameError = Just "Navnet er for kort" }
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "ds-button" ]
                |> Query.count (Expect.equal 2)
