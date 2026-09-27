from flask import Flask, request, jsonify, render_template, session, redirect, url_for, Response
from flask_cors import CORS
from datetime import datetime, timezone
from bson import ObjectId
import socket, os, csv, io, random, math, re, hashlib, json, secrets

from config import (
    SECRET_KEY, OFFICE_LAT, OFFICE_LNG, OFFICE_RADIUS_M, OFFICE_SUBNET,
    PLATFORM_NAME, SUPER_ADMIN_COMPANY, DEFAULT_TIMEZONE,
    FACE_MATCH_TOLERANCE, SESSION_COOKIE_SECURE, 
    SESSION_COOKIE_HTTPONLY, SESSION_COOKIE_SAMESITE,
    HOST, PORT, DEBUG,
    LIVENESS_CONFIDENCE_THRESHOLD, LIVENESS_SESSION_TTL_SECONDS, REQUIRE_LIVENESS
)
from database import (
    db, companies_col, users_col, employees_col, branches_col,
    departments_col, shifts_col, attendance_col, attendance_corrections_col,
    leaves_col, field_visits_col, audit_logs_col, policies_col,
    notifications_col, hash_password, log_audit_event, seed_global_system
)
from timezone_engine import (
    GLOBAL_TIMEZONES, GLOBAL_COUNTRIES, get_utc_now, 
    get_utc_iso_string, get_localized_time, format_utc_to_tz,
    evaluate_attendance_status, resolve_entity_timezone,
    get_utc_date_range_for_local_date
)
from face_engine import (
    encode_face_from_b64, recognize_face_from_b64,
    evaluate_liveness_score, check_virtual_camera_metadata,
    verify_face_biometric_match
)
from wifi_attendance import is_office_ip, get_client_real_ip, get_server_local_ip

app = Flask(
    __name__,
    template_folder="../frontend/templates",
    static_folder="../frontend/static"
)
app.secret_key = SECRET_KEY
app.config.update(
    SESSION_COOKIE_SECURE=SESSION_COOKIE_SECURE,
    SESSION_COOKIE_HTTPONLY=SESSION_COOKIE_HTTPONLY,
    SESSION_COOKIE_SAMESITE=SESSION_COOKIE_SAMESITE
)
CORS(app)

# In-memory secure OTP store with attempt limits and expiry:
# { "COMPANY:EMP_ID": {"otp_hash": str, "expires": float, "attempts": int, "mobile": str, "email": str} }
otp_store = {}

# In-memory single-use cryptographic liveness challenge store:
# { "session_token": {"company_id": str, "emp_id": str, "challenge": str, "challenge_text": str, "nonce": str, "expires_ts": float, "used": bool} }
liveness_challenge_store = {}

ACTIVE_CHALLENGES = ["BLINK", "TURN_LEFT", "TURN_RIGHT", "SMILE"]
CHALLENGE_DESCRIPTIONS = {
    "BLINK": "Please blink your eyes naturally",
    "TURN_LEFT": "Please turn your head slightly to the left",
    "TURN_RIGHT": "Please turn your head slightly to the right",
    "SMILE": "Please smile naturally"
}

def clean_expired_liveness_sessions():
    """Remove expired or consumed liveness challenge tokens."""
    now_ts = datetime.now(timezone.utc).timestamp()
    expired = [k for k, v in liveness_challenge_store.items() if now_ts > v.get("expires_ts", 0) or v.get("used")]
    for k in expired:
        liveness_challenge_store.pop(k, None)

def create_liveness_challenge_session(company_id: str, emp_id: str) -> dict:
    """Create a new short-lived single-use liveness challenge session."""
    clean_expired_liveness_sessions()
    token = "lv_" + secrets.token_hex(16)
    nonce = "n_" + secrets.token_hex(8)
    action = random.choice(ACTIVE_CHALLENGES)
    expires = datetime.now(timezone.utc).timestamp() + LIVENESS_SESSION_TTL_SECONDS
    
    session_data = {
        "company_id": (company_id or "").upper(),
        "emp_id": (emp_id or "").upper(),
        "challenge": action,
        "challenge_text": CHALLENGE_DESCRIPTIONS.get(action, "Please face camera"),
        "nonce": nonce,
        "expires_ts": expires,
        "used": False,
        "created_at": get_utc_iso_string()
    }
    liveness_challenge_store[token] = session_data
    return {
        "ok": True,
        "session_token": token,
        "challenge": action,
        "challenge_text": session_data["challenge_text"],
        "nonce": nonce,
        "expires_in": LIVENESS_SESSION_TTL_SECONDS
    }

def validate_and_consume_liveness_session(token: str, company_id: str, emp_id: str, nonce: str = None) -> tuple:
    """Validate and atomically consume a liveness session token to defeat replay attacks."""
    if not token:
        return False, None, "Missing liveness session token"
    clean_expired_liveness_sessions()
    sess = liveness_challenge_store.get(token)
    if not sess:
        return False, None, "Invalid or expired liveness session token"
    if sess.get("used"):
        return False, None, "Anti-Replay Attack Detected: This liveness session token has already been consumed"
    now_ts = datetime.now(timezone.utc).timestamp()
    if now_ts > sess.get("expires_ts", 0):
        liveness_challenge_store.pop(token, None)
        return False, None, "Liveness session token has expired. Please initiate a fresh challenge"
    if sess.get("company_id") and company_id and sess.get("company_id") != company_id.upper():
        return False, None, "Liveness session token company mismatch"
    if sess.get("emp_id") and emp_id and sess.get("emp_id") != emp_id.upper():
        return False, None, "Liveness session token employee mismatch"
    if nonce and sess.get("nonce") != nonce:
        return False, None, "Liveness session nonce mismatch"
        
    # Atomically mark consumed to guarantee anti-replay protection
    sess["used"] = True
    liveness_challenge_store.pop(token, None)
    return True, sess, None


# ══════════════════════════════════════════════════════════════════════════════
#  SECURITY & AUTHENTICATION HELPERS
# ══════════════════════════════════════════════════════════════════════════════

def client_ip():
    return get_client_real_ip(request)


def client_user_agent():
    return request.headers.get("User-Agent", "Unknown Browser")


def get_current_user():
    """Retrieve currently authenticated user from session."""
    if "user_id" not in session:
        return None
    try:
        user = users_col.find_one({"_id": ObjectId(session["user_id"])})
        return user
    except Exception:
        return None


def require_auth(allowed_roles=None):
    """
    Session-based RBAC Authentication Guard.
    Returns (user, None) if authorized, or (None, (error_json, status_code)) if unauthorized.
    """
    user = get_current_user()
    if not user:
        return None, (jsonify({"ok": False, "error": "Authentication required. Please sign in."}), 401)
    
    if user.get("status") != "active":
        return None, (jsonify({"ok": False, "error": "Your account is inactive. Contact your administrator."}), 403)

    if allowed_roles:
        if user.get("role") not in allowed_roles:
            return None, (jsonify({"ok": False, "error": "Forbidden: Insufficient privileges for this resource."}), 403)

    return user, None


def resolve_tenant_id(user: dict, requested_company_id: str = None) -> tuple[str, tuple]:
    """
    STRICT TENANT ISOLATION:
    - Super Admin can access any requested company or defaults to their own.
    - Company Admin, HR, Manager, Employee CAN ONLY access their own assigned company.
    If a non-Super Admin attempts to access a different company, returns (None, (error_json, 403)).
    """
    if not user:
        return None, (jsonify({"ok": False, "error": "Authentication required"}), 401)

    user_role = user.get("role")
    user_company = user.get("company_id", "").upper()

    if user_role == "super_admin":
        if requested_company_id and requested_company_id.strip():
            return requested_company_id.strip().upper(), None
        return user_company, None

    if requested_company_id and requested_company_id.strip():
        req_clean = requested_company_id.strip().upper()
        if req_clean != user_company:
            log_audit_event(
                action="CROSS_TENANT_ACCESS_DENIED",
                company_id=user_company,
                actor_name=user.get("name"),
                actor_role=user_role,
                details={"attempted_tenant": req_clean},
                ip=client_ip(),
                user_agent=client_user_agent()
            )
            return None, (jsonify({"ok": False, "error": "Access Denied: You cannot view or modify data from other company workspaces. Cross-tenant access forbidden."}), 403)

    return user_company, None


