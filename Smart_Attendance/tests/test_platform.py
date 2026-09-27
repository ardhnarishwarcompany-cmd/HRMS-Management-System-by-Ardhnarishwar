import pytest
import sys, os, time, cv2, numpy as np, base64

# Ensure backend directory is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from app import app, otp_store
from database import (
    companies_col, users_col, employees_col, 
    attendance_col, field_visits_col, audit_logs_col, policies_col,
    hash_password, seed_global_system
)
from config import SUPER_ADMIN_EMAIL, SUPER_ADMIN_PASS, SUPER_ADMIN_MOBILE
from timezone_engine import evaluate_attendance_status


@pytest.fixture(autouse=True)
def clean_and_bootstrap_db():
    """Reset database and bootstrap Super Admin before each test."""
    companies_col.delete_many({})
    users_col.delete_many({})
    employees_col.delete_many({})
    attendance_col.delete_many({})
    field_visits_col.delete_many({})
    audit_logs_col.delete_many({})
    policies_col.delete_many({})
    otp_store.clear()
    seed_global_system()


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


# ══════════════════════════════════════════════════════════════════════════════
#  1. BOOTSTRAP & ZERO DEMO DATA TESTS
# ══════════════════════════════════════════════════════════════════════════════

def test_zero_demo_data_on_bootstrap():
    """Verify that NO fake companies, employees, or attendance records exist on startup."""
    assert companies_col.count_documents({}) == 0, "No demo companies should be seeded"
    assert employees_col.count_documents({}) == 0, "No demo employees should be seeded"
    assert attendance_col.count_documents({}) == 0, "No demo attendance records should be seeded"
    assert field_visits_col.count_documents({}) == 0, "No demo field visits should be seeded"
    
    # Only the initial Super Admin account should exist
    assert users_col.count_documents({"role": "super_admin"}) == 1
    super_admin = users_col.find_one({"role": "super_admin"})
    assert super_admin["email"] == SUPER_ADMIN_EMAIL
    assert super_admin["company_id"] == "ARDHNARISHWAR"


def test_super_admin_authentication(client):
    """Test Super Admin login with valid and invalid credentials."""
    # Invalid login
    res = client.post("/api/login", json={
        "role": "super_admin",
        "email": SUPER_ADMIN_EMAIL,
        "password": "wrong_password"
    })
    assert res.status_code == 401
    assert res.json["ok"] is False

    # Valid login
    res = client.post("/api/login", json={
        "role": "super_admin",
        "email": SUPER_ADMIN_EMAIL,
        "password": SUPER_ADMIN_PASS
    })
    assert res.status_code == 200
    assert res.json["ok"] is True
    assert res.json["role"] == "super_admin"


# ══════════════════════════════════════════════════════════════════════════════
#  2. SUPER ADMIN COMPANY LIFECYCLE TESTS
# ══════════════════════════════════════════════════════════════════════════════

def test_super_admin_company_management(client):
    # Log in as Super Admin
    client.post("/api/login", json={
        "role": "super_admin",
        "email": SUPER_ADMIN_EMAIL,
        "password": SUPER_ADMIN_PASS
    })

    # 1. Create Company A
    res = client.post("/api/superadmin/companies", json={
        "company_id": "COMP-A",
        "name": "Alpha Technologies Ltd",
        "country": "India",
        "timezone": "Asia/Kolkata",
        "contact_phone": "9876500001",
        "contact_email": "admin@alpha.com",
        "admin_name": "Alpha Admin",
        "admin_password": "alpha_password_123",
        "shift_start": "09:00",
        "grace_period_mins": 15
    })
    assert res.status_code == 200
    assert res.json["ok"] is True

    # Verify company in DB
    comp = companies_col.find_one({"company_id": "COMP-A"})
    assert comp is not None
    assert comp["name"] == "Alpha Technologies Ltd"

    # Verify Company Admin account was created
    admin_user = users_col.find_one({"company_id": "COMP-A", "role": "company_admin"})
    assert admin_user is not None
    assert admin_user["mobile"] == "9876500001"
    assert admin_user["password"] == hash_password("alpha_password_123")

    # 2. List Companies
    res = client.get("/api/superadmin/companies")
    assert res.status_code == 200
    assert len(res.json["companies"]) == 1
    assert res.json["companies"][0]["company_id"] == "COMP-A"

    # 3. Analytics
    res = client.get("/api/superadmin/analytics")
    assert res.status_code == 200
    assert res.json["stats"]["total_companies"] == 1
    assert res.json["stats"]["active_companies"] == 1

    # 4. Toggle Status
    res = client.post("/api/superadmin/companies/COMP-A/toggle-status", json={"status": "suspended"})
    assert res.status_code == 200
    comp = companies_col.find_one({"company_id": "COMP-A"})
    assert comp["status"] == "suspended"

    # Reactivate
    client.post("/api/superadmin/companies/COMP-A/toggle-status", json={"status": "active"})


