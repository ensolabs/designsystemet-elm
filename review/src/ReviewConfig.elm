module ReviewConfig exposing (config)

{-| The app's elm-review rules plus the docs rules a published package needs.
-}

import Docs.NoMissing exposing (exposedModules, onlyExposed)
import Docs.ReviewAtDocs
import Docs.ReviewLinksAndSections
import Docs.UpToDateReadmeLinks
import NoConfusingPrefixOperator
import NoDebug.Log
import NoDebug.TodoOrToString
import NoExposingEverything
import NoImportingEverything
import NoMissingTypeAnnotation
import NoMissingTypeExpose
import NoPrematureLetComputation
import NoSimpleLetBody
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule as Rule exposing (Rule)
import Simplify


config : List Rule
config =
    [ Docs.NoMissing.rule { document = onlyExposed, from = exposedModules }
    , Docs.ReviewAtDocs.rule
    , Docs.ReviewLinksAndSections.rule
    , Docs.UpToDateReadmeLinks.rule
    , NoConfusingPrefixOperator.rule
    , NoDebug.Log.rule
    , NoDebug.TodoOrToString.rule
    , NoExposingEverything.rule
    , NoImportingEverything.rule []
    , NoMissingTypeAnnotation.rule
    , NoMissingTypeExpose.rule
    , NoSimpleLetBody.rule
    , NoPrematureLetComputation.rule
    , Simplify.rule Simplify.defaults
    ]
        ++ ([ NoUnused.CustomTypeConstructors.rule []
            , NoUnused.CustomTypeConstructorArgs.rule
            , NoUnused.Dependencies.rule
            , NoUnused.Exports.rule
            , NoUnused.Parameters.rule
            , NoUnused.Patterns.rule
            , NoUnused.Variables.rule
            ]
                |> List.map (Rule.ignoreErrorsForDirectories [ "tests/", "../tests/" ])
           )
        -- Generated story sources, and an icon set with icons no story uses yet.
        |> List.map (Rule.ignoreErrorsForDirectories [ "src/Generated/" ])
        |> List.map (Rule.ignoreErrorsForFiles [ "src/Icons.elm" ])
        -- From the showcase, ../src is a dependency reviewed on its own.
        |> List.map (Rule.ignoreErrorsForDirectories [ "../src/" ])
