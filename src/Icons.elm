module Icons exposing
    ( chevronLeft
    , chevronRight
    , downloadHtml
    , externaLink
    , externaLinkHtml
    )

import Html exposing (Html)
import Html.Attributes
import Phosphor
import Svg
import Svg.Attributes
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


chevronLeft : Html msg
chevronLeft =
    Svg.svg [ Svg.Attributes.fill "none", Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.strokeWidth "1.5", Svg.Attributes.stroke "currentColor" ]
        [ Svg.path
            [ Svg.Attributes.strokeLinecap "round"
            , Svg.Attributes.strokeLinejoin "round"
            , Svg.Attributes.d "M15.75 19.5 8.25 12l7.5-7.5"
            ]
            []
        ]


chevronRight : Html msg
chevronRight =
    Svg.svg [ Svg.Attributes.fill "none", Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.strokeWidth "1.5", Svg.Attributes.stroke "currentColor" ] [ Svg.path [ Svg.Attributes.strokeLinecap "round", Svg.Attributes.strokeLinejoin "round", Svg.Attributes.d "m8.25 4.5 7.5 7.5-7.5 7.5" ] [] ]
