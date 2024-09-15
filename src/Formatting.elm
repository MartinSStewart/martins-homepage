module Formatting exposing (..)

import SyntaxHighlight
import Ui
import Ui.Font
import Ui.Prose


type Formatting
    = Paragraph (List Inline)
    | CodeBlock String
    | BulletList (List Formatting)
    | NumberList (List Formatting)
    | LetterList (List Formatting)
    | Image { source : String, description : String }


type Inline
    = Bold String
    | Italic String
    | Link String String
    | InlineCode String


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
                        |> Ui.el [ Ui.Font.size 18 ]

                Err _ ->
                    Ui.text text

        BulletList formattings ->
            Ui.column
                [ Ui.spacing 16, Ui.paddingLeft 32 ]
                (List.map
                    (\item2 -> Ui.row [] [ Ui.text "* ", viewHelper item2 ])
                    formattings
                )

        NumberList formattings ->
            Ui.column
                [ Ui.spacing 16, Ui.paddingLeft 32 ]
                (List.indexedMap
                    (\index item2 ->
                        Ui.row
                            []
                            [ Ui.text (String.fromInt index ++ ". ")
                            , viewHelper item2
                            ]
                    )
                    formattings
                )

        LetterList formattings ->
            Ui.column
                [ Ui.spacing 16, Ui.paddingLeft 32 ]
                (List.indexedMap
                    (\index item2 ->
                        Ui.row
                            []
                            [ Ui.text (String.fromChar (Char.fromCode (Char.toCode 'A' + index)) ++ ". ")
                            , viewHelper item2
                            ]
                    )
                    formattings
                )

        Image a ->
            Ui.image [] { source = a.source, description = a.description, onLoad = Nothing }


inlineView : Inline -> Ui.Element msg
inlineView inline =
    case inline of
        Bold text ->
            Ui.el [ Ui.Font.bold ] (Ui.text text)

        Italic text ->
            Ui.el [ Ui.Font.italic ] (Ui.text text)

        Link url text ->
            Ui.el [ Ui.link url, Ui.Font.color (Ui.rgb 20 100 255) ] (Ui.text text)

        InlineCode text ->
            case SyntaxHighlight.elm (String.dropLeft 4 text) of
                Ok ok ->
                    SyntaxHighlight.toInlineHtml ok
                        |> Ui.html
                        |> Ui.el [ Ui.Font.size 18 ]

                Err _ ->
                    Ui.el
                        [ Ui.Font.family [ Ui.Font.monospace ]
                        , Ui.Font.size 18
                        ]
                        (Ui.text text)
