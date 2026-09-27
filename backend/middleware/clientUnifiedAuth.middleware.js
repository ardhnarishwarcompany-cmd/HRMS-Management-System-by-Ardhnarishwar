import jwt from "jsonwebtoken";
import { db } from "../config/db.js";
import { ENV } from "../config/env.js";

/**
 * Unified authentication for CLIENT PORTAL read endpoints.
 * Allows both Client Admin and Client Employee tokens while always
 * resolving a normalized req.client tenant context.
 */
export const clientUnifiedAuthMiddleware = async (req, res, next) => {
  try {
    const header = req.headers.authorization;

    if (!header || !header.startsWith("Bearer ")) {
      return res.status(401).json({ success: false, message: "Unauthorized: Token missing" });
    }

    const token = header.slice(7).trim();
    if (!token) {
      return res.status(401).json({ success: false, message: "Unauthorized: Token missing" });
    }

    const decoded = jwt.verify(token, ENV.JWT_SECRET);
    const role = String(decoded.role || "").trim().toUpperCase();

    // CLIENT ADMIN
    if (role === "CLIENT_ADMIN") {
      if (!decoded.client_code) {
        return res.status(403).json({ success: false, message: "Client context missing" });
      }

      const [clients] = await db.query(
        `SELECT id, client_code, status FROM clients WHERE client_code = ? LIMIT 1`,
        [decoded.client_code],
      );

      if (!clients.length) {
        return res.status(401).json({ success: false, message: "Client not found" });
      }
      if (String(clients[0].status).toUpperCase() !== "ACTIVE") {
        return res.status(403).json({ success: false, message: "Client account inactive" });
      }

      req.client = {
        id: clients[0].id,
        client_code: clients[0].client_code,
        role: "client_admin",
      };
      return next();
    }

    // CLIENT EMPLOYEE
    if (role === "CLIENT_EMPLOYEE") {
      if (!decoded.employee_id) {
        return res.status(403).json({ success: false, message: "Employee context missing" });
      }

      const [employees] = await db.query(
        `SELECT id, client_id, isActive, name, email, employeeCode, departmentId, designationId, joiningDate, salary FROM client_employees WHERE id = ? LIMIT 1`,
        [decoded.employee_id],
      );

      if (!employees.length) {
        return res.status(401).json({ success: false, message: "Client employee not found" });
      }
      if (!employees[0].isActive) {
        return res.status(403).json({ success: false, message: "Employee inactive" });
      }

      const [clients] = await db.query(
        `SELECT id, client_code, status FROM clients WHERE id = ? LIMIT 1`,
        [employees[0].client_id],
      );

      if (!clients.length) {
        return res.status(401).json({ success: false, message: "Client not found" });
      }
      if (String(clients[0].status).toUpperCase() !== "ACTIVE") {
        return res.status(403).json({ success: false, message: "Client account inactive" });
      }

      req.employee = {
        employee_id: employees[0].id,
        client_id: employees[0].client_id,
        client_code: clients[0].client_code,
        role: "CLIENT_EMPLOYEE",
        name: employees[0].name,
        email: employees[0].email,
        employeeCode: employees[0].employeeCode,
        departmentId: employees[0].departmentId,
        designationId: employees[0].designationId,
        joiningDate: employees[0].joiningDate,
        salary: employees[0].salary,
      };

      req.client = {
        id: clients[0].id,
        client_code: clients[0].client_code,
        role: "CLIENT_EMPLOYEE",
        employee_id: employees[0].id,
      };

      return next();
    }

    return res.status(403).json({
      success: false,
      message: "Forbidden: Client portal access required",
    });
  } catch (err) {
    console.error("[CLIENT UNIFIED AUTH]", err.message);
    return res.status(401).json({ success: false, message: "Invalid or expired token" });
  }
};