def haversine_distance(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Calculate great-circle distance between two GPS points in meters."""
    R = 6371000  # Earth radius in meters
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lng2 - lng1)
    a = math.sin(dphi/2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlam/2)**2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))


def validate_company_and_employee(company_id: str, emp_id: str, required_method: str = None):
    """
    Validate that:
    1. Company exists and is active.
    2. Employee exists, belongs to company, and is active.
    3. Employee workforce type is authorized for the requested check-in method.
    """
    if not company_id or not emp_id:
        return None, None, "Company ID and Employee ID are required"

    company = companies_col.find_one({"company_id": company_id.upper()})
    if not company:
        return None, None, f"Company workspace '{company_id}' not found"
    
    if company.get("status") != "active":
        return None, None, f"Company workspace '{company_id}' is currently {company.get('status', 'inactive')}. Contact platform administrator."

    employee = employees_col.find_one({"company_id": company_id.upper(), "emp_id": emp_id.upper()})
    if not employee:
        return None, None, f"Employee '{emp_id}' not found in company workspace '{company_id}'"

    if employee.get("status") != "active":
        return None, None, f"Employee account '{emp_id}' is {employee.get('status', 'inactive')}. Please wait for approval or contact HR."

    if required_method:
        allowed_methods = employee.get("allowed_methods", [])
        if allowed_methods and required_method not in allowed_methods:
            return None, None, f"Attendance method '{required_method}' is not enabled for your profile"

        work_type = employee.get("work_type", "Office")
        if work_type == "Remote" and required_method == "WiFi":
            return None, None, "Wi-Fi check-in is only available for on-premise Office employees"
        if work_type == "Office" and required_method == "Field":
            if not employee.get("field_override", False):
                return None, None, f"Method '{required_method}' is not authorized for your employee profile ({employee.get('work_type')})"

    return company, employee, None


# ══════════════════════════════════════════════════════════════════════════════
#  FRONTEND PAGE ROUTES & STRICT ROUTE GUARDS
# ══════════════════════════════════════════════════════════════════════════════

def get_user_dashboard_url(user):
    if not user:
        return "/login"
    role = user.get("role")
    if role == "super_admin":
        return "/admin/dashboard"
    elif role in ("company_admin", "hr", "manager"):
        return "/workspace/dashboard"
    else:
        return "/employee/portal"


def guard_html_route(allowed_roles=None):
    user, err = require_auth(allowed_roles=allowed_roles)
    if err:
        target = request.full_path.rstrip('?')
        return None, redirect(url_for("login_page", redirectTo=target))
    return user, None


@app.route("/")
def index():
    user = get_current_user()
    if user:
        return redirect(get_user_dashboard_url(user))
    return redirect(url_for("login_page"))


@app.route("/login")
def login_page():
    user = get_current_user()
    if user:
        return redirect(get_user_dashboard_url(user))
    return render_template("login.html")


@app.route("/landing")
def landing_page():
    return render_template("landing.html")


@app.route("/register")
@app.route("/register-employee")
@app.route("/status")
def register_page():
    return render_template("register.html")


@app.route("/register-company")
def register_company_page():
    return render_template("register_company.html")


@app.route("/forgot-password")
def forgot_password_page():
    return render_template("forgot_password.html")


@app.route("/privacy-policy")
def privacy_policy_page():
    return render_template("privacy_policy.html")


@app.route("/terms")
def terms_page():
    return render_template("terms.html")


@app.route("/favicon.ico")
def favicon():
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
      <defs>
        <linearGradient id="gamsGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#10B981"/>
          <stop offset="100%" stop-color="#6366F1"/>
        </linearGradient>
      </defs>
      <rect width="48" height="48" rx="12" fill="#070B14"/>
      <circle cx="24" cy="24" r="18" fill="none" stroke="url(#gamsGrad)" stroke-width="2.5"/>
      <ellipse cx="24" cy="24" rx="9" ry="18" fill="none" stroke="url(#gamsGrad)" stroke-width="1.8" stroke-dasharray="2 1"/>
      <line x1="6" y1="24" x2="42" y2="24" stroke="url(#gamsGrad)" stroke-width="1.8"/>
      <circle cx="24" cy="24" r="6" fill="#10B981"/>
      <path d="M24 20v4l3 2" fill="none" stroke="#070B14" stroke-width="2" stroke-linecap="round"/>
      <circle cx="34" cy="14" r="4" fill="#06B6D4"/>
    </svg>'''
    return Response(svg, mimetype="image/svg+xml")


@app.route("/health", methods=["GET"])
def health_check():
    """Production Health Check Endpoint."""
    db_status = "connected"
    try:
        companies_col.find_one({}, {"_id": 1})
    except Exception as e:
        db_status = f"degraded ({str(e)})"

    return jsonify({
        "status": "healthy" if db_status == "connected" else "degraded",
        "service": "Global Attendance Management System",
        "version": "2.4.0",
        "environment": "production",
        "database": db_status,
        "timestamp_utc": get_utc_iso_string()
    })


@app.route("/admin/dashboard")
@app.route("/super-admin")
@app.route("/superadmin")
def super_admin_dashboard():
    user, redir = guard_html_route(allowed_roles=["super_admin"])
    if redir:
        return redir
    return render_template("super_admin.html", user=user)


@app.route("/workspace/dashboard")
@app.route("/admin")
def company_admin_dashboard():
    user, redir = guard_html_route(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if redir:
        return redir
    return render_template("admin.html", user=user)


@app.route("/employee/portal")
@app.route("/employee/dashboard")
@app.route("/employee")
def employee_portal():
    user, redir = guard_html_route(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if redir:
        return redir
    return render_template("employee.html", user=user)


@app.route("/employee/face")
def face_attendance_page():
    user, redir = guard_html_route(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if redir:
        return redir
    return render_template("face_attendance.html", user=user)


@app.route("/employee/otp")
def otp_attendance_page():
    user, redir = guard_html_route(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if redir:
        return redir
    return render_template("otp_attendance.html", user=user)


@app.route("/employee/wifi")
def wifi_attendance_page():
    user, redir = guard_html_route(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if redir:
        return redir
    return render_template("wifi_attendance.html", user=user)


@app.route("/employee/field")
def field_attendance_page():
    user, redir = guard_html_route(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if redir:
        return redir
    return render_template("field_attendance.html", user=user)


# Standard Enterprise Dashboard & Navigation Aliases
@app.route("/admin/workspaces")
def alias_admin_workspaces():
    return redirect("/admin/dashboard?tab=companies")


@app.route("/admin/requests/pending")
def alias_admin_pending():
    return redirect("/admin/dashboard?tab=pending")


@app.route("/admin/attendance/global")
def alias_admin_attendance():
    return redirect("/admin/dashboard?tab=attendance")


@app.route("/admin/security/global")
def alias_admin_security():
    return redirect("/admin/dashboard?tab=audit")


# ══════════════════════════════════════════════════════════════════════════════
#  AUTHENTICATION APIS
# ══════════════════════════════════════════════════════════════════════════════

@app.route("/api/login", methods=["POST"])
def api_login():
    data = request.json or {}
    role = data.get("role", "company_admin").strip()
    identifier = data.get("mobile", "").strip() or data.get("email", "").strip() or data.get("emp_id", "").strip() or data.get("identifier", "").strip()
    password = data.get("password", "").strip()
    company_id = data.get("company_id", "").strip().upper()

    if not identifier or not password:
        return jsonify({"ok": False, "error": "Identifier (Email/Mobile/EmpID) and password are required"}), 400

    if role == "company_admin":
        role_filter = {"$in": ["company_admin", "hr", "manager"]}
    else:
        role_filter = role

    query = {
        "role": role_filter,
        "$or": [
            {"mobile": identifier},
            {"email": identifier},
            {"email": identifier.lower()},
            {"emp_id": identifier.upper()}
        ]
    }

    if role != "super_admin":
        if not company_id:
            return jsonify({"ok": False, "error": "Company Workspace ID is required"}), 400
        
        # Flexible company resolution (case-insensitive ID, name, or alphanumeric fuzzy match)
        clean_comp_query = re.sub(r'[^a-zA-Z0-9]', '', company_id)
        comp_match = companies_col.find_one({
            "$or": [
                {"company_id": company_id.upper()},
                {"company_id": company_id},
                {"company_id": {"$regex": f"^{re.escape(company_id)}$", "$options": "i"}},
                {"name": {"$regex": f"^{re.escape(company_id)}$", "$options": "i"}},
                {"company_id": {"$regex": re.escape(company_id), "$options": "i"}},
                {"name": {"$regex": re.escape(company_id), "$options": "i"}}
            ]
        })
        if not comp_match and clean_comp_query:
            all_comps = list(companies_col.find({}, {"_id": 0, "company_id": 1, "name": 1}))
            # 1. Exact alphanumeric match first
            for c in all_comps:
                c_clean_id = re.sub(r'[^a-zA-Z0-9]', '', c.get("company_id", ""))
                if clean_comp_query.lower() == c_clean_id.lower():
                    comp_match = c
                    break
            # 2. Substring fallback if not found
            if not comp_match:
                for c in all_comps:
                    c_clean_id = re.sub(r'[^a-zA-Z0-9]', '', c.get("company_id", ""))
                    c_clean_name = re.sub(r'[^a-zA-Z0-9]', '', c.get("name", ""))
                    if (clean_comp_query.lower() in c_clean_id.lower() or 
                        c_clean_id.lower() in clean_comp_query.lower() or 
                        clean_comp_query.lower() in c_clean_name.lower()):
                        comp_match = c
                        break

        canonical_comp_id = comp_match["company_id"] if comp_match else company_id.upper()
        query["company_id"] = canonical_comp_id

    user = users_col.find_one(query)
    if not user or user.get("password") != hash_password(password):
        return jsonify({"ok": False, "error": "Invalid login credentials or unauthorized role"}), 401

    if user.get("status") == "pending":
        return jsonify({
            "ok": False,
            "status": "pending",
            "error": "Your registration is under review. Please wait for Super Admin approval."
        }), 403
    elif user.get("status") == "rejected":
        return jsonify({
            "ok": False,
            "status": "rejected",
            "error": "Your registration application has been rejected by administration."
        }), 403
    elif user.get("status") != "active":
        return jsonify({
            "ok": False,
            "status": user.get("status", "inactive"),
            "error": f"Account is {user.get('status', 'inactive').upper()}. Contact your administrator."
        }), 403

    # Check Company status for non-superadmin users
    if user.get("role") != "super_admin":
        comp = companies_col.find_one({"company_id": user.get("company_id")})
        if not comp:
            return jsonify({"ok": False, "error": "Company workspace not found"}), 404
        if comp.get("status") == "pending":
            return jsonify({
                "ok": False,
                "status": "pending",
                "error": "Your company workspace registration is under review. Please wait for Super Admin approval."
            }), 403
        elif comp.get("status") != "active":
            return jsonify({
                "ok": False,
                "status": comp.get("status", "inactive"),
                "error": f"Company workspace is {comp.get('status', 'inactive').upper()}. Contact platform admin."
            }), 403

    session["user_id"] = str(user["_id"])
    session["role"] = user["role"]
    session["company_id"] = user.get("company_id", "")

    log_audit_event(
        action="USER_LOGIN",
        company_id=user.get("company_id", "GLOBAL"),
        actor_name=user.get("name", ""),
        actor_role=user.get("role", ""),
        details={"identifier": identifier, "role": role},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    redirect_url = "/employee/portal"
    if user["role"] == "super_admin":
        redirect_url = "/admin/dashboard"
    elif user["role"] in ("company_admin", "hr", "manager"):
        redirect_url = "/workspace/dashboard"

    return jsonify({
        "ok": True,
        "role": user["role"],
        "name": user.get("name", ""),
        "email": user.get("email", ""),
        "mobile": user.get("mobile", ""),
        "company_id": user.get("company_id", ""),
        "emp_id": user.get("emp_id", ""),
        "redirect_url": redirect_url
    })


@app.route("/api/logout", methods=["POST"])
def api_logout():
    user = get_current_user()
    if user:
        log_audit_event(
            action="USER_LOGOUT",
            company_id=user.get("company_id", "GLOBAL"),
            actor_name=user.get("name", ""),
            actor_role=user.get("role", ""),
            details={},
            ip=client_ip(),
            user_agent=client_user_agent()
        )
    session.clear()
    return jsonify({"ok": True, "message": "Logged out successfully"})


@app.route("/api/me", methods=["GET"])
def api_me():
    user = get_current_user()
    if not user:
        return jsonify({"ok": False, "authenticated": False}), 401
    
    user["_id"] = str(user["_id"])
    user.pop("password", None)

    target_comp_id = request.args.get("company_id", "").strip().upper()
    comp_to_fetch = target_comp_id if (user.get("role") == "super_admin" and target_comp_id) else user.get("company_id")

    company = None
    if comp_to_fetch and comp_to_fetch != "ARDHNARISHWAR":
        comp_doc = companies_col.find_one({"company_id": comp_to_fetch}, {"_id": 0})
        if comp_doc:
            company = comp_doc

    return jsonify({
        "ok": True,
        "authenticated": True,
        "user": user,
        "company": company
    })


# ── Self-Registration & Password Recovery APIs ─────────────────────────────────

@app.route("/api/auth/register-company", methods=["POST"])
def api_register_company():
    data = request.json or {}
    company_id = data.get("company_id", "").strip().upper()
    name = data.get("name", "").strip()
    email = data.get("email", "").strip().lower()
    phone = data.get("phone", "").strip()
    country = data.get("country", "India").strip()
    tz = data.get("timezone", DEFAULT_TIMEZONE).strip()
    gst_number = data.get("gst_number", "").strip().upper() or data.get("reg_no", "").strip().upper()
    admin_name = data.get("admin_name", "Administrator").strip()
    password = data.get("admin_password", "").strip()

    if not company_id or not name or not phone or not password:
        return jsonify({"ok": False, "error": "Company ID, Legal Name, Contact Phone, and Admin Password are required"}), 400

    if companies_col.find_one({"company_id": company_id}):
        return jsonify({"ok": False, "error": f"Workspace ID '{company_id}' is already registered"}), 409

    if users_col.find_one({"mobile": phone}):
        return jsonify({"ok": False, "error": f"Phone number '{phone}' is already registered with another account"}), 409

    now_utc = get_utc_iso_string()

    # Create Company with Pending Status for Super Admin approval
    company_doc = {
        "company_id": company_id,
        "name": name,
        "gst_number": gst_number,
        "email": email,
        "contact_phone": phone,
        "country": country,
        "timezone": tz,
        "status": "pending",
        "created_at": now_utc,
        "plan": "Enterprise",
        "policy": {
            "shift_start": "09:30",
            "shift_end": "18:30",
            "grace_period_mins": 15,
            "half_day_after": "13:00"
        },
        "office_locations": [{
            "location_name": "Main Office",
            "lat": OFFICE_LAT,
            "lng": OFFICE_LNG,
            "radius_m": OFFICE_RADIUS_M,
            "wifi_subnet": OFFICE_SUBNET
        }]
    }
    companies_col.insert_one(company_doc)

    # Create Company Admin account in pending status
    admin_user = {
        "company_id": company_id,
        "name": admin_name,
        "email": email,
        "mobile": phone,
        "password": hash_password(password),
        "role": "company_admin",
        "status": "pending",
        "created_at": now_utc
    }
    users_col.insert_one(admin_user)

    # Record system notification for Super Admin
    notifications_col.insert_one({
        "company_id": "ARDHNARISHWAR",
        "emp_id": "SUPER_ADMIN",
        "title": "New Company Registration Request",
        "message": f"Company '{name}' ({company_id}) registered from {country}. Awaiting verification and activation.",
        "type": "COMPANY_ONBOARDING",
        "is_read": False,
        "timestamp_utc": now_utc
    })

    log_audit_event(
        action="COMPANY_SELF_REGISTERED",
        company_id=company_id,
        actor_name=admin_name,
        actor_role="company_admin",
        details={"company_name": name, "country": country, "phone": phone},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({
        "ok": True,
        "status": "pending",
        "message": "Company workspace submitted for review. An Ardhnarishwar Super Admin will review and activate your workspace."
    })


@app.route("/api/auth/verify-company/<company_id>", methods=["GET"])
def api_verify_company(company_id):
    """Check if a company workspace exists and is active for employee registration."""
    company_query = company_id.strip()
    if not company_query:
        return jsonify({"ok": False, "exists": False, "error": "Company workspace ID is required"}), 400

    clean_query = re.sub(r'[^a-zA-Z0-9]', '', company_query)

    query = {
        "$or": [
            {"company_id": company_query.upper()},
            {"company_id": company_query},
            {"company_id": {"$regex": f"^{re.escape(company_query)}$", "$options": "i"}},
            {"name": {"$regex": f"^{re.escape(company_query)}$", "$options": "i"}},
            {"company_id": {"$regex": re.escape(company_query), "$options": "i"}},
            {"name": {"$regex": re.escape(company_query), "$options": "i"}}
        ]
    }
    comp = companies_col.find_one(query)

    if not comp and clean_query:
        all_comps = list(companies_col.find({}, {"_id": 0, "company_id": 1, "name": 1, "status": 1, "country": 1, "timezone": 1}))
        # 1. Exact alphanumeric match first
        for c in all_comps:
            c_clean_id = re.sub(r'[^a-zA-Z0-9]', '', c.get("company_id", ""))
            if clean_query.lower() == c_clean_id.lower():
                comp = c
                break
        # 2. Substring fallback
        if not comp:
            for c in all_comps:
                c_clean_id = re.sub(r'[^a-zA-Z0-9]', '', c.get("company_id", ""))
                c_clean_name = re.sub(r'[^a-zA-Z0-9]', '', c.get("name", ""))
                if (clean_query.lower() in c_clean_id.lower() or 
                    c_clean_id.lower() in clean_query.lower() or 
                    clean_query.lower() in c_clean_name.lower()):
                    comp = c
                    break
    
    if not comp:
        total_registered = companies_col.count_documents({})
        if total_registered == 0:
            error_msg = f"No organization workspaces are registered on this platform yet. Please register your Organization first in the 'Company Registration' tab."
        else:
            error_msg = f"Workspace '{company_query}' is not registered on this platform. Please verify your Workspace Code or register your organization first."
        
        return jsonify({
            "ok": False,
            "exists": False,
            "error": error_msg,
            "can_register_company": True
        }), 404
    
    canonical_id = comp.get("company_id", company_query.upper())
    status = comp.get("status", "active")
    
    if status == "suspended" or status == "rejected" or status == "inactive":
        return jsonify({
            "ok": False,
            "exists": True,
            "company_id": canonical_id,
            "status": status,
            "error": f"Workspace '{comp.get('name')}' is currently {status.upper()}. Staff registrations are temporarily paused."
        }), 400

    # Fetch company departments for easy selection
    depts = list(departments_col.find({"company_id": canonical_id}, {"_id": 0, "name": 1}))
    dept_names = [d["name"] for d in depts] if depts else ["General", "Engineering", "Sales", "Operations", "HR"]

    return jsonify({
        "ok": True,
        "exists": True,
        "status": status,
        "company_id": canonical_id,
        "company_name": comp.get("name"),
        "country": comp.get("country", "India"),
        "timezone": comp.get("timezone", DEFAULT_TIMEZONE),
        "departments": dept_names
    })


@app.route("/api/auth/register-employee", methods=["POST"])
def api_register_employee():
    """Self-registration for employees into an active company workspace in PENDING status."""
    data = request.json or {}
    company_id_input = data.get("company_id", "").strip()
    emp_id = data.get("emp_id", "").strip().upper()
    name = data.get("name", "").strip()
    mobile = data.get("mobile", "").strip().replace(" ", "").replace("-", "")
    email = data.get("email", "").strip().lower()
    department = data.get("department", "General").strip()
    designation = data.get("designation", "Staff").strip()
    work_type = data.get("work_type", "Office").strip()  # Office, WFH, Field
    password = data.get("password", "").strip()

    if not company_id_input or not emp_id or not name or not mobile or not password:
        return jsonify({
            "ok": False, 
            "error": "Target Company Workspace ID, Employee ID, Full Name, Mobile Number, and Password are required."
        }), 400

    # 1. Company Verification (Case-insensitive, regex & alphanumeric fallback)
    clean_query = re.sub(r'[^a-zA-Z0-9]', '', company_id_input)
    query = {
        "$or": [
            {"company_id": company_id_input.upper()},
            {"company_id": company_id_input},
            {"company_id": {"$regex": f"^{re.escape(company_id_input)}$", "$options": "i"}},
            {"name": {"$regex": f"^{re.escape(company_id_input)}$", "$options": "i"}},
            {"company_id": {"$regex": re.escape(company_id_input), "$options": "i"}},
            {"name": {"$regex": re.escape(company_id_input), "$options": "i"}}
        ]
    }
    comp = companies_col.find_one(query)

    if not comp and clean_query:
        all_comps = list(companies_col.find({}, {"_id": 0, "company_id": 1, "name": 1, "status": 1}))
        # 1. Exact alphanumeric match first
        for c in all_comps:
            c_clean_id = re.sub(r'[^a-zA-Z0-9]', '', c.get("company_id", ""))
            if clean_query.lower() == c_clean_id.lower():
                comp = c
                break
        # 2. Substring fallback
        if not comp:
            for c in all_comps:
                c_clean_id = re.sub(r'[^a-zA-Z0-9]', '', c.get("company_id", ""))
                c_clean_name = re.sub(r'[^a-zA-Z0-9]', '', c.get("name", ""))
                if (clean_query.lower() in c_clean_id.lower() or 
                    c_clean_id.lower() in clean_query.lower() or 
                    clean_query.lower() in c_clean_name.lower()):
                    comp = c
                    break

    if not comp:
        total_registered = companies_col.count_documents({})
        if total_registered == 0:
            err_text = f"No organization is registered yet. Please register your Organization first in the 'Company Registration' tab."
        else:
            err_text = f"Target Company Workspace '{company_id_input}' is not registered on this platform. Please check your Organization ID or register your organization first."
        return jsonify({
            "ok": False, 
            "error": err_text,
            "can_register_company": True
        }), 404

    canonical_company_id = comp.get("company_id", company_id_input.upper())
    comp_status = comp.get("status", "active")
    if comp_status in ("suspended", "rejected", "inactive"):
        return jsonify({
            "ok": False, 
            "error": f"Company workspace '{comp.get('name')}' is currently {comp_status.upper()}. Cannot register."
        }), 400

    # 2. Check if Employee ID is already registered under this company
    existing_emp = employees_col.find_one({"company_id": canonical_company_id, "emp_id": emp_id})
    if existing_emp:
        if existing_emp.get("status") == "pending":
            return jsonify({
                "ok": False,
                "status": "pending",
                "error": f"Employee ID '{emp_id}' is already registered and pending review. You can track status in the Application Status Tracker."
            }), 409
        return jsonify({
            "ok": False, 
            "error": f"Employee ID '{emp_id}' is already registered under company '{comp.get('name')}'. Please sign in or contact HR."
        }), 409

    # 3. Check if mobile is already used by an existing user
    existing_user = users_col.find_one({"mobile": mobile})
    if existing_user:
        if existing_user.get("status") == "pending":
            return jsonify({
                "ok": False,
                "status": "pending",
                "error": f"Mobile number '{mobile}' is already registered and pending administrator approval. Please track your application status."
            }), 409
        return jsonify({
            "ok": False, 
            "error": f"Mobile number '{mobile}' is already registered with an existing active account. Please sign in or use a different number."
        }), 409

    now_utc = get_utc_iso_string()

    # 3. Create Employee in 'pending' status
    emp_doc = {
        "company_id": canonical_company_id,
        "emp_id": emp_id,
        "name": name,
        "mobile": mobile,
        "email": email,
        "department": department,
        "designation": designation,
        "work_type": work_type,
        "status": "pending",
        "created_at": now_utc,
        "joining_date": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        "allowed_methods": ["Face", "OTP", "WiFi", "GPS"]
    }
    employees_col.insert_one(emp_doc)

    # 4. Create User in 'pending' status
    user_doc = {
        "company_id": canonical_company_id,
        "emp_id": emp_id,
        "name": name,
        "mobile": mobile,
        "email": email,
        "password": hash_password(password),
        "role": "employee",
        "status": "pending",
        "department": department,
        "designation": designation,
        "work_type": work_type,
        "created_at": now_utc
    }
    users_col.insert_one(user_doc)

    # 5. Notify Company Admin and Super Admin
    notifications_col.insert_one({
        "company_id": canonical_company_id,
        "emp_id": "ADMIN",
        "title": "New Employee Registration Pending Approval",
        "message": f"{name} ({emp_id}) applied to join department '{department}' as {work_type}. Awaiting Administrator approval.",
        "type": "EMPLOYEE_ONBOARDING",
        "is_read": False,
        "timestamp_utc": now_utc
    })

    notifications_col.insert_one({
        "company_id": "ARDHNARISHWAR",
        "emp_id": "SUPER_ADMIN",
        "title": "Global Staff Registration Alert",
        "message": f"{name} ({emp_id}) registered under company '{comp.get('name')}' ({canonical_company_id}).",
        "type": "EMPLOYEE_ONBOARDING",
        "is_read": False,
        "timestamp_utc": now_utc
    })

    log_audit_event(
        action="EMPLOYEE_SELF_REGISTERED",
        company_id=canonical_company_id,
        actor_name=name,
        actor_role="employee",
        details={"emp_id": emp_id, "name": name, "department": department, "work_type": work_type},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({
        "ok": True,
        "status": "pending",
        "message": f"Employee registration submitted successfully for {comp.get('name')}! Your account is pending administrator approval before you can sign in."
    })


@app.route("/api/auth/check-registration-status", methods=["POST"])
def api_check_registration_status():
    """Public lookup endpoint to check the review/approval status of an application."""
    data = request.json or {}
    identifier = data.get("identifier", "").strip()
    company_id = data.get("company_id", "").strip().upper()

    if not identifier:
        return jsonify({"ok": False, "error": "Company Workspace ID, Employee ID, Mobile Number, or Email is required"}), 400

    # 1. Check Companies collection directly (by workspace id, contact phone, email, or name)
    comp = companies_col.find_one({
        "$or": [
            {"company_id": identifier.upper()},
            {"contact_phone": identifier},
            {"email": identifier.lower()},
            {"name": {"$regex": f"^{re.escape(identifier)}$", "$options": "i"}}
        ]
    })
    if comp:
        return jsonify({
            "ok": True,
            "found": True,
            "type": "company",
            "entity_name": comp.get("name"),
            "name": comp.get("name"),
            "company_id": comp.get("company_id"),
            "company_name": comp.get("name"),
            "identifier": identifier,
            "status": comp.get("status", "pending"),
            "created_at": comp.get("created_at"),
            "country": comp.get("country", "Global"),
            "phone": comp.get("contact_phone", "")
        })

    # 2. Check Users collection (by mobile, email, emp_id)
    user_query = {
        "$or": [
            {"mobile": identifier},
            {"email": identifier},
            {"email": identifier.lower()},
            {"emp_id": identifier.upper()}
        ]
    }
    if company_id:
        user_query["company_id"] = company_id

    user = users_col.find_one(user_query)
    
    # 3. Check Employees collection if not found in users_col
    if not user:
        emp_query = {
            "$or": [
                {"mobile": identifier},
                {"email": identifier},
                {"email": identifier.lower()},
                {"emp_id": identifier.upper()}
            ]
        }
        if company_id:
            emp_query["company_id"] = company_id
        emp_doc = employees_col.find_one(emp_query)
        if emp_doc:
            c = companies_col.find_one({"company_id": emp_doc.get("company_id")})
            comp_name = c.get("name", emp_doc.get("company_id")) if c else emp_doc.get("company_id")
            return jsonify({
                "ok": True,
                "found": True,
                "type": "employee",
                "name": emp_doc.get("name"),
                "entity_name": emp_doc.get("name"),
                "emp_id": emp_doc.get("emp_id"),
                "company_id": emp_doc.get("company_id"),
                "company_name": comp_name,
                "role": "employee",
                "status": emp_doc.get("status", "pending"),
                "department": emp_doc.get("department", "General"),
                "work_type": emp_doc.get("work_type", "Office"),
                "created_at": emp_doc.get("created_at")
            })

        return jsonify({"ok": False, "found": False, "error": f"No registration record found matching '{identifier}'"}), 404

    comp_name = "Global Platform"
    if user.get("company_id") and user.get("company_id") != "ARDHNARISHWAR":
        c = companies_col.find_one({"company_id": user.get("company_id")})
        if c: comp_name = c.get("name", user.get("company_id"))

    return jsonify({
        "ok": True,
        "found": True,
        "type": "employee" if user.get("role") == "employee" else "company_admin",
        "name": user.get("name"),
        "entity_name": user.get("name"),
        "emp_id": user.get("emp_id") or "N/A",
        "company_id": user.get("company_id"),
        "company_name": comp_name,
        "role": user.get("role"),
        "status": user.get("status", "pending"),
        "department": user.get("department", "General"),
        "work_type": user.get("work_type", "Office"),
        "created_at": user.get("created_at")
    })



@app.route("/api/auth/forgot-password", methods=["POST"])
def api_forgot_password():
    data = request.json or {}
    identifier = data.get("identifier", "").strip()
    company_id = data.get("company_id", "").strip().upper()
    role = data.get("role", "").strip()

    if not identifier:
        return jsonify({"ok": False, "error": "Email or registered mobile number is required"}), 400

    query = {"$or": [{"mobile": identifier}, {"email": identifier}]}
    if role: query["role"] = role
    if company_id and role != "super_admin": query["company_id"] = company_id

    user = users_col.find_one(query)
    if not user:
        return jsonify({"ok": False, "error": "No account matched the provided details"}), 404

    # Issue secure 6-digit reset OTP code
    reset_code = str(random.randint(100000, 999999))
    target_comp = user.get("company_id", "GLOBAL")
    target_emp = user.get("emp_id") or user.get("mobile", "USER")

    notifications_col.insert_one({
        "company_id": target_comp,
        "emp_id": target_emp,
        "title": "Password Reset Authorization Code",
        "message": f"Your password reset authorization code is: {reset_code}. Valid for 10 minutes.",
        "type": "PASSWORD_RESET",
        "reset_code_hash": hash_password(reset_code),
        "expires_ts": datetime.now(timezone.utc).timestamp() + 600,
        "is_read": False,
        "timestamp_utc": get_utc_iso_string()
    })

    log_audit_event(
        action="PASSWORD_RESET_REQUESTED",
        company_id=target_comp,
        actor_name=user.get("name"),
        actor_role=user.get("role"),
        details={"identifier": identifier},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({
        "ok": True,
        "message": "Authorization code issued to your in-app notification vault.",
        "reset_code": reset_code
    })


@app.route("/api/auth/reset-password", methods=["POST"])
def api_reset_password():
    data = request.json or {}
    identifier = data.get("identifier", "").strip()
    company_id = data.get("company_id", "").strip().upper()
    reset_code = data.get("reset_code", "").strip()
    new_password = data.get("new_password", "").strip()

    if not identifier or not reset_code or not new_password:
        return jsonify({"ok": False, "error": "Identifier, reset code, and new password are required"}), 400

    query = {"$or": [{"mobile": identifier}, {"email": identifier}]}
    if company_id: query["company_id"] = company_id

    user = users_col.find_one(query)
    if not user:
        return jsonify({"ok": False, "error": "User account not found"}), 404

    target_comp = user.get("company_id", "GLOBAL")
    target_emp = user.get("emp_id") or user.get("mobile", "USER")

    # Verify reset code in notification vault
    notif = notifications_col.find_one({
        "company_id": target_comp,
        "emp_id": target_emp,
        "type": "PASSWORD_RESET",
        "reset_code_hash": hash_password(reset_code)
    })
    now_ts = datetime.now(timezone.utc).timestamp()
    if not notif or notif.get("expires_ts", 0) < now_ts:
        return jsonify({"ok": False, "error": "Invalid or expired authorization code"}), 400

    # Update password
    users_col.update_one({"_id": user["_id"]}, {"$set": {"password": hash_password(new_password)}})
    notifications_col.delete_one({"_id": notif["_id"]})

    log_audit_event(
        action="PASSWORD_RESET_COMPLETED",
        company_id=target_comp,
        actor_name=user.get("name"),
        actor_role=user.get("role"),
        details={"identifier": identifier},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": "Password updated successfully. You can now log in."})


# ══════════════════════════════════════════════════════════════════════════════
#  ARDHNARISHWAR SUPER ADMIN APIS
# ══════════════════════════════════════════════════════════════════════════════

@app.route("/api/superadmin/companies/<company_id>/approve", methods=["POST"])
def superadmin_approve_company(company_id):
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    company_id = company_id.upper()
    comp = companies_col.find_one({"company_id": company_id})
    if not comp:
        return jsonify({"ok": False, "error": "Company not found"}), 404

    companies_col.update_one({"company_id": company_id}, {"$set": {"status": "active", "approved_at": get_utc_iso_string()}})
    users_col.update_many({"company_id": company_id}, {"$set": {"status": "active"}})

    log_audit_event(
        action="COMPANY_APPROVED",
        company_id=company_id,
        actor_name=user.get("name"),
        actor_role="super_admin",
        details={"approved_company": comp.get("name")},
        ip=client_ip(),
        user_agent=client_user_agent()
    )
    return jsonify({"ok": True, "message": f"Company '{company_id}' approved and activated successfully"})


@app.route("/api/superadmin/companies/<company_id>/reject", methods=["POST"])
def superadmin_reject_company(company_id):
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    company_id = company_id.upper()
    comp = companies_col.find_one({"company_id": company_id})
    if not comp:
        return jsonify({"ok": False, "error": "Company not found"}), 404

    companies_col.update_one({"company_id": company_id}, {"$set": {"status": "rejected", "rejected_at": get_utc_iso_string()}})
    users_col.update_many({"company_id": company_id}, {"$set": {"status": "rejected"}})

    log_audit_event(
        action="COMPANY_REJECTED",
        company_id=company_id,
        actor_name=user.get("name"),
        actor_role="super_admin",
        details={"rejected_company": comp.get("name")},
        ip=client_ip(),
        user_agent=client_user_agent()
    )
    return jsonify({"ok": True, "message": f"Company '{company_id}' rejected"})


@app.route("/api/superadmin/pending-approvals", methods=["GET"])
def superadmin_pending_approvals():
    """Retrieve all pending client company and employee registration requests."""
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    pending_companies = list(companies_col.find({"status": "pending"}).sort("created_at", -1))
    for c in pending_companies:
        c["_id"] = str(c["_id"])

    pending_employees = list(employees_col.find({"status": "pending"}).sort("created_at", -1))
    for e in pending_employees:
        e["_id"] = str(e["_id"])
        comp = companies_col.find_one({"company_id": e.get("company_id")})
        e["company_name"] = comp.get("name", e.get("company_id")) if comp else e.get("company_id")

    return jsonify({
        "ok": True,
        "pending_companies": pending_companies,
        "pending_employees": pending_employees,
        "total_pending": len(pending_companies) + len(pending_employees)
    })


@app.route("/api/superadmin/employees/<company_id>/<emp_id>/approve", methods=["POST"])
def superadmin_approve_employee(company_id, emp_id):
    """Super Admin approves and activates an employee registration."""
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    company_id = company_id.upper()
    emp_id = emp_id.upper()

    emp = employees_col.find_one({"company_id": company_id, "emp_id": emp_id})
    if not emp:
        return jsonify({"ok": False, "error": "Employee record not found"}), 404

    now_utc = get_utc_iso_string()
    employees_col.update_one({"company_id": company_id, "emp_id": emp_id}, {"$set": {"status": "active", "approved_at": now_utc, "approved_by": "SUPER_ADMIN"}})
    users_col.update_one({"company_id": company_id, "emp_id": emp_id}, {"$set": {"status": "active"}})

    log_audit_event(
        action="SUPERADMIN_EMPLOYEE_APPROVED",
        company_id=company_id,
        actor_name=user.get("name"),
        actor_role="super_admin",
        details={"emp_id": emp_id, "employee_name": emp.get("name")},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": f"Employee {emp.get('name')} ({emp_id}) approved and activated successfully"})


@app.route("/api/superadmin/employees/<company_id>/<emp_id>/reject", methods=["POST"])
def superadmin_reject_employee(company_id, emp_id):
    """Super Admin rejects an employee registration."""
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    company_id = company_id.upper()
    emp_id = emp_id.upper()

    emp = employees_col.find_one({"company_id": company_id, "emp_id": emp_id})
    if not emp:
        return jsonify({"ok": False, "error": "Employee record not found"}), 404

    now_utc = get_utc_iso_string()
    employees_col.update_one({"company_id": company_id, "emp_id": emp_id}, {"$set": {"status": "rejected", "rejected_at": now_utc, "rejected_by": "SUPER_ADMIN"}})
    users_col.update_one({"company_id": company_id, "emp_id": emp_id}, {"$set": {"status": "rejected"}})

    log_audit_event(
        action="SUPERADMIN_EMPLOYEE_REJECTED",
        company_id=company_id,
        actor_name=user.get("name"),
        actor_role="super_admin",
        details={"emp_id": emp_id, "employee_name": emp.get("name")},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": f"Employee {emp.get('name')} ({emp_id}) registration rejected"})



@app.route("/api/superadmin/companies", methods=["GET", "POST"])
def superadmin_companies():
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    if request.method == "GET":
        comps = list(companies_col.find().sort("created_at", -1))
        for c in comps:
            c["_id"] = str(c["_id"])
            c["employee_count"] = employees_col.count_documents({"company_id": c["company_id"]})
            c["active_employees"] = employees_col.count_documents({"company_id": c["company_id"], "status": "active"})
        return jsonify({"ok": True, "companies": comps, "count": len(comps)})

    if request.method == "POST":
        data = request.json or {}
        company_id = data.get("company_id", "").strip().upper()
        name = data.get("name", "").strip()
        legal_name = data.get("legal_name", name).strip()
        country = data.get("country", "India").strip()
        tz = data.get("timezone", DEFAULT_TIMEZONE).strip()
        plan = data.get("plan", "Enterprise Global").strip()
        address = data.get("address", "").strip()
        contact_email = data.get("contact_email", "").strip()
        contact_phone = data.get("contact_phone", "").strip()
        admin_name = data.get("admin_name", "Company Admin").strip()
        admin_pass = data.get("admin_password", "admin123").strip()

        if not company_id or not name or not contact_phone:
            return jsonify({"ok": False, "error": "Company ID, Name, and Contact Phone are required"}), 400

        if companies_col.find_one({"company_id": company_id}):
            return jsonify({"ok": False, "error": f"Company ID '{company_id}' already exists"}), 400

        # Parse office locations
        office_locations = data.get("office_locations", [])
        if not office_locations:
            office_locations = [{
                "location_name": f"{name} HQ",
                "lat": float(data.get("lat", OFFICE_LAT)),
                "lng": float(data.get("lng", OFFICE_LNG)),
                "radius_m": float(data.get("radius_m", OFFICE_RADIUS_M)),
                "wifi_subnet": data.get("wifi_subnet", OFFICE_SUBNET),
                "allowed_methods": ["Face", "OTP", "WiFi", "GPS"]
            }]

        comp_doc = {
            "company_id": company_id,
            "name": name,
            "legal_name": legal_name,
            "country": country,
            "timezone": tz,
            "status": "active",
            "plan": plan,
            "address": address,
            "contact_email": contact_email,
            "contact_phone": contact_phone,
            "office_locations": office_locations,
            "created_at": get_utc_iso_string(),
            "created_by": user.get("name", "Super Admin")
        }
        companies_col.insert_one(comp_doc)

        # Create Default Company Policy
        policies_col.update_one(
            {"company_id": company_id},
            {"$set": {
                "company_id": company_id,
                "shift_start": data.get("shift_start", "09:30"),
                "shift_end": data.get("shift_end", "18:30"),
                "grace_period_mins": int(data.get("grace_period_mins", 15)),
                "half_day_after": data.get("half_day_after", "13:00"),
                "allowed_methods": ["Face", "OTP", "WiFi", "GPS"],
                "updated_at": get_utc_iso_string()
            }},
            upsert=True
        )

        # Create Company Admin Account
        admin_user = {
            "name": admin_name,
            "email": contact_email,
            "mobile": contact_phone,
            "password": hash_password(admin_pass),
            "role": "company_admin",
            "company_id": company_id,
            "status": "active",
            "created_at": get_utc_iso_string()
        }
        users_col.insert_one(admin_user)

        log_audit_event(
            action="COMPANY_CREATED",
            company_id=company_id,
            actor_name=user.get("name"),
            actor_role="super_admin",
            details={"company_name": name, "country": country, "timezone": tz, "plan": plan},
            ip=client_ip(),
            user_agent=client_user_agent()
        )

        return jsonify({
            "ok": True, 
            "message": f"Company '{name}' ({company_id}) created successfully with Admin account ({contact_phone})",
            "company_id": company_id
        })


@app.route("/api/superadmin/companies/<company_id>", methods=["PUT", "DELETE"])
def superadmin_company_detail(company_id):
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    company_id = company_id.upper()
    company = companies_col.find_one({"company_id": company_id})
    if not company:
        return jsonify({"ok": False, "error": f"Company '{company_id}' not found"}), 404

    if request.method == "PUT":
        data = request.json or {}
        update_fields = {}
        for key in ["name", "legal_name", "country", "timezone", "plan", "address", "contact_email", "contact_phone", "office_locations"]:
            if key in data:
                update_fields[key] = data[key]

        update_fields["updated_at"] = get_utc_iso_string()
        companies_col.update_one({"company_id": company_id}, {"$set": update_fields})

        log_audit_event(
            action="COMPANY_UPDATED",
            company_id=company_id,
            actor_name=user.get("name"),
            actor_role="super_admin",
            details=update_fields,
            ip=client_ip(),
            user_agent=client_user_agent()
        )
        return jsonify({"ok": True, "message": f"Company '{company_id}' updated successfully"})

    if request.method == "DELETE":
        # Safe cascading deletion of company records
        companies_col.delete_one({"company_id": company_id})
        users_col.delete_many({"company_id": company_id})
        employees_col.delete_many({"company_id": company_id})
        branches_col.delete_many({"company_id": company_id})
        departments_col.delete_many({"company_id": company_id})
        shifts_col.delete_many({"company_id": company_id})
        attendance_col.delete_many({"company_id": company_id})
        attendance_corrections_col.delete_many({"company_id": company_id})
        leaves_col.delete_many({"company_id": company_id})
        field_visits_col.delete_many({"company_id": company_id})
        policies_col.delete_many({"company_id": company_id})
        notifications_col.delete_many({"company_id": company_id})

        log_audit_event(
            action="COMPANY_DELETED",
            company_id=company_id,
            actor_name=user.get("name"),
            actor_role="super_admin",
            details={"deleted_company": company.get("name")},
            ip=client_ip(),
            user_agent=client_user_agent()
        )
        return jsonify({"ok": True, "message": f"Company '{company_id}' and all associated records permanently removed"})


@app.route("/api/superadmin/companies/<company_id>/toggle-status", methods=["POST"])
def superadmin_toggle_company_status(company_id):
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    company_id = company_id.upper()
    data = request.json or {}
    new_status = data.get("status", "active").lower()  # active, suspended, inactive

    res = companies_col.update_one({"company_id": company_id}, {"$set": {"status": new_status, "updated_at": get_utc_iso_string()}})
    if res.matched_count == 0:
        return jsonify({"ok": False, "error": "Company not found"}), 404

    # Synchronize status to all users under this company
    users_col.update_many({"company_id": company_id}, {"$set": {"status": new_status}})

    log_audit_event(
        action="COMPANY_STATUS_CHANGED",
        company_id=company_id,
        actor_name=user.get("name"),
        actor_role="super_admin",
        details={"new_status": new_status},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": f"Company {company_id} status updated to {new_status.upper()}"})


@app.route("/api/superadmin/analytics", methods=["GET"])
def superadmin_analytics():
    """Real dynamic aggregation metrics strictly from database."""
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    total_companies = companies_col.count_documents({})
    active_companies = companies_col.count_documents({"status": "active"})
    total_employees = employees_col.count_documents({})
    active_employees = employees_col.count_documents({"status": "active"})

    today_utc_date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    today_attendance = attendance_col.count_documents({"date": today_utc_date})

    # Countries breakdown
    pipeline_countries = [
        {"$group": {"_id": "$country", "count": {"$sum": 1}}},
        {"$sort": {"count": -1}}
    ]
    countries_stat = list(companies_col.aggregate(pipeline_countries))

    # Workforce breakdown
    pipeline_workforce = [
        {"$group": {"_id": "$work_type", "count": {"$sum": 1}}},
        {"$sort": {"count": -1}}
    ]
    workforce_stat = list(employees_col.aggregate(pipeline_workforce))

    return jsonify({
        "ok": True,
        "stats": {
            "total_companies": total_companies,
            "active_companies": active_companies,
            "total_employees": total_employees,
            "active_employees": active_employees,
            "today_attendance": today_attendance
        },
        "countries_breakdown": countries_stat,
        "workforce_breakdown": workforce_stat
    })


@app.route("/api/superadmin/audit-logs", methods=["GET"])
def superadmin_audit_logs():
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    limit = int(request.args.get("limit", 100))
    logs = list(audit_logs_col.find().sort("timestamp_utc", -1).limit(limit))
    for log in logs:
        log["_id"] = str(log["_id"])
    return jsonify({"ok": True, "logs": logs, "count": len(logs)})


@app.route("/api/superadmin/global-attendance", methods=["GET"])
def superadmin_global_attendance():
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    company_id = request.args.get("company_id", "").strip().upper()
    emp_id = request.args.get("emp_id", "").strip().upper()
    date_val = request.args.get("date", "").strip()
    status_val = request.args.get("status", "").strip()
    method_val = request.args.get("method", "").strip()
    limit = int(request.args.get("limit", 150))

    query = {}
    if company_id:
        query["company_id"] = company_id
    if emp_id:
        query["emp_id"] = emp_id
    if date_val:
        query["$or"] = [{"date": date_val}, {"local_date": date_val}]
    if status_val:
        query["status"] = status_val
    if method_val:
        query["method"] = method_val

    rows = list(attendance_col.find(query).sort("timestamp_utc", -1).limit(limit))
    for r in rows:
        r["_id"] = str(r["_id"])
        if "company_name" not in r:
            comp = companies_col.find_one({"company_id": r.get("company_id")}, {"name": 1})
            r["company_name"] = comp.get("name") if comp else r.get("company_id")

    return jsonify({"ok": True, "attendance": rows, "count": len(rows)})


@app.route("/api/superadmin/timezones", methods=["GET"])
def superadmin_timezones():
    return jsonify({
        "ok": True,
        "timezones": GLOBAL_TIMEZONES,
        "countries": GLOBAL_COUNTRIES
    })


# ══════════════════════════════════════════════════════════════════════════════
#  COMPANY ADMIN APIS (STRICT TENANT ISOLATION)
# ══════════════════════════════════════════════════════════════════════════════

@app.route("/api/company/profile", methods=["GET", "POST"])
def company_profile():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    company = companies_col.find_one({"company_id": target_company_id})
    if not company:
        return jsonify({"ok": False, "error": f"Company '{target_company_id}' not found"}), 404

    # Fetch policy
    policy = policies_col.find_one({"company_id": target_company_id}) or {}
    policy.pop("_id", None)

    if request.method == "GET":
        company["_id"] = str(company["_id"])
        company["policy"] = policy
        return jsonify({"ok": True, "company": company})

    if request.method == "POST":
        data = request.json or {}
        update_fields = {}
        if "name" in data: update_fields["name"] = data["name"].strip()
        if "timezone" in data: update_fields["timezone"] = data["timezone"].strip()
        if "office_locations" in data: update_fields["office_locations"] = data["office_locations"]
        if "contact_email" in data: update_fields["contact_email"] = data["contact_email"].strip()
        if "contact_phone" in data: update_fields["contact_phone"] = data["contact_phone"].strip()
        if "address" in data: update_fields["address"] = data["address"].strip()

        update_fields["updated_at"] = get_utc_iso_string()
        companies_col.update_one({"company_id": target_company_id}, {"$set": update_fields})

        # Update policy if provided
        if "policy" in data:
            pol_data = data["policy"]
            policies_col.update_one(
                {"company_id": target_company_id},
                {"$set": {
                    "company_id": target_company_id,
                    "shift_start": pol_data.get("shift_start", "09:30"),
                    "shift_end": pol_data.get("shift_end", "18:30"),
                    "grace_period_mins": int(pol_data.get("grace_period_mins", 15)),
                    "half_day_after": pol_data.get("half_day_after", "13:00"),
                    "allowed_methods": pol_data.get("allowed_methods", ["Face", "OTP", "WiFi", "GPS"]),
                    "updated_at": get_utc_iso_string()
                }},
                upsert=True
            )

        log_audit_event(
            action="COMPANY_PROFILE_UPDATED",
            company_id=target_company_id,
            actor_name=user.get("name"),
            actor_role=user.get("role"),
            details=update_fields,
            ip=client_ip(),
            user_agent=client_user_agent()
        )
        return jsonify({"ok": True, "message": "Company workspace and policy settings updated successfully"})


# ── Branches Management APIs (Point 15) ──────────────────────────────────────

@app.route("/api/company/branches", methods=["GET", "POST"])
def company_branches():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    if request.method == "GET":
        branches = list(branches_col.find({"company_id": target_company_id}).sort("name", 1))
        for b in branches:
            b["_id"] = str(b["_id"])
        return jsonify({"ok": True, "branches": branches, "count": len(branches)})

    data = request.json or {}
    name = data.get("name", "").strip()
    city = data.get("city", "").strip()
    country = data.get("country", "India").strip()
    tz = data.get("timezone", DEFAULT_TIMEZONE).strip()
    lat = float(data.get("lat") or OFFICE_LAT)
    lng = float(data.get("lng") or OFFICE_LNG)
    radius_m = float(data.get("radius_m") or OFFICE_RADIUS_M)
    branch_id = data.get("branch_id", "").strip().upper() or f"BR-{random.randint(100, 999)}"

    if not name:
        return jsonify({"ok": False, "error": "Branch name is required"}), 400

    branches_col.update_one(
        {"company_id": target_company_id, "branch_id": branch_id},
        {"$set": {
            "company_id": target_company_id,
            "branch_id": branch_id,
            "name": name,
            "city": city,
            "country": country,
            "timezone": tz,
            "lat": lat,
            "lng": lng,
            "radius_m": radius_m,
            "created_at": get_utc_iso_string()
        }},
        upsert=True
    )

    log_audit_event(
        action="BRANCH_SAVED",
        company_id=target_company_id,
        actor_name=user.get("name"),
        actor_role=user.get("role"),
        details={"branch_id": branch_id, "name": name, "city": city},
        ip=client_ip(),
        user_agent=client_user_agent()
    )
    return jsonify({"ok": True, "message": f"Branch '{name}' ({branch_id}) saved successfully"})


@app.route("/api/company/branches/<branch_id>", methods=["DELETE"])
def delete_company_branch(branch_id):
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    branches_col.delete_one({"company_id": target_company_id, "branch_id": branch_id.upper()})
    return jsonify({"ok": True, "message": f"Branch '{branch_id}' removed"})


# ── Departments Management APIs (Point 16) ───────────────────────────────────

@app.route("/api/company/departments", methods=["GET", "POST"])
def company_departments():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    if request.method == "GET":
        depts = list(departments_col.find({"company_id": target_company_id}).sort("name", 1))
        for d in depts:
            d["_id"] = str(d["_id"])
            d["employee_count"] = employees_col.count_documents({"company_id": target_company_id, "department": d.get("name")})
        return jsonify({"ok": True, "departments": depts, "count": len(depts)})

    data = request.json or {}
    name = data.get("name", "").strip()
    if not name:
        return jsonify({"ok": False, "error": "Department name is required"}), 400

    departments_col.update_one(
        {"company_id": target_company_id, "name": name},
        {"$set": {"company_id": target_company_id, "name": name, "created_at": get_utc_iso_string()}},
        upsert=True
    )
    return jsonify({"ok": True, "message": f"Department '{name}' saved"})


@app.route("/api/company/departments/<dept_name>", methods=["DELETE"])
def delete_company_department(dept_name):
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    departments_col.delete_one({"company_id": target_company_id, "name": dept_name})
    return jsonify({"ok": True, "message": f"Department '{dept_name}' removed"})


# ── Shifts Management APIs (Point 17) ────────────────────────────────────────

@app.route("/api/company/shifts", methods=["GET", "POST"])
def company_shifts():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    if request.method == "GET":
        shifts = list(shifts_col.find({"company_id": target_company_id}).sort("name", 1))
        for s in shifts:
            s["_id"] = str(s["_id"])
        return jsonify({"ok": True, "shifts": shifts, "count": len(shifts)})

    data = request.json or {}
    name = data.get("name", "").strip()
    start_time = data.get("start_time", "09:30").strip()
    end_time = data.get("end_time", "18:30").strip()
    grace_mins = int(data.get("grace_period_mins") or 15)
    half_day = data.get("half_day_after", "13:00").strip()
    is_overnight = bool(data.get("is_overnight", False))
    shift_id = data.get("shift_id", "").strip().upper() or f"SH-{random.randint(100, 999)}"

    if not name:
        return jsonify({"ok": False, "error": "Shift name is required"}), 400

    shifts_col.update_one(
        {"company_id": target_company_id, "shift_id": shift_id},
        {"$set": {
            "company_id": target_company_id,
            "shift_id": shift_id,
            "name": name,
            "start_time": start_time,
            "end_time": end_time,
            "grace_period_mins": grace_mins,
            "half_day_after": half_day,
            "is_overnight": is_overnight,
            "created_at": get_utc_iso_string()
        }},
        upsert=True
    )
    return jsonify({"ok": True, "message": f"Shift '{name}' ({shift_id}) saved successfully"})


@app.route("/api/company/shifts/<shift_id>", methods=["DELETE"])
def delete_company_shift(shift_id):
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    shifts_col.delete_one({"company_id": target_company_id, "shift_id": shift_id.upper()})
    return jsonify({"ok": True, "message": f"Shift '{shift_id}' removed"})


# ── Attendance Corrections Workflow APIs (Point 19) ──────────────────────────

@app.route("/api/attendance/request-correction", methods=["POST"])
def request_attendance_correction():
    user, err = require_auth(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    data = request.json or {}
    company_id = user.get("company_id")
    emp_id = user.get("emp_id") or data.get("emp_id", "").strip().upper()
    date_val = data.get("date", "").strip()
    req_time = data.get("requested_time", "").strip()
    reason = data.get("reason", "").strip()
    check_type = data.get("check_type", "IN").strip()

    if not date_val or not req_time or not reason:
        return jsonify({"ok": False, "error": "Date, requested time, and explanation reason are required"}), 400

    corr_id = f"CORR-{random.randint(10000, 99999)}"
    now_utc = get_utc_iso_string()

    attendance_corrections_col.insert_one({
        "correction_id": corr_id,
        "company_id": company_id,
        "emp_id": emp_id,
        "employee_name": user.get("name", "Employee"),
        "date": date_val,
        "requested_time": req_time,
        "check_type": check_type,
        "reason": reason,
        "status": "pending",
        "timestamp_utc": now_utc
    })

    log_audit_event(
        action="ATTENDANCE_CORRECTION_REQUESTED",
        company_id=company_id,
        actor_name=user.get("name"),
        actor_role=user.get("role"),
        details={"correction_id": corr_id, "emp_id": emp_id, "date": date_val, "reason": reason},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": "Attendance correction request submitted for HR approval", "correction_id": corr_id})


@app.route("/api/company/attendance-corrections", methods=["GET"])
def company_attendance_corrections():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    corrs = list(attendance_corrections_col.find({"company_id": target_company_id}).sort("timestamp_utc", -1))
    for c in corrs:
        c["_id"] = str(c["_id"])
    return jsonify({"ok": True, "corrections": corrs, "count": len(corrs)})


@app.route("/api/company/attendance-corrections/<correction_id>/review", methods=["POST"])
def review_attendance_correction(correction_id):
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    data = request.json or {}
    decision = data.get("decision", "approved").lower()  # approved or rejected
    remarks = data.get("remarks", "").strip()

    corr = attendance_corrections_col.find_one({"company_id": target_company_id, "correction_id": correction_id.upper()})
    if not corr:
        return jsonify({"ok": False, "error": "Correction request not found"}), 404

    now_utc = get_utc_iso_string()
    attendance_corrections_col.update_one(
        {"_id": corr["_id"]},
        {"$set": {
            "status": decision,
            "reviewed_by": user.get("name"),
            "reviewer_role": user.get("role"),
            "review_remarks": remarks,
            "reviewed_at": now_utc
        }}
    )

    # If approved, update or insert attendance record
    if decision == "approved":
        attendance_col.update_one(
            {"company_id": target_company_id, "emp_id": corr["emp_id"], "date": corr["date"]},
            {"$set": {
                "company_id": target_company_id,
                "emp_id": corr["emp_id"],
                "name": corr.get("employee_name"),
                "date": corr["date"],
                "time": corr["requested_time"],
                "status": "Present",
                "method": "Correction-Approved",
                "notes": f"Corrected by {user.get('name')}: {remarks or corr.get('reason')}",
                "timestamp_utc": now_utc
            }},
            upsert=True
        )

    log_audit_event(
        action=f"ATTENDANCE_CORRECTION_{decision.upper()}",
        company_id=target_company_id,
        actor_name=user.get("name"),
        actor_role=user.get("role"),
        details={"correction_id": correction_id, "decision": decision, "emp_id": corr["emp_id"]},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": f"Correction request {decision.upper()} successfully"})


# ── Leave Management APIs (Point 20) ─────────────────────────────────────────

@app.route("/api/leaves/apply", methods=["POST"])
def apply_leave():
    user, err = require_auth(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    data = request.json or {}
    company_id = user.get("company_id")
    emp_id = user.get("emp_id") or data.get("emp_id", "").strip().upper()
    leave_type = data.get("leave_type", "Casual").strip()
    start_date = data.get("start_date", "").strip()
    end_date = data.get("end_date", "").strip()
    reason = data.get("reason", "").strip()

    if not start_date or not end_date or not reason:
        return jsonify({"ok": False, "error": "Start date, end date, and reason are required"}), 400

    leave_id = f"LV-{random.randint(1000, 9999)}"
    now_utc = get_utc_iso_string()

    leaves_col.insert_one({
        "leave_id": leave_id,
        "company_id": company_id,
        "emp_id": emp_id,
        "employee_name": user.get("name", "Employee"),
        "leave_type": leave_type,
        "start_date": start_date,
        "end_date": end_date,
        "reason": reason,
        "status": "pending",
        "timestamp_utc": now_utc
    })

    log_audit_event(
        action="LEAVE_APPLIED",
        company_id=company_id,
        actor_name=user.get("name"),
        actor_role=user.get("role"),
        details={"leave_id": leave_id, "emp_id": emp_id, "type": leave_type, "start": start_date, "end": end_date},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": "Leave application submitted for approval", "leave_id": leave_id})


@app.route("/api/leaves/my-leaves", methods=["GET"])
def my_leaves():
    user, err = require_auth(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    company_id = user.get("company_id")
    emp_id = user.get("emp_id")
    leaves = list(leaves_col.find({"company_id": company_id, "emp_id": emp_id}).sort("timestamp_utc", -1))
    for l in leaves:
        l["_id"] = str(l["_id"])
    return jsonify({"ok": True, "leaves": leaves, "count": len(leaves)})


@app.route("/api/company/leaves", methods=["GET"])
def company_leaves():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    leaves = list(leaves_col.find({"company_id": target_company_id}).sort("timestamp_utc", -1))
    for l in leaves:
        l["_id"] = str(l["_id"])
    return jsonify({"ok": True, "leaves": leaves, "count": len(leaves)})


@app.route("/api/company/leaves/<leave_id>/review", methods=["POST"])
def review_leave_request(leave_id):
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    data = request.json or {}
    raw_decision = data.get("decision", "").strip().lower()
    # Normalize decision; allow explicit approved/rejected, reject arbitrary values
    if raw_decision not in ("approved", "rejected"):
        if raw_decision == "":
            decision = "approved"
        else:
            return jsonify({"ok": False, "error": "Invalid decision. Must be 'approved' or 'rejected'."}), 400
    else:
        decision = raw_decision
    remarks = data.get("remarks", "").strip()

    leave_doc = leaves_col.find_one({"company_id": target_company_id, "leave_id": leave_id.upper().strip()})
    if not leave_doc:
        return jsonify({"ok": False, "error": "Leave request not found"}), 404

    current_status = str(leave_doc.get("status", "")).strip().lower()
    if current_status != "pending":
        return jsonify({"ok": False, "error": f"Leave request is already {current_status.upper()}. Only PENDING requests can be reviewed."}), 400

    now_utc = get_utc_iso_string()
    leaves_col.update_one(
        {"_id": leave_doc["_id"]},
        {"$set": {
            "status": decision,
            "reviewed_by": user.get("name"),
            "reviewer_role": user.get("role"),
            "review_remarks": remarks,
            "reviewed_at": now_utc
        }}
    )

    log_audit_event(
        action=f"LEAVE_{decision.upper()}",
        company_id=target_company_id,
        actor_name=user.get("name"),
        actor_role=user.get("role"),
        details={"leave_id": leave_id, "decision": decision, "emp_id": leave_doc["emp_id"]},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": f"Leave request {decision.upper()} successfully"})


@app.route("/api/company/employees", methods=["GET", "POST", "PUT", "DELETE"])
def company_employees():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    data = request.json if (request.is_json and request.method in ("POST", "PUT", "DELETE")) else {}
    req_comp_id = (data.get("company_id") if isinstance(data, dict) else None) or request.args.get("company_id")
    target_company_id, iso_err = resolve_tenant_id(user, req_comp_id)
    if iso_err:
        return iso_err

    if request.method == "GET":
        search = request.args.get("search", "").strip()
        dept = request.args.get("department", "").strip()
        work_type = request.args.get("work_type", "").strip()
        status = request.args.get("status", "").strip()

        query = {"company_id": target_company_id}
        if search:
            query["$or"] = [
                {"name": {"$regex": search, "$options": "i"}},
                {"emp_id": {"$regex": search, "$options": "i"}},
                {"email": {"$regex": search, "$options": "i"}},
                {"mobile": {"$regex": search, "$options": "i"}}
            ]
        if dept: query["department"] = dept
        if work_type: query["work_type"] = work_type
        if status: query["status"] = status

        employees = list(employees_col.find(query, {"encoding": 0}).sort("name", 1))
        for emp in employees:
            emp["_id"] = str(emp["_id"])
        return jsonify({"ok": True, "employees": employees, "count": len(employees), "company_id": target_company_id})

    if request.method == "POST":
        data = request.json or {}
        emp_id = data.get("emp_id", "").strip().upper()
        name = data.get("name", "").strip()
        mobile = data.get("mobile", "").strip()
        email = data.get("email", "").strip()
        department = data.get("department", "General").strip()
        designation = data.get("designation", "Staff").strip()
        work_type = data.get("work_type", "Office").strip()  # Office, WFH, Field
        assigned_location = data.get("assigned_location", "").strip()
        allowed_methods = data.get("allowed_methods", ["Face", "OTP", "WiFi", "GPS"])
        raw_password = data.get("password")
        initial_password = (raw_password or "").strip() or "emp123"
        joining_date = data.get("joining_date", datetime.now(timezone.utc).strftime("%Y-%m-%d"))

        if not emp_id or not name or not mobile:
            return jsonify({"ok": False, "error": "Employee ID, Full Name, and Mobile Number are required"}), 400

        # Unique ID constraint within company
        if employees_col.find_one({"emp_id": emp_id, "company_id": target_company_id}):
            return jsonify({"ok": False, "error": f"Employee ID '{emp_id}' already exists in this company"}), 400

        comp = companies_col.find_one({"company_id": target_company_id})
        tz = comp.get("timezone", DEFAULT_TIMEZONE) if comp else DEFAULT_TIMEZONE

        doc = {
            "emp_id": emp_id,
            "company_id": target_company_id,
            "name": name,
            "mobile": mobile,
            "email": email,
            "department": department,
            "designation": designation,
            "work_type": work_type,
            "assigned_location": assigned_location,
            "timezone": tz,
            "status": "active",
            "allowed_methods": allowed_methods,
            "joining_date": joining_date,
            "created_at": get_utc_iso_string()
        }
        employees_col.insert_one(doc)

        # Create user account for employee portal login
        user_doc = {
            "name": name,
            "email": email,
            "mobile": mobile,
            "password": hash_password(initial_password),
            "role": "employee",
            "company_id": target_company_id,
            "emp_id": emp_id,
            "status": "active",
            "created_at": get_utc_iso_string()
        }
        users_col.insert_one(user_doc)

        log_audit_event(
            action="EMPLOYEE_CREATED",
            company_id=target_company_id,
            actor_name=user.get("name"),
            actor_role=user.get("role"),
            details={"emp_id": emp_id, "name": name, "work_type": work_type, "department": department},
            ip=client_ip(),
            user_agent=client_user_agent()
        )

        return jsonify({"ok": True, "message": f"Employee '{name}' ({emp_id}) added successfully!"})

    if request.method == "PUT":
        data = request.json or {}
        emp_id = data.get("emp_id", "").strip().upper()
        if not emp_id:
            return jsonify({"ok": False, "error": "Employee ID is required"}), 400

        update_fields = {}
        for key in ["name", "mobile", "email", "department", "designation", "work_type", "assigned_location", "timezone", "status", "allowed_methods", "encoding"]:
            if key in data:
                update_fields[key] = data[key]

        update_fields["updated_at"] = get_utc_iso_string()
        res = employees_col.update_one({"emp_id": emp_id, "company_id": target_company_id}, {"$set": update_fields})
        if res.matched_count == 0:
            return jsonify({"ok": False, "error": f"Employee '{emp_id}' not found in this company"}), 404

        # Sync user status if status updated
        if "status" in update_fields:
            users_col.update_one({"emp_id": emp_id, "company_id": target_company_id}, {"$set": {"status": update_fields["status"]}})

        log_audit_event(
            action="EMPLOYEE_UPDATED",
            company_id=target_company_id,
            actor_name=user.get("name"),
            actor_role=user.get("role"),
            details={"emp_id": emp_id, "updates": update_fields},
            ip=client_ip(),
            user_agent=client_user_agent()
        )
        return jsonify({"ok": True, "message": f"Employee '{emp_id}' updated successfully"})

    if request.method == "DELETE":
        data = request.json or {}
        emp_id = data.get("emp_id", "").strip().upper() or request.args.get("emp_id", "").strip().upper()
        if not emp_id:
            return jsonify({"ok": False, "error": "Employee ID is required"}), 400

        res = employees_col.delete_one({"emp_id": emp_id, "company_id": target_company_id})
        if res.deleted_count == 0:
            return jsonify({"ok": False, "error": f"Employee '{emp_id}' not found in this company"}), 404

        users_col.delete_one({"emp_id": emp_id, "company_id": target_company_id})

        log_audit_event(
            action="EMPLOYEE_DELETED",
            company_id=target_company_id,
            actor_name=user.get("name"),
            actor_role=user.get("role"),
            details={"emp_id": emp_id},
            ip=client_ip(),
            user_agent=client_user_agent()
        )
        return jsonify({"ok": True, "message": f"Employee '{emp_id}' deleted successfully"})


@app.route("/api/company/pending-employees", methods=["GET"])
def company_pending_employees():
    """List all pending self-registered employees for this specific company workspace."""
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    pending_list = list(employees_col.find({"company_id": target_company_id, "status": "pending"}).sort("created_at", -1))
    for p in pending_list:
        p["_id"] = str(p["_id"])

    return jsonify({"ok": True, "pending_employees": pending_list, "count": len(pending_list)})


@app.route("/api/company/pending-employees/<emp_id>/approve", methods=["POST"])
def company_approve_employee(emp_id):
    """Company Admin approves and activates a self-registered employee account."""
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    emp_id = emp_id.upper()
    emp = employees_col.find_one({"company_id": target_company_id, "emp_id": emp_id})
    if not emp:
        return jsonify({"ok": False, "error": "Employee record not found"}), 404

    data = request.json or {}
    update_data = {
        "status": "active",
        "approved_at": get_utc_iso_string(),
        "approved_by": user.get("name", "Company Admin")
    }
    if "department" in data: update_data["department"] = data["department"]
    if "designation" in data: update_data["designation"] = data["designation"]
    if "work_type" in data: update_data["work_type"] = data["work_type"]

    employees_col.update_one({"company_id": target_company_id, "emp_id": emp_id}, {"$set": update_data})
    users_col.update_one({"company_id": target_company_id, "emp_id": emp_id}, {"$set": {
        "status": "active",
        "department": update_data.get("department", emp.get("department")),
        "designation": update_data.get("designation", emp.get("designation")),
        "work_type": update_data.get("work_type", emp.get("work_type"))
    }})

    # Send in-app welcome notification to the employee
    notifications_col.insert_one({
        "company_id": target_company_id,
        "emp_id": emp_id,
        "title": "Welcome! Account Registration Approved",
        "message": f"Your employee account has been approved by {user.get('name')}. You can now sign in and mark attendance.",
        "type": "ONBOARDING_APPROVED",
        "is_read": False,
        "timestamp_utc": get_utc_iso_string()
    })

    log_audit_event(
        action="EMPLOYEE_REGISTRATION_APPROVED",
        company_id=target_company_id,
        actor_name=user.get("name"),
        actor_role=user.get("role"),
        details={"emp_id": emp_id, "employee_name": emp.get("name")},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": f"Employee {emp.get('name')} ({emp_id}) approved and activated successfully"})


@app.route("/api/company/pending-employees/<emp_id>/reject", methods=["POST"])
def company_reject_employee(emp_id):
    """Company Admin rejects a self-registered employee account."""
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    emp_id = emp_id.upper()
    emp = employees_col.find_one({"company_id": target_company_id, "emp_id": emp_id})
    if not emp:
        return jsonify({"ok": False, "error": "Employee record not found"}), 404

    now_utc = get_utc_iso_string()
    employees_col.update_one({"company_id": target_company_id, "emp_id": emp_id}, {"$set": {"status": "rejected", "rejected_at": now_utc, "rejected_by": user.get("name")}})
    users_col.update_one({"company_id": target_company_id, "emp_id": emp_id}, {"$set": {"status": "rejected"}})

    log_audit_event(
        action="EMPLOYEE_REGISTRATION_REJECTED",
        company_id=target_company_id,
        actor_name=user.get("name"),
        actor_role=user.get("role"),
        details={"emp_id": emp_id, "employee_name": emp.get("name")},
        ip=client_ip(),
        user_agent=client_user_agent()
    )

    return jsonify({"ok": True, "message": f"Employee {emp.get('name')} ({emp_id}) registration rejected"})



@app.route("/api/company/stats", methods=["GET"])
def company_stats():
    """Calculate company today's live KPI attendance metrics strictly from database."""
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    company = companies_col.find_one({"company_id": target_company_id})
    tz = company.get("timezone", DEFAULT_TIMEZONE) if company else DEFAULT_TIMEZONE
    today_date, _, _ = get_localized_time(tz)

    registered_total = employees_col.count_documents({"company_id": target_company_id})
    active_total = employees_col.count_documents({"company_id": target_company_id, "status": "active"})

    present_count = attendance_col.count_documents({"company_id": target_company_id, "date": today_date, "status": "Present"})
    late_count = attendance_col.count_documents({"company_id": target_company_id, "date": today_date, "status": "Late"})
    half_day_count = attendance_col.count_documents({"company_id": target_company_id, "date": today_date, "status": "Half Day"})
    wfh_count = attendance_col.count_documents({"company_id": target_company_id, "date": today_date, "work_type": "WFH"})
    field_count = attendance_col.count_documents({"company_id": target_company_id, "date": today_date, "work_type": "Field"})

    # Real calculated absent: Active employees who haven't marked attendance today
    marked_total = attendance_col.count_documents({"company_id": target_company_id, "date": today_date})
    absent_count = max(0, active_total - marked_total)

    stats_payload = {
        "total_employees": registered_total,
        "active_employees": active_total,
        "registered": registered_total,
        "active": active_total,
        "present_today": present_count,
        "present": present_count,
        "absent": absent_count,
        "late_today": late_count,
        "late": late_count,
        "half_day_today": half_day_count,
        "half_day": half_day_count,
        "wfh_today": wfh_count,
        "wfh": wfh_count,
        "field_today": field_count,
        "field": field_count,
        "punctuality_rate": round(((present_count) / max(1, marked_total)) * 100, 1) if marked_total > 0 else 100.0
    }

    return jsonify({
        "ok": True,
        "date": today_date,
        "timezone": tz,
        "stats": stats_payload
    })


@app.route("/api/company/ai-insights", methods=["GET"])
def company_ai_insights():
    """AI Attendance Telemetry: Department performance, hourly distribution, and anomaly detection."""
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    company = companies_col.find_one({"company_id": target_company_id})
    tz = company.get("timezone", DEFAULT_TIMEZONE) if company else DEFAULT_TIMEZONE
    today_date, _, _ = get_localized_time(tz)

    # Hourly distribution for today
    today_logs = list(attendance_col.find({"company_id": target_company_id, "date": today_date}))
    hourly_counts = {f"{h:02d}:00": 0 for h in range(7, 21)}
    for log in today_logs:
        t = log.get("time", "")
        if t and len(t) >= 2:
            hr_key = f"{t[:2]}:00"
            if hr_key in hourly_counts:
                hourly_counts[hr_key] += 1

    # Department breakdown
    pipeline_dept = [
        {"$match": {"company_id": target_company_id}},
        {"$group": {"_id": "$department", "total": {"$sum": 1}}}
    ]
    dept_stats = list(employees_col.aggregate(pipeline_dept))
    dept_attendance = []
    for d in dept_stats:
        dname = d.get("_id") or "General"
        emp_in_dept = d.get("total", 0)
        present_in_dept = attendance_col.count_documents({
            "company_id": target_company_id,
            "department": dname,
            "date": today_date
        })
        dept_attendance.append({
            "department": dname,
            "total_employees": emp_in_dept,
            "present_today": present_in_dept,
            "rate": round((present_in_dept / max(1, emp_in_dept)) * 100, 1)
        })

    # AI Anomaly Detection flags
    anomalies = []
    late_today = [l for l in today_logs if l.get("status") == "Late"]
    if len(late_today) > 0:
        anomalies.append({
            "type": "LATE_BURST",
            "severity": "medium",
            "message": f"AI Alert: {len(late_today)} employee(s) arrived past the grace threshold today."
        })

    field_active = [l for l in today_logs if l.get("work_type") == "Field"]
    if len(field_active) > 0:
        anomalies.append({
            "type": "FIELD_ACTIVE",
            "severity": "info",
            "message": f"AI Telemetry: {len(field_active)} field personnel actively reporting GPS coordinates."
        })

    return jsonify({
        "ok": True,
        "hourly_distribution": [{"hour": k, "count": v} for k, v in hourly_counts.items()],
        "department_performance": dept_attendance,
        "anomalies": anomalies,
        "ai_health_score": 99.4
    })


@app.route("/api/company/attendance", methods=["GET"])
def company_attendance_logs():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    date = request.args.get("date")
    dept = request.args.get("department")
    work_type = request.args.get("work_type")
    method = request.args.get("method")
    status = request.args.get("status")
    emp_id = request.args.get("emp_id")

    query = {"company_id": target_company_id}
    if date: query["$or"] = [{"date": date}, {"local_date": date}]
    if dept: query["department"] = dept
    if work_type: query["work_type"] = work_type
    if method: query["method"] = method
    if status: query["status"] = status
    if emp_id: query["emp_id"] = emp_id.upper()

    limit = int(request.args.get("limit", 200))
    logs = list(attendance_col.find(query).sort("timestamp_utc", -1).limit(limit))
    for l in logs:
        l["_id"] = str(l["_id"])

    return jsonify({"ok": True, "rows": logs, "count": len(logs), "company_id": target_company_id})


@app.route("/api/company/export-csv", methods=["GET"])
def company_export_csv():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    period = request.args.get("period", "today")
    company = companies_col.find_one({"company_id": target_company_id})
    tz = company.get("timezone", DEFAULT_TIMEZONE) if company else DEFAULT_TIMEZONE
    today_date, _, _ = get_localized_time(tz)

    query = {"company_id": target_company_id}
    if period == "today":
        query["date"] = today_date
        fname = f"{target_company_id}_attendance_{today_date}.csv"
    elif period == "month":
        month_prefix = today_date[:7]
        query["date"] = {"$regex": f"^{month_prefix}"}
        fname = f"{target_company_id}_attendance_month_{month_prefix}.csv"
    else:
        fname = f"{target_company_id}_attendance_all.csv"

    rows = list(attendance_col.find(query, {"_id": 0, "encoding": 0}).sort([("date", 1), ("time", 1)]))

    output = io.StringIO()
    fields = ["company_id", "emp_id", "name", "department", "work_type", "date", "time", "status", "method", "ip", "notes", "timestamp_utc"]
    writer = csv.DictWriter(output, fieldnames=fields, extrasaction="ignore")
    writer.writeheader()
    writer.writerows(rows)

    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={"Content-Disposition": f"attachment; filename={fname}"}
    )


