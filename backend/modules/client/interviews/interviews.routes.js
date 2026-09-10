import express from "express";
import { clientPortalAuthMiddleware } from "../../../middleware/clientPortalAuth.middleware.js";
import { clientAuthMiddleware } from "../../../middleware/clientAuth.middleware.js";
import { getClientInterviews, updateClientDecision } from "./interviews.controller.js";

const router = express.Router();
router.get("/", clientPortalAuthMiddleware, (req,res,next) => req.employee ? res.status(403).json({success:false,message:"Interview tracker is available to client administrators only"}) : getClientInterviews(req,res,next));
router.put("/:id/decision", clientAuthMiddleware, updateClientDecision);
export default router;
