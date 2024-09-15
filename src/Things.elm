module Things exposing
    ( Tag(..)
    , Thing
    , ThingType(..)
    , csharpColor
    , elmColor
    , gameMakerColor
    , lamderaColor
    , qualityOrder
    , tagData
    , thingsIHaveDone
    )

import Date exposing (Date)
import Dict exposing (Dict)
import Formatting exposing (Formatting(..), Inline(..))
import Time exposing (Month(..))
import Ui


tagData : Tag -> TagData
tagData tag =
    case tag of
        Elm ->
            { text = "Elm", color = elmColor, tooltip = "Anything created with Elm or related to the Elm community" }

        ElmPackage ->
            { text = "Elm package", color = Ui.rgb 77 174 226, tooltip = "Is a published Elm package" }

        Game ->
            { text = "Game", color = Ui.rgb 43 121 34, tooltip = "Is a game or contains games" }

        Lamdera ->
            { text = "Lamdera", color = lamderaColor, tooltip = "Created with Lamdera" }

        Podcast ->
            { text = "Podcast", color = Ui.rgb 150 74 8, tooltip = "A podcast I've been invited to" }

        GameMaker ->
            { text = "GameMaker", color = gameMakerColor, tooltip = "Made with Game Maker 7/8/Studio" }

        GameJam ->
            { text = "Game jam", color = Ui.rgb 154 20 20, tooltip = "Made with Game Maker 7/8/Studio" }

        Presentation ->
            { text = "Presentation", color = Ui.rgb 120 168 0, tooltip = "Presented to a live audience" }

        Job ->
            { text = "Job", color = Ui.rgb 168 116 116, tooltip = "Full time or part time job" }

        CSharp ->
            { text = "C#", color = csharpColor, tooltip = "Made using C#" }

        FSharp ->
            { text = "F#", color = Ui.rgb 55 139 186, tooltip = "Worked with F#" }

        ElmPages ->
            { text = "elm-pages", color = Ui.rgb 24 151 218, tooltip = "Anything created with Elm or related to the Elm community" }

        Javascript ->
            { text = "JavaScript", color = Ui.rgb 217 197 70, tooltip = "Made using JavaScript" }


gameMakerColor : Ui.Color
gameMakerColor =
    Ui.rgb 182 6 6


csharpColor : Ui.Color
csharpColor =
    Ui.rgb 105 0 129


elmColor : Ui.Color
elmColor =
    Ui.rgb 18 147 216


lamderaColor : Ui.Color
lamderaColor =
    Ui.rgb 46 51 53


type alias TagData =
    { text : String, color : Ui.Color, tooltip : String }


elmPackage : String -> String -> List Formatting -> Date -> Date -> ( String, Thing )
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


