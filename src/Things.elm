module Things exposing (Tag(..), Thing, qualityOrder, tagData, thingsIHaveDone)

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

        Complete ->
            { text = "Complete", color = Ui.rgb 105 22 168 }

        Podcast ->
            { text = "Podcast", color = Ui.rgb 150 74 8 }


type alias TagData =
    { text : String, color : Ui.Color }


elmPackage : String -> String -> String -> Date -> Date -> ( String, Thing )
elmPackage user packageName description lastUpdated releasedAt =
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
      , description = description
      , pageLastUpdated = lastUpdated
      , releasedAt = releasedAt
      }
    )


date : Int -> Date.Month -> Int -> Date
date =
    Date.fromCalendarDate


thingsIHaveDone : Dict String Thing
thingsIHaveDone =
    [ ( "town-collab"
      , { name = "town-collab"
        , website = Just "https://town-collab.app/"
        , repo = Just "https://github.com/MartinSStewart/town-collab"
        , tags = [ Elm, Game, Lamdera ]
        , description = "A game I've been working on, inspired by an old childrens game called Lego Loco"
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2023 Feb 11
        }
      )
    , ( "ascii-collab"
      , { name = "ascii-collab"
        , website = Just "https://ascii-collab.app/"
        , repo = Just "https://github.com/MartinSStewart/ascii-collab"
        , tags = [ Elm, Game, Lamdera, Complete ]
        , description = "An infinite canvas that people can draw ascii art on together"
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2020 Sep 12
        }
      )
    , ( "meetdown"
      , { name = "Meetdown"
        , website = Just "https://meetdown.app/"
        , repo = Just "https://github.com/MartinSStewart/meetdown"
        , tags = [ Elm, Lamdera, Complete ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2021 Jun 27
        }
      )
    , ( "circuit-breaker"
      , { name = "Circuit Breaker"
        , website = Just "https://martinsstewart.gitlab.io/hackman/"
        , repo = Just "https://gitlab.com/MartinSStewart/hackman"
        , tags = [ Elm, Game, Complete ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2019 Dec 17
        }
      )
    , elmPackage "MartinSStewart" "elm-audio" "" (date 2024 May 25) (date 2020 Mar 11)
    , ( "elm-review-bot"
      , { name = "elm-review-bot"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-review-bot"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2021 Aug 24
        }
      )
    , ( "state-of-elm"
      , { name = "state-of-elm"
        , website = Just "https://state-of-elm.com/2022"
        , repo = Just "https://github.com/MartinSStewart/state-of-elm"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2022 May 1
        }
      )
    , elmPackage "MartinSStewart" "elm-serialize" "" (date 2024 May 25) (date 2020 Jul 30)
    , ( "elm-review-elm-ui-upgrade"
      , { name = "elm-review-elm-ui-upgrade"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-review-elm-ui-upgrade"
        , tags = [ Elm, Complete ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2023 Aug 27
        }
      )
    , ( "lamdera-backend-debugger"
      , { name = "Lamdera backend debugger"
        , website = Just "https://backend-debugger.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/lamdera-backend-debugger"
        , tags = [ Elm, Lamdera, Complete ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2023 Jul 20
        }
      )
    , ( "discord-bot"
      , { name = "discord-bot"
        , website = Nothing
        , repo = Nothing
        , tags = [ Elm, Game, Complete ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2020 Mar 21
        }
      )
    , ( "elm-pdf"
      , { name = "elm-pdf"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-pdf"
        , tags = [ Elm ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2020 Oct 29
        }
      )
    , elmPackage "MartinSStewart" "send-grid" "" (date 2024 May 25) (date 2020 Feb 15)
    , ( "postmark-email-client"
      , { name = "Postmark email client"
        , website = Just "https://postmark-email-client.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/postmark-email-client"
        , tags = [ Elm, Lamdera, Complete ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2023 Jul 5
        }
      )
    , ( "translation-editor"
      , { name = "Translation editor"
        , website = Just "https://translations-editor.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/translation-editor"
        , tags = [ Elm, Lamdera, Complete ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2023 Feb 27
        }
      )
    , ( "elm-map"
      , { name = "elm-map"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-map"
        , tags = [ Elm ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2023 May 17
        }
      )
    , ( "simple-survey"
      , { name = "simple-survey"
        , website = Just "https://simple-survey.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/simple-survey"
        , tags = [ Elm, Lamdera, Complete ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2023 May 21
        }
      )
    , ( "sheep-game"
      , { name = "Sheep game"
        , website = Just "https://sheep-game.lamdera.app/"
        , repo = Just ""
        , tags = [ Elm, Lamdera, Complete ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2022 Jun 13
        }
      )
    , ( "air-hockey-racing"
      , { name = "Air Hockey Racing"
        , website = Just "https://air-hockey-racing.lamdera.app/"
        , repo = Just ""
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2022 Jun 14
        }
      )
    , ( "elm-town-48"
      , { name = "Elm Town episode 48"
        , website = Just "https://elm.town/episodes/making-little-games-like-presents"
        , repo = Just ""
        , tags = [ Elm, Podcast ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2020 Jan 11
        }
      )
    , ( "elm-town-64"
      , { name = "Elm Town episode 64"
        , website = Just "https://elm.town/episodes/elm-town-64-the-network-effect"
        , repo = Just ""
        , tags = [ Elm, Podcast ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2023 Sep 5
        }
      )
    , ( "elm-radio-57"
      , { name = "Elm Radio episode 57"
        , website = Just "https://elm-radio.com/episode/state-of-elm-2022"
        , repo = Just ""
        , tags = [ Elm, Podcast ]
        , description = ""
        , pageLastUpdated = date 2024 May 25
        , releasedAt = date 2022 May 23
        }
      )
    ]
        |> Dict.fromList


{-| Best at the top
-}
qualityOrder : List String
qualityOrder =
    [ "town-collab"
    , "ascii-collab"
    , "meetdown"
    , "elm-audio"
    , "elm-serialize"
    , "discord-bot"
    , "circuit-breaker"
    , "elm-map"
    , "state-of-elm"
    , "sheep-game"
    , "air-hockey-racing"
    , "elm-town-48"
    , "elm-town-64"
    , "elm-radio-57"
    , "send-grid"
    , "elm-review-elm-ui-upgrade"
    , "elm-review-bot"
    , "lamdera-backend-debugger"
    , "elm-pdf"
    , "postmark-email-client"
    , "simple-survey"
    , "translation-editor"
    ]


type Tag
    = Elm
    | ElmPackage
    | Game
    | Lamdera
    | Complete
    | Podcast


type alias Thing =
    { name : String
    , website : Maybe String
    , repo : Maybe String
    , tags : List Tag
    , description : String
    , pageLastUpdated : Date
    , -- Very imprecise due to it being unclear what counts as "released at". If there isn't a clear release date, pick something that counts as when the thing became usable for or known to several people.
      releasedAt : Date
    }
