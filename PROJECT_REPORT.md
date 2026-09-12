# ARDHNARISHWAR HRMS — COMPLETE PROJECT REPORT

**Project:** Recruweb / Ardhnarishwar Human Resource Management System (HRMS) with Integrated Employee Verification System (EVS)
**Architecture:** Multi-portal micro-frontend suite with shared backend + standalone verification microservice
**Report Date:** August 2026
**Status:** All portals operational, EVS fully integrated with HRMS

---

## TABLE OF CONTENTS

1. Executive Summary
2. Technology Stack
3. System Architecture
4. Project Structure
5. Portal Inventory (Ports & Roles)
6. Database Design
7. Data Flow Diagrams (DFD Level 0, 1, 2)
8. User Flow Diagrams (per role)
9. Module-by-Module Functionality
10. Employee Verification System (EVS) — Deep Dive
11. HRMS ↔ EVS Integration Bridge (Implemented)
12. Job Board & ATS Module
13. Security Implementation
14. Everything Implemented During This Project
15. Testing & Verification Performed
16. API Reference Summary
17. Known Constraints & Future Enhancements

---

## 1. EXECUTIVE SUMMARY

The Ardhnarishwar HRMS is a complete enterprise HR platform composed of **six role-specific
React portals** (Super Admin, HR, IT, Sales, Client, Employee) served by **one shared
Node.js/Express backend** (port 5000) over **one MySQL database (`hrms_db`)**, plus a
**standalone Employee Verification System** (React + FastAPI + its own MySQL database
`employee_verification`) that is now bridged two-way with the main HRMS.

Core capabilities:

- Full employee lifecycle: recruitment (Job Board + ATS) → interview → offer letter →
  joining → onboarding → attendance → payroll → exit
- Identity & compliance: Aadhaar/PAN verification (Verhoeff checksum validated),
  document verification, background checks, employment-history validation, audit logs
- Client-facing operations: client employees, attendance, leave approvals, invoices,
  offer letters, SOP library, sales reports
- IT operations: task assignment, timesheets, EOD reports, bug tracking, code reviews,
  milestones, deployments, SOPs
- Sales operations: leads, batches, EOD reports, targets, commissions
- Cross-cutting: AI chat/assistant, notifications, messaging, OTP auth, geo-attendance,
  web forms, visitor management, birthdays, complaints, benefits, analytics

---

## 2. TECHNOLOGY STACK

| Layer | Technology |
|---|---|
| Frontends (6 portals) | React 18 + Vite, Tailwind CSS (admin/client), custom CSS (EVS), lucide-react icons, axios, react-router-dom |
| Main Backend | Node.js + Express (port 5000), modular route/controller architecture (33 modules) |
| EVS Backend | Python FastAPI + Uvicorn (port 8000), PyMySQL, JWT auth |
| Databases | MySQL 8 — `hrms_db` (140+ tables), `employee_verification` (8 tables) |
| Auth | JWT Bearer tokens; separate token per portal family (`hrms_admin_token`, `hrms_hr_Token`, EVS token) |
| File Storage | Local `uploads/` directories (documents, resumes) |
| Communications | Twilio (OTP/SMS — 6 configured accounts), email hooks |

---

## 3. SYSTEM ARCHITECTURE

