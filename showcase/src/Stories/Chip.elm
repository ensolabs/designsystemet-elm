module Stories.Chip exposing (chapter)

{-| `chip.stories.tsx`, story for story.

The upstream stories use `defaultChecked`, so they use the uncontrolled chips:
the browser keeps track of what is checked.

-}

import Designsystemet.Chip as Chip
import Html exposing (Html)
import Showcase.Story as Story exposing (Chapter)


chapter : Chapter msg
chapter =
    Story.chapter { title = "Chip", module_ = "Stories.Chip", storybook = "komponenter-chip" }
        [ Story.story "Preview" preview
        , Story.story "Checkbox" checkbox
        , Story.story "Removable" removable
        , Story.story "Button" button
            |> Story.withStoryCustomStyles [ ( "flex-wrap", "wrap" ), ( "justify-content", "center" ) ]
        , Story.story "Nowrap" nowrap |> Story.withStoryLayout Story.Padded
        , Story.story "Wrap" wrap |> Story.withStoryLayout Story.Padded
        ]
        |> Story.withCustomStyles [ ( "display", "flex" ), ( "gap", "var(--ds-size-2)" ) ]


preview : List (Html msg)
preview =
    [ Chip.uncontrolledRadio { name = "my-radio", value = "nynorsk", initiallyChecked = True } [] [ Html.text "Nynorsk" ]
    , Chip.uncontrolledRadio { name = "my-radio", value = "bokmål", initiallyChecked = False } [] [ Html.text "Bokmål" ]
    ]


checkbox : List (Html msg)
checkbox =
    [ Chip.uncontrolledCheckbox { name = "my-checkbox", value = "nynorsk", initiallyChecked = False } [] [ Html.text "Nynorsk" ] ]


removable : List (Html msg)
removable =
    -- Clicking doesn't remove the chip: the app handles the click.
    [ Chip.removable { removeLabel = "Trykk for å fjerne" } [] [ Html.text "Norge" ] ]


button : List (Html msg)
button =
    [ Chip.button [] [ Html.text "Tøm alle filtre" ] ]


nowrap : List (Html msg)
nowrap =
    [ Chip.uncontrolledRadio { name = "my-radio-nowrap", value = "nynorsk", initiallyChecked = True } [] [ Html.text loremIpsum ]
    , Chip.uncontrolledCheckbox { name = "my-checkbox-nowrap", value = "nynorsk", initiallyChecked = True } [] [ Html.text loremIpsum ]
    , Chip.removable { removeLabel = "Trykk for å fjerne" } [] [ Html.text loremIpsum ]
    , Chip.button [] [ Html.text loremIpsum ]
    ]


wrap : List (Html msg)
wrap =
    [ Chip.uncontrolledRadio { name = "my-radio-wrap", value = "nynorsk", initiallyChecked = True } [ Chip.wrap ] [ Html.text loremIpsum ]
    , Chip.uncontrolledCheckbox { name = "my-checkbox-wrap", value = "nynorsk", initiallyChecked = True } [ Chip.wrap ] [ Html.text loremIpsum ]
    , Chip.removable { removeLabel = "Trykk for å fjerne" } [ Chip.wrap ] [ Html.text loremIpsum ]
    , Chip.button [ Chip.wrap ] [ Html.text loremIpsum ]
    ]


loremIpsum : String
loremIpsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus in lobortis eros. Aenean id tellus molestie, semper massa non, ultricies sapien."
