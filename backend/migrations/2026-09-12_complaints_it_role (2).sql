-- 2026-09-12: Fix IT complaints silently disappearing
--
-- Root cause: `complaints.created_by_role` and `complaint_replies.sender_role`
-- were both defined as ENUM('employee','hr','client','sales','admin') —
-- 'it' (and 'manager') were never added, even though the application code
-- (modules/complaint) has always written 'it' for complaints/replies coming
-- from the IT portal.
--
-- Effect in production: inserting an ENUM value that isn't in the allowed
-- list either fails the INSERT outright (strict SQL mode) or MySQL silently
-- stores it as the enum's blank/invalid value (non-strict mode). Either way,
-- every later query filtering `WHERE created_by_role = 'it'` matches zero
-- rows — so an IT complaint looked like it "submitted successfully" but then
-- never appeared anywhere again, and any reply to it could never be saved
-- with sender_role = 'it' either.
--
-- This migration only widens the two ENUM columns; it does not touch any
-- existing data. (Any rows that were already silently corrupted to an empty
-- created_by_role by the old strict/blank-enum behavior cannot be recovered
-- automatically — there is no way to tell which department they came from
-- after the fact.)

ALTER TABLE complaints
  MODIFY COLUMN created_by_role ENUM(
    'employee',
    'hr',
    'client',
    'sales',
    'admin',
    'it',
    'manager'
  ) NOT NULL;

ALTER TABLE complaint_replies
  MODIFY COLUMN sender_role ENUM(
    'employee',
    'hr',
    'client',
    'sales',
    'admin',
    'it',
    'manager'
  ) NOT NULL;
