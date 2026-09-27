import bcrypt from "bcryptjs";
import { asyncHandler } from "../../../utils/asyncHandler.js";
import { signToken } from "../../../utils/jwt.js";
import { db } from "../../../config/db.js";

export const loginEmployee = asyncHandler(async (req, res) => {

  const { email, employeeCode, employeeId, joiningId, password } = req.body || {};
  const identifier = String(email || employeeCode || employeeId || joiningId || "").trim();
  if (!identifier || !password) {
    return res.status(400).json({
      success: false,
      message: "Employee ID/email and password are required",
    });
  }

  const [rows] = await db.query(
    `
    SELECT 
      e.id,
      e.name,
      e.email,
      e.password_hash,
      e.employeeCode,
      e.joiningId,
      e.departmentId,
      d.name as department

    FROM employees e
    LEFT JOIN departments d ON d.id = e.departmentId

    WHERE (e.email = ? OR e.employeeCode = ? OR CAST(e.id AS CHAR) = ? OR CAST(e.joiningId AS CHAR) = ?)
    AND e.isActive = 1
    LIMIT 1
    `,
    [identifier, identifier, identifier, identifier],
  );

  if (!rows.length) {
    return res.status(401).json({
      success: false,
      message: "Invalid credentials",
    });
  }

  const employee = rows[0];
  console.log("EVS LOGIN:", { identifier, matchedId: employee.id, matchedCode: employee.employeeCode, matchedName: employee.name, matchedEmail: employee.email });

  const isMatch = await bcrypt.compare(
    password,
    employee.password_hash,
  );

  console.log("MATCH RESULT:", isMatch);

  if (!isMatch) {
    return res.status(401).json({
      success: false,
      message: "Invalid credentials",
    });
  }

const user = {
  id: employee.id,
  role: "EMPLOYEE",   // <-- YE ADD KARNA HAI
  name: employee.name,
  email: employee.email,
  employeeCode: employee.employeeCode,
  joiningId: employee.joiningId,
  department: employee.department,
};

  const token = signToken(user);

  res.json({
    success: true,
    token,
    user,
  });
});

export const getMe = async (
  req,
  res
) => {
  try {
    res.json({
      success: true,
      user: req.employee,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};