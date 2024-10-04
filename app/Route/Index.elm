module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App)
import Shared exposing (Breakpoints(..))
import Ui
import UrlPath
import View exposing (View)


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithLocalState
            { init = init
            , update = update
            , view = view
            , subscriptions = \_ _ _ _ -> Sub.none
            }


init : App data action routeParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( {}, Cmd.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    ( model, Cmd.none )


data : BackendTask FatalError Data
data =
    BackendTask.succeed {}


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Martin's homepage"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Stuff I've done that I don't want to forget"
        , locale = Nothing
        , title = "elm-pages is running"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view app _ model =
    { title = ""
    , body = Ui.el [ Ui.id "Elm" ] Ui.none
    }
