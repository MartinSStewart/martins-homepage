module Route.Stuff.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Date exposing (Date)
import Dict
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Markdown.Block exposing (Block)
import Markdown.Parser
import MarkdownThemed
import Pages.Url
import PagesMsg exposing (PagesMsg)
import ParserUtils
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Things exposing (Tag)
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
    { thing : Thing }


type alias Thing =
    { name : String
    , website : Maybe String
    , repo : Maybe String
    , tags : List Tag
    , description : List Block
    , pageLastUpdated : Date
    , pageCreatedAt : Date
    , releasedAt : Date
    }


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    case Dict.get routeParams.slug Things.thingsIHaveDone of
        Just thing ->
            case Markdown.Parser.parse thing.description of
                Ok description ->
                    BackendTask.succeed
                        { thing =
                            { name = thing.name
                            , website = thing.website
                            , repo = thing.repo
                            , tags = thing.tags
                            , description = description
                            , pageLastUpdated = thing.pageLastUpdated
                            , pageCreatedAt = thing.pageCreatedAt
                            , releasedAt = thing.releasedAt
                            }
                        }

                Err error ->
                    FatalError.fromString (ParserUtils.errorsToString "Things.elm" error) |> BackendTask.fail

        Nothing ->
            BackendTask.fail (FatalError.fromString "Page not found")


head : App Data ActionData RouteParams -> List Head.Tag
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
        , description = ""
        , locale = Nothing
        , title = app.data.thing.name
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app sharedModel =
    let
        thing : Thing
        thing =
            app.data.thing
    in
    { title = thing.name
    , body =
        Ui.column
            [ Ui.padding 16 ]
            [ Ui.el [ Ui.Font.size 36 ] (Ui.text thing.name)
            , Ui.text
                ("Created at "
                    ++ Date.toIsoString thing.pageCreatedAt
                    ++ (if thing.pageLastUpdated == thing.pageCreatedAt then
                            ""

                        else
                            " " ++ "(updated at " ++ Date.toIsoString thing.pageLastUpdated ++ ")"
                       )
                )
            , if List.isEmpty thing.description then
                Ui.text "TODO"

              else
                MarkdownThemed.render thing.description
            ]
    }
