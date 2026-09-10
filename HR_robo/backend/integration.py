"""HRMS Integration API — connects HR_robo (AI Interview Portal) to the main
Recruweb HRMS dashboards (HR Portal + Superadmin Portal).

Data flow (per requirement §11):  AI Interview Portal → HR Portal → Superadmin Portal

The interview runs in the browser (offline AI engine + proctoring), and after
each interview the portal POSTs a snapshot here. The main HRMS React apps
(HR dashboard, admin/superadmin dashboard) read these endpoints.
"""
from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import JSONResponse
from datetime import datetime
import hmac
import os, json, threading

from backend.videos import get_videos_index
from backend.auth import decode_token

integration_router = APIRouter()

# Shared secret for server-to-server pushes (set HRMS_SYNC_KEY in the env).
_SYNC_KEY = os.getenv("HRMS_SYNC_KEY", "")

if not _SYNC_KEY:
    print(
        "[HR_robo] WARNING: HRMS_SYNC_KEY env var is not set. "
        "Server-to-server /sync pushes (X-Sync-Key) are DISABLED - only "
        "logged-in portal users (Bearer JWT) can sync. Set HRMS_SYNC_KEY "
        "in production if any external service pushes snapshots."
    )


def _require_sync_auth(request: Request):
    """/sync must not be open to the world - it overwrites the whole store.

    Accepts EITHER:
      1. A valid HR_robo JWT (Authorization: Bearer <token>) - the interview
         portal user is already logged in, so reuse that session.
      2. The shared sync key (X-Sync-Key header) for server-to-server pushes.
    """
    auth_header = request.headers.get("authorization", "")
    if auth_header.lower().startswith("bearer "):
        token = auth_header.split(" ", 1)[1].strip()
        if decode_token(token):
            return

    sync_key = request.headers.get("x-sync-key", "")
    if _SYNC_KEY and sync_key and hmac.compare_digest(sync_key, _SYNC_KEY):
        return

    raise HTTPException(status_code=401, detail="Sync authentication required")

_STORE_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "integration_store.json")
_LOCK = threading.Lock()


def _load():
    if not os.path.exists(_STORE_PATH):
        return {"reports": [], "proctor_logs": [], "candidates": [], "schedules": [], "config": {}, "synced_at": None}
    try:
        with open(_STORE_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {"reports": [], "proctor_logs": [], "candidates": [], "schedules": [], "config": {}, "synced_at": None}


def _save(data):
    with _LOCK:
        with open(_STORE_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=1)


@integration_router.post("/sync")
async def sync_snapshot(request: Request):
    """Interview portal pushes its latest data snapshot after each interview."""
    _require_sync_auth(request)
    body = await request.json()
    store = _load()
    for key in ("reports", "proctor_logs", "candidates", "schedules", "config"):
        if key in body and body[key] is not None:
            store[key] = body[key]
    store["synced_at"] = datetime.utcnow().isoformat() + "Z"
    _save(store)
    return {"ok": True, "synced_at": store["synced_at"],
            "counts": {k: len(store[k]) for k in ("reports", "proctor_logs", "candidates", "schedules")}}


@integration_router.get("/summary")
async def summary():
    """Headline numbers for HRMS dashboard widgets."""
    s = _load()
    reports = s.get("reports", [])
    logs = s.get("proctor_logs", [])
    verdict_counts = {}
    for r in reports:
        v = (r.get("recommendation") or {}).get("verdict") or r.get("verdict") or "PENDING"
        verdict_counts[v] = verdict_counts.get(v, 0) + 1
    return {
        "synced_at": s.get("synced_at"),
        "total_interviews": len(reports),
        "total_candidates": len(s.get("candidates", [])),
        "scheduled": len([x for x in s.get("schedules", []) if x.get("status") == "scheduled"]),
        "terminated": len([l for l in logs if l.get("terminated")]),
        "avg_integrity": round(sum(l.get("integrity", 100) for l in logs) / len(logs), 1) if logs else None,
        "verdicts": verdict_counts,
    }


@integration_router.get("/reports")
async def get_reports():
    """Full interview reports for the HR dashboard (scores, assessment, recommendation)."""
    s = _load()
    return {"synced_at": s.get("synced_at"), "reports": s.get("reports", []),
            "candidates": s.get("candidates", []), "schedules": s.get("schedules", [])}


@integration_router.get("/proctor-logs")
async def get_proctor_logs():
    """Integrity/proctoring audit for the Superadmin dashboard.

    Each proctor log / candidate is enriched with interview recording info
    (has_video + video_url) when a recording exists in video_storage/.
    """
    s = _load()
    try:
        videos = get_videos_index()
    except Exception:
        videos = {}

    def _video_meta(cid):
        meta = videos.get(str(cid)) if cid is not None else None
        if not meta:
            return {"has_video": False, "video_url": None}
        return {
            "has_video": True,
            "video_url": "/api/videos/%s" % cid,
            "video_duration": meta.get("duration", 0),
            "video_size": meta.get("size", 0),
            "video_uploaded_at": meta.get("uploaded_at"),
        }

    proctor_logs = []
    for log in s.get("proctor_logs", []):
        entry = dict(log)
        entry.update(_video_meta(log.get("candidate_id")))
        proctor_logs.append(entry)

    candidates = []
    for c in s.get("candidates", []):
        entry = dict(c)
        entry.update(_video_meta(c.get("id")))
        candidates.append(entry)

    return {"synced_at": s.get("synced_at"), "proctor_logs": proctor_logs,
            "config": s.get("config", {}), "candidates": candidates}


@integration_router.get("/health")
async def integration_health():
    s = _load()
    return {"status": "ok", "module": "hrms-integration", "synced_at": s.get("synced_at")}