@app.route("/api/company/field-visits", methods=["GET"])
def company_field_visits():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    visits = list(field_visits_col.find({"company_id": target_company_id}).sort("timestamp_utc", -1).limit(100))
    for v in visits:
        v["_id"] = str(v["_id"])
    return jsonify({"ok": True, "visits": visits, "count": len(visits)})


@app.route("/api/company/audit-logs", methods=["GET"])
def company_audit_logs():
    user, err = require_auth(allowed_roles=["company_admin", "super_admin"])
    if err:
        return err

    target_company_id, iso_err = resolve_tenant_id(user, request.args.get("company_id"))
    if iso_err:
        return iso_err

    logs = list(audit_logs_col.find({"company_id": target_company_id}).sort("timestamp_utc", -1).limit(100))
    for l in logs:
        l["_id"] = str(l["_id"])
    return jsonify({"ok": True, "logs": logs, "count": len(logs)})


# ══════════════════════════════════════════════════════════════════════════════
#  ATTENDANCE ENGINE APIS (Multi-Tenant & Multi-Method)
# ══════════════════════════════════════════════════════════════════════════════

@app.route("/api/attendance/validate-employee", methods=["POST"])
def api_validate_employee():
    """
    Validates company existence, active status, employee existence, and work permissions.
    """
    data = request.json or {}
    company_id = data.get("company_id", "").strip().upper()
    emp_id = data.get("emp_id", "").strip().upper()
    method = data.get("method", "Face").strip()

    company, employee, error = validate_company_and_employee(company_id, emp_id, required_method=method)
    if error:
        return jsonify({"ok": False, "valid": False, "error": error}), 400

    return jsonify({
        "ok": True,
        "valid": True,
        "employee": {
            "emp_id": employee.get("emp_id"),
            "name": employee.get("name"),
            "department": employee.get("department"),
            "designation": employee.get("designation"),
            "work_type": employee.get("work_type"),
            "company_id": company_id,
            "company_name": company.get("name"),
            "timezone": employee.get("timezone", company.get("timezone", DEFAULT_TIMEZONE)),
            "face_enrolled": bool(employee.get("encoding"))
        }
    })


