import { db } from "../../../config/db.js";

// 🔥 CREATE BATCH
export const createBatch = async (fileName, total, userId, assignedTo) => {
  const [res] = await db.query(
    `INSERT INTO lead_batches 
    (file_name, total_records, uploaded_by, assigned_to)
    VALUES (?, ?, ?, ?)`,
    [fileName, total, userId, assignedTo]
  );

  return res.insertId;
};


// 🔥 INSERT LEADS
export const insertLeads = async (leads) => {
  const values = leads.map((l) => [
    l.name,
    l.phone,
    l.batch_id,
    l.assigned_to,
    l.assigned_by,
    new Date(), // assigned_date
  ]);

  await db.query(
    `INSERT INTO leads 
    (name, phone, batch_id, assigned_to, assigned_by, assigned_date)
    VALUES ?`,
    [values]
  );
};
// 🔥 ASSIGN
export const assignLead = async (id, hrId, adminId) => {
  await db.query(
    `UPDATE leads
     SET assigned_to=?, assigned_by=?, assigned_date=NOW()
     WHERE id=?`,
    [hrId, adminId, id]
  );

  // Keep the batch assignment in sync so the HR portal can recover
  // legacy/partially assigned batches as well.
  await db.query(
    `UPDATE lead_batches b
       JOIN leads l ON l.batch_id = b.id
       SET b.assigned_to = ?
     WHERE l.id = ?`,
    [hrId, id]
  );
};

// 🔥 UPDATE LEAD
export const updateLead = async (id, data) => {
  const current = data || {};
  const fields = []; const values = [];
  if (current.name !== undefined) { fields.push("name=?"); values.push(String(current.name).trim()); }
  if (current.phone !== undefined) { fields.push("phone=?"); values.push(String(current.phone).trim()); }
  if (current.status !== undefined) { fields.push("status=?"); values.push(current.status); fields.push("response_date = CASE WHEN ? != 'pending' THEN NOW() ELSE response_date END"); values.push(current.status); }
  if (current.remarks !== undefined) { fields.push("remarks=?"); values.push(current.remarks); }
  if (!fields.length) return false;
  values.push(id);
  const [result] = await db.query(`UPDATE leads SET ${fields.join(", ")} WHERE id=?`, values);
  return result.affectedRows > 0;
};

// 🔥 ALL LEADS (ADMIN)
export const getAllLeads = async () => {
  const [rows] = await db.query(`
    SELECT l.*, e.name as hr_name
    FROM leads l
    LEFT JOIN employees e ON l.assigned_to = e.id
    ORDER BY l.id DESC
  `);

  return rows;
};

// 🔥 HR LEADS
export const getMyLeads = async (hrId) => {
  const [rows] = await db.query(
    `SELECT * FROM leads 
     WHERE assigned_to = ? 
     ORDER BY id DESC`,
    [hrId]
  );

  return rows;
};

export const getAllBatches = async () => {
  try {
const [rows] = await db.query(`
  SELECT 
    b.id,
    b.file_name,
    b.created_at,

    COUNT(l.id) as total,
    SUM(CASE WHEN l.status != 'pending' THEN 1 ELSE 0 END) as completed,

    MAX(e.name) as hr_name

  FROM lead_batches b
  LEFT JOIN leads l ON l.batch_id = b.id
  LEFT JOIN employees e ON l.assigned_to = e.id

  GROUP BY b.id, b.file_name, b.created_at
  ORDER BY b.id DESC
`);

    return rows;
  } catch (err) {
    console.error("BATCH ERROR:", err); // 🔥 VERY IMPORTANT
    throw err;
  }
};

// 🔥 RENAME BATCH (edit)
export const renameBatch = async (id, fileName) => {
  const [result] = await db.query(
    `UPDATE lead_batches SET file_name=? WHERE id=?`,
    [String(fileName).trim(), id]
  );
  return result.affectedRows > 0;
};

// 🔥 DELETE BATCH (and every lead inside it)
export const deleteBatch = async (id) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [[batch]] = await connection.query("SELECT id FROM lead_batches WHERE id=? LIMIT 1", [id]);
    if (!batch) { await connection.rollback(); return false; }
    await connection.query("DELETE FROM leads WHERE batch_id=?", [id]);
    await connection.query("DELETE FROM lead_batches WHERE id=?", [id]);
    await connection.commit();
    return true;
  } catch (err) { await connection.rollback(); throw err; } finally { connection.release(); }
};



export const deleteLead = async (id) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [[lead]] = await connection.query("SELECT id, batch_id FROM leads WHERE id=? LIMIT 1", [id]);
    if (!lead) { await connection.rollback(); return false; }
    await connection.query("DELETE FROM leads WHERE id=?", [id]);
    const [[remaining]] = await connection.query("SELECT COUNT(*) AS total FROM leads WHERE batch_id=?", [lead.batch_id]);
    if (Number(remaining.total) === 0) await connection.query("DELETE FROM lead_batches WHERE id=?", [lead.batch_id]);
    else await connection.query("UPDATE lead_batches SET total_records=? WHERE id=?", [Number(remaining.total), lead.batch_id]);
    await connection.commit(); return true;
  } catch (err) { await connection.rollback(); throw err; } finally { connection.release(); }
};
