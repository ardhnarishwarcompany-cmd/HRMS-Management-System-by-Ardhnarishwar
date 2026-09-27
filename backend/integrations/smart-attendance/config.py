import os
from dotenv import load_dotenv

# Load .env if present
load_dotenv()

# Platform Metadata
PLATFORM_NAME = os.environ.get("PLATFORM_NAME", "Global Attendance Management System")
SUPER_ADMIN_COMPANY = os.environ.get("SUPER_ADMIN_COMPANY", "Global Attendance Enterprise")

# Initial Super Admin Bootstrap Credentials (Used ONLY if no Super Admin exists in DB)
SUPER_ADMIN_EMAIL = os.environ.get("SUPER_ADMIN_EMAIL", "superadmin@ardhnarishwar.com")
SUPER_ADMIN_MOBILE = os.environ.get("SUPER_ADMIN_MOBILE", "9999999999")
SUPER_ADMIN_PASS = os.environ.get("SUPER_ADMIN_PASS", "superadmin123")

# Database configuration
MONGO_URI = os.environ.get("MONGO_URI", "mongodb://localhost:27017/")
DATABASE_NAME = os.environ.get("DATABASE_NAME", "smart_attendance")

# Security & Session
SECRET_KEY = os.environ.get("SECRET_KEY", "ardhnarishwar_global_production_secret_2026_key")
SESSION_COOKIE_SECURE = os.environ.get("SESSION_COOKIE_SECURE", "False").lower() in ("true", "1")
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"

# Global Defaults
DEFAULT_TIMEZONE = os.environ.get("DEFAULT_TIMEZONE", "Asia/Kolkata")
OFFICE_LAT = float(os.environ.get("OFFICE_LAT", "28.626001"))
OFFICE_LNG = float(os.environ.get("OFFICE_LNG", "77.378001"))
OFFICE_RADIUS_M = float(os.environ.get("OFFICE_RADIUS", "50"))
OFFICE_SUBNET = os.environ.get("OFFICE_SUBNET", "192.168.29")

# Face Recognition Settings
FACE_MATCH_TOLERANCE = float(os.environ.get("FACE_MATCH_TOLERANCE", "0.5"))

# Server Run Settings
HOST = os.environ.get("HOST", "127.0.0.1")
PORT = int(os.environ.get("PORT", "5001"))
DEBUG = os.environ.get("DEBUG", "False").lower() in ("true", "1")

