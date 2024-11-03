port module Route.Stuff.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Browser.Dom
import Browser.Events
import Date exposing (Date)
import Dict
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Formatting exposing (Formatting)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes
import Json.Decode
import List.Extra
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Random
import RouteBuilder exposing (App, StatefulRoute)
import Set exposing (Set)
import Shared exposing (Breakpoints(..))
import Task
import Things exposing (Tag, ThingType(..))
import Time
import Ui
import Ui.Font
import Ui.Lazy
import Ui.Prose
import Ui.Responsive
import View exposing (View)


port skipForwardVideo : () -> Cmd msg


port skipBackwardVideo : () -> Cmd msg


port shoot : { x : Float, y : Float } -> Cmd msg


port playSound : String -> Cmd msg


port loadSounds : () -> Cmd msg


type GunType
    = Handgun
    | MachineGun
    | Shotgun
    | Bomb


type alias Model =
    { selectedAltText : Set String
    , videoIsPlaying : Bool
    , bulletHoles : List { x : Float, y : Float, gunType : GunType }
    , gameState : Maybe GameState
    }


type alias GameState =
    { gun : GunType
    , machineGunAmmo : Int
    , shotgunAmmo : Int
    , bombAmmo : Int
    , elapsedTime : Float
    , cursors : List Cursor
    , dogsGif : { x : Float, y : Float, width : Float, height : Float }
    , pageHeight : Float
    }


type Msg
    = PressedAltText String
    | StartedVideo
    | PressedArrowKey ArrowKey
    | PressedStartShootEmUp
    | MouseDown MouseDownData
    | PressedGunKey GunType
    | AnimationFrameDelta Float
    | GotDogsAndPageImage
        (Result
            Browser.Dom.Error
            ( { x : Float, y : Float, width : Float, height : Float }, Float )
        )


type alias MouseDownData =
    { clientX : Float, clientY : Float, pageX : Float, pageY : Float }


type ArrowKey
    = LeftArrowKey
    | RightArrowKey


type alias RouteParams =
    { slug : String }


init : App Data action routeParams -> Shared.Model -> ( Model, Cmd Msg )
init _ _ =
    ( { selectedAltText = Set.empty, videoIsPlaying = False, bulletHoles = [], gameState = Nothing }
    , Cmd.none
    )


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