lamderaPackage : String -> List Formatting -> Date -> Date -> ( String, Thing )
lamderaPackage packageName description lastUpdated releasedAt =
    ( "lamdera-" ++ packageName
    , { name = "lamdera/" ++ packageName
      , website = Nothing
      , tags = [ Elm, ElmPackage ]
      , description = description
      , pageLastUpdated = lastUpdated
      , pageCreatedAt = lastUpdated
      , previewImage = "/lamdera-preview.svg"
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
        , description = [ SimpleParagraph "A game I've been working on, inspired by an old childrens game called Lego Loco" ]
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
        , description = [ SimpleParagraph "An infinite canvas that people can draw ascii art on together. I wrote an [announcement post](https://discourse.elm-lang.org/t/ascii-collab-draw-ascii-art-together-on-an-infinite-canvas/6273) and a [follow up post](https://discourse.elm-lang.org/t/ascii-collab-progress-update/7019) about it." ]
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
        , description = [ SimpleParagraph "[Announcement post](https://discourse.elm-lang.org/t/i-made-a-meetup-com-clone/7480)" ]
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
        , description = [ SimpleParagraph "I made a [blog post](https://dev.to/martinsstewart/what-is-elm-and-a-game-i-m-making-with-it-3di1) describing how Elm made it easier to create along with an [announcement post](https://discourse.elm-lang.org/t/ive-created-a-game-in-elm/4844)." ]
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
    , ( "hackman"
      , { name = "HackMan"
        , website = Nothing
        , tags = [ GameMaker, Game, GameJam ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2016 Aug 1
                , repo = Nothing
                }
        }
      )
    , elmPackage "MartinSStewart" "elm-audio" [] websiteReleasedAt (date 2020 Mar 11)
    , ( "elm-review-bot"
      , { name = "elm-review-bot"
        , website = Nothing
        , tags = [ Elm, Lamdera ]
        , description = [ SimpleParagraph "[Discourse post](https://discourse.elm-lang.org/t/i-created-218-pull-requests-in-3-days/7276)" ]
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
    , ( "state-of-elm-2022"
      , { name = "state-of-elm 2022"
        , website = Just "https://state-of-elm.com/2022"
        , tags = [ Elm, Lamdera ]
        , description = [ SimpleParagraph "[Announcement post](https://discourse.elm-lang.org/t/state-of-elm-2022/8284) and [results announcement](https://discourse.elm-lang.org/t/state-of-elm-survey-results/8362)." ]
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
    , ( "state-of-elm-2023"
      , { name = "state-of-elm 2023"
        , website = Just "https://state-of-elm.com/2023"
        , tags = [ Elm, Lamdera ]
        , description = [ SimpleParagraph "[Announcement post](https://discourse.elm-lang.org/t/state-of-elm-2023/9307) and a [closing post](https://discourse.elm-lang.org/t/state-of-elm-2023-closed/9369). Embarrassingly I've never finished the results page for this so the results of this survey aren't published." ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Sep 3
                , repo = Just "https://github.com/MartinSStewart/state-of-elm"
                }
        }
      )
    , elmPackage
        "MartinSStewart"
        "elm-serialize"
        [ SimpleParagraph "[Discourse post](https://discourse.elm-lang.org/t/elm-serialize-quickly-and-reliably-encode-and-decode-elm-values/6112/3)" ]
        websiteReleasedAt
        (date 2020 Jul 30)
    , ( "elm-review-elm-ui-upgrade"
      , { name = "elm-review-elm-ui-upgrade"
        , website = Nothing
        , tags = [ Elm ]
        , description = []
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
        , description = []
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
        , description = []
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
        , description = []
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
    , elmPackage "MartinSStewart" "send-grid" [] websiteReleasedAt (date 2020 Feb 15)
    , elmPackage "MartinSStewart" "elm-bayer-matrix" [ SimpleParagraph "A package for generating [bayer matrices](https://en.wikipedia.org/wiki/Ordered_dithering). These are useful for producing a dithering effect for partially transparent images. I used it for [surface-voyage](/stuff/surface-voyage) to fade out objects too close to the camera. That said, in hindsight it was silly to make a package for 50 lines of code though." ] websiteReleasedAt (date 2020 Feb 15)
    , elmPackage "MartinSStewart" "elm-box-packing" [] websiteReleasedAt (date 2020 Apr 25)
    , elmPackage
        "MartinSStewart"
        "elm-codec-bytes"
        [ SimpleParagraph "[Discourse post](https://discourse.elm-lang.org/t/elm-codec-bytes-1-0-0-released/3989)" ]
        websiteReleasedAt
        (date 2020 Feb 15)
    , elmPackage "MartinSStewart" "elm-geometry-serialize" [] websiteReleasedAt (date 2020 Jul 31)
    , elmPackage "MartinSStewart" "elm-nonempty-string" [] websiteReleasedAt (date 2020 Feb 15)
    , ( "postmark-email-client"
      , { name = "Postmark email client"
        , website = Just "https://postmark-email-client.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
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
    , ( "elm-camp-2023"
      , { name = "Elm Camp 2023"
        , website = Just "https://elm.camp/23-denmark"
        , tags = [ Elm, Lamdera ]
        , description = [ SimpleParagraph "I helped set up the website for Elm Camp 2023. Also I created a simple website for displaying a schedule of events during the unconference. Also I borrowed a fancy camera and took photos while I was there." ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/elm-camp-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Jun 28
                , repo = Just "https://github.com/elm-camp/website"
                }
        }
      )
    , ( "translation-editor"
      , { name = "Translation editor"
        , website = Just "https://translations-editor.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
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
        , description = [ SimpleParagraph "While working at [Realia](/stuff/realia) the app I was creating needed a map viewer so you could see which realtors had sold properties in your area (so you could judge if they would do a good job selling your home). Initially I used Google Maps for this. From a user perspective, Google Maps is pretty good. From a programmer perspective it was really awful to work with. So I switched to Mapbox. It's better. And it has an [Elm package](https://package.elm-lang.org/packages/gampleman/elm-mapbox/latest/) too. Still not great though. So I decided to make my own map viewer written in Elm. I made a proof of concept for the vector tile decoding over the 2022 winter break (the map viewer would still be relying on the Mapbox server for data) and then in 2023 summer I convinced my boss (Sam) to let finish the rest during work time.\n\nLater when I started working for [Ambue](/stuff/ambue) my new boss (Stephen) expressed interest in using the map viewer I had created in Elm for viewing homes that belonged to our client's portfolios. I got permission from Sam to open source the map viewer so it could live on at Ambue." ]
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
        , description = [ SimpleParagraph "A simple survey app! As of time of writing it only lets you create surveys with free text questions. Other survey creation tools can do a lot more than that. But simple-survey has the advantage of not spamming you with ads, not showing cookie/GDPR popups (while still respecting user privacy), or ask you to sign up. Initially it was created so that we could gather some attendee info before the first [elm-camp](/stuff/elm-camp-2023). Since then it's been used for the 2024 Elm camp and nothing else that I'm aware of." ]
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
        , description = [ SimpleParagraph "A game you play with a group of friends where everyone is given the same list of questions and in secret everyone tries to pick the same answers as everyone else. Once everyone is done, for each question you count the number of answers that match your own. Whoever has the most matches in total wins.\n\nI didn't come up with this idea, it's probably a pretty old concept. But I did make this app to speed up the process of collecting answers and displaying the results. My friends and I play it twice a year. I organize the \"summer sheep game\" and a friend organizes the \"winter sheep game\" (that way be both get once chance to participate each year).\n\n[Here's an example](https://sheep-game.lamdera.app/join/a217210861) of what it looks like when I played it with some Elm community members" ]
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
        , description = []
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
        , description = []
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
        , description = []
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
        , description = []
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
        , description = []
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
        , tags = [ Game, GameMaker, GameJam ]
        , description = []
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
        , tags = [ Game, GameMaker, GameJam ]
        , description = [ SimpleParagraph "I created this for the Game Maker Community game jam #3. Everyone had 3 days to make a game themed around the word \"live\". There were 56 entries and I placed 16th." ]
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
        , description = [ SimpleParagraph "I finished this before [Sanctum](/stuff/sanctum) but due to it being part of the Game Maker Community Game it didn't get released until later." ]
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
    , lamderaPackage "websocket" [] websiteReleasedAt (date 2021 May 16)
    , lamderaPackage "program-test" [] websiteReleasedAt (date 2021 Jul 7)
    , ( "making-a-game-with-elm-and-lamdera"
      , { name = "Making a game with Elm and Lamdera"
        , website = Just "https://www.youtube.com/watch?v=pZ_WqwRwwao"
        , tags = [ Game, Elm, Lamdera, Presentation ]
        , description = []
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
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/elm-online-preview.svg"
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
        , description = []
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
        , description = []
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
        , description = []
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
        , tags = [ Game, GameMaker, GameJam ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
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
        , description = [ SimpleParagraph "A 2d portal game I worked on and off on for a couple years. Really it was attempt four at a 2d portal game. The first three attempts were in Game Maker (which includes [enough-portals](/stuff/enough-portals)). It wasn't suited to the complexity or performance requirements so eventually I switched to using C#. I never got close to finishing this game but it's largely responsible for teaching me C# and helping me independently realize that inheritence is bad and pure functions and immutable data are good.\n\nThis is where my profile image originated. I picked [an icon](https://thenounproject.com/icon/work-in-progress-42732/) for Aventyr's exe file to indicate that it's a work in progress. Then for some reason I started using that icon for profile images (assuming I can be bothered with setting a profile image)" ]
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
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2014 Apr 1
                , endedAt = Just (date 2017 Jan 31)
                , elmPercentage = 0
                , columnIndex = 2
                }
        }
      )
    , ( "crivia"
      , { name = "Crivia"
        , website = Just "https://www.cliftonbazaar.games/games.php?game=crivia"
        , tags = [ Game, GameMaker, Job ]
        , description = [ SimpleParagraph "A game I was hired to make for a guy named James Clifton. Crivia or Cricket Trivia is a game about answering trivia questions about the sport Cricket. I was only paid like 60 USD for on and off work spanning 8 months so this kind of stretches the definition of a job but I think at the time I was more concerned with experience and resume building. The game was made in Game Maker with a tiny amount of PHP used for saving highscores to James' website." ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2013 Jun 4
                , endedAt = Just (date 2014 Feb 14)
                , elmPercentage = 0
                , columnIndex = 1
                }
        }
      )
    , ( "tretton37"
      , { name = "tretton37"
        , website = Just "https://www.tretton37.com/"
        , tags = [ CSharp, Elm, Job ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2016 Oct 31
                , endedAt = Just (date 2020 Jan 31)
                , elmPercentage = 5
                , columnIndex = 1
                }
        }
      )
    , ( "insurello"
      , { name = "Insurello"
        , website = Just "https://insurello.se/"
        , tags = [ FSharp, Elm, Job ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2020 Feb 3
                , endedAt = Just (date 2022 Feb 25)
                , elmPercentage = 50
                , columnIndex = 1
                }
        }
      )
    , ( "realia"
      , { name = "Realia"
        , website = Just "https://realia.se/"
        , tags = [ Elm, Lamdera, Job ]
        , description = [ SimpleParagraph "[Discourse post](https://discourse.elm-lang.org/t/using-lamdera-professionally/9142)" ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2021 Aug 18
                , endedAt = Just (date 2023 Apr 30)
                , elmPercentage = 100
                , columnIndex = 2
                }
        }
      )
    , ( "ambue"
      , { name = "Ambue"
        , website = Just "https://ambue.com/"
        , tags = [ Elm, Lamdera, Job ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            JobThing
                { startedAt = date 2023 Aug 15
                , endedAt = Nothing
                , elmPercentage = 100
                , columnIndex = 1
                }
        }
      )
    , ( "demon-clutched-walkaround"
      , { name = "Demon Clutched walkaround"
        , website = Just "https://ambue.com/"
        , tags = [ Game, GameMaker ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
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
        , description = []
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
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
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
        , description = []
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
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
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
        , description = []
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
        , description = []
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
        , tags = [ Game, GameMaker, GameJam ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
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
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
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
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
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
        , tags = [ Javascript ]
        , description = []
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
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
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
        , tags = [ Game, GameMaker, GameJam ]
        , description = [ SimpleParagraph "A game I made for the 5th Game Maker Community game jam (aka GMC Jam). We had 3 days to make a game themed around the word \"facade\". [Last time I participated](/stuff/sanctum) I got 16th place, but this time I tied for 1st! As a result, I won a Mr. Karoshi tshirt ![Mr. Karoshi is a puzzle game where you help an office worker kill themselves](/break-the-facade/mr-karoshi.jpg), a coffee mug with YoYo Games branding, and free copy of Game Maker Studio pro (which let me export games to HTML5)!" ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
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
        , description = [ SimpleParagraph "I participated in a secret santa event where everyone made a little game for another randomly chosen participant. This is the game I made and in my opinion it's the has by far the highest fun to effort ratio of anything I've ever made." ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2015 Mar 7
                , repo = Nothing
                }
        }
      )
    , ( "ssrpg"
      , { name = "SSRPG"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = [ SimpleParagraph "I tried making a hex grid based fire emblem style game with a friend who went by the name SS (no, not *that* SS). Another friend named FQ drew the hex grid art. Unfortunately for them, I didn't get very far with this. Just a very basic turn based movement and combat system." ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/game-maker-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2015 Mar 7
                , repo = Nothing
                }
        }
      )
    , ( "memo-2020-credits"
      , { name = "Memo 2020 credits"
        , website = Just "https://memo-2020-credits.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2020 Dec 31
                , repo = Just "https://github.com/MartinSStewart/memo-credits-2020"
                }
        }
      )
    , ( "memo-lounge-3am"
      , { name = "Memo lounge 3am"
        , website = Just "https://martinsstewart.gitlab.io/memo-lounge-3am/"
        , tags = [ Elm ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2019 Dec 31
                , repo = Just "https://gitlab.com/MartinSStewart/memo-lounge-3am"
                }
        }
      )
    , ( "birthday-list"
      , { name = "Birthday list"
        , website = Nothing
        , tags = [ Elm ]
        , description = [ SimpleParagraph "I made a simple website that lists my friends birthdays ordered by how soon it will be. When it is someone's birthday, the website will show \"Happy Birthday <name>!\" with a image of a party hat. For a while me and my friends used this. Eventually though [my discord bot](/stuff/discord-bot) took over keeping track of birthdays.\n\nUnfortunately I can't show the website itself or the code since it has personal information." ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2019 Jun 14
                , repo = Nothing
                }
        }
      )
    , ( "tile-editor"
      , { name = "Tile editor"
        , website = Just "https://martinsstewart.gitlab.io/tile-editor/"
        , tags = [ Elm ]
        , description = [ SimpleParagraph "For one Christmas I asked for a level tileset as a present and my sister made me one! Then I made this tile editor so that I could make some kind of map with that tileset (just for admiring, you can't interact with it in any way).\n\nHere's a level my sister drew using it ![a level drawn with her tileset and my editor](/tile-editor/level.png)" ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2018 Dec 30
                , repo = Just "https://gitlab.com/MartinSStewart/tile-editor"
                }
        }
      )
    , ( "how-many-words-jo"
      , { name = "How many words Jo"
        , website = Just "https://martinsstewart.gitlab.io/how-many-words-jo/"
        , tags = [ Elm ]
        , description = [ SimpleParagraph "A friend (named Jo) participates in NaNoWriMo (National Novel Writing Month) each year. I made a website that would track how many words she would need to have written during the month to be on pace to meet her desired word count of 220k (aka a lot of words)." ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2019 Nov 1
                , repo = Just "https://gitlab.com/MartinSStewart/tile-editor"
                }
        }
      )
    , ( "summer-home-website"
      , { name = "Summer home website"
        , website = Nothing
        , tags = [ Elm ]
        , description = [ SimpleParagraph "My extended family shares ownership of a summer home in Sweden. I decided to make a website that would help people book a visit. And by that I mean, it would just let people pick a start and end date to their visit and then generate an email they could send to the person actually responsible for keep track of who was visiting. There's no link to the website or the code since it contains someone's email address and info about where the house is located. You're not missing out on much though. I did a terrible job of hosting images and the website looks like this now ![a website with broken image links](/summer-home/website.png)" ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2018 Dec 23
                , repo = Nothing
                }
        }
      )
    , ( "tretton37-game-jam"
      , { name = "tretton37 game jam"
        , website = Nothing
        , tags = [ Elm, Game, GameJam ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2012 Jul 30
                , repo = Just "https://github.com/MartinSStewart/tretton37-game-jam"
                }
        }
      )
    , ( "the-best-color"
      , { name = "The best color"
        , website = Just "https://the-best-color.lamdera.app/"
        , tags = [ Elm, Game, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/lamdera-preview.svg"
        , thingType =
            OtherThing
                { releasedAt = date 2020 Jan 27
                , repo = Just "https://github.com/MartinSStewart/best-color"
                }
        }
      )
    , ( "elm-online-survey"
      , { name = "Elm Online survey"
        , website = Just "https://audience-questions.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Oct 6
                , repo = Just "https://github.com/MartinSStewart/elm-online-survey"
                }
        }
      )
    , ( "time-loop-inc"
      , { name = "Time loop inc."
        , website = Just "https://time-travel-game.lamdera.app/"
        , tags = [ Elm, Game, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Jul 27
                , repo = Just "https://github.com/MartinSStewart/time-loop-inc"
                }
        }
      )
    , ( "question-and-answer"
      , { name = "Question and Answer"
        , website = Just "https://question-and-answer.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Oct 26
                , repo = Just "https://github.com/MartinSStewart/elm-qna"
                }
        }
      )
    , ( "elm-review-remove-duplicate-code"
      , { name = "elm-review-remove-duplicate-code"
        , website = Nothing
        , tags = [ Elm ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Jul 14
                , repo = Just "https://github.com/MartinSStewart/elm-review-remove-duplicate-code"
                }
        }
      )
    , ( "moment-of-the-month"
      , { name = "Moment of the Month"
        , website = Just "moment-of-the-month.lamdera.app"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 May 21
                , repo = Just "https://github.com/MartinSStewart/elm-moment-of-the-month"
                }
        }
      )
    , ( "memo-theatre"
      , { name = "Memo theatre"
        , website = Just "memo-theatre.lamdera.app"
        , tags = [ Elm, Game, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Mar 24
                , repo = Just "https://github.com/MartinSStewart/memo-theatre"
                }
        }
      )
    , ( "lego-loco-remake"
      , { name = "Lego Loco remake"
        , website = Nothing
        , tags = [ Elm, Game, CSharp ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2018 Jun 21
                , repo = Just "https://github.com/MartinSStewart/Lego-Loco-Remake"
                }
        }
      )
    , ( "lens"
      , { name = "Lens"
        , website = Nothing
        , tags = [ CSharp ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2017 Dec 7
                , repo = Just "https://github.com/MartinSStewart/Lens"
                }
        }
      )
    , ( "discord-spaceship-game"
      , { name = "Discord spaceship game"
        , website = Nothing
        , tags = [ CSharp, Game ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2018 Feb 12
                , repo = Just "https://github.com/MartinSStewart/DiscordSpaceshipGame"
                }
        }
      )
    , ( "foolproof-multiplayer-games-in-elm"
      , { name = "Foolproof* multiplayer* games in Elm*"
        , website = Just "https://www.youtube.com/watch?v=Fkj2Is6jxCE"
        , tags = [ Elm, Lamdera, Game, Presentation ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/elm-online-preview.svg"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Jul 7
                , repo = Nothing
                }
        }
      )
    , ( "emils-turn"
      , { name = "Emils turn"
        , website = Nothing
        , tags = [ Elm, Lamdera ]
        , description = [ SimpleParagraph "A simple app that helps me and my friend Emil remember whose turn it is to buy brownies to snack on after we take a break from bouldering. Took 20-30 minutes to make. ![Martin's turn](/emils-tur/image0.png) ![Emil's turn](/emils-tur/image1.png)" ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/lamdera-preview.svg"
        , thingType =
            OtherThing
                { releasedAt = date 2024 Jun 30
                , repo = Just "https://github.com/MartinSStewart/emils-turn"
                }
        }
      )
    , lamderaPackage "containers" [ SimpleParagraph """This package lets Elm users finally have a Dict and Set type that is both fast (not linear access time like [pzp-1997/assoc-list](https://package.elm-lang.org/packages/pzp1997/assoc-list/latest/)) while not requiring keys to be `comparable`.

In this article I want to discuss an interesting set of trade offs I discovered when designing a Dict/Set data structure that, as far as I can tell, are unavoidable regardless of which programming language you use.

But first some thanks are in order.
* Thank you [Robin](https://github.com/robinheghan) for the original implementation of this package https://github.com/elm-explorations/hashmap. You handled most of the work for me!
* Thank you [Ambue](https://ambue.com/) for letting me work on this package during work hours.
* Thank you [miniBill](https://github.com/miniBill) for the Dict test suite. Without it I would have missed a critical bug.

## So here's what I discovered

First, for the purposes of explaining this discovery, lets say a Dict is a type with the following API:
```elm
get : key -> Dict key value -> Maybe value
insert : key -> value -> Dict key value -> Dict key value
fromList : List (key, value) -> Dict key value
toList : Dict key value -> List (key, value)
```

Now let me list some properties that are really nice to have in a Dict type:
1. The `key` typevar can be any equatable type (so functions can't be used as keys but non-comparable types are allowed)
2. Two dicts with exactly the same key-value pairs are equal regardless of insertion order. For example, `elm fromList [ ("X", 0), ("Y", 1) ] == fromList [ ("Y", 1), ("X", 0) ]`
3. If `elm dictA == dictB` then `elm f dictA == f dictB` where `f` is an arbitrary function
4. Renaming/reordering record fields or custom type variants should never change the output of `toList`

My discovery is that, as far as I can tell, regardless of what programming language you use or performance characteristics you allow for, *it's impossible to have more than 3 of these properties in a Dict type*.

Now I don't have a mathematical proof to back this claim but I can explain why I believe it is true.

First, lets consider the built in Dict type (I'm going to refer to it as elm/dict even though there isn't any package named that). What properties does it have?

* Well it fails on 1. You can only have comparable keys.
* It passes on 2. You'll find that `elm fromList [ ("X", 0), ("Y", 1) ] == fromList [ ("Y", 1), ("X", 0) ]` is indeed true
* Passes on 3. And actually more broadly, outside of one language bug that exploits the fact that `NaN /= NaN`, any code written in Elm will pass on 3.
* Passes on 4. Again this is a global property of the Elm language. Renaming/reordering a record fields or custom type variants will never change the runtime behavior of your code (with the exception of reordering record fields affecting record constructors).

It's nice that elm/dict passes on 2, 3, and 4. But comparable keys are really restrictive! So lets try allowing for non-comparable keys while trying to keep those other nice properties.

Well, the question we immediately encounter is, how should `toList` sort the list of key-value pairs? With elm/dict the list is lexicographically sorted by the key. This is possible because all of the keys are comparable values. But what do we do if we have non-comparable keys? For example, suppose we have the following custom type being used as our key
```elm
type Color
    = Red
    | Green
    | Blue

myDict =
    fromList [ (Blue, 2), (Green, 1), (Red, 0) ]
```
We really only have 3 options for sorting:
A. Sort based on variant names. For example alphabetically sort the names in ascending order. Which gives us `elm toList myDict == [ (Blue, 2), (Green, 1), (Red, 0) ]`
B. Sort by the order the variants are defined. That gives us `elm toList myDict == [ (Red, 0), (Green, 1), (Blue, 2) ]`
C. Sort the list based on the order the key-value pairs were added. Then we get `elm toList [ (Blue, 2), (Green, 1), (Red, 0) ]` aka the original list.

Do any of these approaches to sorting let us keep all 4 of the nice to have properties?
A. Violates 4. If we rename a variant, it could potentially change it's alphabetical ordering and thereby change the output of `toList`.
B. Also violates 4. If we reorder our variants, that will change the output of `toList`
C. This does not violate 4! But what about 2 and 3?
    * Well it depends on how `==` is implemented for our Dict type. Supposed `dictA == dictB` is the same as writing `toList dictA == toList dictB`. Well in that case 2 fails. We can see that if we take the example we used on elm/dict earlier.
    ```elm
    fromList [ ("X", 0), ("Y", 1) ] == fromList [ ("Y", 1), ("X", 0) ]

    -- is converted into this because of how we defined == to work for dict equality
    toList (fromList [ ("X", 0), ("Y", 1) ]) == toList (fromList [ ("Y", 1), ("X", 0) ])

    -- which simplifies to this since ordering by insertion means toList and fromList cancel eachother out
    [ ("X", 0), ("Y", 1) ]) == [ ("Y", 1), ("X", 0) ]

    -- which is
    False
    ```
    On the bright side, property 3 is valid at least!
    * Okay well how about we make it so `dictA == dictB` instead checks that both dicts have the same key-values pairs while ignoring order? In that case 2 is valid! But lets look at 3. More specifically, consider this code
    ```elm
    dictA = fromList [ ("X", 0), ("Y", 1) ]
    dictB = fromList [ ("Y", 1), ("X", 0) ]

    -- This is now true since order doesn't matter when checking for equality
    dictA == dictB

    -- But if we were to do this
    toList dictA == toList dictB

    -- Then we get
    False
    ```
    This violates 3 which says `elm dictA == dictB` implies `elm f dictA == f dictB` for any function f.

You might argue I've skipped an obvious approach to sorting `toList`'s output, just don't sort at all! We'll leave it as an implementation detail of our Dict type. Maybe a hashmap, binary tree, or red-black tree?

Unfortunately that still sorts it, just in a way that probably ends up depending on variant names, variant order, and insertion order, all at the same time.

For example, if you're hashing the keys, what property of that key will you use? The variant names? The variant order? Its insertion order? If you don't use any of those, what is left? If you use a binary tree or red-black tree then instead of a hash function you need some kind of comparable function internally but you have the same problem. You need to compare based on *something* in the key. Even if you don't care about performance and your dict is just a list internally with `==` used on every existing key to check for duplicate keys (this is [pzp-1997/assoc-list](https://package.elm-lang.org/packages/pzp1997/assoc-list/latest/)'s approach) you still have to pick at least one of these 3 sorting approaches.

It's starting to feel like a game of whack-a-mole isn't it? Every time we try to force all 4 properties to be valid, one pops back up. Maybe we can solve this by thinking outside of the box?

For example, in our custom type example, what if we could define a unique function for each non-comparable type that tells the dict how to sort it? Maybe we could introduce some new syntax and make it look like this:
```elm
type Color
    = Red
    | Green
    | Blue
    compareWith(compareColor)

compareColor : Color -> Color -> Order
compareColor a b =
    Basics.compare (colorToInt a) (colorToInt b)

colorToInt : Color -> Order
colorToInt a =
    case a of
        Red -> 0
        Green -> 1
        Blue -> 2
```
I'd argue you this doesn't so much give you all 4 properties as it just forces us to give up 1 (non-comparable keys) but lets us make any type comparable. You can do this of course, and languages like Haskell let you do it, with various other trade-offs (how does this work with anonymous/structural records for example).

How about a framing challenge? From the start I said we'd say a Dict type has the following functions
```elm
get : key -> Dict key value -> Maybe value
insert : key -> value -> Dict key value -> Dict key value
fromList : List (key, value) -> Dict key value
toList : Dict key value -> List (key, value)
```
but `toList` is causing us lots of trouble. What if we just remove it?

Well we can. But we'd also need to remove any other functions iterate over the dict's key-value pairs (foldl and foldr for example). That's quite limiting.

Okay what if we keep toList but change it to this?
```elm
toList : (key -> key -> Order) -> Dict key value -> List (key, value)
```
Now the user has to choose how to sort the key-value pairs, problem solved!

That indeed solves it but it's not ideal. The first is that it's inconvenient. The second is that there are some types that can't easily be sorted by the user. For example
```elm
import Package exposing (OpaqueType)

dict : Dict OpaqueType Int
dict = ...

list =
    toList sortOpaqueType dict

sortOpaqueType =
    Debug.todo "How am I supposed to sort an opaque type that doesn't expose anything useful?? "
```
Maybe this situation is rare. Or rare enough that this approach is practical? Hard to say.

## Summary

To me it wasn't at all obvious from the start that I'd encounter so many trade-offs when all I wanted was a Dict type that didn't demand comparable keys. While I independently discovered this, I'm sure either many others have also figured this out, or alternatively, I've made a mistake somewhere and my conclusions aren't sound. I sure hope it's the latter. I really want all 4 of those properties in a dict package...

    """ ] websiteReleasedAt (date 2021 Sep 7)
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
    , "lamdera-containers"
    , "discord-bot"
    , "circuit-breaker"
    , "realia"
    , "elm-map"
    , "elm-codec-bytes"
    , "break-the-facade"
    , "state-of-elm-2022"
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
    , "elm-camp-2023"
    , "aventyr"
    , "hobby-scale-func-prog-sweden"
    , "hackman"
    , "zig-zag"
    , "vector-rockets"
    , "code-breakers"
    , "memo-2020-credits"
    , "surface-voyage"
    , "moment-of-the-month"
    , "question-and-answer"
    , "send-grid"
    , "ds-game-over"
    , "emils-turn"
    , "elm-box-packing"
    , "elm-review-remove-duplicate-code"
    , "elm-audio-presentation"
    , "the-best-color"
    , "demon-clutched-walkaround"
    , "tetherball-extreme-zombie-edition"
    , "elm-review-elm-ui-upgrade"
    , "elm-review-bot"
    , "foolproof-multiplayer-games-in-elm"
    , "lamdera-backend-debugger"
    , "building-a-meetup-clone-on-lamdera"
    , "elm-pdf"
    , "elm-online-survey"
    , "postmark-email-client"
    , "simple-survey"
    , "translation-editor"
    , "starship-corporation"
    , "memo-lounge-3am"
    , "time-loop-inc"
    , "tretton37-game-jam"
    , "sanctum"
    , "culminating-game"
    , "tile-editor"
    , "discord-spaceship-game"
    , "lens"
    , "state-of-elm-2023"
    , "stewart-everybody-net"
    , "german-game"
    , "lego-loco-remake"
    , "elm-bayer-matrix"
    , "fake-key-gen"
    , "birthday-list"
    , "enough-portals"
    , "hyperboggling"
    , "memo-theatre"
    , "summer-home-website"
    , "how-many-words-jo"
    , "crivia"
    , "gmc-jam-7-animation"
    , "ssrpg"
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
    | GameJam


type alias Thing =
    { name : String
    , website : Maybe String
    , tags : List Tag
    , description : List Formatting
    , pageLastUpdated : Date
    , pageCreatedAt : Date
    , previewImage : String
    , thingType : ThingType
    }


type ThingType
    = JobThing { startedAt : Date, endedAt : Maybe Date, elmPercentage : Int, columnIndex : Int }
    | OtherThing
        { repo : Maybe String
        , -- Very imprecise due to it being unclear what counts as "released at". If there isn't a clear release date, pick something that counts as when the thing became usable for or known to several people.
          releasedAt : Date
        }
    | PodcastThing { releasedAt : Date }
