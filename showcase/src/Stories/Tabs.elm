module Stories.Tabs exposing (chapter)

{-| `tabs.stories.tsx`, story for story.

Each tab carries its own panel. The values are custom types; `toId` turns them
into the panels' DOM ids, which must be unique on the page.

-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Size as Size
import Designsystemet.Tabs as Tabs
import Html exposing (Html)
import Html.Events as Events
import Icons
import Showcase.Story as Story exposing (Chapter)
import Stories.Interactive.State exposing (Model, Msg(..), TabValue(..), tabValueToId)


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Tabs", module_ = "Stories.Tabs", storybook = "komponenter-tabs" }
        [ Story.story "Preview" preview
        , Story.story "IconsOnly" iconsOnly
        , Story.story "IconsWithText" iconsWithText
        , Story.story "Controlled" (controlled model)
        , Story.story "ControlledStop" controlledStop
        , Story.story "DefaultValue" defaultValue
        ]


type Vehicle
    = Car
    | Bicycle
    | Motorcycle


preview : List (Html msg)
preview =
    [ Tabs.uncontrolled { toId = \n -> "tabs-preview-" ++ String.fromInt n, initial = 1 }
        []
        [ Tabs.tab { value = 1, label = [ Html.text "Tab 1" ], panel = [ Html.text "content 1" ] }
        , Tabs.tab { value = 2, label = [ Html.text "Tab 2" ], panel = [ Html.text "content 2" ] }
        , Tabs.tab { value = 3, label = [ Html.text "Tab 3" ], panel = [ Html.text "content 3" ] }
        ]
    ]


iconsOnly : List (Html msg)
iconsOnly =
    let
        vehicleId : Vehicle -> String
        vehicleId vehicle =
            case vehicle of
                Car ->
                    "tabs-icons-only-car"

                Bicycle ->
                    "tabs-icons-only-bicycle"

                Motorcycle ->
                    "tabs-icons-only-motorcycle"

        none : List (Html msg)
        none =
            [ Html.text "Du har ingen av denne typen registrert hos oss" ]
    in
    -- An icon tab's label names it and is shown as its tooltip.
    [ Tabs.uncontrolled { toId = vehicleId, initial = Car }
        []
        [ Tabs.iconTab { value = Car, label = "Dine biler", icon = Icons.car [], panel = none }
        , Tabs.iconTab { value = Bicycle, label = "Dine sykler", icon = Icons.bicycle [], panel = none }
        , Tabs.iconTab { value = Motorcycle, label = "Dine motorsykler", icon = Icons.motorcycle [], panel = none }
        ]
    ]


iconsWithText : List (Html msg)
iconsWithText =
    let
        vehicleId : Vehicle -> String
        vehicleId vehicle =
            case vehicle of
                Car ->
                    "tabs-icons-with-text-car"

                Bicycle ->
                    "tabs-icons-with-text-bicycle"

                Motorcycle ->
                    "tabs-icons-with-text-motorcycle"

        none : List (Html msg)
        none =
            [ Html.text "Du har ingen av denne typen registrert hos oss" ]
    in
    [ Tabs.uncontrolled { toId = vehicleId, initial = Car }
        []
        [ Tabs.tab { value = Car, label = [ Icons.car [], Html.text "Biler" ], panel = none }
        , Tabs.tab { value = Bicycle, label = [ Icons.bicycle [], Html.text "Sykler" ], panel = none }
        , Tabs.tab { value = Motorcycle, label = [ Icons.motorcycle [], Html.text "Motorsykler" ], panel = none }
        ]
    ]


controlled : Model -> List (Html Msg)
controlled model =
    [ Button.view [ Ds.size Size.sm, Events.onClick (TabSelected Value3) ] [ Html.text "Choose Tab 3" ]
    , Html.br [] []
    , Tabs.controlled { toId = tabValueToId, selected = model.controlledTab, onSelect = TabSelected }
        []
        [ Tabs.tab { value = Value1, label = [ Icons.bell [], Html.text "Tab 1" ], panel = [ Html.text "content 1" ] }
        , Tabs.tab { value = Value2, label = [ Icons.newspaper [], Html.text "Tab 2" ], panel = [ Html.text "content 2" ] }
        , Tabs.tab { value = Value3, label = [ Icons.backpack [], Html.text "Tab 3" ], panel = [ Html.text "content 3" ] }
        ]
    ]


{-| Controlled tabs whose model never changes: clicking does nothing.
-}
controlledStop : List (Html Msg)
controlledStop =
    [ Tabs.controlled { toId = \n -> "tabs-controlled-stop-" ++ String.fromInt n, selected = 1, onSelect = \_ -> Ignored }
        []
        [ Tabs.tab { value = 1, label = [ Html.text "Tab 1" ], panel = [ Html.text "Content of tab 1" ] }
        , Tabs.tab { value = 2, label = [ Html.text "Tab 2" ], panel = [ Html.text "Content of tab 2" ] }
        ]
    ]


defaultValue : List (Html msg)
defaultValue =
    [ Tabs.uncontrolled { toId = \n -> "tabs-default-value-" ++ String.fromInt n, initial = 2 }
        []
        [ Tabs.tab { value = 1, label = [ Html.text "Tab 1" ], panel = [ Html.text "content 1" ] }
        , Tabs.tab { value = 2, label = [ Html.text "Tab 2" ], panel = [ Html.text "content 2" ] }
        , Tabs.tab { value = 3, label = [ Html.text "Tab 3" ], panel = [ Html.text "content 3" ] }
        ]
    ]
