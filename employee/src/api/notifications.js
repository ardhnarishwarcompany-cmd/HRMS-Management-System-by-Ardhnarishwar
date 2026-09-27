import axios from "./axios.js";

export const fetchNotifications = () => axios.get("/employee/notifications");
export const fetchUnreadCount = () => axios.get("/employee/notifications/unread-count");
export const markNotificationRead = (id) => axios.patch(`/employee/notifications/${id}/read`);
export const markAllNotificationsRead = () => axios.patch("/employee/notifications/read-all");
