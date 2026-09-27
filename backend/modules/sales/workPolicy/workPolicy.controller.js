import { db } from "../../../config/db.js";
import PDFDocument from "pdfkit";

/* =========================================
GET POLICIES (SALES - VIEW ONLY)
========================================= */
export const getPolicies = async (req, res) => {
  try {
    const { category, status } = req.query;

    let query = `
      SELECT 
        wp.id,
        wp.title,
        wp.category,
        wp.description,
        wp.status,
        wp.effective_date,
        wp.policy_code,
        wp.departmentId,
        wp.createdAt,
        d.name AS department_name
      FROM work_policies wp
      LEFT JOIN departments d ON d.id = wp.departmentId
      WHERE wp.isActive = 1
    `;

    const params = [];

    // filters
    if (category) {
      query += " AND wp.category = ?";
      params.push(category);
    }

    if (status) {
      query += " AND wp.status = ?";
      params.push(status);
    }

    query += " ORDER BY wp.createdAt DESC";

    const [rows] = await db.query(query, params);

    const [globalPolicies] = await db.query(
      `SELECT id, title, category, description, is_active, updated_at AS createdAt, created_at AS effective_date
       FROM policies ORDER BY id DESC`
    );
    const existingTitles = new Set(rows.map((r) => String(r.title || "").trim().toLowerCase()));
    for (const p of globalPolicies) {
      const key = String(p.title || "").trim().toLowerCase();
      if (!key || existingTitles.has(key)) continue;
      rows.push({ id:`sa-${p.id}`, title:p.title, category:p.category, description:p.description,
        status:p.is_active ? "active" : "archived", effective_date:p.effective_date,
        policy_code:`SA-POL-${p.id}`, departmentId:0, createdAt:p.createdAt, department_name:"All" });
    }

    // 🔥 map for frontend compatibility
    const formatted = rows.map((r) => ({
      id: r.id,
      title: r.title,
      category: r.category,
      description: r.description,
      status: r.status,

      // mapping
      effectiveDate: r.effective_date,
      policyId: r.policy_code,
      department: r.department_name || r.departmentId,

      createdAt: r.createdAt,

      // safe defaults (frontend expects)
      rules: [],
      violations: [],
    }));

    res.json({
      success: true,
      data: formatted,
    });
  } catch (err) {
    console.error("GET POLICIES ERROR:", err);
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

export const downloadPolicyPdf = async (req, res) => {
  try {
    const id = String(req.params.id);
    let policy;
    if (id.startsWith("sa-")) {
      const [rows] = await db.query("SELECT id,title,category,description,is_active,created_at FROM policies WHERE id=? LIMIT 1", [Number(id.slice(3))]);
      if (rows.length) policy = { ...rows[0], status: rows[0].is_active ? "active" : "archived", policy_code: `SA-POL-${rows[0].id}` };
    } else {
      const [rows] = await db.query("SELECT wp.*, d.name AS department_name FROM work_policies wp LEFT JOIN departments d ON d.id=wp.departmentId WHERE wp.id=? AND wp.isActive=1 LIMIT 1", [Number(id)]);
      policy = rows[0];
    }
    if (!policy) return res.status(404).json({ success:false, message:"Policy not found" });
    const name = String(policy.title || "Work-Policy").replace(/[^a-z0-9]+/gi, "_").replace(/^_+|_+$/g, "") || "Work-Policy";
    const doc = new PDFDocument({ size:"A4", margin:56 });
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `attachment; filename="${name}.pdf"`);
    doc.pipe(res);
    doc.rect(0,0,595.28,90).fill("#24133f");
    doc.fillColor("#fff").font("Helvetica-Bold").fontSize(20).text("WORK POLICY",56,30);
    doc.y=125;
    doc.fillColor("#3d225f").font("Helvetica-Bold").fontSize(18).text(policy.title || "Work Policy");
    doc.moveDown();
    doc.fillColor("#555").font("Helvetica").fontSize(10).text(`Category: ${policy.category || "General"}`).text(`Status: ${policy.status || "Active"}`).text(`Department: ${policy.department_name || policy.departmentId || "All"}`).text(`Policy Code: ${policy.policy_code || "-"}`);
    doc.moveDown(1.2);
    doc.fillColor("#3d225f").font("Helvetica-Bold").fontSize(12).text("Policy Details");
    doc.moveDown(.5);
    doc.fillColor("#222").font("Helvetica").fontSize(10.5).text(policy.description || "No policy description available.", { width:483, lineGap:4 });
    doc.end();
  } catch (err) {
    console.error("DOWNLOAD SALES WORK POLICY PDF ERROR:", err);
    if (!res.headersSent) res.status(500).json({ success:false, message:err.message });
  }
};
