module Route.AboutMe exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import Effect
import FatalError
import Formatting exposing (Formatting(..), Inline(..))
import Head
import Html
import PagesMsg
import ParserUtils
import Route exposing (Route(..))
import RouteBuilder
import Set exposing (Set)
import Shared exposing (Breakpoints(..))
import Ui
import Ui.Font
import Ui.Prose
import Ui.Responsive
import UrlPath
import View


type alias Model =
    { selectedAltText : Set String }


type Msg
    = PressedAltText String


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
init app shared =
    ( { selectedAltText = Set.empty }, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case msg of
        PressedAltText altText ->
            ( { model | selectedAltText = Set.insert altText model.selectedAltText }, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    { description : List Formatting }


type alias ActionData =
    BackendTask.BackendTask FatalError.FatalError (List RouteParams)


data : BackendTask.BackendTask FatalError.FatalError Data
data =
    BackendTask.succeed
        { description =
            [ Paragraph
                [ Text "I'm Martin Stewart! I'm a Swedish American (American Swede?) living in Stockholm." ]
            , Paragraph
                [ Text "I like making things, mostly computer programs, and this website is an attempt at keeping track of all the stuff that I've made. Some of that stuff is "
                , Link "cool" (Stuff__Slug_ { slug = "circuit-breaker" })
                , Text ", other stuff is "
                , Link "cringey garbage" (Stuff__Slug_ { slug = "demon-clutched-walkaround" })
                , Text " but worth remembering anyway."
                ]
            , Paragraph
                [ Text "I also like biking, jogging, walking, bouldering, and board games (ordered by velocity)."
                ]
            , Paragraph
                [ Text "If you want to say hello, I'm Martin Stewart on Elm Slack and "
                , ExternalLink "MartinS" "discourse.elm-lang.org/u/martins"
                , Text " on Elm Discourse."
                ]
            ]
        }


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "About me"
    , body =
        Ui.row
            [ Ui.widthMax 1000
            , Ui.centerX
            , Ui.contentTop
            , Ui.height Ui.fill
            ]
            [ Ui.image
                [ Ui.widthMin 250
                , Ui.Responsive.visible Shared.breakpoints [ NotMobile ]
                ]
                { source = "/about-me.jpg"
                , description = "A photo of me pretending to steal a bag of money"
                , onLoad = Nothing
                }
            , Ui.column
                [ Ui.spacing 64, Ui.height Ui.fill ]
                [ Ui.column
                    [ Ui.Responsive.paddingXY
                        Shared.breakpoints
                        (\label ->
                            case label of
                                Mobile ->
                                    { x = Ui.Responsive.value 8, y = Ui.Responsive.value 16 }

                                NotMobile ->
                                    { x = Ui.Responsive.value 16, y = Ui.Responsive.value 32 }
                        )
                    , Ui.spacing 16
                    ]
                    [ Ui.el [ Ui.Font.size 32, Ui.Font.bold, Ui.Font.lineHeight 1.1 ] (Ui.text "About me")
                    , Formatting.view
                        (\text -> PressedAltText text |> PagesMsg.fromMsg)
                        model
                        app.data.description
                    ]
                , Ui.image
                    [ Ui.Responsive.visible Shared.breakpoints [ Mobile ]
                    , Ui.alignBottom
                    ]
                    { source = "/about-me-mobile.jpg"
                    , description = "A photo of me pretending to steal a bag of money from someone's house"
                    , onLoad = Nothing
                    }
                ]
            ]
    }
