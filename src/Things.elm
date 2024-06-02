module Things exposing (Tag(..), Thing, ThingType(..), qualityOrder, tagData, thingsIHaveDone)

import Date exposing (Date)
import Dict exposing (Dict)
import Set exposing (Set)
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

        Podcast ->
            { text = "Podcast", color = Ui.rgb 150 74 8, tooltip = "A podcast I've been invited to" }

        GameMaker ->
            { text = "Game Maker", color = Ui.rgb 182 6 6, tooltip = "Made with Game Maker 7/8/Studio" }

        Presentation ->
            { text = "Presentation", color = Ui.rgb 120 168 0, tooltip = "Presented to a live audience" }

        Job ->
            { text = "Job", color = Ui.rgb 168 116 116, tooltip = "Full time or part time job" }

        CSharp ->
            { text = "C#", color = Ui.rgb 105 0 129, tooltip = "Made using C#" }

        FSharp ->
            { text = "F#", color = Ui.rgb 55 139 186, tooltip = "Worked with F#" }

        ElmPages ->
            { text = "elm-pages", color = Ui.rgb 24 151 218, tooltip = "Anything created with Elm or related to the Elm community" }

        Javascript ->
            { text = "JavaScript", color = Ui.rgb 217 197 70, tooltip = "Made using JavaScript" }


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
      , tags = [ Elm, ElmPackage ]
      , description = description
      , pageLastUpdated = lastUpdated
      , pageCreatedAt = lastUpdated
      , previewImage = "/elm-package-preview.png"
      , thingType =
            OtherThing
                { releasedAt = releasedAt
                , repo = "https://github.com/" ++ user ++ "/" ++ packageName |> Just
                }
      }
    )


lamderaPackage : String -> String -> Date -> Date -> ( String, Thing )
lamderaPackage packageName description lastUpdated releasedAt =
    ( "lamdera-" ++ packageName
    , { name = "lamdera/" ++ packageName
      , website = Nothing
      , tags = [ Elm, ElmPackage ]
      , description = description
      , pageLastUpdated = lastUpdated
      , pageCreatedAt = lastUpdated
      , previewImage = "/elm-package-preview.png"
      , thingType =
            OtherThing
                { releasedAt = releasedAt
                , repo = "https://github.com/lamdera/" ++ packageName |> Just
                }
      }
    )


date : Int -> Date.Month -> Int -> Date
date y m d =
    Date.fromCalendarDate y m d


websiteReleasedAt : Date
websiteReleasedAt =
    date 2024 Jun 27