# ══════════════════════════════════════════════════════════════════════════════
#  3. MANDATORY CROSS-TENANT SECURITY & ISOLATION TESTS
# ══════════════════════════════════════════════════════════════════════════════

def test_cross_tenant_security_isolation(client):
    """
    CRITICAL MANDATORY TEST:
    Company A Admin MUST NEVER be able to read, mutate, or delete Company B data.
    """
    # 1. Setup Company A and Company B via Super Admin
    client.post("/api/login", json={
        "role": "super_admin",
        "email": SUPER_ADMIN_EMAIL,
        "password": SUPER_ADMIN_PASS
    })

    client.post("/api/superadmin/companies", json={
        "company_id": "COMP-A",
        "name": "Company Alpha",
        "contact_phone": "9000000001",
        "admin_password": "passA"
    })
    client.post("/api/superadmin/companies", json={
        "company_id": "COMP-B",
        "name": "Company Beta",
        "contact_phone": "9000000002",
        "admin_password": "passB"
    })

    # Log in as Company B Admin and create Employee B1
    client.post("/api/login", json={
        "role": "company_admin",
        "company_id": "COMP-B",
        "mobile": "9000000002",
        "password": "passB"
    })
    res = client.post("/api/company/employees", json={
        "emp_id": "EMP-B1",
        "name": "Bob Beta",
        "mobile": "8000000002",
        "department": "Security",
        "designation": "Specialist",
        "password": "empB1_pass"
    })
    assert res.status_code == 200
    assert employees_col.find_one({"company_id": "COMP-B", "emp_id": "EMP-B1"}) is not None

    # Now log in as Company A Admin
    client.post("/api/login", json={
        "role": "company_admin",
        "company_id": "COMP-A",
        "mobile": "9000000001",
        "password": "passA"
    })

    # Create Employee A1
    client.post("/api/company/employees", json={
        "emp_id": "EMP-A1",
        "name": "Alice Alpha",
        "mobile": "8000000001",
        "department": "Engineering",
        "designation": "Architect",
        "password": "empA1_pass"
    })

    # ── CROSS-TENANT ATTACK 1: Company A attempts to view Company B employees ──
    res = client.get("/api/company/employees?company_id=COMP-B")
    assert res.status_code == 403, "Company A Admin must not view Company B employees"
    assert res.json["ok"] is False

    # ── CROSS-TENANT ATTACK 2: Company A attempts to create employee in Company B ──
    res = client.post("/api/company/employees?company_id=COMP-B", json={
        "emp_id": "HACK-01",
        "name": "Hacker",
        "mobile": "7000000000"
    })
    assert res.status_code == 403, "Company A Admin must not create employees in Company B"

    # ── CROSS-TENANT ATTACK 3: Company A attempts to delete Company B employee ──
    res = client.delete("/api/company/employees?company_id=COMP-B&emp_id=EMP-B1")
    assert res.status_code == 403, "Company A Admin must not delete Company B employee"
    # Ensure Employee B1 is still intact
    assert employees_col.find_one({"company_id": "COMP-B", "emp_id": "EMP-B1"}) is not None

    # ── CROSS-TENANT ATTACK 4: Company A attempts to access Company B attendance ──
    res = client.get("/api/company/attendance?company_id=COMP-B")
    assert res.status_code == 403, "Company A Admin must not query Company B attendance"

    # ── CROSS-TENANT ATTACK 5: Company A attempts to export Company B CSV ──
    res = client.get("/api/company/export-csv?company_id=COMP-B")
    assert res.status_code == 403, "Company A Admin must not export Company B CSV"


