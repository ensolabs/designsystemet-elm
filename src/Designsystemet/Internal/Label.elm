module Designsystemet.Internal.Label exposing (Label(..))

{-| Accessible name of a form control. `Designsystemet` exposes it as an alias:
components can pattern match on it, users go through the constructors.
-}

import Html exposing (Html)


type Label msg
    = Visible (List (Html msg))
    | AriaLabel String
    | LabelledBy String
