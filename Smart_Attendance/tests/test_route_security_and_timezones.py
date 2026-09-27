import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

import pytest
from app import app
from timezone_engine import (
    resolve_entity_timezone,
    get_utc_date_range_for_local_date,
    format_utc_to_tz,
    evaluate_attendance_status
)


@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SECRET_KEY'] = 'test_secret_suite_key_2026'
    with app.test_client() as c:
        yield c


def test_unauthenticated_landing_redirect(client):
    """Test 1: Unauthenticated visit to root / redirects to /login."""
    res = client.get('/', follow_redirects=False)
    assert res.status_code == 302
    assert '/login' in res.headers.get('Location', '')


def test_unauthenticated_protected_route_guards(client):
    """Test 2: Unauthenticated visits to protected routes redirect to /login with redirectTo."""
    routes = ['/superadmin', '/admin', '/employee', '/employee/face', '/employee/wifi', '/employee/otp', '/employee/field']
    for r in routes:
        res = client.get(r, follow_redirects=False)
        assert res.status_code == 302, f"Route {r} should redirect unauthenticated access"
        location = res.headers.get('Location', '')
        assert '/login' in location
        assert 'redirectTo=' in location


def test_navigation_route_aliases(client):
    """Test 3: Navigation route aliases redirect properly."""
    aliases = {
        '/admin/workspaces': 'tab=companies',
        '/admin/requests/pending': 'tab=pending',
        '/admin/attendance/global': 'tab=attendance',
        '/admin/security/global': 'tab=audit',
    }
    for alias, target in aliases.items():
        res = client.get(alias, follow_redirects=False)
        assert res.status_code == 302
        assert target in res.headers.get('Location', '')


def test_timezone_resolution_hierarchy():
    """Test 4: Hierarchical timezone resolution fallback."""
    # 1. User/Employee override
    user = {"timezone": "America/New_York"}
    branch = {"timezone": "Europe/London"}
    company = {"timezone": "Asia/Kolkata"}
    assert resolve_entity_timezone(user, branch, company) == "America/New_York"

    # 2. Branch override
    user_empty = {}
    assert resolve_entity_timezone(user_empty, branch, company) == "Europe/London"

    # 3. Company default
    branch_empty = {}
    assert resolve_entity_timezone(user_empty, branch_empty, company) == "Asia/Kolkata"

    # 4. Default fallback
    company_empty = {}
    assert resolve_entity_timezone(user_empty, branch_empty, company_empty, "UTC") == "UTC"
    assert resolve_entity_timezone(None, None, None, "Asia/Kolkata") == "Asia/Kolkata"


def test_utc_date_range_for_local_date():
    """Test 5: Translation of local calendar day to UTC bounds."""
    # India IST (UTC+05:30)
    utc_start, utc_end = get_utc_date_range_for_local_date("2026-09-02", "Asia/Kolkata")
    assert "2026-09-01" in utc_start  # 00:00:00 IST is 18:30:00 UTC previous day
    assert "18:30:00" in utc_start
    assert "2026-09-02" in utc_end

    # New York (EDT, UTC-04:00)
    utc_start_ny, utc_end_ny = get_utc_date_range_for_local_date("2026-09-02", "America/New_York")
    assert "2026-09-02" in utc_start_ny
    assert "04:00:00" in utc_start_ny
    assert "2026-09-03" in utc_end_ny


def test_superadmin_authenticated_access(client):
    """Test 6: Authenticated Super Admin can access /admin/dashboard directly and login returns canonical redirect."""
    login_res = client.post('/api/login', json={
        "role": "super_admin",
        "email": "superadmin@ardhnarishwar.com",
        "password": "superadmin123"
    })
    assert login_res.status_code == 200
    assert login_res.json.get("ok") is True
    assert login_res.json.get("redirect_url") == "/admin/dashboard"

    # Access /admin/dashboard and /superadmin
    for path in ['/admin/dashboard', '/superadmin']:
        sa_res = client.get(path)
        assert sa_res.status_code == 200
        assert b"Global Attendance Management System" in sa_res.data

    # When authenticated as super_admin, / redirects to /admin/dashboard
    root_res = client.get('/', follow_redirects=False)
    assert root_res.status_code == 302
    loc = root_res.headers.get('Location', '')
    assert '/admin/dashboard' in loc or '/superadmin' in loc


def test_favicon_endpoint(client):
    """Test 7: Favicon endpoint returns 200 and svg content."""
    res = client.get('/favicon.ico')
    assert res.status_code == 200
    assert 'image/svg+xml' in res.content_type
    assert b'<svg' in res.data