# ══════════════════════════════════════════════════════════════════════════════
#  4. ATTENDANCE ENGINE & MULTI-METHOD TESTS
# ══════════════════════════════════════════════════════════════════════════════

def test_attendance_engine_validation_rule(client):
    """Test 'NO COMPANY -> NO EMPLOYEE -> NO VALID ID -> NO ATTENDANCE'."""
    # 1. Non-existent company
    res = client.post("/api/attendance/validate-employee", json={
        "company_id": "NON-EXISTENT",
        "emp_id": "EMP-001"
    })
    assert res.status_code == 400
    assert res.json["ok"] is False

    # 2. Setup real company
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "NEXUS",
        "name": "Nexus Corp",
        "contact_phone": "9111111111",
        "admin_password": "pass"
    })

    # 3. Non-existent employee in real company
    res = client.post("/api/attendance/validate-employee", json={
        "company_id": "NEXUS",
        "emp_id": "INVALID-EMP"
    })
    assert res.status_code == 400
    assert res.json["ok"] is False

    # 4. Valid employee
    client.post("/api/login", json={"role": "company_admin", "company_id": "NEXUS", "mobile": "9111111111", "password": "pass"})
    client.post("/api/company/employees", json={
        "emp_id": "EMP-77",
        "name": "Sarah Connor",
        "mobile": "9222222222",
        "work_type": "Office",
        "password": "emp_password"
    })

    res = client.post("/api/attendance/validate-employee", json={
        "company_id": "NEXUS",
        "emp_id": "EMP-77"
    })
    assert res.status_code == 200
    assert res.json["valid"] is True
    assert res.json["employee"]["name"] == "Sarah Connor"


def test_wifi_attendance_marking(client):
    # Setup company and employee
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "WIFI-CO",
        "name": "WiFi Enterprise",
        "contact_phone": "9333333333",
        "admin_password": "pass"
    })

    client.post("/api/login", json={"role": "company_admin", "company_id": "WIFI-CO", "mobile": "9333333333", "password": "pass"})
    client.post("/api/company/employees", json={
        "emp_id": "EMP-W1",
        "name": "David Clark",
        "mobile": "9444444444",
        "work_type": "Office",
        "password": "emp_password"
    })

    # Mark attendance via WiFi (from local test environment)
    res = client.post("/api/attendance/mark-wifi", json={
        "company_id": "WIFI-CO",
        "emp_id": "EMP-W1"
    })
    assert res.status_code == 200
    assert res.json["ok"] is True
    assert res.json["status"] == "marked"

    # Verify attendance in database
    rec = attendance_col.find_one({"company_id": "WIFI-CO", "emp_id": "EMP-W1"})
    assert rec is not None
    assert rec["method"] == "WiFi"

    # Duplicate check on same day should return already_marked
    res2 = client.post("/api/attendance/mark-wifi", json={
        "company_id": "WIFI-CO",
        "emp_id": "EMP-W1"
    })
    assert res2.status_code == 200
    assert res2.json["status"] == "already_marked"


def test_field_gps_attendance_and_visit_logging(client):
    # Setup company and field employee
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "FIELD-CO",
        "name": "Global Field Services",
        "contact_phone": "9555555555",
        "admin_password": "pass"
    })

    client.post("/api/login", json={"role": "company_admin", "company_id": "FIELD-CO", "mobile": "9555555555", "password": "pass"})
    client.post("/api/company/employees", json={
        "emp_id": "EMP-F1",
        "name": "Frank Field",
        "mobile": "9666666666",
        "work_type": "Field",
        "password": "emp_password"
    })

    # Mark Field check-in with GPS and client meeting info
    res = client.post("/api/attendance/mark-field", json={
        "company_id": "FIELD-CO",
        "emp_id": "EMP-F1",
        "lat": 28.6139,
        "lng": 77.2090,
        "accuracy": 12,
        "check_type": "IN",
        "client_name": "Apex Industries HQ",
        "notes": "Annual service review meeting"
    })
    assert res.status_code == 200
    assert res.json["ok"] is True
    assert res.json["status"] == "marked"

    # Verify visit logged in field_visits collection
    visit = field_visits_col.find_one({"company_id": "FIELD-CO", "emp_id": "EMP-F1"})
    assert visit is not None
    assert visit["client_name"] == "Apex Industries HQ"
    assert visit["location"]["lat"] == 28.6139


