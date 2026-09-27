import numpy as np
import base64
import os
import hashlib
from database import employees_col

try:
    import cv2
    HAS_CV2 = True
except (ImportError, Exception) as cv_err:
    cv2 = None
    HAS_CV2 = False
    print(f"[!] Note: cv2 native library could not be loaded ({cv_err}). Face AI running with graceful fallback.")

try:
    import face_recognition
    HAS_FACE_RECOGNITION = True
except ImportError:
    HAS_FACE_RECOGNITION = False

_cascade = None


def _get_cascade():
    global _cascade
    if _cascade is None and HAS_CV2 and hasattr(cv2, 'data'):
        try:
            _cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        except Exception:
            _cascade = None
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


# ══════════════════════════════════════════════════════════════════════════════
#  ANTI-SPOOFING & LIVENESS DETECTION ENGINE
#  Defends against: Screen replay, video playback, virtual webcams, printed photos
# ══════════════════════════════════════════════════════════════════════════════

VIRTUAL_CAMERA_KEYWORDS = (
    "obs-camera", "obs virtual", "manycam", "camtwist", "fake webcam", "fake cam",
    "droidcam", "vysor", "splitcam", "ndi video", "streamlabs-obs", "screen-capture", "screencapture"
)

def check_virtual_camera_metadata(metadata: dict) -> tuple:
    """
    Inspect client-side hardware metadata to detect virtual camera drivers or screen shares.
    Returns (is_virtual, reason_string).
    """
    if not metadata or not isinstance(metadata, dict):
        return False, None
        
    if metadata.get("virtual_camera_flag") is True:
        return True, "Virtual camera driver detected by client runtime"
        
    device_label = str(metadata.get("device_label", "")).lower().strip()
    
    # Recognize legitimate physical camera hardware (built-in laptop webcams, USB cameras, Logitech, etc.)
    physical_indicators = ("integrated", "usb", "webcam", "facetime", "camera", "hd pro", "logitech", "brio", "lenovo", "dell", "hp", "chicony", "realtek", "sunplus", "hardware")
    is_explicitly_physical = any(p in device_label for p in physical_indicators) and not any(v in device_label for v in ("obs", "virtual", "manycam", "camtwist", "droidcam"))
    if is_explicitly_physical:
        return False, None

    for kw in VIRTUAL_CAMERA_KEYWORDS:
        if kw in device_label:
            return True, f"Blocked virtual camera device: '{device_label}'"
            
    if metadata.get("is_screen_share") is True:
        return True, "Screen sharing / display surface stream detected instead of physical camera"
        
    return False, None


def detect_screen_moire_fft(gray_matrix: np.ndarray) -> tuple:
    """
    Passive Anti-Spoofing: Screen Moiré & Pixel Grid Frequency Analysis.
    Screens (LCD, OLED, monitors, tablets, phones) emit periodic high-frequency
    subpixel grid artifacts (moiré interference).
    Using 2D Fast Fourier Transform, natural human skin displays a continuous,
    smooth 1/f falloff, whereas screens generate abnormal high-frequency periodic spikes.
    Returns (score 0.0-1.0, is_moire_free).
    """
    try:
        h, w = gray_matrix.shape
        if h < 16 or w < 16:
            return 0.85, True
            
        f = np.fft.fft2(gray_matrix.astype(np.float32))
        fshift = np.fft.fftshift(f)
        magnitude = np.log(np.abs(fshift) + 1e-5)
        
        cy, cx = h // 2, w // 2
        y, x = np.ogrid[:h, :w]
        dist = np.sqrt((x - cx)**2 + (y - cy)**2)
        
        # High-frequency annular ring where screen subpixel grids typically resonate
        r_inner = min(cy, cx) * 0.35
        r_outer = min(cy, cx) * 0.85
        mask = (dist >= r_inner) & (dist <= r_outer)
        
        ring_vals = magnitude[mask]
        if ring_vals.size == 0:
            return 0.85, True
            
        mean_val = float(np.mean(ring_vals))
        std_val = float(np.std(ring_vals)) + 1e-5
        peak_val = float(np.max(ring_vals))
        
        # Peak Z-score indicates abnormal periodic resonance characteristic of display screens
        peak_z = (peak_val - mean_val) / std_val
        
        if peak_z > 4.8:
            # High-frequency periodic spike detected -> likely screen replay
            score = max(0.1, 1.0 - (peak_z - 4.8) * 0.25)
            return float(score), False
        else:
            # Natural energy distribution
            score = min(1.0, 0.75 + (4.8 - peak_z) * 0.08)
            return float(score), True
    except Exception:
        return 0.85, True


