import { db } from "../../../config/db.js";

/**
 * Works against the EXISTING SOP schema shared with modules/sop:
 *   sops(title, department, category ENUM('Internal','Client'), description,
 *        current_version, requires_ack, requires_training, is_active,
 *        created_by, created_at, updated_at)
 *   sop_versions(sop_id, version, file_path, file_name, change_note,
 *                uploaded_by, created_at)
 *   sop_acknowledgements(sop_id, version, employee_id,
 *                        ack_type ENUM('Read','Training Completed'),
 *                        acknowledged_at)
 */

const DEPARTMENTS = [
  "HR",
  "Sales",
  "IT",
  "Finance",
  "Operations",
  "Recruitment",
  "Compliance",
];

const toFileUrl = (filePath) =>
  filePath ? "/uploads/sops/" + filePath.split(/[\\/]/).pop() : null;

let clientSopSchemaPromise;

const ensureClientSopSchema = () => {
  if (clientSopSchemaPromise) return clientSopSchemaPromise;

  clientSopSchemaPromise = (async () => {
    await db.query(`CREATE TABLE IF NOT EXISTS sop_version_files (
      id INT AUTO_INCREMENT PRIMARY KEY, sop_id INT NOT NULL, version INT NOT NULL,
      file_kind VARCHAR(50) NULL, file_path VARCHAR(500) NOT NULL, file_name VARCHAR(255) NULL,
      file_size BIGINT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_sop_version(sop_id,version)
    )`);

    const [[c]] = await db.query(
      `SELECT COUNT(*) c FROM information_schema.columns
       WHERE table_schema=DATABASE() AND table_name='sop_versions' AND column_name='file_name'`,
    );
    if (!Number(c?.c)) {
      await db.query(`ALTER TABLE sop_versions ADD COLUMN file_name VARCHAR(255) NULL AFTER file_path`);
    }

    // Older installations may already have sop_version_files with only the
    // original columns. Add the newer nullable columns without destroying data.
    const ensureColumn = async (table, column, definition) => {
      const [[r]] = await db.query(
        `SELECT COUNT(*) c FROM information_schema.columns
         WHERE table_schema=DATABASE() AND table_name=? AND column_name=?`,
        [table, column],
      );
      if (!Number(r?.c)) {
        await db.query(`ALTER TABLE ${table} ADD COLUMN ${column} ${definition}`);
      }
    };

    await ensureColumn("sop_version_files", "file_kind", "VARCHAR(50) NULL");
    await ensureColumn("sop_version_files", "file_name", "VARCHAR(255) NULL");
    await ensureColumn("sop_version_files", "file_size", "BIGINT NULL");

    await db.query(`CREATE TABLE IF NOT EXISTS client_sop_acknowledgements (
      id INT AUTO_INCREMENT PRIMARY KEY, client_id INT NOT NULL, sop_id INT NOT NULL, version INT NOT NULL,
      employee_id INT NOT NULL, status ENUM('accepted','rejected') NOT NULL, note VARCHAR(500) NULL,
      decided_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uq_client_sop_emp_ver(client_id,sop_id,version,employee_id)
    )`);
  })().catch((err) => {
    clientSopSchemaPromise = null;
    throw err;
  });

  return clientSopSchemaPromise;
};

const FIELD_KINDS = {
  reportFile: "report",
  sheetFile: "sheet",
  sourceCodeFile: "source_code",
  videoFile: "video",
  projectReportFile: "project_report",
};

// Collect files from sopMultiUpload (req.files) or legacy single upload (req.file)
const collectUploadedFiles = (req) => {
  const out = [];
  if (req.files && typeof req.files === "object") {
    for (const [field, arr] of Object.entries(req.files)) {
      for (const f of arr) {
        out.push({
          kind: FIELD_KINDS[field] || "other",
          path: f.path,
          name: f.originalname,
          size: f.size,
        });
      }
    }
  }
  if (req.file) {
    out.push({
      kind: "other",
      path: req.file.path,
      name: req.file.originalname,
      size: req.file.size,
    });
  }
  return out;
};

