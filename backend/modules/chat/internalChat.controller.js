import jwt from "jsonwebtoken";
import { ENV } from "../../config/env.js";
import { db } from "../../config/db.js";

/*
 * Internal HR <-> IT rooms are private:
 *   hr-it:<hrId>:<itId>
 * Each IT employee therefore gets a separate room with each HR employee.
 *
 * Legacy rooms are still accepted so existing deployments do not lose data.
 */
const LEGACY_ROOMS = ["hr-it", "hr-superadmin", "it-superadmin"];
const DIRECT_ROOM_RE = /^hr-it:(\d+):(\d+)$/;
const HR_HR_ROOM_RE = /^hr-hr:(\d+):(\d+)$/;
const LEGACY_HR_ROOM_RE = /^hr-it:(\d+)$/;

export const internalChatAuth = async (req, res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header?.startsWith("Bearer ")) {
      return res.status(401).json({ success: false, message: "No token provided" });
    }

    const decoded = jwt.verify(header.split(" ")[1], ENV.JWT_SECRET);

    if (String(decoded.role || "").toUpperCase() === "SUPER_ADMIN") {
      req.internalUser = { type: "superadmin", id: Number(decoded.id || 0) };
      return next();
    }

    const employeeId = Number(decoded.employee_id);
    if (!employeeId) {
      return res.status(403).json({ success: false, message: "Internal employee access required" });
    }

    const [[employee]] = await db.query(
      `SELECT e.id, d.name AS department
         FROM employees e
         LEFT JOIN departments d ON d.id = e.departmentId
        WHERE e.id = ? AND e.isActive = 1
        LIMIT 1`,
      [employeeId],
    );

    if (!employee) {
      return res.status(403).json({ success: false, message: "Employee not found" });
    }

    const department = String(employee.department || "").trim().toUpperCase();
    let type = null;
    if (department === "HR" || department.includes("HUMAN RESOURCE")) type = "hr";
    if (department === "IT" || department.includes("INFORMATION TECHNOLOGY")) type = "it";

    if (!type) {
      return res.status(403).json({ success: false, message: "Only HR and IT employees can use internal chat" });
    }

    req.internalUser = { type, id: employeeId };
    next();
  } catch (err) {
    console.error("internal chat auth error:", err);
    return res.status(401).json({ success: false, message: "Invalid or expired token" });
  }
};

const parseRoom = (room) => {
  let m = DIRECT_ROOM_RE.exec(room || "");
  if (m) return { hrId: Number(m[1]), itId: Number(m[2]), legacy: false, kind: "it" };
  m = HR_HR_ROOM_RE.exec(room || "");
  if (m) return { hrA: Number(m[1]), hrB: Number(m[2]), legacy: false, kind: "hr" };
  m = LEGACY_HR_ROOM_RE.exec(room || "");
  if (m) return { hrId: Number(m[1]), itId: null, legacy: true, kind: "it" };
  return null;
};

const canAccess = (room, type, employeeId) => {
  if (room === "hr-it") return type === "hr" || type === "it";
  if (room === "hr-superadmin") return type === "hr" || type === "superadmin";
  if (room === "it-superadmin") return type === "it" || type === "superadmin";

  const parsed = parseRoom(room);
  if (!parsed) return false;

  if (parsed.legacy) {
    return type === "it" || (type === "hr" && Number(employeeId) === parsed.hrId);
  }

  if (parsed.kind === "hr") {
    return type === "hr" && (Number(employeeId) === parsed.hrA || Number(employeeId) === parsed.hrB) || type === "superadmin";
  }
  return (
    (type === "hr" && Number(employeeId) === parsed.hrId) ||
    (type === "it" && Number(employeeId) === parsed.itId) ||
    type === "superadmin"
  );
};

const isValidRoom = (room) =>
  LEGACY_ROOMS.includes(room) || DIRECT_ROOM_RE.test(room || "") || HR_HR_ROOM_RE.test(room || "") || LEGACY_HR_ROOM_RE.test(room || "");

/* HR contacts used by IT portals */
export const getInternalHRs = async (req, res) => {
  try {
    const userId = Number(req.internalUser?.id || 0);
    const userType = req.internalUser?.type;
    if (!userId || !["hr", "it"].includes(userType)) {
      return res.status(403).json({ success: false, message: "Internal employee access required" });
    }

    const [rows] = await db.query(`
      SELECT e.id, e.name, e.email
      FROM employees e
      JOIN departments d ON d.id = e.departmentId
      WHERE UPPER(d.name) = 'HR' AND e.isActive = 1
      ORDER BY e.name ASC
    `);

    const data = rows.map((row) => ({
      ...row,
      room: userType === "it"
        ? `hr-it:${row.id}:${userId}`
        : `hr-hr:${Math.min(row.id, userId)}:${Math.max(row.id, userId)}`,
    })).filter((row) => userType !== "hr" || Number(row.id) !== userId);

    res.json({ success: true, data });
  } catch (err) {
    console.error("internal HR directory error:", err);
    res.status(500).json({ success: false, message: "Unable to load HR contacts" });
  }
};

/*
 * HR portal: only show IT employees who have actually sent a message
 * to the currently logged-in HR. This prevents one shared "IT Team"
 * conversation from exposing unrelated employees/messages.
 */
