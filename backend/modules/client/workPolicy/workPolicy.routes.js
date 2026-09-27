
import express from "express";
import {
  getAllPolicies,
  createPolicy,
  updatePolicy,
  deletePolicy, downloadPolicyPdf,
} from "./workPolicy.controller.js";
import { clientUnifiedAuthMiddleware } from "../../../middleware/clientUnifiedAuth.middleware.js";
import { clientAuthMiddleware } from "../../../middleware/clientAuth.middleware.js";
const router = express.Router();

// ✅ apply ONCE
// router.use(clientUnifiedAuthMiddleware);


router.get("/", clientUnifiedAuthMiddleware, getAllPolicies);
router.get("/:id/pdf", clientUnifiedAuthMiddleware, downloadPolicyPdf);
router.post("/", clientAuthMiddleware, createPolicy);
router.put("/:id", clientAuthMiddleware, updatePolicy);
router.delete("/:id", clientAuthMiddleware, deletePolicy);

export default router;
