module Designsystemet.Tabs exposing
    ( Tab, tab, iconTab
    , uncontrolled, controlled
    )

{-| Content split into panels, one shown at a time.

Mirrors `Tabs` from `@digdir/designsystemet-react`.

    type Section
        = Overview
        | Documents
        | History

    sectionId : Section -> String
    sectionId section =
        case section of
            Overview ->
                "case-overview"

            Documents ->
                "case-documents"

            History ->
                "case-history"

    view : Model -> Html Msg
    view model =
        Tabs.controlled { toId = sectionId, selected = model.section, onSelect = SectionSelected }
            []
            [ Tabs.tab { value = Overview, label = [ Html.text "Oversikt" ], panel = [ overview model ] }
            , Tabs.tab { value = Documents, label = [ Html.text "Dokumenter" ], panel = [ documents model ] }
            , Tabs.tab { value = History, label = [ Html.text "Historikk" ], panel = [ history model ] }
            ]

Each tab carries its panel, so neither can exist without the other.

The markup is `designsystemet-web`'s `<ds-tabs>`, which handles the keyboard
(arrow keys, Home, End), focus and showing the right panel.


# Controlled or uncontrolled

  - [`uncontrolled`](#uncontrolled): the browser tracks the open tab and
    nothing goes in your model. Use it when the rest of the page doesn't care
    which tab is open.
  - [`controlled`](#controlled): your model says which tab is open, and
    clicking a tab sends a message instead of switching. Use it when the open
    tab is in the URL or something else depends on it.


# Ids

`toId` turns a value into the DOM `id` of its panel, so it must be unique on
the page. Prefix it if you have more than one set of tabs.


# React → Elm

  - `<Tabs defaultValue="a">` → `Tabs.uncontrolled { toId = …, initial = A } []`
  - `<Tabs value={v} onChange={f}>` → `Tabs.controlled { toId = …, selected = v, onSelect = F } []`
  - `<Tabs.List>` + `<Tabs.Tab value="a">` → `Tabs.tab { value = A, label = […], panel = […] }`
  - `<Tabs.Panel value="a">` → the `panel` of that `Tabs.tab`
  - `<Tooltip content="…"><Tabs.Tab>` + icon → `Tabs.iconTab { value = A, label = "…", icon = …, panel = […] }`
  - `<Tabs onChange={f}>` without `value` → use `controlled`


# Differences from React

React puts the raw `value` in each tab's `data-value` and derives the panel
ids from it with `useId`. Here both are `toId value`, since Elm has no `useId`
and `toId` already gives a unique, readable string.


# Managed by designsystemet-web

Never set these yourself: `tabindex` on tabs and panels; `hidden`,
`aria-hidden`, `aria-labelledby` and `role` on panels; `role` on the list.
In uncontrolled tabs, `aria-selected` also belongs to the web component after
the first render. Elm writes it again only when `initial` changes. Elm renders
the tabs' `role="tab"` and `aria-controls` as React does, with the values the
web component would write.

@docs Tab, tab, iconTab
@docs uncontrolled, controlled

-}

import Designsystemet.Internal.Attributes as Internal
import Designsystemet.Tooltip as Tooltip
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed as Keyed
import Json.Decode as Decode


{-| A tab and the panel it shows.
-}
type Tab a msg
    = Tab
        { value : a
        , label : List (Html msg)
        , panel : List (Html msg)
        , tabAttributes : List (Html.Attribute msg)
        }


{-| A tab with a `label` (what's on the tab itself) and the `panel` it shows.

    Tabs.tab
        { value = Documents
        , label = [ documentIcon, Html.text "Dokumenter" ]
        , panel = [ documentList model.documents ]
        }

-}
tab : { value : a, label : List (Html msg), panel : List (Html msg) } -> Tab a msg
tab { value, label, panel } =
    Tab { value = value, label = label, panel = panel, tabAttributes = [] }


{-| A tab showing only an icon. The label is required, since an icon means
nothing to a screen reader or to someone who doesn't recognise it. It names the
tab and shows as a [tooltip](Designsystemet-Tooltip) on hover and focus.

    Tabs.iconTab
        { value = Cars
        , label = "Dine biler"
        , icon = carIcon
        , panel = [ Html.text "Du har ingen av denne typen registrert hos oss" ]
        }

-}
iconTab : { value : a, label : String, icon : Html msg, panel : List (Html msg) } -> Tab a msg
iconTab { value, label, icon, panel } =
    Tab
        { value = value
        , label = [ icon ]
        , panel = panel
        , tabAttributes = [ Attr.attribute "aria-label" label, Tooltip.content label ]
        }


{-| Tabs the browser switches between. `initial` is the tab open on first
render.

    Tabs.uncontrolled { toId = sectionId, initial = Overview } [] tabs

If `initial` changes later, that tab is opened. Otherwise Elm leaves the tabs
alone.

-}
uncontrolled : { toId : a -> String, initial : a } -> List (Html.Attribute msg) -> List (Tab a msg) -> Html msg
uncontrolled { toId, initial } =
    viewTabs toId initial (\_ -> Internal.none)


{-| Tabs your model switches between. Clicking a tab (or pressing Enter or Space
on it) sends `onSelect` with its value. The open tab changes only when
`selected` does.

    Tabs.controlled
        { toId = sectionId
        , selected = model.section
        , onSelect = SectionSelected
        }
        []
        tabs

-}
controlled : { toId : a -> String, selected : a, onSelect : a -> msg } -> List (Html.Attribute msg) -> List (Tab a msg) -> Html msg
controlled { toId, selected, onSelect } =
    viewTabs toId
        selected
        (\value ->
            if value == selected then
                Internal.none

            else
                -- designsystemet-web skips clicks that are already
                -- defaultPrevented, so the tab only switches when Elm says so.
                Events.preventDefaultOn "click" (Decode.succeed ( onSelect value, True ))
        )


viewTabs : (a -> String) -> a -> (a -> Html.Attribute msg) -> List (Html.Attribute msg) -> List (Tab a msg) -> Html msg
viewTabs toId selected onClick attributes tabs =
    Keyed.node "ds-tabs"
        (Attr.class "ds-tabs" :: attributes)
        (( "ds-tablist"
         , Keyed.node "ds-tablist"
            []
            (List.map (viewTab toId selected onClick) tabs)
         )
            :: List.map (viewPanel toId) tabs
        )


viewTab : (a -> String) -> a -> (a -> Html.Attribute msg) -> Tab a msg -> ( String, Html msg )
viewTab toId selected onClick (Tab { value, label, tabAttributes }) =
    let
        panelId : String
        panelId =
            toId value
    in
    ( panelId
    , Html.node "ds-tab"
        (Attr.attribute "aria-controls" panelId
            :: Attr.attribute "aria-selected"
                (if value == selected then
                    "true"

                 else
                    "false"
                )
            :: Internal.data "value" panelId
            :: Attr.attribute "role" "tab"
            :: onClick value
            :: tabAttributes
        )
        label
    )


viewPanel : (a -> String) -> Tab a msg -> ( String, Html msg )
viewPanel toId (Tab { value, panel }) =
    ( "panel-" ++ toId value
    , Html.node "ds-tabpanel" [ Attr.id (toId value) ] panel
    )