def test_otp_attendance_workflow(client):
    # Setup company and employee
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "OTP-CO",
        "name": "Secure OTP Inc",
        "contact_phone": "9777777777",
        "admin_password": "pass"
    })

    client.post("/api/login", json={"role": "company_admin", "company_id": "OTP-CO", "mobile": "9777777777", "password": "pass"})
    client.post("/api/company/employees", json={
        "emp_id": "EMP-O1",
        "name": "Oliver Twist",
        "mobile": "9888888888",
        "work_type": "WFH",
        "password": "emp_password"
    })

    # Send OTP
    res = client.post("/api/attendance/otp-send", json={
        "company_id": "OTP-CO",
        "emp_id": "EMP-O1"
    })
    assert res.status_code == 200
    assert res.json["ok"] is True

    # Check that OTP is hashed in memory
    otp_key = "OTP-CO:EMP-O1"
    assert otp_key in otp_store
    stored_entry = otp_store[otp_key]

    # Verify with incorrect OTP
    res_err = client.post("/api/attendance/otp-verify", json={
        "company_id": "OTP-CO",
        "emp_id": "EMP-O1",
        "otp": "000000"
    })
    assert res_err.status_code == 400
    assert "Incorrect OTP" in res_err.json["error"]

    # Inject known hash for deterministic verification test
    test_code = "654321"
    stored_entry["otp_hash"] = hash_password(test_code)

    # Verify with correct OTP
    res_ok = client.post("/api/attendance/otp-verify", json={
        "company_id": "OTP-CO",
        "emp_id": "EMP-O1",
        "otp": test_code
    })
    assert res_ok.status_code == 200
    assert res_ok.json["ok"] is True
    assert res_ok.json["status"] == "marked"

    # Verify recorded in DB
    rec = attendance_col.find_one({"company_id": "OTP-CO", "emp_id": "EMP-O1"})
    assert rec is not None
    assert rec["method"] == "OTP"


def test_attendance_policy_evaluation():
    policy = {
        "shift_start": "09:30",
        "grace_period_mins": 15,
        "half_day_after": "13:00"
    }

    # On time (09:15) -> Present
    assert evaluate_attendance_status("09:15:00", policy, "Office") == "Present"
    # Within grace (09:40) -> Present
    assert evaluate_attendance_status("09:40:00", policy, "Office") == "Present"
    # After grace (10:15) -> Late
    assert evaluate_attendance_status("10:15:00", policy, "Office") == "Late"
    # After half day threshold (13:30) -> Half Day
    assert evaluate_attendance_status("13:30:00", policy, "Office") == "Half Day"
    # Field worker -> Field
    assert evaluate_attendance_status("10:30:00", policy, "Field") == "Field"


def test_csv_report_export(client):
    # Setup company, employee, and attendance
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "REPORT-CO",
        "name": "Report Systems",
        "contact_phone": "9999900000",
        "admin_password": "pass"
    })

    client.post("/api/login", json={"role": "company_admin", "company_id": "REPORT-CO", "mobile": "9999900000", "password": "pass"})
    client.post("/api/company/employees", json={
        "emp_id": "EMP-R1",
        "name": "Rachel Green",
        "mobile": "9111100000",
        "work_type": "Office",
        "password": "emp_password"
    })

    # Mark attendance
    client.post("/api/attendance/mark-wifi", json={"company_id": "REPORT-CO", "emp_id": "EMP-R1"})

    # Export CSV
    res = client.get("/api/company/export-csv?company_id=REPORT-CO&period=all")
    assert res.status_code == 200
    assert "text/csv" in res.content_type
    csv_text = res.data.decode("utf-8")
    assert "EMP-R1" in csv_text
    assert "Rachel Green" in csv_text
    assert "WiFi" in csv_text


