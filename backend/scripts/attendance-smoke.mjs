/**
 * Live smoke test for the merged Smart Attendance module.
 * Backend must be running on :5000.
 * Writes results to _sa.txt.
 *
 * This test deliberately uses the existing smoke attendance employee. Before
 * OTP it removes only today's smoke record, creates a temporary HRMS employee
 * mapping when needed, and clears today's HRMS attendance for that mapping.
 */
import fs from "fs";
import path from "path";
import dotenv from "dotenv";
import mysql from "mysql2/promise";

dotenv.config({ path: path.join(process.cwd(), ".env") });
const BASE = process.env.SMOKE_BASE || "http://localhost:5000";
const M = `${BASE}/api/smart-attendance`;
const out = [];
const log = (ok, name, extra = "") => out.push(`${ok ? "PASS" : "FAIL"} ${name}${extra ? " -> " + extra : ""}`);

const j = async (url, opt = {}) => {
  const r = await fetch(url, opt);
  const t = await r.text();
  let b;
  try { b = JSON.parse(t); } catch { b = t; }
  return { s: r.status, b, h: r.headers };
};

let conn = null;
let admin = null;
let emp = null;
let originalAdminPassword = null;
let originalEmpPassword = null;
let smokeHrmsId = null;
let createdSmokeHrms = false;
let smokeCode = null;
let smokeOtpKey = null;