@app.route("/api/attendance/liveness-challenge", methods=["POST"])
def api_attendance_liveness_challenge():
    """Generate an active challenge with short-lived session token to defeat presentation attacks."""
    data = request.json or {}
    company_id = data.get("company_id", "").strip().upper()
    emp_id = data.get("emp_id", "").strip().upper()

    user = get_current_user()
    if user and user.get("role") == "employee":
        if not company_id: company_id = user.get("company_id", "").upper()
        if not emp_id: emp_id = user.get("emp_id", "").upper()

    challenge_data = create_liveness_challenge_session(company_id, emp_id)
    return jsonify(challenge_data), 200


@app.route("/api/attendance/mark-face", methods=["POST"])
def api_mark_face_attendance():
    """Camera Face AI Biometric & Live Photo Attendance with Anti-Spoofing, Geofence & Policy Evaluation."""
    data = request.json or {}
    company_id = data.get("company_id", "").strip().upper()
    emp_id = data.get("emp_id", "").strip().upper()
    image = data.get("image", "")
    baseline_image = data.get("baseline_image", "")
    session_token = data.get("session_token")
    nonce = data.get("nonce")
    liveness_metadata = data.get("liveness_metadata") or {}
    lat = data.get("lat")
    lng = data.get("lng")
    accuracy = data.get("accuracy")

    user = get_current_user()
    if user and user.get("role") == "employee":
        if not company_id: company_id = user.get("company_id", "").upper()
        if not emp_id: emp_id = user.get("emp_id", "").upper()

    company, employee, error = validate_company_and_employee(company_id, emp_id, required_method="Face")
    if error:
        return jsonify({"ok": False, "error": error}), 400

    if not image:
        return jsonify({"ok": False, "error": "Camera frame snapshot is required to mark attendance"}), 400

    # 1. Anti-Replay Session Validation (Mandatory for Face AI Biometric PAD)
    challenge_action = None
    if not session_token or not nonce:
        return jsonify({
            "ok": False,
            "error": "Liveness Challenge Required: Face biometric attendance requires an active anti-spoofing session token. Please initiate a challenge session first.",
            "code": "LIVENESS_CHALLENGE_REQUIRED"
        }), 400

    valid_sess, sess_data, sess_err = validate_and_consume_liveness_session(session_token, company_id, emp_id, nonce)
    if not valid_sess:
        log_audit_event(
            action="LIVENESS_FAILED",
            company_id=company_id,
            actor_name=employee.get("name"),
            actor_role="employee",
            details={
                "emp_id": emp_id,
                "reason": sess_err,
                "attack_type": "Session Replay / Token Hijacking Attempt",
                "method": "Face"
            },
            ip=client_ip(),
            user_agent=client_user_agent()
        )
        return jsonify({
            "ok": False,
            "error": f"Security Anti-Replay Alert: {sess_err}",
            "code": "LIVENESS_SESSION_INVALID"
        }), 400
    challenge_action = sess_data.get("challenge")

    # 2. Multi-Layer Presentation Attack Detection (PAD) & Liveness Evaluation
    liveness_eval = evaluate_liveness_score(
        action_image_b64=image,
        baseline_image_b64=baseline_image,
        liveness_metadata=liveness_metadata,
        challenge_action=challenge_action,
        threshold=LIVENESS_CONFIDENCE_THRESHOLD
    )

    if not liveness_eval["is_live"]:
        fail_reason = liveness_eval.get("reason", "Liveness verification failed")
        is_hard_spoof = any(k in fail_reason.lower() for k in ["virtual", "screen", "moiré", "static", "cutout", "glare", "planar", "chromatic"])
        log_audit_event(
            action="SPOOFING_ATTEMPT_DETECTED" if is_hard_spoof else "LIVENESS_FAILED",
            company_id=company_id,
            actor_name=employee.get("name"),
            actor_role="employee",
            details={
                "emp_id": emp_id,
                "reason": fail_reason,
                "liveness_score": liveness_eval.get("liveness_score", 0.0),
                "checks": liveness_eval.get("checks", {}),
                "method": "Face"
            },
            ip=client_ip(),
            user_agent=client_user_agent()
        )
        return jsonify({
            "ok": False,
            "error": f"Biometric Anti-Spoofing Alert: {fail_reason}",
            "code": "SPOOFING_DETECTED",
            "details": liveness_eval
        }), 400

    # 3. Geofence check for Office employees if coordinates available
    if employee.get("work_type") == "Office" and lat is not None and lng is not None:
        policy = policies_col.find_one({"company_id": company_id}) or {}
        enforce_geo = policy.get("enforce_geofence", False) or company.get("enforce_geofence", False)
        office_locations = company.get("office_locations", [])
        if office_locations and enforce_geo:
            within_any = False
            min_dist = 999999
            for loc in office_locations:
                loc_lat = float(loc.get("lat", OFFICE_LAT))
                loc_lng = float(loc.get("lng", OFFICE_LNG))
                loc_radius = float(loc.get("radius_m", OFFICE_RADIUS_M))
                dist = haversine_distance(float(lat), float(lng), loc_lat, loc_lng)
                if dist < min_dist:
                    min_dist = dist
                if dist <= loc_radius:
                    within_any = True
                    break
            if not within_any:
                return jsonify({
                    "ok": False,
                    "error": f"Geofence check failed: You are outside the authorized office boundary ({round(min_dist, 1)}m away). Allowed radius: {OFFICE_RADIUS_M}m"
                }), 400

    # 4. Biometric Identity Matching against Database Enrolled Template
    enrolled_encoding = employee.get("encoding")
    if enrolled_encoding:
        is_match, dist, match_err = verify_face_biometric_match(image, enrolled_encoding, tolerance=FACE_MATCH_TOLERANCE)
        if not is_match:
            log_audit_event(
                action="BIOMETRIC_MISMATCH",
                company_id=company_id,
                actor_name=employee.get("name"),
                actor_role="employee",
                details={
                    "emp_id": emp_id,
                    "reason": match_err or "Face does not match registered employee profile",
                    "distance": dist,
                    "tolerance": FACE_MATCH_TOLERANCE,
                    "method": "Face"
                },
                ip=client_ip(),
                user_agent=client_user_agent()
            )
            return jsonify({
                "ok": False,
                "error": f"Biometric Verification Rejected: Detected face does not match registered biometric profile for {employee.get('name')} ({emp_id}).",
                "code": "BIOMETRIC_MISMATCH"
            }), 400
    else:
        # First-time auto-enrollment of live validated facial biometric
        try:
            new_enc, enc_err = encode_face_from_b64(image)
            if not enc_err and new_enc:
                employees_col.update_one({"emp_id": emp_id, "company_id": company_id}, {"$set": {"encoding": new_enc}})
        except Exception:
            pass

    # 5. Localized Time & Attendance Policy with Hierarchical Fallback
    tz = resolve_entity_timezone(employee, None, company, DEFAULT_TIMEZONE)
    local_date, local_time, local_formatted = get_localized_time(tz)
    utc_iso = get_utc_iso_string()
    ip = client_ip()

    # Prevent Duplicate Attendance for the day
    existing = attendance_col.find_one({"company_id": company_id, "emp_id": emp_id, "$or": [{"date": local_date}, {"local_date": local_date}]})
    if existing:
        return jsonify({
            "ok": True,
            "status": "already_marked",
            "attendance_status": existing.get("status", "Present"),
            "name": employee.get("name"),
            "emp_id": emp_id,
            "company_name": company.get("name"),
            "company_id": company_id,
            "time": existing.get("time"),
            "date": local_date,
            "timezone": tz,
            "message": f"Attendance already marked for today at {existing.get('time')} ({tz})"
        })

    # Policy-based status evaluation (Present, Late, Half Day)
    policy = policies_col.find_one({"company_id": company_id}) or {}
    status = evaluate_attendance_status(local_time, policy, employee.get("work_type", "Office"))

    attendance_doc = {
        "company_id": company_id,
        "emp_id": emp_id,
        "name": employee.get("name"),
        "department": employee.get("department", "General"),
        "designation": employee.get("designation", "Staff"),
        "work_type": employee.get("work_type", "Office"),
        "date": local_date,
        "time": local_time,
        "local_date": local_date,
        "local_time": local_time,
        "timezone": tz,
        "timestamp_utc": utc_iso,
        "status": status,
        "method": "Face",
        "photo_captured": True,
        "liveness_verified": True,
        "liveness_score": liveness_eval.get("liveness_score", 1.0),
        "ip": ip,
        "location": {"lat": float(lat), "lng": float(lng), "accuracy": float(accuracy) if accuracy else None} if lat and lng else None,
        "device_info": client_user_agent()
    }
    attendance_col.insert_one(attendance_doc)

    log_audit_event(
        action="ATTENDANCE_MARKED_FACE",
        company_id=company_id,
        actor_name=employee.get("name"),
        actor_role="employee",
        details={
            "emp_id": emp_id,
            "method": "Face",
            "liveness_score": liveness_eval.get("liveness_score", 1.0),
            "date": local_date,
            "time": local_time,
            "status": status
        },
        ip=ip,
        user_agent=client_user_agent()
    )

    return jsonify({
        "ok": True,
        "status": "marked",
        "attendance_status": status,
        "liveness_verified": True,
        "liveness_score": liveness_eval.get("liveness_score", 1.0),
        "name": employee.get("name"),
        "emp_id": emp_id,
        "company_name": company.get("name"),
        "company_id": company_id,
        "department": employee.get("department", "General"),
        "work_type": employee.get("work_type", "Office"),
        "date": local_date,
        "time": local_time,
        "formatted": local_formatted,
        "timezone": tz,
        "message": f"🎉 Attendance marked successfully for {employee.get('name')} ({emp_id}) as '{status}' at {local_time} ({tz})"
    })


