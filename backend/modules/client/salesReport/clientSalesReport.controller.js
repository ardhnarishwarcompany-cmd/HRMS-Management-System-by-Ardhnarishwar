import { createClientSalesReportService, getClientSalesReportService, updateClientSalesReportService } from "./clientSalesReport.service.js";

const scopeOf = (req) => ({
  clientCode: req.client?.client_code || req.employee?.client_code,
  employeeId: req.employee?.employee_id || null,
  isEmployee: Boolean(req.employee?.employee_id),
});

export const createClientSalesReport = async (req, res) => {
  try {
    const scope = scopeOf(req);
    if (!scope.clientCode) return res.status(401).json({success:false,message:"Client context missing"});
    const id = await createClientSalesReportService(scope.clientCode, scope.isEmployee ? scope.employeeId : (req.body.employee_id || null), req.body, scope);
    res.status(201).json({ success:true, id, message:"Sales record added successfully" });
  } catch (err) { console.error(err); res.status(400).json({success:false,message:err.message}); }
};

export const getClientSalesReport = async (req, res) => {
  try {
    const scope = scopeOf(req);
    const data = await getClientSalesReportService(scope.clientCode, scope.employeeId);
    res.json({success:true,data});
  } catch (err) { console.error(err); res.status(500).json({success:false,message:err.message}); }
};

export const updateClientSalesReport = async (req,res) => {
  try {
    const scope = scopeOf(req);
    await updateClientSalesReportService(scope.clientCode, req.params.id, req.body, scope);
    res.json({success:true,message:"Sales record updated successfully"});
  } catch(err) { console.error(err); res.status(400).json({success:false,message:err.message}); }
};
