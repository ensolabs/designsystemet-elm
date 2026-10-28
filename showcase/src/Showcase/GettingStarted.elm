module Showcase.GettingStarted exposing (view)

{-| A complete, tested recipe for a new app: Elm, Bun, this package, and
optionally Tailwind. Every file here was built and checked in a browser, in
both `bun run dev` and `bun run build`. Keep it that way: when a step changes,
follow the recipe from an empty folder again.
-}

import Designsystemet as Ds
import Designsystemet.Heading as Heading
import Designsystemet.Paragraph as Paragraph
import Html exposing (Html)
import Showcase.Code as Code


view : Html msg
view =
    Html.div []
        [ Heading.h3 [ Heading.size Heading.Small ] [ Html.text "Getting started with Bun" ]
        , Paragraph.view []
            [ Html.text "From an empty folder to a running app. Bun's CSS bundler can't parse Designsystemet's CSS, so never import or bundle it: serve it as files and link it from JavaScript. The rest is ordinary Bun." ]
        , step "1. Install"
        , Paragraph.view []
            [ Html.text "In an empty folder (the first "
            , Html.code [] [ Html.text "bun add" ]
            , Html.text " creates package.json):"
            ]
        , Code.plain installCommands
        , step "2. Add the files"
        , file "src/Main.elm"
        , Code.view mainElm
        , file "index.html"
        , Code.plain indexHtml
        , file "main.js"
        , Code.plain mainJs
        , file "style.css"
        , Code.plain styleCss
        , file "vendor.js"
        , Code.plain vendorJs
        , file "dev.js"
        , Code.plain devJs
        , file "build.js"
        , Code.plain buildJs
        , file "package.json (add the scripts)"
        , Code.plain packageScripts
        , step "3. Run it"
        , Code.plain runCommands
        , Paragraph.view []
            [ Html.text "After changing Elm code, run "
            , Html.code [] [ Html.text "bun run elm" ]
            , Html.text " and reload the page. "
            , Html.code [] [ Html.text "dist/" ]
            , Html.text " is a static site: serve the whole folder, "
            , Html.code [] [ Html.text "vendor/" ]
            , Html.text " included. Add "
            , Html.code [] [ Html.text "node_modules" ]
            , Html.text ", "
            , Html.code [] [ Html.text "elm-stuff" ]
            , Html.text " and "
            , Html.code [] [ Html.text "dist" ]
            , Html.text " to .gitignore if you use git."
            ]
        , Heading.h3 [ Heading.size Heading.Small ] [ Html.text "Adding Tailwind" ]
        , Paragraph.view []
            [ Html.text "Tailwind v4 can take the theme's tokens as its own, so "
            , Html.code [] [ Html.text "bg-accent-surface-tinted" ]
            , Html.text ", "
            , Html.code [] [ Html.text "p-4" ]
            , Html.text " and "
            , Html.code [] [ Html.text "shadow-md" ]
            , Html.text " come from Designsystemet and follow "
            , Html.code [] [ Html.text "Ds.color" ]
            , Html.text ", "
            , Html.code [] [ Html.text "Ds.size" ]
            , Html.text " and dark mode. On top of the setup above:"
            ]
        , step "1. Install"
        , Code.plain tailwindInstall
        , step "2. Use the plugin in the dev server"
        , file "bunfig.toml"
        , Code.plain bunfig
        , step "3. Use it in the build"
        , file "build.js"
        , Code.plain tailwindBuildJs
        , step "4. Replace style.css"
        , file "style.css"
        , Code.plain tailwindStyleCss
        , Paragraph.view []
            [ Html.text "Without the "
            , Html.code [] [ Html.text "@layer" ]
            , Html.text " line, component styles beat utilities ("
            , Html.code [] [ Html.text "mt-4" ]
            , Html.text " on a Paragraph does nothing); it must be in the first stylesheet the page loads, so keep "
            , Html.code [] [ Html.text "style.css" ]
            , Html.text " first in index.html. Never "
            , Html.code [] [ Html.text "@import" ]
            , Html.text " Designsystemet's own CSS here: Bun can't parse it, and loaded before Tailwind its layers come first and Tailwind's reset strips the buttons. Without "
            , Html.code [] [ Html.text "theme(inline)" ]
            , Html.text ", utilities ignore "
            , Html.code [] [ Html.text "Ds.size" ]
            , Html.text " and a nested color scheme. Use the quoted form of "
            , Html.code [] [ Html.text "@import" ]
            , Html.text "; Tailwind passes "
            , Html.code [] [ Html.text "url(…)" ]
            , Html.text " through unread."
            ]
        , Paragraph.view []
            [ Html.text "Restart "
            , Html.code [] [ Html.text "bun run dev" ]
            , Html.text " so the dev server loads the plugin."
            ]
        , step "5. Use classes"
        , Paragraph.view []
            [ Html.text "In src/Main.elm, add "
            , Html.code [] [ Html.text "import Html.Attributes as Attr" ]
            , Html.text " and replace "
            , Html.code [] [ Html.text "view" ]
            , Html.text " with:"
            ]
        , Code.view tailwindElm
        , Paragraph.view []
            [ Html.code [] [ Html.text "Ds.color Color.danger" ]
            , Html.text " is on the box now, so both buttons and the tint inside it turn red."
            ]
        , Paragraph.view []
            [ Html.text "Classes go in a component's attributes with "
            , Html.code [] [ Html.text "Attr.class" ]
            , Html.text ", which adds to its own ds-* class ("
            , Html.code [] [ Html.text "Attr.attribute \"class\"" ]
            , Html.text " would replace it). On Spinner, an "
            , Html.code [] [ Html.text "<svg>" ]
            , Html.text ", use "
            , Html.code [] [ Html.text "Svg.Attributes.class" ]
            , Html.text ". Tailwind finds classes by reading your compiled Elm, so write class names out in full; never build them from strings. See \"Using with Tailwind\" in the package README for what's mapped, custom themes and version pinning."
            ]
        ]


