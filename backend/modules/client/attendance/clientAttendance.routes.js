import express from "express";
import { clientPortalAuthMiddleware } from "../../../middleware/clientPortalAuth.middleware.js";
import { clientAuthMiddleware } from "../../../middleware/clientAuth.middleware.js";
import { createAttendance, listAttendance, updateAttendance, deleteAttendance } from "./clientAttendance.controller.js";

const router = express.Router();

// Read: Client Admin + Client Employee.
router.get("/", clientPortalAuthMiddleware, listAttendance);
// Write: Client Admin only.
router.post("/", clientAuthMiddleware, (req,res,next) => req.employee ? res.status(403).json({success:false,message:"Employees cannot manually create attendance records"}) : createAttendance(req,res,next));
router.put("/:id", clientAuthMiddleware, (req,res,next) => req.employee ? res.status(403).json({success:false,message:"Employees cannot edit attendance records"}) : updateAttendance(req,res,next));
router.delete("/:id", clientAuthMiddleware, (req,res,next) => req.employee ? res.status(403).json({success:false,message:"Employees cannot delete attendance records"}) : deleteAttendance(req,res,next));

export default router;
