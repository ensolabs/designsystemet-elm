module Stories.AvatarStack exposing (Model, Msg, chapter, init, update)

{-| `avatar-stack.stories.tsx`, story for story.

`AvatarStack.view` wraps each avatar in its own `<li>`, so the stories pass
avatars, not list items. The Playground story has sliders, so this chapter
keeps state.

Differences from the React stories (they show up in the markup diff):

  - React styles `section`, `fieldset` and `legend` with a global `<style>`;
    here the same styles are inline on the `section` and
    `fieldset` helpers, so they don't leak into the rest of the page.
  - Images are `/assets/cat*.webp` with `alt=""`.
  - WithTooltip: React's `<Tooltip>` writes its default `data-placement="top"`
    and `data-autoplacement="true"`; a `Tooltip` name leaves them out, which
    means the same.
  - Playground: the sliders' `value` is a DOM property, not an attribute.

-}

import Designsystemet as Ds
import Designsystemet.Avatar as Avatar exposing (Content(..), Name(..))
import Designsystemet.AvatarStack as AvatarStack
import Designsystemet.Checkbox as Checkbox
import Designsystemet.Field as Field
import Designsystemet.Label as Label
import Designsystemet.Size as Size
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icons
import Showcase.Story as Story exposing (Chapter)



-- STATE


{-| The Playground's controls. Sizes are in pixels.
-}
type alias Model =
    { expand : Maybe AvatarStack.Expand
    , size : Int
    , radius : Int
    , overlap : Int
    , gap : Int
    }


type Msg
    = ToggledExpandable Bool
    | ChangedRadius Int
    | ChangedSize Int
    | ChangedOverlap Int
    | ChangedGap Int


init : Model
init =
    { expand = Nothing, size = 64, radius = 150, overlap = 32, gap = 2 }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggledExpandable True ->
            { model | expand = Just AvatarStack.Grow }

        ToggledExpandable False ->
            { model | expand = Nothing }

        ChangedRadius pixels ->
            { model | radius = pixels }

        ChangedSize pixels ->
            { model | size = pixels }

        ChangedOverlap pixels ->
            { model | overlap = pixels }

        ChangedGap pixels ->
            { model | gap = pixels }



-- STORIES


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "AvatarStack", module_ = "Stories.AvatarStack", storybook = "komponenter-avatarstack" }
        [ Story.story "Preview" preview
        , Story.story "Expandable" expandable
        , Story.story "DataSize" dataSize
        , Story.story "Radius" radius
        , Story.story "WithTooltip" withTooltip
        , Story.story "WithTooltipAndLink" withTooltipAndLink
        , Story.story "Playground" (playground model)
        ]
        |> Story.withLayout Story.Fullscreen


preview : List (Html msg)
preview =
    [ AvatarStack.new
        |> AvatarStack.view [ Attr.attribute "aria-label" "Test av aria label" ]
            [ Avatar.view { name = Label "Navn", content = Image "/assets/cat1Img.webp" } []
            , Avatar.view { name = Label "Navn", content = Icon (Icons.briefcase []) } []
            , Avatar.view { name = Label "Navn", content = Initials "md" } []
            ]
    ]


expandable : List (Html msg)
expandable =
    let
        profiles : List (Html msg)
        profiles =
            [ Avatar.view { name = Label "profile picture a", content = Image "/assets/cat1Img.webp" } []
            , Avatar.view { name = Label "profile picture b", content = Image "/assets/cat1Img.webp" } []
            , Avatar.view { name = Label "profile picture c", content = Image "/assets/cat3Img.webp" } []
            , Avatar.view { name = Label "profile picture d", content = Image "/assets/cat4Img.webp" } []
            ]
    in
    [ section
        [ legendFieldset "expandable"
            [ AvatarStack.new
                |> AvatarStack.withExpand AvatarStack.Grow
                |> AvatarStack.view [ Attr.attribute "aria-label" "Test av aria label" ] profiles
            ]
        , legendFieldset "expandable=\"fixed\""
            [ AvatarStack.new
                |> AvatarStack.withExpand AvatarStack.ReserveSpace
                |> AvatarStack.view [ Attr.attribute "aria-label" "Test av aria label" ] profiles
            ]
        , legendFieldset "default"
            [ AvatarStack.new
                |> AvatarStack.view [ Attr.attribute "aria-label" "Test av aria label" ]
                    [ Avatar.view { name = Label "Navn", content = Image "/assets/cat1Img.webp" } []
                    , Avatar.view { name = Label "Navn", content = Image "/assets/cat1Img.webp" } []
                    , Avatar.view { name = Label "Navn", content = Image "/assets/cat3Img.webp" } []
                    ]
            ]
        ]
    ]


