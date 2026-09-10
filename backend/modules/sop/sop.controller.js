import { db } from "../../config/db.js";

/* ------------------------------------------------------------------ */
/* Schema                                                              */
/* ------------------------------------------------------------------ */
const ensureTables = async () => {
  await db.query(`
    CREATE TABLE IF NOT EXISTS sops (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(200) NOT NULL,
      department VARCHAR(100) NOT NULL,
      category ENUM('Internal','Client') DEFAULT 'Internal',
      description TEXT NULL,
      current_version INT DEFAULT 1,
      requires_ack TINYINT(1) DEFAULT 1,
      is_active TINYINT(1) DEFAULT 1,
      created_by VARCHAR(120) NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )
  `);
  await db.query(`
    CREATE TABLE IF NOT EXISTS sop_versions (
      id INT AUTO_INCREMENT PRIMARY KEY,
      sop_id INT NOT NULL,
      version INT NOT NULL,
      file_path VARCHAR(255) NULL,
      change_note VARCHAR(255) NULL,
      uploaded_by VARCHAR(120) NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
  await db.query(`
    CREATE TABLE IF NOT EXISTS sop_acknowledgements (
      id INT AUTO_INCREMENT PRIMARY KEY,
      sop_id INT NOT NULL,
      version INT NOT NULL,
      employee_id INT NOT NULL,
      ack_type ENUM('Read','Training Completed') DEFAULT 'Read',
      acknowledged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uq_sop_emp_ver (sop_id, employee_id, version, ack_type)
    )
  `);
};
ensureTables().catch((e) => console.error("sop schema error:", e.message));

/* ------------------------------------------------------------------ */
/* Admin: CRUD + versions                                              */
/* ------------------------------------------------------------------ */
export const createSop = async (req, res) => {
  try {
    const { title, department, category, description, requires_ack } = req.body;
    if (!title || !department)
      return res.status(400).json({ success: false, message: "title and department required" });

    const [r] = await db.query(
      `INSERT INTO sops (title, department, category, description, requires_ack, created_by)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        title,
        department,
        category === "Client" ? "Client" : "Internal",
        description || null,
        requires_ack === false || requires_ack === "false" ? 0 : 1,
        req.user.name || "Admin",
      ]
    );

    const uploadedFile =
  req.files?.reportFile?.[0] ||
  req.files?.sheetFile?.[0] ||
  req.files?.sourceCodeFile?.[0] ||
  req.files?.videoFile?.[0] ||
  req.files?.projectReportFile?.[0];

const filePath = uploadedFile
  ? `sops/${uploadedFile.filename}`
  : null;
    await db.query(
      `INSERT INTO sop_versions (sop_id, version, file_path, change_note, uploaded_by)
       VALUES (?, 1, ?, 'Initial version', ?)`,
      [r.insertId, filePath, req.user.name || "Admin"]
    );

    res.json({ success: true, id: r.insertId });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

