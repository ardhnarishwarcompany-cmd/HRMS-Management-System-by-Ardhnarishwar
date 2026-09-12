// // workPolicy.service.js
// import {db} from "../../../config/db.js";

// export const getAllPolicies = async () => {
//   const [rows] = await db.query("SELECT * FROM work_policies ORDER BY id DESC");
//   return rows;
// };

// export const createPolicy = async (data) => {
//   const {
//     title,
//     type,
//     departmentId,
//     description,
//     isActive,
//     isAutomated,
//     autoDeduction,
//     autoApply,
//   } = data;

//   const [result] = await db.query(
//     `INSERT INTO work_policies 
//     (title, type, departmentId, description, isActive, isAutomated, autoDeduction, autoApply)
//     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
//     [
//       title,
//       type,
//       departmentId,
//       description,
//       isActive,
//       isAutomated,
//       autoDeduction,
//       autoApply,
//     ]
//   );

//   const [rows] = await db.query(
//     "SELECT * FROM work_policies WHERE id = ?",
//     [result.insertId]
//   );

//   return rows[0];
// };

// export const updatePolicy = async (id, data) => {
//   const {
//     title,
//     type,
//     departmentId,
//     description,
//     isActive,
//     isAutomated,
//     autoDeduction,
//     autoApply,
//   } = data;

//   await db.query(
//     `UPDATE work_policies SET 
//       title=?, type=?, departmentId=?, description=?, 
//       isActive=?, isAutomated=?, autoDeduction=?, autoApply=?
//      WHERE id=?`,
//     [
//       title,
//       type,
//       departmentId,
//       description,
//       isActive,
//       isAutomated,
//       autoDeduction,
//       autoApply,
//       id,
//     ]
//   );

//   const [rows] = await db.query(
//     "SELECT * FROM work_policies WHERE id = ?",
//     [id]
//   );

//   return rows[0];
// };

// export const deletePolicy = async (id) => {
//   await db.query("DELETE FROM work_policies WHERE id = ?", [id]);
// };






import { db } from "../../../config/db.js";

// ✅ GET
export const getAllPolicies = async (clientId) => {
  const [rows] = await db.query(
    `SELECT * FROM work_policies
     WHERE client_id = ? OR client_id = 0
     ORDER BY id DESC`,
    [clientId]
  );

  const [globalPolicies] = await db.query(
    `SELECT id, title, category, description, is_active, created_at, updated_at
     FROM policies ORDER BY id DESC`
  );
  const existingTitles = new Set(rows.map((p) => String(p.title || "").trim().toLowerCase()));
  for (const p of globalPolicies) {
    const key = String(p.title || "").trim().toLowerCase();
    if (!key || existingTitles.has(key)) continue;
    rows.push({
      id: `sa-${p.id}`, client_id: 0, title: p.title, category: p.category,
      description: p.description || "", status: p.is_active ? "active" : "archived",
      isActive: p.is_active ? 1 : 0, isAutomated: 1, autoApply: p.auto_apply ? 1 : 0,
      policy_code: `SA-POL-${p.id}`, effective_date: p.created_at,
      createdAt: p.created_at, updatedAt: p.updated_at, departmentId: 0, type: "general",
    });
  }
  return rows;
};

// ✅ CREATE
export const createPolicy = async (data) => {
  const { client_id, title, description } = data;

  const [result] = await db.query(
    `INSERT INTO work_policies (client_id, title, description)
     VALUES (?, ?, ?)`,
    [client_id, title, description]
  );

  return { id: result.insertId, ...data };
};

// ✅ UPDATE (SECURE)
export const updatePolicy = async (id, clientId, data) => {
  const { title, description } = data;

  await db.query(
    `UPDATE work_policies 
     SET title = ?, description = ?
     WHERE id = ? AND client_id = ?`,
    [title, description, id, clientId]
  );

  return { id, ...data };
};

// ✅ DELETE (SECURE)
export const deletePolicy = async (id, clientId) => {
  await db.query(
    `DELETE FROM work_policies 
     WHERE id = ? AND client_id = ?`,
    [id, clientId]
  );
};