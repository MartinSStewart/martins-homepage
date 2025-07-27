module Route.Index exposing (ActionData, Data, Model, Msg, route)

import Array exposing (Array)
import BackendTask exposing (BackendTask)
import Browser.Dom
import Browser.Events
import Color.Manipulate
import Date exposing (Date)
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Attributes
import List.Extra
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Process
import Route
import RouteBuilder exposing (App)
import Set exposing (Set)
import Shared exposing (Breakpoints(..))
import Svg exposing (Svg)
import Svg.Attributes
import Task
import Things exposing (Tag(..), ThingType(..))
import Time exposing (Month(..))
import Ui
import Ui.Events
import Ui.Font
import Ui.Input
import Ui.Lazy
import Ui.Responsive
import Ui.Shadow
import UrlPath
import View exposing (View)


type alias Model =
    { filter : Set String, worstTier : Line, topTier : Line, timelineEventHover : Maybe String }


type Msg
    = ToggledTag Tag Bool
    | GotWorstTierPosition (Result Browser.Dom.Error (List Browser.Dom.Element))
    | GotTopTierPosition (Result Browser.Dom.Error (List Browser.Dom.Element))
    | WindowResized
    | MouseEnterTimelineEvent String
    | MouseLeaveTimelineEvent String


type SortBy
    = Alphabetical
    | Chronological
    | Quality


type alias RouteParams =
    {}


type alias Data =
    { thingsIHaveDone : Dict String Thing }


type alias Thing =
    { name : String
    , tags : List Tag
    , previewImage : String
    , thingType : ThingType
    , previewText : String
    }


type alias ActionData =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithLocalState
            { init = init
            , update = update
            , view = view
            , subscriptions = \_ _ _ _ -> Browser.Events.onResize (\_ _ -> WindowResized)
            }


init : App data action routeParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { filter = Set.empty
      , worstTier = NoLine
      , topTier = NoLine
      , timelineEventHover = Nothing
      }
    , getElements
    )


type Line
    = NoLine
    | HorizontalLine { xStart : Float, xEnd : Float, y : Float }
    | StaggeredLine { xStart : Float, xEnd : Float, y0 : Float, y1 : Float, x : Float }


type Tier
    = TopTier
    | MiddleTier
    | WorstTier


sortByFromApp : App Data ActionData RouteParams -> SortBy
sortByFromApp app =
    case app.url of
        Just url ->
            case Dict.get "sort" url.query of
                Just [ "alphabetical" ] ->
                    Alphabetical

                Just [ "chronological" ] ->
                    Chronological

                _ ->
                    Quality

        Nothing ->
            Quality


sortByToString : SortBy -> String
sortByToString sortBy =
    case sortBy of
        Quality ->
            "quality"

        Alphabetical ->
            "alphabetical"

        Chronological ->
            "chronological"


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update app _ msg model =
    case msg of
        ToggledTag tag isChecked ->
            ( { model
                | filter =
                    if isChecked then
                        Set.insert (Things.tagData tag).text model.filter

                    else
                        Set.remove (Things.tagData tag).text model.filter
              }
            , Cmd.none
            )

        WindowResized ->
            ( { model | worstTier = NoLine, topTier = NoLine }
            , if sortByFromApp app == Quality then
                getElements

              else
                Cmd.none
            )

        GotWorstTierPosition result ->
            ( { model | worstTier = getLines result }, Cmd.none )

        GotTopTierPosition result ->
            ( { model | topTier = getLines result }, Cmd.none )

        MouseEnterTimelineEvent id ->
            ( { model | timelineEventHover = Just id }, Cmd.none )

        MouseLeaveTimelineEvent id ->
            ( { model
                | timelineEventHover =
                    if Just id == model.timelineEventHover then
                        Nothing

                    else
                        model.timelineEventHover
              }
            , Cmd.none
            )


