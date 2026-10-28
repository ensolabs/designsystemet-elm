module Theme exposing (all, themeColors)

{-| The colors of the default Designsystemet theme the showcase loads.

The pattern the package recommends: the theme's color names live in one
module, so a typo in one can only happen here.

-}

import Designsystemet.Color as Color exposing (Color)


brand1 : Color
brand1 =
    Color.custom "brand1"


brand2 : Color
brand2 =
    Color.custom "brand2"


{-| The theme's main colors, in the order the upstream stories list them.
-}
themeColors : List Color
themeColors =
    [ Color.accent, brand1, brand2, Color.neutral ]


{-| Main colors and severity colors.
-}
all : List Color
all =
    themeColors ++ [ Color.success, Color.warning, Color.danger, Color.info ]