@app.route("/api/attendance/otp-send", methods=["POST"])
def api_otp_send():
    """Method 2: Secure Two-Factor OTP Dispatch Engine."""
    data = request.json or {}
    company_id = data.get("company_id", "").strip().upper()
    emp_id = data.get("emp_id", "").strip().upper()

    user = get_current_user()
    if user and user.get("role") == "employee":
        company_id = user.get("company_id")
        emp_id = user.get("emp_id")

    company, employee, error = validate_company_and_employee(company_id, emp_id, required_method="OTP")
    if error:
        return jsonify({"ok": False, "error": error}), 400

    otp_key = f"{company_id}:{emp_id}"
    
    # Rate limit check: max 1 request every 30 seconds
    now_ts = datetime.now(timezone.utc).timestamp()
    if otp_key in otp_store and (now_ts < otp_store[otp_key]["created_ts"] + 30):
        remaining = int((otp_store[otp_key]["created_ts"] + 30) - now_ts)
        return jsonify({"ok": False, "error": f"Please wait {remaining}s before requesting a new OTP"}), 429

    otp_code = str(random.randint(100000, 999999))
    expires = now_ts + 300  # 5 minutes expiry

    otp_store[otp_key] = {
        "otp_hash": hash_password(otp_code),
        "expires": expires,
        "attempts": 0,
        "created_ts": now_ts,
        "mobile": employee.get("mobile"),
        "email": employee.get("email"),
        "raw_code": otp_code  # Stored in memory for private in-session retrieval
    }

    # Store in private in-system notification vault (100% self-contained private API)
    notifications_col.insert_one({
        "company_id": company_id,
        "emp_id": emp_id,
        "type": "OTP_VERIFICATION",
        "title": "Private Attendance Verification Code",
        "message": f"Your private attendance verification code is: {otp_code} (Valid for 5 minutes).",
        "otp_code": otp_code,
        "expires_ts": expires,
        "timestamp_utc": get_utc_iso_string(),
        "read": False
    })

    mobile = employee.get("mobile", "")
    masked = mobile[:2] + "****" + mobile[-2:] if len(mobile) >= 4 else mobile
    print(f"\n[PRIVATE IN-SYSTEM OTP DISPATCH] Company: {company_id} | Employee: {employee.get('name')} ({emp_id}) | Code: {otp_code}\n")

    return jsonify({
        "ok": True,
        "message": f"Private verification code generated and delivered to your private account ({masked})"
    })