getLines : Result error (List Browser.Dom.Element) -> Line
getLines result =
    case result of
        Ok elements ->
            let
                elements2 : List Browser.Dom.Element
                elements2 =
                    List.Extra.gatherEqualsBy (\a -> round a.element.x) elements
                        |> List.filterMap (\( first, rest ) -> List.Extra.minimumBy (\a -> a.element.y) (first :: rest))
            in
            case List.Extra.gatherEqualsBy (\a -> a.element.y) elements2 of
                [] ->
                    NoLine

                [ ( first, _ ) ] ->
                    let
                        xStart : Float
                        xStart =
                            List.map (\a -> a.element.x) elements |> List.minimum |> Maybe.withDefault 0

                        xEnd : Float
                        xEnd =
                            List.map (\a -> a.element.x) elements
                                |> List.maximum
                                |> Maybe.withDefault 0
                                |> (+) Shared.tileWidth
                    in
                    HorizontalLine
                        { xStart = xStart
                        , xEnd = xEnd
                        , y = first.element.y - Shared.tileSpacing / 2 - Shared.headerHeight
                        }

                ( first, firstRest ) :: ( second, secondRest ) :: _ ->
                    let
                        xStart : Float
                        xStart =
                            List.map (\a -> a.element.x) elements |> List.minimum |> Maybe.withDefault 0

                        xEnd : Float
                        xEnd =
                            List.map (\a -> a.element.x) elements
                                |> List.maximum
                                |> Maybe.withDefault 0
                                |> (+) Shared.tileWidth

                        helper top topRest bottom =
                            StaggeredLine
                                { xStart = xStart
                                , xEnd = xEnd
                                , y0 = top.element.y - Shared.tileSpacing / 2 - Shared.headerHeight
                                , x =
                                    List.map (\a -> a.element.x) (top :: topRest)
                                        |> List.minimum
                                        |> Maybe.withDefault 0
                                        |> (\a -> a - Shared.tileSpacing / 2)
                                , y1 = bottom.element.y - Shared.tileSpacing / 2 - Shared.headerHeight
                                }
                    in
                    if first.element.y < second.element.y then
                        helper first firstRest second

                    else
                        helper second secondRest first

        Err _ ->
            NoLine


getElements : Cmd Msg
getElements =
    Cmd.batch
        [ -- Give the DOM some time to settle before we getElements
          Process.sleep 100
            |> Task.andThen
                (\() -> List.map (\name -> Browser.Dom.getElement name) topOfLowTier |> Task.sequence)
            |> Task.attempt GotWorstTierPosition
        , Process.sleep 100
            |> Task.andThen
                (\() -> List.map (\name -> Browser.Dom.getElement name) topOfTopTier |> Task.sequence)
            |> Task.attempt GotTopTierPosition
        ]


worstTier : List String
worstTier =
    List.Extra.dropWhile (\a -> a /= "sanctum") Things.qualityOrder


topOfLowTier : List String
topOfLowTier =
    List.take Shared.maxColumns worstTier


middleTier : List String
middleTier =
    List.Extra.dropWhile (\a -> a /= "secret-santa-game") Things.qualityOrder


topOfTopTier : List String
topOfTopTier =
    List.take Shared.maxColumns middleTier


data : BackendTask FatalError Data
data =
    validateQualityOrder
        |> BackendTask.map
            (\() ->
                { thingsIHaveDone =
                    Dict.map
                        (\_ thing ->
                            { name = thing.name
                            , tags = thing.tags
                            , previewImage = thing.previewImage
                            , previewText = thing.previewText
                            , thingType = thing.thingType
                            }
                        )
                        Things.thingsIHaveDone
                }
            )


validateQualityOrder : BackendTask FatalError ()
validateQualityOrder =
    let
        set : Set String
        set =
            Set.fromList (Dict.keys Things.thingsIHaveDone)

        set2 : Set String
        set2 =
            Set.fromList Things.qualityOrder

        missing : Set String
        missing =
            Set.diff set set2

        extra : Set String
        extra =
            Set.diff set2 set
    in
    case ( Set.isEmpty missing, Set.isEmpty extra ) of
        ( True, True ) ->
            BackendTask.succeed ()

        ( False, _ ) ->
            String.join ", " (List.map (\a -> "\"" ++ a ++ "\"") (Set.toList missing))
                ++ " are missing from Things.qualityOrder"
                |> FatalError.fromString
                |> BackendTask.fail

        ( True, False ) ->
            String.join ", " (List.map (\a -> "\"" ++ a ++ "\"") (Set.toList extra))
                ++ " in Things.qualityOrder don't exist in Things.thingsIHaveDone"
                |> FatalError.fromString
                |> BackendTask.fail


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Martin's homepage"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Stuff I've done that I don't want to forget"
        , locale = Nothing
        , title = "elm-pages is running"
        }
        |> Seo.website


thingDate : Thing -> Date
thingDate thing =
    case thing.thingType of
        JobThing record ->
            record.startedAt

        OtherThing record ->
            record.releasedAt

        PodcastThing record ->
            record.releasedAt

        GameMakerThing record ->
            record.releasedAt


