module Things exposing (Tag(..), Thing, tagData, thingsIHaveDone)

import Date exposing (Date)
import Dict exposing (Dict)
import Time exposing (Month(..))
import Ui


tagData : Tag -> TagData
tagData tag =
    case tag of
        Elm ->
            { text = "Elm", color = Ui.rgb 18 147 216 }

        ElmPackage ->
            { text = "Elm package", color = Ui.rgb 77 174 226 }

        Game ->
            { text = "Game", color = Ui.rgb 43 121 34 }

        Lamdera ->
            { text = "Lamdera", color = Ui.rgb 46 51 53 }


type alias TagData =
    { text : String, color : Ui.Color }


elmPackage user packageName description lastUpdated =
    ( packageName
    , { name = packageName
      , website =
            "https://package.elm-lang.org/packages/"
                ++ user
                ++ "/"
                ++ packageName
                ++ "/latest/"
                |> Just
      , repo = "https://github.com/" ++ user ++ "/" ++ packageName |> Just
      , tags = [ Elm, ElmPackage ]
      , description = "A game I've been working on, inspired by an old childrens game called Lego Loco"
      , lastUpdated = Date.fromCalendarDate 2024 May 25
      }
    )


thingsIHaveDone : Dict String Thing
thingsIHaveDone =
    [ ( "town-collab"
      , { name = "town-collab"
        , website = Just "https://town-collab.app/"
        , repo = Just "https://github.com/MartinSStewart/town-collab"
        , tags = [ Elm, Game, Lamdera ]
        , description = "A game I've been working on, inspired by an old childrens game called Lego Loco"
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "ascii-collab"
      , { name = "ascii-collab"
        , website = Just "https://ascii-collab.app/"
        , repo = Just "https://github.com/MartinSStewart/ascii-collab"
        , tags = [ Elm, Game, Lamdera ]
        , description = "An infinite canvas that people can draw ascii art on together"
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "meetdown"
      , { name = "meetdown"
        , website = Just "https://meetdown.app/"
        , repo = Just "https://github.com/MartinSStewart/meetdown"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "circuit-breaker"
      , { name = "Circuit Breaker"
        , website = Just "https://martinsstewart.gitlab.io/hackman/"
        , repo = Just "https://gitlab.com/MartinSStewart/hackman"
        , tags = [ Elm, Game ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , elmPackage "MartinSStewart" "elm-audio" "" (Date.fromCalendarDate 2024 May 25)
    , ( "elm-review-bot"
      , { name = "elm-review-bot"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-review-bot"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "state-of-elm"
      , { name = "state-of-elm"
        , website = Just "https://state-of-elm.com/2022"
        , repo = Just "https://github.com/MartinSStewart/state-of-elm"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , elmPackage "MartinSStewart" "elm-serialize" "" (Date.fromCalendarDate 2024 May 25)
    , ( "elm-review-elm-ui-upgrade"
      , { name = "elm-review-elm-ui-upgrade"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-review-elm-ui-upgrade"
        , tags = [ Elm, ElmPackage ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "lamdera-backend-debugger"
      , { name = "Lamdera backend debugger"
        , website = Just "https://backend-debugger.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/lamdera-backend-debugger"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "discord-bot"
      , { name = "discord-bot"
        , website = Nothing
        , repo = Nothing
        , tags = [ Elm, Game ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "elm-pdf"
      , { name = "elm-pdf"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-pdf"
        , tags = [ Elm ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , elmPackage "MartinSStewart" "send-grid" "" (Date.fromCalendarDate 2024 May 25)
    , ( "postmark-email-client"
      , { name = "Postmark email client"
        , website = Just "https://postmark-email-client.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/postmark-email-client"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "translation-editor"
      , { name = "translation-editor"
        , website = Just "https://translations-editor.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/translation-editor"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "elm-map"
      , { name = "elm-map"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-map"
        , tags = [ Elm, ElmPackage ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "simple-survey"
      , { name = "simple-survey"
        , website = Just "https://simple-survey.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/simple-survey"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "sheep-game"
      , { name = "sheep-game"
        , website = Just "https://sheep-game.lamdera.app/"
        , repo = Just ""
        , tags = [ Elm, Lamdera ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    , ( "air-hockey-racing"
      , { name = "Air Hockey Racing"
        , website = Just "https://air-hockey-racing.lamdera.app/"
        , repo = Just ""
        , tags = [ Elm, Lamdera ]
        , description = ""
        , lastUpdated = Date.fromCalendarDate 2024 May 25
        }
      )
    ]
        |> Dict.fromList


type Tag
    = Elm
    | ElmPackage
    | Game
    | Lamdera


type alias Thing =
    { name : String
    , website : Maybe String
    , repo : Maybe String
    , tags : List Tag
    , description : String
    , lastUpdated : Date
    }