const insertVersionFiles = async (sopId, version, files) => {
  for (const f of files) {
    await db.query(
      `INSERT INTO sop_version_files (sop_id, version, file_kind, file_path, file_name, file_size)
       VALUES (?,?,?,?,?,?)`,
      [sopId, version, f.kind, f.path, f.name, f.size || null],
    );
  }
};

// Fetch current-version files for a list of SOP rows and attach as .files
const attachFiles = async (rows, versionKey = "current_version") => {
  if (!rows.length) return rows;
  const ids = rows.map((r) => r.id);
  const [files] = await db.query(
    `SELECT id, sop_id, version, file_kind, file_path, file_name, file_size
     FROM sop_version_files WHERE sop_id IN (?)`,
    [ids],
  );
  const byKey = {};
  for (const f of files) {
    const k = `${f.sop_id}:${f.version}`;
    (byKey[k] = byKey[k] || []).push({
      id: f.id,
      file_kind: f.file_kind,
      file_name: f.file_name,
      file_size: f.file_size,
      file_url: toFileUrl(f.file_path),
      download_url: `/api/sops/files/${f.id}/download`,
    });
  }
  return rows.map((r) => ({
    ...r,
    files: byKey[`${r.id}:${r[versionKey]}`] || [],
  }));
};

const typeToCategory = (t) =>
  t === "client_template" ? "Client" : "Internal";

/* ============ HR: list all SOPs ============ */
export const getAllSops = async (req, res) => {
  try {
    const { department, sop_type, status } = req.query;

    let sql = `
      SELECT s.id, s.title, s.department, s.description,
        s.category, s.current_version, s.requires_training,
        s.is_active, s.created_at AS createdAt, s.updated_at AS updatedAt,
        (SELECT COUNT(*) FROM sop_acknowledgements a
          WHERE a.sop_id = s.id AND a.version = s.current_version
            AND a.ack_type = 'Read') AS ack_count,
        (SELECT COUNT(*) FROM sop_acknowledgements a
          WHERE a.sop_id = s.id AND a.version = s.current_version
            AND a.ack_type = 'Training Completed') AS trained_count,
        (SELECT COUNT(*) FROM sop_versions v WHERE v.sop_id = s.id) AS version_count,
        (SELECT v.file_path FROM sop_versions v
          WHERE v.sop_id = s.id AND v.version = s.current_version LIMIT 1) AS file_path,
        (SELECT v.file_name FROM sop_versions v
          WHERE v.sop_id = s.id AND v.version = s.current_version LIMIT 1) AS file_name
      FROM sops s WHERE 1=1`;
    const params = [];

    if (department) {
      sql += " AND s.department = ?";
      params.push(department);
    }
    if (sop_type) {
      sql += " AND s.category = ?";
      params.push(typeToCategory(sop_type));
    }
    if (status === "active") sql += " AND s.is_active = 1";
    if (status === "archived") sql += " AND s.is_active = 0";

    sql += " ORDER BY s.updated_at DESC";

    const [rows] = await db.query(sql, params);

    const [[{ total_employees }]] = await db.query(
      "SELECT COUNT(*) AS total_employees FROM employees WHERE isActive = 1",
    );

    const withFiles = await attachFiles(rows);

    res.json({
      departments: DEPARTMENTS,
      total_employees,
      data: withFiles.map((r) => ({
        ...r,
        sop_type: r.category === "Client" ? "client_template" : "internal",
        status: r.is_active ? "active" : "archived",
        file_url: toFileUrl(r.file_path),
      })),
    });
  } catch (err) {
    console.error("getAllSops error:", err);
    res.status(500).json({ message: "Failed to fetch SOPs" });
  }
};

