"""
Global Attendance Management System — Local Web Launcher (Waitress WSGI)
High-performance multi-threaded server runner on port 5001.
"""
import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
backend_path = os.path.join(BASE_DIR, "backend")
sys.path.insert(0, backend_path)
os.chdir(backend_path)

try:
    from app import app, seed_global_system
except ImportError:
    from backend.app import app, seed_global_system
from waitress import serve

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "5001"))
    host = os.environ.get("HOST", "127.0.0.1")
    print(f"[*] Bootstrapping Global Attendance Management System...")
    seed_global_system()
    print(f"[*] Smart Attendance application active on http://{host}:{port}")
    serve(app, host=host, port=port, threads=8)
