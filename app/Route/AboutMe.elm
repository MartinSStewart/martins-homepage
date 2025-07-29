module Route.AboutMe exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import BackendTask.Time
import Date exposing (Date)
import Effect
import FatalError
import Formatting exposing (Formatting(..), Inline(..))
import Head
import Html
import Html.Attributes
import Icons
import List.Extra
import List.Nonempty exposing (Nonempty(..))
import PagesMsg exposing (PagesMsg)
import Route exposing (Route(..))
import RouteBuilder
import Set exposing (Set)
import Shared exposing (Breakpoints(..))
import Time
import Ui
import Ui.Font
import Ui.Input
import Ui.Responsive
import UrlPath
import View


type alias Model =
    { selectedAltText : Set String, photoIndex : Int }


type Msg
    = PressedAltText String
    | PressedNextPhoto
    | PressedPreviousPhoto
    | StartedVideo


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
    ( { selectedAltText = Set.empty, photoIndex = 0 }, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update _ _ msg model =
    case msg of
        PressedAltText altText ->
            ( { model | selectedAltText = Set.insert altText model.selectedAltText }, Effect.none )

        PressedNextPhoto ->
            ( { model | photoIndex = model.photoIndex + 1 |> min (List.Nonempty.length photos - 1) }
            , Effect.none
            )

        PressedPreviousPhoto ->
            ( { model | photoIndex = model.photoIndex - 1 |> max 0 }, Effect.none )

        StartedVideo ->
            ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


photos : Nonempty ( String, List Inline )
photos =
    Nonempty
        ( "tretton37-meetup-photo.jpg"
        , [ Text "Taken at a "
          , Link "tretton37" (Route.Stuff__Slug_ { slug = "tretton37" })
          , Text " after work meetup."
          ]
        )
        [ ( "about-me.jpg"
          , [ Text "We had a contest at "
            , Link "Insurello" (Route.Stuff__Slug_ { slug = "insurello" })
            , Text " to take a photo of something starting with "
            , Quote "S"
            , Text ". I chose "
            , Quote "Stealing"
            , Text " and my photo won."
            ]
          )
        , ( "resume-photo.jpg", [ Text "22 year old me posing in the bathroom for a resume photo." ] )
        , ( "hair-pizza.jpg", [ Text "There's hair in my pizza." ] )
        , ( "hair-pizza-2.jpg", [ Text "My goodness that's a lot of hair." ] )
        ]
        |> List.Nonempty.map (\( url, a ) -> ( "/about-me/" ++ url, a ))


imageCollection : Int -> Nonempty ( String, List Inline ) -> Model -> Ui.Element (PagesMsg Msg)
imageCollection index images model =
    let
        ( imageUrl, altText ) =
            List.Nonempty.get index images
    in
    Ui.row
        []
        [ Ui.el
            [ Ui.height Ui.fill
            , Ui.background (Ui.rgb 240 240 240)
            , Ui.Input.button (PagesMsg.fromMsg PressedPreviousPhoto)
            ]
            (Ui.html Icons.chevronLeft)
        , Html.figure
            [ Html.Attributes.style "padding-bottom" "16px", Html.Attributes.style "margin" "0" ]
            [ Html.img
                [ Html.Attributes.src imageUrl
                , Html.Attributes.style "max-width" "500px"
                , Html.Attributes.style "max-height" "500px"
                , Html.Attributes.style "border-radius" "4px"
                ]
                []
            , Html.figcaption
                [ Html.Attributes.style "font-size" "14px"
                , Html.Attributes.style "padding" "0 8px 0 8px "
                ]
                (List.map
                    (Formatting.inlineView
                        { pressedAltText = \text -> PressedAltText text |> PagesMsg.fromMsg }
                        model
                    )
                    altText
                )
            ]
            |> Ui.html
        , Ui.el
            [ Ui.height Ui.fill
            , Ui.background (Ui.rgb 240 240 240)
            , Ui.Input.button (PagesMsg.fromMsg PressedNextPhoto)
            ]
            (Ui.html Icons.chevronRight)
        ]


type alias Data =
    { description : List Formatting }


type alias ActionData =
    BackendTask.BackendTask FatalError.FatalError (List RouteParams)


birthday : Date
birthday =
    Date.fromCalendarDate 1993 Time.Oct 9


data : BackendTask.BackendTask FatalError.FatalError Data
data =
    BackendTask.map
        (\time ->
            { description =
                [ Paragraph
                    [ Text "I'm Martin Stewart! I'm "
                    , Date.diff Date.Years birthday (Date.fromPosix Time.utc time) |> String.fromInt |> Text
                    , Text " years old and I live in Stockholm."
                    ]
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
        )
        BackendTask.Time.now


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "About me"
    , body =
        Ui.column
            [ Ui.widthMax 1000
            , Ui.centerX
            , Ui.contentTop
            , Ui.height Ui.fill
            ]
            [ imageCollection model.photoIndex photos model
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
                        { pressedAltText = \text -> PressedAltText text |> PagesMsg.fromMsg
                        , startedVideo = StartedVideo |> PagesMsg.fromMsg
                        , windowWidth = shared.windowWidth
                        , devicePixelRatio = shared.devicePixelRatio
                        }
                        model
                        app.data.description
                    ]
                ]
            ]
    }
