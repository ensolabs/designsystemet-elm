// Smoke test: the built showcase in a real browser with the real
// designsystemet-web, where Elm's virtual DOM and the web components share
// elements. Covers what unit tests can't:
//
//   - every chapter renders, every story has content, and there are no errors
//   - native behaviour driven by markup alone (invokers, popovers, tabs)
//   - Elm-controlled state round-tripping through the web layer
//
//   bun run showcase:build && bun run smoke
//
// Needs no network. Set PLAYWRIGHT_CHROMIUM_EXECUTABLE to use a specific Chromium.

import path from "node:path";
import { chromium } from "playwright";

const dist = path.join(import.meta.dir, "dist");
const server = Bun.serve({
  port: 0,
  fetch(req) {
    const p = new URL(req.url).pathname;
    return new Response(Bun.file(path.join(dist, p === "/" ? "index.html" : p)));
  },
});

const browser = await chromium.launch({ executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE || undefined });
const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
const pageErrors = [];
page.on("pageerror", (e) => pageErrors.push(String(e)));

const failures = [];
let passed = 0;
async function check(name, fn) {
  try {
    await fn();
    passed++;
    console.log(`  ✓ ${name}`);
  } catch (e) {
    failures.push(name);
    console.log(`  ✗ ${name}\n    ${String(e.message ?? e).split("\n")[0]}`);
  }
}
function expect(actual, expected, what) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(`${what}: expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
  }
}

const visit = async (chapter) => {
  await page.goto(`${server.url.href}#/${chapter}`);
  await page.waitForSelector("[data-storybook-id]");
  await page.waitForTimeout(200);
};
const story = (id) => page.locator(`[data-storybook-id="${id}"] .story__root`);
const openDialogs = () => page.evaluate(() => [...document.querySelectorAll("dialog[open]")].map((d) => d.id));

console.log("Every chapter");
await page.goto(server.url.href);
await page.waitForSelector(".showcase__nav a");
const chapters = await page.locator(".showcase__nav a").evaluateAll((as) => as.map((a) => a.getAttribute("href").slice(2)));
await check(`${chapters.length} chapters render, and no story is empty`, async () => {
  const empty = [];
  for (const chapter of chapters) {
    await visit(chapter);
    empty.push(
      ...(await page.locator("[data-storybook-id]").evaluateAll((sections) =>
        sections.filter((s) => !s.querySelector(".story__root")?.children.length).map((s) => s.dataset.storybookId),
      )),
    );
  }
  expect(empty, [], "empty stories");
});

console.log("Dialog");
await visit("dialog");
await check("an invoker button opens a modal dialog, with no Elm state", async () => {
  await story("komponenter-dialog--preview").getByRole("button", { name: "Open Dialog" }).click();
  expect(await openDialogs(), ["dialog-preview"], "open dialogs");
});
await check("Escape closes it", async () => {
  await page.keyboard.press("Escape");
  await page.waitForTimeout(100);
  expect(await openDialogs(), [], "open dialogs");
});
await check("open state: Dialog.open opens the dialog from the model", async () => {
  await story("komponenter-dialog--dialog-with-open-prop").getByRole("button", { name: "Open Dialog with prop" }).click();
  await page.waitForTimeout(150);
  expect(await openDialogs(), ["dialog-with-open-prop"], "open dialogs");
});
await check("open state: Escape closes it, and onClose brings the model along", async () => {
  await page.keyboard.press("Escape");
  await page.waitForTimeout(150);
  expect(await openDialogs(), [], "open dialogs");
  expect(
    await page.locator("#dialog-with-open-prop").getAttribute("data-open"),
    "false",
    "data-open after Escape",
  );
  // The model says closed, so one click (not two) opens it again.
  await story("komponenter-dialog--dialog-with-open-prop").getByRole("button", { name: "Open Dialog with prop" }).click();
  await page.waitForTimeout(150);
  expect(await openDialogs(), ["dialog-with-open-prop"], "open dialogs after reopening");
  await page.keyboard.press("Escape");
  await page.waitForTimeout(100);
});

console.log("Popover");
await visit("popover");
const popoverOpen = (id) => page.evaluate((id) => document.getElementById(id).matches(":popover-open"), id);
await check("popovertarget opens a popover, with no Elm state", async () => {
  await story("komponenter-popover--preview").getByRole("button").first().click();
  await page.waitForTimeout(100);
  expect(await popoverOpen("popover-preview"), true, "open");
  await page.keyboard.press("Escape");
});
await check("open state: Popover.open follows the model, in both directions", async () => {
  const root = story("komponenter-popover--controlled");
  await root.getByRole("button", { name: "Slett" }).first().click();
  await page.waitForTimeout(150);
  expect(await popoverOpen("popover-controlled"), true, "open after the trigger");
  expect(await page.locator("#popover-controlled").getAttribute("data-open"), "true", "data-open after the trigger");
  // "Avbryt" only sets the model to closed; the companion script closes it.
  await page.locator("#popover-controlled").getByRole("button", { name: "Avbryt" }).click();
  await page.waitForTimeout(150);
  expect(await popoverOpen("popover-controlled"), false, "open after Avbryt");
});
await check("open state: Popover.open True opens popovers on mount", async () => {
  const open = await page.evaluate(() => document.querySelectorAll("[id^=popover-variant-]:popover-open").length);
  expect(open, 8, "open variant popovers");
});

