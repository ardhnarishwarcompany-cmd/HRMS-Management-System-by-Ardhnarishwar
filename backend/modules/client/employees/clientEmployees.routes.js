import express from "express";
import * as ctrl from "./clientEmployees.controller.js";
import { clientAuthMiddleware } from "../../../middleware/clientAuth.middleware.js";
import { clientUnifiedAuthMiddleware } from "../../../middleware/clientUnifiedAuth.middleware.js";

const router = express.Router();

router.post("/", clientAuthMiddleware, ctrl.createEmployee);
router.get("/by-department", clientUnifiedAuthMiddleware, ctrl.listEmployeesByDepartment);
router.get("/", clientUnifiedAuthMiddleware, (req,res,next) => req.employee ? res.status(403).json({success:false,message:"Employee management is available to client administrators only"}) : ctrl.listEmployees(req,res,next));
router.put("/:id", clientAuthMiddleware, ctrl.updateEmployee);
router.patch("/:id/toggle", clientAuthMiddleware, ctrl.toggleEmployee);
router.delete("/:id", clientAuthMiddleware, ctrl.deleteEmployee);

export default router;