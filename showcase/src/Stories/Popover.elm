module Stories.Popover exposing (chapter)

{-| `popover.stories.tsx`, story for story.

React's `Popover.TriggerContext` isn't needed: a `Popover.Id` links the
trigger and the popover. React's `open` is `Popover.open`, kept in step by the
companion script (`js/open-state.js`); `Popover.onToggle` covers
`onOpen` and `onClose`.

-}

import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Paragraph as Paragraph
import Designsystemet.Placement as Placement
import Designsystemet.Popover as Popover
import Designsystemet.Size as Size
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icons
import Showcase.Story as Story exposing (Chapter)
import Stories.Interactive.State exposing (Model, Msg(..))


chapter : Model -> Chapter Msg
chapter model =
    Story.chapter { title = "Popover", module_ = "Stories.Popover", storybook = "komponenter-popover" }
        [ Story.story "Preview" preview
            |> Story.withStoryCustomStyles [ ( "padding-top", "5rem" ) ]
        , Story.story "Interactive" interactive
            |> Story.withStoryCustomStyles [ ( "padding", "12rem 6rem 1rem" ) ]
        , Story.story "DottedUnderline" dottedUnderline
            |> Story.withStoryCustomStyles [ ( "padding", "10rem 6rem 1rem" ) ]
        , Story.story "Variants" variants
            |> Story.withStoryCustomStyles
                [ ( "display", "grid" )
                , ( "grid-template-columns", "repeat(4, 1fr)" )
                , ( "gap", "var(--ds-size-2)" )
                , ( "height", "100%" )
                , ( "width", "100%" )
                , ( "place-items", "center" )
                , ( "padding", "5rem 3rem" )
                ]
        , Story.story "Controlled" (controlled model)
            |> Story.withStoryCustomStyles [ ( "padding", "8rem 6rem 1rem" ) ]
        , Story.story "WithoutContext" (withoutContext model)
            |> Story.withStoryCustomStyles [ ( "padding", "8rem 6rem 1rem" ) ]
        ]
        |> Story.withCustomStyles [ ( "display", "flex" ), ( "place-items", "end" ), ( "place-content", "center" ), ( "padding", "1rem 2rem" ) ]
        |> Story.withLayout Story.Fullscreen


preview : List (Html msg)
preview =
    let
        notifications : Popover.Id
        notifications =
            Popover.id "popover-preview"
    in
    [ Popover.trigger notifications [] [ Html.text "Mine varsler" ]
    , Popover.view notifications [ Popover.placement Placement.Top ] [ Html.text "Du har ingen varsler" ]
    ]


interactive : List (Html msg)
interactive =
    let
        confirmDelete : Popover.Id
        confirmDelete =
            Popover.id "popover-interactive"
    in
    [ Popover.trigger confirmDelete
        [ Ds.color Color.danger, Attr.attribute "aria-label" "Slett rad" ]
        [ Icons.trash [ Attr.attribute "title" "Slett rad" ] ]
    , Popover.view confirmDelete
        [ Ds.color Color.danger ]
        [ Paragraph.view [] [ Html.text "Er du sikker på at du vil slette raden? Handlingen kan ikke angres." ]
        , Html.div [ Attr.style "display" "flex", Attr.style "gap" "var(--ds-size-2)", Attr.style "margin-top" "var(--ds-size-2)" ]
            [ Button.view [ Ds.size Size.sm ] [ Html.text "Ja, slett den" ]
            , Button.view [ Ds.size Size.sm, Button.tertiary ] [ Html.text "Avbryt" ]
            ]
        ]
    ]


dottedUnderline : List (Html msg)
dottedUnderline =
    let
        designTokens : Popover.Id
        designTokens =
            Popover.id "popover-dotted-underline"
    in
    [ Paragraph.view []
        [ Html.text "Vi bruker "
        , Popover.inlineTrigger designTokens [] [ Html.text "design tokens" ]
        , Html.text " for å sikre at vi har en konsistent design."
        ]
    , Popover.view designTokens
        [ Ds.color Color.neutral ]
        [ Paragraph.view []
            [ Html.strong [ Attr.style "display" "block" ] [ Html.text "Design tokens" ]
            , Html.text "Design tokens er en samling av variabler som definerer designet i et designsystem."
            ]
        ]
    ]


{-| All eight are open from the start, like React's: `Popover.open True`. They
are `"manual"` popovers, as React's are, so one opening doesn't close the
others.
-}
variants : List (Html msg)
variants =
    List.concat <|
        List.indexedMap
            (\index ( name, color, variant ) ->
                let
                    popover : Popover.Id
                    popover =
                        Popover.id ("popover-variant-" ++ name)
                in
                [ Popover.trigger popover [] [ Html.text "popover" ]
                , Popover.view popover
                    (Attr.attribute "popover" "manual"
                        :: Popover.open True
                        :: Popover.placement
                            (if index >= 4 then
                                Placement.Bottom

                             else
                                Placement.Top
                            )
                        :: Ds.color color
                        :: variant
                    )
                    [ Html.text name ]
                ]
            )
            [ ( "neutralDefault", Color.neutral, [] )
            , ( "neutralTinted", Color.neutral, [ Popover.tinted ] )
            , ( "dangerDefault", Color.danger, [] )
            , ( "dangerTinted", Color.danger, [ Popover.tinted ] )
            , ( "infoDefault", Color.info, [] )
            , ( "infoTinted", Color.info, [ Popover.tinted ] )
            , ( "warningDefault", Color.warning, [] )
            , ( "warningTinted", Color.warning, [ Popover.tinted ] )
            ]


controlled : Model -> List (Html Msg)
controlled model =
    let
        confirmDelete : Popover.Id
        confirmDelete =
            Popover.id "popover-controlled"
    in
    [ Popover.trigger confirmDelete [] [ Html.text "Slett" ]
    , Popover.view confirmDelete
        [ Popover.open model.popoverOpen
        , Popover.onToggle (\state -> PopoverOpenChanged (state == Popover.Open))
        , Ds.color Color.neutral
        ]
        [ Paragraph.view [] [ Html.text "Er du sikker på at du vil slette?" ]
        , Html.div [ Attr.style "display" "flex", Attr.style "gap" "var(--ds-size-2)", Attr.style "margin-top" "var(--ds-size-2)" ]
            [ Button.view [ Ds.color Color.danger, Events.onClick (PopoverOpenChanged False), Ds.size Size.sm ]
                [ Html.text "Slett" ]
            , Button.view [ Button.tertiary, Ds.color Color.danger, Events.onClick (PopoverOpenChanged False), Ds.size Size.sm ]
                [ Html.text "Avbryt" ]
            ]
        ]
    ]


withoutContext : Model -> List (Html Msg)
withoutContext model =
    let
        myPopover : Popover.Id
        myPopover =
            Popover.id "my-popover"
    in
    -- Any button opens a popover with the invoker attributes.
    [ Button.view (Popover.toggle myPopover) [ Html.text "My trigger" ]
    , Popover.view myPopover
        [ Popover.open model.popoverWithoutContextOpen
        , Popover.onToggle (\state -> PopoverWithoutContextOpenChanged (state == Popover.Open))
        , Ds.color Color.neutral
        ]
        [ Paragraph.view [] [ Html.text "Er du sikker på at du vil slette?" ]
        , Button.view
            [ Ds.color Color.danger
            , Events.onClick (PopoverWithoutContextOpenChanged False)
            , Ds.size Size.sm
            , Attr.style "margin-top" "var(--ds-size-2)"
            ]
            [ Html.text "Slett" ]
        ]
    ]
