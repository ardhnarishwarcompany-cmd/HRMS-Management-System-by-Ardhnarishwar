-- Employee profile compatibility migration.
-- Safe for databases that already have these columns.
DELIMITER $$
CREATE PROCEDURE hrms_add_employee_profile_col(IN col_name VARCHAR(64), IN col_def VARCHAR(255))
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'employees' AND column_name = col_name
  ) THEN
    SET @q = CONCAT('ALTER TABLE employees ADD COLUMN `', col_name, '` ', col_def);
    PREPARE stmt FROM @q; EXECUTE stmt; DEALLOCATE PREPARE stmt;
  END IF;
END$$
DELIMITER ;
CALL hrms_add_employee_profile_col('avatar', 'VARCHAR(500) NULL');
CALL hrms_add_employee_profile_col('address', 'VARCHAR(500) NULL');
CALL hrms_add_employee_profile_col('emergency_name', 'VARCHAR(120) NULL');
CALL hrms_add_employee_profile_col('emergency_relation', 'VARCHAR(60) NULL');
CALL hrms_add_employee_profile_col('emergency_mobile', 'VARCHAR(30) NULL');
DROP PROCEDURE hrms_add_employee_profile_col;
