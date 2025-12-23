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
import Ui.Input
import Ui.Responsive
import Ui.Shadow
import UrlPath
import View


type alias Song =
    { url : String
    , name : String
    , description : String
    }


names : Array Song
names =
    [ { url = "A Million Miles Away"
      , name = "Mars Express OST - A Million Miles Away"
      , description = "I happened to be reading Dan Olson's reddit comments and randomly saw that he recommended the movie Mars Express. I like his Folding Ideas youtube channel so I figured I'd give the movie a watch. I liked it. This song plays during the credits and I like it too."
      }
    , { url = "Anish Kumar & Barry Can’t Swim - 'Blackpool Boulevard' (Official Audio)"
      , name = "Anish Kumar & Barry Can’t Swim - 'Blackpool Boulevard' (Official Audio)"
      , description = "This song played a couple times at the bouldering gym. I asked the person running the playlist what it was called so I could listen to it again."
      }
    , { url = "Birth of the Yamato (feat. Wind Loop Case)"
      , name = "Yusuke Shima - Birth of the Yamato (feat. Wind Loop Case)"
      , description = "Found while listening to music on youtube. Nice calm song."
      }
    , { url = "Carol Brown"
      , name = "Flight of the Conchords - Carol Brown"
      , description = "One of the less well known Flight of the Conchord songs that I enjoy listening to."
      }
    , { url = "Color Your Night"
      , name = "Persona 3 Reload OST - Color Your Night"
      , description = "From a soundtrack a friend would constantly sing back in high school. I wasn't into to the songs then but now I've grown to like some of them."
      }
    , { url = "Concert Boy (Original 12＂ Version)"
      , name = "Cube - Concert Boy"
      , description = "The \"Original 12 inch Version\" according to the youtube video I downloaded it from. I heard this one playing at the bouldering gym as well. One of the employees (David) really likes this song."
      }
    , { url = "Fitz and the Tantrums - HandClap [Official Video]"
      , name = "Fitz and the Tantrums - HandClap"
      , description = "Someone made a Beat Saber map using this song which is how I ended up listening to it."
      }
    , { url = "John Newman - Love Me Again (Lyrics)"
      , name = "John Newman - Love Me Again"
      , description = "Someone *tried* to make a Beat Saber map using this song but it wouldn't load for me (or rather, it crashed the game when I tried loading it). Still the song preview sounded good so I went and listened to it on youtube."
      }
    , { url = "Lizzo - About Damn Time (Lyrics)"
      , name = "Lizzo - About Damn Time"
      , description = "Not the kind of song I would have expected to like. I found this one while, once again, playing Beat Saber. It makes for a really good FitBeat map."
      }
    , { url = "Magdalena Bay - Image (Official Video)"
      , name = "Magdalena Bay - Image"
      , description = "Thea showed me this song. Most of the songs by this artist I'm not into but this song and a couple others are good."
      }
    , { url = "Mazie - Dumb Dumb (Lyrics)"
      , name = "Mazie - Dumb Dumb"
      , description = "Yet another song I found while playing BeatSaber. It's very silly."
      }
    , { url = "New Mjondalen Disco Swingers - Eurodans"
      , name = "New Mjondalen Disco Swingers - Eurodans"
      , description = "Another silly song but a different kind of silly. I found it on youtube while listening to Todd Terje music, he also has a song called Eurodans. I'm not sure in what way they are related."
      }
    , { url = "seinwave"
      , name = "Abelard - ☆ＳＥＩＮＷＡＶＥ☆２０００☆"
      , description = "I'm not that into Vaporwave music but the Seinfeld crossover and excellent name make this one stand out for me."
      }
    , { url = "Song for Sienna"
      , name = "Brian Crain - Song for Sienna"
      , description = "Found while listening to piano music on, you guessed it, youtube."
      }
    , { url = "Staff Credits - Mario Kart  Double Dash!!"
      , name = "Mario Kart: Double Dash OST - Staff Credits"
      , description = "There is a debate to be had whether Mario Kart Double Dash is the best Mario Kart. There is however, no debate as to which Mario Kart credits song is the best."
      }
    , { url = "The Dog, The Dog, He's At It Again"
      , name = "Caravan - The Dog, The Dog, He's At It Again"
      , description = "I heard this song on another mixtape called Ray Smith's Non-Stop Golden Deluxe Hammond Party that my mom got as a present from a friend decades ago."
      }
    , { url = "The Whisper"
      , name = "Laika: Aged Through Blood OST - The Whisper"
      , description = "Theme song for a video game set in a post-apocalypse."
      }
    , { url = "Vulfmon & Evangeline - Got To Be Mine (Official Video)"
      , name = "Vulfmon & Evangeline - Got To Be Mine"
      , description = "Good song. I like the music video for it too."
      }
    , { url = "Water Ripples"
      , name = "Enno Aare - Water Ripples"
      , description = "Another piano song I like. I think I found it at the same time as Song for Sienna."
      }
    ]
        |> Array.fromList


