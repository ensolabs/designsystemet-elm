module Stories.Display exposing (Model, Msg, chapters, init, update)

{-| The display chapters, and the state their interactive stories need.

Stateless chapters are listed in `chapters`. A chapter with interactive
stories has its own `Model`, `Msg` and `update` in its module; this module
keeps one field and one `Msg` variant per such chapter.

-}

import Showcase.Story as Story exposing (Chapter)
import Stories.Alert
import Stories.Avatar
import Stories.AvatarStack
import Stories.Badge
import Stories.Card
import Stories.Divider
import Stories.Heading
import Stories.Link
import Stories.List
import Stories.Paragraph
import Stories.Skeleton
import Stories.Spinner
import Stories.Table
import Stories.Tag
import Stories.Typography


type alias Model =
    { alert : Stories.Alert.Model
    , avatarStack : Stories.AvatarStack.Model
    , table : Stories.Table.Model
    , typography : Stories.Typography.Model
    }


type Msg
    = AlertMsg Stories.Alert.Msg
    | AvatarStackMsg Stories.AvatarStack.Msg
    | TableMsg Stories.Table.Msg
    | TypographyMsg Stories.Typography.Msg


init : Model
init =
    { alert = Stories.Alert.init
    , avatarStack = Stories.AvatarStack.init
    , table = Stories.Table.init
    , typography = Stories.Typography.init
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AlertMsg alertMsg ->
            ( { model | alert = Stories.Alert.update alertMsg model.alert }, Cmd.none )

        AvatarStackMsg avatarStackMsg ->
            ( { model | avatarStack = Stories.AvatarStack.update avatarStackMsg model.avatarStack }, Cmd.none )

        TableMsg tableMsg ->
            ( { model | table = Stories.Table.update tableMsg model.table }, Cmd.none )

        TypographyMsg typographyMsg ->
            ( { model | typography = Stories.Typography.update typographyMsg model.typography }, Cmd.none )


chapters : Model -> List (Chapter Msg)
chapters model =
    [ Story.map AlertMsg (Stories.Alert.chapter model.alert)
    , Stories.Avatar.chapter
    , Story.map AvatarStackMsg (Stories.AvatarStack.chapter model.avatarStack)
    , Stories.Badge.chapter
    , Stories.Card.chapter
    , Stories.Divider.chapter
    , Stories.Heading.chapter
    , Stories.Link.chapter
    , Stories.List.chapter
    , Stories.Paragraph.chapter
    , Stories.Skeleton.chapter
    , Stories.Spinner.chapter
    , Story.map TableMsg (Stories.Table.chapter model.table)
    , Stories.Tag.chapter
    , Story.map TypographyMsg (Stories.Typography.chapter model.typography)
    ]