svgLine : String -> String -> String -> String -> Line -> Ui.Element msg
svgLine aboveTier belowTier aboveColor belowColor line =
    Svg.svg
        [ Html.Attributes.style "position" "relative"
        , Html.Attributes.style "top" "0"
        , Html.Attributes.style "left" "0"
        , Html.Attributes.style "width" "100%"
        , Html.Attributes.style "height" "100%"
        ]
        (case line of
            NoLine ->
                []

            HorizontalLine { xStart, xEnd, y } ->
                [ Svg.line
                    [ Svg.Attributes.x1 (String.fromFloat (xStart - Shared.pagePadding))
                    , Svg.Attributes.x2 (String.fromFloat (xEnd + Shared.pagePadding))
                    , Svg.Attributes.y1 (String.fromFloat (y + 2))
                    , Svg.Attributes.y2 (String.fromFloat (y + 2))
                    , Svg.Attributes.strokeWidth "2"
                    , Svg.Attributes.stroke belowColor
                    ]
                    []
                , Svg.line
                    [ Svg.Attributes.x1 (String.fromFloat (xStart - Shared.pagePadding))
                    , Svg.Attributes.x2 (String.fromFloat (xEnd + Shared.pagePadding))
                    , Svg.Attributes.y1 (String.fromFloat (y - 2))
                    , Svg.Attributes.y2 (String.fromFloat (y - 2))
                    , Svg.Attributes.strokeWidth "2"
                    , Svg.Attributes.stroke aboveColor
                    ]
                    []
                , svgText "start" belowColor (xStart - Shared.pagePadding) (y + 16) belowTier
                , svgText "start" aboveColor (xStart - Shared.pagePadding) (y - 6) aboveTier
                , svgText "end" belowColor (xEnd + Shared.pagePadding) (y + 16) belowTier
                , svgText "end" aboveColor (xEnd + Shared.pagePadding) (y - 6) aboveTier
                ]

            StaggeredLine { xStart, xEnd, x, y0, y1 } ->
                [ Svg.path
                    [ "M "
                        ++ String.fromFloat (xStart - Shared.pagePadding)
                        ++ " "
                        ++ String.fromFloat (y1 + 2)
                        ++ " H "
                        ++ String.fromFloat (x + 2)
                        ++ " V "
                        ++ String.fromFloat (y0 + 2)
                        ++ " H "
                        ++ String.fromFloat (xEnd + Shared.pagePadding)
                        |> Svg.Attributes.d
                    , Svg.Attributes.strokeWidth "2"
                    , Svg.Attributes.stroke belowColor
                    , Svg.Attributes.fill "none"
                    ]
                    []
                , Svg.path
                    [ "M "
                        ++ String.fromFloat (xStart - Shared.pagePadding)
                        ++ " "
                        ++ String.fromFloat (y1 - 2)
                        ++ " H "
                        ++ String.fromFloat (x - 2)
                        ++ " V "
                        ++ String.fromFloat (y0 - 2)
                        ++ " H "
                        ++ String.fromFloat (xEnd + Shared.pagePadding)
                        |> Svg.Attributes.d
                    , Svg.Attributes.strokeWidth "2"
                    , Svg.Attributes.stroke aboveColor
                    , Svg.Attributes.fill "none"
                    ]
                    []
                , svgText "start" belowColor (xStart - Shared.pagePadding) (y1 + 16) belowTier
                , svgText "start" aboveColor (xStart - Shared.pagePadding) (y1 - 6) aboveTier
                , svgText "end" belowColor (xEnd + Shared.pagePadding) (y0 + 16) belowTier
                , svgText "end" aboveColor (xEnd + Shared.pagePadding) (y0 - 6) aboveTier
                ]
        )
        |> Ui.html
        |> Ui.el
            [ Ui.Responsive.visible Shared.breakpoints [ NotMobile ]
            , Ui.height Ui.fill
            , Ui.htmlAttribute (Html.Attributes.style "pointer-events" "none")
            ]


