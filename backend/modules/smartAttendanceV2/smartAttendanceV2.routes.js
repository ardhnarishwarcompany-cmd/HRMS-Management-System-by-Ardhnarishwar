import express from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import { db } from "../../config/db.js";

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET;
const COOKIE = "smart_attendance_token";
const COOKIE_MAX_AGE = 8 * 60 * 60 * 1000;

if (!JWT_SECRET) console.warn("[smart-attendance-v2] JWT_SECRET is not configured");

function send(res, data, status = 200) {
  return res.status(status).json(data);
}
function tokenFor(user) {
  return jwt.sign({
    id: user.id,
    company_id: user.company_id,
    emp_id: user.emp_id ?? null,
    name: user.name,
    role: user.role,
    email: user.email ?? null,
  }, JWT_SECRET, { expiresIn: "8h" });
}
function setAuthCookie(res, token) {
  res.setHeader("Set-Cookie",
    `${COOKIE}=${encodeURIComponent(token)}; Path=/; HttpOnly; SameSite=Lax; Max-Age=${Math.floor(COOKIE_MAX_AGE/1000)}${process.env.NODE_ENV === "production" ? "; Secure" : ""}`
  );
}
function clearAuthCookie(res) {
  res.setHeader("Set-Cookie", `${COOKIE}=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0${process.env.NODE_ENV === "production" ? "; Secure" : ""}`);
}
function cookies(req) {
  const out = {};
  for (const p of String(req.headers.cookie || "").split(";")) {
    const i = p.indexOf("=");
    if (i > 0) out[p.slice(0,i).trim()] = decodeURIComponent(p.slice(i+1).trim());
  }
  return out;
}
function auth(req, res, next) {
  try {
    const raw = cookies(req)[COOKIE] || (String(req.headers.authorization || "").startsWith("Bearer ") ? req.headers.authorization.slice(7) : null);
    if (!raw) return send(res, { error: "Authentication required" }, 401);
    req.smartUser = jwt.verify(raw, JWT_SECRET);
    next();
  } catch {
    return send(res, { error: "Invalid or expired authentication" }, 401);
  }
}
function roles(...allowed) {
  return (req, res, next) => {
    if (!req.smartUser || !allowed.includes(req.smartUser.role)) return send(res, { error: "Forbidden" }, 403);
    next();
  };
}
function company(req) {
  return req.query.company_id || req.body?.company_id || req.smartUser?.company_id;
}
function ip(req) {
  return String(req.headers["x-forwarded-for"] || req.socket.remoteAddress || "").split(",")[0].trim();
}
async function audit(req, action, details = {}) {
  try {
    await db.query(
      `INSERT INTO smart_audit_logs
       (action,company_id,actor_name,actor_role,details,ip,user_agent,timestamp_utc,created_at)
       VALUES (?,?,?,?,?,?,?,?,?)`,
      [action, req.smartUser?.company_id || details.company_id || "GLOBAL_ENT",
       req.smartUser?.name || "system", req.smartUser?.role || "system",
       JSON.stringify(details), ip(req), req.headers["user-agent"] || null,
       new Date().toISOString(), new Date().toISOString()]
    );
  } catch (e) {
    console.error("[smart-attendance-v2] audit:", e.message);
  }
}
async function employeeById(companyId, empId) {
  const [rows] = await db.query(
    `SELECT u.id,u.company_id,u.emp_id,u.name,u.email,u.mobile,u.role,u.status,
            m.department,m.designation,m.work_type,m.timezone,m.encoding
       FROM smart_users u
       LEFT JOIN smart_employee_meta m ON m.company_id=u.company_id AND m.emp_id=u.emp_id
      WHERE u.company_id=? AND (u.emp_id=? OR CAST(u.id AS CHAR)=?) LIMIT 1`,
    [companyId, empId, String(empId)]
  );
  return rows[0] || null;
}
function sameTenant(req, id) {
  return req.smartUser.role === "super_admin" || String(req.smartUser.company_id) === String(id);
}
function normalizeTime(v) {
  if (!v) return null;
  const s = String(v);
  return s.length === 5 ? `${s}:00` : s.slice(0,8);
}
function today() {
  return new Date().toISOString().slice(0,10);
}
function cosine(a,b) {
  if (!Array.isArray(a) || !Array.isArray(b) || !a.length || a.length !== b.length) return -1;
  let dot=0,na=0,nb=0;
  for(let i=0;i<a.length;i++){ const x=Number(a[i]),y=Number(b[i]); dot+=x*y;na+=x*x;nb+=y*y; }
  return na && nb ? dot/(Math.sqrt(na)*Math.sqrt(nb)) : -1;
}

/* health */
router.get(["/health","/api/health"], async (_req,res) => {
  try {
    await db.query("SELECT 1");
    return send(res,{status:"healthy",database:"connected",service:"smart-attendance-v2"});
  } catch (e) { return send(res,{status:"degraded",database:"error",error:e.message},503); }
});

