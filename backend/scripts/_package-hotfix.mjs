/**
 * Packages a hotfix: changed backend modules + freshly built admin & IT dist.
 * Run from backend/:  node scripts/_package-hotfix.mjs
 */
import fs from "fs";
import path from "path";
import { execSync } from "child_process";

const SRC = path.resolve(process.cwd(), "..");                 // HRMS Merging
const OUTROOT = "D:\\HRMS_new";
const NAME = "HRMS-HOTFIX-2026-09-03";
const PKG = path.join(OUTROOT, NAME);
const FULL = path.join(OUTROOT, "HRMS-FULL-PRODUCTION-2026-09-02");

const rm = (p) => fs.existsSync(p) && fs.rmSync(p, { recursive: true, force: true });
const cp = (from, to) => {
  fs.mkdirSync(path.dirname(to), { recursive: true });
  fs.cpSync(from, to, { recursive: true });
};

rm(PKG); rm(PKG + ".zip");

// backend files touched by this hotfix
const backendItems = [
  "app.js",
  "modules/it/it.controller.js",
  "modules/itdev",
  "modules/common/deliverables",
  "modules/hrRobo",
];
for (const rel of backendItems) cp(path.join(SRC, "backend", rel), path.join(PKG, "0-hrms-backend", rel));

// built portals
cp(path.join(SRC, "admin", "dist"), path.join(PKG, "1-superadmin"));
cp(path.join(SRC, "IT", "dist"), path.join(PKG, "8-it"));
for (const p of ["1-superadmin", "8-it"]) {
  const ht = path.join(FULL, p, ".htaccess");
  if (fs.existsSync(ht)) fs.copyFileSync(ht, path.join(PKG, p, ".htaccess"));
}

fs.writeFileSync(path.join(PKG, "README-HOTFIX.md"), `# HRMS Hotfix 2026-09-03

Apply on top of HRMS-FULL-PRODUCTION-2026-09-02.

## Contents
- 0-hrms-backend/  -> copy over the deployed backend folder (same paths), then restart Node (pm2 restart / nodemon).
  - modules/it/it.controller.js        timesheet scoped to logged-in developer; SUPER_ADMIN/hr see all
  - modules/itdev/*                     unified IT Developer admin API; admin timesheet is read-only (POST/DELETE removed)
  - modules/common/deliverables/*       list readable by any HRMS token (Super Admin can view); delete = uploader or SUPER_ADMIN
  - modules/hrRobo/*                    HR Robo shared store (GET/PUT /api/store) + UI sync
  - app.js                              mounts
- 1-superadmin/  -> replace contents of the superadmin subdomain public_html (SPA .htaccess included)
  - IT Developer page: Log Time + timesheet delete removed; new read-only Deliverables tab (Videos / Reports / Source code)
- 8-it/          -> replace contents of the IT subdomain public_html (SPA .htaccess included)
  - Premium MagicCard redesign of Task Assignment, Timesheet, Bug Reporting
  - Timesheet shows only the developer's own hours

No DB migration required. Builds bake in recruweb.com production domains (0 localhost).
`);

const count = (d) => { let n = 0; for (const e of fs.readdirSync(d, { withFileTypes: true })) n += e.isDirectory() ? count(path.join(d, e.name)) : 1; return n; };
execSync(`powershell -NoProfile -Command "Compress-Archive -Path '${PKG}\\*' -DestinationPath '${PKG}.zip' -Force"`, { stdio: "pipe" });
const mb = (fs.statSync(PKG + ".zip").size / 1048576).toFixed(2);
console.log(`OK  ${PKG}  files=${count(PKG)}  zip=${mb} MB`);
