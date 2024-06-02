module Route.AboutMe exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import Effect
import FatalError
import Head
import Html
import Markdown.Block exposing (Block)
import Markdown.Parser
import MarkdownThemed
import PagesMsg
import ParserUtils
import RouteBuilder
import Shared exposing (Breakpoints(..))
import Ui
import Ui.Font
import Ui.Prose
import Ui.Responsive
import UrlPath
import View


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { data = data, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( {}, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    { description : List Block }


type alias ActionData =
    BackendTask.BackendTask FatalError.FatalError (List RouteParams)


data : BackendTask.BackendTask FatalError.FatalError Data
data =
    let
        descriptionResult =
            Markdown.Parser.parse "I'm Martin Stewart! I like making things, mostly computer programs, and this website is an attempt at keeping track of stuff that I've made. Some of that stuff is [cool](/stuff/circuit-breaker), other stuff is [cringey garbage](/stuff/demon-clutched-walkaround) but worth remembering anyway.\n\nI also like biking, jogging, walking, bouldering, and board games (ordered by velocity).\n\nIf you want to say hello, I'm Martin Stewart on Elm Slack and [MartinS](https://discourse.elm-lang.org/u/martins) on Elm Discourse."
    in
    case descriptionResult of
        Ok description ->
            BackendTask.succeed { description = description }

        Err error ->
            FatalError.fromString (ParserUtils.errorsToString "" error) |> BackendTask.fail


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "About me"
    , body =
        Ui.row
            [ Ui.widthMax 1000, Ui.centerX, Ui.contentTop ]
            [ Ui.el
                [ Ui.width Ui.fill ]
                (Ui.image
                    [ Ui.widthMin 250
                    , Ui.Responsive.visible Shared.breakpoints [ NotMobile ]
                    ]
                    { source = "/about-me.jpg"
                    , description = "A photo of me pretending to steal a bag of money from someone's house"
                    , onLoad = Nothing
                    }
                )
            , Ui.column
                [ Ui.spacing 16
                , Ui.Responsive.paddingXY
                    Shared.breakpoints
                    (\label ->
                        case label of
                            Mobile ->
                                { x = Ui.Responsive.value 0, y = Ui.Responsive.value 16 }

                            NotMobile ->
                                { x = Ui.Responsive.value 0, y = Ui.Responsive.value 32 }
                    )
                , Ui.width Ui.fill
                ]
                [ Ui.el [ Ui.Font.size 32, Ui.Font.bold, Ui.Font.lineHeight 1.1 ] (Ui.text "About me")
                , MarkdownThemed.render app.data.description
                ]
            ]
    }