console.log("Tabs");
await visit("tabs");
const selected = (id) => story(id).locator("[role=tab]").evaluateAll((tabs) => tabs.map((t) => t.getAttribute("aria-selected")));
await check("uncontrolled tabs: the web layer switches tabs", async () => {
  await story("komponenter-tabs--preview").locator("[role=tab]").nth(1).click();
  expect(await selected("komponenter-tabs--preview"), ["false", "true", "false"], "aria-selected");
});
await check("controlled tabs: a click goes through update and back", async () => {
  await story("komponenter-tabs--controlled").locator("[role=tab]").nth(2).click();
  await page.waitForTimeout(100);
  expect((await selected("komponenter-tabs--controlled"))[2], "true", "aria-selected of the clicked tab");
});

await check("controlled tabs: when update says no, the web layer doesn't switch either", async () => {
  const id = "komponenter-tabs--controlled-stop";
  await story(id).locator("[role=tab]").nth(1).click();
  await page.waitForTimeout(100);
  expect(await selected(id), ["true", "false"], "aria-selected");
  const hidden = await story(id).locator("[role=tabpanel]").evaluateAll((ps) => ps.map((p) => p.hidden));
  expect(hidden, [false, true], "hidden panels");
});

console.log("ToggleGroup");
await visit("togglegroup");
await check("controlled toggle group: Elm owns the checked radio", async () => {
  const group = story("komponenter-togglegroup--kontrollert");
  await group.locator("label").nth(1).click();
  await page.waitForTimeout(100);
  const checked = await group.locator("input[type=radio]").evaluateAll((rs) => rs.map((r) => r.checked));
  expect(checked.indexOf(true), 1, "checked index");
});

console.log("Details");
await visit("details");
await check("controlled details: the summary click goes through update", async () => {
  const details = story("komponenter-details--controlled").locator("details").first();
  const before = await details.evaluate((d) => d.open);
  await details.locator("summary").click();
  await page.waitForTimeout(100);
  expect(await details.evaluate((d) => d.open), !before, "open");
});

console.log("Textfield");
await visit("textfield");
await check("controlled textfield: typing round-trips through the model", async () => {
  const root = story("komponenter-textfield--controlled");
  await root.locator("input").first().fill("Hei Elm");
  await page.waitForTimeout(100);
  if (!(await root.innerText()).includes("Hei Elm")) throw new Error("the typed value is not rendered back");
});

console.log("Suggestion");
await visit("suggestion");
// u-datalist filters by visibility, not with the hidden attribute.
const shownOptions = (root) =>
  root.locator("u-option").evaluateAll((os) => os.filter((o) => o.checkVisibility()).map((o) => o.getAttribute("value")));
await check("typing filters the options (u-datalist on Elm's markup)", async () => {
  const root = story("komponenter-suggestion--preview");
  await root.locator("input").first().focus();
  await page.keyboard.type("Sog");
  await page.waitForTimeout(300);
  expect(await shownOptions(root), ["Sogndal"], "visible options");
  await page.keyboard.press("Escape");
});
await check("controlled suggestion: choosing an option goes through update", async () => {
  const root = story("komponenter-suggestion--controlled-single");
  await root.locator("input").first().focus();
  await page.keyboard.type("Oslo");
  await page.waitForTimeout(300);
  await root.locator("u-option[value=Oslo]").click();
  await page.waitForTimeout(200);
  if (!(await root.innerText()).includes("Valgte reisemål: Oslo")) throw new Error("the model did not get the selection");
});
await check("controlled suggestion: update can set the value from outside", async () => {
  const root = story("komponenter-suggestion--controlled-single");
  await root.getByRole("button", { name: "Sett reisemål til Sogndal" }).click();
  await page.waitForTimeout(200);
  if (!(await root.innerText()).includes("Valgte reisemål: Sogndal")) throw new Error("the model did not change");
  expect(await root.locator("input").first().inputValue(), "Sogndal", "input value");
});

console.log("Pagination");
await visit("pagination");
await check("pagination: choosing a page moves aria-current", async () => {
  const root = story("komponenter-pagination--preview");
  const current = () => root.locator("[aria-current=true]").innerText();
  const before = await current();
  await root.getByRole("button", { name: /neste/i }).click();
  await page.waitForTimeout(100);
  expect(Number(await current()), Number(before) + 1, "current page");
});

await check("no page errors anywhere", async () => expect(pageErrors, [], "page errors"));

await browser.close();
server.stop();
console.log(`\n${passed} passed, ${failures.length} failed`);
if (failures.length) process.exit(1);
