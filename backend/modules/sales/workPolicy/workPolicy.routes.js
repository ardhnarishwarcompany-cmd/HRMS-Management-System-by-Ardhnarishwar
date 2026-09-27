import express from "express";
import {
  getPolicies, downloadPolicyPdf,
} from "./workPolicy.controller.js";

import { requireSalesAuth } from "../../../middleware/salesAuth.middleware.js";

const router = express.Router();

router.use(requireSalesAuth);

router.get("/", getPolicies);
router.get("/:id/pdf", downloadPolicyPdf);

export default router;