```
                        ┌──────────────────────────────────────────────────┐
                        │                    BROWSER                        │
                        └───────┬──────┬──────┬──────┬──────┬──────┬───────┘
                                │      │      │      │      │      │
                 ┌──────────────┼──────┼──────┼──────┼──────┼──────┼─────────────┐
                 │   :5174      │ :5176-5178  │      │ :5179│      │  :5173      │
                 ▼              ▼      ▼      ▼      ▼      ▼      ▼             │
          ┌───────────┐  ┌──────┐ ┌──────┐ ┌────────┐ ┌───────┐ ┌─────────────┐ │
          │   ADMIN   │  │  HR  │ │  IT  │ │ CLIENT │ │ SALES │ │  EVS (React)│ │
          │  (Super   │  │Portal│ │Portal│ │ Portal │ │Portal │ │ Verification│ │
          │   Admin)  │  │      │ │      │ │ :5175  │ │       │ │   Portal    │ │
          └─────┬─────┘  └───┬──┘ └───┬──┘ └───┬────┘ └───┬───┘ └──────┬──────┘ │
                │            │        │        │          │           │        │
                │   JWT Bearer (role-scoped tokens)       │           │ JWT    │
                ▼            ▼        ▼        ▼          ▼           ▼        │
        ┌─────────────────────────────────────────────────┐  ┌───────────────┐│
        │        NODE.JS / EXPRESS BACKEND  (:5000)        │  │ FASTAPI (EVS) ││
        │  33 modules: superAdmin, hr, it, itdev, sales,   │  │   (:8000)     ││
        │  client, employee, jobBoard, verification, leave,│  │ auth, identity││
        │  onboarding, aiChat, analytics, otpAuth, sop ... │  │ docs, bg-check││
        └───────────────────────┬─────────────────────────┘  │ history, sync ││
                                │                             └───────┬───────┘│
                                ▼                                     ▼        │
                    ┌────────────────────┐   direct SQL read  ┌──────────────┐ │
                    │   MySQL: hrms_db   │◄───(hrms_sync.py)──│    MySQL:    │ │
                    │   140+ tables      │                    │  employee_   │ │
                    │  employees, depts, │──── employee ─────►│ verification │ │
                    │  candidates, jobs, │     sync (upsert)  │   8 tables   │ │
                    │  verification_docs │                    └──────────────┘ │
                    └────────────────────┘                                     │
                                                                               │
   TWO-WAY BRIDGE (implemented in this project):                               │
   • Admin portal panel  ── reads ──►  EVS API /verification-status, /hrms-status
   • EVS Documents page  ── reads ──►  EVS API /hrms-documents ──► hrms_db.verification_documents
   • EVS "Sync from HRMS" ── reads ──► hrms_db.employees ──► upserts into EVS employees
```

**Port map (verified live):**

| Port | Service |
|---|---|
| 5000 | Node/Express shared HRMS backend |
| 8000 | FastAPI EVS backend |
| 5173 | EVS frontend (verification portal) |
| 5174 | Admin portal (Super Admin) |
| 5175 | Client portal |
| 5176–5178 | HR, IT, Employee portals |
| 5179 | Sales portal |
| 5180 | EVS frontend (duplicate instance) |

---

## 4. PROJECT STRUCTURE

```
HRMS Merging/
├── admin/                          # Super Admin portal (React+Vite+Tailwind, :5174)
│   └── src/
│       ├── pages/
│       │   └── verification/
│       │       ├── VerificationPortal.jsx   # doc upload/verify + EVS panel
│       │       └── EvsOverview.jsx          # NEW: live EVS bridge panel
│       ├── components/  (sidebarPermissions.js — SUPER_ADMIN role map)
│       └── ...
├── HR/                             # HR portal (React+Vite)
├── IT/                             # IT portal (React+Vite) — .env → :5000/api
├── Sales/                          # Sales portal (React+Vite, :5179)
├── client/                         # Client portal (React+Vite+Tailwind, :5175)
│   └── src/pages/overview/Overview.jsx      # REBUILT: live stats dashboard
├── employee/                       # Employee self-service portal
├── backen/                         # Shared Node/Express backend (:5000)
│   └── modules/                    # 33 feature modules
│       ├── superAdmin/  hr/  it/  itdev/  sales/  client/  employee/
│       ├── jobBoard/               # Job board + ATS resume scoring
│       ├── verification/           # Admin doc verification (verification_documents)
│       ├── leave/  onboarding/  documents/  sop/  compliance/
│       ├── aiChat/  aiRecruit/  assistant/  analytics/
│       ├── otpAuth/  geoAttendance/  notifications/  messaging/  chat/
│       ├── benefits/  birthday/  branches/  complaint/  docExpiry/
│       ├── webForms/  visitors/  search/  common/
│       └── ...
├── employee-verification-system/   # Standalone EVS microservice
│   ├── employee-verification-backend/       # FastAPI (:8000)
│   │   ├── app/
│   │   │   ├── main.py                      # CORS allow_origins=["*"]
│   │   │   └── routes/
│   │   │       ├── auth.py                  # JWT login/register
│   │   │       ├── employee.py              # EVS employee CRUD
│   │   │       ├── identity_routes.py       # Aadhaar/PAN + Verhoeff validation
│   │   │       ├── document.py              # document submit/verify
│   │   │       ├── background_routes.py     # bg-check workflow
│   │   │       ├── employment_history_routes.py
│   │   │       ├── verification_dashboard.py# status matrix + summary
│   │   │       └── hrms_sync.py             # NEW: /hrms-status, /hrms-sync,
│   │   │                                    #      /hrms-documents, reports
│   │   ├── uploads/
│   │   └── venv/
│   └── frontend/frontend/                   # EVS React app (:5173)
│       ├── public/logo.png                  # NEW: Ardhnarishwar logo
│       └── src/
│           ├── components/Navbar.jsx        # logo replaces "EV" badge
│           └── pages/                       # 13 pages
│               ├── Login.jsx  Dashboard.jsx  Employees.jsx
│               ├── IdentityVerification.jsx  Documents.jsx
│               ├── BackgroundVerification.jsx  EmploymentHistory.jsx
│               ├── VerificationStatus.jsx  AuditLogs.jsx  Reports.jsx
│               └── Profile.jsx  VerifyDocument.jsx  VerifyPage.jsx
├── scripts/
└── PROJECT_REPORT.md               # this document
```

