import * as service from "./lead.service.js";
import xlsx from "xlsx";

// Lead sheets uploaded by different HRs/clients use inconsistent column
// headers ("Full Name", "Name", "Candidate Name", "Mobile No.", "Phone",
// "Contact Number", etc). Matching only two exact header strings left the
// name/phone blank for every other header variant, so we match
// case-insensitively against a list of known variations instead.
const NAME_HEADERS = ["full name", "name", "candidate name", "lead name", "customer name"];
const PHONE_HEADERS = [
  "mobile no.",
  "mobile no",
  "mobile number",
  "mobile",
  "phone",
  "phone no.",
  "phone no",
  "phone number",
  "contact number",
  "contact no.",
  "contact no",
];

const pickField = (row, candidates) => {
  const keys = Object.keys(row);
  for (const wanted of candidates) {
    const match = keys.find((k) => k.trim().toLowerCase() === wanted);
    if (match && String(row[match] ?? "").trim() !== "") return row[match];
  }
  return undefined;
};

// 🔥 UPLOAD
export const uploadLeads = async (req, res) => {
  try {
    const file = req.file;
    const { assignedTo } = req.body; // 🔥 HR ID

    if (!assignedTo) {
      return res.status(400).json({ message: "HR is required" });
    }

    const workbook = xlsx.read(file.buffer);
    const sheet = workbook.Sheets[workbook.SheetNames[0]];
    const data = xlsx.utils.sheet_to_json(sheet);

    const leads = data.map((row) => ({
      name: pickField(row, NAME_HEADERS) || row.name,
      phone: pickField(row, PHONE_HEADERS) || row.phone,
    }));

    // 🔥 CREATE BATCH
    const batchId = await service.createBatch(
      file.originalname,
      leads.length,
      req.user.id,
      assignedTo // 🔥 ADD THIS
    );

    // 🔥 ASSIGN HR DURING INSERT
    const finalLeads = leads.map((l) => ({
      ...l,
      batch_id: batchId,
      assigned_to: assignedTo,
      assigned_by: req.user.id,
    }));

    await service.insertLeads(finalLeads);

    res.json({ success: true });
  } catch (err) {
    console.error("UPLOAD ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// 🔥 ASSIGN
export const assignLead = async (req, res) => {
  try {
    await service.assignLead(
      req.params.id,
      req.body.assignedTo,
      req.user.id
    );

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🔥 UPDATE
export const updateLead = async (req, res) => {
  try {
    const updated = await service.updateLead(req.params.id, req.body);
    if (!updated) return res.status(404).json({ success: false, message: "Lead not found" });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const deleteLead = async (req, res) => {
  try {
    const deleted = await service.deleteLead(req.params.id);
    if (!deleted) return res.status(404).json({ success: false, message: "Lead not found" });
    res.json({ success: true, message: "Lead deleted" });
  } catch (err) {
    console.error("DELETE LEAD ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// 🔥 ADMIN VIEW
export const getAllLeads = async (req, res) => {
  const data = await service.getAllLeads();
  res.json({ success: true, data });
};

// 🔥 HR VIEW
export const getMyLeads = async (req, res) => {
  const data = await service.getMyLeads(req.user.id);
  res.json({ success: true, data });
};

export const getAllBatches = async (req, res) => {
  const data = await service.getAllBatches();
  res.json({ success: true, data });
};

// 🔥 RENAME BATCH (edit — three-dot menu)
export const updateBatch = async (req, res) => {
  try {
    const { file_name } = req.body;
    if (!file_name || !String(file_name).trim()) {
      return res.status(400).json({ success: false, message: "File name is required" });
    }
    const updated = await service.renameBatch(req.params.id, file_name);
    if (!updated) return res.status(404).json({ success: false, message: "Batch not found" });
    res.json({ success: true, message: "Batch updated" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 🔥 DELETE BATCH (and its leads — three-dot menu)
export const deleteBatch = async (req, res) => {
  try {
    const deleted = await service.deleteBatch(req.params.id);
    if (!deleted) return res.status(404).json({ success: false, message: "Batch not found" });
    res.json({ success: true, message: "Batch deleted" });
  } catch (err) {
    console.error("DELETE BATCH ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