def test_company_cascading_deletion(client):
    # Setup company, employee, and attendance
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "DEL-CO",
        "name": "Deletion Test Co",
        "contact_phone": "9888800000",
        "admin_password": "pass"
    })

    client.post("/api/login", json={"role": "company_admin", "company_id": "DEL-CO", "mobile": "9888800000", "password": "pass"})
    client.post("/api/company/employees", json={
        "emp_id": "EMP-D1",
        "name": "Dan Delete",
        "mobile": "9222200000",
        "work_type": "Office",
        "password": "emp_password"
    })

    client.post("/api/attendance/mark-wifi", json={"company_id": "DEL-CO", "emp_id": "EMP-D1"})

    # Switch back to Super Admin and delete DEL-CO
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    res = client.delete("/api/superadmin/companies/DEL-CO")
    assert res.status_code == 200
    assert res.json["ok"] is True

    # Ensure all resources for DEL-CO are purged
    assert companies_col.find_one({"company_id": "DEL-CO"}) is None
    assert users_col.find_one({"company_id": "DEL-CO"}) is None
    assert employees_col.find_one({"company_id": "DEL-CO"}) is None
    assert attendance_col.find_one({"company_id": "DEL-CO"}) is None


def test_private_in_app_notification_and_otp_api(client):
    """Test 100% private in-house notification vault and active in-session OTP retrieval."""
    # 1. Setup company and employee
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "PRIV-CO",
        "name": "Private Vault Co",
        "contact_phone": "9444400000",
        "admin_password": "pass"
    })

    client.post("/api/login", json={"role": "company_admin", "company_id": "PRIV-CO", "mobile": "9444400000", "password": "pass"})
    client.post("/api/company/employees", json={
        "emp_id": "EMP-P1",
        "name": "Pamela Private",
        "mobile": "9333300000",
        "work_type": "WFH",
        "password": "emp_password"
    })

    # Log in as Employee P1
    client.post("/api/login", json={
        "role": "employee",
        "company_id": "PRIV-CO",
        "mobile": "9333300000",
        "password": "emp_password"
    })

    # Trigger private OTP send
    res = client.post("/api/attendance/otp-send", json={"company_id": "PRIV-CO", "emp_id": "EMP-P1"})
    assert res.status_code == 200

    # Retrieve in-app active OTP code privately
    res_otp = client.get("/api/attendance/my-active-otp")
    assert res_otp.status_code == 200
    assert res_otp.json["ok"] is True
    active_code = res_otp.json["otp_code"]
    assert len(active_code) == 6

    # Verify notification vault record
    res_notes = client.get("/api/notifications")
    assert res_notes.status_code == 200
    assert len(res_notes.json["notifications"]) >= 1
    assert res_notes.json["notifications"][0]["otp_code"] == active_code

    # Verify clock-in using the private in-app code
    res_verify = client.post("/api/attendance/otp-verify", json={
        "company_id": "PRIV-CO",
        "emp_id": "EMP-P1",
        "otp": active_code
    })
    assert res_verify.status_code == 200
    assert res_verify.json["ok"] is True
    assert res_verify.json["status"] == "marked"


# ══════════════════════════════════════════════════════════════════════════════
#  9. SELF-REGISTRATION & SUPER ADMIN APPROVAL WORKFLOW
# ══════════════════════════════════════════════════════════════════════════════

