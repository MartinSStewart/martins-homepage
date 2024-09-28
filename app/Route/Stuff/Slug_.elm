port module Route.Stuff.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Browser.Events
import Date exposing (Date)
import Dict
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Formatting exposing (Formatting)
import Head
import Head.Seo as Seo
import Json.Decode
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Set exposing (Set)
import Shared exposing (Breakpoints(..))
import Things exposing (Tag, ThingType(..))
import Ui
import Ui.Font
import Ui.Prose
import Ui.Responsive
import View exposing (View)


port skipForwardVideo : () -> Cmd msg


port skipBackwardVideo : () -> Cmd msg


type alias Model =
    { selectedAltText : Set String, videoIsPlaying : Bool }


type Msg
    = PressedAltText String
    | StartedVideo
    | PressedArrowKey ArrowKey


type ArrowKey
    = LeftArrowKey
    | RightArrowKey


type alias RouteParams =
    { slug : String }


init _ _ =
    ( { selectedAltText = Set.empty, videoIsPlaying = False }, Effect.none )


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


update : App data action routeParams -> Shared.Model -> Msg -> Model -> ( Model, Effect msg )
update _ _ msg model =
    case msg of
        PressedAltText altText ->
            ( { model | selectedAltText = Set.insert altText model.selectedAltText }, Effect.none )

        StartedVideo ->
            ( { model | videoIsPlaying = True }, Effect.none )

        PressedArrowKey arrowKey ->
            ( model
            , case arrowKey of
                LeftArrowKey ->
                    skipBackwardVideo ()

                RightArrowKey ->
                    skipForwardVideo ()
            )


subscriptions : a -> b -> c -> Model -> Sub Msg
subscriptions _ _ _ model =
    if model.videoIsPlaying then
        Browser.Events.onKeyDown
            (Json.Decode.field "key" Json.Decode.string
                |> Json.Decode.andThen
                    (\key ->
                        if key == "ArrowLeft" then
                            Json.Decode.succeed (PressedArrowKey LeftArrowKey)

                        else if key == "ArrowRight" then
                            Json.Decode.succeed (PressedArrowKey RightArrowKey)

                        else
                            Json.Decode.fail ""
                    )
            )

    else
        Sub.none


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
    , previewImage : String
    }


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    case Dict.get routeParams.slug Things.thingsIHaveDone of
        Just thing ->
            case Formatting.checkFormatting thing.description of
                Ok () ->
                    BackendTask.succeed
                        { thing =
                            { name = thing.name
                            , website = thing.website
                            , tags = thing.tags
                            , description = thing.description
                            , pageLastUpdated = thing.pageLastUpdated
                            , pageCreatedAt = thing.pageCreatedAt
                            , thingType = thing.thingType
                            , previewImage = thing.previewImage
                            }
                        }

                Err error ->
                    BackendTask.fail (FatalError.fromString error)

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
    -> Model
    -> View (PagesMsg Msg)
view app _ model =
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
            , Ui.spacing 8
            ]
            [ title thing
            , if List.isEmpty thing.description then
                Ui.text "TODO"

              else
                Formatting.view
                    { pressedAltText = \text -> PressedAltText text |> PagesMsg.fromMsg
                    , startedVideo = StartedVideo |> PagesMsg.fromMsg
                    }
                    model
                    thing.description
            , Ui.el [ Ui.height (Ui.px 100) ] Ui.none
            ]
    }


dateView date =
    Ui.el [ Ui.Font.bold ] (Ui.text (Date.toIsoString date))


title : Thing -> Ui.Element msg
title thing =
    Ui.row
        [ Ui.spacing 8 ]
        [ Ui.image
            [ Ui.width (Ui.px 64)
            , Ui.alignBottom
            , Ui.Responsive.visible Shared.breakpoints [ NotMobile ]
            ]
            { source = thing.previewImage, description = "Preview image", onLoad = Nothing }
        , Ui.column
            []
            [ case thing.website of
                Just url ->
                    Formatting.externalLink 36 thing.name url

                Nothing ->
                    Ui.el [ Ui.Font.size 36 ] (Ui.text thing.name)
            , Ui.row
                [ Ui.wrap, Ui.spacing 16, Ui.Font.size 14 ]
                [ case thing.thingType of
                    OtherThing { releasedAt } ->
                        "Released at " ++ Date.toIsoString releasedAt |> Ui.text

                    JobThing { startedAt, endedAt, elmPercentage } ->
                        Ui.Prose.paragraph
                            []
                            ([ Ui.text "Employed between "
                             , dateView startedAt
                             , Ui.text " and "
                             ]
                                ++ (case endedAt of
                                        Just a ->
                                            [ dateView a
                                            , Ui.text
                                                (" ("
                                                    ++ String.fromInt (Date.diff Date.Months startedAt a)
                                                    ++ "\u{00A0}months)"
                                                )
                                            ]

                                        Nothing ->
                                            [ Ui.el [ Ui.Font.bold ] (Ui.text "present day") ]
                                   )
                            )

                    PodcastThing { releasedAt } ->
                        "Released at " ++ Date.toIsoString releasedAt |> Ui.text

                    GameMakerThing { releasedAt } ->
                        Ui.text ("Released at " ++ Date.toIsoString releasedAt)
                , case thing.thingType of
                    OtherThing other ->
                        case other.repo of
                            Just repo ->
                                Formatting.externalLink 14 "View\u{00A0}source\u{00A0}code" repo

                            Nothing ->
                                Ui.none

                    JobThing _ ->
                        Ui.none

                    PodcastThing _ ->
                        Ui.none

                    GameMakerThing { download } ->
                        Formatting.downloadLink "Windows exe" download
                ]
            ]
        ]