step : String -> Html msg
step title =
    Heading.h4 [ Heading.size Heading.ExtraSmall ] [ Html.text title ]


file : String -> Html msg
file name =
    Paragraph.view [ Paragraph.size Paragraph.Small ] [ Html.code [] [ Html.text name ] ]


{-| The CSS's version: the port's version without its `-N`.
-}
cssVersion : String
cssVersion =
    String.split "-" Ds.version |> List.head |> Maybe.withDefault Ds.version


installCommands : String
installCommands =
    "bun add -E @ensolabs/designsystemet-elm@"
        ++ Ds.version
        ++ " @digdir/designsystemet-css@"
        ++ cssVersion
        ++ """
bun add @fontsource/inter
bun add -d elm
bunx elm init
bunx elm install ensolabs/designsystemet-elm"""


mainElm : String
mainElm =
    """module Main exposing (main)

import Browser
import Designsystemet as Ds
import Designsystemet.Button as Button
import Designsystemet.Color as Color
import Designsystemet.Heading as Heading
import Designsystemet.Paragraph as Paragraph
import Html exposing (Html)
import Html.Events as Events


main : Program () Int Int
main =
    Browser.sandbox { init = 0, update = (+), view = view }


view : Int -> Html Int
view count =
    Html.main_ []
        [ Heading.h1 [] [ Html.text "Hei" ]
        , Paragraph.view [] [ Html.text ("Klikk: " ++ String.fromInt count) ]
        , Button.view [ Events.onClick 1 ] [ Html.text "Pluss" ]
        , Button.view [ Button.secondary, Ds.color Color.danger, Events.onClick (-1) ]
            [ Html.text "Minus" ]
        ]"""


indexHtml : String
indexHtml =
    """<!doctype html>
<html lang="nb" data-color-scheme="auto">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>App</title>
    <link rel="stylesheet" href="./style.css" />
    <script type="module" src="./main.js"></script>
  </head>
  <body>
    <div id="app"></div>
  </body>
</html>"""


mainJs : String
mainJs =
    """import "@fontsource/inter/latin-400.css";
import "@fontsource/inter/latin-500.css";
import "@fontsource/inter/latin-600.css";
import "@ensolabs/designsystemet-elm";
import { Elm } from "./elm-stuff/elm.js";

// Designsystemet's CSS, linked untouched (see vendor.js). Wait for it before
// starting Elm: some web components read their texts from the CSS.
const stylesheet = (href) =>
  new Promise((resolve) => {
    const link = Object.assign(document.createElement("link"), { rel: "stylesheet", href });
    link.onload = link.onerror = resolve;
    document.head.append(link);
  });

await Promise.all([stylesheet("vendor/designsystemet.css"), stylesheet("vendor/theme.css")]);

Elm.Main.init({ node: document.getElementById("app") });"""


