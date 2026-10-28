module Stories.Interactive exposing (Model, Msg, chapters, init, update)

{-| The interactive chapters, and the state their interactive stories need.

The `Model` and `Msg` live in `Stories.Interactive.State`, so the story
modules can use the messages directly; this module updates them.

-}

import Showcase.Story exposing (Chapter)
import Stories.Breadcrumbs
import Stories.Chip
import Stories.Details
import Stories.Dialog
import Stories.Dropdown
import Stories.Interactive.State as State exposing (Company(..), Msg(..))
import Stories.Pagination
import Stories.Popover
import Stories.SkipLink
import Stories.Tabs
import Stories.ToggleGroup
import Stories.Tooltip


type alias Model =
    State.Model


type alias Msg =
    State.Msg


init : Model
init =
    State.init


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ignored ->
            ( model, Cmd.none )

        DialogOpenToggled ->
            ( { model | dialogOpen = not model.dialogOpen }, Cmd.none )

        DialogClosed ->
            ( { model | dialogOpen = False }, Cmd.none )

        DialogFormNameChanged name ->
            ( { model | dialogFormName = name }, Cmd.none )

        DialogFormSubmitted ->
            ( { model | dialogFormSubmitted = Just model.dialogFormName }, Cmd.none )

        DialogFormClosed ->
            ( { model | dialogFormName = "" }, Cmd.none )

        DestinationSelected destination ->
            ( { model | dialogDestination = destination }, Cmd.none )

        PopoverOpenChanged open ->
            ( { model | popoverOpen = open }, Cmd.none )

        PopoverWithoutContextOpenChanged open ->
            ( { model | popoverWithoutContextOpen = open }, Cmd.none )

        DropdownOpenChanged open ->
            ( { model | dropdownOpen = open }, Cmd.none )

        DropdownExternalOpenChanged open ->
            ( { model | dropdownExternalOpen = open }, Cmd.none )

        Copied ->
            ( { model | tooltipCopied = True }, Cmd.none )

        CopyButtonBlurred ->
            ( { model | tooltipCopied = False }, Cmd.none )

        TabSelected value ->
            ( { model | controlledTab = value }, Cmd.none )

        FolderSelected folder ->
            ( { model | folder = folder }, Cmd.none )

        CompanyToggled company open ->
            ( { model
                | openCompanies =
                    if open then
                        company :: List.filter ((/=) company) model.openCompanies

                    else
                        List.filter ((/=) company) model.openCompanies
              }
            , Cmd.none
            )

        AllCompaniesToggled open ->
            ( { model
                | openCompanies =
                    if open then
                        [ SoleProprietorship, LimitedCompany, Partnership ]

                    else
                        []
              }
            , Cmd.none
            )

        PageSelected page ->
            ( { model | paginationPage = page }, Cmd.none )

        MobilePageSelected page ->
            ( { model | mobilePaginationPage = page }, Cmd.none )


chapters : Model -> List (Chapter Msg)
chapters model =
    [ Stories.Dialog.chapter model
    , Stories.Popover.chapter model
    , Stories.Dropdown.chapter model
    , Stories.Tooltip.chapter model
    , Stories.Tabs.chapter model
    , Stories.ToggleGroup.chapter model
    , Stories.Pagination.chapter model
    , Stories.Breadcrumbs.chapter
    , Stories.Details.chapter model
    , Stories.SkipLink.chapter
    , Stories.Chip.chapter
    ]
