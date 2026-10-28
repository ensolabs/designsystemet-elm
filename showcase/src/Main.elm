module Main exposing (main)

{-| The showcase: every upstream Storybook story, in Elm, built with the
package itself.
-}

import Browser
import Browser.Navigation as Nav
import Designsystemet as Ds
import Designsystemet.Color as Color exposing (Color)
import Designsystemet.Details as Details
import Designsystemet.Field as Field
import Designsystemet.Heading as Heading
import Designsystemet.Label as Label
import Designsystemet.Link as Link
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Select as Select
import Designsystemet.Size as Size exposing (Size)
import Designsystemet.Tag as Tag
import Designsystemet.ToggleGroup as ToggleGroup
import Generated.Sources as Sources
import Html exposing (Html)
import Html.Attributes as Attr
import Showcase.Code as Code
import Showcase.GettingStarted as GettingStarted
import Showcase.Story as Story exposing (Chapter, Layout(..), Story)
import Stories.Button
import Stories.Display
import Stories.Forms
import Stories.Interactive
import Theme
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , route : Route
    , size : SizeChoice
    , scheme : Ds.ColorScheme
    , color : Maybe Color
    , display : Stories.Display.Model
    , forms : Stories.Forms.Model
    , interactive : Stories.Interactive.Model
    }


type Route
    = Home
    | ChapterPage String
    | NotFound


type SizeChoice
    = Small
    | Medium
    | Large


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init () url key =
    ( { key = key
      , route = toRoute url
      , size = Medium
      , scheme = Ds.Light
      , color = Nothing
      , display = Stories.Display.init
      , forms = Stories.Forms.init
      , interactive = Stories.Interactive.init
      }
    , Cmd.none
    )


isRoute : Url -> Bool
isRoute url =
    case url.fragment of
        Nothing ->
            True

        Just fragment ->
            fragment == "" || String.startsWith "/" fragment


toRoute : Url -> Route
toRoute url =
    case Maybe.map (String.split "/") url.fragment of
        Nothing ->
            Home

        Just [ "" ] ->
            Home

        Just [ "", "" ] ->
            Home

        Just [ "", chapterSlug ] ->
            ChapterPage chapterSlug

        Just _ ->
            NotFound



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | SizeChosen SizeChoice
    | SchemeChosen Ds.ColorScheme
    | ColorChosen (Maybe Color)
    | DisplayMsg Stories.Display.Msg
    | FormsMsg Stories.Forms.Msg
    | InteractiveMsg Stories.Interactive.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked (Browser.Internal url) ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        LinkClicked (Browser.External href) ->
            ( model, Nav.load href )

        UrlChanged url ->
            if isRoute url then
                ( { model | route = toRoute url }, Cmd.none )

            else
                -- An in-page link inside a story (href "#" or "#side-2"):
                -- stay on the chapter.
                ( model, Cmd.none )

        SizeChosen size ->
            ( { model | size = size }, Cmd.none )

        SchemeChosen scheme ->
            ( { model | scheme = scheme }, Cmd.none )

        ColorChosen color ->
            ( { model | color = color }, Cmd.none )

        DisplayMsg storyMsg ->
            Stories.Display.update storyMsg model.display
                |> Tuple.mapBoth (\display -> { model | display = display }) (Cmd.map DisplayMsg)

        FormsMsg storyMsg ->
            Stories.Forms.update storyMsg model.forms
                |> Tuple.mapBoth (\forms -> { model | forms = forms }) (Cmd.map FormsMsg)

        InteractiveMsg storyMsg ->
            Stories.Interactive.update storyMsg model.interactive
                |> Tuple.mapBoth (\interactive -> { model | interactive = interactive }) (Cmd.map InteractiveMsg)



-- CHAPTERS


{-| Every chapter, sorted by title like the Storybook sidebar.
-}
chapters : Model -> List (Chapter Msg)
chapters model =
    List.sortBy .title
        (Stories.Button.chapter
            :: List.map (Story.map DisplayMsg) (Stories.Display.chapters model.display)
            ++ List.map (Story.map FormsMsg) (Stories.Forms.chapters model.forms)
            ++ List.map (Story.map InteractiveMsg) (Stories.Interactive.chapters model.interactive)
        )


slug : Chapter msg -> String
slug chapter =
    String.toLower chapter.title



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Designsystemet for Elm"
    , body =
        [ Html.div [ Attr.class "showcase", Ds.colorScheme model.scheme ]
            [ viewHeader model
            , Html.div [ Attr.class "showcase__body" ]
                [ viewNav model
                , Html.main_ [ Attr.class "showcase__main", Attr.id "main" ] [ viewRoute model ]
                ]
            ]
        ]
    }


