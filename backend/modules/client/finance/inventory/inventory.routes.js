import express from "express";
import {
  getAllInventory,
  getTotalInventoryValue,
  createInventoryItem,
  updateInventoryItem,
  deleteInventoryItem,
  getLowStockItems,
  updateStock,
} from "./inventory.controller.js";
import auditMiddleware from "../../../../middleware/audit.middleware.js";

import { clientAuthMiddleware } from "../../../../middleware/clientAuth.middleware.js";
import { clientUnifiedAuthMiddleware } from "../../../../middleware/clientUnifiedAuth.middleware.js";

const router = express.Router();

// GET
router.get("/", clientUnifiedAuthMiddleware, getAllInventory);
router.get("/total-value", clientUnifiedAuthMiddleware, getTotalInventoryValue);
router.get("/low-stock", clientUnifiedAuthMiddleware, getLowStockItems);

// POST
router.post("/add", clientAuthMiddleware, auditMiddleware("ADD_INVENTORY"), createInventoryItem);

// PUT
router.put("/:id", clientAuthMiddleware, auditMiddleware("UPDATE_INVENTORY"), updateInventoryItem);
router.put("/stock/:id", clientAuthMiddleware, updateStock);

// DELETE
router.delete("/:id", clientAuthMiddleware, auditMiddleware("DELETE_INVENTORY"), deleteInventoryItem);

export default router;