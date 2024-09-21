module Route.Stuff.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Date exposing (Date)
import Dict
import FatalError exposing (FatalError)
import Formatting exposing (Formatting)
import Head
import Head.Seo as Seo
import Icons
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared exposing (Breakpoints(..))
import Things exposing (Tag, ThingType(..))
import Ui
import Ui.Font
import Ui.Responsive
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
    BackendTask.succeed (List.map (\name -> { slug = name }) Things.qualityOrder)


type alias Data =
    { thing : Thing }


type alias Thing =
    { name : String
    , website : Maybe String
    , tags : List Tag
    , description : List Formatting
    , pageLastUpdated : Date
    , pageCreatedAt : Date
    , thingType : ThingType
    }


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    case Dict.get routeParams.slug Things.thingsIHaveDone of
        Just thing ->
            BackendTask.succeed
                { thing =
                    { name = thing.name
                    , website = thing.website
                    , tags = thing.tags
                    , description = thing.description
                    , pageLastUpdated = thing.pageLastUpdated
                    , pageCreatedAt = thing.pageCreatedAt
                    , thingType = thing.thingType
                    }
                }

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
            [ Ui.Responsive.paddingXY
                Shared.breakpoints
                (\label ->
                    case label of
                        Mobile ->
                            { x = Ui.Responsive.value 8, y = Ui.Responsive.value 16 }

                        NotMobile ->
                            { x = Ui.Responsive.value 16, y = Ui.Responsive.value 16 }
                )
            , Ui.widthMax 800
            , Ui.centerX
            , Ui.height Ui.fill
            , Ui.spacing 24
            ]
            [ Ui.column
                []
                [ case thing.website of
                    Just url ->
                        Formatting.externalLink 36 thing.name url

                    Nothing ->
                        Ui.el [ Ui.Font.size 36 ] (Ui.text thing.name)
                , Ui.row
                    [ Ui.spacing 16 ]
                    [ Ui.text
                        ("Created at "
                            ++ Date.toIsoString thing.pageCreatedAt
                            ++ (if thing.pageLastUpdated == thing.pageCreatedAt then
                                    ""

                                else
                                    " " ++ "(updated at " ++ Date.toIsoString thing.pageLastUpdated ++ ")"
                               )
                        )
                    , case thing.thingType of
                        OtherThing other ->
                            case other.repo of
                                Just repo ->
                                    Formatting.externalLink 16 "View source code" repo

                                Nothing ->
                                    Ui.none

                        JobThing _ ->
                            Ui.none

                        PodcastThing _ ->
                            Ui.none
                    ]
                ]
            , if List.isEmpty thing.description then
                Ui.text "TODO"

              else
                Formatting.view thing.description
            ]
    }