def test_company_self_registration_and_superadmin_approval(client):
    """Test full onboarding lifecycle: Self-Register -> Pending State -> Super Admin Approval -> Active."""
    # 1. Company self-registers
    res = client.post("/api/auth/register-company", json={
        "company_id": "ONBOARD-CO",
        "name": "Onboarding Enterprise",
        "email": "contact@onboard.com",
        "phone": "9555500000",
        "country": "Germany",
        "timezone": "Europe/Berlin",
        "admin_name": "Hans Muller",
        "admin_password": "secure_admin_pass"
    })
    assert res.status_code == 200
    assert res.json["ok"] is True
    assert res.json["status"] == "pending"

    # 2. Verify company and user exist in 'pending' status
    comp = companies_col.find_one({"company_id": "ONBOARD-CO"})
    assert comp is not None
    assert comp["status"] == "pending"

    admin_user = users_col.find_one({"company_id": "ONBOARD-CO"})
    assert admin_user is not None
    assert admin_user["status"] == "pending"

    # 3. Attempting login before approval should be blocked (HTTP 403)
    res_login = client.post("/api/login", json={
        "role": "company_admin",
        "company_id": "ONBOARD-CO",
        "mobile": "9555500000",
        "password": "secure_admin_pass"
    })
    assert res_login.status_code == 403

    # 4. Super Admin reviews and approves the company
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    res_approve = client.post("/api/superadmin/companies/ONBOARD-CO/approve")
    assert res_approve.status_code == 200
    assert res_approve.json["ok"] is True

    # 5. Verify company and admin user are now 'active'
    assert companies_col.find_one({"company_id": "ONBOARD-CO"})["status"] == "active"
    assert users_col.find_one({"company_id": "ONBOARD-CO"})["status"] == "active"

    # 6. Admin can now login successfully
    res_login_after = client.post("/api/login", json={
        "role": "company_admin",
        "company_id": "ONBOARD-CO",
        "mobile": "9555500000",
        "password": "secure_admin_pass"
    })
    assert res_login_after.status_code == 200
    assert res_login_after.json["ok"] is True


# ══════════════════════════════════════════════════════════════════════════════
#  10. BRANCHES, DEPARTMENTS & SHIFTS MANAGEMENT TESTS
# ══════════════════════════════════════════════════════════════════════════════

def test_branches_departments_shifts_crud(client):
    """Test company branch, department, and shift schedule CRUD operations with strict tenant isolation."""
    # Setup company
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "STRUCT-CO",
        "name": "Structured Enterprises",
        "contact_phone": "9666600000",
        "admin_password": "pass"
    })

    client.post("/api/login", json={"role": "company_admin", "company_id": "STRUCT-CO", "mobile": "9666600000", "password": "pass"})

    # 1. Branches
    res_br = client.post("/api/company/branches", json={
        "branch_id": "BR-LON",
        "name": "London HQ",
        "city": "London",
        "country": "United Kingdom",
        "timezone": "Europe/London"
    })
    assert res_br.status_code == 200
    assert res_br.json["ok"] is True

    res_br_list = client.get("/api/company/branches")
    assert res_br_list.status_code == 200
    assert len(res_br_list.json["branches"]) == 1
    assert res_br_list.json["branches"][0]["branch_id"] == "BR-LON"

    # 2. Departments
    res_dept = client.post("/api/company/departments", json={"name": "Engineering"})
    assert res_dept.status_code == 200
    res_dept_list = client.get("/api/company/departments")
    assert len(res_dept_list.json["departments"]) == 1

    # 3. Shifts
    res_shift = client.post("/api/company/shifts", json={
        "shift_id": "SH-NIGHT",
        "name": "Night Owl Shift",
        "start_time": "22:00",
        "end_time": "06:00",
        "is_overnight": True
    })
    assert res_shift.status_code == 200
    res_shift_list = client.get("/api/company/shifts")
    assert len(res_shift_list.json["shifts"]) == 1
    assert res_shift_list.json["shifts"][0]["is_overnight"] is True


# ══════════════════════════════════════════════════════════════════════════════
#  11. ATTENDANCE CORRECTIONS & LEAVE MANAGEMENT WORKFLOWS
# ══════════════════════════════════════════════════════════════════════════════

