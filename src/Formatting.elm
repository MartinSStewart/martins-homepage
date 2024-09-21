module Formatting exposing (..)

import Icons
import Route exposing (Route)
import SyntaxHighlight
import Ui
import Ui.Font
import Ui.Prose


type Formatting
    = Paragraph (List Inline)
    | CodeBlock String
    | BulletList (List Inline) (List (List Formatting))
    | NumberList (List Inline) (List (List Formatting))
    | LetterList (List Inline) (List (List Formatting))
    | Image { source : String, description : String }
    | SimpleParagraph String


type Inline
    = Bold String
    | Italic String
    | Link String Route
    | InlineCode String
    | Text String
    | ExternalLink String String


view : List Formatting -> Ui.Element msg
view list =
    Ui.column
        [ Ui.spacing 32 ]
        (List.map viewHelper list)


viewHelper : Formatting -> Ui.Element msg
viewHelper item =
    case item of
        Paragraph items ->
            Ui.Prose.paragraph [] (List.map inlineView items)

        CodeBlock text ->
            case SyntaxHighlight.elm text of
                Ok ok ->
                    SyntaxHighlight.toBlockHtml Nothing ok
                        |> Ui.html
                        |> Ui.el
                            [ codeBackground
                            , codeBorder
                            , Ui.border 1
                            , Ui.rounded 4
                            , Ui.paddingXY 8 0
                            ]

                Err _ ->
                    Ui.text text

        BulletList leading formattings ->
            listHelper (\_ -> "•") leading formattings

        NumberList leading formattings ->
            listHelper (\index -> String.fromInt (index + 1) ++ ".") leading formattings

        LetterList leading formattings ->
            listHelper
                (\index -> String.fromChar (Char.fromCode (Char.toCode 'A' + index)) ++ ".")
                leading
                formattings

        Image a ->
            Ui.image [] { source = a.source, description = a.description, onLoad = Nothing }

        SimpleParagraph text ->
            Ui.text text


listHelper : (Int -> String) -> List Inline -> List (List Formatting) -> Ui.Element msg
listHelper iconFunc leading formattings =
    Ui.column
        [ Ui.spacing 12 ]
        [ Ui.Prose.paragraph [] (List.map inlineView leading)
        , Ui.column
            [ Ui.spacing 12, Ui.paddingLeft 4 ]
            (List.indexedMap
                (\index item2 ->
                    Ui.row
                        [ Ui.spacing 6 ]
                        [ Ui.el
                            [ Ui.alignTop, Ui.width Ui.shrink, Ui.Font.bold ]
                            (Ui.text (iconFunc index))
                        , view item2
                        ]
                )
                formattings
            )
        ]


inlineView : Inline -> Ui.Element msg
inlineView inline =
    case inline of
        Bold text ->
            Ui.el [ Ui.Font.bold ] (Ui.text text)

        Italic text ->
            Ui.el [ Ui.Font.italic ] (Ui.text text)

        Link text url ->
            Ui.el [ Ui.link (Route.toString url), Ui.Font.color (Ui.rgb 20 100 255) ] (Ui.text text)

        InlineCode text ->
            case SyntaxHighlight.elm text of
                Ok ok ->
                    SyntaxHighlight.toInlineHtml ok
                        |> Ui.html
                        |> Ui.el
                            [ codeBackground
                            , codeBorder
                            , Ui.border 1
                            , Ui.rounded 4
                            , Ui.paddingXY 4 0
                            , Ui.width Ui.shrink
                            ]

                Err _ ->
                    Ui.el
                        [ Ui.Font.family [ Ui.Font.monospace ]
                        , Ui.width Ui.shrink
                        ]
                        (Ui.text text)

        Text text ->
            Ui.text text

        ExternalLink text url ->
            externalLink 16 text url


externalLink : Int -> String -> String -> Ui.Element msg
externalLink fontSize text url =
    Ui.row
        [ Ui.linkNewTab ("https://" ++ url)
        , Ui.Font.color (Ui.rgb 20 100 255)
        , Ui.Font.size fontSize
        ]
        [ Ui.text text
        , Ui.el [ Ui.Font.size (round (toFloat fontSize * 12 / 16)), Ui.paddingLeft 2 ] Icons.externaLink
        ]


codeBackground =
    Ui.background (Ui.rgb 240 240 240)


codeBorder =
    Ui.borderColor (Ui.rgb 210 210 210)
