module Stories.Avatar exposing (chapter)

{-| `avatar.stories.tsx`, story for story.

Every avatar answers two questions, each with its own type: who it is for a
screen reader (`Avatar.Name`) and what it shows (`Avatar.Content`).

Differences from the React stories (they show up in the markup diff):

  - Images are `/assets/cat*.webp` with `alt=""`: an `Avatar.Image` is named
    by the avatar, so the picture itself is decorative.
  - InDropdown: the dropdown is a native `popover="auto"` and starts closed.
    React opens it with `open`; Elm can only open a popover from a click on
    its trigger (or a port).

-}

import Designsystemet as Ds
import Designsystemet.Avatar as Avatar exposing (Content(..), Name(..))
import Designsystemet.Badge as Badge
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Dropdown as Dropdown
import Designsystemet.Placement as Placement
import Designsystemet.Size as Size
import Html exposing (Html)
import Html.Attributes as Attr
import Icons
import Showcase.Story as Story exposing (Chapter)
import Theme


chapter : Chapter msg
chapter =
    Story.chapter { title = "Avatar", module_ = "Stories.Avatar", storybook = "komponenter-avatar" }
        [ Story.story "Preview" preview
        , Story.story "NoName" noName
        , Story.story "Sizes" sizes
        , Story.story "ColorVariants" colorVariants
        , Story.story "Radius" radius
        , Story.story "WithImage" withImage
        , Story.story "InDropdown" inDropdown
            |> Story.withStoryLayout Story.Fullscreen
            |> Story.withStoryCustomStyles [ ( "height", "320px" ) ]
        , Story.story "AsLink" asLink
        , Story.story "AsButton" asButton
        , Story.story "SlotAndInitials" slotAndInitials
        ]
        |> Story.withCustomStyles
            [ ( "display", "flex" )
            , ( "gap", "var(--ds-size-2)" )
            , ( "justify-content", "center" )
            , ( "align-items", "center" )
            , ( "flex-wrap", "wrap" )
            ]
        |> Story.withLayout Story.Padded


preview : List (Html msg)
preview =
    [ Avatar.view { name = Label "Ola Nordmann", content = Placeholder } [] ]


noName : List (Html msg)
noName =
    [ Avatar.view { name = Label "Ola", content = Placeholder } [] ]


sizes : List (Html msg)
sizes =
    List.concatMap
        (\( size, text, label ) ->
            [ Avatar.view { name = Label label, content = Initials text } [ Avatar.size size ]
            , Avatar.view { name = Label label, content = Placeholder } [ Avatar.size size ]
            , Avatar.view { name = Label label, content = Icon (Icons.heart []) } [ Avatar.size size ]
            ]
        )
        [ ( Avatar.ExtraSmall, "xs", "extra small" )
        , ( Avatar.Small, "sm", "small" )
        , ( Avatar.Medium, "md", "medium" )
        , ( Avatar.Large, "lg", "large" )
        ]


colorVariants : List (Html msg)
colorVariants =
    List.map
        (\color ->
            Avatar.view { name = Label ("color " ++ Color.toString color), content = Placeholder }
                [ Ds.color color ]
        )
        Theme.themeColors


radius : List (Html msg)
radius =
    -- React's deprecated `variant="square"` is a CSS variable here. Set it
    -- with `Attr.attribute "style"`: `Attr.style` can't set custom properties.
    [ Avatar.view { name = Label "radius default", content = Placeholder } []
    , Avatar.view { name = Label "radius md 1", content = Placeholder }
        [ Attr.attribute "style" "--dsc-avatar-radius: var(--ds-border-radius-md)" ]
    , Avatar.view { name = Label "Ola Nordmann", content = Initials "ON" } []
    , Avatar.view { name = Label "radius md 2", content = Initials "ON" }
        [ Attr.attribute "style" "--dsc-avatar-radius: var(--ds-border-radius-md)" ]
    ]


withImage : List (Html msg)
withImage =
    [ Avatar.view { name = Label "Ola Nordmann", content = Image "/assets/cat3Img.webp" } [] ]


inDropdown : List (Html msg)
inDropdown =
    let
        profiles : Dropdown.Id
        profiles =
            Dropdown.id "avatar-profiles"
    in
    -- Always open, like React's `open` without `onClose`: a "manual" popover,
    -- so a click outside doesn't close it either.
    [ Dropdown.trigger profiles
        [ Button.tertiary ]
        [ Avatar.view { name = Label "Ola Nordmann", content = Initials "ON" } [ Avatar.size Avatar.Small ]
        , Html.text "Velg Profil"
        ]
    , Dropdown.view profiles
        [ Dropdown.placement Placement.BottomEnd
        , Ds.size Size.md
        , Dropdown.open True
        , Attr.attribute "popover" "manual"
        ]
        [ Dropdown.list []
            [ Dropdown.item []
                [ Dropdown.button []
                    [ Badge.position { placement = Badge.TopRight, overlap = Badge.Circle }
                        []
                        [ Badge.view Badge.Dot [ Ds.color Color.danger, Ds.size Size.sm ]
                        , Avatar.view { name = Decorative, content = Initials "ON" } [ Avatar.size Avatar.ExtraSmall ]
                        ]
                    , Html.text "Ola Nordmann"
                    ]
                ]
            , Dropdown.item []
                [ Dropdown.button []
                    [ Avatar.view { name = Decorative, content = Icon (Icons.briefcase []) } [ Avatar.size Avatar.ExtraSmall ]
                    , Html.text "Sogndal kommune"
                    ]
                ]
            ]
        ]
    ]


asLink : List (Html msg)
asLink =
    List.map
        (\( size, label ) ->
            Avatar.viewAs Html.a
                { name = Label label, content = Icon (Icons.heart []) }
                [ Attr.href "#none", Avatar.size size ]
        )
        [ ( Avatar.ExtraSmall, "xs" )
        , ( Avatar.Small, "sm" )
        , ( Avatar.Medium, "md" )
        , ( Avatar.Large, "lg" )
        ]


asButton : List (Html msg)
asButton =
    List.map
        (\( size, label ) ->
            Avatar.viewAs Html.button
                { name = Label label, content = Icon (Icons.heart []) }
                [ Attr.type_ "button", Avatar.size size ]
        )
        [ ( Avatar.ExtraSmall, "xs" )
        , ( Avatar.Small, "sm" )
        , ( Avatar.Medium, "md" )
        , ( Avatar.Large, "lg" )
        ]


slotAndInitials : List (Html msg)
slotAndInitials =
    [ Avatar.viewAs Html.button { name = Label "xs", content = Initials "DS" } [ Attr.type_ "button" ]
    , Avatar.viewAs Html.button { name = Label "xs", content = Initials "0" } [ Attr.type_ "button" ]
    , Avatar.viewAs Html.button { name = Label "xs", content = Image "/assets/cat3Img.webp" } [ Attr.type_ "button" ]
    ]