update : App data action routeParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ shared msg model =
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

        PressedStartShootEmUp ->
            ( { model
                | gameState =
                    Just
                        { gun = Handgun
                        , machineGunAmmo = 0
                        , shotgunAmmo = 0
                        , bombAmmo = 0
                        , elapsedTime = 0
                        , cursors = []
                        , dogsGif = { x = 0, y = 0, width = 0, height = 0 }
                        , pageHeight = toFloat shared.windowHeight
                        }
              }
            , Cmd.batch
                [ loadSounds ()
                , Task.map2
                    (\{ element } { scene } -> ( element, scene.height ))
                    (Browser.Dom.getElement Formatting.dogsImageId)
                    Browser.Dom.getViewport
                    |> Task.attempt GotDogsAndPageImage
                ]
            )

        MouseDown { clientX, clientY, pageX, pageY } ->
            case model.gameState of
                Just gameState ->
                    ( { model
                        | bulletHoles = { x = pageX, y = pageY, gunType = Handgun } :: model.bulletHoles
                        , gameState =
                            { gun = gameState.gun
                            , machineGunAmmo = gameState.machineGunAmmo
                            , shotgunAmmo = gameState.shotgunAmmo
                            , bombAmmo = gameState.bombAmmo
                            , elapsedTime = gameState.elapsedTime
                            , cursors =
                                List.map
                                    (\cursor ->
                                        case cursor.isDead of
                                            Just _ ->
                                                cursor

                                            Nothing ->
                                                let
                                                    distance =
                                                        sqrt ((cursor.x - pageX) ^ 2 + (cursor.y - pageY) ^ 2)
                                                in
                                                if distance < 16 then
                                                    { cursor
                                                        | isDead = Just { diedAt = gameState.elapsedTime }
                                                        , isAttached = False
                                                    }

                                                else
                                                    cursor
                                    )
                                    gameState.cursors
                            , dogsGif = gameState.dogsGif
                            , pageHeight = gameState.pageHeight
                            }
                                |> Just
                      }
                    , Cmd.batch
                        [ shoot { x = clientX, y = clientY }
                        , (case gameState.gun of
                            Handgun ->
                                "sn_handgun"

                            MachineGun ->
                                "sn_machinegun"

                            Shotgun ->
                                "sn_shotgun"

                            Bomb ->
                                "sn_explosion"
                          )
                            |> playSound
                        ]
                    )

                Nothing ->
                    ( model, Cmd.none )

        PressedGunKey gunType ->
            case model.gameState of
                Just gameState ->
                    ( { model | gameState = Just { gameState | gun = gunType } }
                    , (case gunType of
                        Handgun ->
                            "sn_handgun_voice"

                        MachineGun ->
                            "sn_machinegun_voice"

                        Shotgun ->
                            "sn_shotgun_voice"

                        Bomb ->
                            "sn_bomb_voice"
                      )
                        |> playSound
                    )

                Nothing ->
                    ( model, Cmd.none )

        AnimationFrameDelta elapsed ->
            ( case model.gameState of
                Just gameState ->
                    let
                        cursorSpeed =
                            1

                        elapsed2 =
                            gameState.elapsedTime + elapsed

                        newCursors : List Cursor
                        newCursors =
                            Random.step
                                (spawnCursors shared.windowWidth (round gameState.pageHeight) (round elapsed2))
                                (Random.initialSeed (elapsed2 * 10000 |> round))
                                |> Tuple.first

                        gif =
                            gameState.dogsGif

                        gifCenterX : Float
                        gifCenterX =
                            gif.x + gif.width / 2

                        gifCenterY : Float
                        gifCenterY =
                            gif.y + gif.height / 2

                        dragCount =
                            List.Extra.count
                                (\cursor -> cursor.isAttached && cursor.isDead == Nothing)
                                gameState.cursors
                                |> toFloat

                        pageCenterX =
                            toFloat shared.windowWidth / 2

                        pageCenterY =
                            gameState.pageHeight / 2

                        dragDirection =
                            atan2 (pageCenterY - gifCenterY) (pageCenterX - gifCenterX) + pi

                        dragX =
                            dragCount * 0.1 * cos dragDirection

                        dragY =
                            dragCount * 0.1 * sin dragDirection

                        updateCursor : Cursor -> Maybe Cursor
                        updateCursor cursor =
                            case cursor.isDead of
                                Just { diedAt } ->
                                    if elapsed2 - diedAt > 2000 then
                                        Nothing

                                    else
                                        Just cursor

                                Nothing ->
                                    if cursor.isAttached then
                                        { x = cursor.x + dragX
                                        , y = cursor.y + dragY
                                        , isBonus = cursor.isBonus
                                        , isAttached = True
                                        , isDead = cursor.isDead
                                        }
                                            |> Just

                                    else
                                        let
                                            direction : Float
                                            direction =
                                                atan2 (gifCenterY - cursor.y) (gifCenterX - cursor.x)

                                            x : Float
                                            x =
                                                cursor.x + cursorSpeed * cos direction

                                            y : Float
                                            y =
                                                cursor.y + cursorSpeed * sin direction
                                        in
                                        { x = x
                                        , y = y
                                        , isBonus = cursor.isBonus
                                        , isAttached =
                                            (abs (gifCenterX - x) < gif.width / 2)
                                                && (abs (gifCenterY - y) < gif.height / 2)
                                        , isDead = cursor.isDead
                                        }
                                            |> Just
                    in
                    { model
                        | gameState =
                            { gun = gameState.gun
                            , machineGunAmmo = gameState.machineGunAmmo
                            , shotgunAmmo = gameState.shotgunAmmo
                            , bombAmmo = gameState.bombAmmo
                            , elapsedTime = elapsed2
                            , cursors = newCursors ++ List.filterMap updateCursor gameState.cursors
                            , dogsGif = { gif | x = gif.x + dragX, y = gif.y + dragY }
                            , pageHeight = gameState.pageHeight
                            }
                                |> Just
                    }

                Nothing ->
                    model
            , Cmd.none
            )

        GotDogsAndPageImage result ->
            case ( model.gameState, result ) of
                ( Just gameState, Ok ( element, pageHeight ) ) ->
                    ( { model | gameState = Just { gameState | dogsGif = element, pageHeight = pageHeight } }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )


