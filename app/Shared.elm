module Shared exposing (Breakpoints(..), Data, Model, Msg(..), SharedMsg(..), breakpoints, template)

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
            []
            (Ui.column
                []
                [ header
                , pageView.body
                ]
            )
        ]
    , title = pageView.title
    }


type Breakpoints
    = Mobile
    | NotMobile


header =
    Ui.row
        [ Ui.background (Ui.rgb 200 200 200) ]
        [ Ui.el
            [ Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
            , Ui.link (Route.toString Route.Index)
            , Ui.paddingXY 8 4
            , Ui.width Ui.shrink
            ]
            (Ui.text "Martin's homepage")

        --, Ui.el
        --    [ Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
        --    , Ui.link (Route.toString Route.AboutMe)
        --    , Ui.alignRight
        --    ]
        --    (Ui.text "About me")
        ]


breakpoints : Ui.Responsive.Breakpoints Breakpoints
breakpoints =
    Ui.Responsive.breakpoints Mobile [ ( 500, NotMobile ) ]