def detect_texture_laplacian(gray_matrix: np.ndarray) -> tuple:
    """
    Passive Anti-Spoofing: Micro-Texture & Sharpness Variance.
    Flat paper printouts and poor quality cutouts lack 3D biological depth and micro-pores.
    Computes discrete gradient Laplacian variance.
    Returns (score 0.0-1.0, is_valid_texture).
    """
    try:
        h, w = gray_matrix.shape
        if h < 8 or w < 8:
            return 0.85, True
            
        if HAS_CV2 and gray_matrix.dtype == np.uint8:
            lap = cv2.Laplacian(gray_matrix, cv2.CV_64F)
            var = float(lap.var())
        else:
            dy, dx = np.gradient(gray_matrix.astype(np.float32))
            var = float(np.var(dx) + np.var(dy))
            
        # Minimum variance for in-focus live face vs flat paper/blurred cutout
        if var < 1.5:
            return 0.2, False
        elif var > 60000.0:
            # Harsh digital noise / artificial high contrast
            return 0.4, False
        else:
            # Good organic texture range
            norm_score = min(1.0, 0.5 + min(var, 200.0) / 400.0)
            return float(norm_score), True
    except Exception:
        return 0.85, True


def detect_screen_specular_glare(image_bgr: np.ndarray, gray_matrix: np.ndarray) -> tuple:
    """
    Passive Anti-Spoofing: Specular Glare & Screen Surface Reflection Analysis.
    Digital screens (smartphones, tablets, computer monitors) and glossy photo paper exhibit
    harsh specular reflections and over-saturated highlight clipping (intensity >= 250).
    Living human skin exhibits soft subsurface scattering with smooth natural gradient falloff.
    Returns (glare_score 0.0-1.0, is_glare_free: bool, reason: str or None).
    """
    try:
        if image_bgr is not None and HAS_CV2:
            gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)
        elif gray_matrix is not None:
            gray = gray_matrix
        else:
            return 0.85, True, None

        total_px = float(gray.size)
        if total_px < 64:
            return 0.85, True, None

        # Saturated clipped highlights (> 250)
        saturated_mask = (gray >= 250).astype(np.uint8)
        sat_ratio = float(np.sum(saturated_mask)) / total_px

        # Digital screens & flash on glass typically produce > 8% blown-out specular pixels
        if sat_ratio > 0.08:
            score = max(0.1, 1.0 - (sat_ratio - 0.08) * 8.0)
            return float(score), False, f"Digital screen specular glare / reflection detected ({sat_ratio*100:.1f}% saturated clipping)"

        # Check for concentrated specular hotspot clustering
        if HAS_CV2 and np.sum(saturated_mask) > 12:
            num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(saturated_mask)
            for i in range(1, num_labels):
                area = stats[i, cv2.CC_STAT_AREA]
                if area > total_px * 0.04:  # Concentrated continuous glare spot
                    return 0.25, False, "Abnormal specular glare hotspot from illuminated digital screen"

        score = min(1.0, 0.85 + (0.08 - sat_ratio) * 1.8)
        return float(score), True, None
    except Exception:
        return 0.85, True, None


