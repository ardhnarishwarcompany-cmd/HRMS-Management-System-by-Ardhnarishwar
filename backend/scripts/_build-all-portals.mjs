/**
 * Builds every React portal with its .env.production and reports results to
 * _build_report.txt. Run from backend/:  node scripts/_build-all-portals.mjs
 */
import { execSync } from "child_process";
import fs from "fs";
import path from "path";

const ROOT = path.resolve(process.cwd(), "..");
const portals = [
  ["admin", "admin"],
  ["client", "client"],
  ["employee", "employee"],
  ["HR", "HR"],
  ["IT", "IT"],
  ["Sales", "Sales"],
  ["evs-frontend", path.join("employee-verification-system", "frontend", "frontend")],
];
/* optional: node scripts/_build-all-portals.mjs evs-frontend  -> build only that one */
const only = process.argv.slice(2);
const selected = only.length ? portals.filter(([l]) => only.includes(l)) : portals;
const lines = [];
const log = (s) => { lines.push(s); console.log(s); };

const dirSize = (d) => {
  let n = 0, files = 0;
  const walk = (p) => { for (const e of fs.readdirSync(p, { withFileTypes: true })) { const f = path.join(p, e.name); if (e.isDirectory()) walk(f); else { n += fs.statSync(f).size; files++; } } };
  if (fs.existsSync(d)) walk(d);
  return { mb: (n / 1048576).toFixed(2), files };
};

let failed = 0;
for (const [label, rel] of selected) {
  const dir = path.join(ROOT, rel);
  if (!fs.existsSync(path.join(dir, "package.json"))) { log(`${label}: SKIP (no package.json at ${dir})`); failed++; continue; }
  const env = path.join(dir, ".env.production");
  log(`\n=== ${label}  (${rel})  env.production=${fs.existsSync(env) ? "yes" : "MISSING"}`);
  const t = Date.now();
  try {
    if (!fs.existsSync(path.join(dir, "node_modules"))) {
      log("  npm install ...");
      execSync("npm install --no-audit --no-fund", { cwd: dir, stdio: "pipe", timeout: 600000 });
    }
    const out = execSync("npx vite build --mode production", { cwd: dir, stdio: "pipe", timeout: 600000, env: { ...process.env, CI: "1" } }).toString();
    const warn = out.split(/\r?\n/).filter((l) => /warn|error/i.test(l) && !/chunk size|chunks are larger/i.test(l));
    const dist = path.join(dir, "dist");
    const { mb, files } = dirSize(dist);
    const idx = path.join(dist, "index.html");
    log(`  BUILD OK  ${((Date.now() - t) / 1000).toFixed(0)}s  dist=${files} files ${mb} MB  index.html=${fs.existsSync(idx) ? "yes" : "MISSING"}`);
    if (warn.length) log("  notes: " + warn.slice(0, 5).join(" | "));
    // sanity: production API domain baked in, no localhost
    const js = fs.readdirSync(path.join(dist, "assets")).filter((f) => f.endsWith(".js")).map((f) => fs.readFileSync(path.join(dist, "assets", f), "utf8")).join("");
    const local = (js.match(/http:\/\/localhost:\d+/g) || []).length;
    const prod = (js.match(/recruweb\.com/g) || []).length;
    log(`  baked URLs: recruweb.com=${prod}  localhost=${local}${local ? "  <-- CHECK" : ""}`);
  } catch (e) {
    failed++;
    log("  BUILD FAILED");
    log((e.stdout?.toString() || "") + (e.stderr?.toString() || e.message));
  }
}
log(`\nSUMMARY: ${portals.length - failed}/${portals.length} portals built${failed ? `, ${failed} FAILED` : ""}`);
fs.writeFileSync(path.join(process.cwd(), "_build_report.txt"), lines.join("\n"));
process.exit(failed ? 1 : 0);