export const getInternalITContacts = async (req, res) => {
  try {
    const hrId = Number(req.internalUser?.id);
    if (req.internalUser?.type !== "hr" || !hrId) {
      return res.status(403).json({ success: false, message: "HR access required" });
    }

    const [rows] = await db.query(
      `
      SELECT
        e.id,
        e.name,
        e.email,
        CONCAT('hr-it:', ?, ':', e.id) AS room,
        MAX(m.created_at) AS last_message_at
      FROM employees e
      JOIN departments d ON d.id = e.departmentId
      JOIN internal_messages m
        ON m.sender_type = 'it'
       AND m.sender_id = e.id
       AND (
            m.room = CONCAT('hr-it:', ?, ':', e.id)
            OR (m.room = 'hr-it' AND m.recipient_id = ? AND m.sender_id = e.id)
            OR (m.room = CONCAT('hr-it:', ?) AND m.sender_id = e.id)
       )
      WHERE UPPER(d.name) = 'IT'
        AND e.isActive = 1
      GROUP BY e.id, e.name, e.email
      ORDER BY last_message_at DESC, e.name ASC
      `,
      [hrId, hrId, hrId, hrId],
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("internal IT directory error:", err);
    res.status(500).json({ success: false, message: "Unable to load IT contacts" });
  }
};

export const getInternalMessages = async (req, res) => {
  try {
    const { room } = req.params;
    const user = req.internalUser;

    if (!isValidRoom(room)) return res.status(400).json({ success: false, message: "Bad room" });
    if (!canAccess(room, user.type, user.id)) return res.status(403).json({ success: false, message: "No access" });

    let query;
    let params;

    const parsed = parseRoom(room);

    if (parsed?.legacy && user.type === "hr") {
      query = `
        SELECT id, room, sender_type, sender_id, recipient_id, message, created_at
        FROM internal_messages
        WHERE (room = ? AND (recipient_id IS NULL OR recipient_id = ?))
           OR (room = ? AND (sender_id = ? OR recipient_id = ?))
        ORDER BY created_at ASC, id ASC
        LIMIT 500`;
      params = [room, user.id, room, user.id, user.id];
    } else {
      query = `
        SELECT id, room, sender_type, sender_id, recipient_id, message, created_at
        FROM internal_messages
        WHERE room = ?
        ORDER BY created_at ASC, id ASC
        LIMIT 500`;
      params = [room];
    }

    const [rows] = await db.query(query, params);
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("internal chat get error:", err);
    res.status(500).json({ success: false, message: "Unable to load chat" });
  }
};

export const sendInternalMessage = async (req, res) => {
  try {
    const requestedRoom = String(req.body.room || "").trim();
    const message = String(req.body.message || "").trim();
    const user = req.internalUser;

    if (!message) return res.status(400).json({ success: false, message: "Message required" });

    let room = requestedRoom;
    let recipientId = req.body.recipientId ? Number(req.body.recipientId) : null;

    /*
     * Always derive the private HR<->IT room from authenticated IDs.
     * The browser cannot choose another employee's room.
     */
    if (user.type === "it") {
      const hrId = Number(recipientId);
      if (!hrId) return res.status(400).json({ success: false, message: "recipientId (HR id) is required" });

      room = `hr-it:${hrId}:${user.id}`;
      recipientId = hrId;
    } else if (user.type === "hr") {
      const targetId = Number(recipientId);
      if (!targetId) return res.status(400).json({ success: false, message: "recipientId is required" });

      const [[target]] = await db.query(
        `SELECT e.id, UPPER(COALESCE(d.name,'')) AS department
           FROM employees e
           JOIN departments d ON d.id = e.departmentId
          WHERE e.id = ? AND e.isActive = 1
          LIMIT 1`,
        [targetId],
      );
      if (!target) return res.status(400).json({ success: false, message: "Selected employee is not available" });

      if (target.department === "IT" || target.department.includes("INFORMATION TECHNOLOGY")) {
        room = `hr-it:${user.id}:${targetId}`;
      } else if (target.department === "HR" || target.department.includes("HUMAN RESOURCE")) {
        const a = Math.min(user.id, targetId);
        const b = Math.max(user.id, targetId);
        room = `hr-hr:${a}:${b}`;
      } else {
        return res.status(400).json({ success: false, message: "Only HR and IT contacts are supported" });
      }
      recipientId = targetId;
    }

    if (!isValidRoom(room) || !canAccess(room, user.type, user.id)) {
      return res.status(403).json({ success: false, message: "No access" });
    }

    const [result] = await db.query(
      `INSERT INTO internal_messages (room, sender_type, sender_id, recipient_id, message)
       VALUES (?,?,?,?,?)`,
      [room, user.type, user.id, recipientId, message],
    );

    const [[row]] = await db.query(
      `SELECT id, room, sender_type, sender_id, recipient_id, message, created_at
       FROM internal_messages WHERE id = ?`,
      [result.insertId],
    );

    res.json({ success: true, data: row });
  } catch (err) {
    console.error("internal chat send error:", err);
    res.status(500).json({ success: false, message: "Unable to send message" });
  }
};
