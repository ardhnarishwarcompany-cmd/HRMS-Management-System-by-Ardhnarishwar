/**
 * Assembles the complete Hostinger production package.
 *   node scripts/_package-full.mjs      (run from backend/)
 * Output: D:\HRMS_new\HRMS-FULL-PRODUCTION-<date>\  + .zip
 */
import fs from "fs";
import path from "path";
import { execSync } from "child_process";

const SRC = path.resolve(process.cwd(), "..");                 // HRMS Merging
const DATE = new Date().toISOString().slice(0, 10);
const OUT_ROOT = "D:\\HRMS_new";
const NAME = `HRMS-FULL-PRODUCTION-${DATE}`;
const OUT = path.join(OUT_ROOT, NAME);
const lines = [];
const log = (s) => { lines.push(s); console.log(s); };

fs.rmSync(OUT, { recursive: true, force: true });
fs.mkdirSync(OUT, { recursive: true });

const SKIP_BACKEND = new Set(["node_modules", ".env", "uploads", ".git", "dist", "_boot_report.txt", "_build_report.txt", "_robo_refs.txt", "_redeploy_report.txt", "smoke-results.json"]);
// scratch/probe files never ship: _*.txt, _*.json, _*.mjs (packager + probes live in scripts/ as _*.mjs), local *.log files
const skipFile = (name) => /^_.*\.(txt|json|mjs)$/.test(name) || /\.log$/i.test(name);
function copyDir(src, dst, filter = () => true, depth = 0) {
  fs.mkdirSync(dst, { recursive: true });
  for (const e of fs.readdirSync(src, { withFileTypes: true })) {
    if (!filter(e.name, depth, src)) continue;
    const s = path.join(src, e.name), d = path.join(dst, e.name);
    e.isDirectory() ? copyDir(s, d, filter, depth + 1) : fs.copyFileSync(s, d);
  }
}

/* 0. backend */
const BE = path.join(OUT, "0-hrms-backend");
copyDir(path.join(SRC, "backend"), BE, (name, depth) => !(depth === 0 && SKIP_BACKEND.has(name)) && !skipFile(name));
// keep upload folder skeleton (empty) so pm2 boot never fails on missing dirs
for (const d of ["uploads", "uploads/evs", "uploads/hr-robo/video", "uploads/hr-robo/snapshots"]) fs.mkdirSync(path.join(BE, d), { recursive: true });
fs.writeFileSync(path.join(BE, "uploads", ".gitkeep"), "");
// integrity: every module a portal depends on must be present
const MUST = [
  "server.js", "app.js", "package.json", "package-lock.json", ".env.production", "README-DEPLOY.md",
  "modules/attendance/attendance.controller.js", "modules/attendance/ui/admin.html", "modules/attendance/ui/vendor/face-api.min.js",
  "modules/hrRobo/hrRobo.controller.js", "modules/hrRobo/ui/index.html",
  "modules/evs/evs.routes.js", "modules/superAdmin/clients/superAdminClients.controller.js",
  "modules/client/employees/clientEmployees.service.js", "modules/it/it.controller.js", "modules/itdev/itdev.routes.js",
  "modules/common/deliverables", "modules/sales", "modules/employee", "modules/hr",
  "modules/sales/proposals/salesProposals.routes.js", "modules/sales/proposals/salesProposals.controller.js",
  "modules/proposals/proposals.controller.js", "modules/proposals/proposalsClient.routes.js",
  "modules/superAdmin/offerLetter/offerLetter.routes.js", "modules/complaint/complaint.service.js",
  "scripts/run-evs-schema.mjs", "scripts/run-hrrobo-migrate.mjs", "scripts/run-attendance-migrate.mjs", "scripts/run-it-portal-migrate.mjs", "scripts/boot-check.mjs",
];
const missing = MUST.filter((m) => !fs.existsSync(path.join(BE, m)));
if (missing.length) { log(`0-hrms-backend: MISSING ${missing.join(", ")}`); process.exitCode = 1; }
const countFiles = (d) => { let n = 0; for (const e of fs.readdirSync(d, { withFileTypes: true })) n += e.isDirectory() ? countFiles(path.join(d, e.name)) : 1; return n; };
log(`0-hrms-backend: ${countFiles(BE)} files, ${MUST.length - missing.length}/${MUST.length} integrity checks (no node_modules / .env / uploads). Uses .env.production as template.`);

