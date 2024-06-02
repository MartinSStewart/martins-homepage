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
import Shared
import Ui
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
            Markdown.Parser.parse "I'm Martin Stewart! I like making things, mostly computer programs, and this website is an attempt at keeping track of stuff that I've made. Some of that stuff is cool, other stuff is [cringey garbage](/stuff/demon-clutched-walkaround) but still worth remembering.\n\nIn order the counter-balance against all the time I spend in front of a computer, I also like biking, jogging, walking, bouldering, and board games (ordered by velocity)"
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
    { title = "About me", body = MarkdownThemed.render app.data.description }