type alias Model =
    {}


type Msg
    = NoOp
    | SongEnded Int
    | PressedAlbumArt Int


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
                Just song ->
                    ( model, Shared.playSong song.url )

                Nothing ->
                    ( model, Effect.none )

        PressedAlbumArt songIndex ->
            case Array.get songIndex names of
                Just song ->
                    ( model, Shared.playSong song.url )

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
    { title = "Merry Mixtape 2025"
    , body =
        Ui.column
            [ Ui.widthMax 1000
            , Ui.centerX
            , Ui.Responsive.paddingXY Shared.breakpoints
                (\label ->
                    if label == Mobile then
                        { x = Ui.Responsive.value 8, y = Ui.Responsive.value 16 }

                    else
                        { x = Ui.Responsive.value 16, y = Ui.Responsive.value 16 }
                )
            ]
            [ Ui.column
                [ Ui.spacing 8 ]
                [ Ui.el [ Ui.Font.size 48 ] (Ui.text "Merry Mixtape 2025 📼")
                , Ui.el
                    [ Ui.paddingBottom 16, Ui.Font.size 18 ]
                    (Ui.text "Merry Christmas Mama and Papa! Here are some new songs I like and want to share.")
                ]
            , if shared.windowWidth > 700 then
                List.indexedMap
                    (\index { url, name, description } ->
                        Ui.row
                            [ Ui.Shadow.shadows [ { x = 0, y = 2, size = 0, blur = 8, color = Ui.rgba 0 0 0 0.2 } ]
                            , Ui.rounded 8
                            , Ui.clip
                            , Ui.background (Ui.rgb 40 40 40)
                            ]
                            [ Ui.image
                                [ Ui.width (Ui.px 256)
                                , Ui.height (Ui.px 256)
                                , Ui.Input.button (PressedAlbumArt index)
                                ]
                                { source = "/mixtape2025/" ++ url ++ ".jpg"
                                , description = "Cover art for " ++ name
                                , onLoad = Nothing
                                }
                            , Ui.column
                                [ Ui.height Ui.fill ]
                                [ Html.audio
                                    [ Html.Attributes.src ("/mixtape2025/" ++ url ++ ".mp3")
                                    , Html.Attributes.controls True
                                    , Html.Events.on "ended" (Json.Decode.succeed (SongEnded index))
                                    , Html.Attributes.id url
                                    ]
                                    []
                                    |> Ui.html
                                , Ui.column
                                    [ Ui.padding 16, Ui.spacing 8 ]
                                    [ Ui.el [ Ui.Font.bold ] (Ui.text name)
                                    , Ui.text description
                                    ]
                                ]
                            ]
                    )
                    (Array.toList names)
                    |> Ui.column
                        [ Ui.spacing 24
                        , Ui.Font.color (Ui.rgb 255 255 255)
                        ]

              else
                List.indexedMap
                    (\index { url, name, description } ->
                        Ui.column
                            [ Ui.Shadow.shadows [ { x = 0, y = 2, size = 0, blur = 8, color = Ui.rgba 0 0 0 0.2 } ]
                            , Ui.rounded 8
                            , Ui.clip
                            , Ui.background (Ui.rgb 40 40 40)
                            ]
                            [ Html.audio
                                [ Html.Attributes.src ("/mixtape2025/" ++ url ++ ".mp3")
                                , Html.Attributes.controls True
                                , Html.Events.on "ended" (Json.Decode.succeed (SongEnded index))
                                , Html.Attributes.id url
                                ]
                                []
                                |> Ui.html
                            , Ui.row
                                [ Ui.height Ui.fill ]
                                [ Ui.image
                                    [ Ui.width (Ui.px 128)
                                    , Ui.height (Ui.px 128)
                                    , Ui.Input.button (PressedAlbumArt index)
                                    ]
                                    { source = "/mixtape2025/" ++ url ++ ".jpg"
                                    , description = "Cover art for " ++ name
                                    , onLoad = Nothing
                                    }
                                , Ui.column
                                    [ Ui.padding 16, Ui.spacing 8, Ui.alignTop ]
                                    [ Ui.el [ Ui.Font.bold ] (Ui.text name)
                                    , Ui.text description
                                    ]
                                ]
                            ]
                    )
                    (Array.toList names)
                    |> Ui.column
                        [ Ui.spacing 16
                        , Ui.Font.color (Ui.rgb 255 255 255)
                        ]
            ]
            |> Ui.map PagesMsg.fromMsg
    }
