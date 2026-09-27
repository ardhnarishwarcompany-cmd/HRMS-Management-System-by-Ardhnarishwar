import * as service from "./clientLead.service.js";
import xlsx from "xlsx";

// Resolve the caller's tenant scope from clientUnifiedAuthMiddleware.
//   client_admin     -> req.client   { id, client_code }
//   CLIENT_EMPLOYEE  -> req.employee { employee_id, client_id }
const scopeOf = (req) => {
  // Unified auth attaches req.client for both roles. Check employee first
  // so a CLIENT_EMPLOYEE can never accidentally be treated as an admin.
  if (req.employee?.employee_id && req.employee?.client_id) {
    return {
      clientId: Number(req.employee.client_id),
      employeeId: Number(req.employee.employee_id),
      isAdmin: false,
    };
  }
  if (req.client?.id) {
    return {
      clientId: Number(req.client.id),
      employeeId: null,
      isAdmin: String(req.client.role || "").toUpperCase() === "CLIENT_ADMIN",
    };
  }
  return null;
};

const fail = (res, status, message) => res.status(status).json({ success: false, message });

// 🔥 UPLOAD (client admin only)
export const uploadClientLeads = async (req, res) => {
  try {
    const scope = scopeOf(req);
    if (!scope?.isAdmin) return fail(res, 403, "Only client admins can upload leads");
    const file = req.file;
    if (!file) return fail(res, 400, "Excel file is required. Please choose an .xlsx or .xls file.");
    if (!/\.(xlsx|xls)$/i.test(file.originalname || "")) {
      return fail(res, 400, "Invalid file type. Please upload an .xlsx or .xls Excel file.");
    }
    if (file.size > 10 * 1024 * 1024) {
      return fail(res, 400, "Excel file is too large. Maximum allowed size is 10 MB.");
    }

    const assignedTo = Number(String(req.body?.assignedTo ?? "").trim());
    if (!Number.isInteger(assignedTo) || assignedTo <= 0) return fail(res, 400, "Please select a valid employee before uploading.");

    if (service.validateAssignedEmployee) {
      const valid = await service.validateAssignedEmployee(scope.clientId, assignedTo);
      if (!valid) return fail(res, 400, "Selected employee does not belong to this client or is inactive.");
    }

    const workbook = xlsx.read(file.buffer, { type: "buffer", cellDates: true });
    if (!workbook.SheetNames.length) return fail(res, 400, "The uploaded Excel file has no worksheet.");
    const sheet = workbook.Sheets[workbook.SheetNames[0]];
    const raw = xlsx.utils.sheet_to_json(sheet, { defval: "" });
    if (!raw.length) return fail(res, 400, "The Excel sheet is empty.");

    const normalize = (v) => String(v ?? "").trim().toLowerCase().replace(/[^a-z0-9]/g, "");
    const pick = (row, aliases) => {
      const keys = Object.keys(row);
      const found = keys.find(k => aliases.includes(normalize(k)));
      return found ? String(row[found] ?? "").trim() : "";
    };
    const leads = raw.map(row => ({
      name: pick(row, ["fullname","name","leadname","customername","contactname","firstname"]),
      phone: pick(row, ["mobileno","mobile","phone","phonenumber","contactnumber"]),
      email: pick(row, ["email","emailid","emailaddress"]),
      company: pick(row, ["company","companyname","organisation","organization"]),
    })).filter(l => l.name || l.phone || l.email);

    if (!leads.length) return fail(res, 400, "No valid leads found. Use columns such as Full Name, Mobile No., Email or Company.");

    const batchId = await service.createBatch(file.originalname, leads.length, scope.clientId, assignedTo);
    await service.insertLeads(leads, batchId, scope.clientId, assignedTo);
    res.json({ success:true, data:{batchId,total:leads.length}, message:`${leads.length} leads uploaded and assigned successfully.` });
  } catch (err) {
    console.error("UPLOAD ERROR:", err);
    fail(res, 400, err.message || "Lead upload failed");
  }
};
// 🔥 BATCHES (admin: all batches of the client; employee: only batches with leads assigned to them)
export const getClientBatches = async (req, res) => {
  try {
    const scope = scopeOf(req);
    if (!scope) return fail(res, 403, "Invalid role");
    const data = await service.getBatches(scope.clientId, scope.employeeId);
    res.json({ success: true, data });
  } catch (err) {
    console.error("BATCH ERROR:", err);
    fail(res, 500, err.message);
  }
};

// 🔥 LEADS OF ONE BATCH (tenant-scoped; employees only see their own rows)
export const getClientLeadsByBatch = async (req, res) => {
  try {
    const scope = scopeOf(req);
    if (!scope) return fail(res, 403, "Invalid role");
    const data = await service.getLeadsByBatch(req.params.id, scope.clientId, scope.employeeId);
    res.json({ success: true, data });
  } catch (err) {
    console.error("LEADS BY BATCH ERROR:", err);
    fail(res, 500, err.message);
  }
};

// 🔥 MY LEADS (client employee)
export const getEmployeeLeads = async (req, res) => {
  try {
    const scope = scopeOf(req);
    if (!scope) return fail(res, 403, "Invalid role");
    if (scope.isAdmin) {
      // admins have no "my" leads — return all leads of the tenant instead of crashing
      const data = await service.getClientLeads(scope.clientId);
      return res.json({ success: true, data });
    }
    const data = await service.getEmployeeLeads(scope.employeeId, scope.clientId);
    res.json({ success: true, data });
  } catch (err) {
    console.error("MY LEADS ERROR:", err);
    fail(res, 500, err.message);
  }
};

// 🔥 UPDATE (scoped to the caller's tenant; employees may only update leads assigned to them)
export const updateClientLead = async (req, res) => {
  try {
    const scope = scopeOf(req);
    if (!scope) return fail(res, 403, "Invalid role");
    const { status, remarks } = req.body || {};
    if (!status) return fail(res, 400, "status is required");

    const affected = await service.updateLead(req.params.id, { status, remarks }, scope.clientId, scope.employeeId);
    if (!affected) return fail(res, 404, "Lead not found");
    res.json({ success: true });
  } catch (err) {
    console.error("UPDATE LEAD ERROR:", err);
    fail(res, 500, err.message);
  }
};
