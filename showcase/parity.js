// Parity check: every Elm story against its React twin on the live upstream
// Storybook (storybook.designsystemet.no), in two ways:
//
//   - markup: the rendered DOM of both, normalized (sorted classes and
//     attributes, generated ids replaced, icons collapsed) and diffed
//   - pixels: a screenshot of each, side by side, for a human to look at
//
//   bun run showcase:build && bun run parity            # every story
//   bun run parity button tabs                          # some chapters
//
// Writes to showcase/parity/ (gitignored): report.md, and per story
// <id>.elm.png, <id>.react.png and, if the markup differs, <id>.diff.
//
// The live Storybook shows upstream's latest release. If that is newer than
// VERSION, differences may be upstream changes. Run this during an upgrade
// (see UPGRADING.md), when both sides should agree.
//
// Set PLAYWRIGHT_CHROMIUM_EXECUTABLE to use a specific Chromium.

import { mkdir, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import { chromium } from "playwright";

const here = import.meta.dir;
const dist = path.join(here, "dist");
const out = path.join(here, "parity");
const only = process.argv.slice(2);
const storybook = "https://storybook.designsystemet.no";

// Attributes whose values are generated ids: only their presence matters.
const ID_ATTRIBUTES = [
  "id", "for", "aria-labelledby", "aria-describedby", "aria-controls",
  "commandfor", "popovertarget", "list", "name", "data-clickdelegatefor",
];

// Runs in the browser: the element's children as canonical, indented lines.
// Called with the Elm story root (.story__root) and Storybook's #storybook-root.
function canonical(element, idAttributes) {
  // Storybook wraps every story in a decorator element, and some stories add
  // layout-only <div>s (only a `style` attribute). The showcase puts that
  // layout on the story root (customStyles), so unwrap single wrappers like
  // these on both sides.
  const layoutOnly = (el) => el.tagName === "DIV" && [...el.attributes].every((a) => a.name === "style");
  let root = element.querySelector(":scope > [data-storybook-decorator]") ?? element;
  while (root.children.length === 1 && layoutOnly(root.firstElementChild)) {
    root = root.firstElementChild;
  }
  // designsystemet-web defaults, which the Elm port leaves out.
  const isDefault = (el, name, value) =>
    (name === "data-autoplacement" && value === "true") ||
    (name === "data-placement" && value === "top" && el.hasAttribute("data-tooltip"));
  // Identity tokens: compared like ids, by presence.
  const isToken = (el, name) => name === "data-value" && (el.tagName === "DS-TAB" || el.tagName === "DS-TABPANEL");
  const lines = [];
  const walk = (node, depth) => {
    const pad = "  ".repeat(depth);
    if (node.nodeType === Node.TEXT_NODE) {
      // Adjacent text nodes ("Du har valgt: " + value) read as one text.
      if (node.previousSibling?.nodeType === Node.TEXT_NODE) return;
      let text = "";
      for (let n = node; n?.nodeType === Node.TEXT_NODE; n = n.nextSibling) text += n.textContent;
      text = text.replace(/\s+/g, " ").trim();
      if (text) lines.push(pad + JSON.stringify(text));
      return;
    }
    if (node.nodeType !== Node.ELEMENT_NODE) return;
    const tag = node.tagName.toLowerCase();
    const cls = node.getAttribute("class") ?? "";
    // Icons are the app's business (React uses aksel-icons components, the
    // showcase an Elm port of the same SVGs); compare that one is there.
    if (tag === "svg" && !cls.includes("ds-")) {
      lines.push(pad + "<svg icon>");
      return;
    }
    // Elm sets checked/value/selected as DOM properties, React as attributes,
    // so compare the live properties.
    const isFormControl = tag === "input" || tag === "textarea" || tag === "select" || tag === "option";
    const stateAttributes = isFormControl ? ["checked", "value", "selected"] : [];
    const attrs = [...node.attributes]
      .filter((a) => a.name !== "class" && a.name !== "style" && !stateAttributes.includes(a.name))
      .filter((a) => !isDefault(node, a.name, a.value))
      .map((a) => {
        if (idAttributes.includes(a.name) || isToken(node, a.name)) return `${a.name}=<id>`;
        // The stories' images are data URIs upstream and files here.
        if (tag === "img" && a.name === "src") return "src=<image>";
        // Upstream appends a random "?=123" to its example links.
        if (a.name === "href") return `href=${JSON.stringify(a.value.replace(/[?&]=\d+$/, ""))}`;
        return `${a.name}=${JSON.stringify(a.value)}`;
      })
      .sort();
    if (tag === "input" && (node.type === "checkbox" || node.type === "radio")) {
      if (node.checked) attrs.push(":checked");
      if (node.getAttribute("value") !== null || node.value !== "on") attrs.push(`:value=${JSON.stringify(node.value)}`);
    } else if (tag === "input" || tag === "textarea" || tag === "select") {
      if (node.value) attrs.push(`:value=${JSON.stringify(node.value)}`);
    } else if (tag === "option" && node.selected) {
      attrs.push(":selected");
    }
    if (tag === "option") attrs.push(`:value=${JSON.stringify(node.value)}`);
    attrs.sort();
    const classes = cls.split(/\s+/).filter(Boolean).sort();
    if (classes.length) attrs.unshift(`class=${JSON.stringify(classes.join(" "))}`);
    lines.push(`${pad}<${tag}${attrs.length ? " " + attrs.join(" ") : ""}>`);
    for (const child of node.childNodes) walk(child, depth + 1);
  };
  for (const child of root.childNodes) walk(child, 0);
  return lines.join("\n");
}

async function diff(a, b) {
  const tmp = path.join(out, ".tmp");
  await mkdir(tmp, { recursive: true });
  await writeFile(path.join(tmp, "elm"), a + "\n");
  await writeFile(path.join(tmp, "react"), b + "\n");
  const proc = Bun.spawn(["diff", "-u", "--label", "react", "--label", "elm", path.join(tmp, "react"), path.join(tmp, "elm")]);
  return (await new Response(proc.stdout).text()).trim();
}

const server = Bun.serve({
  port: 0,
  fetch(req) {
    const p = new URL(req.url).pathname;
    return new Response(Bun.file(path.join(dist, p === "/" ? "index.html" : p)));
  },
});

await rm(out, { recursive: true, force: true });
await mkdir(out, { recursive: true });

const browser = await chromium.launch({ executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE || undefined });
const page = await browser.newPage({ viewport: { width: 1100, height: 800 } });
const pageErrors = [];
page.on("pageerror", (e) => pageErrors.push(String(e)));

await page.goto(server.url.href);
await page.waitForSelector(".showcase__nav a");
const chapters = (await page.locator(".showcase__nav a").evaluateAll((as) => as.map((a) => a.getAttribute("href"))))
  .filter((href) => !only.length || only.includes(href.replace("#/", "")));

// Coverage: every upstream component story should have an Elm twin, unless
// skipped-stories.json says why not.
const skipped = await Bun.file(path.join(here, "skipped-stories.json")).json();
let upstream = [];
try {
  const index = await (await fetch(`${storybook}/index.json`)).json();
  upstream = Object.values(index.entries)
    .filter((e) => e.type === "story" && e.title.startsWith("Komponenter/"))
    .map((e) => e.id);
} catch (e) {
  console.warn(`Could not read ${storybook}/index.json: ${e}`);
}
const ported = new Set();

const results = [];
for (const href of chapters) {
  await page.goto(server.url.href + href);
  await page.waitForTimeout(300);
  const ids = await page.locator("[data-storybook-id]").evaluateAll((els) => els.map((e) => e.dataset.storybookId));
  ids.forEach((id) => ported.add(id));
  const elm = {};
  for (const id of ids) {
    const canvas = page.locator(`[data-storybook-id="${id}"] .story__root`);
    elm[id] = await canvas.evaluate(canonical, ID_ATTRIBUTES);
    await canvas.screenshot({ path: path.join(out, `${id}.elm.png`) });
  }
  for (const id of ids) {
    const response = await page.goto(`${storybook}/iframe.html?id=${id}&viewMode=story`);
    const root = page.locator("#storybook-root");
    try {
      await root.locator(":scope > *").first().waitFor({ timeout: 10000 });
    } catch {
      results.push({ id, status: response?.ok() ? "no React story" : "Storybook unreachable" });
      continue;
    }
    await page.waitForTimeout(500);
    const react = await root.evaluate(canonical, ID_ATTRIBUTES);
    await root.screenshot({ path: path.join(out, `${id}.react.png`) });
    const d = await diff(elm[id], react);
    if (d) await writeFile(path.join(out, `${id}.diff`), d + "\n");
    results.push({ id, status: d ? "markup differs" : "identical" });
  }
  console.log(`${href.replace("#/", "")}: ${ids.length} stories`);
}

await browser.close();
server.stop();
await rm(path.join(out, ".tmp"), { recursive: true, force: true });

const count = (status) => results.filter((r) => r.status === status).length;
const missing = only.length ? [] : upstream.filter((id) => !ported.has(id) && !(id in skipped));
const report = [
  "# Parity report",
  "",
  `${results.length} stories: ${count("identical")} identical markup, ${count("markup differs")} differ, ` +
    `${count("no React story")} without a React twin.`,
  "",
  only.length
    ? "Coverage not checked: only some chapters were run."
    : missing.length
      ? `**${missing.length} upstream stories have no Elm twin:**\n\n${missing.map((id) => `- ${id}`).join("\n")}\n\nPort them, or add them to showcase/skipped-stories.json with a reason.`
      : `Coverage: all ${upstream.length} upstream component stories are ported or deliberately skipped (${Object.keys(skipped).length - 1}, see showcase/skipped-stories.json).`,
  "",
  "Look at every `.elm.png` next to its `.react.png`, and read every `.diff`.",
  "A difference is either a bug, or a deviation the module documents.",
  "",
  "| Story | Markup |",
  "| --- | --- |",
  ...results.map((r) => `| ${r.id} | ${r.status} |`),
  "",
  pageErrors.length ? `Page errors:\n\n${pageErrors.map((e) => `- ${e}`).join("\n")}` : "No page errors.",
].join("\n");
await writeFile(path.join(out, "report.md"), report + "\n");
console.log(`\n${results.length} stories: ${count("identical")} identical, ${count("markup differs")} differ. ${missing.length ? missing.length + " upstream stories missing! " : ""}See showcase/parity/report.md`);
if (missing.length) process.exitCode = 1;
