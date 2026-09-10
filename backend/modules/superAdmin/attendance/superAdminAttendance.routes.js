import express from "express";
import {
  getAllAttendance,
  createAttendance,
  updateAttendance,
  deleteAttendance,
  getEmployeesList,
  getAttendanceSettings,
  updateAttendanceSettings,
  getShiftTimings,
} from "./superAdminAttendance.controller.js";

import { protect } from "../../../middleware/auth.middleware.js";

const router = express.Router();

router.use(protect(["SUPER_ADMIN", "MANAGER", "TL"]));

// Live attendance configuration and shared IT/HR shift definitions.
router.get("/settings", getAttendanceSettings);
router.put("/settings", updateAttendanceSettings);
router.get("/shift-timings", getShiftTimings);

router.get("/", getAllAttendance);
router.get("/employees", getEmployeesList);
router.post("/", createAttendance);
router.put("/:id", updateAttendance);
router.delete("/:id", deleteAttendance);

export default router;
