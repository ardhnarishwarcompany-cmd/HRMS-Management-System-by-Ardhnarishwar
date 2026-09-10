import { db } from "../../config/db.js";
import { logAudit } from "../compliance/compliance.controller.js";

const err = (res, e) => res.status(500).json({ success: false, message: e.message });

const fileUrl = (p) => {
  if (!p) return null;
  if (/^https?:\/\//i.test(String(p))) return p;
  const clean = String(p).replace(/\\/g, "/").replace(/^\/+/, "");
  return `/${clean.startsWith("uploads/") ? clean : `uploads/${clean}`}`;
};

const normalizeDocStatus = (rows, types) => {
  const list = rows.filter((r) => types.some((t) => String(r.doc_type || "").toLowerCase() === t.toLowerCase()));
  if (!list.length) return "Not Submitted";
  if (list.some((r) => r.status === "Rejected")) return "Rejected";
  if (list.every((r) => r.status === "Verified")) return "Verified";
  return "Pending";
};

const ensureEvsEmployee = async (employeeId) => {
  const [[emp]] = await db.query(`SELECT id,name,email,phone,departmentId,designationId FROM employees WHERE id=? LIMIT 1`, [employeeId]);
  if (!emp) return null;
  let department = "", designation = "";
  try {
    const [[d]] = await db.query(`SELECT name FROM departments WHERE id=? LIMIT 1`, [emp.departmentId]);
    const [[ds]] = await db.query(`SELECT name FROM designations WHERE id=? LIMIT 1`, [emp.designationId]);
    department = d?.name || ""; designation = ds?.name || "";
  } catch {}
  try {
    await db.query(
      `INSERT INTO evs_employees (id,name,email,phone,department,designation) VALUES (?,?,?,?,?,?)
       ON DUPLICATE KEY UPDATE name=VALUES(name), email=VALUES(email), phone=VALUES(phone), department=VALUES(department), designation=VALUES(designation)`,
      [emp.id, emp.name, emp.email, emp.phone || "", department, designation],
    );
  } catch (e) {
    // If an older EVS database has not been migrated, the background action will
    // return a useful database error rather than silently losing the case.
    throw e;
  }
  return emp;
};

export const employeeVerificationOverview = async (req, res) => {
  try {
    const [employees] = await db.query(`
      SELECT e.id, e.name, e.email, e.employeeCode, e.avatar, e.isActive,
             d.name AS department, ds.name AS designation
      FROM employees e
      LEFT JOIN departments d ON d.id=e.departmentId
      LEFT JOIN designations ds ON ds.id=e.designationId
      WHERE e.isActive=1 ORDER BY e.name ASC
    `);
    const [docs] = await db.query(`SELECT employee_id, doc_type, status FROM verification_documents ORDER BY created_at DESC`);
    let backgrounds = [];
    try {
      const [rows] = await db.query(`SELECT id, employee_id, previous_company, hr_email, feedback, rehire_eligible, criminal_record, status, created_at FROM evs_background_verifications ORDER BY id DESC`);
      backgrounds = rows;
    } catch {}

    const rows = employees.map((e) => {
      const employeeDocs = docs.filter((d) => Number(d.employee_id) === Number(e.id));
      const bg = backgrounds.find((b) => Number(b.employee_id) === Number(e.id));
      const identityA = normalizeDocStatus(employeeDocs, ["Aadhaar Card"]);
      const identityP = normalizeDocStatus(employeeDocs, ["PAN Card"]);
      const identity_status = identityA === "Rejected" || identityP === "Rejected" ? "Rejected" : identityA === "Verified" && identityP === "Verified" ? "Verified" : identityA === "Not Submitted" && identityP === "Not Submitted" ? "Not Submitted" : "Pending";
      const graduation_status = normalizeDocStatus(employeeDocs, ["Graduation (if any)", "Education Certificate"]);
      const post_graduation_status = normalizeDocStatus(employeeDocs, ["Post Graduation (if any)"]);
      const bank_status = normalizeDocStatus(employeeDocs, ["Bank Details", "Bank Statement"]);
      const documents_status = employeeDocs.length ? (employeeDocs.some(d => d.status === "Rejected") ? "Rejected" : employeeDocs.every(d => d.status === "Verified") ? "Verified" : "Pending") : "Not Submitted";
      const background_status = bg?.status || "Not Submitted";
      const parts = [identity_status, graduation_status, post_graduation_status, bank_status, documents_status, background_status].filter(s => s !== "Not Submitted");
      const overall_status = parts.some(s => s === "Rejected") ? "Rejected" : parts.length && parts.every(s => s === "Verified") ? "Verified" : parts.length ? "Pending" : "Not Submitted";
      return { ...e, profile_image: e.avatar || null, identity_status, graduation_status, post_graduation_status, bank_status, documents_status, background_status, overall_status };
    });
    res.json({ success: true, employees: rows, education_completed: rows.filter(e => e.graduation_status === "Verified" || e.post_graduation_status === "Verified").length, bank_completed: rows.filter(e => e.bank_status === "Verified").length, background_verified: rows.filter(e => e.background_status === "Verified").length });
  } catch (e) { err(res, e); }
};

export const listAdminBackground = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT b.id,b.employee_id,e.name AS employee_name,d.name AS department,b.previous_company,b.hr_email,b.feedback,
             CASE WHEN b.rehire_eligible=1 THEN 'Yes' WHEN b.rehire_eligible=0 THEN 'No' ELSE 'Unknown' END AS rehire_eligible,
             CASE WHEN b.criminal_record=1 THEN 'Yes' WHEN b.criminal_record=0 THEN 'No' ELSE 'Unknown' END AS criminal_record,
             b.status,b.created_at
      FROM evs_background_verifications b
      JOIN employees e ON e.id=b.employee_id
      LEFT JOIN departments d ON d.id=e.departmentId
      ORDER BY b.id DESC
    `);
    res.json({ success: true, backgrounds: rows });
  } catch (e) { err(res, e); }
};

export const createAdminBackground = async (req, res) => {
  try {
    const employeeId = Number(req.body?.employee_id);
    if (!employeeId) return res.status(400).json({ success:false, message:"Employee is required" });
    const employee = await ensureEvsEmployee(employeeId);
    if (!employee) return res.status(404).json({ success:false, message:"Employee not found" });
    const rehire = req.body?.rehire_eligible === "Yes" ? 1 : req.body?.rehire_eligible === "No" ? 0 : null;
    const criminal = req.body?.criminal_record === "Yes" ? 1 : req.body?.criminal_record === "No" ? 0 : null;
    const [r] = await db.query(`INSERT INTO evs_background_verifications (employee_id,previous_company,hr_email,feedback,rehire_eligible,criminal_record,status) VALUES (?,?,?,?,?,?,'Pending')`, [employeeId, String(req.body?.previous_company || "").trim(), String(req.body?.hr_email || "").trim(), String(req.body?.feedback || "").trim(), rehire, criminal]);
    await logAudit(req.user?.name || "Super Admin", "BACKGROUND_CREATE", "Verification", `Background check #${r.insertId} for ${employee.name}`);
    res.status(201).json({ success:true, id:r.insertId, status:"Pending", message:"Background verification created" });
  } catch (e) { err(res, e); }
};

