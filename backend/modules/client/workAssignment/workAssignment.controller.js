import path from "path";
import { db } from "../../../config/db.js";

/* =========================================
GET ASSIGNMENTS (HR specific)
========================================= */
export const getAssignments = async (req, res) => {
  try {
    const clientCode =
      req.client?.client_code || req.employee?.client_code;

    if (!clientCode) {
      return res.status(401).json({ success: false });
    }

    const [clientRows] = await db.query(
      `SELECT id FROM clients WHERE client_code = ? LIMIT 1`,
      [clientCode]
    );

    const clientId = clientRows[0].id;

    const { status, priority } = req.query;

    let query = `
      SELECT 
        t.*,
        e.name AS employee_name,
        e.employeeCode,
        d.name AS department_name
      FROM client_work_assignments t
      JOIN client_employees e ON e.id = t.employee_id
      LEFT JOIN departments d ON d.id = e.departmentId
      WHERE t.client_id = ?
    `;

    const params = [clientId];

    // ✅ employee → only own data
    if (req.employee) {
      query += " AND t.employee_id = ?";
      params.push(req.employee.employee_id);
    }

    if (status) {
      query += " AND t.status = ?";
      params.push(status);
    }

    if (priority) {
      query += " AND t.priority = ?";
      params.push(priority);
    }

    query += " ORDER BY t.created_at DESC";

    const [rows] = await db.query(query, params);

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("GET ASSIGNMENTS ERROR:", err);
    res.status(500).json({ success: false });
  }
};