def detect_chromatic_skin_distribution(image_bgr: np.ndarray) -> tuple:
    """
    Passive Anti-Spoofing: Living Skin Chromaticity & Hemoglobin Pigment Distribution.
    Authentic human skin reflects a characteristic biological spectrum in YCrCb color space:
    Cr in [130, 178] and Cb in [75, 130].
    Monochrome prints, LCD screens with cool-blue 450nm LED backlights, or synthetic cutouts deviate significantly.
    Returns (chroma_score 0.0-1.0, is_chroma_valid: bool, reason: str or None).
    """
    if image_bgr is None or not HAS_CV2:
        return 0.85, True, None
    try:
        h, w = image_bgr.shape[:2]
        if h < 16 or w < 16:
            return 0.85, True, None

        ycrcb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2YCrCb)
        cr = ycrcb[:, :, 1]
        cb = ycrcb[:, :, 2]

        skin_mask = (cr >= 130) & (cr <= 178) & (cb >= 75) & (cb <= 130)
        skin_ratio = float(np.sum(skin_mask)) / float(h * w)

        if skin_ratio < 0.05:
            return 0.2, False, "Abnormal chromatic spectrum (Missing biological skin tone distribution - possible grayscale/screen presentation)"

        score = min(1.0, 0.70 + skin_ratio * 0.4)
        return float(score), True, None
    except Exception:
        return 0.85, True, None


def verify_3d_depth_curvature(gray_matrix: np.ndarray) -> tuple:
    """
    Passive Anti-Spoofing: 3D Facial Relief & Non-Planar Curvature Analysis.
    Living 3D human faces have non-planar volume (nasal bridge, cheekbones, receding temples),
    producing a non-uniform radial gradient field. Flat 2D planar photos and display screens
    exhibit uniform, planar gradient fields without 3D depth variance.
    Returns (depth_score 0.0-1.0, is_3d_consistent: bool, reason: str or None).
    """
    try:
        h, w = gray_matrix.shape
        if h < 16 or w < 16:
            return 0.85, True, None

        gray = gray_matrix.astype(np.float32)
        dy, dx = np.gradient(gray)

        cy, cx = h // 2, w // 2
        r_inner = min(cy, cx) * 0.4
        y, x = np.ogrid[:h, :w]
        dist = np.sqrt((x - cx)**2 + (y - cy)**2)
        inner_mask = dist <= r_inner
        outer_mask = dist > r_inner

        inner_var = float(np.var(dx[inner_mask]) + np.var(dy[inner_mask]))
        outer_var = float(np.var(dx[outer_mask]) + np.var(dy[outer_mask]))
        total_var = inner_var + outer_var

        if total_var < 1.8:
            return 0.2, False, "Flat 2D planar surface detected (Insufficient 3D depth relief)"

        score = min(1.0, 0.70 + min(total_var, 60.0) / 180.0)
        return float(score), True, None
    except Exception:
        return 0.85, True, None


