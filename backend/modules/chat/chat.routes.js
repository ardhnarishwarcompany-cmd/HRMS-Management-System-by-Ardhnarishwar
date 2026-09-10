import express from "express";
import jwt from "jsonwebtoken";
import { ENV } from "../../config/env.js";

import {
  getAllHR,
  getAllClients,
  startConversation,
  getMessages,
  sendMessage,
  getClientConversations,
  getHRConversations,
  askAI,
  getAssignedClientChat, startClientEmployeeConversation, getClientEmployeeMessages, sendClientEmployeeMessage,
  getClientEmployeeConversations, getClientEmployeeConversationMessages, sendClientEmployeePortalMessage,
} from "./chat.controller.js";

import { hrAuthMiddleware } from "../../middleware/hrAuth.middleware.js";
import { clientAuthMiddleware } from "../../middleware/clientAuth.middleware.js";
import {
  internalChatAuth,
  getInternalMessages,
  sendInternalMessage,
  getInternalHRs,
  getInternalITContacts,
} from "./internalChat.controller.js";

const router = express.Router();

/*
  SECURITY FIX: /messages/:conversationId was unauthenticated, letting
  anyone read any conversation. Accept either an HR token or a client
  token (both signed with the same JWT secret).
*/
const hrOrClientAuth = (req, res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith("Bearer ")) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }
    const decoded = jwt.verify(header.split(" ")[1], ENV.JWT_SECRET);

    const role = String(decoded.role || "").toUpperCase();
    if (role === "CLIENT_ADMIN" || role === "CLIENT_EMPLOYEE") {
      // Both client admins and client employees use the client-side conversation permissions.
      return clientAuthMiddleware(req, res, next);
    }

    // HR / internal staff token
    req.employee = {
      id: decoded.employee_id,
      code: decoded.employee_code,
      role: decoded.role,
    };
    req.user = decoded;
    return next();
  } catch {
    return res.status(401).json({ success: false, message: "Invalid or expired token" });
  }
};

/* INTERNAL CHAT (HR / IT / SUPERADMIN) */

router.get("/internal/hrs", internalChatAuth, getInternalHRs);
router.get("/internal/it-contacts", internalChatAuth, getInternalITContacts);
router.get("/internal/:room", internalChatAuth, getInternalMessages);
router.post("/internal/send", internalChatAuth, sendInternalMessage);

/* CLIENT DIRECTORY */

router.get("/client/hrs", clientAuthMiddleware, getAllHR);

/* HR DIRECTORY */

router.get("/hr/clients", hrAuthMiddleware, getAllClients);


/* EXISTING CONVERSATIONS */

router.get(
  "/client/conversations",
  clientAuthMiddleware,
  getClientConversations
);

router.get(
  "/hr/conversations",
  hrAuthMiddleware,
  getHRConversations
);


/* CHAT */

router.post("/client/start", clientAuthMiddleware, startConversation);

router.post("/hr/start", hrAuthMiddleware, startConversation);

router.get("/messages/:conversationId", hrOrClientAuth, getMessages);

router.post("/send", hrAuthMiddleware, sendMessage);

router.post("/client/send", clientAuthMiddleware, sendMessage);
router.post("/client/ai/ask", clientAuthMiddleware, askAI);
router.post("/ai/ask", hrAuthMiddleware, askAI);

router.get("/client/assigned-chat", clientAuthMiddleware, getAssignedClientChat);
router.post("/client/employee/start", clientAuthMiddleware, startClientEmployeeConversation);
router.get("/client/employee/messages/:conversationId", clientAuthMiddleware, getClientEmployeeMessages);
router.post("/client/employee/send", clientAuthMiddleware, sendClientEmployeeMessage);
router.get("/client/employee/conversations", clientAuthMiddleware, getClientEmployeeConversations);
router.get("/client/employee/conversations/:conversationId/messages", clientAuthMiddleware, getClientEmployeeConversationMessages);
router.post("/client/employee/conversations/send", clientAuthMiddleware, sendClientEmployeePortalMessage);

export default router;