/* =========================================
CREATE ASSIGNMENT
========================================= */
export const createAssignment = async (req, res) => {
  try {
    if (req.employee) return res.status(403).json({success:false,message:"Only client administrators can manage assignments"});
    const clientCode = req.client?.client_code;

    if (!clientCode) {
      return res.status(403).json({ success: false });
    }

    const [clientRows] = await db.query(
      `SELECT id FROM clients WHERE client_code = ? LIMIT 1`,
      [clientCode],
    );

    const clientId = clientRows[0].id;

    const { title, employeeId, targetValue, unit, deadline, priority } =
      req.body;

    await db.query(
      `INSERT INTO client_work_assignments
      (client_id, employee_id, title, target_value, unit, deadline, priority, created_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        clientId,
        employeeId,
        title,
        targetValue || 0,
        unit || "",
        deadline || null,
        priority || "medium",
        clientId,
      ],
    );
  

    res.json({ success: true });
  } catch (err) {
    console.error("CREATE ERROR:", err);
    res.status(500).json({ success: false });
  }
};

/* =========================================
UPDATE ASSIGNMENT
========================================= */
export const updateAssignment = async (req, res) => {
  try {
    if (req.employee) return res.status(403).json({success:false,message:"Only client administrators can manage assignments"});
    const clientCode = req.client?.client_code;

    if (!clientCode) {
      return res.status(403).json({
        success: false,
        message: "Admin access required",
      });
    }

    const [clientRows] = await db.query(
      `SELECT id FROM clients WHERE client_code = ? LIMIT 1`,
      [clientCode],
    );

    const clientId = clientRows[0].id;

    const { id } = req.params;
    const { title, targetValue, unit, deadline, priority } = req.body;

    await db.query(
      `UPDATE client_work_assignments SET
        title = ?,
        target_value = ?,
        unit = ?,
        deadline = ?,
        priority = ?
      WHERE id = ? AND client_id = ?`,
      [title, targetValue, unit, deadline, priority, id, clientId],
    );

    res.json({ success: true });
  } catch (err) {
    console.error("UPDATE ERROR:", err);
    res.status(500).json({ success: false });
  }
};

/* =========================================
UPDATE STATUS
========================================= */
export const updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { current_value, status } = req.body;

    if (!req.employee) {
      return res.status(403).json({
        success: false,
        message: "Employee access only",
      });
    }

    await db.query(
      `UPDATE client_work_assignments 
       SET current_value = ?, status = ?
       WHERE id = ? AND employee_id = ?`,
      [
        current_value || 0,
        status || "in_progress",
        id,
        req.employee.employee_id,
      ]
    );

    res.json({ success: true });
  } catch (err) {
    console.error("UPDATE PROGRESS ERROR:", err);
    res.status(500).json({ success: false });
  }
};
/* =========================================
DELETE
========================================= */
export const deleteAssignment = async (req, res) => {
  try {
    if (req.employee) return res.status(403).json({success:false,message:"Only client administrators can manage assignments"});
    const clientCode = req.client?.client_code;

    if (!clientCode) {
      return res.status(403).json({
        success: false,
        message: "Admin access required",
      });
    }

    const [clientRows] = await db.query(
      `SELECT id FROM clients WHERE client_code = ? LIMIT 1`,
      [clientCode],
    );

    const clientId = clientRows[0].id;

    const { id } = req.params;

    await db.query(
      `DELETE FROM client_work_assignments 
       WHERE id = ? AND client_id = ?`,
      [id, clientId],
    );

    res.json({ success: true });
  } catch (err) {
    console.error("DELETE ERROR:", err);
    res.status(500).json({ success: false });
  }
};

/* =========================================
   ASSIGNMENT DELIVERABLES
========================================= */
export const listAssignmentDeliverables = async (req,res) => {
  try {
    const clientId = Number(req.client?.id || req.employee?.client_id);
    const assignmentId = Number(req.params.id);
    const [[assignment]] = await db.query(`SELECT id,employee_id FROM client_work_assignments WHERE id=? AND client_id=?`,[assignmentId,clientId]);
    if(!assignment) return res.status(404).json({success:false,message:"Assignment not found"});
    if(req.employee && Number(assignment.employee_id)!==Number(req.employee.employee_id)) return res.status(403).json({success:false,message:"You can only view deliverables for your own assignment"});
    await db.query(`CREATE TABLE IF NOT EXISTS client_assignment_deliverables (id INT AUTO_INCREMENT PRIMARY KEY, client_id INT NOT NULL, assignment_id INT NOT NULL, employee_id INT NOT NULL, type VARCHAR(40) NOT NULL, title VARCHAR(255) NOT NULL, description TEXT NULL, file_path VARCHAR(500) NOT NULL, file_name VARCHAR(255) NOT NULL, file_size BIGINT DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, INDEX idx_assignment(assignment_id), INDEX idx_employee(employee_id))`);
    const [rows] = await db.query(`SELECT * FROM client_assignment_deliverables WHERE assignment_id=? AND client_id=? ORDER BY created_at DESC`,[assignmentId,clientId]);
    res.json({success:true,data:rows.map(r=>({...r,file_url:`/uploads/assignment-deliverables/${r.file_path.split(/[\\/]/).pop()}`}))});
  } catch(e){console.error(e);res.status(500).json({success:false,message:e.message})}
};

export const createAssignmentDeliverable = async (req,res) => {
  try {
    if(!req.employee?.employee_id) return res.status(403).json({success:false,message:"Only assigned employees can upload deliverables"});
    const clientId=Number(req.employee.client_id), assignmentId=Number(req.params.id);
    const [[assignment]]=await db.query(`SELECT id,employee_id,title FROM client_work_assignments WHERE id=? AND client_id=?`,[assignmentId,clientId]);
    if(!assignment || Number(assignment.employee_id)!==Number(req.employee.employee_id)) return res.status(403).json({success:false,message:"This assignment is not assigned to you"});
    if(!req.file)return res.status(400).json({success:false,message:"Please select a file"});
    const type=String(req.body.type||'document').toLowerCase();
    const allowed = {
      video: ['.mp4','.mov','.avi','.mkv','.webm','.m4v'],
      document: ['.pdf','.txt','.rtf','.odt'],
      word: ['.doc','.docx'],
      excel: ['.xls','.xlsx','.csv'],
      code: ['.js','.jsx','.ts','.tsx','.py','.java','.c','.cpp','.cs','.php','.html','.css','.json','.xml','.sql','.sh','.yml','.yaml','.md','.zip'],
      other: []
    };
    if (!allowed[type]) return res.status(400).json({success:false,message:'Invalid deliverable type'});
    const ext=path.extname(req.file.originalname).toLowerCase();
    if (allowed[type].length && !allowed[type].includes(ext)) return res.status(400).json({success:false,message:`Invalid file for ${type}. Allowed: ${allowed[type].join(', ')}`});
    const title=String(req.body.title||req.file.originalname).trim(); if(!title)return res.status(400).json({success:false,message:"Deliverable title is required"});
    await db.query(`CREATE TABLE IF NOT EXISTS client_assignment_deliverables (id INT AUTO_INCREMENT PRIMARY KEY, client_id INT NOT NULL, assignment_id INT NOT NULL, employee_id INT NOT NULL, type VARCHAR(40) NOT NULL, title VARCHAR(255) NOT NULL, description TEXT NULL, file_path VARCHAR(500) NOT NULL, file_name VARCHAR(255) NOT NULL, file_size BIGINT DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, INDEX idx_assignment(assignment_id), INDEX idx_employee(employee_id))`);
    const [r]=await db.query(`INSERT INTO client_assignment_deliverables (client_id,assignment_id,employee_id,type,title,description,file_path,file_name,file_size) VALUES (?,?,?,?,?,?,?,?,?)`,[clientId,assignmentId,req.employee.employee_id,type,title,String(req.body.description||'').trim()||null,req.file.path,req.file.originalname,req.file.size]);
    res.status(201).json({success:true,id:r.insertId,message:"Deliverable uploaded successfully"});
  }catch(e){console.error(e);res.status(500).json({success:false,message:e.message})}
};
