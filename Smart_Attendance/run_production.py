"""
Global Attendance Management System — Production WSGI Launcher (Waitress)
High-performance multi-threaded production server runner.
"""
import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
backend_path = os.path.join(BASE_DIR, "backend")
sys.path.insert(0, backend_path)
os.chdir(backend_path)

from app import app, HOST, PORT, seed_global_system
from waitress import serve

if __name__ == "__main__":
    print(f"[*] Bootstrapping Global Attendance Management System Production Server...")
    seed_global_system()
    print(f"[*] Production Waitress WSGI server active on http://{HOST}:{PORT}")
    serve(app, host=HOST, port=PORT, threads=8)