def test_attendance_corrections_workflow(client):
    """Test employee attendance correction request, review, approval, and audit trail."""
    # Setup company and employee
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "CORR-CO",
        "name": "Correction Corp",
        "contact_phone": "9777700000",
        "admin_password": "pass"
    })

    client.post("/api/login", json={"role": "company_admin", "company_id": "CORR-CO", "mobile": "9777700000", "password": "pass"})
    client.post("/api/company/employees", json={
        "emp_id": "EMP-C1",
        "name": "Carl Correction",
        "mobile": "9888800000",
        "work_type": "Office",
        "password": "emp_password"
    })

    # Employee submits correction request
    client.post("/api/login", json={"role": "employee", "company_id": "CORR-CO", "mobile": "9888800000", "password": "emp_password"})
    res_corr = client.post("/api/attendance/request-correction", json={
        "date": "2026-09-01",
        "requested_time": "09:15",
        "check_type": "IN",
        "reason": "Biometric terminal camera lens was under maintenance"
    })
    assert res_corr.status_code == 200
    corr_id = res_corr.json["correction_id"]

    # Admin reviews and approves correction
    client.post("/api/login", json={"role": "company_admin", "company_id": "CORR-CO", "mobile": "9777700000", "password": "pass"})
    res_review = client.post(f"/api/company/attendance-corrections/{corr_id}/review", json={
        "decision": "approved",
        "remarks": "Verified with security gate logs"
    })
    assert res_review.status_code == 200
    assert res_review.json["ok"] is True

    # Verify attendance record created
    att = attendance_col.find_one({"company_id": "CORR-CO", "emp_id": "EMP-C1", "date": "2026-09-01"})
    assert att is not None
    assert att["time"] == "09:15"
    assert att["method"] == "Correction-Approved"


def test_leave_management_workflow(client):
    """Test employee leave application, admin review, and state transition."""
    # Setup company and employee
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "LEAVE-CO",
        "name": "Leave Management Co",
        "contact_phone": "9911100000",
        "admin_password": "pass"
    })

    client.post("/api/login", json={"role": "company_admin", "company_id": "LEAVE-CO", "mobile": "9911100000", "password": "pass"})
    client.post("/api/company/employees", json={
        "emp_id": "EMP-L1",
        "name": "Laura Leave",
        "mobile": "9922200000",
        "work_type": "Office",
        "password": "emp_password"
    })

    # Employee applies for leave
    client.post("/api/login", json={"role": "employee", "company_id": "LEAVE-CO", "mobile": "9922200000", "password": "emp_password"})
    res_apply = client.post("/api/leaves/apply", json={
        "leave_type": "Sick",
        "start_date": "2026-09-05",
        "end_date": "2026-09-06",
        "reason": "Medical appointment"
    })
    assert res_apply.status_code == 200
    leave_id = res_apply.json["leave_id"]

    # Admin reviews leave request
    client.post("/api/login", json={"role": "company_admin", "company_id": "LEAVE-CO", "mobile": "9911100000", "password": "pass"})
    res_rev = client.post(f"/api/company/leaves/{leave_id}/review", json={
        "decision": "approved",
        "remarks": "Approved with sick leave quota"
    })
    assert res_rev.status_code == 200
    assert res_rev.json["ok"] is True


# ══════════════════════════════════════════════════════════════════════════════
#  12. SYSTEM HEALTH & PRODUCTION ENDPOINT TEST
# ══════════════════════════════════════════════════════════════════════════════

def test_system_health_endpoint(client):
    """Test /health production health check endpoint."""
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json["status"] == "healthy"
    assert res.json["environment"] == "production"
    assert "timestamp_utc" in res.json


# ══════════════════════════════════════════════════════════════════════════════
#  13. EMPLOYEE SELF-REGISTRATION & APPROVAL WORKFLOW
# ══════════════════════════════════════════════════════════════════════════════

