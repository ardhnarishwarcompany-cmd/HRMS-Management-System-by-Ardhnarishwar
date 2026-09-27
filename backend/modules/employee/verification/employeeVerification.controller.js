import fs from "fs";
import path from "path";
import { asyncHandler } from "../../../utils/asyncHandler.js";
import { db } from "../../../config/db.js";

const bad = (res, message, status = 400) =>
  res.status(status).json({ success: false, message });

const fileUrl = (p) => {
  if (!p) return null;
  if (/^https?:\/\//i.test(p)) return p;
  const rel = String(p).replace(/\\/g, "/").replace(/^.*?uploads\//, "");
  return `/uploads/${rel}`;
};



// The EVS module can be deployed into an existing HRMS database.  Older
// databases may not have the EVS tables yet, so make the small set of tables
// used by the employee self-service verification pages available on demand.
let evsSchemaReady = false;
const ensureEvsTables = async () => {
  if (evsSchemaReady) return;
  await db.query(`CREATE TABLE IF NOT EXISTS evs_employees (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(30) DEFAULT '',
    department VARCHAR(100) DEFAULT '',
    designation VARCHAR(120) DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`);
  await db.query(`CREATE TABLE IF NOT EXISTS evs_identity_verifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL UNIQUE,
    aadhaar_masked VARCHAR(20) DEFAULT NULL,
    pan_masked VARCHAR(20) DEFAULT NULL,
    aadhaar_status VARCHAR(40) DEFAULT 'Not Submitted',
    pan_status VARCHAR(40) DEFAULT 'Not Submitted',
    remarks VARCHAR(255) DEFAULT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_evs_identity_employee (employee_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`);
  await db.query(`CREATE TABLE IF NOT EXISTS evs_background_verifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    previous_company VARCHAR(150) DEFAULT '',
    hr_email VARCHAR(150) DEFAULT '',
    feedback TEXT,
    rehire_eligible TINYINT(1) DEFAULT NULL,
    criminal_record TINYINT(1) DEFAULT NULL,
    status VARCHAR(40) DEFAULT 'Pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_evs_background_employee (employee_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`);
  evsSchemaReady = true;
};

const syncEmployee = async (employeeId) => {
  const [[emp]] = await db.query(`
    SELECT e.id, e.name, e.email, e.phone,
           d.name AS department, ds.name AS designation
      FROM employees e
      LEFT JOIN departments d ON d.id=e.departmentId
      LEFT JOIN designations ds ON ds.id=e.designationId
     WHERE e.id=? AND e.isActive=1 LIMIT 1`, [employeeId]);
  if (!emp) return null;

  // Avoid the old email-unique collision which caused the 500 on Identity Details
  // when a legacy EVS record already existed with a different id.
  const [[byId]] = await db.query(`SELECT id FROM evs_employees WHERE id=? LIMIT 1`, [emp.id]);
  const [[byEmail]] = await db.query(`SELECT id FROM evs_employees WHERE email=? LIMIT 1`, [emp.email]);
  if (byId) {
    await db.query(`UPDATE evs_employees SET name=?,email=?,phone=?,department=?,designation=? WHERE id=?`,
      [emp.name, emp.email, emp.phone || '', emp.department || '', emp.designation || '', emp.id]);
  } else if (byEmail) {
    // Keep the legacy row id stable, then move verification records to the HRMS id
    // only when it is safe to do so.  If records already exist, copy their state.
    const legacyId = byEmail.id;
    await db.query(`UPDATE evs_employees SET name=?,phone=?,department=?,designation=? WHERE id=?`,
      [emp.name, emp.phone || '', emp.department || '', emp.designation || '', legacyId]);
    const [[existingIdentity]] = await db.query(`SELECT * FROM evs_identity_verifications WHERE employee_id=? LIMIT 1`, [legacyId]);
    const [existingBg] = await db.query(`SELECT * FROM evs_background_verifications WHERE employee_id=?`, [legacyId]);
    const [[hrIdRow]] = await db.query(`SELECT id FROM evs_employees WHERE id=? LIMIT 1`, [emp.id]);
    if (!hrIdRow && legacyId !== emp.id) {
      await db.query(`UPDATE evs_employees SET email=CONCAT(email,'.legacy.',id) WHERE id=?`, [legacyId]);
      await db.query(`INSERT INTO evs_employees (id,name,email,phone,department,designation) VALUES (?,?,?,?,?,?)`,
        [emp.id, emp.name, emp.email, emp.phone || '', emp.department || '', emp.designation || '']);
      if (existingIdentity) {
        await db.query(`INSERT INTO evs_identity_verifications (employee_id,aadhaar_masked,pan_masked,aadhaar_status,pan_status,remarks) VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE aadhaar_masked=VALUES(aadhaar_masked),pan_masked=VALUES(pan_masked),aadhaar_status=VALUES(aadhaar_status),pan_status=VALUES(pan_status),remarks=VALUES(remarks)`,
          [emp.id, existingIdentity.aadhaar_masked, existingIdentity.pan_masked, existingIdentity.aadhaar_status, existingIdentity.pan_status, existingIdentity.remarks]);
      }
      for (const b of existingBg) {
        await db.query(`INSERT INTO evs_background_verifications (employee_id,previous_company,hr_email,feedback,rehire_eligible,criminal_record,status,created_at) VALUES (?,?,?,?,?,?,?,?)`,
          [emp.id,b.previous_company,b.hr_email,b.feedback,b.rehire_eligible,b.criminal_record,b.status,b.created_at]);
      }
    }
  } else {
    await db.query(`INSERT INTO evs_employees (id,name,email,phone,department,designation) VALUES (?,?,?,?,?,?)`,
      [emp.id, emp.name, emp.email, emp.phone || '', emp.department || '', emp.designation || '']);
  }
  return emp;
};

const allowedExt = new Set([
  ".pdf", ".png", ".jpg", ".jpeg", ".webp", ".doc", ".docx",
]);

export const listMyVerificationDocs = asyncHandler(async (req, res) => {
  const employeeId = Number(req.employee?.id);
  if (!employeeId) return bad(res, "Employee session is invalid", 401);
  await ensureEvsTables();

  const [rows] = await db.query(
    `SELECT id, employee_id, employee_name, doc_type, file_path, status,
            remarks, verified_by, verified_at, created_at
       FROM verification_documents
      WHERE employee_id = ?
      ORDER BY created_at DESC`,
    [employeeId],
  );

  res.json({
    success: true,
    documents: rows.map((row) => ({ ...row, file_url: fileUrl(row.file_path) })),
    counts: {
      total: rows.length,
      pending: rows.filter((r) => r.status === "Pending").length,
      verified: rows.filter((r) => r.status === "Verified").length,
      rejected: rows.filter((r) => r.status === "Rejected").length,
    },
  });
});

export const uploadMyVerificationDoc = asyncHandler(async (req, res) => {
  const employeeId = Number(req.employee?.id);
  if (!employeeId) return bad(res, "Employee session is invalid", 401);
  await ensureEvsTables();

  const docType = String(req.body?.doc_type || "").trim();
  if (!docType) {
    if (req.file?.path) fs.unlink(req.file.path, () => {});
    return bad(res, "Document type is required");
  }
  if (!req.file) return bad(res, "Please select a document to upload");

  const ext = path.extname(req.file.originalname || "").toLowerCase();
  if (!allowedExt.has(ext)) {
    fs.unlink(req.file.path, () => {});
    return bad(res, "Only PDF, JPG, PNG, WEBP, DOC and DOCX files are allowed");
  }

  const [[employee]] = await db.query(
    `SELECT id, name, email FROM employees WHERE id = ? AND isActive = 1 LIMIT 1`,
    [employeeId],
  );
  if (!employee) {
    fs.unlink(req.file.path, () => {});
    return bad(res, "Employee not found or inactive", 404);
  }

  const filePath = req.file.path
    ? path.relative(process.cwd(), req.file.path).replace(/\\/g, "/")
    : null;

  const [result] = await db.query(
    `INSERT INTO verification_documents
      (employee_id, employee_name, doc_type, file_path, status)
     VALUES (?, ?, ?, ?, 'Pending')`,
    [employee.id, employee.name, docType.slice(0, 120), filePath],
  );

  res.status(201).json({
    success: true,
    message: "Document submitted for Super Admin verification",
    id: result.insertId,
    status: "Pending",
    file_url: fileUrl(filePath),
  });
});


const ensureEvsEmployee = async (employeeId) => {
  await ensureEvsTables();
  return syncEmployee(employeeId);
};


export const getMyVerificationStatus = asyncHandler(async (req, res) => {
  const employeeId = Number(req.employee?.id);
  if (!employeeId) return bad(res, "Employee session is invalid", 401);
  const emp = await ensureEvsEmployee(employeeId);
  if (!emp) return bad(res, "Employee not found or inactive", 404);

  const [docs] = await db.query(`SELECT id, doc_type, status, remarks, created_at FROM verification_documents WHERE employee_id=? ORDER BY created_at DESC`, [employeeId]);
  const [[identity]] = await db.query(`SELECT aadhaar_masked, pan_masked, aadhaar_status, pan_status, remarks, updated_at FROM evs_identity_verifications WHERE employee_id=? LIMIT 1`, [employeeId]);
  const [background] = await db.query(`SELECT id, previous_company, hr_email, feedback, rehire_eligible, criminal_record, status, created_at FROM evs_background_verifications WHERE employee_id=? ORDER BY id DESC`, [employeeId]);

  const roll = (rows, ok="Verified") => {
    if (!rows.length) return "Not Submitted";
    if (rows.some(x => x.status === "Rejected")) return "Rejected";
    if (rows.every(x => x.status === ok)) return ok;
    return "Pending";
  };
  const identityStatus = !identity ? "Not Submitted" :
    [identity.aadhaar_status, identity.pan_status].some(x => x === "Rejected") ? "Rejected" :
    identity.aadhaar_status === "Verified" && identity.pan_status === "Verified" ? "Verified" :
    [identity.aadhaar_status, identity.pan_status].some(x => x && x !== "Not Submitted") ? "Pending" : "Not Submitted";
  const backgroundStatus = background[0]?.status || "Not Submitted";
  const documentsStatus = roll(docs);
  const statusForType = (types) => roll(docs.filter(d => types.some(t => String(d.doc_type || "").trim().toLowerCase() === t.toLowerCase())));
  const graduationStatus = statusForType(["Graduation (if any)", "Graduation", "Education Certificate"]);
  const postGraduationStatus = statusForType(["Post Graduation (if any)", "Post Graduation", "Post-graduation"]);
  const bankStatus = statusForType(["Bank Details", "Bank Statement"]);
  const parts = [documentsStatus, identityStatus, backgroundStatus, graduationStatus, postGraduationStatus, bankStatus].filter(x => x !== "Not Submitted");
  const overall = !parts.length ? "Not Started" : parts.includes("Rejected") ? "Action Required" : parts.every(x => x === "Verified") ? "Fully Verified" : "In Progress";

  res.json({
    success: true,
    employee: emp,
    documents: docs,
    identity: identity || null,
    background,
    statuses: {
      documents: documentsStatus,
      identity: identityStatus,
      background: backgroundStatus,
      graduation: graduationStatus,
      postGraduation: postGraduationStatus,
      bank: bankStatus,
      overall,
    },
  });
});

export const getMyIdentity = asyncHandler(async (req, res) => {
  const employeeId = Number(req.employee?.id);
  if (!employeeId) return bad(res, "Employee session is invalid", 401);
  const emp = await ensureEvsEmployee(employeeId);
  if (!emp) return bad(res, "Employee not found or inactive", 404);
  const [[record]] = await db.query(`SELECT id, aadhaar_masked, pan_masked, aadhaar_status, pan_status, remarks, updated_at FROM evs_identity_verifications WHERE employee_id=? LIMIT 1`, [employeeId]);
  res.json({ success: true, employee: emp, record: record || null });
});

export const submitMyIdentity = asyncHandler(async (req, res) => {
  const employeeId = Number(req.employee?.id);
  if (!employeeId) return bad(res, "Employee session is invalid", 401);
  const emp = await ensureEvsEmployee(employeeId);
  if (!emp) return bad(res, "Employee not found or inactive", 404);
  const aadhaar = String(req.body?.aadhaar_number || "").replace(/\s|-/g, "");
  const pan = String(req.body?.pan_number || "").trim().toUpperCase();
  if (!/^\d{12}$/.test(aadhaar) && !/^[A-Z]{5}\d{4}[A-Z]$/.test(pan)) return bad(res, "Enter a valid Aadhaar (12 digits) or PAN (AAAAA9999A)");
  const maskedA = /^\d{12}$/.test(aadhaar) ? `XXXX-XXXX-${aadhaar.slice(-4)}` : null;
  const maskedP = /^[A-Z]{5}\d{4}[A-Z]$/.test(pan) ? `${pan.slice(0,2)}XXX${pan.slice(5,9)}${pan.slice(-1)}` : null;
  const [[existing]] = await db.query(`SELECT id FROM evs_identity_verifications WHERE employee_id=? LIMIT 1`, [employeeId]);
  if (existing) {
    await db.query(`UPDATE evs_identity_verifications SET aadhaar_masked=COALESCE(?,aadhaar_masked), pan_masked=COALESCE(?,pan_masked), aadhaar_status=CASE WHEN ? IS NULL THEN aadhaar_status ELSE 'Pending Approval' END, pan_status=CASE WHEN ? IS NULL THEN pan_status ELSE 'Pending Approval' END WHERE id=?`, [maskedA, maskedP, maskedA, maskedP, existing.id]);
  } else {
    await db.query(`INSERT INTO evs_identity_verifications (employee_id,aadhaar_masked,pan_masked,aadhaar_status,pan_status) VALUES (?,?,?,?,?)`, [employeeId, maskedA, maskedP, maskedA ? "Pending Approval" : "Not Submitted", maskedP ? "Pending Approval" : "Not Submitted"]);
  }
  res.status(201).json({ success:true, message:"Identity details submitted for Super Admin verification" });
});

export const getMyBackground = asyncHandler(async (req, res) => {
  const employeeId = Number(req.employee?.id);
  if (!employeeId) return bad(res, "Employee session is invalid", 401);
  const emp = await ensureEvsEmployee(employeeId);
  if (!emp) return bad(res, "Employee not found or inactive", 404);
  const [rows] = await db.query(`SELECT id, previous_company, hr_email, feedback, rehire_eligible, criminal_record, status, created_at FROM evs_background_verifications WHERE employee_id=? ORDER BY id DESC`, [employeeId]);
  res.json({ success:true, employee:emp, backgrounds:rows });
});

export const submitMyBackground = asyncHandler(async (req, res) => {
  const employeeId = Number(req.employee?.id);
  if (!employeeId) return bad(res, "Employee session is invalid", 401);
  const emp = await ensureEvsEmployee(employeeId);
  if (!emp) return bad(res, "Employee not found or inactive", 404);
  const previousCompany = String(req.body?.previous_company || "").trim();
  if (!previousCompany) return bad(res, "Previous company is required");
  const [r] = await db.query(`INSERT INTO evs_background_verifications (employee_id,previous_company,hr_email,feedback,rehire_eligible,criminal_record,status) VALUES (?,?,?,?,?,?, 'Pending')`, [employeeId, previousCompany, String(req.body?.hr_email || "").trim(), String(req.body?.feedback || "").trim(), req.body?.rehire_eligible === "Yes" ? 1 : req.body?.rehire_eligible === "No" ? 0 : null, req.body?.criminal_record === "Yes" ? 1 : req.body?.criminal_record === "No" ? 0 : null]);
  res.status(201).json({ success:true, id:r.insertId, status:"Pending", message:"Background details submitted for Super Admin verification" });
});