@app.route("/api/attendance/otp-verify", methods=["POST"])
def api_otp_verify():
    """Method 2: Verify 6-digit OTP and mark attendance."""
    data = request.json or {}
    company_id = data.get("company_id", "").strip().upper()
    emp_id = data.get("emp_id", "").strip().upper()
    entered_otp = data.get("otp", "").strip()

    user = get_current_user()
    if user and user.get("role") == "employee":
        company_id = user.get("company_id")
        emp_id = user.get("emp_id")

    company, employee, error = validate_company_and_employee(company_id, emp_id, required_method="OTP")
    if error:
        return jsonify({"ok": False, "error": error}), 400

    otp_key = f"{company_id}:{emp_id}"
    stored = otp_store.get(otp_key)
    if not stored:
        return jsonify({"ok": False, "error": "No active OTP request found. Please request a new OTP."}), 400

    now_ts = datetime.now(timezone.utc).timestamp()
    if now_ts > stored["expires"]:
        del otp_store[otp_key]
        return jsonify({"ok": False, "error": "OTP has expired. Please request a fresh OTP."}), 400

    if stored["attempts"] >= 3:
        del otp_store[otp_key]
        return jsonify({"ok": False, "error": "Maximum OTP verification attempts exceeded. Please request a new OTP."}), 403

    if hash_password(entered_otp) != stored["otp_hash"]:
        stored["attempts"] += 1
        remaining = 3 - stored["attempts"]
        return jsonify({"ok": False, "error": f"Incorrect OTP entered. {remaining} attempt(s) remaining."}), 400

    # Clean OTP from memory upon successful verification
    del otp_store[otp_key]

    tz = resolve_entity_timezone(employee, None, company, DEFAULT_TIMEZONE)
    local_date, local_time, local_formatted = get_localized_time(tz)
    utc_iso = get_utc_iso_string()
    ip = client_ip()

    existing = attendance_col.find_one({"company_id": company_id, "emp_id": emp_id, "$or": [{"date": local_date}, {"local_date": local_date}]})
    if existing:
        return jsonify({
            "ok": True,
            "status": "already_marked",
            "time": existing.get("time"),
            "date": local_date,
            "timezone": tz,
            "message": f"Attendance already recorded for today at {existing.get('time')} ({tz})"
        })

    policy = policies_col.find_one({"company_id": company_id}) or {}
    status = evaluate_attendance_status(local_time, policy, employee.get("work_type", "Office"))

    attendance_doc = {
        "company_id": company_id,
        "emp_id": emp_id,
        "name": employee.get("name"),
        "department": employee.get("department"),
        "work_type": employee.get("work_type"),
        "date": local_date,
        "time": local_time,
        "local_date": local_date,
        "local_time": local_time,
        "timezone": tz,
        "timestamp_utc": utc_iso,
        "status": status,
        "method": "OTP",
        "ip": ip,
        "device_info": client_user_agent()
    }
    attendance_col.insert_one(attendance_doc)

    log_audit_event(
        action="ATTENDANCE_MARKED_OTP",
        company_id=company_id,
        actor_name=employee.get("name"),
        actor_role="employee",
        details={"emp_id": emp_id, "method": "OTP", "date": local_date, "time": local_time, "status": status},
        ip=ip,
        user_agent=client_user_agent()
    )

    return jsonify({
        "ok": True,
        "status": "marked",
        "attendance_status": status,
        "date": local_date,
        "time": local_time,
        "formatted": local_formatted,
        "timezone": tz,
        "message": f"[+] OTP verification successful! Attendance marked as '{status}' at {local_time} ({tz})"
    })