/* auth */
router.post("/api/login", async (req,res) => {
  const { company_id, email, mobile, password, role } = req.body || {};
  if (!password || (!email && !mobile)) return send(res,{error:"email/mobile and password are required"},400);

  let rows;
  if (role === "super_admin") {
    [rows] = await db.query(
      `SELECT * FROM smart_users WHERE role='super_admin' AND ${email ? "email=?" : "mobile=?"} LIMIT 1`,
      [email || mobile]
    );
  } else {
    if (!company_id) return send(res,{error:"company_id, email/mobile and password are required"},400);
    [rows] = await db.query(
      `SELECT * FROM smart_users WHERE company_id=? AND ${email ? "email=?" : "mobile=?"} LIMIT 1`,
      [company_id, email || mobile]
    );
  }
  const user = rows[0];
  if (!user || user.status !== "active" || !(await bcrypt.compare(String(password), user.password))) return send(res,{error:"Invalid credentials"},401);
  const token=tokenFor(user); setAuthCookie(res,token); await audit({smartUser:user,headers:req.headers,socket:req.socket}, "login");
  return send(res,{success:true,user:{id:user.id,company_id:user.company_id,emp_id:user.emp_id,name:user.name,email:user.email,mobile:user.mobile,role:user.role,status:user.status}});
});
router.post("/api/logout", auth, async (req,res) => { await audit(req,"logout"); clearAuthCookie(res); return send(res,{success:true}); });
router.get("/api/me", auth, async (req,res) => {
  const [rows]=await db.query(`SELECT id,company_id,emp_id,name,email,mobile,role,status FROM smart_users WHERE id=? LIMIT 1`,[req.smartUser.id]);
  if(!rows[0]) return send(res,{error:"User not found"},404);
  return send(res,{success:true,user:rows[0]});
});