/* ============ HR: create SOP (v1 upload) ============ */
export const createSop = async (req, res) => {
  try {
    const { title, department, description, sop_type, requires_training } =
      req.body;

    if (!title || !String(title).trim()) {
      return res.status(400).json({ message: "Title is required" });
    }
    if (!department || !DEPARTMENTS.includes(department)) {
      return res.status(400).json({ message: "Valid department is required" });
    }
    const uploaded = collectUploadedFiles(req);
    if (!uploaded.length) {
      return res.status(400).json({
        message:
          "At least one file is required (report, sheet, source code, or video)",
      });
    }

    const [result] = await db.query(
      `INSERT INTO sops (title, department, category, description, requires_training, created_by)
       VALUES (?,?,?,?,?,?)`,
      [
        String(title).trim(),
        department,
        typeToCategory(sop_type),
        description || null,
        requires_training === "1" || requires_training === "true" ? 1 : 0,
        req.employee?.name || String(req.employee?.id || "HR"),
      ],
    );

    // legacy pointer row (first file) keeps old consumers working
    await db.query(
      `INSERT INTO sop_versions (sop_id, version, file_path, file_name, change_note, uploaded_by)
       VALUES (?,?,?,?,?,?)`,
      [
        result.insertId,
        1,
        uploaded[0].path,
        uploaded[0].name,
        req.body.notes || "Initial version",
        req.employee?.name || String(req.employee?.id || "HR"),
      ],
    );

    await insertVersionFiles(result.insertId, 1, uploaded);

    res.status(201).json({ id: result.insertId, message: "SOP created" });
  } catch (err) {
    console.error("createSop error:", err);
    res.status(500).json({ message: "Failed to create SOP" });
  }
};

/* ============ HR: upload new version ============ */
export const uploadNewVersion = async (req, res) => {
  try {
    const { id } = req.params;

    const uploaded = collectUploadedFiles(req);
    if (!uploaded.length) {
      return res.status(400).json({
        message:
          "At least one file is required (report, sheet, source code, or video)",
      });
    }

    const [[sop]] = await db.query("SELECT * FROM sops WHERE id = ?", [id]);
    if (!sop) return res.status(404).json({ message: "SOP not found" });

    const newVersion = sop.current_version + 1;

    await db.query(
      `INSERT INTO sop_versions (sop_id, version, file_path, file_name, change_note, uploaded_by)
       VALUES (?,?,?,?,?,?)`,
      [
        id,
        newVersion,
        uploaded[0].path,
        uploaded[0].name,
        req.body.notes || null,
        req.employee?.name || String(req.employee?.id || "HR"),
      ],
    );

    await insertVersionFiles(id, newVersion, uploaded);

    await db.query("UPDATE sops SET current_version = ? WHERE id = ?", [
      newVersion,
      id,
    ]);

    res.json({ message: "New version uploaded", version: newVersion });
  } catch (err) {
    console.error("uploadNewVersion error:", err);
    res.status(500).json({ message: "Failed to upload version" });
  }
};

/* ============ HR: version history ============ */
export const getVersionHistory = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query(
      `SELECT id, sop_id, version AS version_no, file_path, file_name,
              change_note AS notes, uploaded_by AS uploaded_by_name,
              created_at AS createdAt
       FROM sop_versions
       WHERE sop_id = ?
       ORDER BY version DESC`,
      [id],
    );
    // attach per-version files (rows here are versions, keyed by sop_id + version_no)
    const [allFiles] = rows.length
      ? await db.query(
          `SELECT id, sop_id, version, file_kind, file_path, file_name, file_size
           FROM sop_version_files WHERE sop_id = ?`,
          [id],
        )
      : [[]];
    const byVersion = {};
    for (const f of allFiles) {
      (byVersion[f.version] = byVersion[f.version] || []).push({
        id: f.id,
        file_kind: f.file_kind,
        file_name: f.file_name,
        file_size: f.file_size,
        file_url: toFileUrl(f.file_path),
        download_url: `/api/sops/files/${f.id}/download`,
      });
    }

    res.json(
      rows.map((r) => ({
        ...r,
        file_url: toFileUrl(r.file_path),
        files: byVersion[r.version_no] || [],
      })),
    );
  } catch (err) {
    console.error("getVersionHistory error:", err);
    res.status(500).json({ message: "Failed to fetch versions" });
  }
};

