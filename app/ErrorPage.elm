module ErrorPage exposing (ErrorPage(..), Model, Msg, init, internalError, notFound, statusCode, update, view)

import Html
import Ui
import Ui.Prose
import View exposing (View)


type alias Msg =
    ()


type alias Model =
    { count : Int
    }


init : ErrorPage -> ( Model, Cmd Msg )
init _ =
    ( { count = 0 }
    , Cmd.none
    )


update : ErrorPage -> Msg -> Model -> ( Model, Cmd Msg )
update _ _ model =
    ( model, Cmd.none )


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
view error _ =
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

            InternalError _ ->
                "Unexpected Error"
    , overlay = Html.text ""
    }


statusCode : ErrorPage -> number
statusCode error =
    case error of
        NotFound ->
            404

        InternalError _ ->
            500