/* company registration / verification */
router.get("/api/auth/verify-company/:company", async (req,res) => {
  const [rows]=await db.query(`SELECT company_id,name,code,status FROM smart_companies WHERE company_id=? OR code=? LIMIT 1`,[req.params.company,req.params.company]);
  if(!rows[0]) return send(res,{valid:false,error:"Company not found"},404);
  return send(res,{valid:rows[0].status==="active",company:rows[0]});
});
router.post("/api/auth/register-company", async (req,res) => {
  const {company_id,name,code,admin_name,email,mobile,password}=req.body||{};
  if(!company_id||!name||!password||(!email&&!mobile)) return send(res,{error:"company_id, name, admin_name, email/mobile and password are required"},400);
  const conn=await db.getConnection();
  try {
    await conn.beginTransaction();
    await conn.query(`INSERT INTO smart_companies(company_id,name,code,status) VALUES(?,?,?,'active')`,[company_id,name,code||null]);
    const hash=await bcrypt.hash(String(password),12);
    const [r]=await conn.query(
      `INSERT INTO smart_users(company_id,emp_id,name,email,mobile,password,role,status) VALUES(?,NULL,?,?,?,?, 'admin','active')`,
      [company_id,admin_name||name,email||null,mobile||null,hash]
    );
    /* keep the legacy `companies` table (jobs, etc. have an FK to it) in sync */
    const slug=String(company_id).toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-+|-+$/g,'')||String(company_id).toLowerCase();
    await conn.query(
      `INSERT INTO companies(id,name,slug,domain,plan_tier,status,max_jobs,max_candidates_per_month,max_employees,contact_email,contact_person,industry,ai_custom_rules_enabled,recording_storage_used_mb,recording_storage_quota_mb,created_at,updated_at)
       VALUES(?,?,?,?, 'STARTER','ACTIVE', 10,100,50, ?, ?, 'General', 0, 0, 5000, NOW(), NOW())
       ON DUPLICATE KEY UPDATE name=VALUES(name)`,
      [company_id, name, slug, `${slug}.recruweb.com`, email||'no-reply@recruweb.com', admin_name||name]
    );
    await conn.commit();
    return send(res,{success:true,company_id,user_id:r.insertId},201);
  } catch(e){await conn.rollback(); return send(res,{error:e.code==="ER_DUP_ENTRY"?"Company or account already exists":e.message},409)}
  finally{conn.release();}
});
router.post("/api/auth/register-employee", async (req,res) => {
  const {company_id,emp_id,name,email,mobile,password,department,designation,work_type,timezone}=req.body||{};
  if(!company_id||!emp_id||!name||!password) return send(res,{error:"company_id, emp_id, name and password are required"},400);
  const hash=await bcrypt.hash(String(password),12);
  const conn=await db.getConnection();
  try{
    await conn.beginTransaction();
    const [r]=await conn.query(
      `INSERT INTO smart_users(company_id,emp_id,name,email,mobile,password,role,status) VALUES(?,?,?,?,?,?, 'employee','active')`,
      [company_id,emp_id,name,email||null,mobile||null,hash]
    );
    await conn.query(
      `INSERT INTO smart_employee_meta(company_id,emp_id,department,designation,work_type,timezone) VALUES(?,?,?,?,?,?)
       ON DUPLICATE KEY UPDATE department=VALUES(department),designation=VALUES(designation),work_type=VALUES(work_type),timezone=VALUES(timezone)`,
      [company_id,emp_id,department||null,designation||null,work_type||null,timezone||null]
    );
    await conn.commit(); return send(res,{success:true,user_id:r.insertId},201);
  }catch(e){await conn.rollback();return send(res,{error:e.code==="ER_DUP_ENTRY"?"Employee already exists":e.message},409)}
  finally{conn.release();}
});
router.post("/api/auth/check-registration-status", async(req,res)=>{
  const {company_id,emp_id,email,mobile}=req.body||{};
  const [rows]=await db.query(`SELECT id,status FROM smart_users WHERE company_id=? AND (emp_id=? OR email=? OR mobile=?) LIMIT 1`,[company_id||"",emp_id||"",email||"",mobile||""]);
  return send(res,{registered:!!rows[0],status:rows[0]?.status||null});
});
router.post("/api/auth/forgot-password/request", async(req,res)=>{
  const {company_id,email,mobile}=req.body||{};
  const [rows]=await db.query(`SELECT id,email,mobile FROM smart_users WHERE company_id=? AND (${email?"email=?":"mobile=?"}) LIMIT 1`,[company_id,email||mobile]);
  if(!rows[0]) return send(res,{success:true,message:"If the account exists, a reset code has been generated."});
  const code=String(Math.floor(100000+Math.random()*900000));
  const hash=crypto.createHash("sha256").update(code).digest("hex");
  await db.query(`INSERT INTO smart_notifications(company_id,emp_id,type,title,message,reset_code_hash,expires_ts,email,mobile) VALUES(?,(SELECT emp_id FROM smart_users WHERE id=?),'PASSWORD_RESET','PASSWORD_RESET','Password reset requested',?,UNIX_TIMESTAMP()+900,?,?)`,
    [company_id,rows[0].id,hash,rows[0].email||null,rows[0].mobile||null]);
  const response={success:true,message:"Reset code generated."};
  if(process.env.NODE_ENV!=="production") response.debug_code=code;
  return send(res,response);
});
router.post("/api/auth/forgot-password/reset", async(req,res)=>{
  const {company_id,email,mobile,code,new_password}=req.body||{};
  if(!company_id||!code||!new_password) return send(res,{error:"company_id, code and new_password are required"},400);
  const [rows]=await db.query(`SELECT id,emp_id,reset_code_hash,expires_ts FROM smart_notifications WHERE company_id=? AND type='PASSWORD_RESET' AND reset_code_hash IS NOT NULL ORDER BY id DESC LIMIT 1`,[company_id]);
  const n=rows[0];
  if(!n || Number(n.expires_ts)<Date.now()/1000 || n.reset_code_hash!==crypto.createHash("sha256").update(String(code)).digest("hex")) return send(res,{error:"Invalid or expired reset code"},400);
  const [users]=await db.query(
    `SELECT id FROM smart_users WHERE company_id=? AND ${email?"email=?":"mobile=?"} LIMIT 1`,
    [company_id,email||mobile]
  );
  if(!users[0]) return send(res,{error:"Account not found"},404);
  const hash=await bcrypt.hash(String(new_password),12);
  const [u]=await db.query(
    `UPDATE smart_users SET password=? WHERE id=? AND company_id=?`,
    [hash,users[0].id,company_id]
  );
  if(!u.affectedRows) return send(res,{error:"Password update failed"},500);
  await db.query(
    `UPDATE smart_notifications SET reset_code_hash=NULL WHERE id=?`,
    [n.id]
  );
  return send(res,{success:true});
});

