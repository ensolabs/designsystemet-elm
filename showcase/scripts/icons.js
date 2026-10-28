// Generates src/Icons.elm from @navikt/aksel-icons, the icon set the upstream
// stories use. Add a name to ICONS and run `bun showcase/scripts/icons.js`.

import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const ICONS = [
  "AlignCenter", "AlignLeft", "AlignRight", "Archive", "Backpack", "Bell",
  "Bicycle", "Book", "Briefcase", "Car", "Chat", "ChevronDown",
  "ChevronDownUp", "ChevronUpDown", "ChevronUp", "CircleSlash", "Component",
  "DocPencil", "EnvelopeClosedFill", "EnvelopeClosed", "ExternalLink", "Files",
  "Floppydisk", "HeartFill", "Heart", "Inbox", "Link", "Motorcycle",
  "Newspaper", "Paperplane", "Paragraph", "Pencil", "PencilWriting", "Robot",
  "Trash", "VideoFill", "Video", "MagnifyingGlass", "Plus", "XMark", "Person",
  "Cog", "Sun", "Moon",
];

const svgDir = path.join(import.meta.dir, "../../node_modules/@navikt/aksel-icons/dist/svg");
const lowerFirst = (s) => s.charAt(0).toLowerCase() + s.slice(1);

const attr = (name) => name.replace(/-([a-z])/g, (_, c) => c.toUpperCase());

const decls = [];
for (const name of ICONS) {
  const svg = await readFile(path.join(svgDir, `${name}.svg`), "utf8");
  const paths = [...svg.matchAll(/<path ([^>]*?)\/>/g)].map(([, attrs]) => {
    const list = [...attrs.matchAll(/([a-z-]+)="([^"]*)"/g)]
      .map(([, k, v]) => `SvgAttr.${attr(k)} "${v}"`);
    return `Svg.path [ ${list.join(", ")} ] []`;
  });
  decls.push(`{-| \`${name}Icon\` from @navikt/aksel-icons.
-}
${lowerFirst(name)} : List (Html.Attribute msg) -> Html msg
${lowerFirst(name)} attributes =
    icon attributes
        [ ${paths.join("\n        , ")}
        ]
`);
}

const elm = `module Icons exposing (${ICONS.map(lowerFirst).join(", ")})

{-| The icons the upstream stories use, from @navikt/aksel-icons. Each takes
attributes like the React components do: \`Icons.pencil [ Attr.style "font-size" "1.5rem" ]\`.

Showcase only: the package itself ships no icons, so apps bring their own.

The icon paths are from @navikt/aksel-icons, MIT License, Copyright 2025 Nav
(Arbeids- og velferdsdirektoratet).

-}

import Html exposing (Html)
import Html.Attributes as Attr
import Svg
import Svg.Attributes as SvgAttr


{-| Like the React icons: decorative (\`aria-hidden\`) unless you give it a
\`title\` or other attributes of your own, which come last and win.
-}
icon : List (Html.Attribute msg) -> List (Svg.Svg msg) -> Html msg
icon attributes =
    Svg.svg
        ([ SvgAttr.width "1em"
         , SvgAttr.height "1em"
         , SvgAttr.viewBox "0 0 24 24"
         , SvgAttr.fill "none"
         , Attr.attribute "aria-hidden" "true"
         , Attr.attribute "focusable" "false"
         ]
            ++ attributes
        )


${decls.join("\n\n")}`;

await writeFile(path.join(import.meta.dir, "../src/Icons.elm"), elm);
console.log(`wrote ${ICONS.length} icons to showcase/src/Icons.elm`);
