module View exposing (View, map)

{-|

@docs View, map

-}

import Html exposing (Html)
import Ui


{-| -}
type alias View msg =
    { title : String
    , body : Ui.Element msg
    , overlay : Html msg
    }


{-| -}
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = Ui.map fn doc.body
    , overlay = Html.map fn doc.overlay
    }