svgText : String -> String -> Float -> Float -> String -> Svg msg
svgText anchor color x y text =
    Svg.text_
        [ Svg.Attributes.x (String.fromFloat x)
        , Svg.Attributes.y (String.fromFloat y)
        , Svg.Attributes.textAnchor anchor
        , Svg.Attributes.fill color
        , Svg.Attributes.style "font-weight: 700; font-size: 14px"
        ]
        [ Svg.text text ]


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app _ model =
    let
        thingsDone0 : Dict String ( Tier, Thing )
        thingsDone0 =
            Dict.map (\_ thing -> ( TopTier, thing )) app.data.thingsIHaveDone

        thingsDone1 : Dict String ( Tier, Thing )
        thingsDone1 =
            List.foldl
                (\name dict ->
                    Dict.update name (Maybe.map (Tuple.mapFirst (\_ -> MiddleTier))) dict
                )
                thingsDone0
                middleTier

        thingsDone2 : Dict String ( Tier, Thing )
        thingsDone2 =
            List.foldl
                (\name dict ->
                    Dict.update name (Maybe.map (Tuple.mapFirst (\_ -> WorstTier))) dict
                )
                thingsDone1
                worstTier

        sortBy : SortBy
        sortBy =
            sortByFromApp app

        thingsSorted : List ( String, ( Tier, Thing ) )
        thingsSorted =
            case sortBy of
                Alphabetical ->
                    Dict.toList thingsDone2

                Quality ->
                    List.foldl
                        (\name list ->
                            case Dict.get name thingsDone2 of
                                Just thing ->
                                    ( name, thing ) :: list

                                Nothing ->
                                    list
                        )
                        []
                        Things.qualityOrder
                        |> List.reverse

                Chronological ->
                    Dict.toList thingsDone2
                        |> List.sortWith (\( _, ( _, a ) ) ( _, ( _, b ) ) -> Date.compare (thingDate b) (thingDate a))

        filterThings viewFunc ( name, ( tier, thing ) ) =
            if Set.isEmpty model.filter then
                viewFunc name tier thing |> Just

            else if
                Set.toList model.filter
                    |> List.all
                        (\tag ->
                            List.any
                                (\tag2 -> Things.tagData tag2 |> .text |> (==) tag)
                                thing.tags
                        )
            then
                viewFunc name tier thing |> Just

            else
                Nothing
    in
    { title = "Martin's homepage"
    , body =
        Ui.el
            (if sortBy == Quality then
                [ svgLine "Middle tier" "Worst tier" "orange" "red" model.worstTier |> Ui.inFront
                , svgLine "Top tier" "Middle tier" "#1293d8" "orange" model.topTier |> Ui.inFront
                ]

             else
                []
            )
            (Ui.column
                [ Ui.spacing 16
                , Ui.widthMax Shared.contentMaxWidth
                , Ui.centerX
                , Ui.height Ui.fill
                , Ui.Responsive.paddingXY
                    Shared.breakpoints
                    (\label ->
                        case label of
                            Mobile ->
                                { x = Ui.Responsive.value 8, y = Ui.Responsive.value 16 }

                            NotMobile ->
                                { x = Ui.Responsive.value Shared.pagePadding, y = Ui.Responsive.value 16 }
                    )
                ]
                [ Ui.el
                    [ Ui.Font.size 32, Ui.Font.bold, Ui.Font.lineHeight 1.1 ]
                    (Ui.text "Stuff I've done that I don't want to forget")
                , Ui.column
                    [ Ui.spacing 16 ]
                    [ filterView sortBy model
                    , if sortBy == Chronological then
                        timelineView app.data.thingsIHaveDone model

                      else
                        Ui.row
                            [ Ui.wrap
                            , Ui.spacing Shared.tileSpacing
                            , Ui.contentCenterX
                            , Ui.Responsive.visible Shared.breakpoints [ NotMobile ]
                            ]
                            (List.filterMap (filterThings thingsViewNotMobile) thingsSorted)
                    , if sortBy == Chronological then
                        Ui.none

                      else
                        Ui.column
                            [ Ui.spacing Shared.tileSpacing
                            , Ui.Responsive.visible Shared.breakpoints [ Mobile ]
                            ]
                            (List.filterMap (filterThings thingsViewMobile) thingsSorted)
                    ]
                ]
                |> Ui.map PagesMsg.fromMsg
            )
    }


