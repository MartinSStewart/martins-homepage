module Icons exposing (..)

import Html.Attributes
import Phosphor
import Ui


externaLink =
    Phosphor.arrowSquareOut Phosphor.Regular |> Phosphor.toHtml [] |> Ui.html


externaLinkHtml =
    Phosphor.arrowSquareOut Phosphor.Regular |> Phosphor.withSize (12 / 16) |> Phosphor.toHtml []


downloadHtml =
    Phosphor.download Phosphor.Regular
        |> Phosphor.toHtml
            [ Html.Attributes.style "transform" "translateY(2px)"
            , Html.Attributes.style "padding-left" "2px"
            ]
