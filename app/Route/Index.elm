module Route.Index exposing (ActionData, Data, Model, Msg, route)

import Array exposing (Array)
import BackendTask exposing (BackendTask)
import Browser.Dom
import Browser.Events
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
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Set exposing (Set)
import Shared exposing (Breakpoints(..))
import Task
import Things exposing (Tag, ThingType(..))
import Ui
import Ui.Font
import Ui.Input
import Ui.Responsive
import UrlPath
import View exposing (View)


type alias Model =
    { sortBy : SortBy, filter : Array Tag, line : Line }


type Msg
    = PressedAddTag Tag
    | PressedRemoveTag Tag
    | PressedSortBy SortBy
    | GotThingPosition (Result Browser.Dom.Error (List Browser.Dom.Element))
    | WindowResized


type SortBy
    = Alphabetically
    | Chronologically
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
    ( { sortBy = Quality, filter = Array.empty, line = NoLine }, getElements )


type Line
    = NoLine
    | HorizontalLine { y : Float }
    | StaggeredLine { xStart : Float, xEnd : Float, y0 : Float, y1 : Float, x : Float }


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        PressedAddTag tag ->
            ( { model | filter = Array.filter (\a -> a /= tag) model.filter |> Array.push tag }, Cmd.none )

        PressedRemoveTag tag ->
            ( { model | filter = Array.filter (\a -> a /= tag) model.filter }, Cmd.none )

        PressedSortBy sortBy ->
            ( { model | sortBy = sortBy }, Cmd.none )

        WindowResized ->
            ( model, getElements )

        GotThingPosition result ->
            ( case result of
                Ok elements ->
                    case List.Extra.gatherEqualsBy (\a -> a.element.y) elements of
                        [] ->
                            { model | line = NoLine }

                        [ ( first, _ ) ] ->
                            { model | line = HorizontalLine { y = first.element.y - Shared.headerHeight } }

                        ( first, firstRest ) :: ( second, secondRest ) :: _ ->
                            let
                                xStart : Float
                                xStart =
                                    List.map (\a -> a.element.x) elements
                                        |> List.minimum
                                        |> Maybe.withDefault 0

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
                                        , y0 = top.element.y - Shared.headerHeight - Shared.tileSpacing / 2
                                        , x =
                                            List.map (\a -> a.element.x) (top :: topRest)
                                                |> List.minimum
                                                |> Maybe.withDefault 0

                                        --|> (\a ->
                                        --        if
                                        --            List.length firstRest
                                        --                + List.length secondRest
                                        --                + 2
                                        --                == Shared.maxColumns
                                        --        then
                                        --            a - xStart / 2
                                        --
                                        --        else
                                        --            a
                                        --   )
                                        , y1 = bottom.element.y - Shared.headerHeight - Shared.tileSpacing / 2
                                        }
                            in
                            { model
                                | line =
                                    if first.element.y < second.element.y then
                                        helper first firstRest second

                                    else
                                        helper second secondRest first
                            }

                Err _ ->
                    { model | line = NoLine }
            , Cmd.none
            )


getElements =
    List.map (\name -> Browser.Dom.getElement name) topOfLowTier
        |> Task.sequence
        |> Task.attempt GotThingPosition