---

## 5. PORTAL INVENTORY (ROLES & RESPONSIBILITIES)

| Portal | Port | Primary Roles | Purpose |
|---|---|---|---|
| Admin | 5174 | SUPER_ADMIN, MANAGER, hr | Master control center: employees, clients, candidates, joined candidates, interviews, services, attendance, users, departments, payroll, job board/ATS, document verification, lead assigner, EVS live panel |
| HR | 5176-5178 | HR | Recruitment ops, employee records, leave, onboarding, HR documents |
| IT | 5176-5178 | IT dev roles + SUPER_ADMIN | Task assignment, daily work/EOD, timesheets, code reviews, milestones, bugs, deployments, SOPs, automated attendance, interviews |
| Sales | 5179 | Sales roles | Leads, lead batches, sales reports, EOD, targets, inventory |
| Client | 5175 | CLIENT | Overview dashboard, client employees, SOP library, leave approvals, offer letters, employee search, attendance tracker, interview tracker, payroll, sales report, invoices, live chat |
| Employee | 5176-5178 | EMPLOYEE | Self-service: profile, attendance, leave, payslips, documents |
| EVS | 5173 | Admin, HR, Viewer (own auth) | Aadhaar/PAN, documents, background checks, employment history, status matrix, audit logs, reports, HRMS sync |

**Role protection example (verified in code):** `itdev` routes allow read/update for both
roles but restrict task creation and all deletes to `SUPER_ADMIN`. The same
`SUPER_ADMIN` role from `sidebarPermissions.js` governs every portal — one role system
spans the suite.

---

## 6. DATABASE DESIGN

### 6.1 `hrms_db` (main HRMS — 140+ tables, key groups)

| Group | Tables (representative) |
|---|---|
| Org structure | employees, departments, designations, branches, managers, team_leaders, office_locations, shift_timings |
| Recruitment | candidates, candidate_statuses, job_board_posts, job_applications, job_positions, resume_screenings, ai_interviews, joining_forms, offer_letters, offer_letter_templates |
| Attendance/Leave | leave_applications, leave_balances, leave_types, comp_offs, holidays, smart_attendance_otps, super_admin_attendance |
| Payroll/Finance | admin_payroll, payroll_runs, invoices, invoice_items, expenses, revenues, general_ledger, tax_records, cash_flow, profit_reports |
| Client ops | clients, client_employees, client_attendance, client_leave_applications, client_invoices, client_offer_letters, client_interviews, client_payroll, client_sales_report, client_leads |
| IT ops | it_tasks, it_timesheets, it_bugs, it_code_reviews, it_milestones, it_daily_work, dev_tasks, dev_bugs, dev_deployments, eod_reports |
| Sales ops | leads, lead_batches, field_sales_leads, sales_report, sales_eod_reports, sales_inventory, revenue_targets |
| Verification (admin) | verification_documents, verification_audit_logs, background_verifications |
| Governance | sops, sop_versions, sop_acknowledgements, policies, compliance_items, audit_logs, admin_audit_logs, user_sessions, super_admins |
| Comms/Misc | notifications, messages, internal_messages, message_templates, chatbot_conversations, hr_robo_faqs, complaints, visitors, web_form_submissions, birthday_notifications |