/* 1-9 portals (static builds) */
const HTACCESS = `# SPA routing for React (Vite) build on Apache / Hostinger
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
<IfModule mod_headers.c>
  <FilesMatch "\\.(js|css|woff2?|png|jpg|svg|webp)$">
    Header set Cache-Control "public, max-age=31536000, immutable"
  </FilesMatch>
  <FilesMatch "index\\.html$">
    Header set Cache-Control "no-cache"
  </FilesMatch>
</IfModule>
`;
const portals = [
  ["1-superadmin", "admin", "admin-hrms.recruweb.com"],
  ["2-client", "client", "client-hrms.recruweb.com"],
  ["3-evs-frontend", "employee-verification-system/frontend/frontend", "evs-hrms.recruweb.com"],
  ["6-employee", "employee", "employee-hrms.recruweb.com"],
  ["7-hr", "HR", "hr-hrms.recruweb.com"],
  ["8-it", "IT", "it-hrms.recruweb.com"],
  ["9-sales", "Sales", "sales-hrms.recruweb.com"],
];
for (const [folder, rel, domain] of portals) {
  const dist = path.join(SRC, rel, "dist");
  if (!fs.existsSync(path.join(dist, "index.html"))) { log(`${folder}: MISSING dist -> build failed?`); process.exitCode = 1; continue; }
  const dst = path.join(OUT, folder);
  copyDir(dist, dst);
  fs.writeFileSync(path.join(dst, ".htaccess"), HTACCESS);
  // read baked env from source .env.production for the report
  const env = fs.readFileSync(path.join(SRC, rel, ".env.production"), "utf8").split(/\r?\n/).filter((l) => l.startsWith("VITE_")).join("; ");
  // leak check: only real API URLs (localhost:PORT); bare "http://localhost" inside react-router/socket.io is library code
  const assets = path.join(dst, "assets");
  let leaks = 0, prod = 0;
  for (const f of fs.readdirSync(assets).filter((f) => f.endsWith(".js"))) {
    const s = fs.readFileSync(path.join(assets, f), "utf8");
    leaks += (s.match(/localhost:\d{2,5}/g) || []).length;
    prod += (s.match(/backend-hrms\.recruweb\.com/g) || []).length;
  }
  if (leaks) process.exitCode = 1;
  log(`${folder}: ${domain}  <- ${rel}/dist  files=${countFiles(dst)}  backend-url-refs=${prod}  localhost-leaks=${leaks}${leaks ? "  <-- FAIL" : ""}  [${env}]`);
}

/* 11 standalone HR AI interview UI */
copyDir(path.join(SRC, "backend", "modules", "hrRobo", "ui"), path.join(OUT, "11-hr-ai-interview"));
log("11-hr-ai-interview: hr-ai-interview-hrms.recruweb.com  <- backend/modules/hrRobo/ui (plain HTML, no build)");

/* README */
fs.copyFileSync(path.join(SRC, "backend", "README-DEPLOY.md"), path.join(OUT, "README-DEPLOY.md"));

/* zip
 * bsdtar (C:\Windows\System32\tar.exe, Windows 10 1803+) writes standard
 * forward-slash entry names. PowerShell's Compress-Archive writes backslashes,
 * which libzip-based extractors (PHP file managers, some hosting panels) keep
 * literally and flatten the whole tree into one folder. Fall back to
 * Compress-Archive only if tar.exe is missing. */
const zip = path.join(OUT_ROOT, `${NAME}.zip`);
fs.rmSync(zip, { force: true });
try {
  const top = fs.readdirSync(OUT).map((n) => `"${n}"`).join(" ");
  execSync(`tar.exe -a -c -f "${zip}" -C "${OUT}" ${top}`, { stdio: "pipe" });
  log("ZIP writer: bsdtar (forward-slash entries)");
} catch (e) {
  log(`ZIP writer: bsdtar unavailable (${e.message.split("\n")[0]}) - falling back to Compress-Archive`);
  execSync(`powershell -NoProfile -Command "Compress-Archive -Path '${OUT}\\*' -DestinationPath '${zip}' -CompressionLevel Optimal"`, { stdio: "pipe" });
}

/* stats */
let files = 0, bytes = 0;
const walk = (p) => { for (const e of fs.readdirSync(p, { withFileTypes: true })) { const f = path.join(p, e.name); if (e.isDirectory()) walk(f); else { files++; bytes += fs.statSync(f).size; } } };
walk(OUT);
log(`\nPACKAGE: ${OUT}`);
log(`ZIP:     ${zip}  (${(fs.statSync(zip).size / 1048576).toFixed(1)} MB zip, ${files} files / ${(bytes / 1048576).toFixed(1)} MB unpacked)`);
log("FOLDERS: " + fs.readdirSync(OUT).join(", "));
fs.writeFileSync(path.join(process.cwd(), "_pkg_report.txt"), lines.join("\n"));
