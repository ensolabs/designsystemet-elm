// Checks that every story looks the same with Tailwind on the page. Serves the
// built showcase twice, plain and with showcase/tailwind.css (compiled here)
// as the first stylesheet, and compares computed style and size of every ds-*
// element and its ::before/::after/::marker, story by story.
//
//   bun run showcase:build && bun run tailwind [chapter ...]
//
// Preflight's font and letter-spacing inheritance on form controls is
// accepted, so the plain side gets it too. Elements without a ds-* class are
// the story's own HTML and left to Tailwind, as are the stories in `expected`.
// Fails on any other difference, with a .plain.png/.tailwind.png pair per
// story in showcase/tailwind-check/.
// Needs no network. Set PLAYWRIGHT_CHROMIUM_EXECUTABLE to use a specific Chromium.

import path from "node:path";
import { mkdir, rm } from "node:fs/promises";
import { chromium } from "playwright";
import { compile } from "tailwindcss";

const here = import.meta.dir;
const dist = path.join(here, "dist");
const out = path.join(here, "tailwind-check");
const only = process.argv.slice(2);
// Stories whose own plain HTML, which preflight resets, sizes a ds-* element.
const expected = {
  "komponenter-avatarstack--playground": "raw <input>s lose their margins",
  "komponenter-fieldset--legend-as-heading": "a raw <h1> loses its size",
  "komponenter-typography--eksempel-tekst": "a raw <code> gets font-size: 1em",
  "komponenter-typography--eksempel-tekst-dark": "a raw <code> gets font-size: 1em",
  "komponenter-typography--eksempel-tekst-auto-size": "a raw <code> gets font-size: 1em",
};

const load = async (id, base) => {
  const file = id.startsWith(".") ? path.resolve(base, id) : Bun.resolveSync(id === "tailwindcss" ? "tailwindcss/index.css" : id, base);
  return { path: file, base: path.dirname(file), content: await Bun.file(file).text() };
};
const entry = path.join(here, "tailwind.css");
const tailwind = (await compile(await Bun.file(entry).text(), { base: here, loadStylesheet: load })).build([]);
// No motion on either side. The plain side also gets the accepted preflight
// rule, in a layer declared first so ds-css wins over it as over preflight.
const still = "<style>*, ::before, ::after { animation: none !important; transition: none !important }</style>";
const accepted = "<style>@layer accepted { :where(button, input, select, optgroup, textarea) { font: inherit; letter-spacing: inherit } }</style>";
const variants = { plain: accepted + still, tailwind: `<link rel="stylesheet" href="tailwind.css">${still}` };
const server = Bun.serve({
  port: 0,
  async fetch(req) {
    const [, variant, ...rest] = new URL(req.url).pathname.split("/");
    const file = rest.join("/");
    if (!(variant in variants)) return new Response(Bun.file(path.join(dist, variant, file)));
    if (file === "tailwind.css") return new Response(tailwind, { headers: { "content-type": "text/css" } });
    if (file && file !== "index.html") return new Response(Bun.file(path.join(dist, file)));
    const html = await Bun.file(path.join(dist, "index.html")).text();
    return new Response(html.replace("<head>", `<head>${variants[variant]}`), { headers: { "content-type": "text/html" } });
  },
});

// Runs in the page: what each visible ds-* element in a story looks like, with
// lengths rounded to half a pixel. An <hr>'s text colour is never seen.
const PROPS = ["display", "list-style-type", "font-family", "font-size", "font-weight", "line-height", "color", "background-color", "text-decoration-line", "cursor", "content"]
  .concat(...["top", "right", "bottom", "left"].map((s) => [`margin-${s}`, `padding-${s}`, `border-${s}-width`, `border-${s}-color`]));
function looks(root, props) {
  const els = root.querySelectorAll('[class^="ds-"], [class*=" ds-"]');
  const round = (value) => value.replace(/[\d.]+px/g, (px) => `${Math.round(parseFloat(px) * 2) / 2}px`);
  return [...els].flatMap((el, i) => {
    const r = el.getBoundingClientRect();
    if (r.width <= 1 && r.height <= 1) return [];
    const name = `${i}:${el.tagName.toLowerCase()}.${[...el.classList].filter((c) => c.startsWith("ds-")).join(".")}`;
    const size = { name, prop: "size", value: round(`${r.width}px ${r.height}px`) };
    const pseudos = [null, "::before", "::after"].concat(getComputedStyle(el).display === "list-item" ? ["::marker"] : []);
    return [size].concat(...pseudos.map((pseudo) => {
      const cs = getComputedStyle(el, pseudo);
      if (pseudo && pseudo !== "::marker" && cs.content === "none") return [];
      return props.filter((prop) => !(prop === "color" && el.localName === "hr")).map((prop) => {
        const side = /^border-(\w+)-width$/.exec(prop)?.[1];
        const value = side && cs.getPropertyValue(`border-${side}-style`) === "none" ? "0px" : cs.getPropertyValue(prop);
        return { name: name + (pseudo ?? ""), prop, value: round(value) };
      });
    }));
  });
}

const browser = await chromium.launch({ executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE || undefined });
const page = await browser.newPage({ viewport: { width: 1280, height: 900 }, reducedMotion: "reduce" });
await page.route(/fonts\.(googleapis|gstatic)\.com/, (route) => route.abort());
const visit = async (variant, chapter) => {
  await page.goto(`${server.url.href}${variant}/#/${chapter}`);
  await page.waitForSelector("[data-storybook-id]");
  await page.waitForTimeout(200);
};

await page.goto(`${server.url.href}plain/`);
await page.waitForSelector(".showcase__nav a");
const chapters = (await page.locator(".showcase__nav a").evaluateAll((as) => as.map((a) => a.getAttribute("href").slice(2))))
  .filter((c) => !only.length || only.includes(c));
await rm(out, { recursive: true, force: true });

let stories = 0;
let skipped = 0;
const failures = [];
for (const chapter of chapters) {
  const seen = {};
  for (const variant of Object.keys(variants)) {
    await visit(variant, chapter);
    seen[variant] = await page.locator("[data-storybook-id]").evaluateAll(
      (sections, [fn, props]) => Object.fromEntries(sections.map((s) => [s.dataset.storybookId, new Function(`return ${fn}`)()(s.querySelector(".story__root"), props)])),
      [looks.toString(), PROPS],
    );
  }
  for (const [id, plain] of Object.entries(seen.plain)) {
    stories++;
    if (id in expected) {
      skipped++;
      continue;
    }
    const withTailwind = seen.tailwind[id] ?? [];
    const diffs = plain.flatMap((p, i) =>
      withTailwind[i]?.name === p.name && withTailwind[i].value === p.value ? [] : [`${p.name} ${p.prop}: ${p.value} -> ${withTailwind[i]?.value}`],
    );
    if (!diffs.length && plain.length === withTailwind.length) continue;
    failures.push(id);
    console.log(`  ✗ ${id}\n${diffs.slice(0, 5).map((d) => `      ${d}`).join("\n")}`);
    await mkdir(out, { recursive: true });
    for (const variant of Object.keys(variants)) {
      await visit(variant, chapter);
      await page.locator(`[data-storybook-id="${id}"] .story__root`).screenshot({ path: path.join(out, `${id}.${variant}.png`) });
    }
  }
}

await browser.close();
server.stop();
console.log(`\n${stories - failures.length - skipped} of ${stories} stories look the same with Tailwind (${skipped} expected to differ).`);
if (failures.length) {
  console.log(`Screenshots of the ${failures.length} that don't: ${path.relative(process.cwd(), out)}/`);
  process.exit(1);
}
