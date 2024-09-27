module Formatting exposing (Formatting(..), Inline(..), Model, checkFormatting, externalLink, view)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Html.Lazy
import Icons
import Parser exposing ((|.), (|=), Parser)
import Result.Extra
import Route exposing (Route)
import Set exposing (Set)
import SyntaxHighlight
import Ui
import Ui.Font


type Formatting
    = Paragraph (List Inline)
    | CodeBlock String
    | BulletList (List Inline) (List Formatting)
    | NumberList (List Inline) (List Formatting)
    | LetterList (List Inline) (List Formatting)
    | Group (List Formatting)
    | Section String (List Formatting)


type Inline
    = Bold String
    | Italic String
    | Link String Route
    | Code String
    | Code2 String
    | Text String
    | AltText String String
    | ExternalLink String String


type alias Model a =
    { a | selectedAltText : Set String }


view : (String -> msg) -> Model a -> List Formatting -> Ui.Element msg
view onPressAltText model list =
    Html.div
        [ Html.Attributes.style "line-height" "1.5" ]
        (Html.node "style" [] [ Html.text "pre { white-space: pre-wrap; }" ]
            :: SyntaxHighlight.useTheme SyntaxHighlight.gitHub
            :: List.map (viewHelper onPressAltText 0 model) list
        )
        |> Ui.html


codeHighlight : String -> Html msg
codeHighlight string =
    case Parser.run (parser []) string of
        Ok ok ->
            List.map parsedCodeToString ok |> Html.span []

        Err error ->
            Html.text string


type ParsedCode
    = Symbol String
    | ListBracket Char
    | Function String
    | Type2 String
    | Number2 String
    | Text2 String
    | Whitespace String
    | EqualsSign String


checkFormatting : List Formatting -> Result String ()
checkFormatting content =
    Result.Extra.combineMap checkFormattingHelper content |> Result.map (\_ -> ())


checkFormattingHelper : Formatting -> Result String ()
checkFormattingHelper formatting =
    case formatting of
        Paragraph inlines ->
            Result.Extra.combineMap checkInlineFormatting inlines |> Result.map (\_ -> ())

        CodeBlock string ->
            Ok ()

        BulletList inlines content ->
            case ( Result.Extra.combineMap checkInlineFormatting inlines, checkFormatting content ) of
                ( Ok _, Ok _ ) ->
                    Ok ()

                ( Err error, _ ) ->
                    Err error

                ( _, Err error ) ->
                    Err error

        NumberList inlines content ->
            case ( Result.Extra.combineMap checkInlineFormatting inlines, checkFormatting content ) of
                ( Ok _, Ok _ ) ->
                    Ok ()

                ( Err error, _ ) ->
                    Err error

                ( _, Err error ) ->
                    Err error

        LetterList inlines content ->
            case ( Result.Extra.combineMap checkInlineFormatting inlines, checkFormatting content ) of
                ( Ok _, Ok _ ) ->
                    Ok ()

                ( Err error, _ ) ->
                    Err error

                ( _, Err error ) ->
                    Err error

        Group content ->
            checkFormatting content

        Section string content ->
            checkFormatting content


checkInlineFormatting : Inline -> Result String ()
checkInlineFormatting inline =
    case inline of
        Text _ ->
            Ok ()

        Bold _ ->
            Ok ()

        Italic _ ->
            Ok ()

        Link _ route ->
            case route of
                Route.Stuff__Slug_ { slug } ->
                    if String.contains "/" slug then
                        Err ("Stuff route " ++ slug ++ " shouldn't contain /")

                    else
                        Ok ()

                Route.AboutMe ->
                    Ok ()

                Route.Index ->
                    Ok ()

        Code _ ->
            Ok ()

        Code2 _ ->
            Ok ()

        AltText _ _ ->
            Ok ()

        ExternalLink _ string ->
            if String.contains ")" string || String.contains "://" string then
                Err (string ++ " is an invalid url")

            else
                Ok ()


