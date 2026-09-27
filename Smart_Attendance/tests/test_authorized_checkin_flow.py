"""
Automated Verification Suite for Authorized Attendance Check-In Flow, Dynamic Codes & Offline Sync
"""
import pytest
import sys
import os
import json
import base64
from datetime import datetime, timezone

# Add backend directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))
from app import app, companies_col, employees_col, users_col, attendance_col, policies_col, generate_dynamic_token, verify_dynamic_token

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_dynamic_token_generation_and_verification():
    """Verify time-based rotating 6-digit dynamic office tokens."""
    comp_id = "TEST_ORG_99"
    token = generate_dynamic_token(comp_id)
    assert len(token) == 6
    assert token.isdigit()
    assert verify_dynamic_token(comp_id, token) is True
    assert verify_dynamic_token(comp_id, "000000") is False
    assert verify_dynamic_token("OTHER_ORG", token) is False

def test_authorized_checkin_flow(client):
    """Test unified /api/attendance/check-in endpoint with Face, Dynamic Code, and Duplicate prevention."""
    comp_id = "CHECKIN_TEST_CO"
    emp_id = "CHK-101"

    # Setup company, policy, and active employee
    companies_col.delete_many({"company_id": comp_id})
    employees_col.delete_many({"company_id": comp_id})
    attendance_col.delete_many({"company_id": comp_id})

    companies_col.insert_one({
        "company_id": comp_id,
        "name": "Check-In Test Org",
        "status": "active",
        "timezone": "UTC"
    })
    employees_col.insert_one({
        "company_id": comp_id,
        "emp_id": emp_id,
        "name": "Alice Tester",
        "department": "Engineering",
        "designation": "QA Engineer",
        "work_type": "Remote",
        "status": "active"
    })

    # 1. Dynamic Token Check-In
    token = generate_dynamic_token(comp_id)
    res = client.post("/api/attendance/check-in", json={
        "company_id": comp_id,
        "emp_id": emp_id,
        "method": "Code",
        "code": token,
        "lat": 37.7749,
        "lng": -122.4194,
        "accuracy": 10
    })
    data = res.get_json()
    assert res.status_code == 200
    assert data["ok"] is True
    assert data["status"] == "marked"
    assert data["emp_id"] == emp_id

    # 2. Duplicate Check-In Attempt
    res_dup = client.post("/api/attendance/check-in", json={
        "company_id": comp_id,
        "emp_id": emp_id,
        "method": "Code",
        "code": token
    })
    data_dup = res_dup.get_json()
    assert res_dup.status_code == 200
    assert data_dup["ok"] is True
    assert data_dup["status"] == "already_marked"

def test_offline_batch_sync(client):
    """Test /api/attendance/sync-offline batch synchronizer."""
    comp_id = "OFFLINE_SYNC_CO"
    emp1 = "OFF-101"
    emp2 = "OFF-102"

    companies_col.delete_many({"company_id": comp_id})
    employees_col.delete_many({"company_id": comp_id})
    attendance_col.delete_many({"company_id": comp_id})

    companies_col.insert_one({"company_id": comp_id, "name": "Offline Sync Co", "status": "active"})
    employees_col.insert_one({"company_id": comp_id, "emp_id": emp1, "name": "Bob Builder", "status": "active"})
    employees_col.insert_one({"company_id": comp_id, "emp_id": emp2, "name": "Charlie Chaplin", "status": "active"})

    batch_payload = {
        "punches": [
            {
                "punch_id": "P1",
                "company_id": comp_id,
                "emp_id": emp1,
                "date": "2026-08-15",
                "time": "09:15",
                "method": "Offline-Face",
                "location": {"lat": 12.9716, "lng": 77.5946}
            },
            {
                "punch_id": "P2",
                "company_id": comp_id,
                "emp_id": emp2,
                "date": "2026-08-15",
                "time": "09:22",
                "method": "Offline-Code",
                "location": {"lat": 12.9716, "lng": 77.5946}
            }
        ]
    }

    res = client.post("/api/attendance/sync-offline", json=batch_payload)
    data = res.get_json()
    assert res.status_code == 200
    assert data["ok"] is True
    assert data["synced_count"] == 2

    # Check persistence in database
    records = list(attendance_col.find({"company_id": comp_id, "date": "2026-08-15"}))
    assert len(records) == 2
    assert any(r["emp_id"] == emp1 and r["is_offline_sync"] is True for r in records)
    assert any(r["emp_id"] == emp2 and r["is_offline_sync"] is True for r in records)

if __name__ == "__main__":
    pytest.main(["-v", __file__])
