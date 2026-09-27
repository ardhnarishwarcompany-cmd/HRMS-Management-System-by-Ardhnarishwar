import urllib.request
import urllib.error
import http.cookiejar
import json
import time
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

def test_full_workflow():
    client = Client()
    uid = random.randint(1000, 9999)
    comp_id = f"ZNT_{uid}"
    comp_phone = f"98111{uid:05d}"
    comp_email = f"admin{uid}@zenithcorp.com"
    comp_pass = f"zenithpass{uid}"
    
    emp_id = f"ZEN-{uid}"
    emp_phone = f"98222{uid:05d}"
    emp_email = f"sarah{uid}@zenithcorp.com"
    emp_pass = f"sarahpass{uid}"

    print(f"\n--- 1. Health check ---")
    status, res = client.request("GET", "/health")
    assert status == 200, f"Health check failed: {res}"
    print("Health OK:", res)

    print(f"\n--- 2. Company Self-Registration ({comp_id}) ---")
    company_payload = {
        "company_id": comp_id,
        "name": f"Zenith Global {uid} Corp",
        "gst_number": f"27AABCZ{uid}F1Z5",
        "country": "India",
        "timezone": "Asia/Kolkata",
        "admin_name": f"Zenith Admin {uid}",
        "phone": comp_phone,
        "email": comp_email,
        "admin_password": comp_pass
    }
    status, res = client.request("POST", "/api/auth/register-company", company_payload)
    print("Company Registration Response:", status, res)
    assert status == 200 and res.get("ok") is True

    print(f"\n--- 3. Track Status by Workspace ID ('{comp_id}') ---")
    status, res = client.request("POST", "/api/auth/check-registration-status", {"identifier": comp_id})
    print(f"Track by Workspace ID ({comp_id}):", status, res)
    assert status == 200
    assert res["found"] is True
    assert res["status"] == "pending"
    assert res["company_id"] == comp_id

    print(f"\n--- 4. Track Status by Phone ('{comp_phone}') ---")
    status, res = client.request("POST", "/api/auth/check-registration-status", {"identifier": comp_phone})
    print(f"Track by Phone ({comp_phone}):", status, res)
    assert status == 200
    assert res["found"] is True
    assert res["status"] == "pending"

    print(f"\n--- 5. Track Status by Email ('{comp_email}') ---")
    status, res = client.request("POST", "/api/auth/check-registration-status", {"identifier": comp_email.upper()})
    print(f"Track by Email ({comp_email}):", status, res)
    assert status == 200
    assert res["found"] is True

    print(f"\n--- 6. Attempt Login with Pending Company (Should get 403 Pending) ---")
    status, res = client.request("POST", "/api/login", {
        "role": "company_admin",
        "company_id": comp_id,
        "mobile": comp_phone,
        "password": comp_pass
    })
    print("Pending Login Status:", status, res)
    assert status == 403
    assert res.get("status") == "pending"

    print(f"\n--- 7. Super Admin Login & Approval ---")
    sa_client = Client()
    status, res = sa_client.request("POST", "/api/login", {
        "role": "super_admin",
        "email": "superadmin@ardhnarishwar.com",
        "password": "superadmin123"
    })
    assert status == 200 and res.get("ok") is True
    print("Super Admin logged in successfully")

    # Approve company
    status, res = sa_client.request("POST", f"/api/superadmin/companies/{comp_id}/approve")
    print("Approve Company Response:", status, res)
    assert status == 200 and res.get("ok") is True

    print(f"\n--- 8. Track Status after Approval (Should be Active) ---")
    status, res = client.request("POST", "/api/auth/check-registration-status", {"identifier": comp_id})
    print("Track after approval:", status, res)
    assert status == 200
    assert res.get("status") == "active"

    print(f"\n--- 9. Company Admin Login (Should succeed) ---")
    comp_client = Client()
    status, res = comp_client.request("POST", "/api/login", {
        "role": "company_admin",
        "company_id": comp_id,
        "mobile": comp_phone,
        "password": comp_pass
    })
    print("Company Admin Login Response:", status, res)
    assert status == 200 and res.get("ok") is True
    assert res.get("role") == "company_admin"

    print(f"\n--- 10. Employee Self-Registration ({emp_id}) ---")
    emp_payload = {
        "company_id": comp_id,
        "emp_id": emp_id,
        "name": "Sarah Jenkins",
        "mobile": emp_phone,
        "email": emp_email,
        "department": "Engineering",
        "designation": "Cloud Architect",
        "work_type": "Office",
        "password": emp_pass
    }
    status, res = client.request("POST", "/api/auth/register-employee", emp_payload)
    print("Employee Registration Response:", status, res)
    assert status == 200 and res.get("ok") is True

    print(f"\n--- 11. Track Employee Status by Emp ID ('{emp_id}') ---")
    status, res = client.request("POST", "/api/auth/check-registration-status", {"identifier": emp_id})
    print("Track Employee by Emp ID:", status, res)
    assert status == 200
    assert res["found"] is True
    assert res["status"] == "pending"
    assert res["emp_id"] == emp_id

    print(f"\n--- 12. Employee Login Attempt (Should get 403 Pending) ---")
    status, res = client.request("POST", "/api/login", {
        "role": "employee",
        "company_id": comp_id,
        "emp_id": emp_id,
        "password": emp_pass
    })
    print("Employee Pending Login Response:", status, res)
    assert status == 403
    assert res.get("status") == "pending"

    print(f"\n--- 13. Super Admin Approves Employee ---")
    status, res = sa_client.request("POST", f"/api/superadmin/employees/{comp_id}/{emp_id}/approve")
    print("Super Admin Approve Employee:", status, res)
    assert status == 200 and res.get("ok") is True

    print(f"\n--- 14. Track Employee Status (Should be Active) ---")
    status, res = client.request("POST", "/api/auth/check-registration-status", {"identifier": emp_id})
    print("Track Employee after approval:", status, res)
    assert status == 200
    assert res.get("status") == "active"

    print(f"\n--- 15. Employee Login (Should Succeed) ---")
    emp_client = Client()
    status, res = emp_client.request("POST", "/api/login", {
        "role": "employee",
        "company_id": comp_id,
        "emp_id": emp_id,
        "password": emp_pass
    })
    print("Employee Login Response:", status, res)
    assert status == 200 and res.get("ok") is True
    assert res.get("role") == "employee"

    print("\n========================================================")
    print(" ALL 15 TRACK STATUS, REGISTRATION & LOGIN CHECKS PASSED! ")
    print("========================================================")

if __name__ == "__main__":
    test_full_workflow()
