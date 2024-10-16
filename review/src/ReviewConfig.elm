module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Variables
import Review.Rule exposing (Rule)
import Simplify


config : List Rule
config =
    [ NoUnused.Exports.rule

    --, NoUnused.Dependencies.rule
    , NoUnused.Modules.rule
    , NoUnused.Variables.rule
    , NoUnused.Parameters.rule
    , NoUnused.CustomTypeConstructors.rule []
    , NoUnused.CustomTypeConstructorArgs.rule
    , Simplify.rule Simplify.defaults
    ]
        |> List.map (Review.Rule.ignoreErrorsForDirectories [ "vendored", "script", ".elm-pages" ])