topOfLowTier =
    List.Extra.dropWhile (\a -> a /= "sanctum") Things.qualityOrder |> List.take Shared.maxColumns


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


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app _ model =
    let
        thingsDone =
            app.data.thingsIHaveDone

        filterSet : Set String
        filterSet =
            List.map
                (\tag -> Things.tagData tag |> .text)
                (Array.toList model.filter)
                |> Set.fromList

        thingsSorted : List ( String, Thing )
        thingsSorted =
            case model.sortBy of
                Alphabetically ->
                    Dict.toList thingsDone

                Quality ->
                    List.foldl
                        (\name list ->
                            case Dict.get name thingsDone of
                                Just thing ->
                                    ( name, thing ) :: list

                                Nothing ->
                                    list
                        )
                        []
                        Things.qualityOrder
                        |> List.reverse

                Chronologically ->
                    Dict.toList thingsDone
                        |> List.sortWith (\( _, a ) ( _, b ) -> Date.compare (thingDate b) (thingDate a))

        filterThings viewFunc ( name, thing ) =
            if Set.isEmpty filterSet then
                viewFunc ( name, thing ) |> Just

            else if
                Array.toList model.filter
                    |> List.all
                        (\tag ->
                            let
                                tagText =
                                    Things.tagData tag |> .text
                            in
                            List.any
                                (\tag2 -> Things.tagData tag2 |> .text |> (==) tagText)
                                thing.tags
                        )
            then
                viewFunc ( name, thing ) |> Just

            else
                Nothing
    in
    { title = "Martin's homepage"
    , body =
        Ui.column
            (Ui.spacing 16
                :: Ui.Responsive.paddingXY
                    Shared.breakpoints
                    (\label ->
                        case label of
                            Mobile ->
                                { x = Ui.Responsive.value 8, y = Ui.Responsive.value 16 }

                            NotMobile ->
                                { x = Ui.Responsive.value Shared.pagePadding, y = Ui.Responsive.value 16 }
                    )
                :: (case model.line of
                        NoLine ->
                            []

                        HorizontalLine { y } ->
                            [ Ui.el
                                [ Ui.height (Ui.px 1)
                                , Ui.background (Ui.rgb 0 0 0)
                                , Ui.move { x = 0, y = round y, z = 0 }
                                ]
                                Ui.none
                                |> Ui.inFront
                            ]

                        StaggeredLine { xStart, xEnd, x, y0, y1 } ->
                            [ Ui.el
                                [ Ui.height (Ui.px 1)
                                , Ui.background (Ui.rgb 0 0 0)
                                , Ui.move { x = 0, y = round y0, z = 0 }
                                ]
                                Ui.none
                                |> Ui.inFront
                            , Ui.el
                                [ Ui.width (Ui.px 1)
                                , Ui.height (Ui.px (round (y1 - y0)))
                                , Ui.background (Ui.rgb 0 0 0)
                                , Ui.move { x = round x, y = round y0, z = 0 }
                                ]
                                Ui.none
                                |> Ui.inFront
                            , Ui.el
                                [ Ui.height (Ui.px 1)
                                , Ui.background (Ui.rgb 0 0 0)
                                , Ui.move { x = 0, y = round y1, z = 0 }
                                ]
                                Ui.none
                                |> Ui.inFront
                            ]
                   )
            )
            [ Ui.el
                [ Ui.Font.size 32, Ui.Font.bold, Ui.Font.lineHeight 1.1 ]
                (Ui.text "Stuff I've done that I don't want to forget")
            , Ui.column
                [ Ui.spacing 8 ]
                [ filterView model
                , Ui.row
                    [ Ui.wrap
                    , Ui.spacing Shared.tileSpacing
                    , Ui.contentCenterX
                    , Ui.Responsive.visible Shared.breakpoints [ NotMobile ]
                    ]
                    (List.filterMap (filterThings thingsViewNotMobile) thingsSorted)
                , Ui.column
                    [ Ui.spacing Shared.tileSpacing
                    , Ui.Responsive.visible Shared.breakpoints [ Mobile ]
                    ]
                    (List.filterMap (filterThings thingsViewMobile) thingsSorted)
                ]
            ]
            |> Ui.map PagesMsg.fromMsg
    }


containerBackground : Ui.Attribute msg
containerBackground =
    Ui.background (Ui.rgb 245 245 245)


containerBorder : Ui.Color
containerBorder =
    Ui.rgb 210 210 210