subscriptions : a -> b -> c -> Model -> Sub Msg
subscriptions _ _ _ model =
    Sub.batch
        [ case model.gameState of
            Just _ ->
                Sub.batch
                    [ Browser.Events.onMouseDown
                        (Json.Decode.map4
                            MouseDownData
                            (Json.Decode.field "clientX" Json.Decode.float)
                            (Json.Decode.field "clientY" Json.Decode.float)
                            (Json.Decode.field "pageX" Json.Decode.float)
                            (Json.Decode.field "pageY" Json.Decode.float)
                            |> Json.Decode.map MouseDown
                        )
                    , Browser.Events.onAnimationFrameDelta AnimationFrameDelta
                    ]

            Nothing ->
                Sub.none
        , if model.videoIsPlaying then
            Browser.Events.onKeyDown
                (Json.Decode.field "key" Json.Decode.string
                    |> Json.Decode.andThen
                        (\key ->
                            if key == "ArrowLeft" then
                                Json.Decode.succeed (PressedArrowKey LeftArrowKey)

                            else if key == "ArrowRight" then
                                Json.Decode.succeed (PressedArrowKey RightArrowKey)

                            else if key == "1" then
                                Json.Decode.succeed (PressedGunKey Handgun)

                            else if key == "2" then
                                Json.Decode.succeed (PressedGunKey MachineGun)

                            else if key == "3" then
                                Json.Decode.succeed (PressedGunKey Shotgun)

                            else if key == "4" then
                                Json.Decode.succeed (PressedGunKey Bomb)

                            else
                                Json.Decode.fail ""
                        )
                )

          else
            Sub.none
        ]


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
    , previewText : String
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
                            , previewText = thing.previewText
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
            { url = Pages.Url.fromPath (String.split "/" app.data.thing.previewImage)
            , alt = ""
            , dimensions = Just { width = Shared.tileWidth, height = Shared.tileWidth }
            , mimeType = Nothing
            }
        , description = app.data.thing.previewText
        , locale = Nothing
        , title = app.data.thing.name
        }
        |> Seo.website


type alias Cursor =
    { x : Float, y : Float, isBonus : Bool, isAttached : Bool, isDead : Maybe { diedAt : Float } }


getAmmo : Random.Generator GunType
getAmmo =
    Random.weighted
        ( 0.5, MachineGun )
        [ ( 0.35, Shotgun )
        , ( 0.15, Bomb )
        ]


spawnCursors : Int -> Int -> Int -> Random.Generator (List Cursor)
spawnCursors windowWidth windowHeight timeElapsed =
    Random.andThen
        (\t2 ->
            if t2 > 0.995 - (toFloat timeElapsed / 100000) then
                Random.map3
                    (\t side count ->
                        let
                            x : Int
                            x =
                                if side == 0 || side == 2 then
                                    round (toFloat windowWidth * t)

                                else if side == 1 then
                                    windowWidth

                                else
                                    0

                            y : Int
                            y =
                                if side == 1 || side == 3 then
                                    round (toFloat windowHeight * t)

                                else if side == 2 then
                                    windowHeight

                                else
                                    0
                        in
                        Random.list
                            count
                            (Random.map3
                                (\x2 y2 isBonus ->
                                    { x = toFloat x2
                                    , y = toFloat y2
                                    , isBonus = isBonus
                                    , isAttached = False
                                    , isDead = Nothing
                                    }
                                )
                                (Random.int (x - 50) (x + 50))
                                (Random.int (y - 50) (y + 50))
                                (Random.weighted ( 0.8, False ) [ ( 0.2, True ) ])
                            )
                    )
                    (Random.float 0 1)
                    (Random.int 0 3)
                    (Random.int 1 5)
                    |> Random.andThen identity

            else
                Random.constant []
        )
        (Random.float 0 1)


