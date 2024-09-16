module Icons exposing (..)

import Phosphor
import Ui


externaLink =
    Phosphor.arrowSquareOut Phosphor.Regular |> Phosphor.toHtml [] |> Ui.html