dataSize : List (Html msg)
dataSize =
    let
        stack : List (Html.Attribute msg) -> String -> Html msg
        stack attributes initials =
            AvatarStack.new
                |> AvatarStack.view (Attr.attribute "aria-label" "Test av aria label" :: attributes)
                    [ Avatar.view { name = Label "Navn", content = Image "/assets/cat5Img.webp" } []
                    , Avatar.view { name = Label "Navn", content = Icon (Icons.briefcase []) } []
                    , Avatar.view { name = Label "Navn", content = Initials initials } []
                    ]

        sizes : List (Html.Attribute msg) -> List (Html msg)
        sizes attributes =
            [ stack (Ds.size Size.sm :: attributes) "sm"
            , stack (Ds.size Size.md :: attributes) "md"
            , stack (Ds.size Size.lg :: attributes) "lg"
            ]
    in
    [ legendFieldset "Avatar size default" (sizes [])
    , legendFieldset "Avatar size --ds-size-12" (sizes [ Attr.attribute "style" "--dsc-avatar-stack-size: var(--ds-size-12)" ])
    , legendFieldset "Avatar size 3rem" (sizes [ Attr.attribute "style" "--dsc-avatar-stack-size: 3rem" ])
    ]


radius : List (Html msg)
radius =
    [ AvatarStack.new
        |> AvatarStack.withExpand AvatarStack.ReserveSpace
        |> AvatarStack.view
            [ Attr.attribute "aria-label" "Test av aria label"
            , Attr.attribute "style" "--dsc-avatar-stack-radius: var(--ds-border-radius-sm)"
            ]
            [ Avatar.view { name = Label "variant square", content = Placeholder } []
            , Avatar.view { name = Label "Ola Nordmann", content = Image "/assets/cat5Img.webp" } []
            , Avatar.view { name = Label "Ola Nordmann", content = Image "/assets/cat1Img.webp" } []
            , Avatar.view { name = Label "Ola Nordmann", content = Image "/assets/cat5Img.webp" } []
            , Avatar.view { name = Label "Ola Nordmann", content = Image "/assets/cat5Img.webp" } []
            ]
    ]


withTooltip : List (Html msg)
withTooltip =
    -- A `Tooltip` name is both the avatar's accessible name and its tooltip,
    -- and makes it focusable, so it covers React's `data-tooltip` prop and
    -- the `<Tooltip>` wrapper alike.
    [ section
        [ legendFieldset "expandable"
            [ AvatarStack.new
                |> AvatarStack.withExpand AvatarStack.ReserveSpace
                |> AvatarStack.view [ Attr.attribute "aria-label" "Test av aria label" ]
                    [ Avatar.view { name = Tooltip "Ola Nordmann", content = Image "/assets/cat1Img.webp" } []
                    , Avatar.view { name = Tooltip "Kari Nordmann", content = Image "/assets/cat5Img.webp" } []
                    , Avatar.view { name = Tooltip "Person 2", content = Initials "Hei" } []
                    , Avatar.view { name = Tooltip "Person 3", content = Image "/assets/cat5Img.webp" } []
                    ]
            ]
        , legendFieldset "not expandable"
            [ AvatarStack.new
                |> AvatarStack.view [ Attr.attribute "aria-label" "Test av aria label" ]
                    [ Avatar.view { name = Tooltip "Ola Nordmann", content = Image "/assets/cat1Img.webp" } []
                    , Avatar.view { name = Tooltip "Kari Nordmann", content = Image "/assets/cat5Img.webp" } []
                    , Avatar.view { name = Tooltip "Person 2", content = Image "/assets/cat5Img.webp" } []
                    , Avatar.view { name = Tooltip "Person 3", content = Image "/assets/cat5Img.webp" } []
                    ]
            ]
        ]
    ]


