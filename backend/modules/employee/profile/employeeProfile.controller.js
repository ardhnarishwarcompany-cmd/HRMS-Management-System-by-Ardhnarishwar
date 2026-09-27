import bcrypt from "bcryptjs";
import fs from "fs";
import path from "path";
import { asyncHandler } from "../../../utils/asyncHandler.js";
import { db } from "../../../config/db.js";

const bad = (res, message, status = 400) => res.status(status).json({ success: false, message });

const fileUrl = (p) => {
  if (!p) return null;
  if (/^https?:\/\//i.test(p)) return p;
  const rel = String(p).replace(/\\/g, "/").replace(/^.*?uploads\//, "");
  return `/uploads/${rel}`;
};

const EDUCATION_LEVELS = [
  ["10th", "qualification10", "board10", "year10", "percent10"],
  ["12th", "qualification12", "board12", "year12", "percent12"],
  ["Graduation", "qualification_grad", "university_grad", "year_grad", "percent_grad"],
  ["Post-graduation", "qualification_pg", "university_pg", "year_pg", "percent_pg"],
];

/**
 * One read model for the employee's own profile: employees row + joining form +
 * education + documents + EVS status. Everything is scoped by the JWT id.
 */
export const getMyProfile = asyncHandler(async (req, res) => {
  const employeeId = req.employee.id;

  // Profile is an employee self-service endpoint. Older HRMS databases may not
  // have the newer optional profile/EVS tables yet, so only query columns/tables
  // that actually exist instead of turning the whole profile request into 500.
  const [employeeColumns] = await db.query(`
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'employees'
  `);
  const employeeColumnSet = new Set(employeeColumns.map((c) => c.COLUMN_NAME));
  const employeeFields = [
    'id', 'employeeCode', 'joiningId', 'name', 'email', 'phone', 'avatar', 'address',
    'emergency_name', 'emergency_relation', 'emergency_mobile',
    'joiningDate', 'isActive', 'createdAt', 'updatedAt', 'departmentId', 'designationId', 'statusId',
  ];
  const selectEmployeeFields = employeeFields
    .filter((c) => employeeColumnSet.has(c))
    .map((c) => `e.${c}`)
    .join(', ');

  const [[emp]] = await db.query(
    `SELECT ${selectEmployeeFields || 'e.id, e.name, e.email'} ,
            d.name AS department, ds.name AS designation, s.name AS status
       FROM employees e
       LEFT JOIN departments d ON d.id = e.departmentId
       LEFT JOIN designations ds ON ds.id = e.designationId
       LEFT JOIN employee_statuses s ON s.id = e.statusId
      WHERE e.id = ? LIMIT 1`,
    [employeeId],
  );
  if (!emp) return bad(res, "Employee not found", 404);

  let joining = null;
  if (emp.joiningId) {
    try {
      const [[jf]] = await db.query(`SELECT * FROM joining_forms WHERE id = ? LIMIT 1`, [emp.joiningId]);
      joining = jf || null;
    } catch (err) {
      console.warn("Employee profile: joining form unavailable:", err.message);
    }
  }

  let documents = [];
  try {
    const [rows] = await db.query(
      `SELECT id, doc_type, file_path, status, remarks, verified_at, created_at
         FROM verification_documents WHERE employee_id = ? ORDER BY created_at DESC`,
      [employeeId],
    );
    documents = rows;
  } catch (err) {
    console.warn("Employee profile: verification documents unavailable:", err.message);
  }

  let identity = null;
  try {
    const [[row]] = await db.query(
      `SELECT aadhaar_masked, pan_masked, aadhaar_status, pan_status, remarks, updated_at
         FROM evs_identity_verifications WHERE employee_id = ? ORDER BY updated_at DESC LIMIT 1`,
      [employeeId],
    );
    identity = row || null;
  } catch (err) {
    console.warn("Employee profile: EVS identity table unavailable:", err.message);
  }

  let background = [];
  try {
    // Correct HRMS EVS table name is evs_background_verifications.
    const [rows] = await db.query(
      `SELECT previous_company, status, rehire_eligible, created_at
         FROM evs_background_verifications WHERE employee_id = ? ORDER BY created_at DESC`,
      [employeeId],
    );
    background = rows;
  } catch (err) {
    console.warn("Employee profile: EVS background table unavailable:", err.message);
  }

  const education = joining
    ? EDUCATION_LEVELS.map(([level, q, b, y, p]) => ({
        level,
        qualification: joining[q] || null,
        institution: joining[b] || null,
        year: joining[y] || null,
        score: joining[p] || null,
      })).filter((r) => r.qualification || r.institution || r.year || r.score)
    : [];

  const docStates = documents.map((d) => String(d.status || "").toLowerCase());
  const idStates = identity ? [identity.aadhaar_status, identity.pan_status].map((s) => String(s || "").toLowerCase()) : [];
  const bgStates = background.map((b) => String(b.status || "").toLowerCase());
  const all = [...docStates, ...idStates, ...bgStates].filter(Boolean);
  const overall = !all.length
    ? "not_started"
    : all.some((s) => /reject|fail/.test(s))
      ? "attention"
      : all.every((s) => /verified|approved|complete/.test(s))
        ? "verified"
        : "in_progress";

  const joiningAddress = joining
    ? [joining.present_address, joining.present_city, joining.present_state, joining.present_pincode].filter(Boolean).join(", ")
    : "";

  res.json({
    success: true,
    data: {
      employee: {
        id: emp.id,
        employeeCode: emp.employeeCode ?? null,
        name: emp.name,
        email: emp.email,
        phone: emp.phone ?? null,
        avatar: fileUrl(emp.avatar) || fileUrl(joining?.photo),
        avatarUpdatedAt: emp.updatedAt || null,
        address: emp.address ?? (joiningAddress || null),
        emergency: {
          name: emp.emergency_name ?? joining?.emergency_name ?? null,
          relation: emp.emergency_relation ?? joining?.emergency_relation ?? null,
          mobile: emp.emergency_mobile ?? joining?.emergency_mobile ?? null,
        },
        department: emp.department ?? null,
        designation: emp.designation ?? null,
        status: emp.status ?? null,
        joiningDate: emp.joiningDate ?? null,
        isActive: emp.isActive === undefined ? true : emp.isActive === 1,
        memberSince: emp.createdAt ?? null,
      },
      personal: joining
        ? {
            fullName: joining.full_name,
            fatherName: joining.father_name,
            motherName: joining.mother_name,
            dob: joining.dob,
            gender: joining.gender,
            maritalStatus: joining.marital_status,
            bloodGroup: joining.blood_group,
            nationality: joining.nationality,
            altMobile: joining.alt_mobile,
          }
        : null,
      experience: joining
        ? {
            type: joining.experience_type,
            total: joining.total_experience,
            lastCompany: joining.last_company,
            lastDesignation: joining.last_designation,
          }
        : null,
      bank: joining
        ? {
            holder: joining.account_holder,
            bank: joining.bank_name,
            accountMasked: joining.account_number ? `XXXX${String(joining.account_number).slice(-4)}` : null,
            ifsc: joining.ifsc,
            branch: joining.branch,
          }
        : null,
      education,
      documents: documents.map((d) => ({ ...d, file_url: fileUrl(d.file_path) })),
      verification: {
        overall,
        identity,
        background,
        documentsTotal: documents.length,
        documentsVerified: docStates.filter((s) => /verified|approved/.test(s)).length,
      },
    },
  });
});

const PHONE_RE = /^[0-9+\-\s()]{7,20}$/;

export const updateMyProfile = asyncHandler(async (req, res) => {
  const employeeId = req.employee.id;
  const { phone, address, emergency } = req.body || {};
  const patch = {};

  if (phone !== undefined) {
    if (phone && !PHONE_RE.test(String(phone))) return bad(res, "Enter a valid phone number");
    patch.phone = phone ? String(phone).trim() : null;
  }
  if (address !== undefined) {
    if (address && String(address).length > 500) return bad(res, "Address is too long (max 500 characters)");
    patch.address = address ? String(address).trim() : null;
  }
  if (emergency !== undefined) {
    const e = emergency || {};
    if (e.mobile && !PHONE_RE.test(String(e.mobile))) return bad(res, "Enter a valid emergency contact number");
    patch.emergency_name = e.name ? String(e.name).trim().slice(0, 120) : null;
    patch.emergency_relation = e.relation ? String(e.relation).trim().slice(0, 60) : null;
    patch.emergency_mobile = e.mobile ? String(e.mobile).trim() : null;
  }
  if (!Object.keys(patch).length) return bad(res, "Nothing to update");

  // Production databases can be on different migration levels. Only update
  // columns that actually exist; this prevents an optional field such as
  // `address` from making the entire profile save fail with MySQL 1054.
  const [columnRows] = await db.query(`
    SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'employees'
  `);
  let available = new Set(columnRows.map((r) => r.COLUMN_NAME));
  const missingDefinitions = {
    address: "VARCHAR(500) NULL",
    emergency_name: "VARCHAR(120) NULL",
    emergency_relation: "VARCHAR(60) NULL",
    emergency_mobile: "VARCHAR(30) NULL",
  };
  for (const [column, definition] of Object.entries(missingDefinitions)) {
    if (patch[column] !== undefined && !available.has(column)) {
      try {
        await db.query(`ALTER TABLE employees ADD COLUMN \`${column}\` ${definition}`);
        available.add(column);
      } catch (schemaErr) {
        console.warn(`Could not add optional profile column ${column}:`, schemaErr.message);
      }
    }
  }
  const safePatch = Object.fromEntries(Object.entries(patch).filter(([key]) => available.has(key)));
  if (!Object.keys(safePatch).length) {
    return bad(res, "Profile fields are not available in the current database. Please run the latest HRMS migration.", 409);
  }

  const cols = Object.keys(safePatch);
  const updatedAt = available.has("updatedAt") ? ", updatedAt = NOW()" : "";
  await db.query(
    `UPDATE employees SET ${cols.map((c) => `\`${c}\` = ?`).join(", ")}${updatedAt} WHERE id = ?`,
    [...cols.map((c) => safePatch[c]), employeeId],
  );
  res.json({ success: true, message: "Profile updated", updated: cols });
});

export const updateMyAvatar = asyncHandler(async (req, res) => {
  const employeeId = req.employee.id;
  if (!req.file) return bad(res, "Choose an image to upload");
  if (!/^image\/(png|jpe?g|webp)$/i.test(req.file.mimetype)) {
    fs.unlink(req.file.path, () => {});
    return bad(res, "Only PNG, JPG or WEBP images are allowed");
  }

  const [columnRows] = await db.query(`
    SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'employees'
  `);
  const available = new Set(columnRows.map((r) => r.COLUMN_NAME));
  if (!available.has("avatar")) {
    try {
      await db.query("ALTER TABLE employees ADD COLUMN `avatar` VARCHAR(500) NULL");
      available.add("avatar");
    } catch (schemaErr) {
      fs.unlink(req.file.path, () => {});
      return bad(res, "Profile photo is not enabled in the current database and could not be added automatically.", 409);
    }
  }

  const [[prev]] = await db.query(`SELECT avatar FROM employees WHERE id = ?`, [employeeId]);
  const rel = path.relative(process.cwd(), req.file.path).replace(/\\/g, "/");
  const updatedAt = available.has("updatedAt") ? ", updatedAt = NOW()" : "";
  await db.query(`UPDATE employees SET avatar = ?${updatedAt} WHERE id = ?`, [rel, employeeId]);

  if (prev?.avatar && !/^https?:/i.test(prev.avatar)) {
    const oldPath = path.isAbsolute(prev.avatar) ? prev.avatar : path.join(process.cwd(), prev.avatar);
    fs.unlink(oldPath, () => {});
  }
  res.json({ success: true, message: "Photo updated", avatar: fileUrl(rel), avatarUpdatedAt: new Date().toISOString() });
});

export const changeMyPassword = asyncHandler(async (req, res) => {
  const employeeId = req.employee.id;
  const { currentPassword, newPassword } = req.body || {};
  if (!currentPassword || !newPassword) return bad(res, "Current and new password are required");
  if (String(newPassword).length < 8) return bad(res, "New password must be at least 8 characters");
  if (currentPassword === newPassword) return bad(res, "New password must be different from the current one");

  const [[row]] = await db.query(`SELECT password_hash FROM employees WHERE id = ? AND isActive = 1`, [employeeId]);
  if (!row) return bad(res, "Employee not found", 404);
  const ok = await bcrypt.compare(String(currentPassword), row.password_hash);
  if (!ok) return bad(res, "Current password is incorrect", 401);

  const hash = await bcrypt.hash(String(newPassword), 10);
  await db.query(`UPDATE employees SET password_hash = ?, updatedAt = NOW() WHERE id = ?`, [hash, employeeId]);
  res.json({ success: true, message: "Password changed" });
});
