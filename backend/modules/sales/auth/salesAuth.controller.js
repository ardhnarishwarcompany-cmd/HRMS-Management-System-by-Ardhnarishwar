import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { db } from "../../../config/db.js";
import { ENV } from "../../../config/env.js";

const SALES_DEPT_ID = Number(ENV.SALES_DEPT_ID);

// ==============================
// SALES LOGIN
// ==============================
export const salesLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1️⃣ Resolve the real Sales department from the shared production DB.
    // The environment value is only a fallback because department IDs can differ
    // between an older/local database and the current Hostinger database.
    const [salesDepartments] = await db.query(
      `SELECT id FROM departments
       WHERE LOWER(TRIM(name)) = 'sales'
       LIMIT 1`
    );
    const actualSalesDeptId = salesDepartments[0]?.id != null
      ? Number(salesDepartments[0].id)
      : SALES_DEPT_ID;

    // 2️⃣ Find employee. Return the department ID as a number so the comparison
    // is stable across MySQL driver/configuration differences.
    const [rows] = await db.query(
      `SELECT e.*, d.name AS departmentName
       FROM employees e
       LEFT JOIN departments d ON d.id = e.departmentId
       WHERE e.email = ? LIMIT 1`,
      [email]
    );

    const employee = rows[0];

    if (!employee) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // 3️⃣ Check that this employee belongs to the actual Sales department.
    // This prevents a stale SALES_DEPT_ID from blocking valid production users.
    const employeeDeptId = Number(employee.departmentId);
    const departmentIsSales = String(employee.departmentName || '').trim().toLowerCase() === 'sales';
    if (employeeDeptId !== actualSalesDeptId && !departmentIsSales) {
      return res.status(403).json({ message: "Access denied for this portal" });
    }

    // 4️⃣ check active
    if (!Number(employee.isActive)) {
      return res.status(403).json({ message: "Employee is inactive" });
    }

    // 5️⃣ verify password
    if (!employee.password_hash) {
      return res.status(401).json({
        message:
          "No password set for this account. Ask your admin to set one via Edit Employee > Reset Password.",
      });
    }

    const isMatch = await bcrypt.compare(password, employee.password_hash);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // 6️⃣ generate sales token
    const token = jwt.sign(
      {
        employeeId: employee.id,
        employeeCode: employee.employeeCode,
        email: employee.email,
        role: "sales",
      },
      ENV.JWT_SECRET,
      { expiresIn: ENV.JWT_EXPIRES_IN }
    );

    return res.json({
      success: true,
      message: "Login successful",
      token,
      user: {
        id: employee.id,
        name: employee.name,
        email: employee.email,
      },
    });
  } catch (err) {
    console.error("Sales login error:", err);
    res.status(500).json({ message: "Server error" });
  }
};
