module Route.Mixtape2025 exposing (Model, Msg(..), RouteParams, route, Data, ActionData)

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
import Ui.Gradient
import Ui.Input
import Ui.Prose
import Ui.Responsive
import Ui.Shadow
import UrlPath
import View


type alias Song =
    { url : String
    , name : String
    , description : String
    }


songs : Array Song
songs =
    [ { url = "A Million Miles Away"
      , name = "Mars Express OST - A Million Miles Away"
      , description = "Someone on reddit recommended the movie Mars Express. On a whim I decided to watch it. I liked it. This song plays during the credits and I like it too."
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
    , { url = "Lizzo - About Damn Time (Lyrics)"
      , name = "Lizzo - About Damn Time"
      , description = "Not the kind of song I would have expected to like. I found this one as well while playing Beat Saber. It makes for a really good FitBeat map."
      }
    , { url = "Magdalena Bay - Image (Official Video)"
      , name = "Magdalena Bay - Image"
      , description = "Thea showed me this song. Most of the songs by this artist I'm not into but this song and a couple others are good."
      }
    , { url = "Mazie - Dumb Dumb (Lyrics)"
      , name = "Mazie - Dumb Dumb"
      , description = "Yet another song I found while playing BeatSaber. It's very silly."
      }
    , { url = "Song for Sienna"
      , name = "Brian Crain - Song for Sienna"
      , description = "Found while listening to piano music playlist on youtube."
      }
    , { url = "New Mjondalen Disco Swingers - Eurodans"
      , name = "New Mjondalen Disco Swingers - Eurodans"
      , description = "Another silly song but a different kind of silly. I found it on youtube while listening to Todd Terje music. He also has a song called Eurodans though I'm not sure in what way they are related."
      }
    , { url = "seinwave"
      , name = "Abelard - ☆ＳＥＩＮＷＡＶＥ☆２０００☆"
      , description = "I'm not into Vaporwave music but the Seinfeld crossover and excellent name make this one stand out for me."
      }
    , { url = "Staff Credits - Mario Kart  Double Dash!!"
      , name = "Mario Kart: Double Dash OST - Staff Credits"
      , description = "There is a debate to be had whether Mario Kart Double Dash is the best Mario Kart. There is however, no debate as to which Mario Kart credits song is the best."
      }
    , { url = "The Whisper"
      , name = "Laika: Aged Through Blood OST - The Whisper"
      , description = "Theme song for a video game set in a post-apocalypse. I heard it while watching a friend live-stream the game. He wasn't very good at the game but the song is good."
      }
    , { url = "Vulfmon & Evangeline - Got To Be Mine (Official Video)"
      , name = "Vulfmon & Evangeline - Got To Be Mine"
      , description = "Good song. I like the music video for it too though it makes me miss the summer."
      }
    , { url = "Water Ripples"
      , name = "Enno Aare - Water Ripples"
      , description = "Another piano song I like. I think I found it at the same time as Song for Sienna."
      }
    , { url = "Camel by Camel - Mix Vocal"
      , name = "Sandy Marton - Camel by Camel"
      , description = "I think this has become a meme song thanks to his silly face and a crossover with an Egyptian character from the Animal Crossing games."
      }
    , { url = "Riders Of The Ancient Winds"
      , name = "Craig Chaquico & Russ Freeman - Riders Of The Ancient Winds"
      , description = "Very relaxing song"
      }
    , { url = "Double Exposure (feat. Russ Freeman)"
      , name = "Brian Culbertson - Double Exposure (feat. Russ Freeman)"
      , description = "I have a rule about not including a band or musician more than once in a mixtape. I'm making an exception for Russ Freeman because he's only featured in this song so I can still include Riders Of The Ancient Winds."
      }
    , { url = "Empire Of The Sun - Wandering star (HQ)"
      , name = "Empire Of The Sun - Wandering star"
      , description = "Thea showed me this song while I was visiting her old leased apartment up in Kungsängen. The song is apparently from Dumb and Dumber To which is a shockingly different tone compared to the song."
      }
    , { url = "FUTURE WORLD ORCHESTRA - Don't Go (Part 1) - 1985"
      , name = "FUTURE WORLD ORCHESTRA - Don't Go (Part 1)"
      , description = "There's a part 2 that seems to be part 1 but with sections of the song reordered. I think I slightly like part 1 more."
      }
    , { url = "No Straight Roads OST - vs. DJ Subatomic Supernova"
      , name = "No Straight Roads OST - vs. DJ Subatomic Supernova"
      , description = "Plays during a boss fight in the game No Straight Roads. The game has a lot of good songs but this one is my favorite."
      }
    , { url = "Paolo Nutini - New Shoes"
      , name = "Paolo Nutini - New Shoes"
      , description = "Connor showed me this song! Paolo Nutini is Scottish so it makes sense that he'd know about this musician."
      }
    , { url = "Red Parker - Born To Run"
      , name = "Red Parker - Born To Run"
      , description = "Given the name \"Born to Run\" it seems like I'd find this song relatable. Tragically, running in this song refers to driving a car at high speed."
      }
    , { url = "Super Flu - Selee (official video)"
      , name = "Super Flu - Selee"
      , description = "I found this song while watching Line Rider videos (an old game where you draw lines that a man on a sled can slide down on). This song's official music video a very impressive Line Rider map."
      }
    , { url = "You And I (Radio Edit)"
      , name = "Tony Betties - You And I"
      , description = "As far as I can tell, this musician has published this song and another song called So Cool around 2012. Nothing else since then. I guess they wanted to leave on a high note."
      }
    ]
        |> Array.fromList


type alias Model =
    { currentlyPlaying : Maybe Int }


type Msg
    = NoOp
    | SongEnded Int
    | PressedAlbumArt Int
    | SongStarted Int


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
    ( { currentlyPlaying = Nothing }, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app _ msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )

        SongEnded songIndex ->
            case Array.get (songIndex + 1) app.data.songs of
                Just song ->
                    ( model, Shared.playSong song.url )

                Nothing ->
                    ( { model | currentlyPlaying = Nothing }, Effect.none )

        PressedAlbumArt songIndex ->
            case Array.get songIndex app.data.songs of
                Just song ->
                    ( model, Shared.playSong song.url )

                Nothing ->
                    ( model, Effect.none )

        SongStarted songIndex ->
            case Array.get songIndex app.data.songs of
                Just song ->
                    ( { model | currentlyPlaying = Just songIndex }, Shared.songStarted song.url )

                Nothing ->
                    ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


type alias Data =
    { songs : Array Song }


type alias ActionData =
    BackendTask.BackendTask FatalError.FatalError (List RouteParams)


data : BackendTask.BackendTask FatalError.FatalError Data
data =
    BackendTask.succeed { songs = songs }


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


colorText text =
    String.toList text
        |> List.indexedMap
            (\index char ->
                Html.span
                    [ Html.Attributes.style
                        "color"
                        (case modBy 2 index of
                            0 ->
                                "rgb(120,0,0)"

                            _ ->
                                "rgb(0,100,0)"
                        )
                    ]
                    [ Html.text (String.fromChar char) ]
            )
        |> Html.div []
        |> Ui.html


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "Merry Mixtape 2025"
    , body =
        Ui.el
            [ Ui.backgroundGradient
                [ Ui.Gradient.linear
                    (Ui.turns 0.5)
                    [ Ui.Gradient.percent 0 (Ui.rgb 255 255 255)
                    , Ui.Gradient.percent 100 (Ui.rgb 173 214 202)
                    ]
                ]
            ]
            (Ui.column
                [ Ui.widthMax 1000
                , Ui.centerX
                , Ui.Responsive.paddingXY Shared.breakpoints
                    (\label ->
                        if label == Mobile then
                            { x = Ui.Responsive.value 8, y = Ui.Responsive.value 0 }

                        else
                            { x = Ui.Responsive.value 16, y = Ui.Responsive.value 0 }
                    )
                ]
                [ Ui.column
                    [ Ui.spacing 16, Ui.paddingXY 0 32 ]
                    [ Ui.el
                        [ Ui.Font.size 36
                        , Ui.Font.bold
                        ]
                        (colorText "Merry  Mixtape  2025 📼")
                    , Ui.Prose.paragraph
                        [ Ui.Font.size 18, Ui.paddingXY 0 16 ]
                        [ Ui.el [ Ui.Font.bold ] (Ui.text "Merry Christmas Mama and Papa! ")
                        , Ui.text "After a long hiatus, here's a new mixtape with a bunch of songs I've found over the past few\u{00A0}years."
                        ]
                    , Ui.el
                        [ Ui.Font.color (Ui.rgb 0 100 230)
                        , Ui.Font.size 18
                        , Ui.Font.bold
                        , Ui.linkNewTab "https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2FMartinSStewart%2Fmartins-homepage%2Ftree%2Fmaster%2Fpublic%2Fmixtape2025"
                        , Ui.Font.underline
                        ]
                        (Ui.text "Download all")
                    ]
                , if shared.windowWidth > 700 then
                    List.indexedMap
                        (\index song ->
                            Ui.row
                                [ Ui.Shadow.shadows
                                    [ { x = 0
                                      , y = 2
                                      , size =
                                            if model.currentlyPlaying == Just index then
                                                2

                                            else
                                                0
                                      , blur =
                                            if model.currentlyPlaying == Just index then
                                                16

                                            else
                                                8
                                      , color =
                                            if model.currentlyPlaying == Just index then
                                                Ui.rgba 0 0 0 0.5

                                            else
                                                Ui.rgba 0 0 0 0.2
                                      }
                                    ]
                                , Ui.rounded 8
                                , Ui.clip
                                , Ui.background (Ui.rgb 40 40 40)
                                , Ui.border 1
                                , Ui.borderColor (Ui.rgb 0 0 0)
                                ]
                                [ coverImage index song 256
                                , Ui.column [ Ui.height Ui.fill ] [ audio index song, description index song ]
                                ]
                        )
                        (Array.toList app.data.songs)
                        |> Ui.column
                            [ Ui.spacing 24
                            , Ui.Font.color (Ui.rgb 255 255 255)
                            ]

                  else
                    List.indexedMap
                        (\index song ->
                            Ui.column
                                [ Ui.Shadow.shadows [ { x = 0, y = 2, size = 0, blur = 8, color = Ui.rgba 0 0 0 0.2 } ]
                                , Ui.rounded 8
                                , Ui.clip
                                , Ui.background (Ui.rgb 40 40 40)
                                ]
                                [ audio index song
                                , Ui.row [ Ui.height Ui.fill ] [ coverImage index song 128, description index song ]
                                ]
                        )
                        (Array.toList app.data.songs)
                        |> Ui.column
                            [ Ui.spacing 16
                            , Ui.Font.color (Ui.rgb 255 255 255)
                            ]
                , Ui.el
                    [ Ui.Font.size 18, Ui.Font.italic, Ui.centerX, Ui.padding 24, Ui.Font.bold ]
                    (Ui.text "That's all folks!")
                ]
                |> Ui.map PagesMsg.fromMsg
            )
    }