thingsIHaveDone : Dict String Thing
thingsIHaveDone =
    [ ( "town-collab"
      , { name = "town-collab"
        , website = Just "https://town-collab.app/"
        , tags = [ Elm, Game, Lamdera ]
        , description = "A game I've been working on, inspired by an old childrens game called Lego Loco"
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Feb 11
                , repo = Just "https://github.com/MartinSStewart/town-collab"
                }
        }
      )
    , ( "ascii-collab"
      , { name = "ascii-collab"
        , website = Just "https://ascii-collab.app/"
        , tags = [ Elm, Game, Lamdera ]
        , description = "An infinite canvas that people can draw ascii art on together"
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2020 Sep 12
                , repo = Just "https://github.com/MartinSStewart/ascii-collab"
                }
        }
      )
    , ( "meetdown"
      , { name = "Meetdown"
        , website = Just "https://meetdown.app/"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Jun 27
                , repo = Just "https://github.com/MartinSStewart/meetdown"
                }
        }
      )
    , ( "circuit-breaker"
      , { name = "Circuit Breaker"
        , website = Just "https://martinsstewart.gitlab.io/hackman/"
        , tags = [ Elm, Game ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2019 Dec 17
                , repo = Just "https://gitlab.com/MartinSStewart/hackman"
                }
        }
      )
    , elmPackage "MartinSStewart" "elm-audio" "" websiteReleasedAt (date 2020 Mar 11)
    , ( "elm-review-bot"
      , { name = "elm-review-bot"
        , website = Nothing
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Aug 24
                , repo = Just "https://github.com/MartinSStewart/elm-review-bot"
                }
        }
      )
    , ( "state-of-elm"
      , { name = "state-of-elm"
        , website = Just "https://state-of-elm.com/2022"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 May 1
                , repo = Just "https://github.com/MartinSStewart/state-of-elm"
                }
        }
      )
    , elmPackage "MartinSStewart" "elm-serialize" "" websiteReleasedAt (date 2020 Jul 30)
    , ( "elm-review-elm-ui-upgrade"
      , { name = "elm-review-elm-ui-upgrade"
        , website = Nothing
        , tags = [ Elm ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Aug 27
                , repo = Just "https://github.com/MartinSStewart/elm-review-elm-ui-upgrade"
                }
        }
      )
    , ( "lamdera-backend-debugger"
      , { name = "Lamdera backend debugger"
        , website = Just "https://backend-debugger.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Jul 20
                , repo = Just "https://github.com/MartinSStewart/lamdera-backend-debugger"
                }
        }
      )
    , ( "discord-bot"
      , { name = "discord-bot"
        , website = Nothing
        , tags = [ Elm, Game, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2020 Mar 21
                , repo = Nothing
                }
        }
      )
    , ( "elm-pdf"
      , { name = "elm-pdf"
        , website = Nothing
        , tags = [ Elm ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2020 Oct 29
                , repo = Just "https://github.com/MartinSStewart/elm-pdf"
                }
        }
      )
    , elmPackage "MartinSStewart" "send-grid" "" websiteReleasedAt (date 2020 Feb 15)
    , elmPackage "MartinSStewart" "elm-bayer-matrix" "A package for generating [bayer matrices](https://en.wikipedia.org/wiki/Ordered_dithering). These are useful for producing a dithering effect for partially transparent images. I used it for [surface-voyage](/stuff/surface-voyage) to fade out objects tooo close to the camera. That said, in hindsight it was silly to make a package for 50 lines of code though." websiteReleasedAt (date 2020 Feb 15)
    , elmPackage "MartinSStewart" "elm-box-packing" "" websiteReleasedAt (date 2020 Apr 25)
    , elmPackage "MartinSStewart" "elm-codec-bytes" "" websiteReleasedAt (date 2020 Feb 15)
    , elmPackage "MartinSStewart" "elm-geometry-serialize" "" websiteReleasedAt (date 2020 Jul 31)
    , elmPackage "MartinSStewart" "elm-nonempty-string" "" websiteReleasedAt (date 2020 Feb 15)
    , ( "postmark-email-client"
      , { name = "Postmark email client"
        , website = Just "https://postmark-email-client.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Jul 5
                , repo = Just "https://github.com/MartinSStewart/postmark-email-client"
                }
        }
      )
    , ( "translation-editor"
      , { name = "Translation editor"
        , website = Just "https://translations-editor.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Feb 27
                , repo = Just "https://github.com/MartinSStewart/translation-editor"
                }
        }
      )
    , ( "elm-map"
      , { name = "elm-map"
        , website = Nothing
        , tags = [ Elm ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 May 17
                , repo = Just "https://github.com/MartinSStewart/elm-map"
                }
        }
      )
    , ( "simple-survey"
      , { name = "simple-survey"
        , website = Just "https://simple-survey.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 May 21
                , repo = Just "https://github.com/MartinSStewart/simple-survey"
                }
        }
      )
    , ( "sheep-game"
      , { name = "Sheep game"
        , website = Just "https://sheep-game.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/sheep-game-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Jun 13
                , repo = Just "https://github.com/MartinSStewart/sheep-game"
                }
        }
      )
    , ( "air-hockey-racing"
      , { name = "Air Hockey Racing"
        , website = Just "https://air-hockey-racing.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Jun 14
                , repo = Just "https://github.com/MartinSStewart/air-hockey-racing"
                }
        }
      )
    , ( "elm-town-48"
      , { name = "Elm Town episode\u{00A0}48"
        , website = Just "https://elm.town/episodes/making-little-games-like-presents"
        , tags = [ Elm, Podcast ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/elm-town-preview.png"
        , thingType = PodcastThing { releasedAt = date 2020 Jan 11 }
        }
      )
    , ( "elm-town-64"
      , { name = "Elm Town episode\u{00A0}64"
        , website = Just "https://elm.town/episodes/elm-town-64-the-network-effect"
        , tags = [ Elm, Podcast ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/elm-town-preview.png"
        , thingType = PodcastThing { releasedAt = date 2023 Sep 5 }
        }
      )
    , ( "elm-radio-57"
      , { name = "Elm Radio episode\u{00A0}57"
        , website = Just "https://elm-radio.com/episode/state-of-elm-2022"
        , tags = [ Elm, Podcast ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/elm-radio-preview.svg"
        , thingType = PodcastThing { releasedAt = date 2022 May 23 }
        }
      )
    , ( "vector-rockets"
      , { name = "Vector Rockets"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 May 23
                , repo = Nothing
                }
        }
      )
    , ( "code-breakers"
      , { name = "Code Breakers"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2014 Oct 28
                , repo = Nothing
                }
        }
      )
    , ( "sanctum"
      , { name = "Sanctum"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = "I created this for the Game Maker Community game jam #3. Everyone had 3 days to make a game themed around the word \"live\". There were 56 entries and I placed 16th."
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2011 Aug 2
                , repo = Nothing
                }
        }
      )
    , ( "tetherball-extreme-zombie-edition"
      , { name = "Tetherball EXTREME Zombie Edition"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = "I finished this before [Sanctum](/stuff/sanctum) but due to it being part of the Game Maker Community Game it didn't get released until later."
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2012 Mar 3
                , repo = Nothing
                }
        }
      )
    , lamderaPackage "websocket" "" websiteReleasedAt (date 2021 May 16)
    , lamderaPackage "program-test" "" websiteReleasedAt (date 2021 Jul 7)
    , ( "making-a-game-with-elm-and-lamdera"
      , { name = "Making a game with Elm and Lamdera"
        , website = Just "https://www.youtube.com/watch?v=pZ_WqwRwwao"
        , tags = [ Game, Elm, Lamdera, Presentation ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Sep 13
                , repo = Nothing
                }
        }
      )
    , ( "building-a-meetup-clone-on-lamdera"
      , { name = "Building a Meetup clone on Lamdera"
        , website = Just "https://www.youtube.com/watch?v=3Nn5meBieh4"
        , tags = [ Elm, Lamdera, Presentation ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Jul 23
                , repo = Nothing
                }
        }
      )
    , ( "hobby-scale-func-prog-sweden"
      , { name = "Hobby scale (Func\u{00A0}Prog\u{00A0}Sweden)"
        , website = Just "https://www.youtube.com/watch?v=o7M0JxgDfhE"
        , tags = [ Elm, Lamdera, Presentation ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Mar 16
                , repo = Just "https://github.com/MartinSStewart/lamdera-presentation"
                }
        }
      )
    , ( "hobby-scale-goto-aarhus"
      , { name = "Hobby scale (GOTO\u{00A0}Aarhus)"
        , website = Just "https://www.youtube.com/watch?v=o7M0JxgDfhE"
        , tags = [ Elm, Lamdera, Presentation ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Mar 16
                , repo = Just "https://github.com/MartinSStewart/lamdera-presentation"
                }
        }
      )
    , ( "elm-audio-presentation"
      , { name = "elm-audio presentation"
        , website = Nothing
        , tags = [ Elm, Presentation ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Nov 11
                , repo = Just "https://github.com/MartinSStewart/audio-presentation"
                }
        }
      )
    , ( "enough-portals"
      , { name = "enough-portals"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2016 Sep 22
                , repo = Nothing
                }
        }
      )
    , ( "aventyr"
      , { name = "aventyr"
        , website = Just "https://www.youtube.com/watch?v=Y_ExX2LT_bw"
        , tags = [ Game, CSharp ]
        , description = "A 2d portal game I worked on and off on for a couple years. Really it was attempt four at a 2d portal game. The first three attempts were in Game Maker (which includes [enough-portals](/stuff/enough-portals)). It wasn't suited to the complexity or performance requirements so eventually I switched to using C#. I never got close to finishing this game but it's largely responsible for teaching me C# and helping me independently realize that inheritence is bad and pure functions and immutable data are good.\n\nThis is where my profile image originated. I picked [an icon](https://thenounproject.com/icon/work-in-progress-42732/) for Aventyr's exe file to indicate that it's a work in progress. Then for some reason I started using that icon for profile images (assuming I can be bothered with setting a profile image)"
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/profile.png"
        , thingType =
            OtherThing
                { releasedAt = date 2016 Sep 22
                , repo = Just "https://github.com/MartinSStewart/Aventyr-Project"
                }
        }
      )
    , ( "starship-corporation"
      , { name = "Starship Corporation"
        , website = Just "https://store.steampowered.com/app/292330/Starship_Corporation/"
        , tags = [ Game, GameMaker, Job ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2014 Apr 1
                , endedAt = Just (date 2017 Jan 31)
                , elmPercentage = 0
                }
        }
      )
    , ( "crivia"
      , { name = "Crivia"
        , website = Just "https://www.cliftonbazaar.games/games.php?game=crivia"
        , tags = [ Game, GameMaker, Job ]
        , description = "A game I was hired to make for a guy named James Clifton. Crivia or Cricket Trivia is a game about answering trivia questions about the sport Cricket. I was only paid like 60 USD for on and off work spanning 3 years so this kind of stretches the definition of a job but I think at the time I was more concerned with experience and resume building. The game was made in Game Maker with a tiny amount of PHP used for saving highscores to James' website."
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2013 Jun 4
                , endedAt = Just (date 2016 Dec 26)
                , elmPercentage = 0
                }
        }
      )
    , ( "tretton37"
      , { name = "tretton37"
        , website = Just "https://www.tretton37.com/"
        , tags = [ CSharp, Elm, Job ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2016 Oct 31
                , endedAt = Just (date 2020 Jan 31)
                , elmPercentage = 5
                }
        }
      )
    , ( "insurello"
      , { name = "Insurello"
        , website = Just "https://insurello.se/"
        , tags = [ FSharp, Elm, Job ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2020 Feb 3
                , endedAt = Just (date 2022 Feb 25)
                , elmPercentage = 50
                }
        }
      )
    , ( "realia"
      , { name = "Realia"
        , website = Just "https://realia.se/"
        , tags = [ Elm, Lamdera, Job ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2021 Aug 18
                , endedAt = Just (date 2023 Apr 30)
                , elmPercentage = 100
                }
        }
      )
    , ( "ambue"
      , { name = "Ambue"
        , website = Just "https://ambue.com/"
        , tags = [ Elm, Lamdera, Job ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2023 Aug 15
                , endedAt = Nothing
                , elmPercentage = 100
                }
        }
      )
    , ( "demon-clutched-walkaround"
      , { name = "Demon Clutched walkaround"
        , website = Just "https://ambue.com/"
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2012 Oct 5
                , repo = Nothing
                }
        }
      )
    , ( "this-website"
      , { name = "This website!"
        , website = Just "https://martinstewart.dev/"
        , tags = [ Elm, ElmPages ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = websiteReleasedAt
                , repo = Just "https://github.com/MartinSStewart/martins-homepage"
                }
        }
      )
    , ( "culminating-game"
      , { name = "Culminating game"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2010 Mar 10
                , repo = Nothing
                }
        }
      )
    , ( "ds-game-over"
      , { name = "DS game over"
        , website = Nothing
        , tags = [ Javascript ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2014 Mar 1
                , repo = Nothing
                }
        }
      )
    , ( "fake-key-gen"
      , { name = "Fake key gen"
        , website = Nothing
        , tags = [ GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2014 Mar 1
                , repo = Nothing
                }
        }
      )
    , ( "stewart-everybody-net"
      , { name = "stewart-everybody.net"
        , website = Nothing
        , tags = [ Javascript ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2015 Mar 5
                , repo = Nothing
                }
        }
      )
    , ( "surface-voyage"
      , { name = "Surface voyage"
        , website = Nothing
        , tags = [ Elm, Game ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2020 Jan 14
                , repo = Just "https://gitlab.com/MartinSStewart/surface-voyage"
                }
        }
      )
    , ( "gmc-jam-7-animation"
      , { name = "GMC jam 7 animation"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2012 Jul 30
                , repo = Nothing
                }
        }
      )
    , ( "german-game"
      , { name = "German game"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2012 Jun 8
                , repo = Nothing
                }
        }
      )
    , ( "zig-zag"
      , { name = "Zig Zag"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2012 Jun 25
                , repo = Nothing
                }
        }
      )
    , ( "hyperboggling"
      , { name = "Hyperboggling"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2014 Feb 5
                , repo = Nothing
                }
        }
      )
    , ( "minmacro"
      , { name = "Minmacro"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2011 Jun 25
                , repo = Nothing
                }
        }
      )
    , ( "break-the-facade"
      , { name = "Break the facade"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = ""
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2012 Jan 30
                , repo = Nothing
                }
        }
      )
    , ( "secret-santa-game"
      , { name = "Secret santa game"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = "I participated in a secret santa event where everyone made a little game for another randomly chosen participant. This is the game I made and in my opinion it's the has by far the highest fun to effort ratio of anything I've ever made."
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2015 Mar 7
                , repo = Nothing
                }
        }
      )
    ]
        |> Dict.fromList


