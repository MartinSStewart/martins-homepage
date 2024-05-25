module Things exposing (Tag(..), Thing, tagData, thingsIHaveDone)

import Dict exposing (Dict)
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


thingsIHaveDone : Dict String Thing
thingsIHaveDone =
    [ ( "town-collab"
      , { name = "town-collab"
        , tags = [ Elm, Game, Lamdera ]
        , description = "A game I've been working on, inspired by an old childrens game called Lego Loco"
        }
      )
    , ( "ascii-collab"
      , { name = "ascii-collab"
        , tags = [ Elm, Game, Lamdera ]
        , description = "An infinite canvas that people can draw ascii art on together"
        }
      )
    , ( "meetdown"
      , { name = "meetdown"
        , tags = [ Elm, Lamdera ]
        , description = ""
        }
      )
    , ( "circuit-breaker"
      , { name = "circuit-breaker"
        , tags = [ Elm, Game ]
        , description = ""
        }
      )
    , ( "elm-audio"
      , { name = "elm-audio"
        , tags = [ Elm, ElmPackage ]
        , description = ""
        }
      )
    , ( "elm-review-bot"
      , { name = "elm-review-bot"
        , tags = [ Elm, Lamdera ]
        , description = ""
        }
      )
    , ( "state-of-elm"
      , { name = "state-of-elm"
        , tags = [ Elm, Lamdera ]
        , description = ""
        }
      )
    , ( "elm-serialize"
      , { name = "elm-serialize"
        , tags = [ Elm, ElmPackage ]
        , description = ""
        }
      )
    , ( "elm-review-elm-ui-upgrade"
      , { name = "elm-review-elm-ui-upgrade"
        , tags = [ Elm, ElmPackage ]
        , description = ""
        }
      )
    , ( "lamdera-backend-debugger"
      , { name = "lamdera-backend-debugger"
        , tags = [ Elm, Lamdera ]
        , description = ""
        }
      )
    , ( "discord-bot"
      , { name = "discord-bot"
        , tags = [ Elm, Game ]
        , description = ""
        }
      )
    , ( "elm-pdf"
      , { name = "elm-pdf"
        , tags = [ Elm ]
        , description = ""
        }
      )
    , ( "send-grid"
      , { name = "send-grid"
        , tags = [ Elm, ElmPackage ]
        , description = ""
        }
      )
    , ( "postmark-elm-client"
      , { name = "postmark-elm-client"
        , tags = [ Elm, Lamdera ]
        , description = ""
        }
      )
    , ( "translation-editor"
      , { name = "translation-editor"
        , tags = [ Elm, Lamdera ]
        , description = ""
        }
      )
    , ( "elm-map"
      , { name = "elm-map"
        , tags = [ Elm, ElmPackage ]
        , description = ""
        }
      )
    , ( "elm-map"
      , { name = "simple-survey"
        , tags = [ Elm, Lamdera ]
        , description = ""
        }
      )
    , ( "sheep-game"
      , { name = "sheep-game"
        , tags = [ Elm, Lamdera ]
        , description = ""
        }
      )
    , ( "air-hockey-racing"
      , { name = "air-hockey-racing"
        , tags = [ Elm, Lamdera ]
        , description = ""
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
    , tags : List Tag
    , description : String
    }