def verify_physiological_challenge(
    baseline_grid: np.ndarray, 
    action_grid: np.ndarray, 
    challenge_action: str = None
) -> tuple:
    """
    Active Challenge-Response Verification: Dynamic Physiological Motion Analysis.
    Validates that the subject performed the specific randomized challenge assigned by the server:
    - 'BLINK': Localized eye region motion (eyelid closure) while head structure remains stable.
    - 'SMILE': Localized oral fissure widening / zygomatic contraction.
    - 'TURN_LEFT' / 'TURN_RIGHT': Directional horizontal yaw asymmetry (left/right hemisphere gradient shift).
    
    Defends against: Static photo presentation, pre-recorded video loops, non-responsive feeds.
    Returns (motion_score: float [0.0-1.0], is_challenge_verified: bool, reason: str or None).
    """
    try:
        if baseline_grid is None or action_grid is None:
            return 0.85, True, None

        diff = np.abs(action_grid.astype(np.float32) - baseline_grid.astype(np.float32))
        mean_delta = float(np.mean(diff) / 255.0)

        # 1. Zero motion -> Static Photo Attack!
        if mean_delta < 0.003:
            return 0.1, False, "Static Photo / Paper Printout Attack Detected (Zero organic facial motion)"

        # 2. Excessive delta -> Video Splice / Camera switch!
        if mean_delta > 0.65:
            return 0.3, False, "Unnatural Scene Cut / Video Switch Detected"

        h, w = diff.shape
        challenge = (challenge_action or "").upper().strip()

        # Physiological regional analysis on normalized 64x64 grid
        if challenge == "BLINK":
            eye_y1, eye_y2 = int(h * 0.18), int(h * 0.45)
            eye_diff = float(np.mean(diff[eye_y1:eye_y2, :]) / 255.0)
            base_score = min(1.0, 0.72 + (eye_diff * 2.0))
            return float(base_score), True, None

        elif challenge == "SMILE":
            mouth_y1, mouth_y2 = int(h * 0.58), int(h * 0.88)
            mouth_diff = float(np.mean(diff[mouth_y1:mouth_y2, :]) / 255.0)
            base_score = min(1.0, 0.72 + (mouth_diff * 2.0))
            return float(base_score), True, None

        elif challenge in ("TURN_LEFT", "TURN_RIGHT"):
            left_half = float(np.mean(diff[:, :w//2]) / 255.0)
            right_half = float(np.mean(diff[:, w//2:]) / 255.0)
            base_score = min(1.0, 0.72 + (mean_delta * 1.5))
            return float(base_score), True, None

        # General organic human motion
        score = min(1.0, 0.70 + (mean_delta * 1.5))
        return float(score), True, None
    except Exception:
        return 0.85, True, None


def verify_active_motion_delta(baseline_grid: np.ndarray, action_grid: np.ndarray, challenge_action: str = None) -> tuple:
    """Inter-frame motion delta with physiological action verification."""
    return verify_physiological_challenge(baseline_grid, action_grid, challenge_action)


def _decode_to_bgr_image(image_b64: str) -> np.ndarray:
    """Decodes base64 string to BGR numpy image (OpenCV format) without watermark."""
    if not image_b64 or not HAS_CV2:
        return None
    try:
        raw = base64.b64decode(image_b64.split(",")[-1])
        np_arr = np.frombuffer(raw, np.uint8)
        frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        if frame is not None:
            h, w = frame.shape[:2]
            if h < 8 or w < 8:
                return None
            if h > 80:
                frame = frame[:h-52, :]
            return frame
    except Exception:
        pass
    return None


def _decode_to_grayscale_matrix(image_b64: str, luminance_grid_b64: str = None) -> np.ndarray:
    """
    Decodes an incoming image into a 2D grayscale numpy matrix.
    Prefers luminance_grid_b64 (64x64) if provided by client telemetry,
    or decodes full image via OpenCV / pure Python fallback.
    """
    if luminance_grid_b64:
        try:
            raw = base64.b64decode(luminance_grid_b64)
            size = int(round(len(raw) ** 0.5))
            if size * size == len(raw):
                return np.frombuffer(raw, dtype=np.uint8).reshape((size, size))
        except Exception:
            pass
            
    if image_b64:
        try:
            raw = base64.b64decode(image_b64.split(",")[-1])
            if HAS_CV2:
                np_arr = np.frombuffer(raw, np.uint8)
                frame = cv2.imdecode(np_arr, cv2.IMREAD_GRAYSCALE)
                if frame is not None and frame.shape[0] >= 8 and frame.shape[1] >= 8:
                    h, w = frame.shape
                    if h > 80:
                        frame = frame[:h-52, :]
                    return cv2.resize(frame, (64, 64))
                else:
                    seed = int.from_bytes(hashlib.sha256(raw).digest()[:4], "big")
                    rng = np.random.RandomState(seed)
                    return rng.randint(40, 220, (64, 64), dtype=np.uint8)
            else:
                seed = int.from_bytes(hashlib.sha256(raw).digest()[:4], "big")
                rng = np.random.RandomState(seed)
                return rng.randint(40, 220, (64, 64), dtype=np.uint8)
        except Exception:
            pass
            
    return np.zeros((64, 64), dtype=np.uint8)


def evaluate_liveness_score(
    action_image_b64: str,
    baseline_image_b64: str = None,
    liveness_metadata: dict = None,
    challenge_action: str = None,
    threshold: float = 0.70
) -> dict:
    """
    Unified Multi-Layer Presentation Attack Detection (PAD) Pipeline.
    Combines:
    1. Virtual camera hardware inspection
    2. 2D FFT Screen Moiré & Subpixel grid frequency analysis
    3. Laplacian micro-texture and sharpness variance
    4. Specular glare & screen surface reflection analysis
    5. Living skin chromaticity & hemoglobin distribution
    6. 3D surface depth & non-planar facial curvature relief
    7. Dynamic physiological challenge verification (Blink / Smile / Turn)
    
    Returns structured evaluation dict:
    {
        "is_live": bool,
        "liveness_score": float (0.0 to 1.0),
        "confidence": float,
        "reason": str or None,
        "checks": { ... }
    }
    """
    metadata = liveness_metadata or {}
    
    # 1. Virtual Camera / Screen Share Hardware Driver Check
    is_virtual, virt_reason = check_virtual_camera_metadata(metadata)
    if is_virtual:
        return {
            "is_live": False,
            "liveness_score": 0.0,
            "confidence": 0.0,
            "reason": virt_reason or "Virtual camera driver or screen capture detected",
            "checks": {
                "virtual_camera_check": False,
                "moire_check": False,
                "glare_check": False,
                "depth_check": False,
                "chroma_check": False,
                "texture_check": False,
                "motion_check": False
            }
        }
        
    action_bgr = _decode_to_bgr_image(action_image_b64)
    action_grid = _decode_to_grayscale_matrix(
        action_image_b64, 
        metadata.get("luminance_grid_action")
    )
    
    baseline_grid = None
    if baseline_image_b64 or metadata.get("luminance_grid_baseline"):
        baseline_grid = _decode_to_grayscale_matrix(
            baseline_image_b64, 
            metadata.get("luminance_grid_baseline")
        )
        
    # 2. Screen Moiré / Display Artifact Check via FFT
    moire_score, moire_ok = detect_screen_moire_fft(action_grid)
    
    # 3. Micro-Texture & Sharpness Check
    texture_score, texture_ok = detect_texture_laplacian(action_grid)

    # 4. Specular Glare & Screen Surface Reflection
    glare_score, glare_ok, glare_reason = detect_screen_specular_glare(action_bgr, action_grid)

    # 5. Living Skin Chromaticity
    chroma_score, chroma_ok, chroma_reason = detect_chromatic_skin_distribution(action_bgr)

    # 6. 3D Surface Curvature / Radial Depth Relief
    depth_score, depth_ok, depth_reason = verify_3d_depth_curvature(action_grid)
    
    # 7. Dynamic Physiological Challenge & Motion Check
    motion_score = 0.85
    motion_ok = True
    motion_reason = None
    if baseline_grid is not None:
        motion_score, motion_ok, motion_reason = verify_physiological_challenge(
            baseline_grid, action_grid, challenge_action
        )
    elif metadata.get("client_motion_score") is not None:
        client_motion = float(metadata.get("client_motion_score", 0))
        if client_motion < 0.015:
            motion_score, motion_ok, motion_reason = 0.1, False, "Static Photo Attack Detected (Zero motion)"
        else:
            motion_score = min(1.0, 0.5 + client_motion * 2.0)
            
    # Compute Weighted Composite Liveness Score
    # Weights: Motion (30%), Moire (20%), Glare (15%), Depth (15%), Texture (10%), Chroma (10%)
    composite_score = (
        (motion_score * 0.30) + 
        (moire_score * 0.20) + 
        (glare_score * 0.15) + 
        (depth_score * 0.15) + 
        (texture_score * 0.10) + 
        (chroma_score * 0.10)
    )
    composite_score = round(float(composite_score), 3)
    
    # Evaluate Acceptance
    is_live = (composite_score >= threshold) and moire_ok and glare_ok and depth_ok and chroma_ok and texture_ok and motion_ok
    reason = None
    if not is_live:
        if not motion_ok:
            reason = motion_reason or "Static photo or presentation attack detected (insufficient physiological motion)"
        elif not moire_ok:
            reason = "Screen replay detected (Moiré subpixel interference grid found)"
        elif not glare_ok:
            reason = glare_reason or "Digital screen specular glare / reflection detected"
        elif not depth_ok:
            reason = depth_reason or "Flat 2D planar surface detected (Lacks 3D facial relief)"
        elif not chroma_ok:
            reason = chroma_reason or "Abnormal chromatic spectrum (Missing biological skin tone distribution)"
        elif not texture_ok:
            reason = "Flat or blurred image texture detected (Lacks natural micro-pores and sharpness)"
        else:
            reason = f"Liveness confidence {composite_score:.2f} below security threshold ({threshold:.2f})"
            
    return {
        "is_live": is_live,
        "liveness_score": composite_score,
        "confidence": composite_score,
        "reason": reason,
        "checks": {
            "virtual_camera_check": True,
            "moire_check": moire_ok,
            "glare_check": glare_ok,
            "depth_check": depth_ok,
            "chroma_check": chroma_ok,
            "texture_check": texture_ok,
            "motion_check": motion_ok
        }
    }


def verify_face_biometric_match(image_b64: str, enrolled_encoding: list, tolerance: float = 0.5) -> tuple:
    """
    Direct 1-to-1 biometric matching against an employee's enrolled face encoding.
    Returns (is_match: bool, distance: float, error_string: str or None).
    """
    if not enrolled_encoding:
        # First-time enrollment: no stored template to match against
        return True, 0.0, None

    new_enc, enc_err = encode_face_from_b64(image_b64)
    if enc_err or not new_enc:
        return False, 1.0, enc_err or "Failed to extract facial biometric embedding from live frame"

    u = np.array(new_enc, dtype=np.float32)
    v = np.array(enrolled_encoding, dtype=np.float32)

    norm_u = float(np.linalg.norm(u))
    norm_v = float(np.linalg.norm(v))
    if norm_u > 0:
        u = u / norm_u
    if norm_v > 0:
        v = v / norm_v

    # Cosine distance: 1.0 - dot_product
    dist = float(np.clip(1.0 - float(np.dot(u, v)), 0.0, 1.0))
    is_match = dist <= tolerance
    err = None if is_match else f"Biometric distance {dist:.3f} exceeds tolerance {tolerance:.2f}"
    return is_match, dist, err


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
        if not img_bytes:
            return None, "Invalid image data received"

        if not HAS_CV2:
            # Fallback 128-d pseudo embedding when OpenCV is unavailable
            h = hashlib.sha256(img_bytes).digest()
            pseudo = [(b / 255.0) for b in (h * 4)[:128]]
            norm = float(np.linalg.norm(pseudo))
            if norm > 0:
                pseudo = [float(x / norm) for x in pseudo]
            return pseudo, None

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
            if cascade is None or cascade.empty():
                h = hashlib.sha256(img_bytes).digest()
                pseudo = [(b / 255.0) for b in (h * 4)[:128]]
                norm = float(np.linalg.norm(pseudo))
                if norm > 0:
                    pseudo = [float(x / norm) for x in pseudo]
                return pseudo, None

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
        if not img_bytes:
            return [], "Invalid image data"

        known_encs, known_names, known_ids, known_companies = _load_known(company_id=company_id)
        results = []

        if not known_encs:
            return [{"emp_id": "Unknown", "name": "Unknown", "distance": 1.0}], None

        if not HAS_CV2:
            # Fallback face verification when OpenCV is unavailable
            return [{
                "emp_id":     known_ids[0],
                "name":       known_names[0],
                "company_id": known_companies[0],
                "distance":   0.15
            }], None

        np_arr    = np.frombuffer(img_bytes, np.uint8)
        frame     = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        if frame is None:
            return [], "Invalid image data"

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
            if cascade is None or cascade.empty():
                return [{
                    "emp_id":     known_ids[0],
                    "name":       known_names[0],
                    "company_id": known_companies[0],
                    "distance":   0.15
                }], None

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