{-| Best at the top
-}
qualityOrder : List String
qualityOrder =
    [ "ascii-collab"
    , "ambue"
    , "this-website"
    , "meetdown"
    , "town-collab"
    , "elm-audio"
    , "elm-serialize"
    , "lamdera-program-test"
    , "discord-bot"
    , "circuit-breaker"
    , "realia"
    , "elm-map"
    , "elm-codec-bytes"
    , "break-the-facade"
    , "state-of-elm"
    , "sheep-game"
    , "secret-santa-game"
    , "air-hockey-racing"
    , "lamdera-websocket"
    , "elm-geometry-serialize"
    , "hobby-scale-goto-aarhus"
    , "making-a-game-with-elm-and-lamdera"
    , "elm-town-48"
    , "elm-town-64"
    , "elm-radio-57"
    , "elm-nonempty-string"
    , "insurello"
    , "tretton37"
    , "aventyr"
    , "hobby-scale-func-prog-sweden"
    , "zig-zag"
    , "vector-rockets"
    , "code-breakers"
    , "surface-voyage"
    , "send-grid"
    , "ds-game-over"
    , "elm-box-packing"
    , "elm-audio-presentation"
    , "demon-clutched-walkaround"
    , "tetherball-extreme-zombie-edition"
    , "elm-review-elm-ui-upgrade"
    , "elm-review-bot"
    , "lamdera-backend-debugger"
    , "building-a-meetup-clone-on-lamdera"
    , "elm-pdf"
    , "postmark-email-client"
    , "simple-survey"
    , "translation-editor"
    , "starship-corporation"
    , "sanctum"
    , "culminating-game"
    , "stewart-everybody-net"
    , "german-game"
    , "elm-bayer-matrix"
    , "fake-key-gen"
    , "enough-portals"
    , "hyperboggling"
    , "crivia"
    , "gmc-jam-7-animation"
    , "minmacro"
    ]


type Tag
    = Elm
    | ElmPackage
    | ElmPages
    | Game
    | Lamdera
    | Podcast
    | GameMaker
    | Presentation
    | Job
    | CSharp
    | FSharp
    | Javascript


type alias Thing =
    { name : String
    , website : Maybe String
    , tags : List Tag
    , description : String
    , pageLastUpdated : Date
    , pageCreatedAt : Date
    , previewImage : String
    , thingType : ThingType
    }


type ThingType
    = JobThing { startedAt : Date, endedAt : Maybe Date, elmPercentage : Int }
    | OtherThing
        { repo : Maybe String
        , -- Very imprecise due to it being unclear what counts as "released at". If there isn't a clear release date, pick something that counts as when the thing became usable for or known to several people.
          releasedAt : Date
        }
    | PodcastThing { releasedAt : Date }
