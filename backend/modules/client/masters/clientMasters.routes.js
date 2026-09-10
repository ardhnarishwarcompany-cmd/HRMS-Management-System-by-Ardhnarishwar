import express from "express";
import { clientAuthMiddleware } from "../../../middleware/clientAuth.middleware.js";
import { clientUnifiedAuthMiddleware } from "../../../middleware/clientUnifiedAuth.middleware.js";
import {
  getDepartments,
  getDesignations,
  getStatuses,
} from "./clientMasters.controller.js";

const router = express.Router();

// 🔐 unified read access for client admin + client employee
// 📦 masters
router.get("/departments", clientUnifiedAuthMiddleware, getDepartments);
router.get("/designations", clientUnifiedAuthMiddleware, getDesignations);
router.get("/statuses", clientUnifiedAuthMiddleware, getStatuses);

export default router;