export const updateAdminBackground = async (req, res) => {
  try {
    const id = Number(req.params.id);
    const map = { start:"In Progress", verify:"Verified", reject:"Rejected" };
    const status = map[req.body?.action];
    if (!status) return res.status(400).json({ success:false, message:"Invalid background action" });
    const [[row]] = await db.query(`SELECT id FROM evs_background_verifications WHERE id=?`, [id]);
    if (!row) return res.status(404).json({ success:false, message:"Background check not found" });
    await db.query(`UPDATE evs_background_verifications SET status=?, feedback=CASE WHEN ?<>'' THEN ? ELSE feedback END WHERE id=?`, [status, String(req.body?.remarks || "").trim(), String(req.body?.remarks || "").trim(), id]);
    await logAudit(req.user?.name || "Super Admin", `BACKGROUND_${status.toUpperCase().replace(/ /g,"_")}`, "Verification", `Background check #${id}`);
    res.json({ success:true, message:`Background verification ${status}` });
  } catch (e) { err(res, e); }
};

export const listDocs = async (req, res) => {
  try {
    const { status, employee_id } = req.query;
    const where = [], vals = [];
    if (status) { where.push("status = ?"); vals.push(status); }
    if (employee_id) { where.push("employee_id = ?"); vals.push(employee_id); }
    const [rows] = await db.query(
      `SELECT * FROM verification_documents ${where.length ? "WHERE " + where.join(" AND ") : ""} ORDER BY created_at DESC`,
      vals
    );
    const [[counts]] = await db.query(
      `SELECT SUM(status='Pending') pending, SUM(status='Verified') verified, SUM(status='Rejected') rejected
       FROM verification_documents`
    );
    res.json({ documents: rows.map((r) => ({ ...r, file_url: fileUrl(r.file_path) })), counts });
  } catch (e) { err(res, e); }
};

export const uploadDoc = async (req, res) => {
  try {
    const { employee_id, employee_name, doc_type } = req.body;
    if (!employee_id || !doc_type)
      return res.status(400).json({ success: false, message: "employee and document type are required" });
    const file_path = req.file ? `/uploads/${req.file.filename}` : null;
    const [r] = await db.query(
      "INSERT INTO verification_documents (employee_id, employee_name, doc_type, file_path) VALUES (?,?,?,?)",
      [employee_id, employee_name || "", doc_type, file_path]
    );
    await logAudit(req.user?.name, "UPLOAD", "Verification", `${doc_type} for ${employee_name}`);
    res.status(201).json({ success: true, id: r.insertId });
  } catch (e) { err(res, e); }
};

export const reviewDoc = async (req, res) => {
  try {
    const { status, remarks } = req.body;
    if (!["Verified", "Rejected", "Pending"].includes(status))
      return res.status(400).json({ success: false, message: "Invalid status" });
    await db.query(
      `UPDATE verification_documents SET status = ?, remarks = ?,
        verified_by = CASE WHEN ? IN ('Verified','Rejected') THEN ? ELSE NULL END,
        verified_at = CASE WHEN ? IN ('Verified','Rejected') THEN NOW() ELSE NULL END
       WHERE id = ?`,
      [status, remarks || null, status, req.user?.name || "Admin", status, req.params.id]
    );
    await logAudit(req.user?.name, status.toUpperCase(), "Verification", `Document #${req.params.id}`);
    res.json({ success: true });
  } catch (e) { err(res, e); }
};

export const deleteDoc = async (req, res) => {
  try {
    await db.query("DELETE FROM verification_documents WHERE id = ?", [req.params.id]);
    res.json({ success: true });
  } catch (e) { err(res, e); }
};