styleCss : String
styleCss =
    """body {
  margin: 0;
  font-family: var(--ds-font-family), sans-serif;
}"""


vendorJs : String
vendorJs =
    """// Designsystemet's stylesheets, served and shipped untouched: Bun's CSS
// bundler can't parse them. URL -> file in node_modules.
export const vendor = {
  "/vendor/designsystemet.css": Bun.resolveSync("@digdir/designsystemet-css", import.meta.dir),
  "/vendor/theme.css": Bun.resolveSync("@digdir/designsystemet-css/theme", import.meta.dir),
};"""


devJs : String
devJs =
    """import index from "./index.html";
import { vendor } from "./vendor.js";

const server = Bun.serve({
  port: 3000,
  development: true,
  routes: {
    "/": index,
    ...Object.fromEntries(
      Object.entries(vendor).map(([url, file]) => [url, () => new Response(Bun.file(file))]),
    ),
  },
});
console.log(`dev server: ${server.url}`);"""


buildJs : String
buildJs =
    """import { rm } from "node:fs/promises";
import { vendor } from "./vendor.js";

await rm("./dist", { recursive: true, force: true });

const result = await Bun.build({
  entrypoints: ["./index.html"],
  outdir: "./dist",
  minify: true,
});
if (!result.success) {
  console.error(...result.logs);
  process.exit(1);
}
for (const [url, file] of Object.entries(vendor)) {
  await Bun.write(`./dist${url}`, Bun.file(file));
}"""


packageScripts : String
packageScripts =
    """"scripts": {
  "elm": "elm make src/Main.elm --output=elm-stuff/elm.js",
  "dev": "bun run elm && bun dev.js",
  "build": "elm make src/Main.elm --optimize --output=elm-stuff/elm.js && bun build.js"
}"""


runCommands : String
runCommands =
    """bun run dev      # http://localhost:3000
bun run build    # static site in dist/"""


tailwindInstall : String
tailwindInstall =
    "bun add -d tailwindcss bun-plugin-tailwind"


bunfig : String
bunfig =
    """[serve.static]
plugins = ["bun-plugin-tailwind"]"""


tailwindBuildJs : String
tailwindBuildJs =
    """import { rm } from "node:fs/promises";
import tailwind from "bun-plugin-tailwind";
import { vendor } from "./vendor.js";

await rm("./dist", { recursive: true, force: true });

const result = await Bun.build({
  entrypoints: ["./index.html"],
  outdir: "./dist",
  minify: true,
  plugins: [tailwind],
});
if (!result.success) {
  console.error(...result.logs);
  process.exit(1);
}
for (const [url, file] of Object.entries(vendor)) {
  await Bun.write(`./dist${url}`, Bun.file(file));
}"""


tailwindStyleCss : String
tailwindStyleCss =
    """/* Tailwind's reset, then Designsystemet, then utilities. */
@layer theme, base, ds, components, utilities;
@import "tailwindcss";
/* The theme's tokens as Tailwind's: bg-accent-surface-tinted, p-4, shadow-md … */
@import "@digdir/designsystemet-css/theme/designsystemet.tailwind.css" theme(inline);

/* Tailwind's reset removes list markers; Designsystemet's lists rely on them. */
@layer base {
  .ds-list,
  .ds-list :is(ul, ol) {
    list-style: revert;
  }
}

body {
  margin: 0;
  font-family: var(--ds-font-family), sans-serif;
}"""


tailwindElm : String
tailwindElm =
    """view : Int -> Html Int
view count =
    Html.main_ [ Attr.class "mx-auto max-w-2xl p-6 flex flex-col gap-4" ]
        [ Heading.h1 [] [ Html.text "Hei" ]
        , Paragraph.view [ Attr.class "mt-4" ] [ Html.text ("Klikk: " ++ String.fromInt count) ]
        , Html.div [ Ds.color Color.danger, Attr.class "bg-surface-tinted p-4 rounded-md flex gap-2" ]
            [ Button.view [ Events.onClick 1 ] [ Html.text "Pluss" ]
            , Button.view [ Button.secondary, Events.onClick (-1) ] [ Html.text "Minus" ]
            ]
        ]"""