try {
  /* pages + assets */
  for (const p of ["/", "/admin", "/employee", "/employee/face", "/register-account"]) {
    const r = await fetch(M + p);
    const html = await r.text();
    log(r.status === 200 && html.includes("<html"), `page ${p}`, String(r.status));
  }
  for (const a of ["vendor/sa-face.js", "vendor/face-api.min.js", "vendor/models/tiny_face_detector_model-weights_manifest.json", "vendor/models/face_recognition_model-weights_manifest.json"]) {
    const r = await fetch(`${M}/static/${a}`);
    log(r.status === 200, `asset ${a}`, `${r.status} ${r.headers.get("content-length") || ""}b`);
  }
  const h = await j(`${M}/api/health`);
  log(h.s === 200 && h.b.database === "ok", "health", JSON.stringify(h.b));

  /* protected without login */
  const noauth = await j(`${M}/api/stats`);
  log(noauth.s === 401, "stats without login -> 401", String(noauth.s));

  conn = await mysql.createConnection({
    host: process.env.DB_HOST || "localhost",
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || process.env.DB_PASS || "",
    database: process.env.DB_NAME || "hrms_db",
  });

  const [[adminRow]] = await conn.query("SELECT id, mobile, password FROM attendance_users WHERE role='admin' LIMIT 1");
  const [[empRow]] = await conn.query("SELECT id, mobile, emp_id, password FROM attendance_users WHERE role='employee' AND emp_id IS NOT NULL LIMIT 1");
  admin = adminRow;
  emp = empRow;
  if (!admin || !emp) throw new Error("Smoke test requires one attendance admin and one employee account");
  originalAdminPassword = admin.password;
  originalEmpPassword = emp.password;
  smokeCode = String(emp.emp_id);
  smokeOtpKey = `otp_${smokeCode}`;

  const bcrypt = (await import("bcryptjs")).default;
  const TESTPW = "smoke123";
  await conn.query("UPDATE attendance_users SET password=? WHERE id IN (?,?)", [bcrypt.hashSync(TESTPW, 10), admin.id, emp.id]);

  /* Ensure HRMS sync has a valid employeeCode mapping for the smoke employee. */
  const [[existingSmokeHrms]] = await conn.query("SELECT id FROM employees WHERE employeeCode=? LIMIT 1", [smokeCode]);
  smokeHrmsId = existingSmokeHrms?.id || null;
  if (!smokeHrmsId) {
    const [[dept]] = await conn.query("SELECT id FROM departments ORDER BY id LIMIT 1");
    const [[desig]] = await conn.query("SELECT id FROM designations ORDER BY id LIMIT 1");
    const [[status]] = await conn.query("SELECT id FROM employee_statuses ORDER BY id LIMIT 1");
    if (!dept || !desig || !status) throw new Error("Cannot create smoke HRMS employee: master data missing");
    const email = `smoke-${smokeCode.replace(/[^a-zA-Z0-9]/g, "")}@smoke.invalid`;
    const [ins] = await conn.query(
      `INSERT INTO employees (employeeCode,name,email,departmentId,designationId,statusId,joiningDate,salary,isActive) VALUES (?,?,?,?,?,?,?,?,1)`,
      [smokeCode, "Smoke Test", email, dept.id, desig.id, status.id, new Date().toISOString().slice(0, 10), 0],
    );
    smokeHrmsId = ins.insertId;
    createdSmokeHrms = true;
    console.log(`[smoke] temporary HRMS employee created: ${smokeCode}`);
  }

  const al = await j(`${M}/api/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ mobile: admin.mobile, password: TESTPW, role: "admin" }),
  });
  log(al.s === 200 && al.b.ok && al.b.token, "admin login", `role=${al.b.role} cookie=${/sa_token=/.test(al.h.get("set-cookie") || "")}`);
  const A = { Authorization: `Bearer ${al.b.token}` };
  const cookie = { Cookie: (al.h.get("set-cookie") || "").split(";")[0] };

  const st = await j(`${M}/api/stats`, { headers: A });
  log(st.s === 200 && "present" in st.b, "admin stats (bearer)", JSON.stringify(st.b));
  const stc = await j(`${M}/api/stats`, { headers: cookie });
  log(stc.s === 200, "admin stats (cookie)", String(stc.s));
  const rep = await j(`${M}/api/report?date=2026-09-01`, { headers: A });
  log(rep.s === 200 && Array.isArray(rep.b.rows), "report", `rows=${rep.b.rows?.length}`);
  const reg = await j(`${M}/api/registered-employees`, { headers: A });
  log(reg.s === 200 && Array.isArray(reg.b.employees), "registered-employees", `n=${reg.b.employees?.length} face_ready=${reg.b.employees?.map(e=>e.face_ready).join(",")}`);
  const acc = await j(`${M}/api/accounts/list`, { headers: A });
  log(acc.s === 200 && Array.isArray(acc.b.accounts), "accounts list", `n=${acc.b.accounts?.length}`);
  const off = await j(`${M}/api/office-location`);
  log(off.s === 200 && off.b.lat, "office-location", JSON.stringify(off.b));
  const sh = await j(`${M}/api/shift-settings`, { headers: A });
  log(sh.s === 200 && sh.b.shift?.start, "shift-settings", JSON.stringify(sh.b.shift));
  const sum = await j(`${M}/api/summary?month=2026-09`, { headers: A });
  log(sum.s === 200 && sum.b.ok, "admin summary", `rows=${sum.b.rows?.length}`);
  const pend = await j(`${M}/api/attendance/pending`, { headers: A });
  log(pend.s === 200 && pend.b.ok, "pending", `n=${pend.b.records?.length}`);
  const cor = await j(`${M}/api/corrections?state=all`, { headers: A });
  log(cor.s === 200 && cor.b.ok, "corrections (admin)", `n=${cor.b.corrections?.length}`);
  const hs = await j(`${M}/api/hrms-settings`, { headers: A });
  log(hs.s === 200 && hs.b.hrms?.mode === "direct", "hrms-settings", JSON.stringify(hs.b.hrms));

  /* fake face descriptor register + match (admin) */
  const desc = Array.from({ length: 128 }, (_, i) => Math.sin(i) * 0.1);
  const rf = await j(`${M}/api/register-face`, {
    method: "POST",
    headers: { ...A, "Content-Type": "application/json" },
    body: JSON.stringify({ emp_id: emp.emp_id, name: "Smoke Test", descriptor: desc }),
  });
  log(rf.s === 200 && rf.b.ok, "register-face (descriptor)", rf.b.message);
  const mk = await j(`${M}/api/mark-attendance`, {
    method: "POST",
    headers: { ...A, "Content-Type": "application/json" },
    body: JSON.stringify({ descriptors: [desc], lat: off.b.lat, lng: off.b.lng }),
  });
  log(mk.s === 200 && mk.b.ok && mk.b.marked?.[0]?.emp_id === emp.emp_id, "mark-attendance (match)", JSON.stringify(mk.b.marked));
  const legacyImg = await j(`${M}/api/mark-attendance`, {
    method: "POST",
    headers: { ...A, "Content-Type": "application/json" },
    body: JSON.stringify({ image: "data:image/jpeg;base64,xx", lat: off.b.lat, lng: off.b.lng }),
  });
  log(legacyImg.s === 200 && legacyImg.b.ok === false, "mark-attendance legacy image rejected", legacyImg.b.error);

  /* employee flow */
  const el = await j(`${M}/api/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ mobile: emp.mobile, password: TESTPW, role: "employee" }),
  });
  log(el.s === 200 && el.b.ok, "employee login", `emp_id=${el.b.emp_id}`);
  const E = { Authorization: `Bearer ${el.b.token}` };
  const ms = await j(`${M}/api/my-status`, { headers: E });
  log(ms.s === 200 && ms.b.ok, "my-status", `marked=${ms.b.marked}`);
  const mh = await j(`${M}/api/my-history?month=2026-09`, { headers: E });
  log(mh.s === 200 && mh.b.ok, "my-history", JSON.stringify(mh.b.summary));
  const denied = await j(`${M}/api/stats`, { headers: E });
  log(denied.s === 403, "employee -> admin route 403", String(denied.s));

  /* OTP must start from an unmarked day. Also remove any async HRMS row left by the face test. */
  await conn.query("DELETE FROM attendance_records WHERE emp_id=? AND date=CURDATE()", [smokeCode]);
  await conn.query("DELETE FROM super_admin_attendance WHERE employee_id=? AND date=CURDATE()", [smokeHrmsId]);
  await conn.query("DELETE FROM attendance_settings WHERE skey=?", [smokeOtpKey]);
  process.env.OTP_DEBUG = "1";

  const os = await j(`${M}/api/otp/send`, { method: "POST", headers: E });
  log(os.s === 200 && os.b.ok, "otp send", os.b.message || os.b.error);
  const [[otpRow]] = await conn.query("SELECT data FROM attendance_settings WHERE skey = ?", [smokeOtpKey]);
  if (!otpRow?.data) throw new Error(`OTP row was not created after otp/send (status ${os.s})`);
  const otpPayload = JSON.parse(otpRow.data);
  const otp = os.b?.otp_dev || otpPayload.otp;
  if (!otp) throw new Error("OTP value missing from attendance_settings");

  const ov = await j(`${M}/api/otp/verify`, {
    method: "POST",
    headers: { ...E, "Content-Type": "application/json" },
    body: JSON.stringify({ otp, lat: off.b.lat, lng: off.b.lng }),
  });
  log(ov.s === 200 && ov.b.ok, "otp verify", `${ov.b.status || ""} ${ov.b.time || ov.b.error || ""}`.trim());
  const co = await j(`${M}/api/check-out`, { method: "POST", headers: E });
  log(co.s === 200 && co.b.ok !== undefined, "check-out", co.b.message || co.b.error);
  const lo = await j(`${M}/api/logout`, { method: "POST", headers: E });
  log(lo.s === 200 && lo.b.ok, "logout", "");

  /* HRMS Super Admin token works as attendance admin */
  const sa = await j(`${BASE}/api/super-admin/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: process.env.SMOKE_SA_EMAIL || "admin@hrms.com",
      password: process.env.SMOKE_SA_PASS || "admin123",
    }),
  });
  const saTok = sa.b?.token || sa.b?.accessToken || sa.b?.data?.token;
  if (saTok) {
    const sst = await j(`${M}/api/stats`, { headers: { Authorization: `Bearer ${saTok}` } });
    log(sst.s === 200, "HRMS super admin token -> attendance admin", String(sst.s));
  } else log(false, "HRMS super admin login", `${sa.s} ${JSON.stringify(sa.b).slice(0, 120)}`);

  /* HRMS sync is asynchronous; poll instead of assuming an 800ms delay is enough. */
  let syncRow = null;
  for (let i = 0; i < 12; i++) {
    const [[row]] = await conn.query(
      "SELECT hrms_sync, hrms_sync_error FROM attendance_records WHERE emp_id=? ORDER BY id DESC LIMIT 1",
      [smokeCode],
    );
    syncRow = row || null;
    if (syncRow?.hrms_sync === "synced" || syncRow?.hrms_sync === "failed") break;
    await new Promise((r) => setTimeout(r, 500));
  }
  log(syncRow?.hrms_sync === "synced", "hrms sync status of latest record", JSON.stringify(syncRow));
} catch (e) {
  out.push("EXCEPTION " + (e.stack || e.message));
} finally {
  /* Always restore/clean smoke data, even when a test assertion throws. */
  try {
    if (conn) {
      if (smokeCode) {
        await conn.query("DELETE FROM attendance_records WHERE emp_id=? AND date=CURDATE()", [smokeCode]);
        await conn.query("DELETE FROM attendance_settings WHERE skey=?", [`otp_${smokeCode}`]);
      }
      if (smokeHrmsId) {
        await conn.query("DELETE FROM super_admin_attendance WHERE employee_id=? AND date=CURDATE()", [smokeHrmsId]);
        if (createdSmokeHrms) {
          await conn.query("DELETE FROM employees WHERE id=? AND employeeCode=?", [smokeHrmsId, smokeCode]);
        }
      }
      if (admin && originalAdminPassword) await conn.query("UPDATE attendance_users SET password=? WHERE id=?", [originalAdminPassword, admin.id]);
      if (emp && originalEmpPassword) await conn.query("UPDATE attendance_users SET password=? WHERE id=?", [originalEmpPassword, emp.id]);
      await conn.end();
    }
  } catch (cleanupError) {
    out.push("CLEANUP ERROR " + (cleanupError.stack || cleanupError.message));
  }
  fs.writeFileSync("_sa.txt", out.join("\n"));
  console.log(out.join("\n"));
}
