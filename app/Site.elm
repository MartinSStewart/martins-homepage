module Site exposing (config)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import SiteConfig exposing (SiteConfig)


config : SiteConfig
config =
    { canonicalUrl = "https://martinstewart.dev"
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.metaName "apple-mobile-web-app-capable" (Head.raw "content=\"yes\"")
    , Head.manifestLink "/manifest.json"
    , Head.sitemapLink "/sitemap.xml"
    ]
        |> BackendTask.succeed
