import urllib.request
import urllib.error
import http.cookiejar
import json
import base64
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

def generate_dummy_image_b64():
    # Generate a small valid 1x1 black JPEG base64
    return "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA="

def test_camera_and_id_attendance():
    sa_client = Client()
    # 1. Super Admin Login
    status, res = sa_client.request("POST", "/api/login", {
        "role": "super_admin",
        "email": "superadmin@ardhnarishwar.com",
        "password": "superadmin123"
    })
    assert status == 200 and res.get("ok") is True

    # 2. Create Company A (NEXUS)
    uid = random.randint(1000, 9999)
    comp_a = f"NXA_{uid}"
    status, res = sa_client.request("POST", "/api/superadmin/companies", {
        "company_id": comp_a,
        "name": f"Nexus Tech {uid} Corp",
        "contact_phone": f"98777{uid:05d}",
        "contact_email": f"admin{uid}@nexustech.com",
        "timezone": "Asia/Kolkata",
        "admin_password": "adminpassword123",
        "office_locations": [{
            "name": "Global HQ",
            "lat": 28.6139,
            "lng": 77.2090,
            "radius_m": 1000
        }]
    })
    assert status == 200 and res.get("ok") is True

    # 3. Add Employee 1 to Company A
    emp_1 = f"EMP-{uid}"
    status, res = sa_client.request("POST", "/api/company/employees", {
        "company_id": comp_a,
        "emp_id": emp_1,
        "name": f"Alex Rivera {uid}",
        "mobile": f"98888{uid:05d}",
        "email": f"alex{uid}@nexustech.com",
        "department": "Engineering",
        "designation": "Staff Engineer",
        "work_type": "Office",
        "allowed_methods": ["Face", "OTP", "WiFi", "GPS"]
    })
    assert status == 200 and res.get("ok") is True
    print(f"Created Employee: {emp_1} under {comp_a}")

    # 4. Validate Employee via App Provided ID Endpoint
    client = Client()
    status, res = client.request("POST", "/api/attendance/validate-employee", {
        "company_id": comp_a,
        "emp_id": emp_1,
        "method": "Face"
    })
    print("Validate Employee Response:", status, res)
    assert status == 200
    assert res["valid"] is True
    assert res["employee"]["name"] == f"Alex Rivera {uid}"
    assert res["employee"]["emp_id"] == emp_1
    assert res["employee"]["company_id"] == comp_a

    # 5. Mark Attendance with Image Capture and App Provided ID
    dummy_img = generate_dummy_image_b64()
    status, res = client.request("POST", "/api/attendance/mark-face", {
        "company_id": comp_a,
        "emp_id": emp_1,
        "image": dummy_img,
        "lat": 28.6139,
        "lng": 77.2090,
        "accuracy": 15
    })
    print(f"Mark Face & Image Attendance Status: {status} ok={res.get('ok')}")
    assert status == 200
    assert res["status"] == "marked"
    assert res["emp_id"] == emp_1
    assert res["name"] == f"Alex Rivera {uid}"
    assert res["company_id"] == comp_a
    assert "status" in res
    assert "time" in res

    # 6. Attempt Duplicate Attendance on Same Day (Should inform cleanly as already_marked)
    status, res = client.request("POST", "/api/attendance/mark-face", {
        "company_id": comp_a,
        "emp_id": emp_1,
        "image": dummy_img,
        "lat": 28.6139,
        "lng": 77.2090
    })
    print(f"Duplicate Attendance Status: {status} ok={res.get('ok')}")
    assert status == 200
    assert res["status"] == "already_marked"
    assert "Attendance already marked" in res["message"]

    # 7. Check Attendance Record in Company Admin Logs
    status, res = sa_client.request("GET", f"/api/company/attendance?company_id={comp_a}&emp_id={emp_1}")
    print(f"Company Attendance Logs Status: {status} rows={len(res.get('rows', []))}")
    assert status == 200
    assert len(res["rows"]) >= 1
    assert res["rows"][0]["emp_id"] == emp_1
    assert res["rows"][0]["method"] == "Face"
    assert res["rows"][0]["photo_captured"] is True

    print("\n========================================================")
    print(" ALL IMAGE CAPTURE & APP ID ATTENDANCE CHECKS PASSED! ")
    print("========================================================")

if __name__ == "__main__":
    test_camera_and_id_attendance()
