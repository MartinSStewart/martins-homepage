module Route.Stuff.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Date
import Dict
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import MarkdownThemed
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Things exposing (Thing)
import Ui
import Ui.Font
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { slug : String }


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    BackendTask.succeed
        (List.map
            (\( name, _ ) -> { slug = name })
            (Dict.toList Things.thingsIHaveDone)
        )


type alias Data =
    Thing


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    case Dict.get routeParams.slug Things.thingsIHaveDone of
        Just thing ->
            BackendTask.succeed thing

        Nothing ->
            BackendTask.fail (FatalError.fromString "Page not found")


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Martin's homepage"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = app.data.description
        , locale = Nothing
        , title = app.data.name
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app sharedModel =
    let
        thing =
            app.data
    in
    { title = thing.name
    , body =
        Ui.column
            [ Ui.padding 16 ]
            [ Ui.el [ Ui.Font.size 36 ] (Ui.text thing.name)
            , Ui.text ("Last updated at " ++ Date.toIsoString thing.pageLastUpdated)
            , if app.data.description == "" then
                Ui.text "TODO"

              else
                MarkdownThemed.renderFull thing.description
            ]
    }
