import json
import time
import urllib.request
import urllib.error

def verify_live():
    uid = str(int(time.time()))[-4:]
    company_id = f"TLIVE{uid}"
    phone = f"987600{uid}"

    url = 'http://127.0.0.1:5002/api/auth/register-company'
    payload = {
        'company_id': company_id,
        'name': f'Test Live Corp {uid}',
        'country': 'India',
        'timezone': 'Asia/Kolkata',
        'admin_name': 'Admin User',
        'phone': phone,
        'admin_password': 'password123'
    }
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode('utf-8'),
        headers={'Content-Type': 'application/json'}
    )
    res = urllib.request.urlopen(req)
    data = json.loads(res.read().decode('utf-8'))
    print("Registration Response:", data)
    assert data["ok"] is True
    assert data["status"] == "pending"

    # Try login before approval - should get 403
    login_url = 'http://127.0.0.1:5002/api/login'
    login_payload = {
        'role': 'company_admin',
        'company_id': company_id,
        'mobile': phone,
        'password': 'password123'
    }
    login_req = urllib.request.Request(
        login_url,
        data=json.dumps(login_payload).encode('utf-8'),
        headers={'Content-Type': 'application/json'}
    )
    try:
        urllib.request.urlopen(login_req)
        print("ERROR: Should have been blocked!")
    except urllib.error.HTTPError as e:
        err_body = json.loads(e.read().decode('utf-8'))
        print(f"Correctly blocked with HTTP {e.code}: {err_body}")
        assert e.code == 403
        assert "super admin approval" in err_body["error"].lower()

    print("ALL LIVE WORKFLOW VERIFICATIONS PASSED!")

if __name__ == '__main__':
    verify_live()
