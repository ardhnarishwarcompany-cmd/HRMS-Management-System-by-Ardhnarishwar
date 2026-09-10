/**
 * Redeploy package: FULL backend (incl. Smart Attendance + HR Robo modules) +
 * freshly built Super Admin and IT portals + standalone HR AI interview UI.
 *   node scripts/_package-redeploy.mjs      (run from backend/, after _build-all-portals.mjs admin IT)
 * Output: D:\HRMS_new\HRMS-REDEPLOY-<date>\  + .zip
 */
import fs from "fs";
import path from "path";
import { execSync } from "child_process";

const SRC = path.resolve(process.cwd(), "..");
const DATE = new Date().toISOString().slice(0, 10);
const OUT_ROOT = "D:\\HRMS_new";
const NAME = `HRMS-REDEPLOY-${DATE}`;
const OUT = path.join(OUT_ROOT, NAME);
const lines = [];
const log = (s) => { lines.push(s); console.log(s); };

fs.rmSync(OUT, { recursive: true, force: true });
fs.mkdirSync(OUT, { recursive: true });

const SKIP_BACKEND = new Set(["node_modules", ".env", "uploads", ".git", "_boot_report.txt", "_build_report.txt", "dist"]);
const skipFile = (name) => /^_.*\.(txt|json|mjs)$/.test(name);
function copyDir(src, dst, filter = () => true, depth = 0) {
  fs.mkdirSync(dst, { recursive: true });
  for (const e of fs.readdirSync(src, { withFileTypes: true })) {
    if (!filter(e.name, depth, src)) continue;
    const s = path.join(src, e.name), d = path.join(dst, e.name);
    e.isDirectory() ? copyDir(s, d, filter, depth + 1) : fs.copyFileSync(s, d);
  }
}
const count = (d) => { let n = 0; for (const e of fs.readdirSync(d, { withFileTypes: true })) n += e.isDirectory() ? count(path.join(d, e.name)) : 1; return n; };

/* 0. full backend */
const BE = path.join(OUT, "0-hrms-backend");
copyDir(path.join(SRC, "backend"), BE, (name, depth) => !(depth === 0 && SKIP_BACKEND.has(name)) && !skipFile(name));
for (const d of ["uploads", "uploads/evs", "uploads/hr-robo/video", "uploads/hr-robo/snapshots"]) fs.mkdirSync(path.join(BE, d), { recursive: true });
fs.writeFileSync(path.join(BE, "uploads", ".gitkeep"), "");
for (const must of ["app.js", "package.json", ".env.production", "modules/attendance/attendance.controller.js", "modules/attendance/ui/admin.html", "modules/hrRobo/hrRobo.controller.js", "modules/hrRobo/ui/index.html", "modules/superAdmin/clients/superAdminClients.controller.js", "modules/it/it.controller.js"]) {
  if (!fs.existsSync(path.join(BE, must))) { log(`0-hrms-backend: MISSING ${must}`); process.exitCode = 1; }
}
log(`0-hrms-backend: ${count(BE)} files (Node API + Smart Attendance UI at /api/smart-attendance + HR Robo API). No node_modules / .env / uploads.`);

/* portals */
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
  ["8-it", "IT", "it-hrms.recruweb.com"],
];
for (const [folder, rel, domain] of portals) {
  const dist = path.join(SRC, rel, "dist");
  if (!fs.existsSync(path.join(dist, "index.html"))) { log(`${folder}: MISSING dist`); process.exitCode = 1; continue; }
  const dst = path.join(OUT, folder);
  copyDir(dist, dst);
  fs.writeFileSync(path.join(dst, ".htaccess"), HTACCESS);
  const js = fs.readdirSync(path.join(dst, "assets")).filter((f) => f.endsWith(".js"));
  let localhost = 0;
  // only count real API URLs (localhost:PORT); bare `http://localhost` fallbacks inside react-router / socket.io are library code
  for (const f of js) localhost += (fs.readFileSync(path.join(dst, "assets", f), "utf8").match(/localhost:\d{2,5}/g) || []).length;
  log(`${folder}: ${domain}  <- ${rel}/dist  ${count(dst)} files  localhost=${localhost}`);
  if (localhost) process.exitCode = 1;
}