/* ============ Download a specific SOP file with its original name ============ */
export const downloadSopFile = async (req, res) => {
  try {
    const { fileId } = req.params;
    let [[file]] = await db.query(
      "SELECT id, sop_id, version, file_path, file_name FROM sop_version_files WHERE id = ?",
      [fileId],
    );

    // Legacy installations use sop_versions and the URL may contain the
    // sop_versions.id instead of a sop_version_files.id.
    if (!file) {
      [[file]] = await db.query(
        "SELECT id, sop_id, version, file_path, file_name FROM sop_versions WHERE id = ?",
        [fileId],
      );
    }
    if (!file) return res.status(404).json({ message: "SOP file not found" });

    const path = await import("path");
    const fs = await import("fs");
    const pathApi = path.default;
    const fsApi = fs.default;
    const raw = String(file.file_path || "").replace(/\\/g, "/");

    // Resolve uploads reliably regardless of whether Node was started from
    // the backend directory, a parent directory, or Hostinger's app root.
    const candidates = [];
    if (raw) {
      if (pathApi.isAbsolute(raw)) candidates.push(raw);
      else {
        candidates.push(pathApi.resolve(process.cwd(), raw));
        candidates.push(pathApi.resolve(process.cwd(), "backend", raw));
        candidates.push(pathApi.resolve(pathApi.dirname(new URL(import.meta.url).pathname), "../../../..", raw));
      }
    }

    let filePath = candidates.find((candidate) => fsApi.existsSync(candidate)) || null;

    // If the database path points to an old/deleted upload, resolve the
    // current bundled SOP template by title or filename.
    let [[sop]] = await db.query(
      "SELECT title, description, department, current_version FROM sops WHERE id = ?",
      [file.sop_id],
    );
    const uploadDirs = [
      pathApi.resolve(process.cwd(), "uploads", "sops"),
      pathApi.resolve(process.cwd(), "backend", "uploads", "sops"),
      pathApi.resolve(pathApi.dirname(new URL(import.meta.url).pathname), "../../../..", "uploads", "sops"),
    ];
    const normalize = (v) => String(v || "").toLowerCase().replace(/[^a-z0-9]+/g, "");
    const wanted = normalize(file.file_name || raw || sop?.title);
    const titleKey = normalize(sop?.title);

    const aliases = [
      ["onboard", "Employee-Onboarding-SOP-Template.pdf"],
      ["performance", "Performance-Management-SOP-Template.pdf"],
      ["leave", "Leave-Policy-SOP-Template.pdf"],
      ["recruit", "Recruitment-SOP-Template.pdf"],
      ["payroll", "Payroll-Attendance-SOP-Template.pdf"],
      ["attendance", "Payroll-Attendance-SOP-Template.pdf"],
    ];

    for (const dir of uploadDirs) {
      if (!fsApi.existsSync(dir)) continue;
      const names = fsApi.readdirSync(dir);
      const exact = names.find((name) => {
        const n = normalize(name);
        return n === wanted || n === titleKey || n.includes(wanted) || wanted.includes(n.replace("pdf", ""));
      });
      const alias = aliases.find(([key]) => titleKey.includes(key) || wanted.includes(key));
      const fallback = exact || alias?.[1];
      if (fallback) {
        const candidate = pathApi.join(dir, fallback);
        if (fsApi.existsSync(candidate)) {
          filePath = candidate;
          break;
        }
      }
    }

    // Last-resort compatibility: old seeded SOPs can have a database row but
    // no physical upload. Create a small, useful text document from the SOP's
    // stored metadata so every published SOP remains downloadable instead of
    // returning a 404.
    if (!filePath) {
      const dir = uploadDirs.find((d) => fsApi.existsSync(d)) || uploadDirs[0];
      fsApi.mkdirSync(dir, { recursive: true });
      const safeBase = String(file.file_name || sop?.title || `sop-${file.sop_id}`)
        .replace(/[^a-z0-9._-]+/gi, "-")
        .replace(/-+/g, "-")
        .replace(/^-|-$/g, "") || `sop-${file.sop_id}`;
      const generatedName = /\.[a-z0-9]{2,5}$/i.test(safeBase) ? safeBase : `${safeBase}.txt`;
      filePath = pathApi.join(dir, generatedName);
      const body = [
        sop?.title || file.file_name || "Standard Operating Procedure",
        `Department: ${sop?.department || "Company"}`,
        `Version: ${file.version || sop?.current_version || 1}`,
        "",
        sop?.description || "This SOP is available in the employee portal.",
        "",
        "This document was restored automatically because the original upload was not present on the server.",
      ].join("\n");
      fsApi.writeFileSync(filePath, body, "utf8");
    }

    return res.download(
      filePath,
      file.file_name || pathApi.basename(filePath),
      (err) => {
        if (err && !res.headersSent) {
          console.error("SOP download stream error:", err);
          res.status(404).json({ message: "SOP file is not available on the server" });
        }
      },
    );
  } catch (err) {
    console.error("downloadSopFile error:", err);
    if (!res.headersSent) res.status(500).json({ message: "Failed to download SOP file" });
  }
};