audio : Int -> Song -> Ui.Element Msg
audio index song =
    Html.audio
        [ Html.Attributes.src ("/mixtape2025/" ++ song.url ++ ".mp3")
        , Html.Attributes.controls True
        , Html.Events.on "ended" (Json.Decode.succeed (SongEnded index))
        , Html.Events.on "play" (Json.Decode.succeed (SongStarted index))
        , Html.Attributes.id song.url
        , Html.Attributes.style "width" "100%"
        ]
        []
        |> Ui.html


description : Int -> { a | name : String, description : String } -> Ui.Element msg
description index song =
    Ui.column
        [ Ui.padding 16, Ui.spacing 8, Ui.alignTop ]
        [ Ui.row
            [ Ui.spacing 8 ]
            [ Ui.el [ Ui.alignTop, Ui.width Ui.shrink ] (Ui.text (String.fromInt (index + 1) ++ ". "))
            , Ui.el [ Ui.Font.bold ] (Ui.text (String.replace "-" "\u{00A0}–\u{00A0}" song.name))
            ]
        , Ui.text song.description
        ]


coverImage : Int -> Song -> Int -> Ui.Element Msg
coverImage index song size =
    Ui.image
        [ Ui.width (Ui.px size)
        , Ui.height (Ui.px size)
        , Ui.Input.button (PressedAlbumArt index)
        ]
        { source = "/mixtape2025/" ++ song.url ++ ".jpg"
        , description = "Cover art for " ++ song.name
        , onLoad = Nothing
        }
