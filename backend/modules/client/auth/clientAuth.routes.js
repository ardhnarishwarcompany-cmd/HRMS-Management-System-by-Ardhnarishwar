import express from "express";
import { loginClientAdmin } from "./clientAuth.controller.js";
import { clientPortalAuthMiddleware } from "../../../middleware/clientPortalAuth.middleware.js";
import { db } from "../../../config/db.js";

const router = express.Router();
router.post("/login-admin", loginClientAdmin);
router.get("/features", clientPortalAuthMiddleware, async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT feature_key FROM client_features WHERE client_id = ? AND is_enabled = 1`,
      [req.client.id],
    );
    const adminFeatures = rows.map((r) => r.feature_key);
    if (req.employee) {
      return res.json({ success: true, enabledFeatures: [...new Set([...adminFeatures, "ATTENDANCE_TRACKER", "PAYROLL", "PERFORMANCE_TRACKER", "WORK_POLICY", "WORK_ASSIGNMENT", "COMPLAINT", "PURCHASE_ORDERS", "SALES_REPORT"]) ] });
    }
    return res.json({ success: true, enabledFeatures: adminFeatures });
  } catch (err) {
    console.error("client features error:", err);
    return res.status(500).json({ success: false, message: `Server error: ${err.message}` });
  }
});
export default router;