timelineView : Dict String Thing -> Model -> Ui.Element Msg
timelineView things model =
    let
        things2 : Dict ( Int, Int ) (List ( String, Thing ))
        things2 =
            List.foldl
                (\thing dict ->
                    case (Tuple.second thing).thingType of
                        OtherThing { releasedAt } ->
                            Dict.update
                                ( Date.year releasedAt, Date.monthNumber releasedAt - 1 )
                                (\maybe -> Maybe.withDefault [] maybe |> (::) thing |> Just)
                                dict

                        JobThing _ ->
                            dict

                        PodcastThing { releasedAt } ->
                            Dict.update
                                ( Date.year releasedAt, Date.monthNumber releasedAt )
                                (\maybe -> Maybe.withDefault [] maybe |> (::) thing |> Just)
                                dict

                        GameMakerThing { releasedAt } ->
                            Dict.update
                                ( Date.year releasedAt, Date.monthNumber releasedAt )
                                (\maybe -> Maybe.withDefault [] maybe |> (::) thing |> Just)
                                dict
                )
                Dict.empty
                (Dict.toList things)

        durations : List { id : Maybe String, startedAt : Int, endedAt : Int, name : String, color : Ui.Color, columnIndex : Int }
        durations =
            List.filterMap
                (\( id, thing ) ->
                    case thing.thingType of
                        OtherThing { releasedAt } ->
                            Nothing

                        JobThing { startedAt, endedAt, columnIndex } ->
                            Just
                                { id = Just id
                                , startedAt = yearAndMonthToCount (Date.year startedAt) (Date.month startedAt)
                                , endedAt =
                                    case endedAt of
                                        Just a ->
                                            yearAndMonthToCount (Date.year a) (Date.month a)

                                        Nothing ->
                                            currentDate2
                                , name = thing.name ++ " job"
                                , color =
                                    if List.member Lamdera thing.tags then
                                        Things.lamderaColor

                                    else if List.member CSharp thing.tags then
                                        Things.csharpColor

                                    else if List.member Elm thing.tags then
                                        Things.elmColor

                                    else if List.member GameMaker thing.tags then
                                        Things.gameMakerColor

                                    else
                                        Ui.rgb 0 0 0
                                , columnIndex = columnIndex
                                }

                        PodcastThing _ ->
                            Nothing

                        GameMakerThing _ ->
                            Nothing
                )
                (Dict.toList things)
    in
    timelineViewHelper currentDate2 9 [] things2 durations model


yearAndMonthToCount : Int -> Month -> Int
yearAndMonthToCount year month =
    12 * (year - 1993) + (Date.monthToNumber month - 1)


bornAt : Int
bornAt =
    yearAndMonthToCount 1993 Oct


darkAgesEnd : Int
darkAgesEnd =
    yearAndMonthToCount 2007 Jan


gameMakerEraEnd : Int
gameMakerEraEnd =
    yearAndMonthToCount 2016 Nov


csharpEraEnd =
    yearAndMonthToCount 2018 Nov


currentDate2 =
    yearAndMonthToCount 2025 Sep


timelineBlock : Maybe String -> Ui.Color -> String -> Int -> Int -> Int -> Maybe (Ui.Element msg)
timelineBlock maybeId color text startDate endDate count =
    if endDate <= count || startDate > count then
        Nothing

    else
        Ui.el
            ([ Ui.width (Ui.px timelineBlockWidth)
             , Ui.height Ui.fill
             , Ui.background color
             , if endDate == count + 6 then
                Ui.inFront
                    (Ui.el
                        [ Ui.rotate (Ui.turns 0.75)
                        , Ui.Font.exactWhitespace
                        , Ui.Font.color (Ui.rgb 255 255 255)
                        , Ui.move { x = 0, y = 0, z = 0 }
                        ]
                        (Ui.text text)
                    )

               else
                Ui.noAttr
             ]
                ++ (case maybeId of
                        Just id ->
                            [ Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
                            , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = id }))
                            ]

                        Nothing ->
                            []
                   )
            )
            Ui.none
            |> Just


timelineBlockWidth : number
timelineBlockWidth =
    22


timelineViewHelper :
    Int
    -> Int
    -> List (Ui.Element Msg)
    -> Dict ( Int, Int ) (List ( String, Thing ))
    -> List { id : Maybe String, startedAt : Int, endedAt : Int, name : String, color : Ui.Color, columnIndex : Int }
    -> Model
    -> Ui.Element Msg
