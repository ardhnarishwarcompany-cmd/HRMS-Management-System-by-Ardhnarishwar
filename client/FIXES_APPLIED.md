# Fixes applied - Client Portal

1. Lead upload:
   - Accepts .xlsx and .xls in the UI.
   - Validates file type and 10 MB size before upload.
   - Keeps tenant/employee role handling aligned with backend.

2. Sales Reports:
   - Removed the Recharts aspect conflict from the fixed-height chart containers.
   - Added debounce/min-height safeguards to prevent negative-size ResponsiveContainer warnings.

3. Client Employee Chat:
   - Client Admin chat now has an Employees tab.
   - Employee conversations belonging to the logged-in client are listed automatically.
   - Existing employee messages are loaded and displayed.
   - Client Admin can reply to the employee from the same chat section.
   - Existing HR chat and employee-side chat flow are preserved.
