import express from "express";
import { sopMultiUpload, sopValidateSizes } from "../../middleware/upload.middleware.js";
import { hrAuthMiddleware } from "../../middleware/hrAuth.middleware.js";
import { employeeAuthMiddleware } from "../../middleware/employeeAuth.middleware.js";
import { clientPortalAuthMiddleware } from "../../middleware/clientPortalAuth.middleware.js";
import {
  getAllSops,
  createSop,
  uploadNewVersion,
  getVersionHistory,
  getAcknowledgements,
  setSopStatus,
  getEmployeeSops,
  acknowledgeSop,
  completeTraining,
  getClientSopLibrary,
  downloadSopFile
} from "./sop.controller.js";
const router = express.Router();
router.get("/employee", employeeAuthMiddleware, getEmployeeSops);
router.post("/:id/acknowledge", employeeAuthMiddleware, acknowledgeSop);
router.post("/:id/training-complete", employeeAuthMiddleware, completeTraining);
router.get("/client-library", clientPortalAuthMiddleware, getClientSopLibrary);
router.get("/files/:fileId/download", downloadSopFile);
router.get("/", hrAuthMiddleware, getAllSops);
router.post("/", hrAuthMiddleware, sopMultiUpload, sopValidateSizes, createSop);
router.post("/:id/version", hrAuthMiddleware, sopMultiUpload, sopValidateSizes, uploadNewVersion);
router.get("/:id/versions", hrAuthMiddleware, getVersionHistory);
router.get("/:id/acknowledgements", hrAuthMiddleware, getAcknowledgements);
router.patch("/:id/status", hrAuthMiddleware, setSopStatus);
export default router;