/* employee self-service */
router.get("/api/attendance/my-history",auth,async(req,res)=>{
  const [rows]=await db.query(`SELECT * FROM smart_attendance WHERE company_id=? AND emp_id=? ORDER BY date DESC, COALESCE(check_in,'23:59:59') DESC LIMIT ?`,[req.smartUser.company_id,req.smartUser.emp_id,Math.min(Number(req.query.limit||100),500)]);
  return send(res,{success:true,attendance:rows,records:rows});
});
router.get("/api/leaves/my-leaves",auth,async(req,res)=>{
  const [rows]=await db.query(`SELECT * FROM smart_leaves WHERE company_id=? AND emp_id=? ORDER BY start_date DESC`,[req.smartUser.company_id,req.smartUser.emp_id]);
  return send(res,{success:true,leaves:rows});
});
router.post("/api/leaves/apply",auth,async(req,res)=>{
  const {leave_type,start_date,end_date,reason}=req.body||{};
  if(!leave_type||!start_date||!end_date)return send(res,{error:"leave_type, start_date and end_date are required"},400);
  const [r]=await db.query(`INSERT INTO smart_leaves(company_id,emp_id,leave_type,start_date,end_date,reason) VALUES(?,?,?,?,?,?)`,
    [req.smartUser.company_id,req.smartUser.emp_id,leave_type,start_date,end_date,reason||null]);
  await audit(req,"leave.apply",{id:r.insertId}); return send(res,{success:true,id:r.insertId},201);
});
router.post("/api/attendance/request-correction",auth,async(req,res)=>{
  const {date,requested_time,check_type,reason}=req.body||{};
  if(!date||!reason)return send(res,{error:"date and reason are required"},400);
  const cid=`COR-${Date.now()}-${crypto.randomBytes(3).toString("hex")}`;
  const [r]=await db.query(`INSERT INTO smart_attendance_corrections(correction_id,company_id,emp_id,employee_name,date,requested_time,check_type,reason,status,timestamp_utc) VALUES(?,?,?,?,?,?,?,?, 'pending',?)`,
    [cid,req.smartUser.company_id,req.smartUser.emp_id,req.smartUser.name,date,requested_time||null,check_type||"IN",reason,new Date().toISOString()]);
  await audit(req,"attendance.correction.request",{correction_id:cid}); return send(res,{success:true,correction_id:cid,id:r.insertId},201);
});
router.get("/api/notifications",auth,async(req,res)=>{
  const [rows]=await db.query(`SELECT * FROM smart_notifications WHERE company_id=? AND (emp_id=? OR emp_id IS NULL) ORDER BY id DESC LIMIT 100`,[req.smartUser.company_id,req.smartUser.emp_id]);
  return send(res,{success:true,notifications:rows});
});

/* attendance helpers */
async function upsertPunch(req,{emp_id,check_type,lat,lng,face_matched,remarks,status="PRESENT",check_in,check_out}) {
  const companyId=req.smartUser.company_id;
  const eid=emp_id||req.smartUser.emp_id;
  const d=req.body.date||today();
  const [rows]=await db.query(`SELECT * FROM smart_attendance WHERE company_id=? AND emp_id=? AND date=? ORDER BY id DESC LIMIT 1`,[companyId,eid,d]);
  if(rows[0]){
    const values={...rows[0]};
    if(check_in) values.check_in=normalizeTime(check_in);
    if(check_out) values.check_out=normalizeTime(check_out);
    if(check_type) values.check_type=check_type;
    if(lat!=null) values.lat=lat;if(lng!=null)values.lng=lng;
    if(face_matched!=null)values.face_matched=face_matched?1:0;
    if(remarks)values.remarks=remarks;if(status)values.status=status;
    await db.query(`UPDATE smart_attendance SET check_in=?,check_out=?,check_type=?,status=?,lat=?,lng=?,face_matched=?,remarks=? WHERE id=?`,
      [values.check_in,values.check_out,values.check_type,values.status,values.lat,values.lng,values.face_matched,values.remarks,values.id]);
    return values;
  }
  const [r]=await db.query(`INSERT INTO smart_attendance(company_id,emp_id,date,check_in,check_out,check_type,status,lat,lng,face_matched,remarks) VALUES(?,?,?,?,?,?,?,?,?,?,?)`,
    [companyId,eid,d,normalizeTime(check_in)||normalizeTime(new Date().toISOString().slice(11,19)),normalizeTime(check_out),check_type||"WIFI",status,lat??null,lng??null,face_matched?1:0,remarks||null]);
  return {id:r.insertId,company_id:companyId,emp_id:eid,date:d,check_in:normalizeTime(check_in)||new Date().toISOString().slice(11,19),check_out:normalizeTime(check_out),check_type:check_type||"WIFI",status,lat:lat??null,lng:lng??null,face_matched:face_matched?1:0,remarks:remarks||null};
}
router.get("/api/network-status",auth,async(req,res)=>{
  const cid=company(req); const [rows]=await db.query(`SELECT * FROM smart_branches WHERE company_id=? ORDER BY id LIMIT 1`,[cid]);
  return send(res,{success:true,network:rows[0]||null,online:true});
});
router.post("/api/attendance/mark-wifi",auth,async(req,res)=>{
  const r=await upsertPunch(req,{check_type:"WIFI",lat:req.body.lat,lng:req.body.lng,remarks:req.body.remarks});
  await audit(req,"attendance.wifi",{emp_id:r.emp_id}); return send(res,{success:true,attendance:r});
});
router.post("/api/attendance/mark-field",auth,async(req,res)=>{
  const r=await upsertPunch(req,{check_type:"FIELD",lat:req.body.lat,lng:req.body.lng,remarks:req.body.notes||req.body.remarks,status:"PRESENT"});
  if(req.body.client_name) await db.query(`INSERT INTO smart_notifications(company_id,emp_id,type,title,message) VALUES(?,?,?,?,?)`,[req.smartUser.company_id,req.smartUser.emp_id,"FIELD_VISIT","Field visit",`Client: ${req.body.client_name}`]);
  await audit(req,"attendance.field",{emp_id:r.emp_id}); return send(res,{success:true,attendance:r});
});
router.post("/api/attendance/check-in",auth,async(req,res)=>{
  const r=await upsertPunch(req,{check_type:req.body.check_type||"ONLINE",lat:req.body.lat,lng:req.body.lng,face_matched:req.body.face_matched,remarks:req.body.remarks});
  return send(res,{success:true,attendance:r});
});
router.post("/api/attendance/sync-offline",auth,async(req,res)=>{
  const items=Array.isArray(req.body.records)?req.body.records:Array.isArray(req.body.attendance)?req.body.attendance:[];
  const results=[]; for(const item of items){try{results.push(await upsertPunch(req,{...item,check_type:item.check_type||"OFFLINE"}))}catch(e){results.push({error:e.message})}}
  return send(res,{success:true,synced:results.length,results});
});

