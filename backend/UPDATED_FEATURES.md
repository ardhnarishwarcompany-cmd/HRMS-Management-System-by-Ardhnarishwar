# Backend Update

Employee profile save/avatar endpoints are migration-safe for optional fields.
AI Chat gives employee-specific answers before company-wide intents.
SOP download endpoint supports both sop_version_files and legacy sop_versions records and resolves relative/absolute paths safely.
Migration included: migrations/2026-09-09_employee_profile_optional_fields.sql
