import * as service from "./complaint.service.js";

const getUserId = (req) => {
  return (
    req.user?.id ||
    req.user?.employee_id ||
    req.user?.admin_id || // ADMIN
    req.client?.id ||
    req.user?.employeeId || // SALES
    req.employee?.employee_id
  );
};
const getRole = (req) => {
  return req.user?.role || req.salesUser?.role || req.client?.role;
};

const mapRole = (role) => {
  if (role === "SUPER_ADMIN") return "admin";
  if (role === "MANAGER") return "manager";
  if (role === "client_admin" || role === "CLIENT_ADMIN") return "client";
  if (role === "CLIENT_EMPLOYEE") return "employee";
  return role.toLowerCase();
};

export const createComplaint = async (req, res) => {
  try {
    const role = mapRole(getRole(req));
    const userId = getUserId(req);

    const data = await service.createComplaint({
      ...req.body,
      created_by_id: userId,
      created_by_role: role,
      client_id: (role === "client" || role === "employee") ? (req.client?.id || req.employee?.client_id) : null,
    });

    res.json({ success: true, data });
  } catch (err) {
    console.error("CREATE COMPLAINT ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

export const getComplaints = async (req, res) => {
  try {

    const user = {
      id: getUserId(req),
      role: mapRole(getRole(req)),
      client_id: req.client?.id || req.employee?.client_id || req.user?.client_id,
    };

    const data = await service.getComplaints(user);
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const addReply = async (req, res) => {
  try {
    const data = await service.addReply({
      complaint_id: req.params.id,
      message: req.body.message,
      sender_id: getUserId(req),
      sender_role: mapRole(getRole(req)),
      client_id: req.client?.id || req.employee?.client_id || req.user?.client_id,
    });

    res.json({ success: true, data });
  } catch (err) {
    console.error("REPLY ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

export const getSingleComplaint = async (req, res) => {
  try {
    const user = {
      id: getUserId(req),
      role: mapRole(getRole(req)),
      client_id: req.client?.id || req.employee?.client_id || req.user?.client_id,
    };

    const data = await service.getSingleComplaint(req.params.id, user);
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const updateStatus = async (req, res) => {
  try {
    if (req.employee) return res.status(403).json({success:false,message:"Employees cannot change complaint status"});
    const data = await service.updateStatus(req.params.id, req.body.status);

    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
