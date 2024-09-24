module LamderaContainers exposing (content)

import Formatting exposing (Formatting(..), Inline(..))


content : List Formatting
content =
    [ Paragraph
        [ Text "This package was released along with "
        , ExternalLink "version 1.3" "dashboard.lamdera.app/releases/v1-3-0"
        , Text " of the Lamdera compiler. It uses "
        , AltText "kernel code" "(a term used by the Elm community when referring to JavaScript code directly invoked from Elm code instead of via ports. It's not possible for ordinary apps or packages to contain their own kernel code)"
        , Text " to allow Elm programmers to finally have a Dict and Set type that does not require "
        , Code "comparable"
        , AltText " keys" "(the only comparable types in Elm are String, Int, and Float, along with List and Tuple when they have comparable type parameters)"
        , Text " or require any workarounds, while also being similar in performance to the "
        , ExternalLink "built-in Dict" "package.elm-lang.org/packages/elm/core/latest/Dict"
        , Text " and "
        , ExternalLink "Set" "package.elm-lang.org/packages/elm/core/latest/Set"
        , Text " types."
        ]
    , Paragraph [ Text "In this article I want to show a discovery I made while working on this. It's a set of significant trade-offs I faced that, as far as I can tell, are unavoidable regardless of how you go about designing a Dict/Set data structure." ]
    , BulletList
        [ Bold "But first some thanks are in order!" ]
        [ Paragraph
            [ Text "Thank you "
            , ExternalLink "Robin" "github.com/robinheghan"
            , Text " for the "
            , ExternalLink "original implementation" "github.com/elm-explorations/hashmap"
            , Text " of this package. You handled most of the work for me!"
            ]
        , Paragraph
            [ Text "Thank you "
            , ExternalLink "Ambue" "ambue.com/"
            , Text " for letting me work on this package during work hours."
            ]
        , Paragraph
            [ Text "Thank you "
            , ExternalLink "miniBill" "github.com/miniBill"
            , Text " for the "
            , ExternalLink "Dict test suite" "github.com/miniBill/elm-fast-dict/tree/main/tests"
            , Text ". Without it I would have missed some critical bugs."
            ]
        ]
    , Section "So here's what I discovered"
        [ Paragraph [ Text "First, for the purposes of explaining this discovery, lets say a Dict is a type with the following API:" ]
        , CodeBlock """get : key -> Dict key value -> Maybe value

insert : key -> value -> Dict key value -> Dict key value

fromList : List (key, value) -> Dict key value

toList : Dict key value -> List (key, value)
"""
        , NumberList [ Text "Now let me list some properties that are really nice to have in a Dict type:" ]
            [ Paragraph [ Text "The ", Code "key", Text " type variable doesn't have to be ", Code "comparable" ]
            , Paragraph
                [ Text "Two dicts with exactly the same key-value pairs are equal regardless of insertion order. For example, "
                , Code """fromList [ ("X", 0), ("Y", 1) ] == fromList [ ("Y", 1), ("X", 0) ]"""
                ]
            , Paragraph
                [ Text "If "
                , Code "dictA == dictB"
                , Text " then "
                , Code "f dictA == f dictB"
                , Text " where "
                , Code "f"
                , Text " can be any "
                , AltText "function" "(I believe in mathematics, something that has this property is referred to as being well-defined)"
                ]
            , Paragraph [ Text "Renaming/reordering record fields or ", AltText "custom type variants" "(custom types is Elm's word for discriminated unions. And a variant is one of the possible values for the discriminated union)", Text " should never change the order of key-value pairs returned from ", Code "toList" ]
            ]
        , Paragraph
            [ Text "My discovery is that, as far as I can tell, regardless of what programming language you use or performance characteristics you allow for, "
            , Bold "it's impossible to have more than three of these properties in a Dict type"
            , Text "."
            ]
        , Paragraph [ Italic "For the sake of brevity, I'll refer to these properties by number through-out the rest of the article. " ]
        ]
    , Section "Why should you care?"
        [ NumberList [ Text "I expect some readers will wonder why these properties matter. Maybe they feel arbitrary. Let me make a case for why they are important:" ]
            [ Paragraph [ Text "We want keys to be non-comparable for the sake of convenience and type-safety. It's annoying when I have ", Code "type Id = Id String", Text " or ", Code "{ x : Int, y : Int }", Text " and I have to convert them into a ", Code "comparable", Text " type before they can be used as a key. This leads to boilerplate code and increased risk of mixing up types which can lead to bugs." ]
            , Paragraph [ Text "Having two Dicts be equal based on contents, regardless of insertion order is nice but often not that big a deal. But for Sets it's kind of their whole purpose. And Sets are essentially just an alias for ", Code "Dict\u{00A0}key\u{00A0}()" ]
            , BulletList
                [ Code "dictA == dictB"
                , Text " implies "
                , Code "f dictA == f dictB"
                , Text " is quite handy:"
                ]
                [ Paragraph [ Text "If two values are equal and the same function is applied to both, you can save yourself CPU time by only computing one and reusing the result. This can also be used for caching." ]
                , Paragraph [ Text "It's easier to reason about what some code does if you are certain that ", Code "==", Text " means two values are indistinguishable no matter what you do to them." ]
                , Paragraph
                    [ Text "Any code written in Elm will have this property. It would be a shame for "
                    , Code2 "lamdera/containers"
                    , Text " to introduce some kernel code that violates this!"
                    ]
                ]
            , Paragraph [ Text "People often mention that when refactoring in Elm, they feel safe making large changes to their code. Part of why this is true is because renaming or reordering functions/types/fields/variants will never affect the runtime behavior of Elm code (with the sole exception being field order affecting ", AltText " record constructors" "Record constructors are functions that are created for any record type the user defines. The order of parameters is determined by the order of the record fields", Text "). It would be a shame to lose this just because, ", Code "Dict.toList", Text " would change when renaming/reordering record fields or custom type variants." ]
            ]
        ]
    , Section "Rock solid mathematical proof"
        [ Paragraph [ Text "I don't have a mathematical proof to back this claim but let me explain why I believe it is true." ]
        , NumberList [ Text "First, lets consider the built-in Dict type. Which of the 4 properties does it support?" ]
            [ Paragraph [ Text "Well it fails on 1. You can only have ", Code "comparable", Text " keys." ]
            , Paragraph
                [ Text "It passes on 2. You'll find that "
                , Code """fromList [ ("X", 0), ("Y", 1) ] == fromList [ ("Y", 1), ("X", 0) ]"""
                , Text " is indeed true."
                ]
            , Paragraph
                [ Text "Passes on 3. ", Code "dictA == dictB", Text " implies ", Code "f dictA == f dictB" ]
            , Paragraph [ Text "And passes on 4. Since the built-in Dict only allows for ", Code "comparable", Text " keys, records and custom types aren't allowed. Which in turn means there's no way for renames or reorderings to affect ", Code "toList" ]
            ]
        , Paragraph [ Text "It's nice that the built-in Dict passes on 2, 3, and 4. But ", Code "comparable", Text " keys are really restrictive! So let's try allowing for non-comparable keys while trying to keep those other nice properties." ]
        , Paragraph
            [ Text "Well, the question we immediately encounter is, how should "
            , Code "toList"
            , Text " sort the list of key-value pairs it returns? With the built-in Dict this is easy because all of the keys are "
            , Code "comparable"
            , Text " values. But what do we do if we have non-comparable keys? For example, suppose we have the following custom type being used as our key."
            ]
        , CodeBlock """type Color
    = Red
    | Green
    | Blue

myDict =
    fromList [ (Blue, 2), (Green, 1), (Red, 0) ]
"""
        , LetterList [ Text "We have three options:" ]
            [ Paragraph
                [ Text "Sort based on variant names. For example alphabetically sort the names in ascending order. Which gives us "
                , Code "toList myDict == [\u{00A0}(Blue,\u{00A0}2),\u{00A0}(Green,\u{00A0}1),\u{00A0}(Red,\u{00A0}0) ]"
                ]
            , Paragraph
                [ Text "Sort by the order the variants are defined in code. That gives us "
                , Code "toList myDict == [\u{00A0}(Red,\u{00A0}0),\u{00A0}(Green,\u{00A0}1),\u{00A0}(Blue,\u{00A0}2) ]"
                ]
            , Paragraph
                [ Text "Sort the list based on the order the key-value pairs were added. Then we get "
                , Code "toList myDict == [\u{00A0}(Blue,\u{00A0}2),\u{00A0}(Green,\u{00A0}1),\u{00A0}(Red,\u{00A0}0) ]"
                , Text " which is just the original list."
                ]
            ]
        , LetterList [ Text "Do any of these approaches to sorting let us keep all 4 of the nice-to-have properties?" ]
            [ Paragraph
                [ Text "Violates 4. If we rename a variant, it could potentially change its alphabetical ordering and thereby change the output of "
                , Code "toList"
                , Text "."
                ]
            , Paragraph [ Text "Also violates 4. If we reorder our variants, that will change the output of ", Code "toList" ]
            , BulletList [ Text "This does not violate 4! But what about 2 and 3?" ]
                [ Group
                    [ Paragraph
                        [ Text "Well it depends on how "
                        , Code "=="
                        , Text " is implemented for our Dict type. Supposed "
                        , Code "dictA == dictB"
                        , Text " is the same as writing "
                        , Code "toList dictA == toList dictB"
                        , Text ". In that case 2 fails in the following example:"
                        ]
                    , CodeBlock """a = fromList [ ("X", 0), ("Y", 1) ] == fromList [ ("Y", 1), ("X", 0) ]

-- is converted into this because of how we defined == to work for dict equality
a = toList (fromList [ ("X", 0), ("Y", 1) ]) == toList (fromList [ ("Y", 1), ("X", 0) ])

-- simplifies to this since ordering by insertion means toList and fromList cancel eachother out
a = [ ("X", 0), ("Y", 1) ] == [ ("Y", 1), ("X", 0) ]

-- which is
a = False
"""
                    , Paragraph [ Text "On the bright side, property 3 is valid at least!" ]
                    ]
                , Group
                    [ Paragraph [ Text "Okay well how about we make it so ", Code "dictA == dictB", Text " checks that both dicts have the same key-values pairs while ignoring order? In that case 2 is valid! But let's look at 3. Consider this code:" ]
                    , CodeBlock """dictA = fromList [ ("X", 0), ("Y", 1) ]
dictB = fromList [ ("Y", 1), ("X", 0) ]

a = dictA == dictB --> True

b = toList dictA == toList dictB --> False
"""
                    , Paragraph
                        [ Text "This violates 3 which says that if ", Code "dictA == dictB", Text " is true, then that implies ", Code "f dictA == f dictB", Text " is also true for any function ", Code "f", Text ". In our example that's not the case when ", Code "f", Text " is ", Code "toList" ]
                    ]
                ]
            ]
        , Paragraph [ Text "You might argue I've skipped an obvious approach to sorting ", Code "toList", Text "'s output. Just don't sort at all! We'll leave it as an implementation detail of our Dict type. Maybe a hashmap or binary tree?" ]
        , Paragraph [ Text "Unfortunately that still sorts it, just in a way that probably ends up depending on some combination of variant name, variant order, and insertion order." ]
        , Paragraph [ Text "For example, if you use a hashmap, how will you hash custom types? Maybe ", Code "hash (variantName + data)", Text "? Or perhaps ", Code "hash (variantIndex + data)", Text "? If you don't use any of those, what is left? If you use a binary tree then instead of a hash function you need some kind of ", Code "comparable", Text " function internally but you have the same problem. You need to compare keys based on ", Italic "something", Text ". Even if you don't care about performance and your dict is just a list with ", Code "==", Text " used on every existing key to check for duplicates you end up with it depending on insertion order." ]
        , Paragraph [ Text "It's starting to feel like a game of whack-a-mole isn't it? Every time we try to force one property to be valid, another one breaks. Maybe we can solve this by thinking outside of the box?" ]
        ]
    , Section "Time for some lateral thinking"
        [ Paragraph [ Text "In our custom type example, what if we could allow the user to define a function for each non-comparable type that tells the dict how to sort it? Maybe we could introduce some new syntax and have it look like this:" ]
        , CodeBlock """type Color
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
"""
        , Paragraph [ Text "I'd argue you this doesn't give you all 4 properties. We're instead giving up 1 (non-comparable keys) but with a way to make custom types ", Code "comparable", Text ". Languages like Haskell support this but it comes with its own set of trade-offs (for example, how does this work with anonymous/structural records)." ]
        , Paragraph [ Text "How about a framing challenge? From the start I said our Dict type has the following functions" ]
        , CodeBlock """get : key -> Dict key value -> Maybe value

insert : key -> value -> Dict key value -> Dict key value

fromList : List (key, value) -> Dict key value

toList : Dict key value -> List (key, value)
"""
        , Paragraph [ Text "but ", Code "toList", Text " is causing us lots of trouble. What if we just remove it?" ]
        , Paragraph [ Text "Well we can. But we'd also need to remove any other functions that iterate over the dict's key-value pairs such as ", Code "merge", Text " and ", Code "foldl", Text ". That's quite limiting." ]
        , Paragraph [ Text "Okay what if we keep toList but change it to this?" ]
        , CodeBlock """toList : (key -> key -> Order) -> Dict key value -> List (key, value)"""
        , Paragraph [ Text "Now the user has to choose how to sort the key-value pairs, problem solved!" ]
        , Paragraph [ Text "That indeed solves it but it's not ideal. The first reason is that it's inconvenient. The second is that there are some types that can't easily be sorted by the user. For example" ]
        , CodeBlock """import SomePackage exposing (OpaqueType)

dict : Dict OpaqueType Int
dict = fromList [ ... ]

list = toList sortBy dict

sortBy = Debug.todo "How do I sort an opaque type that doesn't expose any data I can use to sort with?"
"""
        , Paragraph [ Text "Maybe this situation is rare enough that this approach is practical? Hard to say." ]
        ]
    , Section "Conclusion"
        [ Paragraph [ Text "It wasn't at all obvious to me from the start that I'd encounter so many trade-offs when all I wanted was a Dict type that didn't demand ", Code "comparable", Text " keys. While I independently discovered this, I'm sure either other people have also figured this out, or alternatively, I've made a mistake somewhere and my conclusions are incorrect. I sure hope it's the latter. I ", Italic "really", Text " want all 4 of those properties in a dict package..." ]
        , NumberList [ Text "Oh. And you probably want to know which properties I ended up choosing for the Dict and Set type in ", Code2 "lamdera/containers", Text ". It was difficult to decide but here's what I settled on:" ]
            [ Paragraph [ Text "Obviously I included support for non-comparable keys. This whole package would be pointless without it." ]
            , Paragraph [ Text "I gave up ", Code """fromList [ ("X", 0), ("Y", 1) ] == fromList [ ("Y", 1), ("X", 0) ]""", Text ". This means if you want to check if two Dicts or Sets are equal, you'll need to use an extra function called ", Code "unorderedEquals", Text ". This isn't ideal since you can't use it on a larger data structure that contains ", AltText "a Set." "With kernel code it would be possible to implement an unorderedEquals function that works on any type but it would involve even more kernel code. I'd rather not resort to that unless people find they regularly need such a function." ]
            , Paragraph [ Text "I kept 3." ]
            , Group [ Paragraph [ Text "I kept 4." ] ]
            ]
        , Paragraph [ Text "Both 3 and 4 are preserved for the same reason. They are properties guaranteed by Elm and that ultimately seemed more valuable than 2." ]
        ]
    , Section "Follow-up questions I've gotten"
        [ Section "Is it possible to pick any combination of three properties?"
            [ NumberList [ Text "It is! Let's look at the possibilities:" ]
                [ Paragraph [ Text "If we pick all but 1 then we have the built-in Dict." ]
                , Paragraph [ Text "If we pick all but 2 then you get this package." ]
                , Paragraph [ Text "If we pick all but 3, one example would be a Dict with a ", Code "toList", Text " function that returns keys by insertion order and ", Code "==", Text " ignores insertion order. There no existing packages that support this since Elm guarantees property 3. You'd need kernel code to implement it." ]
                , Paragraph [ Text "If we pick all but 4, ", Code "toList", Text " sorts keys alphabetically, ", Code "==", Text " ignores order, keys are not required to be ", Code "comparable", Text ", but as a result, renaming fields/variants can affect ", Code "toList", Text ". Like with 3, there's no existing packages that do this since Elm guarantees 4 and you'd need kernel code to work around that." ]
                ]
            , Paragraph [ Text "And of course, you can pick fewer than three properties. Elm is rare in that it guarantees properties 3 and 4 for any user code. Most languages don't and that probably extends to their respective Dict types." ]
            ]
        , Section "Can this package be used with the normal Elm compiler?"
            [ Paragraph [ Text "This package is only supported by the ", AltText "Lamdera compiler" "(the Lamdera compiler is a backwards compatible fork of the Elm compiler)", Text ". In part this is because it contains kernel code and it's unlikely I'd be allowed to publish it to the Elm package ecosystem. But even if I was allowed, it also overrides ", Code "Debug.toString", Text " and ", Code "==", Text " which is only possible due to some changes to the compiler." ]
            ]
        ]
    ]
