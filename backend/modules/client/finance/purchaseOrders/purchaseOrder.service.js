import { db } from "../../../../config/db.js";

// GET
export const fetchOrders = async (clientId, employeeId = null) => {
  const where = employeeId ? `WHERE client_id = ? AND created_by_employee_id = ?` : `WHERE client_id = ?`;
  const params = employeeId ? [clientId, employeeId] : [clientId];
  const [rows] = await db.query(
    `SELECT * FROM purchase_orders ${where} ORDER BY id DESC`,
    params,
  );

  // parse JSON
  return rows.map((row) => ({
    ...row,
    items:
      typeof row.items === "string" ? JSON.parse(row.items) : row.items || [],
  }));
};

// CREATE
export const createNewOrder = async (data) => {
  const { client_id, vendor_name, items, total_amount, order_date, created_by_employee_id = null } = data;

  const [result] = await db.query(
    `INSERT INTO purchase_orders 
     (client_id, vendor_name, items, total_amount, order_date, created_by_employee_id)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [client_id, vendor_name, JSON.stringify(items), total_amount, order_date, created_by_employee_id],
  );

  return { id: result.insertId, ...data };
};

// UPDATE STATUS
export const ALLOWED_STATUS_TRANSITIONS = {
  pending: ["approved", "rejected"],
  approved: ["completed"],
};

export const updateStatus = async (id, clientId, status) => {
  const [rows] = await db.query(
    `SELECT status FROM purchase_orders WHERE id = ? AND client_id = ? LIMIT 1`,
    [id, clientId],
  );
  if (!rows.length) {
    const err = new Error("Purchase order not found");
    err.status = 404;
    throw err;
  }

  const current = String(rows[0].status || "pending").toLowerCase();
  const next = String(status || "").toLowerCase();
  const allowed = ALLOWED_STATUS_TRANSITIONS[current] || [];
  if (!allowed.includes(next)) {
    const err = new Error(`Cannot move order from "${current}" to "${next}"`);
    err.status = 409;
    throw err;
  }

  await db.query(
    `UPDATE purchase_orders SET status = ?
     WHERE id = ? AND client_id = ?`,
    [next, id, clientId],
  );

  return { id, status: next };
};

// DELETE
export const deleteOrderById = async (id, clientId) => {
  await db.query(`DELETE FROM purchase_orders WHERE id = ? AND client_id = ?`, [
    id,
    clientId,
  ]);
};