sorByButtonAttributes selected sortBy =
    [ Ui.Input.button (PressedSortBy sortBy)
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


sortByView : Model -> Ui.Element Msg
sortByView model =
    Ui.row
        [ Ui.width Ui.shrink, Ui.spacing 4, Ui.Font.size 14 ]
        [ Ui.el [ Ui.Font.bold ] (Ui.text "Sort by")
        , Ui.row
            [ Ui.width Ui.shrink ]
            [ Ui.el
                (Ui.roundedWith { topLeft = 16, topRight = 0, bottomLeft = 16, bottomRight = 0 }
                    :: Ui.border 1
                    :: tooltip "Sort by how important and high quality I think things are"
                    :: sorByButtonAttributes model.sortBy Quality
                )
                (Ui.text "Best to worst")
            , Ui.el
                (Ui.borderWith { left = 0, right = 0, top = 1, bottom = 1 }
                    :: tooltip "Sort by title names"
                    :: sorByButtonAttributes model.sortBy Alphabetically
                )
                (Ui.text "A to Z")
            , Ui.el
                (Ui.roundedWith { topLeft = 0, topRight = 16, bottomLeft = 0, bottomRight = 16 }
                    :: Ui.border 1
                    :: tooltip "Sort by when things were released. For stuff that doesn't have a clear release date, this is when it first become known to or used by several people"
                    :: sorByButtonAttributes model.sortBy Chronologically
                )
                (Ui.text "Newest to oldest")
            ]
        ]


filterView : Model -> Ui.Element Msg
filterView model =
    Ui.row
        [ Ui.spacingWith { horizontal = 16, vertical = 8 }, Ui.wrap ]
        [ sortByView model
        , if Array.isEmpty model.filter then
            Ui.none

          else
            Ui.row
                [ Ui.spacing 4, Ui.widthMin 300 ]
                [ Ui.el [ Ui.Font.size 14, Ui.Font.bold, Ui.width Ui.shrink ] (Ui.text "Filter by")
                , Array.toList model.filter
                    |> List.map filterTagView
                    |> Ui.row [ Ui.spacing 4 ]
                ]
        ]


thingsViewMobile : ( String, Thing ) -> Ui.Element Msg
thingsViewMobile ( name, thing ) =
    Ui.row
        [ containerBackground
        , Ui.borderColor containerBorder
        , Ui.border 1
        , Ui.rounded 4
        , Ui.alignTop
        , Ui.padding 4
        , Ui.spacing 4
        ]
        [ Ui.image
            [ Ui.width (Ui.px 100)
            , Ui.height (Ui.px 100)
            , Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
            , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = name }))
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
                , Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
                , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = name }))
                ]
                (Ui.text thing.name)
            , Ui.row
                [ Ui.wrap
                , Ui.spacing 4
                , Ui.alignBottom
                ]
                (List.map tagView thing.tags)
            ]
        ]


thingsViewNotMobile : ( String, Thing ) -> Ui.Element Msg
thingsViewNotMobile ( name, thing ) =
    Ui.column
        [ Ui.width (Ui.px Shared.tileWidth)
        , containerBackground
        , Ui.borderColor containerBorder
        , Ui.border 1
        , Ui.rounded 4
        , Ui.alignTop
        , Ui.padding 4
        , Ui.spacing 4
        , Ui.id name
        ]
        [ Ui.el
            [ Ui.Font.bold
            , Ui.Font.size 16
            , Ui.Font.lineHeight 1
            , Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
            , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = name }))
            ]
            (Ui.text thing.name)
        , Ui.image
            [ Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
            , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = name }))
            ]
            { source = thing.previewImage
            , description = "Preview image for " ++ thing.name
            , onLoad = Nothing
            }
        , Ui.row
            [ Ui.wrap
            , Ui.spacing 4
            , Ui.contentTop
            ]
            (List.map tagView thing.tags)
        ]


tagView : Tag -> Ui.Element Msg
tagView tag =
    let
        { text, color } =
            Things.tagData tag
    in
    Ui.el
        [ Ui.background color
        , Ui.rounded 16
        , Ui.paddingXY 8 2
        , Ui.Font.size 14
        , Ui.Font.color (Ui.rgb 255 255 255)
        , Ui.Font.noWrap
        , Ui.width Ui.shrink
        , Ui.Input.button (PressedAddTag tag)
        ]
        (Ui.text text)


filterTagView : Tag -> Ui.Element Msg
filterTagView tag =
    let
        { text, color } =
            Things.tagData tag
    in
    Ui.row
        [ Ui.background color
        , Ui.rounded 16
        , Ui.paddingXY 8 2
        , Ui.Font.size 14
        , Ui.Font.color (Ui.rgb 255 255 255)
        , Ui.Font.noWrap
        , Ui.width Ui.shrink
        , Ui.Input.button (PressedRemoveTag tag)
        , Ui.spacing 2
        ]
        [ Ui.text text, Ui.el [ Ui.Font.bold, Ui.move { x = 0, y = -1, z = 0 } ] (Ui.text "×") ]
