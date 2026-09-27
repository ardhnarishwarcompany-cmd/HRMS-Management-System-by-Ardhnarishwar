import numpy as np
import cv2
import base64
import os
from database import employees_col

try:
    import face_recognition
    HAS_FACE_RECOGNITION = True
except ImportError:
    HAS_FACE_RECOGNITION = False

_cascade = None


def _get_cascade():
    global _cascade
    if _cascade is None:
        _cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    return _cascade


def _extract_opencv_embedding(face_crop):
    """Generate a 128-dimensional normalized feature embedding for a face crop."""
    if len(face_crop.shape) == 3:
        gray = cv2.cvtColor(face_crop, cv2.COLOR_BGR2GRAY)
    else:
        gray = face_crop
    resized = cv2.resize(gray, (64, 64))
    eq = cv2.equalizeHist(resized)
    dct = cv2.dct(np.float32(eq) / 255.0)
    feat = dct[:16, :8].flatten()
    norm = np.linalg.norm(feat)
    if norm > 0:
        feat = feat / norm
    return feat.tolist()


def _load_known(company_id: str = None):
    """Load face encodings from MongoDB filtered strictly by company_id."""
    query = {"status": "active"}
    if company_id:
        query["company_id"] = company_id
    
    docs = list(employees_col.find(query, {"emp_id": 1, "name": 1, "company_id": 1, "encoding": 1}))
    known_encs  = []
    known_names = []
    known_ids   = []
    known_companies = []

    for d in docs:
        enc = d.get("encoding")
        if enc:
            known_encs.append(np.array(enc, dtype=np.float32))
            known_names.append(d["name"])
            known_ids.append(d["emp_id"])
            known_companies.append(d.get("company_id", ""))
    return known_encs, known_names, known_ids, known_companies


def encode_face_from_b64(image_b64: str):
    """
    Accept base64 image from browser webcam.
    Returns (encoding_list, error_string)
    encoding_list is None on failure.
    """
    try:
        img_bytes = base64.b64decode(image_b64.split(",")[-1])
        np_arr    = np.frombuffer(img_bytes, np.uint8)
        frame     = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        if frame is None:
            return None, "Invalid image data received"

        if HAS_FACE_RECOGNITION:
            rgb  = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            locs = face_recognition.face_locations(rgb, model="hog")
            if not locs:
                return None, "No face detected. Please face the camera properly"
            encs = face_recognition.face_encodings(rgb, locs)
            if not encs:
                return None, "Failed to encode face. Please try again with good lighting"
            return encs[0].tolist(), None
        else:
            cascade = _get_cascade()
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=4, minSize=(30, 30))
            if len(faces) == 0:
                return None, "No face detected. Please face the camera properly"
            faces = sorted(faces, key=lambda f: f[2] * f[3], reverse=True)
            x, y, w, h = faces[0]
            face_crop = frame[y:y+h, x:x+w]
            encoding = _extract_opencv_embedding(face_crop)
            return encoding, None
    except Exception as e:
        return None, str(e)


def recognize_face_from_b64(image_b64: str, company_id: str = None, tolerance: float = 0.5):
    """
    Match face from base64 image against registered employees of the given company.
    Returns list of dicts: [{emp_id, name, company_id, distance}]
    """
    try:
        img_bytes = base64.b64decode(image_b64.split(",")[-1])
        np_arr    = np.frombuffer(img_bytes, np.uint8)
        frame     = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        if frame is None:
            return [], "Invalid image data"

        known_encs, known_names, known_ids, known_companies = _load_known(company_id=company_id)
        results = []

        if HAS_FACE_RECOGNITION:
            rgb  = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            locs = face_recognition.face_locations(rgb, model="hog")
            encs = face_recognition.face_encodings(rgb, locs)

            for enc in encs:
                if not known_encs:
                    results.append({"emp_id": "Unknown", "name": "Unknown", "distance": 1.0})
                    continue
                dists = face_recognition.face_distance(known_encs, enc)
                best  = int(np.argmin(dists))
                if dists[best] < tolerance:
                    results.append({
                        "emp_id":     known_ids[best],
                        "name":       known_names[best],
                        "company_id": known_companies[best],
                        "distance":   float(dists[best])
                    })
                else:
                    results.append({"emp_id": "Unknown", "name": "Unknown", "distance": float(dists[best])})
            return results, None
        else:
            cascade = _get_cascade()
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=4, minSize=(30, 30))
            if len(faces) == 0:
                return [], "No face detected in camera view"

            for (x, y, w, h) in faces:
                face_crop = frame[y:y+h, x:x+w]
                enc = np.array(_extract_opencv_embedding(face_crop), dtype=np.float32)
                if not known_encs:
                    results.append({"emp_id": "Unknown", "name": "Unknown", "distance": 1.0})
                    continue
                
                known_matrix = np.array(known_encs, dtype=np.float32)
                dot_prods = np.dot(known_matrix, enc)
                dists = np.clip(1.0 - dot_prods, 0.0, 1.0)
                best = int(np.argmin(dists))
                if dists[best] < tolerance:
                    results.append({
                        "emp_id":     known_ids[best],
                        "name":       known_names[best],
                        "company_id": known_companies[best],
                        "distance":   float(dists[best])
                    })
                else:
                    results.append({"emp_id": "Unknown", "name": "Unknown", "distance": float(dists[best])})
            return results, None
    except Exception as e:
        return [], str(e)
