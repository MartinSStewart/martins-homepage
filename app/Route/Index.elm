module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Dict
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Things exposing (Tag, Thing)
import Ui
import Ui.Font
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { message : String
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed Data
        |> BackendTask.andMap
            (BackendTask.succeed "Hello!")


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


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = "Martin's homepage"
    , body =
        [ Ui.layout
            []
            (Ui.column
                [ Ui.spacing 16, Ui.padding 8 ]
                [ Ui.el
                    [ Ui.Font.size 32, Ui.Font.bold ]
                    (Ui.text "Things I've created or done that I don't want to forget")
                , Ui.row
                    [ Ui.wrap, Ui.spacing 8 ]
                    (List.map thingsView (Dict.toList Things.thingsIHaveDone))
                ]
            )
        ]

    --[ Html.h1 [] [ Html.text "elm-pages is up and running!" ]
    --, Html.p []
    --    [ Html.text <| "The message is: " ++ app.data.message
    --    ]
    --, Route.Hello
    --    |> Route.link [] [ Html.text "My blog post" ]
    --]
    }


thingsView : ( String, Thing ) -> Ui.Element msg
thingsView ( name, thing ) =
    Ui.column
        [ Ui.widthMin 200
        , Ui.widthMax 300
        , Ui.background (Ui.rgb 245 245 245)
        , Ui.borderColor (Ui.rgb 230 230 230)
        , Ui.border 1
        , Ui.rounded 4
        , Ui.alignTop
        , Ui.padding 4
        , Ui.spacing 4
        , Html.Attributes.attribute "elm-pages:prefetch" "" |> Ui.htmlAttribute
        , Ui.link (Route.toString (Route.Stuff__Slug_ { slug = name }))
        ]
        [ Ui.el [ Ui.Font.bold, Ui.Font.size 16, Ui.Font.lineHeight 1 ] (Ui.text name)
        , Ui.row
            [ Ui.wrap
            , Ui.spacingWith { horizontal = 4, vertical = 2 }
            , Ui.contentTop
            ]
            (List.map tagView thing.tags)
        ]


tagView : Tag -> Ui.Element msg
tagView tag =
    let
        { text, color } =
            Things.tagData tag
    in
    Ui.el
        [ Ui.background color
        , Ui.rounded 16
        , Ui.paddingXY 6 1
        , Ui.Font.size 13
        , Ui.Font.color (Ui.rgb 255 255 255)
        , Ui.Font.noWrap
        , Ui.width Ui.shrink
        ]
        (Ui.text text)