timelineViewHelper currentDate count list thingsSorted durations model =
    let
        month : Int
        month =
            modBy 12 count

        year : Int
        year =
            1993 + count // 12

        columns : List (Ui.Element Msg)
        columns =
            List.foldl
                (\a list2 ->
                    case timelineBlock a.id a.color a.name a.startedAt a.endedAt count of
                        Just element ->
                            List.Extra.setAt (a.columnIndex - 1) (Just element) list2

                        Nothing ->
                            list2
                )
                (List.repeat 2 Nothing)
                durations
                |> List.Extra.dropWhileRight (\a -> a == Nothing)
                |> List.map
                    (Maybe.withDefault
                        (Ui.el
                            [ Ui.width (Ui.px timelineBlockWidth)
                            , Ui.height Ui.fill
                            ]
                            Ui.none
                        )
                    )
    in
    if currentDate <= count then
        Ui.column [] list

    else
        timelineViewHelper
            currentDate
            (count + 1)
            (Ui.row
                [ Ui.spacing 8
                , Ui.behindContent
                    (Ui.el
                        [ Ui.height (Ui.px 1)
                        , Ui.background (Ui.rgb 200 200 200)
                        ]
                        Ui.none
                    )
                , Ui.height (Ui.px 40)
                ]
                ([ Ui.el
                    [ Ui.Font.family [ Ui.Font.monospace ]
                    , Ui.Font.size 16
                    , Ui.width Ui.shrink
                    , if Dict.member ( year, month ) thingsSorted then
                        Ui.Font.bold

                      else
                        Ui.noAttr
                    ]
                    (Ui.text (String.fromInt year ++ " " ++ monthToString month))
                 , timelineBlock Nothing (Ui.rgb 100 100 100) "No programming dark ages" bornAt darkAgesEnd count
                    |> Maybe.withDefault Ui.none
                 , timelineBlock Nothing Things.gameMakerColor "GameMaker era" darkAgesEnd gameMakerEraEnd count
                    |> Maybe.withDefault Ui.none
                 , timelineBlock Nothing Things.csharpColor "C# era" gameMakerEraEnd csharpEraEnd count
                    |> Maybe.withDefault Ui.none
                 , timelineBlock Nothing Things.elmColor "Elm era" csharpEraEnd currentDate count |> Maybe.withDefault Ui.none
                 ]
                    ++ columns
                    ++ [ case Dict.get ( year, month ) thingsSorted of
                            Just things ->
                                List.map
                                    (\( id, thing ) ->
                                        Ui.Lazy.lazy3 timelineEvent id thing (Just id == model.timelineEventHover)
                                    )
                                    things
                                    |> Ui.row [ Ui.spacing 4 ]

                            Nothing ->
                                Ui.none
                       ]
                )
                :: list
            )
            thingsSorted
            durations
            model


timelineEvent : String -> Thing -> Bool -> Ui.Element Msg
timelineEvent id thing showPreview =
    Ui.image
        [ Ui.width (Ui.px 39)
        , Ui.height (Ui.px 39)
        , Ui.alignBottom
        , Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
        , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = id }))
        , Ui.Events.onMouseEnter (MouseEnterTimelineEvent id)
        , Ui.Events.onMouseLeave (MouseLeaveTimelineEvent id)
        , if showPreview then
            Ui.row
                [ Ui.rounded 8
                , Ui.spacing 16
                , Ui.background (Ui.rgb 255 255 255)
                , Ui.move { x = -150 + 20, y = 50, z = 0 }
                , Ui.border 1
                , Ui.width (Ui.px 300)
                , Ui.htmlAttribute (Html.Attributes.style "z-index" "999")
                , Ui.padding 8
                , Ui.htmlAttribute (Html.Attributes.style "pointer-events" "none")
                , Ui.el
                    [ Ui.htmlAttribute (Html.Attributes.style "border-left" "10px solid transparent")
                    , Ui.htmlAttribute (Html.Attributes.style "border-right" "10px solid transparent")
                    , Ui.htmlAttribute (Html.Attributes.style "border-bottom" "10px solid white")
                    , Ui.width (Ui.px 0)
                    , Ui.centerX
                    , Ui.move { x = 0, y = -9, z = 0 }
                    ]
                    Ui.none
                    |> Ui.inFront
                , Ui.el
                    [ Ui.htmlAttribute (Html.Attributes.style "border-left" "10px solid transparent")
                    , Ui.htmlAttribute (Html.Attributes.style "border-right" "10px solid transparent")
                    , Ui.htmlAttribute (Html.Attributes.style "border-bottom" "10px solid black")
                    , Ui.width (Ui.px 0)
                    , Ui.centerX
                    , Ui.move { x = 0, y = -10, z = 0 }
                    ]
                    Ui.none
                    |> Ui.inFront
                ]
                [ Ui.image
                    [ Ui.width (Ui.px 100) ]
                    { source = thing.previewImage
                    , description = "Preview image"
                    , onLoad = Nothing
                    }
                , Ui.column
                    []
                    [ Ui.el [ Ui.Font.bold ] (Ui.text thing.name)
                    , Ui.text thing.previewText
                    ]
                ]
                |> Ui.inFront

          else
            Ui.noAttr
        ]
        { source = thing.previewImage, description = thing.name, onLoad = Nothing }


