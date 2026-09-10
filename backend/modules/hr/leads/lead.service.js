import { db } from "../../../config/db.js";

// Update a lead from the HR portal.
export const updateLead = async (id, data) => {
  const { status, remarks } = data;
  await db.query(
    `UPDATE leads
     SET status=?, remarks=?,
         response_date = CASE WHEN ? != 'pending' THEN NOW() ELSE response_date END
     WHERE id=?`,
    [status, remarks, status, id]
  );
};

// Return only leads assigned to this HR. For legacy batches where the
// individual leads were never populated with assigned_to, the batch
// assignment is used as a safe fallback.
export const getMyLeads = async (hrId) => {
  const [rows] = await db.query(
    `SELECT l.*
       FROM leads l
       LEFT JOIN lead_batches b ON b.id = l.batch_id
      WHERE l.assigned_to = ?
         OR (l.assigned_to IS NULL AND b.assigned_to = ?)
      ORDER BY l.id DESC`,
    [hrId, hrId]
  );
  return rows;
};

// HR batch list. Includes legacy batches assigned at batch level and
// current batches whose individual leads are assigned to this HR.
export const getAllBatches = async (hrId) => {
  const [rows] = await db.query(
    `SELECT
       b.id,
       b.file_name,
       b.created_at,
       COALESCE(
         SUM(CASE
           WHEN l.assigned_to = ? OR (l.assigned_to IS NULL AND b.assigned_to = ?) THEN 1
           ELSE 0
         END), 0
       ) AS total,
       COALESCE(
         SUM(CASE
           WHEN (l.assigned_to = ? OR (l.assigned_to IS NULL AND b.assigned_to = ?))
            AND l.status <> 'pending' THEN 1
           ELSE 0
         END), 0
       ) AS completed,
       MAX(CASE WHEN e.id = ? THEN e.name ELSE NULL END) AS hr_name
     FROM lead_batches b
     LEFT JOIN leads l ON l.batch_id = b.id
     LEFT JOIN employees e ON e.id = l.assigned_to
     WHERE b.assigned_to = ?
        OR EXISTS (SELECT 1 FROM leads lx WHERE lx.batch_id = b.id AND lx.assigned_to = ?)
     GROUP BY b.id, b.file_name, b.created_at
     ORDER BY b.id DESC`,
    [hrId, hrId, hrId, hrId, hrId, hrId, hrId]
  );

  return rows.map((row) => ({
    ...row,
    total: Number(row.total) || 0,
    completed: Number(row.completed) || 0,
  }));
};

export const getLeadsByBatch = async (batchId, hrId) => {
  const [rows] = await db.query(
    `SELECT l.*
       FROM leads l
      WHERE l.batch_id = ?
        AND (l.assigned_to = ? OR l.assigned_to IS NULL AND EXISTS (
          SELECT 1 FROM lead_batches b WHERE b.id = l.batch_id AND b.assigned_to = ?
        ))
      ORDER BY l.id DESC`,
    [batchId, hrId, hrId]
  );
  return rows;
};
