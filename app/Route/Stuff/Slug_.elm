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
import Round
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
    , game : Maybe Game
    }


type alias Game =
    { gun : GunType
    , machineGunAmmo : Int
    , shotgunAmmo : Int
    , bombAmmo : Int
    , elapsedTime : Float
    , cursors : List Cursor
    , gif : { x : Float, y : Float }
    , gifStart : { x : Float, y : Float, width : Float, height : Float }
    , pageHeight : Float
    , gameEnded : Maybe { duration : Float, hideMenu : Bool }
    , lastSpawnCheck : Float
    , bulletHoles : List { x : Float, y : Float, gunType : GunType }
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
    | PressedRestart
    | PressedQuit
    | PressedHide


type alias MouseDownData =
    { clientX : Float, clientY : Float, pageX : Float, pageY : Float }


type ArrowKey
    = LeftArrowKey
    | RightArrowKey


type alias RouteParams =
    { slug : String }


init : App Data action routeParams -> Shared.Model -> ( Model, Cmd Msg )
init _ _ =
    ( { selectedAltText = Set.empty, videoIsPlaying = False, game = Nothing }
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


gameInit : { x : Float, y : Float, width : Float, height : Float } -> Shared.Model -> Game
gameInit gifStart shared =
    { gun = Handgun
    , machineGunAmmo = 0
    , shotgunAmmo = 0
    , bombAmmo = 0
    , elapsedTime = 0
    , cursors = []
    , gif = { x = gifStart.x, y = gifStart.y }
    , gifStart = gifStart
    , pageHeight = toFloat shared.windowHeight
    , gameEnded = Nothing
    , lastSpawnCheck = 0
    , bulletHoles = []
    }


update : App data action routeParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ shared msg model =
    case msg of
        PressedAltText altText ->
            ( { model | selectedAltText = Set.insert altText model.selectedAltText }, Effect.none )

        StartedVideo ->
            ( { model | videoIsPlaying = True }, Effect.none )

        PressedArrowKey arrowKey ->
            if model.videoIsPlaying then
                ( model
                , case arrowKey of
                    LeftArrowKey ->
                        skipBackwardVideo ()

                    RightArrowKey ->
                        skipForwardVideo ()
                )

            else
                ( model, Cmd.none )

        PressedStartShootEmUp ->
            case model.game of
                Just _ ->
                    ( model, Cmd.none )

                Nothing ->
                    ( { model | game = gameInit { x = 0, y = 0, width = 0, height = 0 } shared |> Just }
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
            case model.game of
                Just game ->
                    case game.gameEnded of
                        Just _ ->
                            ( model, Cmd.none )

                        Nothing ->
                            ( { model
                                | game =
                                    { gun = game.gun
                                    , machineGunAmmo = game.machineGunAmmo
                                    , shotgunAmmo = game.shotgunAmmo
                                    , bombAmmo = game.bombAmmo
                                    , elapsedTime = game.elapsedTime
                                    , lastSpawnCheck = game.lastSpawnCheck
                                    , bulletHoles = { x = pageX, y = pageY, gunType = Handgun } :: game.bulletHoles
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
                                                                | isDead = Just { diedAt = game.elapsedTime }
                                                                , isAttached = False
                                                            }

                                                        else
                                                            cursor
                                            )
                                            game.cursors
                                    , gif = game.gif
                                    , gifStart = game.gifStart
                                    , pageHeight = game.pageHeight
                                    , gameEnded = game.gameEnded
                                    }
                                        |> Just
                              }
                            , Cmd.batch
                                [ shoot { x = clientX, y = clientY }
                                , (case game.gun of
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
            case model.game of
                Just gameState ->
                    case gameState.gameEnded of
                        Just _ ->
                            ( model, Cmd.none )

                        Nothing ->
                            ( { model | game = Just { gameState | gun = gunType } }
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
            ( case model.game of
                Just gameState ->
                    { model | game = updateGameState shared elapsed gameState |> Just }

                Nothing ->
                    model
            , Cmd.none
            )

        GotDogsAndPageImage result ->
            case ( model.game, result ) of
                ( Just gameState, Ok ( element, pageHeight ) ) ->
                    ( { model
                        | game =
                            Just
                                { gameState
                                    | gifStart = element
                                    , gif = { x = element.x, y = element.y }
                                    , pageHeight = pageHeight
                                }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        PressedRestart ->
            ( case model.game of
                Just game ->
                    case game.gameEnded of
                        Just _ ->
                            { model | game = gameInit game.gifStart shared |> Just }

                        Nothing ->
                            model

                Nothing ->
                    model
            , Cmd.none
            )

        PressedQuit ->
            ( case model.game of
                Just game ->
                    case game.gameEnded of
                        Just _ ->
                            { model | game = Nothing }

                        Nothing ->
                            model

                Nothing ->
                    model
            , Cmd.none
            )

        PressedHide ->
            ( { model
                | game =
                    case model.game of
                        Just game ->
                            { game
                                | gameEnded =
                                    case game.gameEnded of
                                        Just ended ->
                                            { ended | hideMenu = not ended.hideMenu } |> Just

                                        Nothing ->
                                            Nothing
                            }
                                |> Just

                        Nothing ->
                            Nothing
              }
            , Cmd.none
            )


updateGameState : Shared.Model -> Float -> Game -> Game
updateGameState shared elapsed game =
    let
        elapsed2 =
            game.elapsedTime + elapsed
    in
    case game.gameEnded of
        Just _ ->
            let
                updateCursor : Cursor -> Maybe Cursor
                updateCursor cursor =
                    case cursor.isDead of
                        Just { diedAt } ->
                            if elapsed2 - diedAt > 2000 then
                                Nothing

                            else
                                Just cursor

                        Nothing ->
                            Just cursor
            in
            { game | cursors = List.filterMap updateCursor game.cursors, elapsedTime = elapsed2 }

        Nothing ->
            let
                cursorSpeed =
                    1.5

                {- Try spawning cursors 30 times per second -}
                doSpawnCheck : Bool
                doSpawnCheck =
                    elapsed2 - game.lastSpawnCheck > 1000 / 30

                newCursors : List Cursor
                newCursors =
                    if doSpawnCheck then
                        Random.step
                            (spawnCursors shared.windowWidth (round game.pageHeight) (round elapsed2))
                            (Random.initialSeed (elapsed2 * 10000 |> round))
                            |> Tuple.first

                    else
                        []

                gif =
                    game.gif

                gifCenterX : Float
                gifCenterX =
                    gif.x + game.gifStart.width / 2

                gifCenterY : Float
                gifCenterY =
                    gif.y + game.gifStart.height / 2

                dragCount =
                    List.Extra.count
                        (\cursor -> cursor.isAttached && cursor.isDead == Nothing)
                        game.cursors
                        |> toFloat

                pageCenterX =
                    toFloat shared.windowWidth / 2

                pageCenterY =
                    game.pageHeight / 2

                dragDirection =
                    atan2 (pageCenterY - gifCenterY) (pageCenterX - gifCenterX) + pi

                dragX =
                    dragCount * 0.2 * cos dragDirection

                dragY =
                    dragCount * 0.2 * sin dragDirection

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
                                    (abs (gifCenterX - x) < game.gifStart.width / 2)
                                        && (abs (gifCenterY - y) < game.gifStart.height / 2)
                                , isDead = cursor.isDead
                                }
                                    |> Just
            in
            { gun = game.gun
            , machineGunAmmo = game.machineGunAmmo
            , shotgunAmmo = game.shotgunAmmo
            , bombAmmo = game.bombAmmo
            , elapsedTime = elapsed2
            , bulletHoles = game.bulletHoles
            , lastSpawnCheck =
                game.lastSpawnCheck
                    + (if doSpawnCheck then
                        1000 / 30

                       else
                        0
                      )
            , cursors = newCursors ++ List.filterMap updateCursor game.cursors
            , gif = { gif | x = gif.x + dragX, y = gif.y + dragY }
            , gifStart = game.gifStart
            , pageHeight = game.pageHeight
            , gameEnded =
                if
                    (gif.x + game.gifStart.width < -20)
                        || (gif.y + game.gifStart.height < -20)
                        || (gif.x > toFloat shared.windowWidth + 20)
                        || (gif.y > game.pageHeight + 20)
                then
                    Just { duration = elapsed2, hideMenu = False }

                else
                    Nothing
            }


subscriptions : a -> b -> c -> Model -> Sub Msg
subscriptions _ _ _ model =
    Sub.batch
        [ case model.game of
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
        , Browser.Events.onKeyDown
            (Json.Decode.field "key" Json.Decode.string
                |> Json.Decode.andThen
                    (\key ->
                        if Debug.log "key" key == "ArrowLeft" then
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

                        else if key == "r" then
                            Json.Decode.succeed PressedRestart

                        else if key == "q" then
                            Json.Decode.succeed PressedQuit

                        else if key == "h" then
                            Json.Decode.succeed PressedHide

                        else
                            Json.Decode.fail ""
                    )
            )
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
            if t2 > 0.995 - (toFloat timeElapsed / 1000000) then
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
        case model.game of
            Just game ->
                Html.div
                    []
                    [ Html.div
                        [ Html.Attributes.style "position" "absolute"
                        , Html.Attributes.style "top" "0"
                        , Html.Attributes.style "left" "0"
                        , Html.Attributes.style "overflow" "hidden"
                        , Html.Attributes.style "width" "100%"
                        , Html.Attributes.style "height" (String.fromFloat game.pageHeight ++ "px")
                        , Html.Attributes.style "pointer-events" "none"
                        ]
                        [ case game.gameEnded of
                            Just _ ->
                                Html.audio
                                    [ Html.Attributes.src "/secret-santa-game/audio/sn_boo.mp3"
                                    , Html.Attributes.autoplay True
                                    ]
                                    []

                            Nothing ->
                                Html.audio
                                    [ Html.Attributes.src "/secret-santa-game/audio/norwegian_pirate.mp3"
                                    , Html.Attributes.autoplay True
                                    ]
                                    []
                        , Html.img
                            [ Html.Attributes.src "/secret-santa-game/omfgdogs.gif"
                            , Html.Attributes.style "width" (String.fromFloat game.gifStart.width ++ "px")
                            , Html.Attributes.style "height" (String.fromFloat game.gifStart.height ++ "px")
                            , Html.Attributes.style "position" "absolute"
                            , Html.Attributes.style "left" (String.fromFloat game.gif.x ++ "px")
                            , Html.Attributes.style "top" (String.fromFloat game.gif.y ++ "px")
                            , Html.Attributes.style "pointer-events" "none"
                            ]
                            []
                        , List.map
                            (\{ x, y, gunType } -> drawSprite "bullet-hole.png" x y (round x * 1000))
                            game.bulletHoles
                            |> List.reverse
                            |> Html.div [ Html.Attributes.style "position" "absolute" ]
                        , List.map
                            (\cursor ->
                                let
                                    ( offsetX, offsetY, rotation ) =
                                        case cursor.isDead of
                                            Just { diedAt } ->
                                                let
                                                    ( hSpeed, vSpeed, rSpeed ) =
                                                        Random.step
                                                            (Random.map3
                                                                (\a b c -> ( a, b, c ))
                                                                (Random.float -0.3 0.3)
                                                                (Random.float -0.3 0.3)
                                                                (Random.float -1 1)
                                                            )
                                                            (Random.initialSeed
                                                                (round
                                                                    (1000 * diedAt + cursor.x + cursor.y * 7)
                                                                )
                                                            )
                                                            |> Tuple.first

                                                    elapsed2 =
                                                        game.elapsedTime - diedAt
                                                in
                                                ( elapsed2 * hSpeed
                                                , (elapsed2 / 30) ^ 2 + elapsed2 * vSpeed
                                                , elapsed2 * rSpeed
                                                )

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
                            game.cursors
                            |> Html.div [ Html.Attributes.style "position" "absolute" ]
                        ]
                    , case game.gameEnded of
                        Just ended ->
                            if ended.hideMenu then
                                Html.text ""

                            else
                                Html.div
                                    [ Html.Attributes.style "color" "white"
                                    , Html.Attributes.style "position" "fixed"
                                    , Html.Attributes.style "top" "50%"
                                    , Html.Attributes.style "left" "50%"
                                    , Html.Attributes.style "transform" "translateX(-50%) translateY(-50%)"
                                    , Html.Attributes.style "text-align" "center"
                                    , Html.Attributes.style "font-size" "36px"
                                    , Html.Attributes.style "background-color" "rgba(0,0,0,0.8)"
                                    , Html.Attributes.style "padding" "16px"
                                    , Html.Attributes.style "border-radius" "8px"
                                    ]
                                    [ "Webpage ruined! You survived for "
                                        ++ Round.round 2 (ended.duration / 1000)
                                        ++ " seconds"
                                        |> Html.text
                                    , Html.hr [] []
                                    , Html.div
                                        [ Html.Attributes.style "font-size" "18px" ]
                                        [ Html.text "R key to restart" ]
                                    , Html.div
                                        [ Html.Attributes.style "font-size" "18px" ]
                                        [ Html.text "H key to hide window" ]
                                    , Html.div
                                        [ Html.Attributes.style "font-size" "18px" ]
                                        [ Html.text "Q key to quit" ]
                                    ]

                        Nothing ->
                            Html.text ""
                    ]

            Nothing ->
                Html.div [] []
    , body =
        Ui.column
            (case model.game of
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
                        (model.game /= Nothing)
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
