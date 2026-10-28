// VERSION is the @digdir/designsystemet-react version this port mirrors,
// plus "-N" for fixes to this package that leave -css and -web unchanged
// (1.23.0-1). The npm package uses it too. elm.json has its own semver, since
// the Elm registry rejects "-N"; each CHANGELOG section names it.
//
// Checks every place that states a version against VERSION.

import { readFileSync } from "node:fs";
import path from "node:path";

const dir = path.join(import.meta.dir, "..");
const read = (file) => readFileSync(path.join(dir, file), "utf8");
const problems = [];
const expect = (ok, message) => ok || problems.push(message);

const port = read("VERSION").trim();
if (!/^\d+\.\d+\.\d+(-[1-9]\d*)?$/.test(port)) {
  console.error(`VERSION is "${port}"; expected MAJOR.MINOR.PATCH or MAJOR.MINOR.PATCH-N`);
  process.exit(1);
}
const upstream = port.split("-")[0];
const elmVersion = JSON.parse(read("elm.json")).version;
const npm = JSON.parse(read("package.json"));

expect(npm.version === port, `package.json version is ${npm.version}, expected ${port}`);
for (const [field, name] of [
  ["dependencies", "@digdir/designsystemet-web"],
  ["peerDependencies", "@digdir/designsystemet-css"],
  ["devDependencies", "@digdir/designsystemet-css"],
]) {
  const pin = npm[field]?.[name];
  expect(pin === upstream, `package.json ${field}["${name}"] is ${pin}, expected exactly ${upstream}`);
}

const elm = read("src/Designsystemet.elm");
const value = elm.match(/^version =\n {4}"([^"]*)"$/m)?.[1];
expect(value === port, `Designsystemet.version is ${value}, expected ${port}`);
const documented = elm.match(/^\{-\| The version of this port, `"([^"]*)"`\.$/m)?.[1];
expect(documented === port, `Designsystemet.version's doc says ${documented}, expected ${port}`);

const changelog = read("CHANGELOG.md");
const [, heading, section] = changelog.match(/^## (.*)\n([\s\S]*?)(?=^## |(?![\s\S]))/m) ?? [];
expect(
  heading === port || heading?.startsWith(`${port} (`),
  `CHANGELOG.md's newest section is "${heading}", expected ${port}`,
);
expect(
  section?.includes(`Elm package \`${elmVersion}\``),
  `CHANGELOG.md's newest section doesn't name Elm package \`${elmVersion}\` (elm.json)`,
);

const readme = read("README.md");
for (const [pattern, wanted] of [
  [/@ensolabs\/designsystemet-elm@([^\s`)]+)/g, port],
  [/@digdir\/designsystemet-(?:react|css|web)@([^\s`)]+)/g, upstream],
  [/designsystemet-react\/v\/([^\s`)]+)/g, upstream],
]) {
  for (const [match, found] of readme.matchAll(pattern)) {
    expect(found === wanted, `README.md says ${match}, expected ${wanted}`);
  }
}

if (problems.length) {
  console.error(problems.join("\n"));
  process.exit(1);
}
console.log(`Port ${port} (Elm package ${elmVersion}) mirrors designsystemet ${upstream} everywhere`);
