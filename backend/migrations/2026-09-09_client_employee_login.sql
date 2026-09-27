-- Client employee login support.
-- The current initDb schema already defines password_hash; this migration is
-- intentionally idempotent for databases created before that column existed.
SET @column_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'client_employees'
    AND column_name = 'password_hash'
);

SET @sql := IF(
  @column_exists = 0,
  'ALTER TABLE client_employees ADD COLUMN password_hash VARCHAR(255) NULL AFTER email',
  'SELECT 1'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
