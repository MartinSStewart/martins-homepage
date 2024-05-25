module MarkdownThemed exposing (renderFull)

import Html
import Html.Attributes
import Markdown.Block exposing (HeadingLevel(..), ListItem(..))
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Ui exposing (Element)
import Ui.Accessibility
import Ui.Font
import Ui.Prose


renderFull : String -> Ui.Element msg
renderFull markdownBody =
    render renderer markdownBody |> Result.withDefault (Ui.text "Invalid markdown")


render : Markdown.Renderer.Renderer (Element msg) -> String -> Result String (Ui.Element msg)
render chosenRenderer markdownBody =
    Markdown.Parser.parse markdownBody
        -- @TODO show markdown parsing errors, i.e. malformed html?
        |> Result.withDefault []
        |> (\parsed ->
                parsed
                    |> Markdown.Renderer.render chosenRenderer
                    |> (\res ->
                            case res of
                                Ok elements ->
                                    Ui.column [ Ui.spacing 20 ] elements |> Ok

                                Err err ->
                                    Err err
                       )
           )


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
    , text = \s -> Ui.el [ Ui.width Ui.shrink ] (Ui.text s)
    , codeSpan =
        \content -> Ui.html (Html.code [] [ Html.text content ])
    , strong = \list -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.bold ] list
    , emphasis = \list -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.italic ] list
    , hardLineBreak = Ui.html (Html.br [] [])
    , link =
        \{ title, destination } list ->
            Ui.el
                [ Ui.link destination
                , Ui.Font.underline
                , Ui.Font.color theme.link
                ]
                (case title of
                    Maybe.Just title_ ->
                        Ui.text title_

                    Maybe.Nothing ->
                        Ui.Prose.paragraph [ Ui.width Ui.shrink ] list
                )
    , image =
        \{ alt, src, title } ->
            let
                attrs =
                    [ title |> Maybe.map (\title_ -> Ui.htmlAttribute (Html.Attributes.attribute "title" title_)) ]
                        |> justs
            in
            Ui.image
                -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
                attrs
                { source = src
                , description = alt
                , onLoad = Nothing
                }
    , unorderedList =
        \items ->
            Ui.column [ Ui.spacing 15 ]
                (items
                    |> List.map
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
                )
    , orderedList =
        \startingIndex items ->
            Ui.column [ Ui.spacing 15 ]
                (items
                    |> List.indexedMap
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
                )
    , codeBlock =
        \{ body } ->
            Ui.column
                [ Ui.Font.family [ Ui.Font.monospace ]
                , Ui.background theme.lightGrey
                , Ui.rounded 5
                , Ui.padding 10
                , Ui.htmlAttribute (Html.Attributes.class "preserve-white-space")
                , Ui.scrollableX
                ]
                [ Ui.html (Html.text body)
                ]
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


justs : List (Maybe a) -> List a
justs =
    List.foldl
        (\v acc ->
            case v of
                Just el ->
                    el :: acc

                Nothing ->
                    acc
        )
        []