viewHeader : Model -> Html Msg
viewHeader model =
    Html.header [ Attr.class "showcase__header" ]
        [ Html.div [ Attr.class "showcase__brand" ]
            [ Heading.h1 [ Heading.size Heading.ExtraSmall ]
                [ Html.a [ Attr.href "#/" ] [ Html.text "Designsystemet for Elm" ] ]
            , Tag.view [ Ds.color Color.neutral ] [ Html.text ("v" ++ Ds.version) ]
            ]
        , Html.div [ Attr.class "showcase__toolbar", Ds.size Size.sm ]
            [ ToggleGroup.controlled
                { name = "size", label = "Size", toValue = sizeToString, selected = model.size, onSelect = SizeChosen }
                [ ToggleGroup.secondary ]
                [ ToggleGroup.item Small [ Html.text "sm" ]
                , ToggleGroup.item Medium [ Html.text "md" ]
                , ToggleGroup.item Large [ Html.text "lg" ]
                ]
            , ToggleGroup.controlled
                { name = "scheme", label = "Color scheme", toValue = schemeToString, selected = model.scheme, onSelect = SchemeChosen }
                [ ToggleGroup.secondary ]
                [ ToggleGroup.item Ds.Light [ Html.text "Light" ]
                , ToggleGroup.item Ds.Dark [ Html.text "Dark" ]
                , ToggleGroup.item Ds.Auto [ Html.text "Auto" ]
                ]
            , Field.view []
                [ Label.view [ Attr.class "showcase__sr-only" ] [ Html.text "Color" ]
                , Select.single
                    { options = Theme.all
                    , selected = model.color
                    , toValue = Color.toString
                    , toLabel = Color.toString
                    , onSelect = ColorChosen << Just
                    , placeholder = "Inherit color"
                    }
                    []
                ]
            ]
        ]


viewNav : Model -> Html Msg
viewNav model =
    Html.nav [ Attr.class "showcase__nav", Attr.attribute "aria-label" "Components" ]
        [ Html.ul []
            (List.map
                (\chapter ->
                    Html.li []
                        [ Html.a
                            [ Attr.href ("#/" ++ slug chapter)
                            , Attr.attribute "aria-current"
                                (if model.route == ChapterPage (slug chapter) then
                                    "page"

                                 else
                                    "false"
                                )
                            ]
                            [ Html.text chapter.title ]
                        ]
                )
                (chapters model)
            )
        ]


viewRoute : Model -> Html Msg
viewRoute model =
    case model.route of
        Home ->
            viewHome model

        ChapterPage s ->
            case List.filter (\c -> slug c == s) (chapters model) of
                chapter :: _ ->
                    viewChapter model chapter

                [] ->
                    viewNotFound

        NotFound ->
            viewNotFound


viewHome : Model -> Html Msg
viewHome model =
    Html.article [ Attr.class "showcase__home" ]
        [ Heading.h2 [ Heading.size Heading.Large ] [ Html.text "Designsystemet for Elm" ]
        , Paragraph.view [ Paragraph.long ]
            [ Html.text "Every component of "
            , Link.view [ Attr.href "https://www.npmjs.com/package/@digdir/designsystemet-react" ] [ Html.text "@digdir/designsystemet-react" ]
            , Html.text (" " ++ Ds.version ++ ", as plain Elm view functions. Each story mirrors its upstream Storybook story, links to it and shows its Elm source.")
            ]
        , Heading.h3 [ Heading.size Heading.Small ] [ Html.text "Who does what" ]
        , Html.ul []
            [ Html.li [] [ Html.strong [] [ Html.text "Elm renders" ], Html.text ": the same markup the React components render, with types for what React only documents." ]
            , Html.li [] [ Html.strong [] [ Html.text "@digdir/designsystemet-css styles" ], Html.text ": with your theme." ]
            , Html.li [] [ Html.strong [] [ Html.text "@digdir/designsystemet-web behaves" ], Html.text ": tabs, popovers, dialogs, field wiring and tooltips, as web components and polyfills." ]
            ]
        , Paragraph.view [] [ Html.text "The package needs nothing else. Getting started below loads them with Bun, with or without Tailwind." ]
        , Paragraph.view []
            [ Html.text "Use the toolbar to change "
            , Html.code [] [ Html.text "data-size" ]
            , Html.text ", "
            , Html.code [] [ Html.text "data-color" ]
            , Html.text " and the color scheme. They cascade into every story, as in an app."
            ]
        , Heading.h3 [ Heading.size Heading.Small ] [ Html.text "What Elm adds" ]
        , Html.ul []
            [ Html.li [] [ Html.text "Accessible names are required by type: a field without a label, or an icon button without one, does not compile." ]
            , Html.li [] [ Html.text "No default texts: every user-facing string is yours, in your language." ]
            , Html.li [] [ Html.text "Your own types for values: tabs carry their panels, a sortable table can only sort one column, an error summary links to the field it describes." ]
            , Html.li [] [ Html.text "Structure is never a flag: a badge is a dot, a count or a capped count; a button is plain, busy or icon-only." ]
            ]
        , Paragraph.view [] [ Html.text "A form:" ]
        , Code.view """Html.form [ Ds.size Size.sm, Events.onSubmit Save ]
    [ Textfield.new (Ds.label "Navn")
        |> Textfield.withError model.nameError
        |> Textfield.view [ Attr.value model.name, Events.onInput NameChanged ]
    , Button.view [ Attr.type_ "submit" ] [ Html.text "Lagre" ]
    , Button.view [ Button.tertiary, Ds.color Color.danger, Events.onClick Delete ]
        [ Html.text "Slett" ]
    ]"""
        , Paragraph.view []
            [ Html.text
                (String.fromInt (List.length (List.concatMap .stories (chapters model)))
                    ++ " stories in "
                    ++ String.fromInt (List.length (chapters model))
                    ++ " chapters: every upstream component story except a few that only test Storybook itself."
                )
            ]
        , GettingStarted.view
        ]