### 6.2 `employee_verification` (EVS — 8 tables)

| Table | Purpose |
|---|---|
| users | EVS accounts (Admin / HR / Viewer) with hashed passwords |
| employees | Verification subjects (synced from hrms_db by email upsert) |
| identity_verification | Aadhaar (Verhoeff-validated, masked in UI) + PAN records with approval status |
| documents | Submitted documents with verify/reject states |
| background_verification | Previous company, HR email, feedback, rehire eligibility, criminal record; Pending → In Progress → Verified/Rejected |
| employment_history | Company, designation, dates, HR contact; Pending → Validated |
| audit_logs | Every action recorded with actor and timestamp |
| verification_tokens | Verification token flows |

**Relationship:** the two databases are linked at runtime by `hrms_sync.py`, which
connects to `hrms_db` (read-only) using the same MySQL server credentials and matches
records by employee email.

---

## 7. DATA FLOW DIAGRAMS

### 7.1 DFD Level 0 (Context Diagram)

```
  ┌────────────┐   credentials/actions    ┌──────────────────────┐
  │ SUPER ADMIN├──────────────────────────►                      │
  └────────────┘                          │                      │
  ┌────────────┐   HR operations          │                      │   reports,
  │     HR     ├──────────────────────────►                      ├──────────────►
  └────────────┘                          │      ARDHNARISHWAR   │   payslips,
  ┌────────────┐   tasks/timesheets       │        HRMS          │   offer letters,
  │  IT STAFF  ├──────────────────────────►       PLATFORM       │   audit logs,
  └────────────┘                          │                      │   notifications
  ┌────────────┐   leads/sales data       │  (6 portals + EVS)   │
  │   SALES    ├──────────────────────────►                      │
  └────────────┘                          │                      │
  ┌────────────┐   approvals/invoices     │                      │
  │   CLIENT   ├──────────────────────────►                      │
  └────────────┘                          │                      │
  ┌────────────┐   self-service           │                      │
  │  EMPLOYEE  ├──────────────────────────►                      │
  └────────────┘                          └──────────┬───────────┘
  ┌────────────┐   job application                   │
  │ JOB SEEKER ├───(public API, no login)────────────┘
  └────────────┘
```

### 7.2 DFD Level 1 (Major Processes)

```
                              ┌─────────────────┐
   candidate data ───────────►│ P1: RECRUITMENT │──── offers ────► candidates,
   public applications ──────►│  (jobBoard/ATS, │                  offer_letters
                              │  interviews)    │
                              └────────┬────────┘
                                       │ hired
                                       ▼
  ┌─────────────────┐        ┌─────────────────┐        ┌──────────────────┐
  │ P4: CLIENT OPS  │        │ P2: EMPLOYEE    │        │ P3: VERIFICATION │
  │ invoices, leave │◄──────►│  LIFECYCLE      │───────►│  (EVS microserv.)│
  │ approvals, SOPs │  data  │ onboarding,     │  sync  │ Aadhaar/PAN, docs│
  └─────────────────┘        │ attendance,     │        │ bg-check, history│
                             │ payroll, exit   │        └────────┬─────────┘
  ┌─────────────────┐        └────────┬────────┘                 │ statuses
  │ P5: IT/SALES OPS│◄────────────────┤                          ▼
  │ tasks, leads,   │                 ▼                 ┌──────────────────┐
  │ timesheets, EOD │        ┌─────────────────┐        │ P6: GOVERNANCE   │
  └─────────────────┘        │  D1: hrms_db    │◄──────►│ audit logs,      │
                             └─────────────────┘        │ reports, exports │
                             ┌─────────────────┐        └──────────────────┘
                             │  D2: employee_  │
                             │  verification   │
                             └─────────────────┘
```

### 7.3 DFD Level 2 — Verification Process (P3 expanded)

