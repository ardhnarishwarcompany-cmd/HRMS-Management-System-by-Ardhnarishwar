# HRMS + AI Robotics + Smart Attendance — Production Integration

The production architecture uses **one canonical Node backend and one MySQL database**.

### Native modules
- Employee Verification System: `/api/evs`
- AI Robo Interview: `/api/hr-robo`
- Smart Attendance: `/api/smart-attendance`

These modules are mounted directly in `backend/app.js`; the browser does not connect to localhost ports or separate Python services.

### Public UI URLs
- EVS: https://ardhnarishwar-emp-verification.hrms.recruweb.com
- AI Robo Interview: https://ardhnarishwar-hrms-backend.recruweb.com/api/hr-robo/
- Smart Attendance: https://ardhnarishwar-hrms-backend.recruweb.com/api/smart-attendance/

The older Python/standalone source folders are retained as reference material only and are **not required** for this production deployment.
