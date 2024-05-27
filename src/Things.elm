module Things exposing (Tag(..), Thing, qualityOrder, tagData, thingsIHaveDone)

import Date exposing (Date)
import Dict exposing (Dict)
import Time exposing (Month(..))
import Ui


tagData : Tag -> TagData
tagData tag =
    case tag of
        Elm ->
            { text = "Elm", color = Ui.rgb 18 147 216, tooltip = "Anything created with Elm or related to the Elm community" }

        ElmPackage ->
            { text = "Elm package", color = Ui.rgb 77 174 226, tooltip = "Is a published Elm package" }

        Game ->
            { text = "Game", color = Ui.rgb 43 121 34, tooltip = "Is a game or contains games" }

        Lamdera ->
            { text = "Lamdera", color = Ui.rgb 46 51 53, tooltip = "Created with Lamdera" }

        Wip ->
            { text = "WIP", color = Ui.rgb 105 22 168, tooltip = "Is being worked on" }

        Podcast ->
            { text = "Podcast", color = Ui.rgb 150 74 8, tooltip = "A podcast I've been invited to" }

        GameMaker ->
            { text = "Game Maker", color = Ui.rgb 182 6 6, tooltip = "Made with Game Maker 7/8/Studio" }


type alias TagData =
    { text : String, color : Ui.Color, tooltip : String }


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
      , pageCreatedAt = lastUpdated
      , releasedAt = releasedAt
      , previewImage = "/elm-package-preview.png"
      }
    )


date : Int -> Date.Month -> Int -> Date
date y m d =
    Date.fromCalendarDate y m d


websiteCreatedAt : Date
websiteCreatedAt =
    date 2024 Jun 27


