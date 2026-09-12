import { db } from "../../config/db.js";
import { generateAIResponse } from "./ai.service.js";

// helper → get client_id from client_code
const getClientId = async (client_code) => {
  const [rows] = await db.query(
    `SELECT id FROM clients WHERE client_code = ? LIMIT 1`,
    [client_code],
  );

  if (!rows.length) throw new Error("Client not found");
  return rows[0].id;
};

/* ============================= */
/* GET ALL HR FOR CLIENT SIDEBAR */
/* ============================= */

export const getAllHR = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        e.id,
        e.name,
        e.email
      FROM employees e
      JOIN departments d ON d.id = e.departmentId
      WHERE d.name = 'HR'
      AND e.isActive = 1
      ORDER BY e.name ASC
    `);

    res.json({
      success: true,
      data: rows,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
};

/* ============================= */
/* GET ALL CLIENTS FOR HR        */
/* ============================= */

export const getAllClients = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        id,
        company_name,
        client_name,
        email
      FROM clients
      WHERE status = 'ACTIVE'
      ORDER BY company_name ASC
    `);

    res.json({
      success: true,
      data: rows,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
};

/* ============================= */
/* START CONVERSATION            */
/* ============================= */

export const startConversation = async (req, res) => {
  try {
    const isClientEmployee =
      String(req.employee?.role || "").toUpperCase() === "CLIENT_EMPLOYEE";

    let clientId = null;
    let hrId = null;

    // Client admin and client employee both have a normalized req.client
    // after clientAuthMiddleware. Never depend on a clientId supplied by
    // the browser for client-side chat.
    if (req.client && (!req.employee || isClientEmployee)) {
      clientId = Number(req.client.id);
      hrId = Number(req.body.hrId);
    }

    // HR/internal user starts a conversation with a client.
    if (req.employee && !isClientEmployee) {
      hrId = Number(req.employee.id);
      clientId = Number(req.body.clientId);
    }

    if (!Number.isInteger(clientId) || clientId <= 0 ||
        !Number.isInteger(hrId) || hrId <= 0) {
      return res.status(400).json({
        success: false,
        message: "A valid client and HR member are required to start a conversation",
      });
    }

    // Make sure the selected HR/IT member is actually an active staff account.
    // (Previously this required department = 'HR', which blocked IT-portal
    // staff from ever starting a client chat even though the UI allows it.)
    const [hrRows] = await db.query(
      `SELECT e.id
         FROM employees e
        WHERE e.id = ? AND e.isActive = 1
        LIMIT 1`,
      [hrId],
    );

    if (!hrRows.length) {
      return res.status(400).json({
        success: false,
        message: "Your account is not available to start a chat",
      });
    }

    const [existing] = await db.query(
      `SELECT id FROM conversations WHERE client_id=? AND hr_id=? LIMIT 1`,
      [clientId, hrId],
    );

    if (existing.length > 0) {
      return res.json({
        success: true,
        conversationId: existing[0].id,
      });
    }

    const [result] = await db.query(
      `INSERT INTO conversations (client_id, hr_id) VALUES (?,?)`,
      [clientId, hrId],
    );

    res.json({
      success: true,
      conversationId: result.insertId,
    });
  } catch (err) {
    console.error("startConversation error:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

/* ============================= */
/* GET MESSAGES                  */
/* ============================= */

export const getMessages = async (req, res) => {
  try {
    const conversationId = Number(req.params.conversationId);
    if (!conversationId) return res.status(400).json({ success: false, message: "Invalid conversation" });

    let ownerClause = "";
    let ownerParams = [];

    if (req.client?.id) {
      ownerClause = "AND c.client_id = ?";
      ownerParams = [Number(req.client.id)];
    } else if (req.employee?.id) {
      ownerClause = "AND c.hr_id = ?";
      ownerParams = [Number(req.employee.id)];
    } else {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const [rows] = await db.query(
      `SELECT m.id, m.sender_type, m.sender_id, m.message, m.created_at
         FROM messages m
         JOIN conversations c ON c.id = m.conversation_id
        WHERE m.conversation_id = ? ${ownerClause}
        ORDER BY m.id ASC`,
      [conversationId, ...ownerParams],
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("getMessages error:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

/* ============================= */
/* SEND MESSAGE                  */
/* ============================= */

export const sendMessage = async (req, res) => {
  try {
    const conversationId = Number(req.body?.conversationId);
    const message = String(req.body?.message || "").trim();

    if (!conversationId || !message) {
      return res.status(400).json({ success: false, message: "conversationId and message required" });
    }

    let senderId;
    let senderType;
    let ownerClause = "";
    let ownerParams = [];

    if (req.client?.client_code) {
      senderId = await getClientId(req.client.client_code);
      senderType = "client";
      ownerClause = "AND c.client_id = ?";
      ownerParams = [Number(req.client.id)];
    } else if (req.employee?.id) {
      senderId = Number(req.employee.id);
      senderType = "hr";
      ownerClause = "AND c.hr_id = ?";
      ownerParams = [Number(req.employee.id)];
    } else {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const [[conversation]] = await db.query(
      `SELECT c.id FROM conversations c
        WHERE c.id = ? ${ownerClause}
        LIMIT 1`,
      [conversationId, ...ownerParams],
    );

    if (!conversation) {
      return res.status(403).json({ success: false, message: "Conversation not available" });
    }

    const [result] = await db.query(
      `INSERT INTO messages (conversation_id, sender_type, sender_id, message)
       VALUES (?,?,?,?)`,
      [conversationId, senderType, senderId, message],
    );

    const [[row]] = await db.query(
      `SELECT id, sender_type, sender_id, message, created_at
         FROM messages WHERE id = ?`,
      [result.insertId],
    );

    res.json({ success: true, data: row });
  } catch (err) {
    console.error("sendMessage error:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

/* ============================= */
/* CLIENT CONVERSATIONS LIST     */
/* ============================= */

export const getClientConversations = async (req, res) => {
  try {
    const clientId = req.client.id;

    const [rows] = await db.query(
      `
      SELECT 
        c.id AS conversation_id,
        e.id AS hr_id,
        e.name AS hr_name,
        e.email
      FROM conversations c
      JOIN employees e ON e.id = c.hr_id
      WHERE c.client_id = ?
      ORDER BY c.created_at DESC
    `,
      [clientId],
    );

    res.json({
      success: true,
      data: rows,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
};

/* ============================= */
/* HR CONVERSATIONS LIST         */
/* ============================= */

export const getHRConversations = async (req, res) => {
  try {
    const hrId = req.employee.id;

    const [rows] = await db.query(
      `
      SELECT 
        c.id AS conversation_id,
        cl.id AS client_id,
        cl.company_name,
        cl.client_name,
        cl.email
      FROM conversations c
      JOIN clients cl ON cl.id = c.client_id
      WHERE c.hr_id = ?
      ORDER BY c.created_at DESC
    `,
      [hrId],
    );

    res.json({
      success: true,
      data: rows,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
};

export const askAI = async (req, res) => {
  try {
    const { conversationId, message } = req.body;

    if (!conversationId || !message) {
      return res.status(400).json({
        success: false,
        message: "conversationId and message are required",
      });
    }

    const answer = await generateAIResponse({ conversationId, message });

    await db.query(
      `INSERT INTO messages (conversation_id, sender_type, sender_id, message)
       VALUES (?,?,?,?)`,
      [conversationId, "ai", 0, answer],
    );

    res.json({ success: true, answer });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: err.message });
  }
};


export const getAssignedClientChat = async (req,res) => {
  try {
    if (!req.employee?.employee_id || !req.employee?.client_id) return res.status(403).json({success:false,message:"Client employee access required"});
    const [[client]] = await db.query(`SELECT id, company_name, client_name, email FROM clients WHERE id=? AND status='ACTIVE' LIMIT 1`, [req.employee.client_id]);
    if (!client) return res.status(404).json({success:false,message:"Assigned client not found"});
    res.json({success:true,data:{...client, employee_id:req.employee.employee_id}});
  } catch(e){ console.error(e); res.status(500).json({success:false,message:e.message}); }
};

export const startClientEmployeeConversation = async (req,res) => {
  try {
    if (!req.employee?.employee_id || !req.employee?.client_id) return res.status(403).json({success:false,message:"Client employee access required"});
    const [[existing]] = await db.query(`SELECT id FROM client_employee_conversations WHERE client_id=? AND employee_id=? LIMIT 1`, [req.employee.client_id, req.employee.employee_id]);
    if (existing) return res.json({success:true,conversationId:existing.id});
    const [r] = await db.query(`INSERT INTO client_employee_conversations (client_id,employee_id) VALUES (?,?)`, [req.employee.client_id,req.employee.employee_id]);
    res.status(201).json({success:true,conversationId:r.insertId});
  } catch(e){ console.error(e); res.status(500).json({success:false,message:e.message}); }
};

export const getClientEmployeeMessages = async (req,res) => {
  try {
    if (!req.employee?.employee_id) return res.status(403).json({success:false,message:"Client employee access required"});
    const [[room]] = await db.query(`SELECT id FROM client_employee_conversations WHERE id=? AND client_id=? AND employee_id=? LIMIT 1`, [req.params.conversationId,req.employee.client_id,req.employee.employee_id]);
    if (!room) return res.status(403).json({success:false,message:"Chat room not available"});
    const [rows]=await db.query(`SELECT id,sender_type,sender_id,message,created_at FROM client_employee_messages WHERE conversation_id=? ORDER BY id ASC`,[room.id]);
    res.json({success:true,data:rows});
  }catch(e){console.error(e);res.status(500).json({success:false,message:e.message});}
};

export const sendClientEmployeeMessage = async (req,res) => {
  try {
    if (!req.employee?.employee_id) return res.status(403).json({success:false,message:"Client employee access required"});
    const message=String(req.body?.message||"").trim(); if(!message) return res.status(400).json({success:false,message:"Message is required"});
    const [[room]] = await db.query(`SELECT id FROM client_employee_conversations WHERE id=? AND client_id=? AND employee_id=? LIMIT 1`,[req.body.conversationId,req.employee.client_id,req.employee.employee_id]);
    if(!room)return res.status(403).json({success:false,message:"Chat room not available"});
    await db.query(`INSERT INTO client_employee_messages (conversation_id,sender_type,sender_id,message) VALUES (?,?,?,?)`,[room.id,'employee',req.employee.employee_id,message]);
    res.json({success:true});
  }catch(e){console.error(e);res.status(500).json({success:false,message:e.message});}
};


/* ============================================================
 * CLIENT PORTAL <-> CLIENT EMPLOYEE CHAT
 * Client admins can see every employee conversation belonging
 * to their tenant and can reply. Client employees can only see
 * their own conversation.
 * ============================================================ */

const clientPortalScope = (req) => {
  const clientId = Number(req.client?.id || req.employee?.client_id);
  const employeeId = req.employee?.employee_id ? Number(req.employee.employee_id) : null;
  const role = String(req.employee?.role || req.client?.role || "").toUpperCase();
  return {
    clientId: Number.isInteger(clientId) && clientId > 0 ? clientId : null,
    employeeId: Number.isInteger(employeeId) && employeeId > 0 ? employeeId : null,
    isEmployee: role === "CLIENT_EMPLOYEE",
  };
};

export const getClientEmployeeConversations = async (req, res) => {
  try {
    const { clientId, employeeId, isEmployee } = clientPortalScope(req);
    if (!clientId) return res.status(403).json({ success: false, message: "Client context required" });

    const where = ["c.client_id = ?"];
    const params = [clientId];

    if (isEmployee) {
      if (!employeeId) return res.status(403).json({ success: false, message: "Employee context required" });
      where.push("c.employee_id = ?");
      params.push(employeeId);
    }

    if (!isEmployee) {
      await db.query(
        `INSERT IGNORE INTO client_employee_conversations (client_id, employee_id)
         SELECT ?, id FROM client_employees WHERE client_id=? AND isActive=1`,
        [clientId, clientId],
      );
    }

    const [rows] = await db.query(
      `SELECT
         c.id AS conversation_id,
         c.client_id,
         c.employee_id,
         e.name AS employee_name,
         e.email AS employee_email,
         e.employeeCode,
         c.created_at,
         COALESCE(last_message.message, '') AS last_message,
         last_message.sender_type AS last_sender_type,
         last_message.created_at AS last_message_at
       FROM client_employee_conversations c
       JOIN client_employees e ON e.id = c.employee_id
       LEFT JOIN (
         SELECT m.conversation_id, m.message, m.sender_type, m.created_at
         FROM client_employee_messages m
         INNER JOIN (
           SELECT conversation_id, MAX(id) AS max_id
           FROM client_employee_messages
           GROUP BY conversation_id
         ) latest ON latest.conversation_id = m.conversation_id AND latest.max_id = m.id
       ) last_message ON last_message.conversation_id = c.id
       WHERE ${where.join(" AND ")}
       ORDER BY COALESCE(last_message.created_at, c.created_at) DESC, c.id DESC`,
      params,
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("CLIENT EMPLOYEE CONVERSATIONS ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

export const getClientEmployeeConversationMessages = async (req, res) => {
  try {
    const { clientId, employeeId, isEmployee } = clientPortalScope(req);
    const conversationId = Number(req.params.conversationId);

    if (!clientId || !Number.isInteger(conversationId) || conversationId <= 0) {
      return res.status(400).json({ success: false, message: "Valid conversation is required" });
    }

    const params = [conversationId, clientId];
    let employeeFilter = "";
    if (isEmployee) {
      if (!employeeId) return res.status(403).json({ success: false, message: "Employee context required" });
      employeeFilter = " AND c.employee_id = ?";
      params.push(employeeId);
    }

    const [[conversation]] = await db.query(
      `SELECT c.id, c.employee_id, e.name AS employee_name
       FROM client_employee_conversations c
       JOIN client_employees e ON e.id = c.employee_id
       WHERE c.id = ? AND c.client_id = ?${employeeFilter}
       LIMIT 1`,
      params,
    );

    if (!conversation) {
      return res.status(404).json({ success: false, message: "Chat conversation not found" });
    }

    const [rows] = await db.query(
      `SELECT id, sender_type, sender_id, message, created_at
       FROM client_employee_messages
       WHERE conversation_id = ?
       ORDER BY id ASC`,
      [conversationId],
    );

    res.json({ success: true, data: rows, conversation: {
      id: conversation.id,
      employee_id: conversation.employee_id,
      employee_name: conversation.employee_name,
    }});
  } catch (err) {
    console.error("CLIENT EMPLOYEE MESSAGES ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

export const sendClientEmployeePortalMessage = async (req, res) => {
  try {
    const { clientId, employeeId, isEmployee } = clientPortalScope(req);
    const conversationId = Number(req.body?.conversationId);
    const message = String(req.body?.message || "").trim();

    if (!clientId || !Number.isInteger(conversationId) || conversationId <= 0) {
      return res.status(400).json({ success: false, message: "Valid conversation is required" });
    }
    if (!message) return res.status(400).json({ success: false, message: "Message is required" });

    const params = [conversationId, clientId];
    let employeeFilter = "";
    if (isEmployee) {
      if (!employeeId) return res.status(403).json({ success: false, message: "Employee context required" });
      employeeFilter = " AND employee_id = ?";
      params.push(employeeId);
    }

    const [[conversation]] = await db.query(
      `SELECT id, employee_id
       FROM client_employee_conversations
       WHERE id = ? AND client_id = ?${employeeFilter}
       LIMIT 1`,
      params,
    );

    if (!conversation) {
      return res.status(404).json({ success: false, message: "Chat conversation not found" });
    }

    const senderType = isEmployee ? "employee" : "client";
    const senderId = isEmployee ? employeeId : clientId;

    const [result] = await db.query(
      `INSERT INTO client_employee_messages
       (conversation_id, sender_type, sender_id, message)
       VALUES (?, ?, ?, ?)`,
      [conversation.id, senderType, senderId, message],
    );

    res.json({
      success: true,
      data: {
        id: result.insertId,
        sender_type: senderType,
        sender_id: senderId,
        message,
        created_at: new Date().toISOString(),
      },
    });
  } catch (err) {
    console.error("CLIENT EMPLOYEE SEND ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};
