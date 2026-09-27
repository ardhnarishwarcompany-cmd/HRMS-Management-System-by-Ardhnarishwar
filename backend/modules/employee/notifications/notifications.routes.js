import express from "express";
import {
  listNotifications,
  getUnread,
  markOneRead,
  markAllAsRead,
} from "./notifications.controller.js";
import { employeeAuthMiddleware } from "../../../middleware/employeeAuth.middleware.js";

const router = express.Router();

router.use(employeeAuthMiddleware);

router.get("/", listNotifications);
router.get("/unread-count", getUnread);
router.patch("/:id/read", markOneRead);
router.patch("/read-all", markAllAsRead);

export default router;
