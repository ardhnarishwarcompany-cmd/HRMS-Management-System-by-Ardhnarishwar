import urllib.request
import urllib.error
import http.cookiejar
import json
import random

BASE_URL = "http://127.0.0.1:5002"

class Client:
    def __init__(self):
        self.cookie_jar = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.cookie_jar))

    def request(self, method, path, data=None):
        url = f"{BASE_URL}{path}"
        headers = {"Content-Type": "application/json"}
        req_data = json.dumps(data).encode("utf-8") if data is not None else None
        req = urllib.request.Request(url, data=req_data, headers=headers, method=method)
        try:
            with self.opener.open(req) as resp:
                status = resp.status
                body = resp.read().decode("utf-8")
                return status, json.loads(body) if body else {}
        except urllib.error.HTTPError as e:
            status = e.code
            body = e.read().decode("utf-8")
            return status, json.loads(body) if body else {}

def test_superadmin_and_role_isolation():
    sa = Client()

    # 1. Super Admin Login & Redirect
    print("--- 1. Super Admin Login ---")
    status, res = sa.request("POST", "/api/login", {
        "role": "super_admin",
        "email": "superadmin@ardhnarishwar.com",
        "password": "superadmin123"
    })
    print(f"Super Admin Login: {status}, redirect={res.get('redirect_url')}")
    assert status == 200 and res.get("ok") is True
    assert res.get("redirect_url") in ("/admin/dashboard", "/superadmin")
    assert res.get("role") == "super_admin"

    # 2. Super Admin Creates Company Alpha (ALP) and Company Beta (BET)
    uid = random.randint(1000, 9999)
    comp_a = f"ALP_{uid}"
    comp_b = f"BET_{uid}"

    status, _ = sa.request("POST", "/api/superadmin/companies", {
        "company_id": comp_a,
        "name": f"Alpha Global {uid}",
        "contact_phone": f"98111{uid:05d}",
        "contact_email": f"admin{uid}@alphaglobal.com",
        "admin_password": "alphapassword123"
    })
    assert status == 200

    status, _ = sa.request("POST", "/api/superadmin/companies", {
        "company_id": comp_b,
        "name": f"Beta Dynamics {uid}",
        "contact_phone": f"98222{uid:05d}",
        "contact_email": f"admin{uid}@betadynamics.com",
        "admin_password": "betapassword123"
    })
    assert status == 200
    print(f"Created Tenants: {comp_a} and {comp_b}")

    # 3. Add Employee in Alpha and Employee in Beta
    emp_a = f"ALP-EMP-{uid}"
    emp_b = f"BET-EMP-{uid}"

    sa.request("POST", "/api/company/employees", {
        "company_id": comp_a,
        "emp_id": emp_a,
        "name": f"Alice Alpha {uid}",
        "mobile": f"98333{uid:05d}",
        "email": f"alice{uid}@alphaglobal.com",
        "department": "Engineering",
        "designation": "Lead",
        "work_type": "Remote",
        "password": "alicepassword123"
    })

    sa.request("POST", "/api/company/employees", {
        "company_id": comp_b,
        "emp_id": emp_b,
        "name": f"Bob Beta {uid}",
        "mobile": f"98444{uid:05d}",
        "email": f"bob{uid}@betadynamics.com",
        "department": "Operations",
        "designation": "Manager",
        "work_type": "Office",
        "password": "bobpassword123"
    })

    # 4. Super Admin Universal Access Verification
    print("--- 4. Super Admin Universal Global Access ---")
    # Super Admin accesses Company A data
    status, res = sa.request("GET", f"/api/company/employees?company_id={comp_a}")
    assert status == 200 and len(res.get("employees", [])) >= 1
    assert any(e["emp_id"] == emp_a for e in res["employees"])
    print(f"Super Admin accessed {comp_a} employees: OK")

    # Super Admin accesses Company B data
    status, res = sa.request("GET", f"/api/company/employees?company_id={comp_b}")
    assert status == 200 and len(res.get("employees", [])) >= 1
    assert any(e["emp_id"] == emp_b for e in res["employees"])
    print(f"Super Admin accessed {comp_b} employees: OK")

    # Super Admin accesses Global Attendance Stream across all companies
    status, res = sa.request("GET", "/api/superadmin/global-attendance")
    assert status == 200 and res.get("ok") is True
    print(f"Super Admin global attendance stream count: {res.get('count')}")

    # Super Admin accesses Company A Profile via api_me
    status, res = sa.request("GET", f"/api/me?company_id={comp_a}")
    assert status == 200 and res.get("company", {}).get("company_id") == comp_a
    print(f"Super Admin tenant context switch for {comp_a}: OK")

    # 5. Company Admin A Login and Domain Isolation
    print("--- 5. Company Admin A Login & Strict Domain Confinement ---")
    admin_a = Client()
    status, res = admin_a.request("POST", "/api/login", {
        "role": "company_admin",
        "company_id": comp_a,
        "identifier": f"98111{uid:05d}",
        "password": "alphapassword123"
    })
    print(f"Company Admin A Login: {status}, redirect={res.get('redirect_url')}")
    assert status == 200 and res.get("ok") is True
    assert res.get("redirect_url") in ("/workspace/dashboard", "/admin")

    # Company Admin A accesses Company A data (Should SUCCEED)
    status, res = admin_a.request("GET", f"/api/company/employees?company_id={comp_a}")
    assert status == 200 and res.get("ok") is True
    print(f"Company Admin A accessing {comp_a} employees: 200 OK")

    # Company Admin A attempts to access Company B data (Must get 403 Cross-tenant forbidden)
    status, res = admin_a.request("GET", f"/api/company/employees?company_id={comp_b}")
    print(f"Company Admin A accessing {comp_b} employees (Forbidden): {status} {res.get('error')}")
    assert status == 403
    assert "Cross-tenant access forbidden" in res.get("error", "")

    # Company Admin A attempts to access Super Admin Endpoints (Must get 403 Access Denied)
    status, res = admin_a.request("GET", "/api/superadmin/companies")
    print(f"Company Admin A accessing /api/superadmin/companies: {status}")
    assert status == 403

    status, res = admin_a.request("GET", "/api/superadmin/global-attendance")
    print(f"Company Admin A accessing /api/superadmin/global-attendance: {status}")
    assert status == 403

    # 6. Employee A Login and Personal Domain Confinement
    print("--- 6. Employee A Login & Personal Confinement ---")
    emp_client = Client()
    status, res = emp_client.request("POST", "/api/login", {
        "role": "employee",
        "company_id": comp_a,
        "identifier": emp_a,
        "password": "alicepassword123"
    })
    print(f"Employee A Login: {status}, redirect={res.get('redirect_url')}")
    assert status == 200 and res.get("ok") is True
    assert res.get("redirect_url") in ("/employee/portal", "/employee")

    # Employee A attempts to access Super Admin Endpoints (Must get 403 Access Denied)
    status, res = emp_client.request("GET", "/api/superadmin/companies")
    assert status == 403
    print(f"Employee A accessing Super Admin API: {status} (Blocked)")

    # Employee A attempts to access Company Profile modification (Must get 403 Access Denied)
    status, res = emp_client.request("POST", f"/api/company/profile?company_id={comp_a}", {"name": "Hacked"})
    assert status == 403
    print(f"Employee A accessing Company Admin API: {status} (Blocked)")

    print("\n========================================================")
    print(" ALL SUPER ADMIN & ROLE ACCESS ISOLATION CHECKS PASSED! ")
    print("========================================================")

if __name__ == "__main__":
    test_superadmin_and_role_isolation()
