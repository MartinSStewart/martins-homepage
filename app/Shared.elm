module Shared exposing (Breakpoints(..), Data, Model, Msg(..), SharedMsg(..), breakpoints, template, tileSpacing, tileWidth)

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Html.Attributes
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Ui
import Ui.Anim
import Ui.Font
import Ui.Responsive
import UrlPath exposing (UrlPath)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type Msg
    = SharedMsg SharedMsg
    | MenuClicked
    | UiAnimMsg Ui.Anim.Msg


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    { showMenu : Bool
    , uiAnimModel : Ui.Anim.State
    }


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init flags maybePagePath =
    ( { showMenu = False, uiAnimModel = Ui.Anim.init }
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg globalMsg ->
            ( model, Effect.none )

        MenuClicked ->
            ( { model | showMenu = not model.showMenu }, Effect.none )

        UiAnimMsg uiAnimMsg ->
            ( { model | uiAnimModel = Ui.Anim.update UiAnimMsg uiAnimMsg model.uiAnimModel }, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data
    ->
        { path : UrlPath
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view sharedData page model toMsg pageView =
    { body =
        [ Ui.Anim.layout
            { options = []
            , toMsg = \msg -> UiAnimMsg msg |> toMsg
            , breakpoints = Just breakpoints
            }
            model.uiAnimModel
            [ Ui.height Ui.fill ]
            (Ui.column
                [ Ui.height Ui.fill ]
                [ header page.route
                , Ui.el
                    [ Ui.widthMax contentMaxWidth
                    , Ui.centerX
                    , Ui.height Ui.fill
                    , Ui.Responsive.paddingXY
                        breakpoints
                        (\label ->
                            case label of
                                Mobile ->
                                    { x = Ui.Responsive.value 0, y = Ui.Responsive.value 0 }

                                NotMobile ->
                                    { x = Ui.Responsive.value pagePadding, y = Ui.Responsive.value 0 }
                        )
                    ]
                    pageView.body
                ]
            )
        ]
    , title = pageView.title
    }


maxColumns : number
maxColumns =
    6


contentMaxWidth : number
contentMaxWidth =
    tileWidth * maxColumns + tileSpacing * (maxColumns - 1) + pagePadding * 2


pagePadding : number
pagePadding =
    16


tileWidth : number
tileWidth =
    190


tileSpacing : number
tileSpacing =
    8


type Breakpoints
    = Mobile
    | NotMobile


header : Maybe Route -> Ui.Element msg
header maybeRoute =
    Ui.row
        [ Ui.background (Ui.rgb 0 0 0), Ui.Font.bold, Ui.Font.color (Ui.rgb 255 255 255) ]
        [ Ui.row
            [ Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
            , Ui.link (Route.toString Route.Index)
            , Ui.Responsive.paddingXY
                breakpoints
                (\label ->
                    case label of
                        Mobile ->
                            { x = Ui.Responsive.value 8, y = Ui.Responsive.value 2 }

                        NotMobile ->
                            { x = Ui.Responsive.value 16, y = Ui.Responsive.value 2 }
                )
            , Ui.width Ui.shrink
            , Ui.spacing 4
            , if maybeRoute == Just Route.Index then
                Ui.Font.underline

              else
                Ui.noAttr
            ]
            [ Ui.image [ Ui.width (Ui.px 26) ]
                { source = "/profile.png"
                , description = "My online profile picture"
                , onLoad = Nothing
                }
            , Ui.text "Martin's homepage"
            ]
        , Ui.el
            [ Ui.alignRight
            , Ui.Responsive.paddingXY
                breakpoints
                (\label ->
                    case label of
                        Mobile ->
                            { x = Ui.Responsive.value 8, y = Ui.Responsive.value 2 }

                        NotMobile ->
                            { x = Ui.Responsive.value 16, y = Ui.Responsive.value 2 }
                )
            , Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
            , Ui.link (Route.toString Route.AboutMe)
            , if maybeRoute == Just Route.AboutMe then
                Ui.Font.underline

              else
                Ui.noAttr
            ]
            (Ui.text "About me")
        ]


breakpoints : Ui.Responsive.Breakpoints Breakpoints
breakpoints =
    Ui.Responsive.breakpoints Mobile [ ( 550, NotMobile ) ]
