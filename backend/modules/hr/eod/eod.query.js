import { db } from "../../../config/db.js";

export const getMyEODReports = async (employeeId, filters = {}) => {
  const where = ["employee_id = ?"];
  const params = [employeeId];
  if (filters.date) { where.push("DATE(report_date) = ?"); params.push(filters.date); }
  if (filters.status) { where.push("status = ?"); params.push(filters.status); }

  const [rows] = await db.query(
    `
    SELECT 
      id, employee_id AS employeeId, employee_name AS employeeName, department,
      department_id AS departmentId, report_date AS date,
      tasks_completed AS tasksCompleted, tasks_in_progress AS tasksInProgress,
      blockers, tomorrow_plan AS tomorrowPlan, notes, status,
      submitted_at AS submittedAt, approved_by AS approvedBy
    FROM eod_reports
    WHERE ${where.join(" AND ")}
    ORDER BY id DESC
    `,
    params
  );

  return rows;
};

export const createEOD = async (
  data
) => {
  return db.query(
    `
    INSERT INTO eod_reports
    SET ?
    `,
    [data]
  );
};

export const getEODById = async (
  id
) => {
  const [rows] = await db.query(
    `
    SELECT *
    FROM eod_reports
    WHERE id = ?
    LIMIT 1
    `,
    [id]
  );

  return rows[0];
};

export const updateEOD = async (
  id,
  data
) => {
  return db.query(
    `
    UPDATE eod_reports
    SET ?
    WHERE id = ?
    `,
    [data, id]
  );
};