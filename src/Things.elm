module Things exposing
    ( Tag(..)
    , Thing
    , ThingType(..)
    , allTags
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
import LamderaContainers
import Route exposing (Route(..))
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
            { text = "JS", color = Ui.rgb 217 197 70, tooltip = "Made using JavaScript" }


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
            "package.elm-lang.org/packages/"
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
                , repo = "github.com/" ++ user ++ "/" ++ packageName |> Just
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
                , repo = "github.com/lamdera/" ++ packageName |> Just
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
        , website = Just "town-collab.app/"
        , tags = [ Elm, Game, Lamdera ]
        , description = [ Paragraph [ Text "A game I've been working on, inspired by an old children's game called Lego Loco" ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/town-collab/icon.webp"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Feb 11
                , repo = Just "github.com/MartinSStewart/town-collab"
                }
        }
      )
    , ( "ascii-collab"
      , { name = "ascii-collab"
        , website = Just "ascii-collab.app/"
        , tags = [ Elm, Game, Lamdera ]
        , description =
            [ Paragraph [ Text "An infinite canvas that people can draw ascii art on together. I wrote an ", ExternalLink "announcement post" "discourse.elm-lang.org/t/ascii-collab-draw-ascii-art-together-on-an-infinite-canvas/6273", Text " and a ", ExternalLink "follow up post" "discourse.elm-lang.org/t/ascii-collab-progress-update/7019", Text " about it. I also showed it off on ", ExternalLink "Hacker News" "news.ycombinator.com/item?id=29572662", Text " and then had to spend an hour removing all of the vandalism left behind (but at least people liked it)." ]
            , Section
                "Backstory"
                [ Paragraph [ Text "Back when I was active on the Game Maker Community forums, someone had the idea that we should hop onto ", ExternalLink "www.yourworldoftext.com" "yourworldoftext.com", Text " and draw some ascii art together. We had fun for a day or so but after that other people showed up and started vandalizing everything. Such is life on the internet." ]
                , Image "/ascii-collab/gmc.png" [ Text "I anticipated there would be griefers so I took screenshots of most of what we drew" ]
                , Paragraph [ Text "Years later I thought it would be fun to try drawing some ascii art again. I felt that I was reasonably good at it but I wanted to use something more sophisticated than yourworldoftext.com (which at least at the time, had no moderation tools and was missing basic features like undo/redo)." ]
                , Paragraph [ Text "Naturally the thing to do then was write my own multiplayer ascii drawing webapp! And fortunately I was using Lamdera at this point so I had a convenient way to implement both the frontend and backend purely (heh) in Elm." ]
                ]
            , Section
                "Ascii art (lots of it)"
                [ Paragraph [ Text "There is ", Bold "a lot", Text " of quality ascii art has accumulated over the years this site has been running. The rest of this article is going to showcase some of the cool stuff other people and me have drawn/made." ]
                , Paragraph [ Text "Real quick though, maybe some of you are thinking, ", Quote "Lots of quality ascii art? Easy! Copy-paste it from elsewhere!", Text " And yes, some ascii art is copied from elsewhere (I ask people to prefer drawing original stuff but I don't strictly enforce it)." ]
                , Paragraph [ Text "I'd say 80% of it is original art however! How do I know that? Ascii-collab lets you color code changes people have made. Using it we can tell, this is copied due to the unnaturally placed space characters." ]
                , Image "/ascii-collab/copied.png" [ Text "A chess knight" ]
                , Paragraph [ Text "And this is ", AltText "original work." " There are cases that are ambiguous. If there's a solid colored rectangle, that could be original art that has then been moved with the box selection tool." ]
                , Image "/ascii-collab/legit.png" [ Text "A large cat enjoying some ramen probably" ]
                ]
            ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/ascii-collab/preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2020 Sep 12
                , repo = Just "github.com/MartinSStewart/ascii-collab"
                }
        }
      )
    , ( "meetdown"
      , { name = "Meetdown"
        , website = Just "meetdown.app/"
        , tags = [ Elm, Lamdera ]
        , description = [ Paragraph [ ExternalLink "Announcement post" "discourse.elm-lang.org/t/i-made-a-meetup-com-clone/7480" ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/meetdown/logo.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Jun 27
                , repo = Just "github.com/MartinSStewart/meetdown"
                }
        }
      )
    , ( "circuit-breaker"
      , { name = "Circuit Breaker"
        , website = Just "martinsstewart.gitlab.io/hackman/"
        , tags = [ Elm, Game ]
        , description = [ Paragraph [ Text "I made a ", ExternalLink "blog post" "dev.to/martinsstewart/what-is-elm-and-a-game-i-m-making-with-it-3di1", Text " describing how Elm made it easier to create along with an ", ExternalLink "announcement post" "discourse.elm-lang.org/t/ive-created-a-game-in-elm/4844", Text "." ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2019 Dec 17
                , repo = Just "gitlab.com/MartinSStewart/hackman"
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
        , description = [ Paragraph [ ExternalLink "Discourse post" "discourse.elm-lang.org/t/i-created-218-pull-requests-in-3-days/7276" ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Aug 24
                , repo = Just "github.com/MartinSStewart/elm-review-bot"
                }
        }
      )
    , ( "state-of-elm-2022"
      , { name = "state-of-elm 2022"
        , website = Just "state-of-elm.com/2022"
        , tags = [ Elm, Lamdera ]
        , description = [ Paragraph [ ExternalLink "Announcement post" "discourse.elm-lang.org/t/state-of-elm-2022/8284", Text " and ", ExternalLink "results announcement" "discourse.elm-lang.org/t/state-of-elm-survey-results/8362", Text "." ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/elm-package-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 May 1
                , repo = Just "github.com/MartinSStewart/state-of-elm"
                }
        }
      )
    , ( "state-of-elm-2023"
      , { name = "state-of-elm 2023"
        , website = Just "state-of-elm.com/2023"
        , tags = [ Elm, Lamdera ]
        , description = [ Paragraph [ ExternalLink "Announcement post" "discourse.elm-lang.org/t/state-of-elm-2023/9307", Text " and a ", ExternalLink "closing post" "discourse.elm-lang.org/t/state-of-elm-2023-closed/9369", Text ". Embarrassingly I've never finished the results page for this so the results of this survey aren't published." ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Sep 3
                , repo = Just "github.com/MartinSStewart/state-of-elm"
                }
        }
      )
    , elmPackage
        "MartinSStewart"
        "elm-serialize"
        [ Paragraph [ ExternalLink "Discourse post" "discourse.elm-lang.org/t/elm-serialize-quickly-and-reliably-encode-and-decode-elm-values/6112/3" ] ]
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
                , repo = Just "github.com/MartinSStewart/elm-review-elm-ui-upgrade"
                }
        }
      )
    , ( "lamdera-backend-debugger"
      , { name = "Lamdera backend debugger"
        , website = Just "backend-debugger.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Jul 20
                , repo = Just "github.com/MartinSStewart/lamdera-backend-debugger"
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
                , repo = Just "github.com/MartinSStewart/elm-pdf"
                }
        }
      )
    , elmPackage "MartinSStewart" "send-grid" [] websiteReleasedAt (date 2020 Feb 15)
    , elmPackage "MartinSStewart" "elm-bayer-matrix" [ Paragraph [ Text "A package for generating ", ExternalLink "bayer matrices" "en.wikipedia.org/wiki/Ordered_dithering", Text ". These are useful for producing a dithering effect for partially transparent images. I used it for ", Link "surface-voyage" (Stuff__Slug_ { slug = "surface-voyage" }), Text " to fade out objects too close to the camera. That said, in hindsight it was silly to make a package for 50 lines of code though." ] ] websiteReleasedAt (date 2020 Feb 15)
    , elmPackage "MartinSStewart" "elm-box-packing" [] websiteReleasedAt (date 2020 Apr 25)
    , elmPackage
        "MartinSStewart"
        "elm-codec-bytes"
        [ Paragraph [ ExternalLink "Discourse post" "discourse.elm-lang.org/t/elm-codec-bytes-1-0-0-released/3989" ] ]
        websiteReleasedAt
        (date 2020 Feb 15)
    , elmPackage "MartinSStewart" "elm-geometry-serialize" [] websiteReleasedAt (date 2020 Jul 31)
    , elmPackage "MartinSStewart" "elm-nonempty-string" [] websiteReleasedAt (date 2020 Feb 15)
    , ( "postmark-email-client"
      , { name = "Postmark email client"
        , website = Just "postmark-email-client.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Jul 5
                , repo = Just "github.com/MartinSStewart/postmark-email-client"
                }
        }
      )
    , ( "elm-camp-2023"
      , { name = "Elm Camp 2023"
        , website = Just "elm.camp/23-denmark"
        , tags = [ Elm, Lamdera ]
        , description = [ Paragraph [ Text "I helped set up the website for Elm Camp 2023 and I created a simple website for displaying a schedule of events during the unconference. Also I borrowed a fancy camera and took photos while I was there." ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/elm-camp-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Jun 28
                , repo = Just "github.com/elm-camp/website"
                }
        }
      )
    , ( "translation-editor"
      , { name = "Translation editor"
        , website = Just "translations-editor.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 Feb 27
                , repo = Just "github.com/MartinSStewart/translation-editor"
                }
        }
      )
    , ( "elm-map"
      , { name = "elm-map"
        , website = Nothing
        , tags = [ Elm ]
        , description =
            [ Paragraph [ Text "While working at ", Link "Realia" (Stuff__Slug_ { slug = "realia" }), Text ", the app I was creating needed a map viewer so a user could see which realtors had sold properties in their area (so you could judge if they would do a good job selling your home). Initially I used Google Maps for this. From a user perspective, Google Maps is pretty good. From a programmer perspective it was really awful to work with. So I switched to Mapbox. It's better. And it has an ", ExternalLink "Elm package" "package.elm-lang.org/packages/gampleman/elm-mapbox/latest/", Text " too. Still not great though. So I decided to make my own map viewer written in Elm. I made a proof of concept for the vector tile decoding over the 2022 winter break (the map viewer would still be relying on the Mapbox server for data) and then in 2023 summer I convinced my boss (Sam) to let finish the rest during work time." ]
            , Paragraph [ Text "Later when I started working at ", Link "Ambue" (Stuff__Slug_ { slug = "ambue" }), Text " my new boss (Stephen) expressed interest in using the map viewer I had created in Elm for viewing homes that belonged to our client's portfolios. I got permission from Sam to open source the map viewer so it could use on at Ambue." ]
            ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/elm-map/preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 May 17
                , repo = Just "github.com/MartinSStewart/elm-map"
                }
        }
      )
    , ( "simple-survey"
      , { name = "simple-survey"
        , website = Just "simple-survey.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = [ Paragraph [ Text "A simple survey app! As of time of writing it only lets you create surveys with free text questions. Other survey creation tools can do a lot more than that. But simple-survey has the advantage of not spamming you with ads, not showing cookie/GDPR popups (while still respecting user privacy), or ask you to sign up. Initially it was created so that we could gather some attendee info before the first", Link "elm-camp" (Stuff__Slug_ { slug = "elm-camp-2023" }), Text ". Since then it's been used for the 2024 Elm camp and nothing else that I'm aware of." ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2023 May 21
                , repo = Just "github.com/MartinSStewart/simple-survey"
                }
        }
      )
    , ( "sheep-game"
      , { name = "Sheep game"
        , website = Just "sheep-game.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description =
            [ Paragraph [ Text "A game played with a group of friends where everyone is given the same list of questions and in secret everyone tries to pick the same answers as everyone else. Once everyone is done, for each question you count the number of answers that match your own. Whoever has the most matches in total wins." ]
            , Paragraph [ Text "I didn't come up with this idea, it's probably a pretty old concept. But I did make this app to speed up the process of collecting answers and displaying the results. My friends and I play it twice a year. I organize the \"summer sheep game\" and a friend organizes the \"winter sheep game\" (that way we both get once chance to participate each year)." ]
            , Paragraph [ ExternalLink "Here's an example" "sheep-game.lamdera.app/join/a217210861", Text " of what it looks like when I played it with some Elm community members" ]
            ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/sheep-game-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Jun 13
                , repo = Just "github.com/MartinSStewart/sheep-game"
                }
        }
      )
    , ( "air-hockey-racing"
      , { name = "Air Hockey Racing"
        , website = Just "air-hockey-racing.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Jun 14
                , repo = Just "github.com/MartinSStewart/air-hockey-racing"
                }
        }
      )
    , ( "elm-town-48"
      , { name = "Elm Town episode\u{00A0}48"
        , website = Just "elm.town/episodes/making-little-games-like-presents"
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
        , website = Just "elm.town/episodes/elm-town-64-the-network-effect"
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
        , website = Just "elm-radio.com/episode/state-of-elm-2022"
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
        , description = [ Paragraph [ Text "I created this for the Game Maker Community game jam #3. Everyone had 3 days to make a game themed around the word \"live\". There were 56 entries and I placed 16th." ] ]
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
        , description = [ Paragraph [ Text "I finished this before ", Link "Sanctum" (Stuff__Slug_ { slug = "sanctum" }), Text " but due to it being part of the Game Maker Community Game it didn't get released until later." ] ]
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
        , website = Just "www.youtube.com/watch?v=pZ_WqwRwwao"
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
        , website = Just "www.youtube.com/watch?v=3Nn5meBieh4"
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
        , website = Just "www.youtube.com/watch?v=o7M0JxgDfhE"
        , tags = [ Elm, Lamdera, Presentation ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Mar 16
                , repo = Just "github.com/MartinSStewart/lamdera-presentation"
                }
        }
      )
    , ( "hobby-scale-goto-aarhus"
      , { name = "Hobby scale (GOTO\u{00A0}Aarhus)"
        , website = Just "www.youtube.com/watch?v=o7M0JxgDfhE"
        , tags = [ Elm, Lamdera, Presentation ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Mar 16
                , repo = Just "github.com/MartinSStewart/lamdera-presentation"
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
                , repo = Just "github.com/MartinSStewart/audio-presentation"
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
        , website = Just "www.youtube.com/watch?v=Y_ExX2LT_bw"
        , tags = [ Game, CSharp ]
        , description = [ Paragraph [ Text "A 2d portal game I worked on and off on for a couple years. Really it was attempt four at a 2d portal game. The first three attempts were in Game Maker (which includes ", Link "enough-portals" (Stuff__Slug_ { slug = "enough-portals" }), Text ". It wasn't suited to the complexity or performance requirements so eventually I switched to using C#. I never got close to finishing this game but it's largely responsible for teaching me C# and helping me independently realize that inheritance is bad and pure functions and immutable data are good." ], Paragraph [ Text "This is where my profile image originated. I picked ", ExternalLink "an icon" "thenounproject.com/icon/work-in-progress-42732/", Text " for Aventyr's exe file to indicate that it's a work in progress. Then for some reason I started using that icon for profile images (when I can be bothered with setting a profile image)" ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/profile.png"
        , thingType =
            OtherThing
                { releasedAt = date 2016 Sep 22
                , repo = Just "github.com/MartinSStewart/Aventyr-Project"
                }
        }
      )
    , ( "starship-corporation"
      , { name = "Starship Corporation"
        , website = Just "store.steampowered.com/app/292330/Starship_Corporation/"
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
        , website = Just "www.cliftonbazaar.games/games.php?game=crivia"
        , tags = [ Game, GameMaker, Job ]
        , description = [ Paragraph [ Text "A game I was hired to make for a guy named James Clifton. Crivia or Cricket Trivia is a game about answering trivia questions about the sport Cricket. I was only paid like 60 USD for on and off work spanning 8 months so this kind of stretches the definition of a job but I think at the time I was more concerned with experience and resume building. The game was made in Game Maker with a tiny amount of PHP used for saving highscores to James' website." ] ]
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
        , website = Just "www.tretton37.com/"
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
        , website = Just "insurello.se/"
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
        , website = Just "realia.se/"
        , tags = [ Elm, Lamdera, Job ]
        , description = [ Paragraph [ ExternalLink "Discourse post" "discourse.elm-lang.org/t/using-lamdera-professionally/9142" ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/realia/logo.svg"
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
        , website = Just "ambue.com/"
        , tags = [ Elm, Lamdera, Job ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/ambue/ambue-logo.svg"
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
        , website = Nothing
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
        , website = Just "martinstewart.dev/"
        , tags = [ Elm, ElmPages ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/profile.png"
        , thingType =
            OtherThing
                { releasedAt = websiteReleasedAt
                , repo = Just "github.com/MartinSStewart/martins-homepage"
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
                , repo = Just "gitlab.com/MartinSStewart/surface-voyage"
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
        , description =
            [ Paragraph [ Text "A puzzle game I made for the 5th Game Maker Community game jam (aka GMC Jam). Participants had 72 hours to make a game themed around the word \"facade\"." ]
            , Video "res.cloudinary.com/dqqkfcvf6/video/upload/f_auto:video,q_auto/v1/martins-homepage/xfbuk6m7ilq4y9oywldj"
            , Paragraph [ Link "Last time I participated in the GMC Jam" (Stuff__Slug_ { slug = "sanctum" }), Text " I got 16th place, but this time I tied for 1st! As a result, I won a ", AltText "Mr.\u{00A0}Karoshi tshirt" "(Mr.\u{00A0}Karoshi is a rather grim puzzle game where you help an office worker kill themselves)", Text ", a coffee mug with YoYo Games branding, and free copy of Game Maker Studio pro!" ]
            , Image "/break-the-facade/mr-karoshi.jpg" [ Text "The Mr.\u{00A0}Karoshi t-shirt I won" ]
            , Paragraph [ Text "I think my favorite thing to come out of that years GMC Jam was a Youtuber named raocow deciding to play every game ", AltText "made for it" "(I believe that was the only GMC Jam he did. I can't find the source but I think he said it was too much work playing 60 or so mostly bad video games)", Text ". ", ExternalLink "Here he is playing Break the Facade" "www.youtube.com/watch?v=7ITH8CZXkbk", Text ". Judging by his comments towards the end of the video and the video description being ", Quote "I've oft repeated how much I like this general sort of both game and looks, so it'd be useless to repeat, even if I pretty much just did.", Text " I think it's safe to say he enjoyed playing it!" ]
            , Image "/break-the-facade/zig-winna-banner.png" [ Text "Someone drew banners for the top 3 places (or perhaps more, not sure). Here's mine! And yes, I picked Ziggler1 as my username on the GMC forums. Thanks past me." ]
            ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/break-the-facade/btfIconHighRes.png"
        , thingType =
            GameMakerThing
                { releasedAt = date 2012 Jan 30
                , download = "/break-the-facade/break-the-facade.exe"
                }
        }
      )
    , ( "secret-santa-game"
      , { name = "Secret santa game"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description =
            [ Paragraph [ Text "I participated in a secret santa event where everyone made a little game for another randomly chosen participant. This is the game I made. In my opinion it has by far the highest fun-to-effort ratio of anything I've ever made." ]
            , Video "res.cloudinary.com/dqqkfcvf6/video/upload/f_auto:video,q_auto/v1/martins-homepage/xdxibprfxfthcrtmjtiu"
            , Paragraph [ Text "The song that plays in the game is Norwegian Pirate by Two Steps From Hell" ]
            ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/secret-santa-game/santaHatIconHighRes.png"
        , thingType =
            GameMakerThing
                { releasedAt = date 2015 Mar 7
                , download = "/secret-santa-game/secret-santa-game.exe"
                }
        }
      )
    , ( "ssrpg"
      , { name = "SSRPG"
        , website = Nothing
        , tags = [ Game, GameMaker ]
        , description = [ Paragraph [ Text "I tried making a hex grid based fire emblem style game with a friend who went by the name SS (no, not *that* SS). Another friend named FQ drew the hex grid art. Unfortunately for them, I didn't get very far with this. Just a very basic turn based movement and combat system." ] ]
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
        , website = Just "memo-2020-credits.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2020 Dec 31
                , repo = Just "github.com/MartinSStewart/memo-credits-2020"
                }
        }
      )
    , ( "memo-lounge-3am"
      , { name = "Memo lounge 3am"
        , website = Just "martinsstewart.gitlab.io/memo-lounge-3am/"
        , tags = [ Elm ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2019 Dec 31
                , repo = Just "gitlab.com/MartinSStewart/memo-lounge-3am"
                }
        }
      )
    , ( "birthday-list"
      , { name = "Birthday list"
        , website = Nothing
        , tags = [ Elm ]
        , description =
            [ Paragraph [ Text "I made a simple website that lists my friends birthdays ordered by how soon it will be. When it is someone's birthday, the website will show ", Quote "Happy Birthday <name>!", Text " with a image of a party hat. For a while me and my friends used this. Eventually though ", Link "my discord bot" (Stuff__Slug_ { slug = "discord-bot" }), Text " took over keeping track of birthdays." ]
            , Paragraph [ Text "Unfortunately I can't show the website itself or the code since it has personal information." ]
            ]
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
        , website = Just "martinsstewart.gitlab.io/tile-editor/"
        , tags = [ Elm ]
        , description =
            [ Paragraph [ Text "For one Christmas I asked for a level tileset as a present and my sister made me one! Then I made this tile editor so that I could make some kind of map with that tileset (just for admiring, you can't interact with it in any way)." ]
            , Paragraph [ Text "Here's a level my sister drew using it ![a level drawn with her tileset and my editor](/tile-editor/level.png)" ]
            ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2018 Dec 30
                , repo = Just "gitlab.com/MartinSStewart/tile-editor"
                }
        }
      )
    , ( "how-many-words-jo"
      , { name = "How many words Jo"
        , website = Just "martinsstewart.gitlab.io/how-many-words-jo/"
        , tags = [ Elm ]
        , description = [ Paragraph [ Text "A friend (named Jo) participates in NaNoWriMo (National Novel Writing Month) each year. I made a website that would track how many words she would need to have written during the month to be on pace to meet her desired word count of 220k (aka a lot of words)." ] ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2019 Nov 1
                , repo = Just "gitlab.com/MartinSStewart/how-many-words-jo"
                }
        }
      )
    , ( "summer-home-website"
      , { name = "Summer home website"
        , website = Nothing
        , tags = [ Elm ]
        , description = [ Paragraph [ Text "My extended family shares ownership of a summer home in Sweden. I decided to make a website that would help people book a visit. And by that I mean, it would just let people pick a start and end date to their visit and then generate an email they could send to the person actually responsible for keep track of who was visiting. There's no link to the website or the code since it contains private information. You're not missing out on much though. The background image doesn't load anymore and the styling messed up." ] ]
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
                , repo = Just "github.com/MartinSStewart/tretton37-game-jam"
                }
        }
      )
    , ( "the-best-color"
      , { name = "The best color"
        , website = Just "the-best-color.lamdera.app/"
        , tags = [ Elm, Game, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/lamdera-preview.svg"
        , thingType =
            OtherThing
                { releasedAt = date 2020 Jan 27
                , repo = Just "github.com/MartinSStewart/best-color"
                }
        }
      )
    , ( "elm-online-survey"
      , { name = "Elm Online survey"
        , website = Just "audience-questions.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Oct 6
                , repo = Just "github.com/MartinSStewart/elm-online-survey"
                }
        }
      )
    , ( "time-loop-inc"
      , { name = "Time loop inc."
        , website = Just "time-travel-game.lamdera.app/"
        , tags = [ Elm, Game, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2022 Jul 27
                , repo = Just "github.com/MartinSStewart/time-loop-inc"
                }
        }
      )
    , ( "question-and-answer"
      , { name = "Question and Answer"
        , website = Just "question-and-answer.lamdera.app/"
        , tags = [ Elm, Lamdera ]
        , description = []
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/discord-bot-preview.png"
        , thingType =
            OtherThing
                { releasedAt = date 2021 Oct 26
                , repo = Just "github.com/MartinSStewart/elm-qna"
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
                , repo = Just "github.com/MartinSStewart/elm-review-remove-duplicate-code"
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
                , repo = Just "github.com/MartinSStewart/elm-moment-of-the-month"
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
                , repo = Just "github.com/MartinSStewart/memo-theatre"
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
                , repo = Just "github.com/MartinSStewart/Lego-Loco-Remake"
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
                , repo = Just "github.com/MartinSStewart/Lens"
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
                , repo = Just "github.com/MartinSStewart/DiscordSpaceshipGame"
                }
        }
      )
    , ( "foolproof-multiplayer-games-in-elm"
      , { name = "Foolproof* multiplayer* games in Elm*"
        , website = Just "www.youtube.com/watch?v=Fkj2Is6jxCE"
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
        , description =
            [ Paragraph [ Text "A simple app that helps me and my climbing buddy Emil remember whose turn it is to buy brownies to snack on after we take a break from bouldering. Took 20-30 minutes to make." ]
            , Image "/emils-tur/image0.png" [ Text "My turn to buy brownies!" ]
            , Image "/emils-tur/image1.png" [ Text "Emil's turn to buy brownies!" ]
            ]
        , pageLastUpdated = websiteReleasedAt
        , pageCreatedAt = websiteReleasedAt
        , previewImage = "/lamdera-preview.svg"
        , thingType =
            OtherThing
                { releasedAt = date 2024 Jun 30
                , repo = Just "github.com/MartinSStewart/emils-turn"
                }
        }
      )
    , lamderaPackage "containers" LamderaContainers.content (date 2024 Sep 22) (date 2024 Sep 22)
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


allTags : List Tag
allTags =
    [ ElmPackage
    , ElmPages
    , Elm
    , FSharp
    , Game
    , Presentation
    , Javascript
    , Job
    , Podcast
    , GameJam
    , GameMaker
    , CSharp
    , Lamdera
    ]


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
    | GameMakerThing { download : String, releasedAt : Date }
