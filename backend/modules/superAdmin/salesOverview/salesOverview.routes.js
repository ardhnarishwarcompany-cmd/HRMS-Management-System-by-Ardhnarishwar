import express from "express";
import { protect } from "../../../middleware/auth.middleware.js";
import { getSalesOverview } from "./salesOverview.controller.js";

const router = express.Router();
router.use(protect(["SUPER_ADMIN"]));
router.get("/overview", getSalesOverview);
export default router;
