module Showcase.Story exposing
    ( Chapter
    , CustomStyles
    , Layout(..)
    , Story
    , chapter
    , layout
    , map
    , rootStyles
    , story
    , withCustomStyles
    , withLayout
    , withStoryCustomStyles
    , withStoryLayout
    )

{-| The showcase mirrors upstream Storybook story for story.

A chapter is one React `*.stories.tsx` file; a story is one of its exports.
Give the story the React export name (`"ColorsHover"`), and define it in the
chapter's module as a function named the same in lower camel case
(`colorsHover`). The build reads that function's source and shows it under the
story, and links the story to its React twin on storybook.designsystemet.no.

    chapter : Chapter msg
    chapter =
        Story.chapter { title = "Button", module_ = "Stories.Button", storybook = "komponenter-button" }
            [ Story.story "Preview" preview
            , Story.story "Variants" variants
            ]

The two Storybook parameters that decide how a story sits on the page are
mirrored too: `layout` (see [`Layout`](#Layout)) and `customStyles` (see
[`CustomStyles`](#CustomStyles)). Set them where upstream sets them: on the
chapter for the `meta`, on the story for the story.

-}

import Html exposing (Html)


{-| Upstream's `parameters.layout`: where the story root sits in the canvas.
The showcase default is upstream's global default, `Centered`.

  - `Centered`: the root shrinks to its content and is centered.
  - `Padded`: the root fills the width, with padding around it.
  - `Fullscreen`: the root fills the canvas.

-}
type Layout
    = Centered
    | Padded
    | Fullscreen


{-| CSS for the story root, as `( property, value )` pairs: the Elm version of
upstream's `parameters.customStyles`. Use the upstream values as they are
(`( "display", "flex" ), ( "gap", "var(--ds-size-4)" )`), with CSS property
names (`align-items`, not `alignItems`).
-}
type alias CustomStyles =
    List ( String, String )


type alias Story msg =
    { name : String
    , layout : Maybe Layout
    , customStyles : CustomStyles
    , view : List (Html msg)
    }


type alias Chapter msg =
    { title : String
    , module_ : String
    , storybook : String
    , layout : Layout
    , customStyles : CustomStyles
    , stories : List (Story msg)
    }


{-| A chapter. `storybook` is the Storybook id prefix of the React stories,
`komponenter-button` for `title: 'Komponenter/Button'`.
-}
chapter : { title : String, module_ : String, storybook : String } -> List (Story msg) -> Chapter msg
chapter config stories =
    { title = config.title
    , module_ = config.module_
    , storybook = config.storybook
    , layout = Centered
    , customStyles = []
    , stories = stories
    }


{-| The meta-level `layout`.
-}
withLayout : Layout -> Chapter msg -> Chapter msg
withLayout l c =
    { c | layout = l }


{-| The meta-level `customStyles`: they apply to every story in the chapter.
-}
withCustomStyles : CustomStyles -> Chapter msg -> Chapter msg
withCustomStyles styles c =
    { c | customStyles = styles }


{-| A story, named exactly like the React story export. React stories return
fragments (`<>…</>`); the Elm equivalent is a list.
-}
story : String -> List (Html msg) -> Story msg
story name view =
    { name = name, layout = Nothing, customStyles = [], view = view }


{-| A story-level `layout`, overriding the chapter's.
-}
withStoryLayout : Layout -> Story msg -> Story msg
withStoryLayout l s =
    { s | layout = Just l }


{-| Story-level `customStyles`. Like Storybook, they are merged over the
chapter's: a property set here wins.
-}
withStoryCustomStyles : CustomStyles -> Story msg -> Story msg
withStoryCustomStyles styles s =
    { s | customStyles = styles }


{-| The layout a story is shown in: its own, or its chapter's.
-}
layout : Chapter msg -> Story msg -> Layout
layout c s =
    Maybe.withDefault c.layout s.layout


{-| The styles of a story's root: upstream's decorator defaults, then the
chapter's `customStyles`, then the story's.
-}
rootStyles : Chapter msg -> Story msg -> CustomStyles
rootStyles c s =
    let
        overriddenBy : CustomStyles -> CustomStyles -> CustomStyles
        overriddenBy later earlier =
            List.filter (\( property, _ ) -> not (List.any (\( p, _ ) -> p == property) later)) earlier ++ later
    in
    [ ( "box-sizing", "border-box" ), ( "overflow", "hidden" ), ( "padding", "1rem" ) ]
        |> overriddenBy c.customStyles
        |> overriddenBy s.customStyles


map : (a -> b) -> Chapter a -> Chapter b
map f c =
    { title = c.title
    , module_ = c.module_
    , storybook = c.storybook
    , layout = c.layout
    , customStyles = c.customStyles
    , stories =
        List.map
            (\s -> { name = s.name, layout = s.layout, customStyles = s.customStyles, view = List.map (Html.map f) s.view })
            c.stories
    }
