module Route.Index exposing (ActionData, Data, Model, Msg, route)

import Array exposing (Array)
import BackendTask exposing (BackendTask)
import Date
import Dict
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Set exposing (Set)
import Shared
import Things exposing (Tag, Thing)
import Ui
import Ui.Font
import Ui.Input
import UrlPath
import View exposing (View)


type alias Model =
    { sortBy : SortBy, filter : Array Tag }


type Msg
    = PressedAddTag Tag
    | PressedRemoveTag Tag
    | PressedSortBy SortBy


type SortBy
    = Alphabetically
    | Chronologically
    | Quality


type alias RouteParams =
    {}


type alias Data =
    {}


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
            , subscriptions = \_ _ _ _ -> Sub.none
            }


init : App data action routeParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { sortBy = Quality, filter = Array.empty }, Effect.None )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        PressedAddTag tag ->
            ( { model | filter = Array.filter (\a -> a /= tag) model.filter |> Array.push tag }, Effect.None )

        PressedRemoveTag tag ->
            ( { model | filter = Array.filter (\a -> a /= tag) model.filter }, Effect.None )

        PressedSortBy sortBy ->
            ( { model | sortBy = sortBy }, Effect.None )


data : BackendTask FatalError Data
data =
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
            BackendTask.succeed {}

        ( False, _ ) ->
            String.join ", " (Set.toList missing)
                ++ " are missing from Things.qualityOrder"
                |> FatalError.fromString
                |> BackendTask.fail

        ( True, False ) ->
            String.join ", " (Set.toList extra)
                ++ " in Things.qualityOrder don't exist in Things.thingsIHaveDone"
                |> FatalError.fromString
                |> BackendTask.fail


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Welcome to elm-pages!"
        , locale = Nothing
        , title = "elm-pages is running"
        }
        |> Seo.website


maxColumns : number
maxColumns =
    5


contentMaxWidth : number
contentMaxWidth =
    tileWidth * maxColumns + tileSpacing * (maxColumns - 1) + pagePadding * 2


pagePadding : number
pagePadding =
    16


tileWidth : number
tileWidth =
    210


tileSpacing : number
tileSpacing =
    8


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app shared model =
    let
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
                    Dict.toList Things.thingsIHaveDone

                Quality ->
                    List.foldl
                        (\name list ->
                            case Dict.get name Things.thingsIHaveDone of
                                Just thing ->
                                    ( name, thing ) :: list

                                Nothing ->
                                    list
                        )
                        []
                        Things.qualityOrder
                        |> List.reverse

                Chronologically ->
                    Dict.toList Things.thingsIHaveDone
                        |> List.sortWith (\( _, a ) ( _, b ) -> Date.compare b.releasedAt a.releasedAt)
    in
    { title = "Martin's homepage"
    , body =
        Ui.column
            [ Ui.spacing 16, Ui.padding pagePadding, Ui.widthMax contentMaxWidth, Ui.centerX ]
            [ Ui.el
                [ Ui.Font.size 32, Ui.Font.bold, Ui.Font.lineHeight 1.1 ]
                (Ui.text "Stuff I've made or done that I don't want to forget")
            , Ui.column
                [ Ui.spacing 8 ]
                [ filterView model
                , Ui.row
                    [ Ui.wrap, Ui.spacing tileSpacing, Ui.contentCenterX ]
                    (List.filterMap
                        (\( name, thing ) ->
                            if Set.isEmpty filterSet then
                                thingsView ( name, thing ) |> Just

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
                                thingsView ( name, thing ) |> Just

                            else
                                Nothing
                        )
                        thingsSorted
                    )
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


filterView : Model -> Ui.Element Msg
filterView model =
    Ui.row
        [ Ui.spacing 16 ]
        [ Ui.row
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
                    (Ui.text "Quality")
                , Ui.el
                    (Ui.borderWith { left = 0, right = 0, top = 1, bottom = 1 }
                        :: tooltip "Sort by title names"
                        :: sorByButtonAttributes model.sortBy Alphabetically
                    )
                    (Ui.text "Alphabetically")
                , Ui.el
                    (Ui.roundedWith { topLeft = 0, topRight = 16, bottomLeft = 0, bottomRight = 16 }
                        :: Ui.border 1
                        :: tooltip "Sort by when things were released. For stuff that doesn't have a clear release date, this is when it first become known to or used my several people"
                        :: sorByButtonAttributes model.sortBy Chronologically
                    )
                    (Ui.text "Chronologically")
                ]
            ]
        , if Array.isEmpty model.filter then
            Ui.none

          else
            Ui.row
                [ Ui.spacing 4 ]
                [ Ui.el [ Ui.Font.size 14, Ui.Font.bold, Ui.width Ui.shrink ] (Ui.text "Filter by")
                , Array.toList model.filter
                    |> List.map filterTagView
                    |> Ui.row [ Ui.wrap, Ui.spacing 4 ]
                ]
        ]


thingsView : ( String, Thing ) -> Ui.Element Msg
thingsView ( name, thing ) =
    Ui.column
        [ Ui.width (Ui.px tileWidth)
        , containerBackground
        , Ui.borderColor containerBorder
        , Ui.border 1
        , Ui.rounded 4
        , Ui.alignTop
        , Ui.padding 4
        , Ui.spacing 4
        ]
        [ Ui.el
            [ Ui.Font.bold
            , Ui.Font.size 16
            , Ui.Font.lineHeight 1
            , Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
            , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = name }))
            ]
            (Ui.text thing.name)
        , Ui.el
            [ Ui.height (Ui.px 200), Ui.background (Ui.rgb 200 200 200) ]
            Ui.none
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
