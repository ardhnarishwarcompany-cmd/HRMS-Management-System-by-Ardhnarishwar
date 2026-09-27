import { db } from "../../../config/db.js";

const safe = async (sql, params = []) => {
  try {
    const [rows] = await db.query(sql, params);
    return rows || [];
  } catch (error) {
    console.warn("Sales overview query skipped:", error.message);
    return [];
  }
};

export const getSalesOverview = async (_req, res) => {
  try {
    const [team, sales, calls, leads, proposals, invoices, eod, performance, targets, inventory, services] = await Promise.all([
      safe(`SELECT e.id, e.name, e.email, d.name AS department
            FROM employees e LEFT JOIN departments d ON d.id = e.departmentId
            WHERE LOWER(COALESCE(d.name,'')) LIKE '%sales%' ORDER BY e.name ASC`),
      safe(`SELECT sr.*, c.client_name, c.client_code
            FROM sales_report sr LEFT JOIN clients c ON c.id = sr.client_id
            ORDER BY sr.id DESC LIMIT 100`),
      safe(`SELECT sc.*, e.name AS employee_name, c.client_name
            FROM SuperAdmin_sales_calls sc
            LEFT JOIN employees e ON e.id = sc.employee_id
            LEFT JOIN clients c ON c.id = sc.client_id
            ORDER BY sc.id DESC LIMIT 100`),
      safe(`SELECT f.*, e.name AS employee_name
            FROM field_sales_leads f LEFT JOIN employees e ON e.id = f.created_by
            ORDER BY f.id DESC LIMIT 100`),
      safe(`SELECT p.id,p.proposal_number,p.client_name,p.client_company,p.title,p.total,p.currency,p.status,
                   p.created_by,p.created_by_role,p.sales_employee_id,p.created_at,p.updated_at,p.submitted_at,
                   p.approved_at,p.sent_at,p.responded_at,p.approval_note,p.response_note,e.name AS sales_employee_name
            FROM proposals p LEFT JOIN employees e ON e.id = p.sales_employee_id
            ORDER BY p.id DESC LIMIT 100`),
      safe(`SELECT i.*, c.client_name
            FROM invoices i LEFT JOIN clients c ON c.id = i.client_id
            ORDER BY i.id DESC LIMIT 100`),
      safe(`SELECT id,employee_id,employee_name,department,report_date,status,tasks_completed,tasks_in_progress,submitted_at,approved_by
            FROM eod_reports ORDER BY id DESC LIMIT 100`),
      safe(`SELECT id,employee_id,employee_name,department,period,avg_score,status,reviewed_by,reviewed_at
            FROM performance_records ORDER BY id DESC LIMIT 100`),
      safe(`SELECT t.*, e.name AS employee_name
            FROM super_admin_targets t LEFT JOIN employees e ON e.id = t.employee_id
            ORDER BY t.id DESC LIMIT 100`),
      safe(`SELECT * FROM sales_inventory ORDER BY id DESC LIMIT 100`),
      safe(`SELECT * FROM admin_services ORDER BY id DESC LIMIT 100`),
    ]);

    const sum = (rows, key) => rows.reduce((n, r) => n + Number(r?.[key] || 0), 0);
    const proposalCounts = proposals.reduce((a, p) => { a[p.status] = (a[p.status] || 0) + 1; return a; }, {});
    const callCounts = calls.reduce((a, c) => { const k = c.status || "unknown"; a[k] = (a[k] || 0) + 1; return a; }, {});
    const leadCounts = leads.reduce((a, l) => { const k = l.status || "unknown"; a[k] = (a[k] || 0) + 1; return a; }, {});

    res.json({
      success: true,
      data: {
        team, sales, calls, leads, proposals, invoices, eod, performance, targets, inventory, services,
        stats: {
          team: team.length,
          sales: sales.length,
          salesValue: sum(sales, "amount"),
          collected: sum(sales, "amount_paid"),
          calls: calls.length,
          leads: leads.length,
          proposals: proposals.length,
          proposalValue: sum(proposals, "total"),
          invoices: invoices.length,
          eod: eod.length,
          performance: performance.length,
          targets: targets.length,
          inventory: inventory.length,
          services: services.length,
          proposalCounts, callCounts, leadCounts,
        },
      },
    });
  } catch (error) {
    console.error("Sales overview error:", error);
    res.status(500).json({ success: false, message: "Failed to load Sales management data" });
  }
};
