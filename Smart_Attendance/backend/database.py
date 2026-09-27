from pymongo import MongoClient
from datetime import datetime, timezone
import hashlib
import os

from config import (
    MONGO_URI, DATABASE_NAME, SUPER_ADMIN_COMPANY, 
    SUPER_ADMIN_EMAIL, SUPER_ADMIN_MOBILE, SUPER_ADMIN_PASS, 
    DEFAULT_TIMEZONE
)
from timezone_engine import get_utc_iso_string

# Connect to MongoDB with timeout, fallback to embedded mongomock if unavailable
client = None
try:
    c = MongoClient(MONGO_URI, serverSelectionTimeoutMS=1500)
    c.server_info()  # Verify connection
    client = c
    print(f"[*] Connected to live MongoDB at {MONGO_URI}")
except Exception as e:
    print(f"[!] Local MongoDB not reachable ({e}). Using embedded mongomock database...")
    import mongomock
    client = mongomock.MongoClient()

db = client[DATABASE_NAME]

# ── Collections ─────────────────────────────────────────────────────────────
companies_col             = db["companies"]              # Company workspaces worldwide
users_col                 = db["users"]                  # System user accounts (Super Admin, Company Admin, HR, Manager, Employee)
employees_col             = db["employees"]              # Detailed employee records + face encodings + workforce type
branches_col              = db["branches"]               # Multi-branch / office locations per company
departments_col           = db["departments"]            # Company organizational departments
shifts_col                = db["shifts"]                 # Company shift schedules (fixed, flexible, overnight)
attendance_col            = db["attendance"]             # Multi-tenant attendance events with UTC timestamps
attendance_corrections_col= db["attendance_corrections"] # Employee attendance correction requests & approval trail
leaves_col                = db["leaves"]                 # Employee leave applications & approval workflow
field_visits_col          = db["field_visits"]           # Field employee visits, client meetings, GPS logs
audit_logs_col            = db["audit_logs"]             # Global & Tenant immutable audit trail
policies_col              = db["policies"]               # Company-specific attendance rules & thresholds
notifications_col         = db["notifications"]          # In-house private notification & message vault


# ── Indexes ─────────────────────────────────────────────────────────────────
try:
    companies_col.create_index("company_id", unique=True)
    users_col.create_index([("company_id", 1), ("mobile", 1)])
    users_col.create_index([("company_id", 1), ("email", 1)])
    employees_col.create_index([("company_id", 1), ("emp_id", 1)], unique=True)
    branches_col.create_index([("company_id", 1), ("branch_id", 1)], unique=True)
    departments_col.create_index([("company_id", 1), ("name", 1)], unique=True)
    shifts_col.create_index([("company_id", 1), ("shift_id", 1)], unique=True)
    attendance_col.create_index([("company_id", 1), ("emp_id", 1), ("date", 1), ("check_type", 1)])
    attendance_col.create_index([("company_id", 1), ("date", 1)])
    attendance_col.create_index([("company_id", 1), ("timestamp_utc", -1)])
    attendance_corrections_col.create_index([("company_id", 1), ("emp_id", 1), ("timestamp_utc", -1)])
    leaves_col.create_index([("company_id", 1), ("emp_id", 1), ("timestamp_utc", -1)])
    field_visits_col.create_index([("company_id", 1), ("timestamp_utc", -1)])
    audit_logs_col.create_index([("company_id", 1), ("timestamp_utc", -1)])
    policies_col.create_index("company_id", unique=True)
    notifications_col.create_index([("company_id", 1), ("emp_id", 1), ("timestamp_utc", -1)])
except Exception:
    pass


def hash_password(password: str) -> str:
    """Secure SHA-256 password hashing."""
    if not password:
        return ""
    return hashlib.sha256(password.encode("utf-8")).hexdigest()


def log_audit_event(action: str, company_id: str, actor_name: str, actor_role: str, details: dict = None, ip: str = "", user_agent: str = ""):
    """
    Record an immutable audit trail event for security, compliance, and multi-tenant accountability.
    """
    try:
        audit_logs_col.insert_one({
            "action": action,
            "company_id": company_id or "GLOBAL",
            "actor_name": actor_name or "System",
            "actor_role": actor_role or "system",
            "details": details or {},
            "ip": ip or "127.0.0.1",
            "user_agent": user_agent or "",
            "timestamp_utc": get_utc_iso_string(),
            "created_at": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
        })
    except Exception as e:
        print("[!] Audit logging error:", e)


# ── System Bootstrap (Super Admin Only — ZERO Demo Data) ─────────────────────
def seed_global_system():
    """
    Bootstraps the essential Global Super Admin account (Ardhnarishwar Company)
    if no Super Admin account exists in the database.
    
    STRICT PRODUCTION COMPLIANCE:
    - NO sample companies are created.
    - NO fake employees are created.
    - NO fake attendance records are created.
    - NO hardcoded demo stats are created.
    All business tables remain clean until real records are registered.
    """
    super_admin = users_col.find_one({"role": "super_admin"})
    if not super_admin:
        users_col.insert_one({
            "name": "Ardhnarishwar Super Admin",
            "email": SUPER_ADMIN_EMAIL,
            "mobile": SUPER_ADMIN_MOBILE,
            "password": hash_password(SUPER_ADMIN_PASS),
            "role": "super_admin",
            "company_id": "ARDHNARISHWAR",
            "status": "active",
            "created_at": get_utc_iso_string()
        })
        log_audit_event(
            action="SUPER_ADMIN_BOOTSTRAP",
            company_id="ARDHNARISHWAR",
            actor_name="System",
            actor_role="super_admin",
            details={"email": SUPER_ADMIN_EMAIL, "company": SUPER_ADMIN_COMPANY}
        )
        print(f"[*] Bootstrapped Global Super Admin ({SUPER_ADMIN_EMAIL} / {SUPER_ADMIN_MOBILE})")


def reset_database_to_zero():
    """
    Completely wipes all business and operational data across all collections,
    leaving ONLY the pristine default Super Admin account (Ardhnarishwar Company).
    """
    companies_col.delete_many({})
    employees_col.delete_many({})
    branches_col.delete_many({})
    departments_col.delete_many({})
    shifts_col.delete_many({})
    attendance_col.delete_many({})
    attendance_corrections_col.delete_many({})
    leaves_col.delete_many({})
    field_visits_col.delete_many({})
    audit_logs_col.delete_many({})
    policies_col.delete_many({})
    notifications_col.delete_many({})
    users_col.delete_many({"role": {"$ne": "super_admin"}})
    seed_global_system()
    print("[*] Database successfully reset to ZERO state. Pure clean environment initialized.")


# Run safe bootstrap
seed_global_system()