/* ============ HR: acknowledgement report for one SOP ============ */
export const getAcknowledgements = async (req, res) => {
  try {
    const { id } = req.params;

    const [[sop]] = await db.query("SELECT * FROM sops WHERE id = ?", [id]);
    if (!sop) return res.status(404).json({ message: "SOP not found" });

    const [acks] = await db.query(
      `SELECT a.id, a.employee_id, a.acknowledged_at,
              (SELECT COUNT(*) FROM sop_acknowledgements t
                WHERE t.sop_id = a.sop_id AND t.version = a.version
                  AND t.employee_id = a.employee_id
                  AND t.ack_type = 'Training Completed') AS training_completed,
              e.name, e.employeeCode, d.name AS department_name
       FROM sop_acknowledgements a
       JOIN employees e ON e.id = a.employee_id
       LEFT JOIN departments d ON d.id = e.departmentId
       WHERE a.sop_id = ? AND a.version = ? AND a.ack_type = 'Read'
       ORDER BY a.acknowledged_at DESC`,
      [id, sop.current_version],
    );

    const [pending] = await db.query(
      `SELECT e.id, e.name, e.employeeCode, d.name AS department_name
       FROM employees e
       LEFT JOIN departments d ON d.id = e.departmentId
       WHERE e.isActive = 1
         AND e.id NOT IN (
           SELECT employee_id FROM sop_acknowledgements
           WHERE sop_id = ? AND version = ? AND ack_type = 'Read'
         )
       ORDER BY e.name`,
      [id, sop.current_version],
    );

    res.json({
      sop: {
        id: sop.id,
        title: sop.title,
        version: sop.current_version,
        requires_training: sop.requires_training,
      },
      acknowledged: acks,
      pending,
    });
  } catch (err) {
    console.error("getAcknowledgements error:", err);
    res.status(500).json({ message: "Failed to fetch acknowledgements" });
  }
};

/* ============ HR: archive / restore ============ */
export const setSopStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const isActive = req.body.status === "archived" ? 0 : 1;
    const [result] = await db.query(
      "UPDATE sops SET is_active = ? WHERE id = ?",
      [isActive, id],
    );
    if (result.affectedRows === 0)
      return res.status(404).json({ message: "SOP not found" });
    res.json({ message: isActive ? "SOP restored" : "SOP archived" });
  } catch (err) {
    console.error("setSopStatus error:", err);
    res.status(500).json({ message: "Failed to update status" });
  }
};

