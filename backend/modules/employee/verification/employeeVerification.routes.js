import express from "express";
import upload from "../../../middleware/upload.middleware.js";
import { employeeAuthMiddleware } from "../../../middleware/employeeAuth.middleware.js";
import {
  listMyVerificationDocs,
  uploadMyVerificationDoc,
  getMyVerificationStatus, getMyIdentity, submitMyIdentity, getMyBackground, submitMyBackground,
} from "./employeeVerification.controller.js";

const router = express.Router();

router.use(employeeAuthMiddleware);
router.get("/", listMyVerificationDocs);
router.post("/", upload.single("file"), uploadMyVerificationDoc);
router.get("/status", getMyVerificationStatus);
router.get("/identity", getMyIdentity);
router.post("/identity", submitMyIdentity);
router.get("/background", getMyBackground);
router.post("/background", submitMyBackground);

export default router;
