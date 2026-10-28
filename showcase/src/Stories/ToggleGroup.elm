module Stories.ToggleGroup exposing (chapter)

{-| `toggle-group.stories.tsx`, story for story.

The values are your own types; `toValue` turns them into the radio buttons'
`value`. React's `defaultValue` stories use `ToggleGroup.uncontrolled`, its
`value`/`onChange` story `ToggleGroup.controlled`.

-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Divider as Divider
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Size as Size
import Designsystemet.ToggleGroup as ToggleGroup
import Html exposing (Html)
import Html.Events as Events
import Icons
import Showcase.Story as Story exposing (Chapter)
import Stories.Interactive.State exposing (Folder(..), Model, Msg(..), folderToString)


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "ToggleGroup", module_ = "Stories.ToggleGroup", storybook = "komponenter-togglegroup" }
        [ Story.story "Preview" preview
        , Story.story "OnlyIcons" onlyIcons
        , Story.story "Kontrollert" (kontrollert model)
        , Story.story "Secondary" secondary
        , Story.story "SecondaryOnlyIcons" secondaryOnlyIcons
        , Story.story "Disabled" disabled
        , Story.story "ReadOnly" readOnly
        , Story.story "AriaDisabled" ariaDisabled
        ]


type Alignment
    = AlignLeft
    | AlignCenter
    | AlignRight


alignmentToString : Alignment -> String
alignmentToString alignment =
    case alignment of
        AlignLeft ->
            "option-1"

        AlignCenter ->
            "option-2"

        AlignRight ->
            "option-3"


preview : List (Html msg)
preview =
    [ ToggleGroup.uncontrolled { name = "toggle-group-nuts", label = "Filtrering", toValue = folderToString, initial = Inbox }
        []
        [ ToggleGroup.item Inbox [ Html.text "Innboks" ]
        , ToggleGroup.item Drafts [ Html.text "Utkast" ]
        , ToggleGroup.item Archive [ Html.text "Arkiv" ]
        , ToggleGroup.item Sent [ Html.text "Sendt" ]
        ]
    ]


onlyIcons : List (Html msg)
onlyIcons =
    -- An icon item's label names it and is shown as its tooltip.
    [ ToggleGroup.uncontrolled { name = "alignment", label = "Tekstjustering", toValue = alignmentToString, initial = AlignLeft }
        []
        [ ToggleGroup.iconItem { value = AlignLeft, label = "Venstrestilt", icon = Icons.alignLeft [] }
        , ToggleGroup.iconItem { value = AlignCenter, label = "Midtstilt", icon = Icons.alignCenter [] }
        , ToggleGroup.iconItem { value = AlignRight, label = "Høyrestilt", icon = Icons.alignRight [] }
        ]
    ]


kontrollert : Model -> List (Html Msg)
kontrollert model =
    [ ToggleGroup.controlled
        { name = "folder"
        , label = "Filtrering"
        , toValue = folderToString
        , selected = model.folder
        , onSelect = FolderSelected
        }
        []
        [ ToggleGroup.item Inbox [ Icons.envelopeClosed [], Html.text "Innboks" ]
        , ToggleGroup.item Drafts [ Icons.docPencil [], Html.text "Utkast" ]
        , ToggleGroup.item Archive [ Icons.archive [], Html.text "Arkiv" ]
        , ToggleGroup.item Sent [ Icons.paperplane [], Html.text "Sendt" ]
        ]
    , Divider.view []
    , Paragraph.view [] [ Html.text ("Du har valgt: " ++ folderToString model.folder) ]
    , Button.view [ Ds.size Size.sm, Events.onClick (FolderSelected Archive) ] [ Html.text "Velg Arkiv" ]
    ]


secondary : List (Html msg)
secondary =
    [ ToggleGroup.uncontrolled { name = "toggle-group-secondary", label = "Filtrering", toValue = folderToString, initial = Inbox }
        [ ToggleGroup.secondary ]
        [ ToggleGroup.item Inbox [ Html.text "Innboks" ]
        , ToggleGroup.item Drafts [ Html.text "Utkast" ]
        , ToggleGroup.item Archive [ Html.text "Arkiv" ]
        , ToggleGroup.item Sent [ Html.text "Sendt" ]
        ]
    ]


secondaryOnlyIcons : List (Html msg)
secondaryOnlyIcons =
    [ ToggleGroup.uncontrolled { name = "alignment-secondary", label = "Filtrering", toValue = alignmentToString, initial = AlignLeft }
        [ ToggleGroup.secondary ]
        [ ToggleGroup.iconItem { value = AlignLeft, label = "Venstrestilt", icon = Icons.alignLeft [] }
        , ToggleGroup.iconItem { value = AlignCenter, label = "Midtstilt", icon = Icons.alignCenter [] }
        , ToggleGroup.iconItem { value = AlignRight, label = "Høyrestilt", icon = Icons.alignRight [] }
        ]
    ]


disabled : List (Html msg)
disabled =
    [ ToggleGroup.uncontrolled { name = "toggle-group-disabled", label = "Filtrering", toValue = identity, initial = "innboks" }
        []
        [ ToggleGroup.item "innboks" [ Html.text "Innboks" ]
        , ToggleGroup.item "utkast" [ Html.text "Utkast" ] |> ToggleGroup.disabled
        , ToggleGroup.item "arkiv" [ Html.text "Arkiv" ] |> ToggleGroup.disabled
        , ToggleGroup.item "Søppelpost" [ Html.text "Søppelpost" ]
        , ToggleGroup.item "sendt" [ Html.text "Sendt" ]
        ]
    ]


readOnly : List (Html msg)
readOnly =
    [ ToggleGroup.uncontrolled { name = "toggle-group-read-only", label = "Filtrering", toValue = identity, initial = "innboks" }
        []
        [ ToggleGroup.item "innboks" [ Html.text "Innboks" ]
        , ToggleGroup.item "utkast" [ Html.text "Utkast" ] |> ToggleGroup.readOnly
        , ToggleGroup.item "arkiv" [ Html.text "Arkiv" ] |> ToggleGroup.readOnly
        , ToggleGroup.item "Søppelpost" [ Html.text "Søppelpost" ]
        , ToggleGroup.item "sendt" [ Html.text "Sendt" ]
        ]
    ]


ariaDisabled : List (Html msg)
ariaDisabled =
    [ ToggleGroup.uncontrolled { name = "toggle-group-aria-disabled", label = "Filtrering", toValue = identity, initial = "innboks" }
        []
        [ ToggleGroup.item "innboks" [ Html.text "Innboks" ]
        , ToggleGroup.item "utkast" [ Html.text "Utkast" ] |> ToggleGroup.disabledFocusable
        , ToggleGroup.item "arkiv" [ Html.text "Arkiv" ] |> ToggleGroup.disabledFocusable
        , ToggleGroup.item "Søppelpost" [ Html.text "Søppelpost" ]
        , ToggleGroup.item "sendt" [ Html.text "Sendt" ]
        ]
    ]
