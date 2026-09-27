-- Client portal employee controls, offer-letter ownership and assignment deliverables.
DELIMITER $$
DROP PROCEDURE IF EXISTS hrms_client_portal_add_col$$
CREATE PROCEDURE hrms_client_portal_add_col(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl VARCHAR(500))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tbl AND COLUMN_NAME=col) THEN
    SET @sql = CONCAT('ALTER TABLE `',tbl,'` ADD COLUMN `',col,'` ',ddl);
    PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END$$
DELIMITER ;
CALL hrms_client_portal_add_col('client_offer_letters','client_employee_id','INT NULL');
CALL hrms_client_portal_add_col('client_offer_letters','department','VARCHAR(150) NULL');
CALL hrms_client_portal_add_col('client_offer_letters','work_mode','VARCHAR(40) DEFAULT ''WFO/WFH''');
CALL hrms_client_portal_add_col('client_offer_letters','internship_duration','VARCHAR(100) NULL');
CALL hrms_client_portal_add_col('client_offer_letters','working_days','VARCHAR(100) DEFAULT ''6 Days per Week''');
CALL hrms_client_portal_add_col('client_offer_letters','office_timings','VARCHAR(100) DEFAULT ''9:00 AM – 6:00 PM''');
CALL hrms_client_portal_add_col('client_offer_letters','lunch_break','VARCHAR(100) DEFAULT ''1:00 PM – 1:30 PM''');
CALL hrms_client_portal_add_col('client_offer_letters','notice_period','VARCHAR(100) DEFAULT ''1 Month''');
CALL hrms_client_portal_add_col('client_offer_letters','responsibilities','TEXT NULL');
CALL hrms_client_portal_add_col('purchase_orders','created_by_employee_id','INT NULL');
DROP PROCEDURE IF EXISTS hrms_client_portal_add_col;

CREATE TABLE IF NOT EXISTS client_sop_acknowledgements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  client_id INT NOT NULL,
  sop_id INT NOT NULL,
  version INT NOT NULL,
  employee_id INT NOT NULL,
  status ENUM('accepted','rejected') NOT NULL,
  note VARCHAR(500) NULL,
  decided_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_client_sop_emp_ver (client_id,sop_id,version,employee_id)
);

CREATE TABLE IF NOT EXISTS client_assignment_deliverables (
  id INT AUTO_INCREMENT PRIMARY KEY,
  client_id INT NOT NULL,
  assignment_id INT NOT NULL,
  employee_id INT NOT NULL,
  type VARCHAR(40) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_size BIGINT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_assignment(assignment_id),
  INDEX idx_employee(employee_id)
);