def test_employee_self_registration_and_company_admin_approval(client):
    """Verify that employee self-registration starts in PENDING, blocks login, and requires Admin approval."""
    # 1. Setup active company
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "APPR-CO",
        "name": "Approval Enterprise",
        "contact_phone": "9123450000",
        "admin_password": "admin_password"
    })

    # 2. Verify company lookup works
    res_v = client.get("/api/auth/verify-company/APPR-CO")
    assert res_v.status_code == 200
    assert res_v.json["exists"] is True
    assert res_v.json["company_name"] == "Approval Enterprise"

    # 3. Employee self-registers
    res_reg = client.post("/api/auth/register-employee", json={
        "company_id": "APPR-CO",
        "emp_id": "EMP-SELF1",
        "name": "Sam SelfRegister",
        "mobile": "9811122233",
        "email": "sam@approval.com",
        "department": "Engineering",
        "designation": "Software Dev",
        "work_type": "WFH",
        "password": "sam_secret_password"
    })
    assert res_reg.status_code == 200
    assert res_reg.json["ok"] is True
    assert res_reg.json["status"] == "pending"

    # 4. Check application status tracker
    res_status = client.post("/api/auth/check-registration-status", json={
        "identifier": "9811122233",
        "company_id": "APPR-CO"
    })
    assert res_status.status_code == 200
    assert res_status.json["found"] is True
    assert res_status.json["status"] == "pending"

    # 5. Attempting to log in while PENDING must be blocked (HTTP 403)
    res_blocked = client.post("/api/login", json={
        "role": "employee",
        "company_id": "APPR-CO",
        "mobile": "9811122233",
        "password": "sam_secret_password"
    })
    assert res_blocked.status_code == 403
    assert res_blocked.json["status"] == "pending"
    assert "under review" in res_blocked.json["error"].lower()

    # 6. Company Admin logs in and views pending employee queue
    client.post("/api/login", json={"role": "company_admin", "company_id": "APPR-CO", "mobile": "9123450000", "password": "admin_password"})
    res_pending = client.get("/api/company/pending-employees?company_id=APPR-CO")
    assert res_pending.status_code == 200
    assert len(res_pending.json["pending_employees"]) == 1
    assert res_pending.json["pending_employees"][0]["emp_id"] == "EMP-SELF1"

    # 7. Company Admin approves employee
    res_appr = client.post("/api/company/pending-employees/EMP-SELF1/approve?company_id=APPR-CO", json={})
    assert res_appr.status_code == 200
    assert res_appr.json["ok"] is True

    # 8. Employee can now successfully log in!
    res_login_ok = client.post("/api/login", json={
        "role": "employee",
        "company_id": "APPR-CO",
        "mobile": "9811122233",
        "password": "sam_secret_password"
    })
    assert res_login_ok.status_code == 200
    assert res_login_ok.json["ok"] is True
    assert res_login_ok.json["emp_id"] == "EMP-SELF1"


def test_superadmin_employee_approval_and_rejection(client):
    """Test Super Admin platform-wide approval and rejection of pending employee signups."""
    # Setup company
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    client.post("/api/superadmin/companies", json={
        "company_id": "GLOBAL-CO",
        "name": "Global Corp",
        "contact_phone": "9999111100",
        "admin_password": "pass"
    })

    # Employee 1 & Employee 2 self-register
    client.post("/api/auth/register-employee", json={
        "company_id": "GLOBAL-CO",
        "emp_id": "EMP-G1",
        "name": "George One",
        "mobile": "9999111101",
        "password": "pass"
    })
    client.post("/api/auth/register-employee", json={
        "company_id": "GLOBAL-CO",
        "emp_id": "EMP-G2",
        "name": "Gina Two",
        "mobile": "9999111102",
        "password": "pass"
    })

    # Super Admin retrieves global pending approvals
    client.post("/api/login", json={"role": "super_admin", "email": SUPER_ADMIN_EMAIL, "password": SUPER_ADMIN_PASS})
    res_all_pending = client.get("/api/superadmin/pending-approvals")
    assert res_all_pending.status_code == 200
    assert len(res_all_pending.json["pending_employees"]) == 2

    # Super Admin approves EMP-G1 and rejects EMP-G2
    res_appr1 = client.post("/api/superadmin/employees/GLOBAL-CO/EMP-G1/approve")
    assert res_appr1.status_code == 200
    assert res_appr1.json["ok"] is True

    res_rej2 = client.post("/api/superadmin/employees/GLOBAL-CO/EMP-G2/reject")
    assert res_rej2.status_code == 200
    assert res_rej2.json["ok"] is True

    # EMP-G1 can log in
    res_login_g1 = client.post("/api/login", json={"role": "employee", "company_id": "GLOBAL-CO", "mobile": "9999111101", "password": "pass"})
    assert res_login_g1.status_code == 200

    # EMP-G2 is rejected and cannot log in
    res_login_g2 = client.post("/api/login", json={"role": "employee", "company_id": "GLOBAL-CO", "mobile": "9999111102", "password": "pass"})
    assert res_login_g2.status_code == 403
    assert "rejected" in res_login_g2.json["error"].lower()



