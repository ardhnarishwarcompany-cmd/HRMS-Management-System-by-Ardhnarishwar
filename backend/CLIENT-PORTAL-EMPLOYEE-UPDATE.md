# Client Portal / Employee Login Update

Implemented role-aware client portal controls without changing the existing project architecture.

## Employee login
- Employee Management and Employee Search hidden and blocked.
- Interview Tracker and Performance Report hidden and blocked.
- Finance Dashboard, Inventory, Assets, GST & TDS and Audit Logs hidden and blocked.
- Attendance is restricted to the logged-in employee.
- Payroll is restricted to the logged-in employee and own PDF download.
- Performance is restricted to the logged-in employee.
- Work Policy is read-only and shows all client policies.
- Work Assignment is restricted to assignments assigned to the logged-in employee.
- Deliverables can be uploaded against an assigned task (documents, Excel/data, source code, video and other files).
- Leave Requests are employee-create only; approval/rejection is client-admin only, with rejection note required.
- Offer Letters are employee-view/download only and ownership is enforced.
- Complaint Box is employee-create/own-conversation only; client administrators can view and reply.
- Purchase Orders remain available for employees to create; approval/status actions remain client-admin only.

## Client administrator
- Employee Management remains available and employee detail modal now includes sales, assignments, attendance and latest payroll KPI cards.
- Sales Report is a graph/pie-chart dashboard grouped by employee.
- Client SOPs/work policies are visible to employees; employee SOP decisions are recorded.
- Client can see assignment deliverables uploaded by employees.

## Offer letter PDF
The generated offer letter now uses the Ardhnarishwar logo from `assets/logo.png`, dynamic employee/client details and a structured five-page A4 format based on the supplied offer-letter reference.

## Database migration
Run:
`migrations/2026-09-09_client_portal_employee_controls.sql`

The application also bootstraps the new tables/columns defensively at runtime where needed.