```
 Super Admin (admin portal)                    EVS Admin (verification portal)
        │                                              │
        │ 1. clicks "Sync Employees from HRMS"         │
        ▼                                              │
 ┌─────────────────┐  read employees+dept+desig  ┌─────┴───────────┐
 │ POST /hrms-sync ├────── from hrms_db ────────►│ upsert by email │
 └─────────────────┘                             │ into EVS emps   │
                                                 └─────┬───────────┘
                                                       │ 2. verification work
        ┌──────────────────────────────────────────────┼──────────────────┐
        ▼                        ▼                     ▼                  ▼
 ┌──────────────┐        ┌──────────────┐      ┌──────────────┐   ┌──────────────┐
 │ Aadhaar/PAN  │        │  Documents   │      │  Background  │   │  Employment  │
 │ Verhoeff chk │        │ upload→      │      │ Pending→In   │   │  History     │
 │ masked→      │        │ verify/reject│      │ Progress→    │   │ Pending→     │
 │ approve/rej  │        │              │      │ Verified/Rej │   │ Validated    │
 └──────┬───────┘        └──────┬───────┘      └──────┬───────┘   └──────┬───────┘
        └────────────┬──────────┴──────────┬──────────┴──────────────────┘
                     ▼                     ▼
            ┌────────────────┐   ┌──────────────────┐
            │  audit_logs    │   │ /verification-   │──► status matrix:
            │ (every action) │   │  status (matrix) │    Not Started / In Progress /
            └────────────────┘   └────────┬─────────┘    Action Required / Fully Verified
                                          │
              3. live visibility          ▼
 Admin portal /dashboard/verification ◄── EvsOverview panel (stats + matrix + link)
 EVS Documents page ◄── /hrms-documents ◄── hrms_db.verification_documents (Super
                                            Admin's doc verifications flow back)
```

---

## 8. USER FLOW DIAGRAMS

### 8.1 Super Admin

```
Login (:5174, admin@hrms.com)
  └─► Admin Dashboard
        ├─► Employee Management ──► add/edit employees ──► reflected in EVS after sync
        ├─► Candidate Management ──► interviews ──► joined candidates ──► joining forms
        ├─► Job Board ──► publish job (with ATS keywords)
        │       └─► Applications tab (auto-ranked by ATS score)
        │             └─► Shortlist / Reject / Convert-to-candidate
        ├─► Verification (/dashboard/verification)
        │       ├─► EVS LIVE PANEL: stats + full scrollable matrix + Refresh
        │       │       └─► "Open Verification Portal" ──► EVS (:5173)
        │       └─► Document upload ──► Verify / Reject (with remarks) ──► Reopen
        ├─► Attendance Tracker / Payroll / Users / Departments / Services
        └─► Lead Assigner ──► assign leads to sales
```

### 8.2 EVS Admin (Verification Portal)

```
Login (:5173, admin@test.com)
  └─► Dashboard (HRMS banner: X employees, Y synced, Z pending)
        ├─► "Sync Employees from HRMS" ──► upserts employees ──► audit log entry
        ├─► Identity Verification ──► submit Aadhaar/PAN ──► checksum validated
        │       └─► Approve Aadhaar / Approve PAN / Reject ──► masked display
        ├─► Documents ──► verify/reject own records
        │       └─► "Documents from HRMS Admin Portal" (read-only bridge table)
        ├─► Background Check ──► Start Check ──► In Progress ──► Verify/Reject
        ├─► Employment History ──► Validate / Reject
        ├─► Verification Status ──► per-employee matrix ──► overall state
        ├─► Audit Logs ──► every action, timestamped
        └─► Reports (Admin only) ──► PDF/Excel export by department
```

### 8.3 Client

```
Login (:5175)
  └─► Overview (live dashboard: 5 stat cards + dept chart + leaves + attendance)
        ├─► Employee Management ──► client employees
        ├─► Leave Approvals ──► approve/reject
        ├─► Offer Letters / Invoices / Payroll / Sales Report
        ├─► Attendance Tracker / Interview Tracker / Employee Search
        ├─► SOP Library ──► acknowledge SOPs
        └─► Live Chat
```

### 8.4 Job Seeker (public, no login)