parsedCodeToString : ParsedCode -> Html msg
parsedCodeToString parsedCode =
    case parsedCode of
        Symbol text ->
            Html.span [ Html.Attributes.style "color" "#df5000" ] [ Html.text text ]

        ListBracket char ->
            Html.span [ Html.Attributes.style "color" "#005cc5" ] [ Html.text (String.fromChar char) ]

        Function text ->
            Html.span [ Html.Attributes.style "color" "#24292e" ] [ Html.text text ]

        Type2 text ->
            Html.span [ Html.Attributes.style "color" "#005cc5" ] [ Html.text text ]

        Number2 text ->
            Html.span [ Html.Attributes.style "color" "#005cc5" ] [ Html.text text ]

        Text2 text ->
            Html.span [ Html.Attributes.style "color" "#df5000" ] [ Html.text text ]

        Whitespace text ->
            Html.text text

        EqualsSign text ->
            Html.span [ Html.Attributes.style "color" "#d73a49" ] [ Html.text text ]


appendChar char text =
    String.fromChar char ++ text


parser : List ParsedCode -> Parser (List ParsedCode)
parser parsedSoFar =
    Parser.oneOf
        [ Parser.end |> Parser.map (\() -> List.reverse parsedSoFar)
        , Parser.chompIf (\_ -> True)
            |> Parser.getChompedString
            |> Parser.andThen
                (\text ->
                    case String.toList text of
                        [ char ] ->
                            if Char.isAlpha char then
                                Parser.chompWhile Char.isAlphaNum
                                    |> Parser.getChompedString
                                    |> Parser.andThen
                                        (\text2 ->
                                            (if Char.isLower char then
                                                Function (appendChar char text2) :: parsedSoFar

                                             else
                                                Type2 (appendChar char text2) :: parsedSoFar
                                            )
                                                |> parser
                                        )

                            else if Char.isDigit char then
                                Parser.chompWhile Char.isDigit
                                    |> Parser.getChompedString
                                    |> Parser.andThen (\text3 -> Number2 (appendChar char text3) :: parsedSoFar |> parser)

                            else if char == '"' then
                                parseString
                                    |> Parser.andThen
                                        (\text3 ->
                                            Text2 text3
                                                :: parsedSoFar
                                                |> parser
                                        )

                            else if char == ' ' || char == '\n' || char == '\u{000D}' || char == '\u{00A0}' then
                                Parser.spaces
                                    |> Parser.getChompedString
                                    |> Parser.andThen (\text2 -> Whitespace (appendChar char text2) :: parsedSoFar |> parser)

                            else if char == '[' || char == ']' then
                                parser (ListBracket char :: parsedSoFar)

                            else if char == '=' then
                                Parser.chompWhile (\char2 -> char2 == '=')
                                    |> Parser.getChompedString
                                    |> Parser.andThen (\text2 -> EqualsSign (appendChar char text2) :: parsedSoFar |> parser)

                            else
                                Parser.chompWhile (\char2 -> char2 /= ' ' && char2 /= '"' && not (Char.isAlphaNum char2))
                                    |> Parser.getChompedString
                                    |> Parser.andThen (\text2 -> Symbol (appendChar char text2) :: parsedSoFar |> parser)

                        _ ->
                            Parser.problem "I got a weird unicode token that I don't know how to handle"
                )
        ]


parseString : Parser String
parseString =
    Parser.succeed (\text -> "\"" ++ text ++ "\"")
        |= (Parser.chompWhile (\char -> char /= '"') |> Parser.getChompedString)
        |. Parser.chompIf (\char -> char == '"')


