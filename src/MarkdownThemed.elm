module MarkdownThemed exposing (render)

import Html
import Html.Attributes
import Markdown.Block exposing (Block, HeadingLevel(..), ListItem(..))
import Markdown.Html
import Markdown.Renderer
import SyntaxHighlight
import Ui exposing (Element)
import Ui.Accessibility
import Ui.Font
import Ui.Prose


render : List Block -> Ui.Element msg
render blocks =
    case Markdown.Renderer.render renderer blocks of
        Ok elements ->
            Ui.column
                [ Ui.spacing 20
                , SyntaxHighlight.useTheme SyntaxHighlight.gitHub
                    |> Ui.html
                    |> Ui.behindContent
                ]
                elements

        Err _ ->
            Ui.none


renderer : Markdown.Renderer.Renderer (Element msg)
renderer =
    { heading = \data -> Ui.row [ Ui.width Ui.shrink ] [ heading data ]
    , paragraph = \children -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.paddingXY 0 10 ] children
    , blockQuote =
        \children ->
            Ui.column
                [ Ui.width Ui.shrink
                , Ui.Font.size 20
                , Ui.Font.italic
                , Ui.borderWith { bottom = 0, left = 4, right = 0, top = 0 }
                , Ui.borderColor theme.grey
                , Ui.Font.color theme.mutedText
                , Ui.padding 10
                ]
                children
    , html = Markdown.Html.oneOf []
    , text = \s -> Ui.el [ Ui.width Ui.shrink, Ui.Font.size 18 ] (Ui.text s)
    , codeSpan =
        \content ->
            if String.startsWith "elm " content then
                case SyntaxHighlight.elm (String.dropLeft 4 content) of
                    Ok ok ->
                        SyntaxHighlight.toInlineHtml ok
                            |> Ui.html
                            |> Ui.el [ Ui.Font.size 18 ]

                    Err _ ->
                        Ui.el
                            [ Ui.Font.family [ Ui.Font.monospace ]
                            , Ui.Font.size 18
                            ]
                            (Ui.text content)

            else
                Ui.el
                    [ Ui.Font.family [ Ui.Font.monospace ]
                    , Ui.Font.size 18
                    ]
                    (Ui.text content)
    , strong = \list -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.bold ] list
    , emphasis = \list -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.italic ] list
    , hardLineBreak = Ui.html (Html.br [] [])
    , link =
        \{ title, destination } list ->
            Ui.Prose.paragraph
                [ Ui.link destination
                , Ui.Font.underline
                , Ui.Font.color theme.link
                ]
                (case title of
                    Maybe.Just title_ ->
                        [ Ui.text title_ ]

                    Maybe.Nothing ->
                        list
                )
    , image =
        \{ alt, src, title } ->
            Ui.image
                (case title of
                    Just title2 ->
                        [ Ui.htmlAttribute (Html.Attributes.attribute "title" title2) ]

                    Nothing ->
                        []
                )
                { source = src, description = alt, onLoad = Nothing }
    , unorderedList =
        \items ->
            Ui.column
                [ Ui.spacing 15 ]
                (List.map
                    (\listItem ->
                        case listItem of
                            ListItem _ children ->
                                Ui.row
                                    [ Ui.spacing 5
                                    , Ui.paddingWith { top = 0, right = 0, bottom = 0, left = 20 }
                                    , Ui.wrap
                                    ]
                                    [ Ui.Prose.paragraph
                                        [ Ui.width Ui.shrink, Ui.alignTop ]
                                        (Ui.text " • " :: children)
                                    ]
                    )
                    items
                )
    , orderedList =
        \startingIndex items ->
            Ui.column
                [ Ui.spacing 15 ]
                (List.indexedMap
                    (\index itemBlocks ->
                        Ui.row
                            [ Ui.spacing 5
                            , Ui.paddingWith { top = 0, right = 0, bottom = 0, left = 20 }
                            , Ui.wrap
                            ]
                            [ Ui.Prose.paragraph
                                [ Ui.width Ui.shrink, Ui.alignTop ]
                                (Ui.text (String.fromInt (startingIndex + index) ++ ". ") :: itemBlocks)
                            ]
                    )
                    items
                )
    , codeBlock =
        \{ body, language } ->
            case SyntaxHighlight.elm body of
                Ok ok ->
                    SyntaxHighlight.toBlockHtml Nothing ok
                        |> Ui.html
                        |> Ui.el [ Ui.Font.size 18 ]

                --Ui.column
                --    [ Ui.Font.family [ Ui.Font.monospace ]
                --    , Ui.background theme.lightGrey
                --    , Ui.rounded 5
                --    , Ui.padding 10
                --    , Ui.htmlAttribute (Html.Attributes.style "white-space" "pre-wrap")
                --    , Ui.scrollableX
                --    ]
                --    [ Ui.html (Html.text body) ]
                Err _ ->
                    Ui.text body
    , thematicBreak = Ui.none
    , table = \children -> Ui.column [] children
    , tableHeader = \children -> Ui.column [ Ui.width Ui.shrink ] children
    , tableBody = \children -> Ui.column [ Ui.width Ui.shrink ] children
    , tableRow = \children -> Ui.row [] children
    , tableCell = \_ children -> Ui.column [] children
    , tableHeaderCell = \_ children -> Ui.column [] children
    , strikethrough = \children -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.strike ] children
    }


theme =
    { defaultText = Ui.rgb 0 0 0
    , mutedText = Ui.rgb 100 100 100
    , link = Ui.rgb 20 100 255
    , lightGrey = Ui.rgb 200 200 200
    , grey = Ui.rgb 180 180 180
    }


heading : { level : HeadingLevel, rawText : String, children : List (Element msg) } -> Ui.Element msg
heading { level, rawText, children } =
    Ui.Prose.paragraph
        -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
        ((case level of
            H1 ->
                [ Ui.Accessibility.h1
                , Ui.Font.size 28
                , Ui.Font.bold
                , Ui.Font.color theme.defaultText
                , Ui.paddingXY 0 20
                ]

            H2 ->
                [ Ui.Accessibility.h2
                , Ui.Font.color theme.defaultText
                , Ui.Font.size 20
                , Ui.Font.bold
                , Ui.paddingWith { top = 50, right = 0, bottom = 20, left = 0 }
                ]

            H3 ->
                [ Ui.Accessibility.h3
                , Ui.Font.color theme.defaultText
                , Ui.Font.size 18
                , Ui.Font.bold
                , Ui.paddingWith { top = 30, right = 0, bottom = 10, left = 0 }
                ]

            H4 ->
                [ Ui.Accessibility.h4
                , Ui.Font.color theme.defaultText
                , Ui.Font.size 16
                , Ui.Font.bold
                , Ui.paddingWith { top = 0, right = 0, bottom = 10, left = 0 }
                ]

            H5 ->
                [ Ui.Accessibility.h5
                , Ui.Font.size 12
                , Ui.Font.bold
                , Ui.Font.center
                , Ui.paddingXY 0 20
                ]

            H6 ->
                [ Ui.Accessibility.h6
                , Ui.Font.size 12
                , Ui.Font.bold
                , Ui.Font.center
                , Ui.paddingXY 0 20
                ]
         )
            ++ [ Ui.htmlAttribute
                    (Html.Attributes.attribute "name" (rawTextToId rawText))
               , Ui.htmlAttribute
                    (Html.Attributes.id (rawTextToId rawText))
               ]
        )
        children


rawTextToId : String -> String
rawTextToId rawText =
    rawText
        |> String.toLower
        |> String.replace " " "-"
        |> String.replace "." ""
