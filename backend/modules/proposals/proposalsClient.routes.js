import express from "express";
import { clientPortalAuthMiddleware } from "../../middleware/clientPortalAuth.middleware.js";
import { clientAuthMiddleware } from "../../middleware/clientAuth.middleware.js";
import { listMyProposals, getMyProposal, respondToProposal } from "./proposals.controller.js";
import { downloadMyProposalPdf } from "./proposalPdf.controller.js";

const router = express.Router();
router.get("/", clientPortalAuthMiddleware, listMyProposals);
router.get("/:id/pdf", clientPortalAuthMiddleware, downloadMyProposalPdf);
router.get("/:id", clientPortalAuthMiddleware, getMyProposal);
router.post("/:id/respond", clientAuthMiddleware, respondToProposal);
export default router;