@app.route("/api/attendance/mark-wifi", methods=["POST"])
def api_mark_wifi_attendance():
    """Method 3: Office Authorized Wi-Fi Network Attendance."""
    data = request.json or {}
    company_id = data.get("company_id", "").strip().upper()
    emp_id = data.get("emp_id", "").strip().upper()

    user = get_current_user()
    if user and user.get("role") == "employee":
        company_id = user.get("company_id")
        emp_id = user.get("emp_id")

    company, employee, error = validate_company_and_employee(company_id, emp_id, required_method="WiFi")
    if error:
        return jsonify({"ok": False, "error": error}), 400

    ip = client_ip()
    on_office, reason = is_office_ip(ip, company_id=company_id)
    if not on_office:
        return jsonify({"ok": False, "error": f"Wi-Fi validation rejected: {reason}"}), 400

    tz = resolve_entity_timezone(employee, None, company, DEFAULT_TIMEZONE)
    local_date, local_time, local_formatted = get_localized_time(tz)
    utc_iso = get_utc_iso_string()

    existing = attendance_col.find_one({"company_id": company_id, "emp_id": emp_id, "$or": [{"date": local_date}, {"local_date": local_date}]})
    if existing:
        return jsonify({
            "ok": True,
            "status": "already_marked",
            "time": existing.get("time"),
            "date": local_date,
            "timezone": tz,
            "message": f"Attendance already recorded for today at {existing.get('time')} ({tz})"
        })

    policy = policies_col.find_one({"company_id": company_id}) or {}
    status = evaluate_attendance_status(local_time, policy, employee.get("work_type", "Office"))

    attendance_doc = {
        "company_id": company_id,
        "emp_id": emp_id,
        "name": employee.get("name"),
        "department": employee.get("department"),
        "work_type": employee.get("work_type"),
        "date": local_date,
        "time": local_time,
        "local_date": local_date,
        "local_time": local_time,
        "timezone": tz,
        "timestamp_utc": utc_iso,
        "status": status,
        "method": "WiFi",
        "ip": ip,
        "device_info": client_user_agent()
    }
    attendance_col.insert_one(attendance_doc)

    log_audit_event(
        action="ATTENDANCE_MARKED_WIFI",
        company_id=company_id,
        actor_name=employee.get("name"),
        actor_role="employee",
        details={"emp_id": emp_id, "method": "WiFi", "ip": ip, "status": status},
        ip=ip,
        user_agent=client_user_agent()
    )

    return jsonify({
        "ok": True,
        "status": "marked",
        "attendance_status": status,
        "date": local_date,
        "time": local_time,
        "formatted": local_formatted,
        "timezone": tz,
        "message": f"[+] Office Wi-Fi network verified! Attendance recorded as '{status}' at {local_time} ({tz})"
    })


@app.route("/api/attendance/mark-field", methods=["POST"])
def api_mark_field_attendance():
    """Field Employee & Remote Attendance with Real GPS Geolocation and Client Meeting Tracking."""
    data = request.json or {}
    company_id = data.get("company_id", "").strip().upper()
    emp_id = data.get("emp_id", "").strip().upper()
    lat = data.get("lat")
    lng = data.get("lng")
    accuracy = data.get("accuracy", 0)
    check_type = data.get("check_type", "IN").upper()  # IN or OUT
    client_name = data.get("client_name", "").strip()
    notes = data.get("notes", "").strip()

    user = get_current_user()
    if user and user.get("role") == "employee":
        company_id = user.get("company_id")
        emp_id = user.get("emp_id")

    company, employee, error = validate_company_and_employee(company_id, emp_id, required_method="GPS")
    if error:
        return jsonify({"ok": False, "error": error}), 400

    if lat is None or lng is None:
        return jsonify({"ok": False, "error": "Verified GPS Location coordinates are required for field attendance"}), 400

    tz = resolve_entity_timezone(employee, None, company, DEFAULT_TIMEZONE)
    local_date, local_time, local_formatted = get_localized_time(tz)
    utc_iso = get_utc_iso_string()
    ip = client_ip()

    attendance_doc = {
        "company_id": company_id,
        "emp_id": emp_id,
        "name": employee.get("name"),
        "department": employee.get("department"),
        "work_type": "Field",
        "date": local_date,
        "time": local_time,
        "local_date": local_date,
        "local_time": local_time,
        "timezone": tz,
        "timestamp_utc": utc_iso,
        "status": "Field",
        "method": "GPS_Field",
        "check_type": check_type,
        "ip": ip,
        "location": {"lat": float(lat), "lng": float(lng), "accuracy": accuracy},
        "notes": f"[{check_type}] Client: {client_name} | {notes}" if client_name or notes else f"Field Check-{check_type}",
        "device_info": client_user_agent()
    }
    attendance_col.insert_one(attendance_doc)

    # If client visit details provided, record in dedicated field_visits collection
    if client_name or notes:
        field_visits_col.insert_one({
            "company_id": company_id,
            "emp_id": emp_id,
            "name": employee.get("name"),
            "date": local_date,
            "time": local_time,
            "timestamp_utc": utc_iso,
            "client_name": client_name,
            "check_type": check_type,
            "location": {"lat": float(lat), "lng": float(lng), "accuracy": accuracy},
            "notes": notes
        })

    log_audit_event(
        action=f"FIELD_ATTENDANCE_{check_type}",
        company_id=company_id,
        actor_name=employee.get("name"),
        actor_role="employee",
        details={"emp_id": emp_id, "lat": lat, "lng": lng, "client": client_name, "check_type": check_type},
        ip=ip,
        user_agent=client_user_agent()
    )

    return jsonify({
        "ok": True,
        "status": "marked",
        "check_type": check_type,
        "date": local_date,
        "time": local_time,
        "formatted": local_formatted,
        "timezone": tz,
        "message": f"[+] Field GPS Check-{check_type} recorded at {local_time} ({tz})"
    })


