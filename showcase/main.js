// What an app using the Elm package needs: the CSS, a theme and the web layer.
//
// The stylesheets are linked, not bundled: Bun's CSS parser can't handle
// designsystemet-css (sibling-index()). build.js copies them to vendor/.
//
// They must load before Elm renders: some web components (like
// <ds-suggestion>) read their texts from CSS when they connect. Static CSS
// imports in a bundler give this order.
const stylesheets = ["vendor/designsystemet.css", "vendor/theme.css", "showcase.css"].map(
  (href) =>
    new Promise((resolve) => {
      const link = document.createElement("link");
      link.rel = "stylesheet";
      link.href = href;
      link.onload = link.onerror = resolve;
      document.head.append(link);
    }),
);

import "../js/index.js";
import { Elm } from "./elm-stuff/showcase.js";

await Promise.all(stylesheets);

Elm.Main.init({ node: document.getElementById("app") });
