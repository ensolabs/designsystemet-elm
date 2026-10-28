module Showcase.Code exposing (plain, view)

{-| A minimal Elm syntax highlighter for the story sources.

It tokenizes line by line: comments, strings, keywords, qualified names
(`Button.view`), types and numbers. No regexes and no JavaScript.

-}

import Html exposing (Html)
import Html.Attributes as Attr


{-| Code that isn't Elm (shell, JavaScript, CSS, HTML), shown as it is.
-}
plain : String -> Html msg
plain source =
    Html.pre [ Attr.class "code" ] [ Html.code [] [ Html.text source ] ]


view : String -> Html msg
view source =
    Html.pre [ Attr.class "code" ]
        [ Html.code [] (List.concatMap (\line -> tokens line ++ [ Html.text "\n" ]) (String.lines source)) ]


type Token
    = Plain String
    | Comment String
    | Str String
    | Keyword String
    | Module String
    | Type String
    | Number String


tokens : String -> List (Html msg)
tokens line =
    List.map viewToken (tokenize (String.toList line) [])


viewToken : Token -> Html msg
viewToken token =
    case token of
        Plain s ->
            Html.text s

        Comment s ->
            span "comment" s

        Str s ->
            span "string" s

        Keyword s ->
            span "keyword" s

        Module s ->
            span "module" s

        Type s ->
            span "type" s

        Number s ->
            span "number" s


span : String -> String -> Html msg
span class text =
    Html.span [ Attr.class ("code__" ++ class) ] [ Html.text text ]


tokenize : List Char -> List Token -> List Token
tokenize chars acc =
    case chars of
        [] ->
            List.reverse acc

        '-' :: '-' :: _ ->
            List.reverse (Comment (String.fromList chars) :: acc)

        '"' :: rest ->
            let
                ( body, remaining ) =
                    stringBody rest []
            in
            tokenize remaining (Str ("\"" ++ body) :: acc)

        c :: rest ->
            if Char.isAlpha c then
                let
                    ( word, remaining ) =
                        span_ isWordChar chars
                in
                tokenize remaining (classify word remaining :: acc)

            else if Char.isDigit c then
                let
                    ( number, remaining ) =
                        span_ (\x -> Char.isDigit x || x == '.') chars
                in
                tokenize remaining (Number number :: acc)

            else
                tokenize rest (appendPlain (String.fromChar c) acc)


classify : String -> List Char -> Token
classify word remaining =
    if List.member word keywords then
        Keyword word

    else if startsUpper word then
        if List.head remaining == Just '.' then
            Module word

        else
            Type word

    else
        Plain word


appendPlain : String -> List Token -> List Token
appendPlain s acc =
    case acc of
        (Plain p) :: rest ->
            Plain (p ++ s) :: rest

        _ ->
            Plain s :: acc


stringBody : List Char -> List Char -> ( String, List Char )
stringBody chars acc =
    case chars of
        [] ->
            ( String.fromList (List.reverse acc), [] )

        '\\' :: c :: rest ->
            stringBody rest (c :: '\\' :: acc)

        '"' :: rest ->
            ( String.fromList (List.reverse ('"' :: acc)), rest )

        c :: rest ->
            stringBody rest (c :: acc)


span_ : (Char -> Bool) -> List Char -> ( String, List Char )
span_ predicate chars =
    let
        go remaining acc =
            case remaining of
                c :: rest ->
                    if predicate c then
                        go rest (c :: acc)

                    else
                        ( String.fromList (List.reverse acc), remaining )

                [] ->
                    ( String.fromList (List.reverse acc), [] )
    in
    go chars []


isWordChar : Char -> Bool
isWordChar c =
    Char.isAlphaNum c || c == '_'


startsUpper : String -> Bool
startsUpper word =
    String.left 1 word |> String.any Char.isUpper


keywords : List String
keywords =
    [ "let", "in", "case", "of", "if", "then", "else", "type", "alias", "module", "exposing", "import", "as", "port" ]