withTooltipAndLink : List (Html msg)
withTooltipAndLink =
    [ section
        [ legendFieldset "Link expandable"
            [ AvatarStack.new
                |> AvatarStack.withExpand AvatarStack.ReserveSpace
                |> AvatarStack.view [ Attr.attribute "aria-label" "Test av aria label" ]
                    [ Avatar.viewAs Html.a { name = Label "profile picture a", content = Image "/assets/cat1Img.webp" } [ Attr.href "#" ]
                    , Avatar.viewAs Html.a { name = Label "profile picture b", content = Image "/assets/cat1Img.webp" } [ Attr.href "#" ]
                    , Avatar.viewAs Html.a { name = Label "profile picture c", content = Image "/assets/cat3Img.webp" } [ Attr.href "#" ]
                    , Avatar.viewAs Html.a { name = Label "profile picture d", content = Image "/assets/cat4Img.webp" } [ Attr.href "#" ]
                    ]
            ]
        , legendFieldset "Link + Tooltip"
            [ AvatarStack.new
                |> AvatarStack.view [ Attr.attribute "aria-label" "Test av aria label" ]
                    [ Avatar.viewAs Html.a { name = Tooltip "Ola Nordmann", content = Image "/assets/cat1Img.webp" } [ Attr.href "#" ]
                    , Avatar.viewAs Html.a { name = Tooltip "Kari Nordmann", content = Image "/assets/cat4Img.webp" } [ Attr.href "#" ]
                    , Avatar.viewAs Html.a { name = Tooltip "Person 2", content = Image "/assets/cat3Img.webp" } [ Attr.href "#" ]
                    , Avatar.viewAs Html.a { name = Tooltip "Person 3", content = Initials "BR" } [ Attr.href "#" ]
                    ]
            ]
        ]
    ]


playground : Model -> List (Html Msg)
playground model =
    let
        slider : { label : String, value : Int, min : Int, max : Int, onChange : Int -> Msg } -> Html Msg
        slider config =
            Field.view []
                [ Label.view [] [ Html.text (config.label ++ " "), Html.text (String.fromInt config.value ++ "px") ]
                , Html.input
                    [ Attr.type_ "range"
                    , Attr.min (String.fromInt config.min)
                    , Attr.max (String.fromInt config.max)
                    , Attr.step "1"
                    , Attr.value (String.fromInt config.value)
                    , Attr.style "width" "100%"
                    , Events.onInput (String.toInt >> Maybe.withDefault config.value >> config.onChange)
                    ]
                    []
                ]

        px : Int -> String
        px n =
            String.fromInt n ++ "px"

        withExpand : AvatarStack.AvatarStack -> AvatarStack.AvatarStack
        withExpand =
            case model.expand of
                Just expand ->
                    AvatarStack.withExpand expand

                Nothing ->
                    identity
    in
    [ fieldset
        [ Checkbox.new (Ds.label "Expandable")
            |> Checkbox.view [ Attr.checked (model.expand /= Nothing), Events.onCheck ToggledExpandable ]
        , slider { label = "Radius", value = model.radius, min = 0, max = 150, onChange = ChangedRadius }
        , slider { label = "Size", value = model.size, min = 24, max = 150, onChange = ChangedSize }
        , slider { label = "Overlap", value = model.overlap, min = 0, max = 150, onChange = ChangedOverlap }
        , slider { label = "Gap", value = model.gap, min = 0, max = 15, onChange = ChangedGap }
        ]
    , Html.br [] []
    , AvatarStack.new
        |> withExpand
        |> AvatarStack.withOverflow "+10"
        |> AvatarStack.view
            -- CSS variables need `Attr.attribute "style"`: `Attr.style` can't
            -- set custom properties.
            [ Attr.attribute "style"
                (String.join "; "
                    [ "--dsc-avatar-stack-gap: " ++ px model.gap
                    , "--dsc-avatar-stack-overlap: " ++ px model.overlap
                    , "--dsc-avatar-stack-radius: " ++ px model.radius
                    , "--dsc-avatar-stack-size: " ++ px model.size
                    ]
                )
            ]
            [ Avatar.view { name = Label "profile a", content = Image "/assets/cat1Img.webp" } []
            , Avatar.view { name = Label "profile b", content = Image "/assets/cat5Img.webp" } []
            , Avatar.view { name = Label "profile c", content = Initials "md" } []
            , Avatar.view { name = Label "profile d", content = Image "/assets/cat5Img.webp" } []
            , Avatar.view { name = Label "profile e", content = Image "/assets/cat1Img.webp" } []
            ]
    ]



-- LAYOUT


{-| The React stories style `section`, `fieldset` and `legend` with a global
`<style>`; here the same styles are on the elements themselves.
-}
section : List (Html msg) -> Html msg
section =
    Html.section
        [ Attr.style "display" "flex"
        , Attr.style "flex-direction" "row"
        , Attr.style "gap" "var(--ds-size-4)"
        , Attr.style "flex-wrap" "wrap"
        ]


fieldset : List (Html msg) -> Html msg
fieldset =
    Html.fieldset
        [ Attr.style "display" "flex"
        , Attr.style "gap" "var(--ds-size-4)"
        , Attr.style "align-items" "center"
        ]


legendFieldset : String -> List (Html msg) -> Html msg
legendFieldset legend content =
    fieldset (Html.legend [ Attr.style "font-size" "11px" ] [ Html.text legend ] :: content)
