import * as service from "./clientAttendance.service.js";

const fail = (res, err) =>
  res.status(err?.status || 400).json({ success: false, message: err?.message || "Request failed" });

export const createAttendance = async (req, res) => {
  try {
    const id = await service.createAttendanceService(req.client.client_code, req.body);
    res.json({ success: true, id });
  } catch (err) { fail(res, err); }
};

export const listAttendance = async (req, res) => {
  try {
    const data = await service.listAttendanceService(req.client.client_code, req.employee?.employee_id);
    res.json({ success: true, data });
  } catch (err) { fail(res, err); }
};

export const updateAttendance = async (req, res) => {
  try {
    const data = await service.updateAttendanceService(req.client.client_code, req.params.id, req.body);
    res.json({ success: true, data });
  } catch (err) { fail(res, err); }
};

export const deleteAttendance = async (req, res) => {
  try {
    await service.deleteAttendanceService(req.client.client_code, req.params.id);
    res.json({ success: true });
  } catch (err) { fail(res, err); }
};