thingsIHaveDone : Dict String Thing
thingsIHaveDone =
    [ ( "town-collab"
      , { name = "town-collab"
        , website = Just "https://town-collab.app/"
        , repo = Just "https://github.com/MartinSStewart/town-collab"
        , tags = [ Elm, Game, Lamdera, Wip ]
        , description = "A game I've been working on, inspired by an old childrens game called Lego Loco"
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2023 Feb 11
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "ascii-collab"
      , { name = "ascii-collab"
        , website = Just "https://ascii-collab.app/"
        , repo = Just "https://github.com/MartinSStewart/ascii-collab"
        , tags = [ Elm, Game, Lamdera ]
        , description = "An infinite canvas that people can draw ascii art on together"
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2020 Sep 12
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "meetdown"
      , { name = "Meetdown"
        , website = Just "https://meetdown.app/"
        , repo = Just "https://github.com/MartinSStewart/meetdown"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2021 Jun 27
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "circuit-breaker"
      , { name = "Circuit Breaker"
        , website = Just "https://martinsstewart.gitlab.io/hackman/"
        , repo = Just "https://gitlab.com/MartinSStewart/hackman"
        , tags = [ Elm, Game ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2019 Dec 17
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , elmPackage "MartinSStewart" "elm-audio" "" websiteCreatedAt (date 2020 Mar 11)
    , ( "elm-review-bot"
      , { name = "elm-review-bot"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-review-bot"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2021 Aug 24
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "state-of-elm"
      , { name = "state-of-elm"
        , website = Just "https://state-of-elm.com/2022"
        , repo = Just "https://github.com/MartinSStewart/state-of-elm"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2022 May 1
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , elmPackage "MartinSStewart" "elm-serialize" "" websiteCreatedAt (date 2020 Jul 30)
    , ( "elm-review-elm-ui-upgrade"
      , { name = "elm-review-elm-ui-upgrade"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-review-elm-ui-upgrade"
        , tags = [ Elm ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2023 Aug 27
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "lamdera-backend-debugger"
      , { name = "Lamdera backend debugger"
        , website = Just "https://backend-debugger.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/lamdera-backend-debugger"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2023 Jul 20
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "discord-bot"
      , { name = "discord-bot"
        , website = Nothing
        , repo = Nothing
        , tags = [ Elm, Game, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2020 Mar 21
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "elm-pdf"
      , { name = "elm-pdf"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-pdf"
        , tags = [ Elm ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2020 Oct 29
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , elmPackage "MartinSStewart" "send-grid" "" websiteCreatedAt (date 2020 Feb 15)
    , ( "postmark-email-client"
      , { name = "Postmark email client"
        , website = Just "https://postmark-email-client.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/postmark-email-client"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2023 Jul 5
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "translation-editor"
      , { name = "Translation editor"
        , website = Just "https://translations-editor.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/translation-editor"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2023 Feb 27
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "elm-map"
      , { name = "elm-map"
        , website = Nothing
        , repo = Just "https://github.com/MartinSStewart/elm-map"
        , tags = [ Elm ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2023 May 17
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "simple-survey"
      , { name = "simple-survey"
        , website = Just "https://simple-survey.lamdera.app/"
        , repo = Just "https://github.com/MartinSStewart/simple-survey"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2023 May 21
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "sheep-game"
      , { name = "Sheep game"
        , website = Just "https://sheep-game.lamdera.app/"
        , repo = Just ""
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2022 Jun 13
        , previewImage = "/sheep-game-preview.png"
        }
      )
    , ( "air-hockey-racing"
      , { name = "Air Hockey Racing"
        , website = Just "https://air-hockey-racing.lamdera.app/"
        , repo = Just ""
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2022 Jun 14
        , previewImage = "/discord-bot-preview.png"
        }
      )
    , ( "elm-town-48"
      , { name = "Elm Town episode\u{00A0}48"
        , website = Just "https://elm.town/episodes/making-little-games-like-presents"
        , repo = Just ""
        , tags = [ Elm, Podcast ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2020 Jan 11
        , previewImage = "/elm-town-preview.png"
        }
      )
    , ( "elm-town-64"
      , { name = "Elm Town episode\u{00A0}64"
        , website = Just "https://elm.town/episodes/elm-town-64-the-network-effect"
        , repo = Just ""
        , tags = [ Elm, Podcast ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2023 Sep 5
        , previewImage = "/elm-town-preview.png"
        }
      )
    , ( "elm-radio-57"
      , { name = "Elm Radio episode\u{00A0}57"
        , website = Just "https://elm-radio.com/episode/state-of-elm-2022"
        , repo = Just ""
        , tags = [ Elm, Podcast ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2022 May 23
        , previewImage = "/elm-radio-preview.svg"
        }
      )
    , ( "vector-rockets"
      , { name = "Vector Rockets"
        , website = Nothing
        , repo = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2022 May 23
        , previewImage = "/game-maker-preview.png"
        }
      )
    , ( "code-breakers"
      , { name = "Code Breakers"
        , website = Nothing
        , repo = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2014 Oct 28
        , previewImage = "/game-maker-preview.png"
        }
      )
    , ( "sanctum"
      , { name = "Sanctum"
        , website = Nothing
        , repo = Nothing
        , tags = [ Game, GameMaker ]
        , description = "I created this for the Game Maker Community game jam #3. Everyone had 3 days to make a game themed around the word \"live\". There were 56 entries and I placed 16th."
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2011 Aug 2
        , previewImage = "/game-maker-preview.png"
        }
      )
    , ( "tetherball-extreme-zombie-edition"
      , { name = "Tetherball EXTREME Zombie Edition"
        , website = Nothing
        , repo = Nothing
        , tags = [ Game, GameMaker ]
        , description = "I finished this before [Sanctum](/stuff/sanctum) but due to it being part of the Game Maker Community Game it didn't get released until later."
        , pageLastUpdated = websiteCreatedAt
        , pageCreatedAt = websiteCreatedAt
        , releasedAt = date 2012 Mar 3
        , previewImage = "/game-maker-preview.png"
        }
      )
    ]
        |> Dict.fromList


{-| Best at the top
-}
qualityOrder : List String
qualityOrder =
    [ "ascii-collab"
    , "meetdown"
    , "town-collab"
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
    , "vector-rockets"
    , "code-breakers"
    , "send-grid"
    , "tetherball-extreme-zombie-edition"
    , "sanctum"
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
    | Podcast
    | GameMaker
    | Wip


type alias Thing =
    { name : String
    , website : Maybe String
    , repo : Maybe String
    , tags : List Tag
    , description : String
    , pageLastUpdated : Date
    , pageCreatedAt : Date
    , -- Very imprecise due to it being unclear what counts as "released at". If there isn't a clear release date, pick something that counts as when the thing became usable for or known to several people.
      releasedAt : Date
    , previewImage : String
    }
