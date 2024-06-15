module ErrorPage exposing (ErrorPage(..), Model, Msg, head, init, internalError, notFound, statusCode, update, view)

import Head
import Html exposing (Html)
import Ui
import Ui.Prose
import View exposing (View)


type Msg
    = Increment


type alias Model =
    { count : Int
    }


init : ErrorPage -> ( Model, Cmd Msg )
init errorPage =
    ( { count = 0 }
    , Cmd.none
    )


update : ErrorPage -> Msg -> Model -> ( Model, Cmd Msg )
update errorPage msg model =
    case msg of
        Increment ->
            ( { model | count = model.count + 1 }, Cmd.none )


head : ErrorPage -> List Head.Tag
head errorPage =
    []


type ErrorPage
    = NotFound
    | InternalError String


notFound : ErrorPage
notFound =
    NotFound


internalError : String -> ErrorPage
internalError =
    InternalError


view : ErrorPage -> Model -> View Msg
view error model =
    { body =
        Ui.column
            [ Ui.contentCenterX, Ui.contentCenterY ]
            [ case error of
                NotFound ->
                    Ui.column
                        [ Ui.width Ui.shrink ]
                        [ Ui.text
                            (Ui.Prose.quote "There's a million things I haven't done, but just you wait!")
                        , Ui.el [ Ui.alignRight ] (Ui.text "—Hamilton Musical")
                        ]

                InternalError string ->
                    Ui.text ("Something went wrong.\n" ++ string)
            ]
    , title =
        case error of
            NotFound ->
                "Page Not Found"

            InternalError string ->
                "Unexpected Error"
    }


statusCode : ErrorPage -> number
statusCode error =
    case error of
        NotFound ->
            404

        InternalError _ ->
            500