```
Company website ──► GET /api/job-board/public/jobs (open jobs JSON)
      └─► POST /api/job-board/public/apply (name, email, phone, resume text)
            └─► backend parses resume ──► extracts skills/experience/education
                  └─► ATS score 0–100 ──► appears ranked in admin Applications tab
```

### 8.5 IT Staff

```
Login (IT portal)
  └─► Dashboard ──► assigned tasks (created by SUPER_ADMIN)
        ├─► Daily Work / EOD Reports ──► submit
        ├─► Timesheets ──► log hours
        ├─► Bugs / Code Reviews / Milestones / Deployments
        └─► SOPs / Automated Attendance
```

---

## 9. MODULE-BY-MODULE FUNCTIONALITY (BACKEND, 33 MODULES)

| Module | Function |
|---|---|
| superAdmin | Master CRUD: employees, clients, sales, agreements, joining, services, password resets |
| hr | HR operations, recruitment support, HR documents |
| it / itdev | IT tasks, timesheets, bugs, reviews, milestones, deployments (deletes = SUPER_ADMIN only) |
| sales | Leads, batches, EOD, targets, inventory |
| client | Client employees, attendance, leave-offer, interviews, invoices, work assignments |
| employee | Self-service profile, attendance, leave |
| jobBoard | Job posts + public apply API + resume parser + ATS scorer + convert-to-candidate |
| verification | Admin document verification (13 doc types, file upload, verify/reject/reopen, verified_by tracking) |
| leave | Leave types, balances, applications, comp-offs |
| onboarding | Joining forms, onboarding checklists |
| documents / docExpiry | Employee document storage + expiry alerts |
| sop | SOPs, versions, acknowledgements |
| compliance | Compliance items tracking |
| aiChat / aiRecruit / assistant | AI chatbot, AI resume screening, HR-Robo FAQ |
| analytics | Dashboards and metrics |
| otpAuth | Twilio OTP login flows |
| geoAttendance | Location-based smart attendance with OTP |
| notifications / messaging / chat | In-app notifications, internal messages, live chat |
| benefits / birthday / branches | Employee benefits, birthday alerts, branch management |
| complaint | Complaints + replies workflow |
| webForms / visitors / search / common | Public web forms, visitor log, global search, shared utilities |

---

## 10. EMPLOYEE VERIFICATION SYSTEM — DEEP DIVE

**Stack:** FastAPI (:8000) + React/Vite (:5173) + MySQL `employee_verification`.
**Auth:** own JWT system; roles Admin / HR / Viewer. Sidebar gating: Employees page =
Admin+HR; Reports = Admin only.

**Verification pillars (all implemented and tested):**

1. **Identity (Aadhaar/PAN)** — Aadhaar validated with the **Verhoeff checksum
   algorithm** (invalid numbers rejected server-side, verified during testing); PAN
   format validation; numbers displayed masked (XXXX-XXXX-1012); Approve/Reject per
   document type.
2. **Documents** — submit → Pending → Verified/Rejected; plus the read-only bridge
   table showing Super Admin's `verification_documents` from `hrms_db`.
3. **Background checks** — Pending → Start Check → In Progress → Verified/Rejected;
   captures previous company, HR email, feedback, rehire eligibility, criminal record.
4. **Employment history** — company, designation, dates, HR contact; Validate/Reject.
5. **Status matrix** — per-employee overall state computed across all pillars:
   Not Started / In Progress / Action Required / Fully Verified.
6. **Audit logs** — every action (approvals, rejections, syncs) recorded with actor
   and timestamp.
7. **Reports** — department-level summaries with PDF/Excel export (Admin only).

**Branding:** Ardhnarishwar logo (public/logo.png) replaces the "EV" placeholder in
the navbar badge and login card (`object-fit: cover`).

---

## 11. HRMS ↔ EVS INTEGRATION BRIDGE (IMPLEMENTED IN THIS PROJECT)

Per the Recruweb specification (one centralized verification module under Superadmin
master control), the two systems were consolidated with the EVS as the single source
of verification truth and the Super Admin given full live visibility:

| Direction | Mechanism |
|---|---|
| HRMS → EVS (employees) | `POST /hrms-sync`: reads `hrms_db.employees` joined with departments/designations, upserts into EVS by email; result logged ("HRMS Sync: N added, M updated"); dashboard banner shows synced counts |
| HRMS → EVS (documents) | `GET /hrms-documents`: joins `hrms_db.verification_documents` with employees; EVS Documents page renders a read-only "Documents from HRMS Admin Portal" table (employee, doc type, status, verified_by, remarks, date) |
| EVS → HRMS (visibility) | `EvsOverview.jsx` panel mounted at top of admin `/dashboard/verification`: live connection status, 9/9 sync counter, 5 pipeline stat cards, full per-employee matrix in a **340px scrollable container (vertical + horizontal, sticky header, 760px min-width)**, Refresh button, "Open Verification Portal" deep link, graceful offline banner |
| Fault tolerance | CORS open on EVS; panel degrades to an offline message if :8000 is down; `Promise.allSettled` patterns prevent blank pages |

Bugs caught and fixed during the build: API field `employee_name` (not `name`);
DB column `verified_by` (not `reviewed_by`).

---

## 12. JOB BOARD & ATS MODULE

- **Publish:** title, department, location, type, salary range, description, and
  **ATS keywords** (drive scoring).
- **Public API:** `GET /api/job-board/public/jobs` and
  `POST /api/job-board/public/apply` — embeddable on any company website, no auth.
- **Resume parsing:** auto-extracts email, phone, skills (40-skill bank), years of
  experience, education.
- **ATS score (0–100):** up to 60 pts keyword match + up to 25 pts experience
  (5/year) + 10 pts education + 5 pts contact info.
- **Pipeline:** applications auto-ranked → Shortlist / Reject / **Convert** (inserts
  into `candidates`, entering the main HRMS hiring flow).

---

## 13. SECURITY IMPLEMENTATION

| Control | Detail |
|---|---|
| JWT auth per system | Separate role-scoped tokens: `hrms_admin_token`, `hrms_hr_Token`, EVS JWT |
| Role-based access | SUPER_ADMIN permission map (`sidebarPermissions.js`); route-level guards (e.g. itdev deletes = SUPER_ADMIN only); EVS sidebar gating (Reports = Admin only) |
| Identity validation | Server-side Verhoeff checksum for Aadhaar; PAN format checks — invalid data rejected before storage |
| Data masking | Aadhaar shown masked (XXXX-XXXX-nnnn) throughout EVS UI |
| Audit trails | `audit_logs` (EVS), `admin_audit_logs`, `verification_audit_logs`, `user_sessions` (hrms_db) |
| Parameterized queries | PyMySQL parameterized statements in EVS backend |
| OTP flows | Twilio-backed OTP login (`login_otps`, `smart_attendance_otps`) |

---

## 14. EVERYTHING IMPLEMENTED DURING THIS PROJECT

Chronological implementation log of work performed in this engagement:

1. **EVS ↔ HRMS employee sync** — new `hrms_sync.py` router: `/hrms-status` (connection
   + counts banner) and `/hrms-sync` (department/designation-joined upsert by email),
   with audit logging; "Sync Employees from HRMS" button + banner on the EVS dashboard.
2. **Mock-data approval testing** — seeded identity (Verhoeff-valid Aadhaar), employment
   history, and background cases for 3 synced employees via API; proved the invalid-
   checksum rejection works; executed every approval live in the browser (Aadhaar,
   PAN, history validation, background Start→Verify) and confirmed the status matrix
   flipped to "Fully Verified" with full audit-log entries.
3. **Requirement analysis** — mapped the Recruweb spec's verification module to the
   EVS 5-for-5; identified the admin portal's verification page as a partial duplicate;
   recommended consolidation (EVS = source of truth + Superadmin window).
4. **Two-way integration bridge** —
   - `EvsOverview.jsx` live panel in admin `/dashboard/verification` (stats, matrix,
     refresh, deep link, offline fallback);
   - `GET /hrms-documents` endpoint + read-only HRMS documents table on the EVS
     Documents page;
   - fixed `employee_name` and `verified_by` mismatches before shipping.
5. **Branding** — Ardhnarishwar logo installed as `public/logo.png`, wired into the
   EVS navbar badge and login card with CSS adjustments.
