import { db } from "../../../config/db.js";

export const getByEmployee = async (employeeId) => {
  const [rows] = await db.query(
    `
    SELECT
      id,
      user_id AS employeeId,
      title,
      body AS message,
      type,
      link,
      is_read AS isRead,
      created_at AS createdAt
    FROM notifications
    WHERE audience = 'EMPLOYEE' AND user_id = ?
    ORDER BY id DESC
    LIMIT 50
    `,
    [employeeId]
  );
  return rows;
};

export const getUnreadCount = async (employeeId) => {
  const [rows] = await db.query(
    `SELECT COUNT(*) AS count FROM notifications WHERE audience = 'EMPLOYEE' AND user_id = ? AND is_read = 0`,
    [employeeId]
  );
  return rows[0]?.count || 0;
};

export const markRead = async (id, employeeId) => {
  return db.query(
    `UPDATE notifications SET is_read = 1 WHERE id = ? AND audience = 'EMPLOYEE' AND user_id = ?`,
    [id, employeeId]
  );
};

export const markAllRead = async (employeeId) => {
  return db.query(
    `UPDATE notifications SET is_read = 1 WHERE audience = 'EMPLOYEE' AND user_id = ? AND is_read = 0`,
    [employeeId]
  );
};

export const createNotification = async ({ employeeId, title, message, type = "general", link = null }) => {
  return db.query(
    `INSERT INTO notifications (audience, user_id, type, title, body, link, is_read) VALUES ('EMPLOYEE', ?, ?, ?, ?, ?, 0)`,
    [employeeId, type, title, message, link]
  );
};