/* ============ EMPLOYEE: list active internal SOPs with my state ============ */
export const getEmployeeSops = async (req, res) => {
  try {
    const empId = req.employee?.id || req.employee?.employee_id;

    // Employees only see SOPs for their own department (plus company-wide
    // ones whose department is Operations/Compliance/HR policy).
    const [[emp]] = await db.query(
      `SELECT d.name AS department
         FROM employees e
         LEFT JOIN departments d ON d.id = e.departmentId
        WHERE e.id = ? LIMIT 1`,
      [empId],
    );
    const ownDept = emp?.department || null;
    const visibleDepts = new Set(["HR", "Operations", "Compliance"]);
    if (ownDept) visibleDepts.add(ownDept);
    const deptList = [...visibleDepts];

    const [rows] = await db.query(
      `SELECT s.id, s.title, s.department, s.description, s.requires_training,
              s.current_version, s.updated_at AS updatedAt,
        (SELECT v.file_path FROM sop_versions v
          WHERE v.sop_id = s.id AND v.version = s.current_version LIMIT 1) AS file_path,
        (SELECT v.file_name FROM sop_versions v
          WHERE v.sop_id = s.id AND v.version = s.current_version LIMIT 1) AS file_name,
        (SELECT v.id FROM sop_versions v
          WHERE v.sop_id = s.id AND v.version = s.current_version LIMIT 1) AS legacy_file_id,
        r.acknowledged_at,
        (t.id IS NOT NULL) AS training_completed,
        t.acknowledged_at AS training_completed_at
       FROM sops s
       LEFT JOIN sop_acknowledgements r
         ON r.sop_id = s.id AND r.version = s.current_version
        AND r.employee_id = ? AND r.ack_type = 'Read'
       LEFT JOIN sop_acknowledgements t
         ON t.sop_id = s.id AND t.version = s.current_version
        AND t.employee_id = ? AND t.ack_type = 'Training Completed'
       WHERE s.is_active = 1 AND s.category = 'Internal'
         AND s.department IN (${deptList.map(() => "?").join(",")})
       ORDER BY (r.id IS NULL) DESC, s.updated_at DESC`,
      [empId, empId, ...deptList],
    );

    const withFiles = await attachFiles(rows);

    // Backward compatibility: older SOP records may only have a file in
    // sop_versions. Expose that legacy version id as a downloadable file so
    // employee portals do not fall back to a missing static upload URL.
    res.json(
      withFiles.map((r) => {
        const files = Array.isArray(r.files) ? [...r.files] : [];
        if (!files.length && r.file_path) {
          files.push({
            id: r.legacy_file_id || r.id,
            file_kind: "document",
            file_name: r.file_name || String(r.file_path).split(/[\\/]/).pop(),
            file_size: null,
            file_url: toFileUrl(r.file_path),
            download_url: `/api/sops/files/${r.legacy_file_id || r.id}/download`,
          });
        }
        return {
          ...r,
          files,
          training_completed: r.training_completed ? 1 : 0,
          file_url: toFileUrl(r.file_path),
        };
      }),
    );
  } catch (err) {
    console.error("getEmployeeSops error:", err);
    res.status(500).json({ message: "Failed to fetch SOPs" });
  }
};

/* ============ EMPLOYEE: acknowledge current version ============ */
export const acknowledgeSop = async (req, res) => {
  try {
    const empId = req.employee?.id || req.employee?.employee_id;
    const { id } = req.params;

    const [[sop]] = await db.query(
      "SELECT * FROM sops WHERE id = ? AND is_active = 1",
      [id],
    );
    if (!sop) return res.status(404).json({ message: "SOP not found" });

    const [existing] = await db.query(
      `SELECT id FROM sop_acknowledgements
       WHERE sop_id = ? AND employee_id = ? AND version = ? AND ack_type = 'Read'`,
      [id, empId, sop.current_version],
    );
    if (existing.length) {
      return res.status(409).json({ message: "Already acknowledged" });
    }

    await db.query(
      `INSERT INTO sop_acknowledgements (sop_id, version, employee_id, ack_type)
       VALUES (?,?,?, 'Read')`,
      [id, sop.current_version, empId],
    );

    res.status(201).json({ message: "SOP acknowledged" });
  } catch (err) {
    console.error("acknowledgeSop error:", err);
    res.status(500).json({ message: "Failed to acknowledge" });
  }
};

/* ============ EMPLOYEE: mark training complete ============ */
export const completeTraining = async (req, res) => {
  try {
    const empId = req.employee?.id || req.employee?.employee_id;
    const { id } = req.params;

    const [[sop]] = await db.query(
      "SELECT * FROM sops WHERE id = ? AND is_active = 1",
      [id],
    );
    if (!sop) return res.status(404).json({ message: "SOP not found" });

    const [readAck] = await db.query(
      `SELECT id FROM sop_acknowledgements
       WHERE sop_id = ? AND employee_id = ? AND version = ? AND ack_type = 'Read'`,
      [id, empId, sop.current_version],
    );
    if (!readAck.length) {
      return res
        .status(400)
        .json({ message: "Acknowledge the SOP before completing training" });
    }

    const [existing] = await db.query(
      `SELECT id FROM sop_acknowledgements
       WHERE sop_id = ? AND employee_id = ? AND version = ? AND ack_type = 'Training Completed'`,
      [id, empId, sop.current_version],
    );
    if (existing.length) {
      return res.status(409).json({ message: "Training already recorded" });
    }

    await db.query(
      `INSERT INTO sop_acknowledgements (sop_id, version, employee_id, ack_type)
       VALUES (?,?,?, 'Training Completed')`,
      [id, sop.current_version, empId],
    );

    res.json({ message: "Training marked complete" });
  } catch (err) {
    console.error("completeTraining error:", err);
    res.status(500).json({ message: "Failed to record training" });
  }
};

