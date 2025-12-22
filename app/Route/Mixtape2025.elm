module Route.Mixtape2025 exposing (..)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import Array exposing (Array)
import BackendTask
import BackendTask.Time
import Date exposing (Date)
import Effect
import FatalError
import Formatting exposing (Formatting(..), Inline(..))
import Head
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import PagesMsg
import Route exposing (Route(..))
import RouteBuilder
import Set exposing (Set)
import Shared exposing (Breakpoints(..))
import Time
import Ui
import Ui.Font
import Ui.Responsive
import UrlPath
import View


names : Array ( String, String )
names =
    [ ( "A Million Miles Away.mp3", "A Million Miles Away" )
    , ( "Anish Kumar & Barry Can’t Swim - 'Blackpool Boulevard' (Official Audio).mp3", "Anish Kumar & Barry Can’t Swim - 'Blackpool Boulevard' (Official Audio)" )
    , ( "Birth of the Yamato (feat. Wind Loop Case).mp3", "Birth of the Yamato (feat. Wind Loop Case)" )
    , ( "Carol Brown.mp3", "Carol Brown" )
    , ( "Color Your Night.mp3", "Color Your Night" )
    , ( "Concert Boy (Original 12＂ Version).mp3", "Concert Boy (Original 12＂ Version)" )
    , ( "Fitz and the Tantrums - HandClap [Official Video].mp3", "Fitz and the Tantrums - HandClap [Official Video]" )
    , ( "John Newman - Love Me Again (Lyrics).mp3", "John Newman - Love Me Again (Lyrics)" )
    , ( "Lizzo - About Damn Time (Lyrics).mp3", "Lizzo - About Damn Time (Lyrics)" )
    , ( "Magdalena Bay - Image (Official Video).mp3", "Magdalena Bay - Image (Official Video)" )
    , ( "Mazie - Dumb Dumb (Lyrics).mp3", "Mazie - Dumb Dumb (Lyrics)" )
    , ( "New Mjondalen Disco Swingers - Eurodans.mp3", "New Mjondalen Disco Swingers - Eurodans" )
    , ( "seinwave.mp3", "Abelard - ☆ＳＥＩＮＷＡＶＥ☆２０００☆" )
    , ( "Song for Sienna.mp3", "Song for Sienna" )
    , ( "Staff Credits - Mario Kart  Double Dash!!.mp3", "Staff Credits - Mario Kart  Double Dash!!" )
    , ( "The Dog, The Dog, He's At It Again.mp3", "The Dog, The Dog, He's At It Again" )
    , ( "The Whisper.mp3", "The Whisper" )
    , ( "Vulfmon & Evangeline - Got To Be Mine (Official Video).mp3", "Vulfmon & Evangeline - Got To Be Mine (Official Video)" )
    , ( "Water Ripples.mp3", "Water Ripples" )
    ]
        |> Array.fromList


type alias Model =
    {}


type Msg
    = NoOp
    | SongEnded Int


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
init _ _ =
    ( {}, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update _ _ msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )

        SongEnded songIndex ->
            case Array.get (songIndex + 1) names of
                Just ( url, _ ) ->
                    ( model, Shared.playSong url )

                Nothing ->
                    ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


type alias Data =
    {}


type alias ActionData =
    BackendTask.BackendTask FatalError.FatalError (List RouteParams)


birthday : Date
birthday =
    Date.fromCalendarDate 1993 Time.Oct 9


data : BackendTask.BackendTask FatalError.FatalError Data
data =
    BackendTask.succeed {}


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "Mixtape 2025"
    , body =
        Ui.column
            [ Ui.widthMax 1000
            , Ui.centerX
            , Ui.contentTop
            , Ui.height Ui.fill
            ]
            [ Ui.el [ Ui.Font.size 64 ] (Ui.text "Mixtape 2025")
            , List.indexedMap
                (\index ( url, name ) ->
                    Ui.column
                        []
                        [ Ui.text name
                        , Html.audio
                            [ Html.Attributes.src ("/mixtape2025/" ++ url)
                            , Html.Attributes.controls True
                            , Html.Events.on "ended" (Json.Decode.succeed (SongEnded index))
                            ]
                            []
                            |> Ui.html
                        ]
                )
                (Array.toList names)
                |> Ui.column []
            ]
            |> Ui.map PagesMsg.fromMsg
    }