viewChapter : Model -> Chapter Msg -> Html Msg
viewChapter model chapter =
    Html.article []
        (Heading.h2 [ Heading.size Heading.Large ] [ Html.text chapter.title ]
            :: List.map (viewStory model chapter) chapter.stories
        )


viewStory : Model -> Chapter Msg -> Story Msg -> Html Msg
viewStory model chapter story =
    let
        functionName : String
        functionName =
            String.left 1 story.name |> String.toLower |> (\first -> first ++ String.dropLeft 1 story.name)
    in
    Html.section
        [ Attr.class "story"
        , Attr.id ("story-" ++ kebab story.name)
        , Attr.attribute "data-storybook-id" (chapter.storybook ++ "--" ++ kebab story.name)
        ]
        [ Html.header [ Attr.class "story__header" ]
            [ Heading.h3 [ Heading.size Heading.ExtraSmall ] [ Html.text (words story.name) ]
            , Link.view
                [ Attr.href ("https://storybook.designsystemet.no/?path=/story/" ++ chapter.storybook ++ "--" ++ kebab story.name)
                , Attr.target "_blank"
                , Attr.rel "noreferrer"
                ]
                [ Html.text "React version ↗" ]
            ]
        , Html.div
            [ Attr.class "story__canvas"
            , Attr.attribute "data-layout" (layoutToString (Story.layout chapter story))
            , Ds.size (sizeToSize model.size)
            , case model.color of
                Just color ->
                    Ds.color color

                Nothing ->
                    Attr.classList []
            ]
            [ Html.div
                (Attr.class "story__root"
                    :: List.map (\( property, value ) -> Attr.style property value) (Story.rootStyles chapter story)
                )
                story.view
            ]
        , case Sources.get chapter.module_ functionName of
            Just source ->
                Details.view { summary = [ Html.text "Elm" ], content = [ Code.view source ] } [ Attr.class "story__source" ]

            Nothing ->
                Html.text ""
        ]


viewNotFound : Html msg
viewNotFound =
    Paragraph.view [] [ Html.text "No such page." ]



-- HELPERS


sizeToString : SizeChoice -> String
sizeToString size =
    case size of
        Small ->
            "sm"

        Medium ->
            "md"

        Large ->
            "lg"


sizeToSize : SizeChoice -> Size
sizeToSize size =
    case size of
        Small ->
            Size.sm

        Medium ->
            Size.md

        Large ->
            Size.lg


schemeToString : Ds.ColorScheme -> String
schemeToString scheme =
    case scheme of
        Ds.Light ->
            "light"

        Ds.Dark ->
            "dark"

        Ds.Auto ->
            "auto"


layoutToString : Layout -> String
layoutToString layout =
    case layout of
        Centered ->
            "centered"

        Padded ->
            "padded"

        Fullscreen ->
            "fullscreen"


{-| `"ColorsHover"` → `"colors-hover"`, `"ContentEx1"` → `"content-ex-1"` and
`"WithCSSTooltipText"` → `"with-css-tooltip-text"`: the way Storybook builds
story ids from export names.
-}
kebab : String -> String
kebab name =
    String.join "-" (List.map String.toLower (storyWords name))


{-| `"ColorsHover"` → `"Colors Hover"`, the way Storybook shows story names.
-}
words : String -> String
words name =
    String.join " " (storyWords name)


{-| Split an export name into words like Storybook does (lodash `startCase`):
at a lower-to-upper change, between letters and digits, and before the last
capital of an acronym that is followed by a lowercase letter (`CSSTooltip` is
`CSS` and `Tooltip`).
-}
storyWords : String -> List String
storyWords name =
    let
        chars : List Char
        chars =
            String.toList name

        boundary : Char -> Char -> Maybe Char -> Bool
        boundary previous current next =
            (Char.isLower previous && Char.isUpper current)
                || (Char.isDigit previous /= Char.isDigit current)
                || (Char.isUpper previous && Char.isUpper current && Maybe.map Char.isLower next == Just True)

        go : List Char -> List Char -> List String -> List String
        go remaining word acc =
            case remaining of
                current :: rest ->
                    case word of
                        previous :: _ ->
                            if boundary previous current (List.head rest) then
                                go rest [ current ] (String.fromList (List.reverse word) :: acc)

                            else
                                go rest (current :: word) acc

                        [] ->
                            go rest [ current ] acc

                [] ->
                    List.reverse
                        (if List.isEmpty word then
                            acc

                         else
                            String.fromList (List.reverse word) :: acc
                        )
    in
    go chars [] []