drawSprite : String -> Float -> Float -> Int -> Html msg
drawSprite sprite x y rotation =
    Html.img
        [ Html.Attributes.style "position" "absolute"
        , Html.Attributes.style "left" (String.fromFloat (x - 14) ++ "px")
        , Html.Attributes.style "top" (String.fromFloat (y - 14) ++ "px")
        , Html.Attributes.style "pointer-events" "none"
        , Html.Attributes.src ("/secret-santa-game/" ++ sprite)
        , Html.Attributes.style "transform" ("rotate(" ++ String.fromInt (modBy 360 rotation) ++ "deg)")
        ]
        []


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view app shared model =
    let
        thing : Thing
        thing =
            app.data.thing
    in
    { title = thing.name
    , overlay =
        case model.gameState of
            Just gameState ->
                Html.div
                    [ Html.Attributes.style "position" "absolute"
                    , Html.Attributes.style "top" "0"
                    , Html.Attributes.style "left" "0"
                    , Html.Attributes.style "overflow" "hidden"
                    , Html.Attributes.style "width" "100%"
                    , Html.Attributes.style "height" (String.fromFloat gameState.pageHeight ++ "px")
                    , Html.Attributes.style "pointer-events" "none"
                    ]
                    [ Html.audio
                        [ Html.Attributes.src "/secret-santa-game/audio/norwegian_pirate.mp3"
                        , Html.Attributes.autoplay True
                        ]
                        []
                    , Html.img
                        [ Html.Attributes.src "/secret-santa-game/omfgdogs.gif"
                        , Html.Attributes.style "width" (String.fromFloat gameState.dogsGif.width ++ "px")
                        , Html.Attributes.style "height" (String.fromFloat gameState.dogsGif.height ++ "px")
                        , Html.Attributes.style "position" "absolute"
                        , Html.Attributes.style "left" (String.fromFloat gameState.dogsGif.x ++ "px")
                        , Html.Attributes.style "top" (String.fromFloat gameState.dogsGif.y ++ "px")
                        , Html.Attributes.style "pointer-events" "none"
                        ]
                        []
                    , List.map
                        (\cursor ->
                            let
                                ( offsetX, offsetY, rotation ) =
                                    case cursor.isDead of
                                        Just { diedAt } ->
                                            let
                                                elapsed2 =
                                                    gameState.elapsedTime - diedAt
                                            in
                                            ( elapsed2 / 30, (elapsed2 / 30) ^ 2 + 1, elapsed2 )

                                        Nothing ->
                                            ( 0, 0, 0 )
                            in
                            drawSprite
                                (if cursor.isBonus then
                                    "cursor2.png"

                                 else
                                    "cursor.png"
                                )
                                (cursor.x + offsetX)
                                (cursor.y + offsetY)
                                (round rotation)
                        )
                        gameState.cursors
                        |> Html.div [ Html.Attributes.style "position" "absolute" ]
                    , List.map
                        (\{ x, y, gunType } -> drawSprite "bullet-hole.png" x y (round x * 1000))
                        model.bulletHoles
                        |> List.reverse
                        |> Html.div [ Html.Attributes.style "position" "absolute" ]
                    ]

            Nothing ->
                Html.div [] []
    , body =
        Ui.column
            (case model.gameState of
                Just _ ->
                    [ Html.Attributes.style "cursor" "crosshair" |> Ui.htmlAttribute
                    , Html.Attributes.style "user-select" "none" |> Ui.htmlAttribute
                    ]

                Nothing ->
                    []
            )
            [ Shared.header Nothing
            , Ui.column
                [ Ui.Responsive.paddingXY
                    Shared.breakpoints
                    (\label ->
                        case label of
                            Mobile ->
                                { x = Ui.Responsive.value Formatting.sidePaddingMobile
                                , y = Ui.Responsive.value 16
                                }

                            NotMobile ->
                                { x = Ui.Responsive.value Formatting.sidePaddingNotMobile
                                , y = Ui.Responsive.value 16
                                }
                    )
                , Ui.widthMax Formatting.contentWidthMax
                , Ui.centerX
                , Ui.spacing 8
                ]
                [ title thing
                , if List.isEmpty thing.description then
                    Ui.text "TODO"

                  else
                    Ui.Lazy.lazy5
                        Formatting.view
                        (model.gameState /= Nothing)
                        shared
                        msgConfig
                        model
                        thing.description
                , Ui.el [ Ui.height (Ui.px 100) ] Ui.none
                ]
            ]
    }


msgConfig : Formatting.Config (PagesMsg Msg)
msgConfig =
    { pressedAltText = \text -> PressedAltText text |> PagesMsg.fromMsg
    , startedVideo = StartedVideo |> PagesMsg.fromMsg
    , pressedStartShootEmUp = PressedStartShootEmUp |> PagesMsg.fromMsg
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
                        "Released on " ++ Date.toIsoString releasedAt |> Ui.text

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
                                            , " ("
                                                ++ String.fromInt (Date.diff Date.Months startedAt a)
                                                ++ "\u{00A0}months)"
                                                |> Ui.text
                                            ]

                                        Nothing ->
                                            [ Ui.el [ Ui.Font.bold ] (Ui.text "present day") ]
                                   )
                            )

                    PodcastThing { releasedAt } ->
                        "Released on " ++ Date.toIsoString releasedAt |> Ui.text

                    GameMakerThing { releasedAt } ->
                        Ui.text ("Released on " ++ Date.toIsoString releasedAt)
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