/* 11 HR AI interview UI */
const ROBO = path.join(OUT, "11-hr-ai-interview");
copyDir(path.join(SRC, "backend", "modules", "hrRobo", "ui"), ROBO);
const cfg = path.join(ROBO, "config.js");
log(`11-hr-ai-interview: hr-ai-interview-hrms.recruweb.com  <- backend/modules/hrRobo/ui  ${count(ROBO)} files  config.js=${fs.existsSync(cfg) ? "yes" : "NO"}`);

/* README */
fs.writeFileSync(path.join(OUT, "README-REDEPLOY.md"), `# HRMS Redeploy Package ${DATE}

Fresh, complete copies of every component changed since the 2 Sep 2026 production release.
Deploy in the order listed. Portals not included here (client, EVS, employee, HR, sales) are unchanged.

## 0-hrms-backend  ->  backend-hrms.recruweb.com  (deploy FIRST)
Complete Node backend. This ONE process also serves:
  - Smart Attendance portal   https://backend-hrms.recruweb.com/api/smart-attendance/   (login / admin / employee pages)
  - HR Robo API               /api/hr-robo/*   (used by 11-hr-ai-interview and the HR portal)
  - EVS API                   /api/evs/*
Steps:
  1. Stop Node (pm2 stop hrms-backend).
  2. Replace the deployed backend folder with this one, BUT keep your existing \`.env\` and \`uploads/\` folder
     (copy them back in). \`.env.production\` is only a template.
  3. npm install --omit=dev
  4. pm2 restart hrms-backend   (or pm2 start app.js --name hrms-backend)
  5. Check: GET /api/smart-attendance/api/health  ->  ok
No database migration is required for this release.

## 1-superadmin  ->  admin-hrms.recruweb.com public_html
Delete the old contents, upload everything here including the hidden \`.htaccess\`.

## 8-it  ->  it-hrms.recruweb.com public_html
Delete the old contents, upload everything here including the hidden \`.htaccess\`.

## 11-hr-ai-interview  ->  hr-ai-interview-hrms.recruweb.com public_html
Plain HTML, no build. Replace all files. \`config.js\` sets HR_ROBO_BASE (backend URL) - keep your deployed value if you changed it.

## After deploying
Hard-refresh each portal once (Ctrl+F5). Smart Attendance pages are now sent with no-store so old cached
admin.html cannot survive, but a single hard refresh clears anything already cached.

## What changed (3 Sep 2026)
Backend
  - Super Admin client delete: FK error (client_leads -> client_lead_batches) fixed; transactional delete of all client_* data.
  - Smart Attendance: CSV download always returns a file (empty periods -> header-only CSV, was 404); pages served no-store.
  - HR Robo: shared store merges by candidate identity - candidates registered on any laptop now show in every admin dashboard.
  - IT: timesheet/performance/complaints/targets/emergency/work policies scoped for role \`it\`; EOD API; deliverables read-only for Super Admin.
  - Attendance CSV: BOM + X-Row-Count header.
Super Admin portal
  - Client Directory table: proper sticky header + scroll region; IT Developer page read-only timesheet + Deliverables tab.
IT portal
  - Premium redesign: Tasks, Timesheet, Bugs, Performance, Targets, Deployments, Complaints, Work Policies, Daily Work, My EOD Reports; dark mode fixes.
HR AI interview UI
  - Store sync fix (merge + tombstones), relative asset paths, backend JWT admin login.
`);

/* zip */
const zip = path.join(OUT_ROOT, `${NAME}.zip`);
fs.rmSync(zip, { force: true });
execSync(`powershell -NoProfile -Command "Compress-Archive -Path '${OUT}\\*' -DestinationPath '${zip}' -Force"`, { stdio: "pipe" });
const mb = (fs.statSync(zip).size / 1048576).toFixed(2);
log(`ZIP ${zip}  ${mb} MB  total files=${count(OUT)}`);
fs.writeFileSync(path.join(process.cwd(), "_redeploy_report.txt"), lines.join("\n"));