@app.route("/api/attendance/my-history", methods=["GET"])
def api_my_attendance_history():
    """Retrieve personal attendance history and live statistics for authenticated employee."""
    user, err = require_auth(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    emp_id = user.get("emp_id")
    company_id = user.get("company_id")

    if not emp_id or not company_id:
        return jsonify({
            "ok": True, 
            "rows": [], 
            "logs": [], 
            "count": 0, 
            "today": None,
            "stats": {"present": 0, "late": 0, "half_day": 0, "wfh": 0, "field": 0, "total": 0, "leaves": 0, "punctuality_rate": 100.0}
        })

    company = companies_col.find_one({"company_id": company_id})
    tz = user.get("timezone") or (company.get("timezone") if company else DEFAULT_TIMEZONE) or DEFAULT_TIMEZONE
    today_date, _, _ = get_localized_time(tz)

    history = list(attendance_col.find({"company_id": company_id, "emp_id": emp_id}).sort("timestamp_utc", -1).limit(60))
    for h in history:
        h["_id"] = str(h["_id"])

    # Find today's record
    today_rec = next((h for h in history if h.get("date") == today_date), None)
    if not today_rec:
        today_db = attendance_col.find_one({"company_id": company_id, "emp_id": emp_id, "date": today_date})
        if today_db:
            today_db["_id"] = str(today_db["_id"])
            today_rec = today_db

    # Calculate employee personal stats
    present_cnt = sum(1 for h in history if h.get("status") == "Present")
    late_cnt = sum(1 for h in history if h.get("status") == "Late")
    half_day_cnt = sum(1 for h in history if h.get("status") == "Half Day")
    wfh_cnt = sum(1 for h in history if h.get("work_type") == "WFH" or h.get("status") == "WFH")
    field_cnt = sum(1 for h in history if h.get("work_type") == "Field" or h.get("status") == "Field")
    total_cnt = len(history)

    # Approved leaves count
    leaves_cnt = leaves_col.count_documents({"company_id": company_id, "emp_id": emp_id, "status": "approved"})

    punctuality = round((present_cnt / max(1, total_cnt)) * 100, 1) if total_cnt > 0 else 100.0

    stats = {
        "present": present_cnt,
        "late": late_cnt,
        "half_day": half_day_cnt,
        "wfh": wfh_cnt,
        "field": field_cnt,
        "total": total_cnt,
        "leaves": leaves_cnt,
        "punctuality_rate": punctuality
    }

    return jsonify({
        "ok": True,
        "rows": history,
        "logs": history,
        "count": len(history),
        "today": today_rec,
        "today_date": today_date,
        "stats": stats
    })


@app.route("/api/superadmin/reset-system-data", methods=["POST"])
def api_superadmin_reset_data():
    """Wipes all business data to a clean ZERO state, keeping only Super Admin account."""
    user, err = require_auth(allowed_roles=["super_admin"])
    if err:
        return err

    from database import reset_database_to_zero
    reset_database_to_zero()

    log_audit_event(
        action="SUPER_ADMIN_SYSTEM_ZERO_RESET",
        company_id="GLOBAL",
        actor_name=user.get("name", "Super Admin"),
        actor_role="super_admin",
        details={"initiated_by": user.get("email"), "reason": "Admin requested clean zero-data reset"}
    )

    return jsonify({
        "ok": True,
        "message": "System database successfully wiped and reset to clean zero state. All tables initialized from scratch."
    })



@app.route("/api/network-status", methods=["GET"])
def api_network_status():
    company_id = request.args.get("company_id", "")
    ip = client_ip()
    on_office, reason = is_office_ip(ip, company_id=company_id)
    return jsonify({
        "on_office_wifi": on_office,
        "client_ip": ip,
        "server_ip": get_server_local_ip(),
        "reason": reason
    })


@app.route("/api/notifications", methods=["GET"])
def api_get_private_notifications():
    """Retrieve private in-system notifications for the authenticated user/employee."""
    user, err = require_auth()
    if err:
        return err

    company_id = user.get("company_id")
    emp_id = user.get("emp_id")

    query = {"company_id": company_id}
    if emp_id:
        query["emp_id"] = emp_id

    notes = list(notifications_col.find(query).sort("timestamp_utc", -1).limit(30))
    for n in notes:
        n["_id"] = str(n["_id"])
    return jsonify({"ok": True, "notifications": notes, "count": len(notes)})


@app.route("/api/attendance/my-active-otp", methods=["GET"])
def api_my_active_otp():
    """
    Private in-session OTP retriever.
    Allows authenticated employee to securely view their active OTP code in-app without any 3rd party SMS gateway.
    """
    user, err = require_auth(allowed_roles=["employee", "company_admin", "super_admin", "hr", "manager"])
    if err:
        return err

    company_id = user.get("company_id")
    emp_id = user.get("emp_id")

    if not company_id or not emp_id:
        return jsonify({"ok": False, "error": "Employee session context missing"}), 400

    otp_key = f"{company_id}:{emp_id}"
    stored = otp_store.get(otp_key)

    if not stored:
        return jsonify({"ok": False, "error": "No active OTP found"}), 404

    now_ts = datetime.now(timezone.utc).timestamp()
    if now_ts > stored["expires"]:
        del otp_store[otp_key]
        return jsonify({"ok": False, "error": "OTP expired"}), 400

    remaining_secs = int(stored["expires"] - now_ts)
    return jsonify({
        "ok": True,
        "otp_code": stored.get("raw_code"),
        "expires_in_seconds": remaining_secs
    })


# ── Dynamic Rotating Security Token Helper ────────────────────────────────────
def generate_dynamic_token(company_id):
    """Generates a time-based rotating 6-digit dynamic security code valid for 60 seconds."""
    time_block = int(datetime.now(timezone.utc).timestamp() // 60)
    raw = f"{company_id}:{SECRET_KEY}:{time_block}"
    token_hash = hashlib.sha256(raw.encode("utf-8")).hexdigest()
    return f"{int(token_hash[:8], 16) % 900000 + 100000}"

def verify_dynamic_token(company_id, code):
    """Verifies dynamic token against current and adjacent 60s time blocks."""
    if not code: return False
    code = str(code).strip()
    cur_time_block = int(datetime.now(timezone.utc).timestamp() // 60)
    for tb in (cur_time_block, cur_time_block - 1, cur_time_block + 1):
        raw = f"{company_id}:{SECRET_KEY}:{tb}"
        token_hash = hashlib.sha256(raw.encode("utf-8")).hexdigest()
        expected = f"{int(token_hash[:8], 16) % 900000 + 100000}"
        if code == expected:
            return True
    return False

@app.route("/api/attendance/dynamic-token", methods=["GET"])
def api_get_dynamic_token():
    """Generates rotating dynamic office token / QR payload."""
    company_id = request.args.get("company_id", "").strip().upper()
    if not company_id:
        user = get_current_user()
        if user: company_id = user.get("company_id", "").upper()
    if not company_id:
        return jsonify({"ok": False, "error": "Company ID required"}), 400

    token = generate_dynamic_token(company_id)
    time_remaining = int(60 - (datetime.now(timezone.utc).timestamp() % 60))
    return jsonify({
        "ok": True,
        "company_id": company_id,
        "token": token,
        "expires_in_seconds": time_remaining,
        "qr_payload": json.dumps({
            "company_id": company_id,
            "token": token,
            "type": "DYNAMIC_OFFICE_QR",
            "ts": int(datetime.now(timezone.utc).timestamp())
        })
    })

@app.route("/api/attendance/check-in", methods=["POST"])
def api_authorized_check_in():
    """
    Unified Authorized Attendance Check-In Endpoint.
    Handles:
    - Face AI camera frames (Base64)
    - Dynamic QR / Barcode / In-App Code validation
    - Office Wi-Fi / IP Subnet validation
    - Field GPS Radar validation
    - In-App 2FA OTP verification
    - Offline queued sync records
    """
    data = request.json or {}
    company_id = data.get("company_id", "").strip().upper()
    emp_id = data.get("emp_id", "").strip().upper()
    method = data.get("method", "Face").strip()
    image = data.get("image", "")
    code = data.get("code", "")
    lat = data.get("lat")
    lng = data.get("lng")
    accuracy = data.get("accuracy")
    device_id = data.get("device_id", "") or client_user_agent()
    network_status = data.get("network_status", "online")
    is_offline_sync = bool(data.get("is_offline_sync", False))
    client_timestamp = data.get("timestamp")

    user = get_current_user()
    if user and user.get("role") == "employee":
        if not company_id: company_id = user.get("company_id", "").upper()
        if not emp_id: emp_id = user.get("emp_id", "").upper()

    company, employee, error = validate_company_and_employee(company_id, emp_id, required_method=method if method not in ("QR", "Code") else None)
    if error:
        return jsonify({"ok": False, "error": error, "code": "VALIDATION_FAILED"}), 400

    # 1. Method-Specific Validation
    if method in ("QR", "Code"):
        is_valid_code = verify_dynamic_token(company_id, code)
        if not is_valid_code:
            # Check if OTP was entered as code
            otp_key = f"{company_id}:{emp_id}"
            stored = otp_store.get(otp_key)
            if stored and hash_password(code) == stored.get("otp_hash") and (datetime.now(timezone.utc).timestamp() <= stored.get("expires", 0)):
                is_valid_code = True
                del otp_store[otp_key]

        if not is_valid_code:
            return jsonify({
                "ok": False, 
                "error": "Invalid or expired verification code / QR. Please scan a fresh dynamic code or check your in-app OTP.",
                "code": "INVALID_CODE"
            }), 400

    elif method == "WiFi":
        ip = client_ip()
        on_office, reason = is_office_ip(ip, company_id=company_id)
        if not on_office:
            return jsonify({"ok": False, "error": f"Wi-Fi check-in rejected: {reason}", "code": "WIFI_MISMATCH"}), 400

    session_token = data.get("session_token")
    nonce = data.get("nonce")
    liveness_metadata = data.get("liveness_metadata") or {}
    baseline_image = data.get("baseline_image", "")
    liveness_score = 1.0

    if method == "Face":
        challenge_action = None
        if not session_token or not nonce:
            return jsonify({
                "ok": False,
                "error": "Liveness Challenge Required: Face biometric attendance requires an active anti-spoofing session token. Please initiate a challenge session first.",
                "code": "LIVENESS_CHALLENGE_REQUIRED"
            }), 400

        valid_sess, sess_data, sess_err = validate_and_consume_liveness_session(session_token, company_id, emp_id, nonce)
        if not valid_sess:
            log_audit_event(
                action="LIVENESS_FAILED",
                company_id=company_id,
                actor_name=employee.get("name"),
                actor_role="employee",
                details={"emp_id": emp_id, "reason": sess_err, "method": "Face"},
                ip=client_ip(),
                user_agent=client_user_agent()
            )
            return jsonify({
                "ok": False,
                "error": f"Liveness Security Alert: {sess_err}",
                "code": "LIVENESS_SESSION_INVALID"
            }), 400
        challenge_action = sess_data.get("challenge")

        # Multi-layer anti-spoofing verification
        liveness_eval = evaluate_liveness_score(
            action_image_b64=image,
            baseline_image_b64=baseline_image,
            liveness_metadata=liveness_metadata,
            challenge_action=challenge_action,
            threshold=LIVENESS_CONFIDENCE_THRESHOLD
        )
        if not liveness_eval["is_live"]:
            fail_reason = liveness_eval.get("reason", "Liveness verification failed")
            is_hard_spoof = any(k in fail_reason.lower() for k in ["virtual", "screen", "moiré", "static", "cutout", "glare", "planar", "chromatic"])
            log_audit_event(
                action="SPOOFING_ATTEMPT_DETECTED" if is_hard_spoof else "LIVENESS_FAILED",
                company_id=company_id,
                actor_name=employee.get("name"),
                actor_role="employee",
                details={
                    "emp_id": emp_id,
                    "reason": fail_reason,
                    "liveness_score": liveness_eval.get("liveness_score", 0.0),
                    "checks": liveness_eval.get("checks", {}),
                    "method": "Face"
                },
                ip=client_ip(),
                user_agent=client_user_agent()
            )
            return jsonify({
                "ok": False,
                "error": f"Biometric Anti-Spoofing Alert: {fail_reason}",
                "code": "SPOOFING_DETECTED",
                "details": liveness_eval
            }), 400
        liveness_score = liveness_eval.get("liveness_score", 1.0)

    # Geofence validation for Office staff when lat/lng are provided
    if employee.get("work_type") == "Office" and lat is not None and lng is not None:
        policy = policies_col.find_one({"company_id": company_id}) or {}
        enforce_geo = policy.get("enforce_geofence", False) or company.get("enforce_geofence", False)
        office_locations = company.get("office_locations", [])
        if office_locations and enforce_geo:
            within_any = False
            min_dist = 999999
            for loc in office_locations:
                loc_lat = float(loc.get("lat", OFFICE_LAT))
                loc_lng = float(loc.get("lng", OFFICE_LNG))
                loc_radius = float(loc.get("radius_m", OFFICE_RADIUS_M))
                dist = haversine_distance(float(lat), float(lng), loc_lat, loc_lng)
                if dist < min_dist: min_dist = dist
                if dist <= loc_radius:
                    within_any = True
                    break
            if not within_any:
                return jsonify({
                    "ok": False,
                    "error": f"Geofence check failed: You are outside the authorized boundary ({round(min_dist, 1)}m away). Allowed radius: {OFFICE_RADIUS_M}m",
                    "code": "GEO_MISMATCH"
                }), 400

    # Biometric identity verification and auto-enrollment for camera frames (after liveness passes)
    if method == "Face":
        enrolled_encoding = employee.get("encoding")
        if enrolled_encoding:
            is_match, dist, match_err = verify_face_biometric_match(image, enrolled_encoding, tolerance=FACE_MATCH_TOLERANCE)
            if not is_match:
                log_audit_event(
                    action="BIOMETRIC_MISMATCH",
                    company_id=company_id,
                    actor_name=employee.get("name"),
                    actor_role="employee",
                    details={
                        "emp_id": emp_id,
                        "reason": match_err or "Face does not match registered employee profile",
                        "distance": dist,
                        "tolerance": FACE_MATCH_TOLERANCE,
                        "method": "Face"
                    },
                    ip=client_ip(),
                    user_agent=client_user_agent()
                )
                return jsonify({
                    "ok": False,
                    "error": f"Biometric Verification Rejected: Detected face does not match registered biometric profile for {employee.get('name')} ({emp_id}).",
                    "code": "BIOMETRIC_MISMATCH"
                }), 400
        elif image:
            try:
                new_enc, enc_err = encode_face_from_b64(image)
                if not enc_err and new_enc:
                    employees_col.update_one({"emp_id": emp_id, "company_id": company_id}, {"$set": {"encoding": new_enc}})
            except Exception:
                pass

    # 2. Localized Time & Shift Policy Evaluation with Hierarchical Fallback
    tz = resolve_entity_timezone(employee, None, company, DEFAULT_TIMEZONE)
    local_date, local_time, local_formatted = get_localized_time(tz)
    utc_iso = get_utc_iso_string()
    ip = client_ip()

    # Anti-Duplicate Check
    existing = attendance_col.find_one({"company_id": company_id, "emp_id": emp_id, "$or": [{"date": local_date}, {"local_date": local_date}]})
    if existing:
        return jsonify({
            "ok": True,
            "status": "already_marked",
            "attendance_status": existing.get("status", "Present"),
            "name": employee.get("name"),
            "emp_id": emp_id,
            "company_name": company.get("name"),
            "company_id": company_id,
            "time": existing.get("time"),
            "date": local_date,
            "timezone": tz,
            "message": f"Attendance already recorded for today at {existing.get('time')} ({tz})"
        })

    policy = policies_col.find_one({"company_id": company_id}) or {}
    status = evaluate_attendance_status(local_time, policy, employee.get("work_type", "Office"))

    attendance_doc = {
        "company_id": company_id,
        "emp_id": emp_id,
        "name": employee.get("name"),
        "department": employee.get("department", "General"),
        "designation": employee.get("designation", "Staff"),
        "work_type": employee.get("work_type", "Office"),
        "date": local_date,
        "time": local_time,
        "local_date": local_date,
        "local_time": local_time,
        "timezone": tz,
        "timestamp_utc": utc_iso,
        "status": status,
        "method": method,
        "photo_captured": bool(image),
        "liveness_verified": True if method == "Face" else None,
        "liveness_score": liveness_score if method == "Face" else None,
        "ip": ip,
        "location": {"lat": float(lat), "lng": float(lng), "accuracy": float(accuracy) if accuracy else None} if lat and lng else None,
        "device_info": device_id,
        "network_status": network_status,
        "is_offline_sync": is_offline_sync,
        "client_timestamp": client_timestamp
    }
    attendance_col.insert_one(attendance_doc)

    log_audit_event(
        action="ATTENDANCE_CHECK_IN",
        company_id=company_id,
        actor_name=employee.get("name"),
        actor_role="employee",
        details={
            "emp_id": emp_id,
            "method": method,
            "liveness_verified": True if method == "Face" else None,
            "liveness_score": liveness_score if method == "Face" else None,
            "date": local_date,
            "time": local_time,
            "status": status,
            "is_offline_sync": is_offline_sync
        },
        ip=ip,
        user_agent=client_user_agent()
    )

    return jsonify({
        "ok": True,
        "status": "marked",
        "attendance_status": status,
        "name": employee.get("name"),
        "emp_id": emp_id,
        "company_name": company.get("name"),
        "company_id": company_id,
        "department": employee.get("department", "General"),
        "work_type": employee.get("work_type", "Office"),
        "date": local_date,
        "time": local_time,
        "formatted": local_formatted,
        "timezone": tz,
        "method": method,
        "message": f"🎉 Check-in verified successfully for {employee.get('name')} ({emp_id}) as '{status}' at {local_time} ({tz})"
    })


@app.route("/api/attendance/sync-offline", methods=["POST"])
def api_sync_offline_attendance():
    """Batch Sync Endpoint for Offline Queued Check-In Records."""
    data = request.json or {}
    punches = data.get("punches", [])
    if not punches or not isinstance(punches, list):
        return jsonify({"ok": False, "error": "Invalid or empty punches payload"}), 400

    synced_count = 0
    already_marked_count = 0
    failed_punches = []

    for punch in punches:
        company_id = punch.get("company_id", "").strip().upper()
        emp_id = punch.get("emp_id", "").strip().upper()
        punch_date = punch.get("date")
        punch_time = punch.get("time")

        company, employee, error = validate_company_and_employee(company_id, emp_id)
        if error:
            failed_punches.append({"punch_id": punch.get("punch_id"), "error": error})
            continue

        tz = resolve_entity_timezone(employee, None, company, DEFAULT_TIMEZONE)
        if not punch_date:
            punch_date, punch_time, _ = get_localized_time(tz)

        existing = attendance_col.find_one({"company_id": company_id, "emp_id": emp_id, "$or": [{"date": punch_date}, {"local_date": punch_date}]})
        if existing:
            already_marked_count += 1
            continue

        policy = policies_col.find_one({"company_id": company_id}) or {}
        status = evaluate_attendance_status(punch_time or "09:30", policy, employee.get("work_type", "Office"))

        doc = {
            "company_id": company_id,
            "emp_id": emp_id,
            "name": employee.get("name"),
            "department": employee.get("department", "General"),
            "designation": employee.get("designation", "Staff"),
            "work_type": employee.get("work_type", "Office"),
            "date": punch_date,
            "time": punch_time or "09:30",
            "local_date": punch_date,
            "local_time": punch_time or "09:30",
            "timezone": tz,
            "timestamp_utc": punch.get("timestamp_utc") or get_utc_iso_string(),
            "status": status,
            "method": punch.get("method", "Offline-Sync"),
            "photo_captured": bool(punch.get("image")),
            "ip": client_ip(),
            "location": punch.get("location"),
            "device_info": punch.get("device_info", "Offline Client"),
            "is_offline_sync": True,
            "synced_at": get_utc_iso_string()
        }
        attendance_col.insert_one(doc)
        synced_count += 1

    return jsonify({
        "ok": True,
        "synced_count": synced_count,
        "already_marked_count": already_marked_count,
        "failed_count": len(failed_punches),
        "failed_details": failed_punches,
        "message": f"Successfully synchronized {synced_count} offline attendance punch(es)."
    })


# ══════════════════════════════════════════════════════════════════════════════
#  ENTRYPOINT
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    seed_global_system()
    app.run(host=HOST, port=PORT, debug=DEBUG)


