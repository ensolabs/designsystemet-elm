module Stories.Interactive.State exposing
    ( Company(..)
    , Folder(..)
    , Model
    , Msg(..)
    , TabValue(..)
    , folderToString
    , init
    , tabValueToId
    )

{-| The state of the interactive stories, in its own module so the story
modules can use the messages directly, the way an app's pages would.

`Stories.Interactive` owns `update` and lists the chapters.

-}

-- MODEL


type alias Model =
    { dialogOpen : Bool
    , dialogFormName : String
    , dialogFormSubmitted : Maybe String
    , dialogDestination : Maybe String
    , popoverOpen : Bool
    , popoverWithoutContextOpen : Bool
    , dropdownOpen : Bool
    , dropdownExternalOpen : Bool
    , tooltipCopied : Bool
    , controlledTab : TabValue
    , folder : Folder
    , openCompanies : List Company
    , paginationPage : Int
    , mobilePaginationPage : Int
    }


init : Model
init =
    { dialogOpen = False
    , dialogFormName = ""
    , dialogFormSubmitted = Nothing
    , dialogDestination = Nothing
    , popoverOpen = False
    , popoverWithoutContextOpen = False
    , dropdownOpen = False
    , dropdownExternalOpen = False
    , tooltipCopied = False
    , controlledTab = Value1
    , folder = Drafts
    , openCompanies = []
    , paginationPage = 2
    , mobilePaginationPage = 3
    }



-- MSG


type Msg
    = Ignored
      -- Dialog
    | DialogOpenToggled
    | DialogClosed
    | DialogFormNameChanged String
    | DialogFormSubmitted
    | DialogFormClosed
    | DestinationSelected (Maybe String)
      -- Popover
    | PopoverOpenChanged Bool
    | PopoverWithoutContextOpenChanged Bool
      -- Dropdown
    | DropdownOpenChanged Bool
    | DropdownExternalOpenChanged Bool
      -- Tooltip
    | Copied
    | CopyButtonBlurred
      -- Tabs
    | TabSelected TabValue
      -- ToggleGroup
    | FolderSelected Folder
      -- Details
    | CompanyToggled Company Bool
    | AllCompaniesToggled Bool
      -- Pagination
    | PageSelected Int
    | MobilePageSelected Int



-- VALUES


type Folder
    = Inbox
    | Drafts
    | Archive
    | Sent


folderToString : Folder -> String
folderToString folder =
    case folder of
        Inbox ->
            "innboks"

        Drafts ->
            "utkast"

        Archive ->
            "arkiv"

        Sent ->
            "sendt"


type TabValue
    = Value1
    | Value2
    | Value3


tabValueToId : TabValue -> String
tabValueToId value =
    case value of
        Value1 ->
            "tabs-controlled-value1"

        Value2 ->
            "tabs-controlled-value2"

        Value3 ->
            "tabs-controlled-value3"


type Company
    = SoleProprietorship
    | LimitedCompany
    | Partnership