viewHelper : (String -> msg) -> Int -> Model a -> Formatting -> Html msg
viewHelper onPressAltText depth model item =
    case item of
        Paragraph items ->
            Html.p [] (List.map (inlineView onPressAltText model) items)

        CodeBlock text ->
            case SyntaxHighlight.elm text of
                Ok ok ->
                    Html.div
                        [ Html.Attributes.style "border" "1px rgb(210,210,210) solid"
                        , Html.Attributes.style "padding" "0 8px 0px 8px"
                        , Html.Attributes.style "border-radius" "8px"
                        ]
                        [ SyntaxHighlight.toBlockHtml Nothing ok ]

                --|> Ui.html
                --|> Ui.el
                --    [ codeBackground
                --    , codeBorder
                --    , Ui.border 1
                --    , Ui.rounded 4
                --    , Ui.paddingXY 8 0
                --    ]
                Err _ ->
                    Html.text text

        BulletList leading formattings ->
            Html.div
                []
                [ Html.p [] (List.map (inlineView onPressAltText model) leading)
                , Html.ul
                    [ Html.Attributes.style "padding-left" "20px" ]
                    (List.map
                        (\item2 -> Html.li [] [ Html.Lazy.lazy4 viewHelper onPressAltText depth model item2 ])
                        formattings
                    )
                ]

        NumberList leading formattings ->
            Html.div
                []
                [ Html.p [] (List.map (inlineView onPressAltText model) leading)
                , Html.ol
                    [ Html.Attributes.style "padding-left" "20px" ]
                    (List.map
                        (\item2 -> Html.li [] [ Html.Lazy.lazy4 viewHelper onPressAltText depth model item2 ])
                        formattings
                    )
                ]

        LetterList leading formattings ->
            Html.div
                []
                [ Html.p [] (List.map (inlineView onPressAltText model) leading)
                , Html.ol
                    [ Html.Attributes.type_ "A", Html.Attributes.style "padding-left" "20px" ]
                    (List.map
                        (\item2 -> Html.li [] [ Html.Lazy.lazy4 viewHelper onPressAltText depth model item2 ])
                        formattings
                    )
                ]

        Group formattings ->
            Html.div [] (List.map (Html.Lazy.lazy4 viewHelper onPressAltText depth model) formattings)

        Section title formattings ->
            let
                content =
                    List.map (Html.Lazy.lazy4 viewHelper onPressAltText (depth + 1) model) formattings
            in
            case depth of
                0 ->
                    Html.div
                        [ Html.Attributes.style "padding-top" "16px" ]
                        (Html.h2 [] [ Html.text title ] :: content)

                1 ->
                    Html.div
                        []
                        (Html.h3 [] [ Html.text title ] :: content)

                _ ->
                    Html.div
                        []
                        (Html.h4 [] [ Html.text title ] :: content)


inlineView : (String -> msg) -> Model a -> Inline -> Html msg
inlineView onPressAltText model inline =
    case inline of
        Bold text ->
            Html.b [] [ Html.text text ]

        Italic text ->
            Html.i [] [ Html.text text ]

        Link text url ->
            Html.a [ Html.Attributes.href (Route.toString url) ] [ Html.text text ]

        Code text ->
            Html.code
                [ Html.Attributes.style "border" "1px rgb(210,210,210) solid"
                , Html.Attributes.style "padding" "0 4px 1px 4px"
                , Html.Attributes.style "border-radius" "4px"
                , Html.Attributes.style "font-size" "16px"
                ]
                [ codeHighlight text ]

        Code2 text ->
            Html.code
                [ Html.Attributes.style "border" "1px rgb(210,210,210) solid"
                , Html.Attributes.style "padding" "0 4px 1px 4px"
                , Html.Attributes.style "border-radius" "4px"
                , Html.Attributes.style "font-size" "16px"
                ]
                [ Html.text text ]

        Text text ->
            Html.text text

        ExternalLink text url ->
            externalLinkHtml text url

        AltText text altText ->
            let
                showAltText =
                    Set.member altText model.selectedAltText
            in
            Html.span
                (if showAltText then
                    []

                 else
                    [ Html.Attributes.title altText
                    , Html.Events.onClick (onPressAltText altText)
                    , Html.Attributes.style "cursor" "pointer"
                    ]
                )
                (Html.text text
                    :: (if showAltText then
                            [ Html.sup [ Html.Attributes.style "opacity" "0" ] [ Html.text " " ]
                            , Html.span
                                [ Html.Attributes.style "background" "#dff2ff", Html.Attributes.style "padding" "0 2px 2px 2px" ]
                                [ Html.text altText ]
                            ]

                        else
                            [ Html.sup [] [ Html.text "(?)" ] ]
                       )
                )


externalLinkHtml : String -> String -> Html msg
externalLinkHtml text url =
    Html.a
        [ Html.Attributes.href ("https://" ++ url)
        , Html.Attributes.target "_blank"
        , Html.Attributes.rel "noopener noreferrer"
        ]
        [ Html.text text
        , Icons.externaLinkHtml
        ]


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