monthToString : Int -> String
monthToString month =
    case month of
        0 ->
            "Jan"

        1 ->
            "Feb"

        2 ->
            "Mar"

        3 ->
            "Apr"

        4 ->
            "May"

        5 ->
            "Jun"

        6 ->
            "Jul"

        7 ->
            "Aug"

        8 ->
            "Sep"

        9 ->
            "Oct"

        10 ->
            "Nov"

        _ ->
            "Dec"


containerBackgroundColor : Ui.Color
containerBackgroundColor =
    Ui.rgb 245 245 245


containerBackground : Ui.Attribute msg
containerBackground =
    Ui.background containerBackgroundColor


containerBorder : Ui.Color
containerBorder =
    Ui.rgb 210 210 210


sortByButtonAttributes : SortBy -> SortBy -> List (Ui.Attribute Msg)
sortByButtonAttributes selected sortBy =
    [ Ui.link (Route.toString Route.Index ++ "?sort=" ++ sortByToString sortBy)
    , Ui.border 1
    , Ui.paddingXY 8 2
    , Ui.borderColor containerBorder
    ]
        ++ (if selected == sortBy then
                [ Ui.background containerBorder
                ]

            else
                [ containerBackground ]
           )


tooltip : String -> Ui.Attribute msg
tooltip text =
    Ui.htmlAttribute (Html.Attributes.title text)


sortByView : SortBy -> Ui.Element Msg
sortByView sortBy =
    Ui.row
        [ Ui.width Ui.shrink, Ui.spacing 4, Ui.Font.size 14 ]
        [ Ui.el [ Ui.Font.bold ] (Ui.text "Sort by")
        , Ui.row
            [ Ui.width Ui.shrink ]
            [ Ui.el
                (Ui.roundedWith { topLeft = 16, topRight = 0, bottomLeft = 16, bottomRight = 0 }
                    :: Ui.border 1
                    :: tooltip "Sort by how important and high quality I think things are"
                    :: sortByButtonAttributes sortBy Quality
                )
                (Ui.text "Best to worst")
            , Ui.el
                (Ui.borderWith { left = 0, right = 0, top = 1, bottom = 1 }
                    :: tooltip "Sort by title names"
                    :: sortByButtonAttributes sortBy Alphabetical
                )
                (Ui.text "A to Z")
            , Ui.el
                (Ui.roundedWith { topLeft = 0, topRight = 16, bottomLeft = 0, bottomRight = 16 }
                    :: Ui.border 1
                    :: tooltip "Sort by when things were released. For stuff that doesn't have a clear release date, this is when it first became known to or used by several people (or when I abandoned it)"
                    :: sortByButtonAttributes sortBy Chronological
                )
                (Ui.text "Newest to oldest")
            ]
        ]


filterView : SortBy -> Model -> Ui.Element Msg
filterView sortBy model =
    Ui.column
        [ Ui.spacingWith { horizontal = 16, vertical = 8 }, Ui.wrap ]
        [ sortByView sortBy
        , if sortBy == Chronological then
            Ui.none

          else
            Ui.row
                [ Ui.spacing 4 ]
                [ Ui.el [ Ui.Font.size 14, Ui.Font.bold, Ui.width Ui.shrink ] (Ui.text "Filter by")
                , List.map (filterTagView model.filter) Things.allTags |> Ui.row [ Ui.spacing 4, Ui.wrap ]
                ]
        ]


thingsViewMobile : String -> Tier -> Thing -> Ui.Element Msg
thingsViewMobile name tier thing =
    Ui.row
        ([ containerBackground
         , Ui.borderColor containerBorder
         , Ui.border 1
         , Ui.rounded 4
         , Ui.alignTop
         , Ui.padding 4
         , Ui.spacing 4
         , Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
         , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = name }))
         ]
            ++ borderAndBackground tier
        )
        [ Ui.image
            [ Ui.width (Ui.px 100)
            , Ui.height (Ui.px 100)
            ]
            { source = thing.previewImage
            , description = "Preview image for " ++ thing.name
            , onLoad = Nothing
            }
        , Ui.column
            [ Ui.height Ui.fill ]
            [ Ui.el
                [ Ui.Font.bold
                , Ui.Font.size 20
                , Ui.Font.lineHeight 1
                ]
                (Ui.text thing.name)
            , Ui.text thing.previewText
            , Ui.row
                [ Ui.wrap
                , Ui.spacing 4
                , Ui.alignBottom
                ]
                (List.map tagView thing.tags)
            ]
        ]


