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

def test_target_company_registration_and_validation():
    client = Client()
    uid = random.randint(1000, 9999)
    comp_code = f"AKSHAT_{uid}"
    comp_name = f"Akshat Global {uid} Corp"

    print("--- 1. Testing Unregistered Target Workspace Lookup ---")
    status, res = client.request("GET", f"/api/auth/verify-company/NON_EXISTENT_{uid}")
    print(f"Unregistered Workspace Verify: {status} -> {res.get('error')}")
    assert status == 404
    assert res.get("can_register_company") is True

    print("\n--- 2. Registering Organization Workspace ---")
    status, res = client.request("POST", "/api/auth/register-company", {
        "company_id": comp_code,
        "name": comp_name,
        "country": "India",
        "timezone": "Asia/Kolkata",
        "admin_name": f"Akshat Admin {uid}",
        "phone": f"98111{uid:05d}",
        "email": f"admin{uid}@akshatglobal.com",
        "admin_password": "akshatpassword123"
    })
    print(f"Company Registration: {status} -> {res.get('message')}")
    assert status == 200 and res.get("ok") is True

    print("\n--- 3. Testing Flexible Target Workspace ID Lookups ---")
    # Exact lookup
    status, res = client.request("GET", f"/api/auth/verify-company/{comp_code}")
    print(f"Exact ID Lookup ({comp_code}): {status}, Found ID={res.get('company_id')}, Status={res.get('status')}")
    assert status == 200 and res.get("exists") is True
    assert res.get("company_id") == comp_code

    # Lowercase lookup
    status, res = client.request("GET", f"/api/auth/verify-company/{comp_code.lower()}")
    print(f"Lowercase ID Lookup ({comp_code.lower()}): {status}, Found ID={res.get('company_id')}")
    assert status == 200 and res.get("company_id") == comp_code

    # Name-based lookup
    status, res = client.request("GET", f"/api/auth/verify-company/{urllib.parse.quote(comp_name)}")
    print(f"Name Lookup ({comp_name}): {status}, Found ID={res.get('company_id')}")
    assert status == 200 and res.get("company_id") == comp_code

    # Special char format (e.g. AKSHAT@12)
    special_query = f"AKSHAT@{uid}"
    status, res = client.request("GET", f"/api/auth/verify-company/{urllib.parse.quote(special_query)}")
    print(f"Special Format Lookup ({special_query}): {status}, Found ID={res.get('company_id')}")
    assert status == 200 and res.get("company_id") == comp_code

    print("\n--- 4. Employee Registration under Flexible Target Company Input ---")
    emp_id = f"EMP-{uid}"
    status, res = client.request("POST", "/api/auth/register-employee", {
        "company_id": special_query,  # e.g. AKSHAT@1234
        "emp_id": emp_id,
        "name": f"Varsha Staff {uid}",
        "mobile": f"98222{uid:05d}",
        "email": f"varsha{uid}@akshatglobal.com",
        "department": "Engineering",
        "designation": "Software Developer",
        "work_type": "Office",
        "password": "varshapassword123"
    })
    print(f"Employee Registration: {status} -> {res.get('message')}")
    assert status == 200 and res.get("ok") is True

    print("\n--- 5. Super Admin Approval Flow ---")
    sa = Client()
    sa.request("POST", "/api/login", {
        "role": "super_admin",
        "email": "superadmin@ardhnarishwar.com",
        "password": "superadmin123"
    })
    # Approve company
    status, res = sa.request("POST", f"/api/superadmin/companies/{comp_code}/approve")
    print(f"Super Admin Approve Company: {status} -> {res.get('message')}")
    assert status == 200

    # Approve employee
    status, res = sa.request("POST", f"/api/superadmin/employees/{comp_code}/{emp_id}/approve")
    print(f"Super Admin Approve Employee: {status} -> {res.get('message')}")
    assert status == 200

    print("\n--- 6. Post-Approval Employee & Company Admin Logins ---")
    # Employee Login with case-insensitive / flexible company ID
    emp_client = Client()
    status, res = emp_client.request("POST", "/api/login", {
        "role": "employee",
        "company_id": special_query,
        "identifier": emp_id,
        "password": "varshapassword123"
    })
    print(f"Employee Login with '{special_query}': {status}, redirect={res.get('redirect_url')}")
    assert status == 200 and res.get("redirect_url") in ("/employee/portal", "/employee")

    # Company Admin Login
    admin_client = Client()
    status, res = admin_client.request("POST", "/api/login", {
        "role": "company_admin",
        "company_id": comp_code,
        "identifier": f"98111{uid:05d}",
        "password": "akshatpassword123"
    })
    print(f"Company Admin Login: {status}, redirect={res.get('redirect_url')}")
    assert status == 200 and res.get("redirect_url") in ("/workspace/dashboard", "/admin")

    print("\n==================================================================")
    print(" ALL TARGET COMPANY WORKSPACE REGISTRATION & LOOKUP TESTS PASSED! ")
    print("==================================================================")

if __name__ == "__main__":
    test_target_company_registration_and_validation()