export const listSops = async (req, res) => {
  try {
    const { department, category } = req.query;
    let sql = `
      SELECT s.*, v.file_path, v.change_note,
        (SELECT COUNT(*) FROM sop_acknowledgements a
         WHERE a.sop_id = s.id AND a.version = s.current_version AND a.ack_type = 'Read') AS ack_count,
        (SELECT COUNT(*) FROM sop_acknowledgements a
         WHERE a.sop_id = s.id AND a.version = s.current_version AND a.ack_type = 'Training Completed') AS training_count
      FROM sops s
      LEFT JOIN sop_versions v ON v.sop_id = s.id AND v.version = s.current_version
      WHERE s.is_active = 1`;
    const params = [];
    if (department) {
      sql += " AND s.department = ?";
      params.push(department);
    }
    if (category) {
      sql += " AND s.category = ?";
      params.push(category);
    }
    sql += " ORDER BY s.department, s.title";
    const [rows] = await db.query(sql, params);

    const [[{ total }]] = await db.query(
      "SELECT COUNT(*) AS total FROM employees WHERE isActive = 1"
    );
    res.json({ sops: rows, activeEmployees: Number(total) });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

export const uploadNewVersion = async (req, res) => {
  try {
    const [[sop]] = await db.query("SELECT * FROM sops WHERE id = ?", [req.params.id]);
    if (!sop) return res.status(404).json({ success: false, message: "SOP not found" });

    const newVersion = sop.current_version + 1;
const uploadedFile =
  req.files?.reportFile?.[0] ||
  req.files?.sheetFile?.[0] ||
  req.files?.sourceCodeFile?.[0] ||
  req.files?.videoFile?.[0] ||
  req.files?.projectReportFile?.[0];

const filePath = uploadedFile
  ? `sops/${uploadedFile.filename}`
  : null;
    await db.query(
      `INSERT INTO sop_versions (sop_id, version, file_path, change_note, uploaded_by)
       VALUES (?, ?, ?, ?, ?)`,
      [sop.id, newVersion, filePath, req.body.change_note || null, req.user.name || "Admin"]
    );
    await db.query("UPDATE sops SET current_version = ? WHERE id = ?", [newVersion, sop.id]);

    res.json({ success: true, version: newVersion });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

export const sopVersions = async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM sop_versions WHERE sop_id = ? ORDER BY version DESC",
      [req.params.id]
    );
    res.json(rows);
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

export const updateSop = async (req, res) => {
  try {
    const { title, department, category, description, requires_ack } = req.body;
    await db.query(
      `UPDATE sops SET title = COALESCE(?, title), department = COALESCE(?, department),
        category = COALESCE(?, category), description = COALESCE(?, description),
        requires_ack = COALESCE(?, requires_ack)
       WHERE id = ?`,
      [
        title || null,
        department || null,
        category || null,
        description || null,
        requires_ack === undefined ? null : requires_ack ? 1 : 0,
        req.params.id,
      ]
    );
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

export const deleteSop = async (req, res) => {
  try {
    await db.query("UPDATE sops SET is_active = 0 WHERE id = ?", [req.params.id]);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

/* Acknowledgement report for one SOP */
export const ackReport = async (req, res) => {
  try {
    const [[sop]] = await db.query("SELECT * FROM sops WHERE id = ?", [req.params.id]);
    if (!sop) return res.status(404).json({ success: false, message: "SOP not found" });

    const [acks] = await db.query(
      `SELECT a.*, e.name AS employee_name, e.email
       FROM sop_acknowledgements a
       LEFT JOIN employees e ON e.id = a.employee_id
       WHERE a.sop_id = ? AND a.version = ?
       ORDER BY a.acknowledged_at DESC`,
      [sop.id, sop.current_version]
    );

    const [pendingEmployees] = await db.query(
      `SELECT e.id, e.name, e.email FROM employees e
       WHERE e.isActive = 1
         AND e.id NOT IN (
           SELECT employee_id FROM sop_acknowledgements
           WHERE sop_id = ? AND version = ? AND ack_type = 'Read'
         )
       ORDER BY e.name`,
      [sop.id, sop.current_version]
    );

    res.json({ sop, acks, pending: pendingEmployees });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

/* ------------------------------------------------------------------ */
/* Employee: view + acknowledge                                        */
/* ------------------------------------------------------------------ */
export const mySops = async (req, res) => {
  try {
    const empId = req.user.id;
    const [rows] = await db.query(
      `SELECT s.id, s.title, s.department, s.category, s.description, s.current_version,
              s.requires_ack, v.file_path,
        (SELECT COUNT(*) FROM sop_acknowledgements a
         WHERE a.sop_id = s.id AND a.version = s.current_version
           AND a.employee_id = ? AND a.ack_type = 'Read') AS acknowledged,
        (SELECT COUNT(*) FROM sop_acknowledgements a
         WHERE a.sop_id = s.id AND a.version = s.current_version
           AND a.employee_id = ? AND a.ack_type = 'Training Completed') AS training_done
      FROM sops s
      LEFT JOIN sop_versions v ON v.sop_id = s.id AND v.version = s.current_version
      WHERE s.is_active = 1 AND s.category = 'Internal'
      ORDER BY s.department, s.title`,
      [empId, empId]
    );
    res.json(rows);
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

export const acknowledgeSop = async (req, res) => {
  try {
    const { ack_type } = req.body;
    const type = ack_type === "Training Completed" ? "Training Completed" : "Read";
    const [[sop]] = await db.query("SELECT * FROM sops WHERE id = ?", [req.params.id]);
    if (!sop) return res.status(404).json({ success: false, message: "SOP not found" });

    await db.query(
      `INSERT IGNORE INTO sop_acknowledgements (sop_id, version, employee_id, ack_type)
       VALUES (?, ?, ?, ?)`,
      [sop.id, sop.current_version, req.user.id, type]
    );
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};
/* Employee: mark SOP training as completed */
export const completeTraining = async (req, res) => {
  try {
    const [[sop]] = await db.query(
      "SELECT * FROM sops WHERE id = ?",
      [req.params.id]
    );

    if (!sop) {
      return res.status(404).json({
        success: false,
        message: "SOP not found",
      });
    }

    await db.query(
      `INSERT IGNORE INTO sop_acknowledgements
       (sop_id, version, employee_id, ack_type)
       VALUES (?, ?, ?, ?)`,
      [
        sop.id,
        sop.current_version,
        req.user.id,
        "Training Completed",
      ]
    );

    res.json({
      success: true,
      message: "Training completed successfully",
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      message: e.message,
    });
  }
};
/* Employee / Client: download SOP file */
export const downloadSopFile = async (req, res) => {
  try {
    const [[file]] = await db.query(
      `SELECT sv.*, s.title
       FROM sop_versions sv
       LEFT JOIN sops s ON s.id = sv.sop_id
       WHERE sv.id = ?`,
      [req.params.fileId]
    );

    if (!file) {
      return res.status(404).json({
        success: false,
        message: "SOP file not found",
      });
    }

    if (!file.file_path) {
      return res.status(404).json({
        success: false,
        message: "No file available for this SOP version",
      });
    }

    const path = await import("path");
    const fs = await import("fs");

    const filePath = path.join(
      process.cwd(),
      "uploads",
      file.file_path
    );

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        message: "Physical SOP file not found",
      });
    }

    res.download(
      filePath,
      path.basename(filePath),
      (err) => {
        if (err && !res.headersSent) {
          res.status(500).json({
            success: false,
            message: "Unable to download SOP file",
          });
        }
      }
    );
  } catch (e) {
    res.status(500).json({
      success: false,
      message: e.message,
    });
  }
};
/* ------------------------------------------------------------------ */
/* Route compatibility + missing SOP handlers                         */
/* ------------------------------------------------------------------ */

// Existing controller functions ko route names ke saath map karna
export const getAllSops = listSops;
export const getVersionHistory = sopVersions;
export const getAcknowledgements = ackReport;
export const getEmployeeSops = mySops;


/* HR/Admin: change SOP active status */
export const setSopStatus = async (req, res) => {
  try {
    const { is_active } = req.body;

    if (is_active === undefined) {
      return res.status(400).json({
        success: false,
        message: "is_active is required",
      });
    }

    const activeValue =
      is_active === true ||
      is_active === 1 ||
      is_active === "1" ||
      is_active === "true"
        ? 1
        : 0;

    const [result] = await db.query(
      "UPDATE sops SET is_active = ? WHERE id = ?",
      [activeValue, req.params.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "SOP not found",
      });
    }

    res.json({
      success: true,
      message: activeValue ? "SOP activated" : "SOP deactivated",
      is_active: activeValue,
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      message: e.message,
    });
  }
};


/* Client Portal: get Client SOP library */
export const getClientSopLibrary = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT
        s.id,
        s.title,
        s.department,
        s.category,
        s.description,
        s.current_version,
        s.requires_ack,
        v.id AS file_id,
        v.file_path,
        v.change_note,
        v.created_at AS version_created_at
       FROM sops s
       LEFT JOIN sop_versions v
         ON v.sop_id = s.id
        AND v.version = s.current_version
       WHERE s.is_active = 1
         AND s.category = 'Client'
       ORDER BY s.department, s.title`
    );

    res.json({
      success: true,
      sops: rows,
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      message: e.message,
    });
  }
};