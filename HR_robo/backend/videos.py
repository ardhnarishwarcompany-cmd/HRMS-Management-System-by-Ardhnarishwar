"""Interview Recording Videos API — stores candidate interview recordings
uploaded from the browser so the Superadmin dashboard (AI Platform Audit)
can play them back.

Data flow:  candidate browser (MediaRecorder blob)
              → POST /api/videos/upload/{candidate_id}   (raw video body)
              → saved into video_storage/video/          (settings.VIDEO_DIR)
              → GET  /api/videos                         (index for dashboards)
              → GET  /api/videos/{candidate_id}          (stream for playback)
"""
from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import StreamingResponse, Response
from datetime import datetime
import os, json, threading, re

videos_router = APIRouter()

# HR_robo project root (parent of backend/) — same convention as integration.py
_BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VIDEO_DIR = os.path.join(_BASE_DIR, "video_storage", "video")
_INDEX_PATH = os.path.join(_BASE_DIR, "video_storage", "videos_index.json")
_LOCK = threading.Lock()

MAX_VIDEO_BYTES = 500 * 1024 * 1024  # 500 MB hard cap

_MIME_EXT = {
    "video/webm": "webm",
    "video/mp4": "mp4",
    "video/x-matroska": "mkv",
    "video/ogg": "ogv",
}


def _ext_for(mime: str) -> str:
    base = (mime or "").split(";")[0].strip().lower()
    return _MIME_EXT.get(base, "webm")


def _load_index() -> dict:
    if not os.path.exists(_INDEX_PATH):
        return {}
    try:
        with open(_INDEX_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def _save_index(index: dict) -> None:
    os.makedirs(os.path.dirname(_INDEX_PATH), exist_ok=True)
    with open(_INDEX_PATH, "w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False, indent=1)


def get_videos_index() -> dict:
    """Public helper (used by integration.py) — candidate_id(str) -> video meta.
    Only returns entries whose file still exists on disk."""
    index = _load_index()
    valid = {}
    for cid, meta in index.items():
        fname = meta.get("file") or ""
        # never allow path escape from the index file
        if fname and os.path.basename(fname) == fname and os.path.exists(os.path.join(VIDEO_DIR, fname)):
            valid[cid] = meta
    return valid


@videos_router.post("/upload/{candidate_id}")
async def upload_video(candidate_id: int, request: Request):
    """Receive the raw recording blob for a candidate.
    Body: the video bytes.  Query params: mime, duration (sec), name."""
    if candidate_id <= 0:
        raise HTTPException(status_code=400, detail="Invalid candidate id")

    mime = request.query_params.get("mime", "video/webm")
    try:
        duration = int(float(request.query_params.get("duration", 0)))
    except (TypeError, ValueError):
        duration = 0
    cand_name = request.query_params.get("name", "")[:120]

    body = await request.body()
    if not body:
        raise HTTPException(status_code=400, detail="Empty video body")
    if len(body) > MAX_VIDEO_BYTES:
        raise HTTPException(status_code=413, detail="Video too large (max 500MB)")

    os.makedirs(VIDEO_DIR, exist_ok=True)
    ext = _ext_for(mime)
    filename = "candidate_%d.%s" % (candidate_id, ext)
    filepath = os.path.join(VIDEO_DIR, filename)

    with _LOCK:
        # write atomically: temp file then replace, so a half-written upload
        # never corrupts an existing good recording
        tmp_path = filepath + ".tmp"
        with open(tmp_path, "wb") as f:
            f.write(body)
        os.replace(tmp_path, filepath)

        # remove stale files with a different extension for this candidate
        for other_ext in _MIME_EXT.values():
            if other_ext == ext:
                continue
            stale = os.path.join(VIDEO_DIR, "candidate_%d.%s" % (candidate_id, other_ext))
            if os.path.exists(stale):
                try:
                    os.remove(stale)
                except OSError:
                    pass

        index = _load_index()
        index[str(candidate_id)] = {
            "candidate_id": candidate_id,
            "candidate_name": cand_name,
            "file": filename,
            "mime": (mime or "video/webm").split(";")[0].strip(),
            "duration": duration,
            "size": len(body),
            "uploaded_at": datetime.utcnow().isoformat() + "Z",
        }
        _save_index(index)

    return {
        "ok": True,
        "candidate_id": candidate_id,
        "size": len(body),
        "duration": duration,
        "url": "/api/videos/%d" % candidate_id,
    }


@videos_router.get("")
async def list_videos():
    """Index of all stored recordings — consumed by the Superadmin dashboard."""
    return {"videos": get_videos_index()}


def _iter_file(path: str, start: int, end: int, chunk_size: int = 1024 * 1024):
    """Yield the byte range [start, end] of a file in chunks."""
    with open(path, "rb") as f:
        f.seek(start)
        remaining = end - start + 1
        while remaining > 0:
            data = f.read(min(chunk_size, remaining))
            if not data:
                break
            remaining -= len(data)
            yield data


@videos_router.get("/{candidate_id}")
async def get_video(candidate_id: int, request: Request):
    """Stream a candidate's interview recording for playback.

    Supports HTTP Range requests (206 Partial Content) — required by browser
    <video> elements: Chrome sends `Range: bytes=0-` and stalls at a black
    frame if the server ignores it while advertising Accept-Ranges."""
    index = _load_index()
    meta = index.get(str(candidate_id))
    if not meta:
        raise HTTPException(status_code=404, detail="No recording for this candidate")
    fname = meta.get("file") or ""
    # defense: only serve plain filenames from inside VIDEO_DIR
    if not fname or os.path.basename(fname) != fname or not re.match(r"^[\w.\-]+$", fname):
        raise HTTPException(status_code=404, detail="Recording not found")
    filepath = os.path.join(VIDEO_DIR, fname)
    if not os.path.exists(filepath):
        raise HTTPException(status_code=404, detail="Recording file missing")

    file_size = os.path.getsize(filepath)
    mime = meta.get("mime", "video/webm")
    range_header = request.headers.get("range")

    if range_header:
        m = re.match(r"bytes=(\d*)-(\d*)", range_header.strip())
        if m and (m.group(1) or m.group(2)):
            if m.group(1):
                start = int(m.group(1))
                end = int(m.group(2)) if m.group(2) else file_size - 1
            else:
                # suffix range: last N bytes
                length = int(m.group(2))
                start = max(0, file_size - length)
                end = file_size - 1
            end = min(end, file_size - 1)
            if start > end or start >= file_size:
                return Response(
                    status_code=416,
                    headers={"Content-Range": "bytes */%d" % file_size},
                )
            return StreamingResponse(
                _iter_file(filepath, start, end),
                status_code=206,
                media_type=mime,
                headers={
                    "Content-Range": "bytes %d-%d/%d" % (start, end, file_size),
                    "Content-Length": str(end - start + 1),
                    "Accept-Ranges": "bytes",
                    "Cache-Control": "no-store",
                },
            )

    return StreamingResponse(
        _iter_file(filepath, 0, file_size - 1),
        media_type=mime,
        headers={
            "Content-Length": str(file_size),
            "Accept-Ranges": "bytes",
            "Cache-Control": "no-store",
        },
    )
