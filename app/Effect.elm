module Effect exposing (Effect, batch, fromCmd, map, none, perform)

{-|

@docs Effect, batch, fromCmd, map, none, perform

-}

import Browser.Navigation
import Form
import Http
import Pages.Fetcher
import Url exposing (Url)


{-| -}
type alias Effect msg =
    Cmd msg


{-| -}
none : Effect msg
none =
    Cmd.none


{-| -}
batch : List (Effect msg) -> Effect msg
batch =
    Cmd.batch


{-| -}
fromCmd : Cmd msg -> Effect msg
fromCmd =
    identity


{-| -}
map : (a -> b) -> Effect a -> Effect b
map =
    Cmd.map


{-| -}
perform :
    { fetchRouteData :
        { data : Maybe FormData
        , toMsg : Result Http.Error Url -> pageMsg
        }
        -> Cmd msg
    , submit :
        { values : FormData
        , toMsg : Result Http.Error Url -> pageMsg
        }
        -> Cmd msg
    , runFetcher :
        Pages.Fetcher.Fetcher pageMsg
        -> Cmd msg
    , fromPageMsg : pageMsg -> msg
    , key : Browser.Navigation.Key
    , setField : { formId : String, name : String, value : String } -> Cmd msg
    }
    -> Effect pageMsg
    -> Cmd msg
perform ({ fromPageMsg, key } as helpers) effect =
    Cmd.map fromPageMsg effect


type alias FormData =
    { fields : List ( String, String )
    , method : Form.Method
    , action : String
    , id : Maybe String
    }