worstTierColor : Ui.Color
worstTierColor =
    Ui.rgb 200 100 100


topTierBackground =
    Color.Manipulate.weightedMix containerBackgroundColor Things.elmColor 0.9


worstTierBackground =
    Color.Manipulate.weightedMix containerBackgroundColor worstTierColor 0.9


borderAndBackground : Tier -> List (Ui.Attribute msg)
borderAndBackground tier =
    [ Ui.background
        (case tier of
            MiddleTier ->
                containerBackgroundColor

            TopTier ->
                topTierBackground

            WorstTier ->
                worstTierBackground
        )
    , Ui.borderColor
        (case tier of
            MiddleTier ->
                containerBorder

            TopTier ->
                Things.elmColor

            WorstTier ->
                worstTierColor
        )
    , Ui.Shadow.shadows
        [ { x = 0
          , y = 0
          , size = 0
          , blur = 4
          , color =
                (case tier of
                    MiddleTier ->
                        containerBorder

                    TopTier ->
                        Things.elmColor

                    WorstTier ->
                        containerBorder
                )
                    |> Color.Manipulate.fadeOut 0.8
          }
        , { x = 0
          , y = 0
          , size = 0
          , blur = 2
          , color =
                (case tier of
                    MiddleTier ->
                        containerBorder

                    TopTier ->
                        Things.elmColor

                    WorstTier ->
                        worstTierColor
                )
                    |> Color.Manipulate.fadeOut 0.8
          }
        ]
    ]


thingsViewNotMobile : String -> Tier -> Thing -> Ui.Element Msg
thingsViewNotMobile name tier thing =
    Ui.el
        ([ Ui.width (Ui.px Shared.tileWidth)
         , Ui.heightMin Shared.tileWidth
         , Ui.border 1
         , Ui.rounded 4
         , Ui.padding 3
         , Ui.clip
         , Ui.alignTop
         , Ui.htmlAttribute (Html.Attributes.title thing.previewText)
         , Ui.id name
         , Ui.el
            [ Ui.Font.bold
            , Ui.Font.size
                (if String.length thing.name < 22 then
                    16

                 else
                    14
                )
            , Ui.Font.lineHeight 1
            , Ui.paddingWith { left = 4, right = 4, top = 1, bottom = 3 }
            , Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
            , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = name }))
            , Ui.opacity 0.85
            , Ui.background
                (case tier of
                    MiddleTier ->
                        containerBackgroundColor

                    TopTier ->
                        topTierBackground

                    WorstTier ->
                        worstTierBackground
                )
            ]
            (Ui.text thing.name)
            |> Ui.inFront
         ]
            ++ borderAndBackground tier
        )
        (Ui.image
            [ Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
            , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = name }))
            ]
            { source = thing.previewImage
            , description = "Preview image for " ++ thing.name
            , onLoad = Nothing
            }
        )


tagView : Tag -> Ui.Element Msg
tagView tag =
    let
        { text, color } =
            Things.tagData tag
    in
    Ui.el
        [ Ui.background color
        , Ui.rounded 8
        , Ui.paddingWith { left = 6, right = 6, top = 0, bottom = 2 }
        , Ui.Font.size 14
        , Ui.Font.color (Ui.rgb 255 255 255)
        , Ui.Font.noWrap
        , Ui.width Ui.shrink
        ]
        (Ui.text text)


tagCircleView : Tag -> Ui.Element Msg
tagCircleView tag =
    let
        { color } =
            Things.tagData tag
    in
    Ui.el
        [ Ui.background color, Ui.rounded 8, Ui.width (Ui.px 16), Ui.height (Ui.px 16) ]
        Ui.none


filterTagView : Set String -> Tag -> Ui.Element Msg
filterTagView selectedTags tag =
    let
        { text, color } =
            Things.tagData tag

        { element, id } =
            Ui.Input.label ("id_" ++ text) [] (Ui.text text)
    in
    Ui.row
        [ Ui.background color
        , Ui.rounded 8
        , Ui.paddingXY 6 2
        , Ui.Font.size 14
        , Ui.Font.color (Ui.rgb 255 255 255)
        , Ui.Font.noWrap
        , Ui.width Ui.shrink
        , Ui.spacing 4
        ]
        [ Ui.Input.checkbox
            []
            { onChange = ToggledTag tag
            , icon = Nothing
            , checked = Set.member text selectedTags
            , label = id
            }
        , element
        ]
