import { db } from "./db.js";

/**
 * Initializes all Smart Attendance MySQL tables natively inside hrms_db.
 * Replaces external MongoDB dependency with native MySQL schema.
 */
export const initSmartAttendanceDb = async () => {
  console.log("[db] Initializing Smart Attendance MySQL tables...");

  // 1. Smart Companies Workspace Table
  await db.query(`
    CREATE TABLE IF NOT EXISTS smart_companies (
      id INT AUTO_INCREMENT PRIMARY KEY,
      company_id VARCHAR(50) NOT NULL UNIQUE,
      name VARCHAR(150) NOT NULL,
      code VARCHAR(50) UNIQUE,
      status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )
  `);

  // 2. Smart Branches Table
  await db.query(`
    CREATE TABLE IF NOT EXISTS smart_branches (
      id INT AUTO_INCREMENT PRIMARY KEY,
      branch_id VARCHAR(50) NOT NULL,
      company_id VARCHAR(50) NOT NULL,
      name VARCHAR(120) NOT NULL,
      lat DECIMAL(10, 8) DEFAULT 28.626001,
      lng DECIMAL(11, 8) DEFAULT 77.378001,
      radius_m INT DEFAULT 50,
      subnet VARCHAR(50) DEFAULT '192.168.29',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uniq_company_branch (company_id, branch_id)
    )
  `);

  // 3. Smart Departments Table
  await db.query(`
    CREATE TABLE IF NOT EXISTS smart_departments (
      id INT AUTO_INCREMENT PRIMARY KEY,
      company_id VARCHAR(50) NOT NULL,
      name VARCHAR(100) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uniq_company_dept (company_id, name)
    )
  `);

  // 4. Smart Shifts Table
  await db.query(`
    CREATE TABLE IF NOT EXISTS smart_shifts (
      id INT AUTO_INCREMENT PRIMARY KEY,
      shift_id VARCHAR(50) NOT NULL,
      company_id VARCHAR(50) NOT NULL,
      name VARCHAR(100) NOT NULL,
      start_time TIME NOT NULL DEFAULT '09:00:00',
      end_time TIME NOT NULL DEFAULT '18:00:00',
      grace_minutes INT DEFAULT 15,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uniq_company_shift (company_id, shift_id)
    )
  `);

  // 5. Smart Attendance Logs Table
  await db.query(`
    CREATE TABLE IF NOT EXISTS smart_attendance (
      id INT AUTO_INCREMENT PRIMARY KEY,
      company_id VARCHAR(50) NOT NULL,
      emp_id VARCHAR(50) NOT NULL,
      date DATE NOT NULL,
      check_in TIME NULL,
      check_out TIME NULL,
      check_type VARCHAR(50) DEFAULT 'WIFI',
      status ENUM('PRESENT', 'LATE', 'HALF_DAY', 'ABSENT', 'LEAVE', 'WFH') DEFAULT 'PRESENT',
      lat DECIMAL(10, 8) NULL,
      lng DECIMAL(11, 8) NULL,
      face_matched TINYINT(1) DEFAULT 0,
      remarks TEXT,
      timestamp_utc TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_emp_date (company_id, emp_id, date),
      INDEX idx_company_date (company_id, date)
    )
  `);

  // 6. Smart Leaves Table
  await db.query(`
    CREATE TABLE IF NOT EXISTS smart_leaves (
      id INT AUTO_INCREMENT PRIMARY KEY,
      company_id VARCHAR(50) NOT NULL,
      emp_id VARCHAR(50) NOT NULL,
      leave_type VARCHAR(50) NOT NULL,
      start_date DATE NOT NULL,
      end_date DATE NOT NULL,
      status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
      reason TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // 7. Smart Field Visits Table
  await db.query(`
    CREATE TABLE IF NOT EXISTS smart_field_visits (
      id INT AUTO_INCREMENT PRIMARY KEY,
      company_id VARCHAR(50) NOT NULL,
      emp_id VARCHAR(50) NOT NULL,
      client_name VARCHAR(150) NOT NULL,
      location VARCHAR(255),
      lat DECIMAL(10, 8) NULL,
      lng DECIMAL(11, 8) NULL,
      notes TEXT,
      timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // 8. Smart System Policies Table
  await db.query(`
    CREATE TABLE IF NOT EXISTS smart_policies (
      id INT AUTO_INCREMENT PRIMARY KEY,
      company_id VARCHAR(50) NOT NULL UNIQUE,
      face_required TINYINT(1) DEFAULT 1,
      wifi_required TINYINT(1) DEFAULT 0,
      gps_required TINYINT(1) DEFAULT 0,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Seed default company workspace if empty
  const [existingComp] = await db.query(
    "SELECT id FROM smart_companies WHERE company_id = 'GLOBAL_ENT' LIMIT 1"
  );
  if (!existingComp.length) {
    await db.query(`
      INSERT INTO smart_companies (company_id, name, code, status)
      VALUES ('GLOBAL_ENT', 'Global Attendance Enterprise', 'GLOBAL', 'active')
    `);
  }

  console.log("[db] Smart Attendance MySQL tables initialized successfully!");
};