/* OTP */
router.post("/api/attendance/otp-send",auth,async(req,res)=>{
  const [u]=await db.query(`SELECT id FROM smart_users WHERE id=? AND company_id=?`,[req.smartUser.id,req.smartUser.company_id]);
  if(!u[0])return send(res,{error:"Employee not found"},404);
  const otp=String(Math.floor(100000+Math.random()*900000));
  await db.query(`INSERT INTO smart_attendance_otps(employee_id,otp,expires_at,used) VALUES(?,?,DATE_ADD(NOW(),INTERVAL 5 MINUTE),0)`,[req.smartUser.id,otp]);
  return send(res,{success:true,expires_in:300,...(process.env.NODE_ENV!=="production"?{otp}: {})});
});
router.get("/api/attendance/my-active-otp",auth,async(req,res)=>{
  const [rows]=await db.query(`SELECT id,expires_at,used FROM smart_attendance_otps WHERE employee_id=? AND used=0 AND expires_at>NOW() ORDER BY id DESC LIMIT 1`,[req.smartUser.id]);
  return send(res,{success:true,otp:rows[0]||null});
});
router.post("/api/attendance/otp-verify",auth,async(req,res)=>{
  const {otp}=req.body||{}; const [rows]=await db.query(`SELECT * FROM smart_attendance_otps WHERE employee_id=? AND otp=? AND used=0 AND expires_at>NOW() ORDER BY id DESC LIMIT 1`,[req.smartUser.id,otp||""]);
  if(!rows[0])return send(res,{error:"Invalid or expired OTP"},400);
  await db.query(`UPDATE smart_attendance_otps SET used=1 WHERE id=?`,[rows[0].id]);
  const r=await upsertPunch(req,{check_type:"OTP"});
  return send(res,{success:true,attendance:r});
});

/* face */
router.post("/api/attendance/validate-employee",auth,async(req,res)=>{
  const e=await employeeById(req.smartUser.company_id,req.body.emp_id||req.query.emp_id||req.smartUser.emp_id);
  if(!e)return send(res,{valid:false,error:"Employee not found"},404);
  return send(res,{valid:true,employee:{id:e.id,emp_id:e.emp_id,name:e.name,department:e.department,designation:e.designation,encoding:e.encoding?JSON.parse(e.encoding):null}});
});
router.post("/api/attendance/mark-face",auth,async(req,res)=>{
  const eid=req.body.emp_id||req.smartUser.emp_id;
  const e=await employeeById(req.smartUser.company_id,eid); if(!e)return send(res,{error:"Employee not found"},404);
  let matched=Boolean(req.body.face_matched);
  if(req.body.face_descriptor && e.encoding){try{matched=cosine(req.body.face_descriptor,JSON.parse(e.encoding))>=Number(process.env.SMART_FACE_THRESHOLD||0.52)}catch{}}
  if(!matched)return send(res,{error:"Face not matched",face_matched:false},403);
  const r=await upsertPunch(req,{emp_id:eid,check_type:"FACE",face_matched:true,lat:req.body.lat,lng:req.body.lng});
  return send(res,{success:true,face_matched:true,attendance:r});
});
router.post("/api/register-face",auth,roles("admin","super_admin"),async(req,res)=>{
  const {emp_id,encoding}=req.body||{}; if(!emp_id||!Array.isArray(encoding))return send(res,{error:"emp_id and encoding are required"},400);
  await db.query(`INSERT INTO smart_employee_meta(company_id,emp_id,encoding) VALUES(?,?,?) ON DUPLICATE KEY UPDATE encoding=VALUES(encoding)`,
    [req.smartUser.company_id,emp_id,JSON.stringify(encoding)]);
  return send(res,{success:true});
});

