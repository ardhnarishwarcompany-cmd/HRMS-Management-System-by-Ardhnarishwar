import {
  getByEmployee,
  getUnreadCount,
  markRead,
  markAllRead,
} from "./notifications.query.js";

export const listNotifications = async (req, res) => {
  try {
    const employeeId = req.employee.id;
    const rows = await getByEmployee(employeeId);
    const unreadCount = await getUnreadCount(employeeId);
    res.json({ success: true, data: rows, unreadCount });
  } catch (err) {
    console.error("listNotifications error:", err);
    res.status(500).json({ success: false, message: "Failed to load notifications" });
  }
};

export const getUnread = async (req, res) => {
  try {
    const employeeId = req.employee.id;
    const count = await getUnreadCount(employeeId);
    res.json({ success: true, unreadCount: count });
  } catch (err) {
    console.error("getUnread error:", err);
    res.status(500).json({ success: false, message: "Failed to load count" });
  }
};

export const markOneRead = async (req, res) => {
  try {
    const employeeId = req.employee.id;
    const { id } = req.params;
    await markRead(id, employeeId);
    res.json({ success: true });
  } catch (err) {
    console.error("markOneRead error:", err);
    res.status(500).json({ success: false, message: "Failed to mark read" });
  }
};

export const markAllAsRead = async (req, res) => {
  try {
    const employeeId = req.employee.id;
    await markAllRead(employeeId);
    res.json({ success: true });
  } catch (err) {
    console.error("markAllAsRead error:", err);
    res.status(500).json({ success: false, message: "Failed to mark all read" });
  }
};
