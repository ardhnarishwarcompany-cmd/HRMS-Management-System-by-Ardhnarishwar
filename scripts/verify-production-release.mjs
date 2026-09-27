import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const portals = [
  "admin/dist",
  "client/dist",
  "HR/dist",
  "IT/dist",
  "Sales/dist",
  "employee/dist",
  "employee-verification-system/frontend/frontend/dist",
];

let failures = 0;
const checkText = (file) => {
  const s = fs.readFileSync(file, "utf8");
  const bad = [
    /http:\/\/localhost:\d+/i,
    /https?:\/\/127\.0\.0\.1:\d+/i,
    /https?:\/\/localhost:\d+/i,
  ];
  return bad.filter((re) => re.test(s));
};

for (const rel of portals) {
  const dir = path.join(root, rel);
  if (!fs.existsSync(dir)) {
    console.error(`MISSING DIST: ${rel}`);
    failures++;
    continue;
  }
  const files = fs.readdirSync(dir, { withFileTypes: true });
  const stack = [dir];
  let count = 0;
  while (stack.length) {
    const d = stack.pop();
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) stack.push(p);
      else if (/\.(js|css|html|json)$/i.test(e.name)) {
        count++;
        const bad = checkText(p);
        if (bad.length) {
          console.error(`LOCAL URL FOUND: ${path.relative(root, p)}`);
          failures++;
        }
      }
    }
  }
  console.log(`OK ${rel} (${count} web assets scanned)`);
}

const env = fs.readFileSync(path.join(root, "backend/.env"), "utf8");
for (const required of [
  "NODE_ENV=production",
  "DB_HOST=127.0.0.1",
  "DB_USER=u471298916_hrms_db_user",
  "DB_NAME=u471298916_hrms_db",
  "CORS_ORIGINS=",
  "EVS_FRONTEND_URL=https://ardhnarishwar-emp-verification.hrms.recruweb.com",
]) {
  if (!env.includes(required)) {
    console.error(`BACKEND ENV MISSING: ${required}`);
    failures++;
  }
}

console.log(failures ? `RESULT: FAIL (${failures})` : "RESULT: PASS");
process.exitCode = failures ? 1 : 0;