/* company admin */
router.get("/api/company/stats",auth,roles("admin","super_admin"),async(req,res)=>{
  const cid=company(req); if(!sameTenant(req,cid))return send(res,{error:"Forbidden"},403);
  const [[employees]] = await db.query(`SELECT COUNT(*) n FROM smart_users WHERE company_id=? AND role='employee' AND status='active'`,[cid]);
  const [[todayCount]] = await db.query(`SELECT COUNT(*) n FROM smart_attendance WHERE company_id=? AND date=?`,[cid,today()]);
  const [[present]] = await db.query(`SELECT COUNT(*) n FROM smart_attendance WHERE company_id=? AND date=? AND status IN ('PRESENT','LATE','WFH')`,[cid,today()]);
  return send(res,{success:true,stats:{employees:employees.n,today_attendance:todayCount.n,present:present.n,date:today()}});
});
router.get("/api/company/employees",auth,roles("admin","super_admin"),async(req,res)=>{
  const cid=company(req); if(!sameTenant(req,cid))return send(res,{error:"Forbidden"},403);
  const [rows]=await db.query(`SELECT u.id,u.company_id,u.emp_id,u.name,u.email,u.mobile,u.role,u.status,m.department,m.designation,m.work_type,m.timezone FROM smart_users u LEFT JOIN smart_employee_meta m ON m.company_id=u.company_id AND m.emp_id=u.emp_id WHERE u.company_id=? AND u.role='employee' ORDER BY u.id DESC`,[cid]);
  return send(res,{success:true,employees:rows});
});
router.get("/api/company/pending-employees",auth,roles("admin","super_admin"),async(req,res)=>{const cid=company(req);const [rows]=await db.query(`SELECT u.id,u.company_id,u.emp_id,u.name,u.email,u.mobile,u.status FROM smart_users u WHERE u.company_id=? AND u.role='employee' AND u.status<>'active'`,[cid]);return send(res,{success:true,employees:rows});});
router.post("/api/company/pending-employees/:empId/approve",auth,roles("admin","super_admin"),async(req,res)=>{const cid=company(req);await db.query(`UPDATE smart_users SET status='active' WHERE company_id=? AND (emp_id=? OR id=?)`,[cid,req.params.empId,req.params.empId]);return send(res,{success:true});});
router.post("/api/company/pending-employees/:empId/reject",auth,roles("admin","super_admin"),async(req,res)=>{const cid=company(req);await db.query(`UPDATE smart_users SET status='rejected' WHERE company_id=? AND (emp_id=? OR id=?)`,[cid,req.params.empId,req.params.empId]);return send(res,{success:true});});
router.get("/api/company/attendance",auth,roles("admin","super_admin"),async(req,res)=>{const cid=company(req);const [rows]=await db.query(`SELECT * FROM smart_attendance WHERE company_id=? ORDER BY date DESC,id DESC LIMIT 1000`,[cid]);return send(res,{success:true,attendance:rows,records:rows});});
router.get("/api/company/attendance-corrections",auth,roles("admin","super_admin"),async(req,res)=>{const cid=company(req);const [rows]=await db.query(`SELECT * FROM smart_attendance_corrections WHERE company_id=? ORDER BY created_at DESC`,[cid]);return send(res,{success:true,corrections:rows});});
router.post("/api/company/attendance-corrections/:id/review",auth,roles("admin","super_admin"),async(req,res)=>{const cid=company(req);const {status,review_remarks}=req.body||{};if(!["approved","rejected"].includes(status))return send(res,{error:"status must be approved or rejected"},400);const [r]=await db.query(`UPDATE smart_attendance_corrections SET status=?,reviewed_by=?,reviewer_role=?,review_remarks=?,reviewed_at=? WHERE id=? AND company_id=?`,[status,req.smartUser.name,req.smartUser.role,review_remarks||null,new Date().toISOString(),req.params.id,cid]);return send(res,{success:r.affectedRows>0});});
router.get("/api/company/leaves",auth,roles("admin","super_admin"),async(req,res)=>{const cid=company(req);const [rows]=await db.query(`SELECT * FROM smart_leaves WHERE company_id=? ORDER BY start_date DESC`,[cid]);return send(res,{success:true,leaves:rows});});
router.post("/api/company/leaves/:id/review",auth,roles("admin","super_admin"),async(req,res)=>{const cid=company(req);const {status}=req.body||{};if(!["APPROVED","REJECTED"].includes(status))return send(res,{error:"Invalid status"},400);const [r]=await db.query(`UPDATE smart_leaves SET status=? WHERE id=? AND company_id=?`,[status,req.params.id,cid]);return send(res,{success:r.affectedRows>0});});
router.get("/api/company/branches",auth,roles("admin","super_admin"),async(req,res)=>{const [rows]=await db.query(`SELECT * FROM smart_branches WHERE company_id=? ORDER BY id`,[company(req)]);return send(res,{success:true,branches:rows});});
router.post("/api/company/branches",auth,roles("admin","super_admin"),async(req,res)=>{const {branch_id,name,lat,lng,radius_m,subnet}=req.body||{};const [r]=await db.query(`INSERT INTO smart_branches(branch_id,company_id,name,lat,lng,radius_m,subnet) VALUES(?,?,?,?,?,?,?)`,[branch_id,company(req),name,lat??null,lng??null,radius_m??50,subnet??null]);return send(res,{success:true,id:r.insertId},201);});
router.delete("/api/company/branches/:id",auth,roles("admin","super_admin"),async(req,res)=>{await db.query(`DELETE FROM smart_branches WHERE id=? AND company_id=?`,[req.params.id,company(req)]);return send(res,{success:true});});
router.get("/api/company/departments",auth,roles("admin","super_admin"),async(req,res)=>{const [rows]=await db.query(`SELECT * FROM smart_departments WHERE company_id=? ORDER BY name`,[company(req)]);return send(res,{success:true,departments:rows});});
router.post("/api/company/departments",auth,roles("admin","super_admin"),async(req,res)=>{const [r]=await db.query(`INSERT INTO smart_departments(company_id,name) VALUES(?,?)`,[company(req),req.body.name]);return send(res,{success:true,id:r.insertId},201);});
router.delete("/api/company/departments/:name",auth,roles("admin","super_admin"),async(req,res)=>{await db.query(`DELETE FROM smart_departments WHERE company_id=? AND name=?`,[company(req),req.params.name]);return send(res,{success:true});});
router.get("/api/company/shifts",auth,roles("admin","super_admin"),async(req,res)=>{const [rows]=await db.query(`SELECT * FROM smart_shifts WHERE company_id=? ORDER BY start_time`,[company(req)]);return send(res,{success:true,shifts:rows});});
router.post("/api/company/shifts",auth,roles("admin","super_admin"),async(req,res)=>{const {shift_id,name,start_time,end_time,grace_minutes}=req.body||{};const [r]=await db.query(`INSERT INTO smart_shifts(shift_id,company_id,name,start_time,end_time,grace_minutes) VALUES(?,?,?,?,?,?)`,[shift_id,company(req),name,start_time||"09:00:00",end_time||"18:00:00",grace_minutes??15]);return send(res,{success:true,id:r.insertId},201);});
router.delete("/api/company/shifts/:id",auth,roles("admin","super_admin"),async(req,res)=>{await db.query(`DELETE FROM smart_shifts WHERE id=? AND company_id=?`,[req.params.id,company(req)]);return send(res,{success:true});});
router.get("/api/company/profile",auth,roles("admin","super_admin"),async(req,res)=>{const [rows]=await db.query(`SELECT * FROM smart_companies WHERE company_id=? LIMIT 1`,[company(req)]);return send(res,{success:true,company:rows[0]||null});});
router.get("/api/company/field-visits",auth,roles("admin","super_admin"),async(req,res)=>{return send(res,{success:true,field_visits:[]});});
router.get("/api/company/ai-insights",auth,roles("admin","super_admin"),async(req,res)=>{return send(res,{success:true,insights:[]});});
router.get("/api/company/export-csv",auth,roles("admin","super_admin"),async(req,res)=>{
  const [rows]=await db.query(`SELECT company_id,emp_id,date,check_in,check_out,check_type,status,lat,lng,face_matched,remarks FROM smart_attendance WHERE company_id=? ORDER BY date DESC`,[company(req)]);
  const esc=v=>`"${String(v??"").replaceAll('"','""')}"`;
  const csv=["company_id,emp_id,date,check_in,check_out,check_type,status,lat,lng,face_matched,remarks",...rows.map(r=>[r.company_id,r.emp_id,r.date,r.check_in,r.check_out,r.check_type,r.status,r.lat,r.lng,r.face_matched,r.remarks].map(esc).join(","))].join("\n");
  res.setHeader("Content-Type","text/csv");res.setHeader("Content-Disposition","attachment; filename=smart-attendance.csv");return res.send(csv);
});

