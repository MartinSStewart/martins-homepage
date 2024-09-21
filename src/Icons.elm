module Icons exposing (..)

import Phosphor
import Ui


externaLink =
    Phosphor.arrowSquareOut Phosphor.Regular |> Phosphor.toHtml [] |> Ui.html


externaLinkHtml =
    Phosphor.arrowSquareOut Phosphor.Regular |> Phosphor.toHtml []
