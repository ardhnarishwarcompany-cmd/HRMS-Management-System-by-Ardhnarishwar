from datetime import datetime
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, joinedload

from ..core.database import get_db
from ..core.security import AuthenticatedIdentity, require_super_admin
from ..models import Candidate, InterviewSession

router = APIRouter(
    prefix="/api/integration",
    tags=["AI Platform Integration"],
)


def _diagnostics(session):
    data = session.system_diagnostics or {}
    return data if isinstance(data, dict) else {}


def _candidate_name(candidate):
    if not candidate:
        return "Unknown Candidate"
    return f"{candidate.first_name} {candidate.last_name}".strip()


def _violations(data):
    value = data.get("violations") or data.get("proctoring_violations") or []
    if isinstance(value, list):
        return [v for v in value if isinstance(v, dict)]

    flags = data.get("proctoring_flags")
    if isinstance(flags, int) and flags > 0:
        return [{
            "type": "PROCTORING_FLAG",
            "detail": f"{flags} proctoring flag(s) reported by candidate client",
        }]

    return []


def _events(data):
    value = data.get("events") or data.get("proctoring_events") or []
    if isinstance(value, list):
        return [v for v in value if isinstance(v, dict)]
    return []


def _integrity(data, violations):
    value = data.get("integrity")

    if isinstance(value, (int, float)):
        return max(0, min(100, round(float(value), 1)))

    value = data.get("integrity_score")

    if isinstance(value, (int, float)):
        return max(0, min(100, round(float(value), 1)))

    flags = data.get("proctoring_flags")

    if isinstance(flags, (int, float)):
        return max(0, min(100, round(100 - min(flags, 100), 1)))

    if violations:
        return max(0, 100 - min(len(violations) * 10, 100))

    return 100


def _face_consistency(data):
    value = (
        data.get("face_consistency")
        or data.get("faceConsistency")
        or data.get("face_check")
    )

    if value is not None:
        return value

    if data.get("webcam_active") is True:
        return "PASS"

    if data.get("webcam_active") is False:
        return "FAIL"

    return "—"

@router.get("/proctor-logs")
def get_proctor_logs(
    db: Session = Depends(get_db),
    current_user: AuthenticatedIdentity = Depends(require_super_admin),
):
    sessions = (
        db.query(InterviewSession)
        .options(
            joinedload(InterviewSession.candidate),
            joinedload(InterviewSession.job),
        )
        .order_by(InterviewSession.created_at.desc())
        .limit(500)
        .all()
    )

    logs = []
    candidates = {}

    for session in sessions:
        data = _diagnostics(session)
        violations = _violations(data)
        events = _events(data)
        candidate = session.candidate

        if candidate:
            candidates[session.candidate_id] = {
                "id": session.candidate_id,
                "name": _candidate_name(candidate),
                "email": candidate.email,
            }

        terminated = (
            str(session.status or "").upper() == "ABANDONED"
            or bool(data.get("terminated"))
            or bool(data.get("auto_terminated"))
        )

        has_video = bool(session.video_storage_path)

        logs.append({
            "session_id": session.id,
            "candidate_id": session.candidate_id,
            "integrity": _integrity(data, violations),
            "terminated": terminated,
            "face_consistency": _face_consistency(data),
            "violations": violations,
            "events": events,
            "has_video": has_video,
            "video_url": (
                f"/api/v1/recordings/{session.id}/presigned-url"
                if has_video else None
            ),
            "video_duration": data.get("video_duration") or data.get("duration_sec"),
            "video_uploaded_at": (
                session.completed_at.isoformat()
                if has_video and session.completed_at else None
            ),
            "at": (
                session.completed_at
                or session.started_at
                or session.created_at
            ).isoformat() if (
                session.completed_at
                or session.started_at
                or session.created_at
            ) else None,
            "status": session.status,
            "overall_score": (
                float(session.overall_score)
                if session.overall_score is not None else None
            ),
            "recommendation": session.recommendation,
        })

    return {
        "success": True,
        "proctor_logs": logs,
        "config": {
            "maxWarnings": 3,
            "gazeEnabled": True,
            "faceConsistency": True,
            "speakerDetection": True,
            "techMonitoring": True,
        },
        "candidates": list(candidates.values()),
        "synced_at": datetime.utcnow().isoformat(),
        "source": "interview_sessions.system_diagnostics",
    }


@router.get("/summary")
def get_integration_summary(
    db: Session = Depends(get_db),
    current_user: AuthenticatedIdentity = Depends(require_super_admin),
):
    sessions = (
        db.query(InterviewSession)
        .order_by(InterviewSession.created_at.desc())
        .limit(500)
        .all()
    )

    integrity_values = []
    terminated = 0
    candidates = set()

    for session in sessions:
        data = _diagnostics(session)
        violations = _violations(data)

        integrity_values.append(_integrity(data, violations))
        candidates.add(session.candidate_id)

        if (
            str(session.status or "").upper() == "ABANDONED"
            or bool(data.get("terminated"))
            or bool(data.get("auto_terminated"))
        ):
            terminated += 1

    return {
        "success": True,
        "avg_integrity": (
            round(sum(integrity_values) / len(integrity_values), 1)
            if integrity_values else None
        ),
        "terminated": terminated,
        "total_candidates": len(candidates),
        "total_sessions": len(sessions),
        "generated_at": datetime.utcnow().isoformat(),
    }
