/**
 * Ardhnarishwar HRMS — production portal routing.
 * All public portal destinations use the live DNS records.
 * AI Interview and Smart Attendance are served by the unified HRMS backend.
 */
window.HRMS_CONFIG = window.HRMS_CONFIG || {};
window.HRMS_CONFIG.isProduction = true;

window.HRMS_PORTAL_CONFIG = {
  isProduction: true,
  production: {
    "admin": "https://ardhnarishwar-admin.hrms.recruweb.com",
    "client": "https://ardhnarishwar-client.hrms.recruweb.com",
    "it": "https://ardhnarishwar-it.hrms.recruweb.com",
    "sales": "https://ardhnarishwar-sales.hrms.recruweb.com",
    "hr": "https://ardhnarishwar-hr.hrms.recruweb.com",
    "employee": "https://ardhnarishwar-employee.hrms.recruweb.com",
    "evs": "https://ardhnarishwar-emp-verification.hrms.recruweb.com",
    "aiRobotics": "https://ardhnarishwar-hrms-backend.recruweb.com/api/hr-robo/",
    "smartAttendance": "https://ardhnarishwar-hrms-backend.recruweb.com/api/smart-attendance/",
    "backendApi": "https://ardhnarishwar-hrms-backend.recruweb.com"
},
  local: {
    "admin": "https://ardhnarishwar-admin.hrms.recruweb.com",
    "client": "https://ardhnarishwar-client.hrms.recruweb.com",
    "it": "https://ardhnarishwar-it.hrms.recruweb.com",
    "sales": "https://ardhnarishwar-sales.hrms.recruweb.com",
    "hr": "https://ardhnarishwar-hr.hrms.recruweb.com",
    "employee": "https://ardhnarishwar-employee.hrms.recruweb.com",
    "evs": "https://ardhnarishwar-emp-verification.hrms.recruweb.com",
    "aiRobotics": "https://ardhnarishwar-hrms-backend.recruweb.com/api/hr-robo/",
    "smartAttendance": "https://ardhnarishwar-hrms-backend.recruweb.com/api/smart-attendance/",
    "backendApi": "https://ardhnarishwar-hrms-backend.recruweb.com"
},
  getUrl(key) {
    if (window.HRMS_CONFIG.urls && window.HRMS_CONFIG.urls[key]) {
      return window.HRMS_CONFIG.urls[key];
    }
    return this.production[key] || "#";
  }
};