/* ============ CLIENT PORTAL SOP DECISIONS ============ */
const ensureClientSopAcks = async () => {
  await db.query(`CREATE TABLE IF NOT EXISTS client_sop_acknowledgements (id INT AUTO_INCREMENT PRIMARY KEY, client_id INT NOT NULL, sop_id INT NOT NULL, version INT NOT NULL, employee_id INT NOT NULL, status ENUM('accepted','rejected') NOT NULL, note VARCHAR(500) NULL, decided_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY uq_client_sop_emp_ver (client_id,sop_id,version,employee_id))`);
};
export const decideClientSop = async (req,res) => {
  try {
    await ensureClientSopSchema(); if (!req.employee?.employee_id) return res.status(403).json({success:false,message:'Only employees can accept or reject SOPs here'}); await ensureClientSopAcks(); const id=req.params.id; const status=String(req.body.status||'').toLowerCase(); const note=String(req.body.note||'').trim(); if(!['accepted','rejected'].includes(status)) return res.status(400).json({success:false,message:'Status must be accepted or rejected'}); if(status==='rejected'&&!note)return res.status(400).json({success:false,message:'Please provide a note explaining why you rejected this SOP'}); const [[sop]]=await db.query("SELECT id,current_version FROM sops WHERE id=? AND is_active=1 AND category='Client'",[id]); if(!sop)return res.status(404).json({success:false,message:'SOP not found'}); await db.query(`INSERT INTO client_sop_acknowledgements (client_id,sop_id,version,employee_id,status,note) VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE status=VALUES(status),note=VALUES(note),decided_at=CURRENT_TIMESTAMP`,[req.employee.client_id,sop.id,sop.current_version,req.employee.employee_id,status,note||null]); res.json({success:true,message:status==='accepted'?'SOP accepted':'SOP rejected'}); } catch(e){res.status(500).json({success:false,message:e.message})}
};

/* ============ CLIENT: SOP formats for admin + employee portal ============ */
export const getClientSopLibrary = async (req, res) => {
  try {
    await ensureClientSopSchema(); const isEmp=Boolean(req.employee?.employee_id); if(isEmp) await ensureClientSopAcks(); const join=isEmp?`LEFT JOIN client_sop_acknowledgements a ON a.sop_id=s.id AND a.version=s.current_version AND a.employee_id=? AND a.client_id=?`:`LEFT JOIN client_sop_acknowledgements a ON 1=0`; const params=isEmp?[req.employee.employee_id,req.employee.client_id]:[]; const [rows]=await db.query(`SELECT s.id,s.title,s.department,s.description,s.current_version,s.updated_at AS updatedAt,(SELECT v.file_path FROM sop_versions v WHERE v.sop_id=s.id AND v.version=s.current_version LIMIT 1) file_path,(SELECT v.file_name FROM sop_versions v WHERE v.sop_id=s.id AND v.version=s.current_version LIMIT 1) file_name,a.status employee_decision,a.note employee_note,a.decided_at employee_decided_at FROM sops s ${join} WHERE s.is_active=1 AND s.category='Client' ORDER BY s.department,s.title`,params); const withFiles=await attachFiles(rows); res.json(withFiles.map(r=>({...r,file_url:toFileUrl(r.file_path),download_url:r.files?.[0]?.download_url||null}))); } catch(err){console.error('getClientSopLibrary error:',err);res.status(500).json({message:'Failed to fetch SOP library'})}
};