6. **Scrollable matrix** — converted the admin EVS matrix to a contained scroll area:
   340px max height, vertical + horizontal overflow, sticky header, 760px min table
   width, all rows shown (removed the 8-row cap); verified programmatic scrolling in
   both axes.
7. **Client portal Overview rebuild** — replaced the stub page (:5175/overview) with a
   live dashboard: 5 clickable stat cards (Employees, Present Today, Pending Leaves,
   Interviews, Invoices), Team-by-Department proportion bars, Leave Requests and
   Recent Attendance panels; parallel fetches with `Promise.allSettled`, skeleton
   loading, empty states, contained panel scrolling.
8. **Continuous verification** — every change tested live in the real browser
   (login flows, clicks, scroll measurements, screenshots) and via direct API/schema
   checks; the temporary seed script was removed after use.

---

## 15. TESTING & VERIFICATION PERFORMED

| Test | Method | Result |
|---|---|---|
| HRMS sync | API + dashboard banner | 9/9 employees synced, audit logged |
| Aadhaar checksum rejection | Submitted invalid numbers | Correctly rejected (Verhoeff) |
| Aadhaar/PAN approval | Live browser clicks as admin | Pending → Verified |
| Employment history validation | Live browser | Pending → Validated |
| Background workflow | Live browser | Pending → In Progress → Verified |
| Overall matrix | Verification Status page | "Fully Verified" computed correctly |
| Audit trail | Audit Logs page + screenshot | All actions recorded with timestamps |
| Admin EVS panel | Browser on :5174 | Live stats + matrix render; offline fallback verified in code |
| Matrix scrolling | Programmatic scroll measurements | vScroll ✓ (scrollTop 200), hScroll ✓ (scrollLeft 150 when narrow), sticky header ✓ |
| Documents bridge | `GET /hrms-documents` + EVS UI | Super Admin's verified PAN Card visible in EVS |
| Client Overview | Browser on :5175 | Stat cards + panels render with live Demo Corp data |
| Logo | Browser | Renders in navbar and login card |

---

## 16. API REFERENCE SUMMARY

### Main backend (Node, :5000/api) — representative

| Endpoint | Purpose |
|---|---|
| /super-admin/* | Employees, clients, sales, agreements, joining, services |
| /client/employees, /client/attendance, /client/leave-offer/leaves, /client/interviews, /client/invoices | Client portal data (drives the Overview dashboard) |
| /job-board/public/jobs (GET), /job-board/public/apply (POST) | Public job board |
| /verification/* | Admin document verification (13 doc types) |
| /it/*, /itdev/* | IT tasks, timesheets, bugs, reviews (role-guarded) |

### EVS backend (FastAPI, :8000)

| Endpoint | Purpose |
|---|---|
| /login, /register | EVS JWT auth |
| /employees | EVS employee CRUD |
| /identity-verification (GET/POST + approve/reject) | Aadhaar/PAN pipeline |
| /documents | Document verification |
| /background-verification | Background workflow |
| /employment-history | History validation |
| /verification-status | Summary + per-employee matrix (feeds admin panel) |
| /hrms-status | HRMS connection + sync counts |
| /hrms-sync (POST) | Employee sync from hrms_db |
| /hrms-documents | Admin-portal documents bridge (read-only) |
| /audit-logs, /reports | Governance & exports |

---

## 17. KNOWN CONSTRAINTS & FUTURE ENHANCEMENTS

**Constraints (by design, current state):**
- HRMS and EVS logins are separate (data bridged, sessions not) — SSO is a candidate
  enhancement: EVS could validate the HRMS JWT against `hrms_db.user_sessions`.
- EVS document uploads and the admin portal's file uploads store files in separate
  locations; file-level unification is pending.
- Port allocation is dynamic under Vite (EVS moved 5179 → 5173 when the full suite
  runs); consider pinning ports in each `vite.config.js`.

**Recommended next steps:**
1. Single sign-on between admin portal and EVS (map SUPER_ADMIN → EVS Admin).
2. Add real file upload to EVS documents, then retire the duplicate admin upload page.
3. Push EVS verification outcomes back into `hrms_db` for payroll/joining gating.
4. Pin dev ports; add health checks and a process manager (PM2) for production.
5. Automated regression tests for the sync and approval workflows.

---

*End of report.*