/* super admin */

/* Super Admin provisioning — creates a fully active company + Company Admin */
router.post("/api/superadmin/companies",auth,roles("super_admin"),async(req,res)=>{
  const {
    company_id,
    name,
    country,
    timezone,
    contact_phone,
    admin_password
  } = req.body || {};

  const workspaceId = String(company_id || "").trim().toUpperCase();
  const companyName = String(name || "").trim();
  const headquartersCountry = String(country || "").trim();
  const primaryTimezone = String(timezone || "").trim();
  const contactPhone = String(contact_phone || "").trim();
  const adminPassword = String(admin_password || "");

  if (
    !workspaceId ||
    !companyName ||
    !headquartersCountry ||
    !primaryTimezone ||
    !contactPhone ||
    !adminPassword
  ) {
    return send(res,{
      error:"Workspace ID, company name, country, timezone, contact phone and admin password are required"
    },400);
  }

  if (!/^[A-Z0-9_-]{2,50}$/.test(workspaceId)) {
    return send(res,{
      error:"Workspace Identifier may contain only letters, numbers, hyphens and underscores"
    },400);
  }

  if (adminPassword.length < 8) {
    return send(res,{
      error:"Admin Initial Password must be at least 8 characters"
    },400);
  }

  const conn = await db.getConnection();

  try {
    await conn.beginTransaction();

    const [existingCompany] = await conn.query(
      `SELECT id FROM smart_companies
       WHERE company_id=? OR code=?
       LIMIT 1`,
      [workspaceId,workspaceId]
    );

    if (existingCompany.length) {
      await conn.rollback();
      return send(res,{error:"Workspace Identifier already exists"},409);
    }

    const [existingAdmin] = await conn.query(
      `SELECT id FROM smart_users
       WHERE mobile=?
       LIMIT 1`,
      [contactPhone]
    );

    if (existingAdmin.length) {
      await conn.rollback();
      return send(res,{
        error:"Admin Contact Phone is already registered"
      },409);
    }

    const companyMetadata = JSON.stringify({
      country: headquartersCountry,
      timezone: primaryTimezone,
      contact_phone: contactPhone,
      provisioned_by: "super_admin"
    });

    await conn.query(
      `INSERT INTO smart_companies
       (company_id,name,code,status,metadata)
       VALUES (?,?,?,'active',?)`,
      [
        workspaceId,
        companyName,
        workspaceId,
        companyMetadata
      ]
    );

    const passwordHash = await bcrypt.hash(adminPassword,12);

    const [adminResult] = await conn.query(
      `INSERT INTO smart_users
       (company_id,emp_id,name,email,mobile,password,role,status,metadata)
       VALUES (?,NULL,?,NULL,?,?, 'admin','active',?)`,
      [
        workspaceId,
        companyName,
        contactPhone,
        passwordHash,
        JSON.stringify({
          account_source: "super_admin_provisioning"
        })
      ]
    );

    await conn.commit();

    await audit(req,"company_provisioned",{
      company_id:workspaceId,
      company_name:companyName,
      admin_user_id:adminResult.insertId,
      admin_mobile:contactPhone
    });

    return send(res,{
      success:true,
      message:"Client workspace provisioned successfully",
      company:{
        company_id:workspaceId,
        name:companyName,
        status:"active"
      },
      admin:{
        user_id:adminResult.insertId,
        name:companyName,
        mobile:contactPhone,
        role:"admin",
        status:"active"
      }
    },201);

  } catch(e) {
    try { await conn.rollback(); } catch {}

    console.error(
      "[smart-attendance-v2] company provisioning:",
      e.message
    );

    if (e.code === "ER_DUP_ENTRY") {
      return send(res,{
        error:"Workspace or admin contact already exists"
      },409);
    }

    return send(res,{
      error:"Failed to provision client workspace"
    },500);

  } finally {
    conn.release();
  }
});

router.get("/api/superadmin/companies",auth,roles("super_admin"),async(_req,res)=>{const [rows]=await db.query(`SELECT * FROM smart_companies ORDER BY id DESC`);return send(res,{success:true,companies:rows});});
router.get("/api/superadmin/pending-approvals",auth,roles("super_admin"),async(_req,res)=>{const [rows]=await db.query(`SELECT * FROM smart_companies WHERE status<>'active' ORDER BY id DESC`);return send(res,{success:true,companies:rows});});
router.post("/api/superadmin/companies/:id/approve",auth,roles("super_admin"),async(req,res)=>{await db.query(`UPDATE smart_companies SET status='active' WHERE company_id=? OR id=?`,[req.params.id,req.params.id]);return send(res,{success:true});});
router.post("/api/superadmin/companies/:id/reject",auth,roles("super_admin"),async(req,res)=>{await db.query(`UPDATE smart_companies SET status='suspended' WHERE company_id=? OR id=?`,[req.params.id,req.params.id]);return send(res,{success:true});});
router.post("/api/superadmin/companies/:id/toggle-status",auth,roles("super_admin"),async(req,res)=>{const [r]=await db.query(`UPDATE smart_companies SET status=IF(status='active','inactive','active') WHERE company_id=? OR id=?`,[req.params.id,req.params.id]);return send(res,{success:r.affectedRows>0});});
router.delete("/api/superadmin/companies/:id",auth,roles("super_admin"),async(req,res)=>{await db.query(`DELETE FROM smart_companies WHERE company_id=? OR id=?`,[req.params.id,req.params.id]);return send(res,{success:true});});
router.get("/api/superadmin/analytics",auth,roles("super_admin"),async(_req,res)=>{const [[c]]=await db.query(`SELECT COUNT(*) n FROM smart_companies`);const [[u]]=await db.query(`SELECT COUNT(*) n FROM smart_users`);const [[a]]=await db.query(`SELECT COUNT(*) n FROM smart_attendance`);return send(res,{success:true,analytics:{companies:c.n,users:u.n,attendance:a.n}});});
router.get("/api/superadmin/global-attendance",auth,roles("super_admin"),async(_req,res)=>{const [rows]=await db.query(`SELECT * FROM smart_attendance ORDER BY date DESC,id DESC LIMIT 2000`);return send(res,{success:true,attendance:rows});});
router.get("/api/superadmin/audit-logs",auth,roles("super_admin"),async(_req,res)=>{const [rows]=await db.query(`SELECT * FROM smart_audit_logs ORDER BY id DESC LIMIT 500`);return send(res,{success:true,logs:rows});});
router.post("/api/superadmin/reset-system-data",auth,roles("super_admin"),async(_req,res)=>{return send(res,{error:"Destructive reset is disabled in the production adapter"},403);});

export default router;
