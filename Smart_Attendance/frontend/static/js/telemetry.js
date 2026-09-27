/**
 * Ardhnarishwar Global SaaS — Enterprise Telemetry, Localization & Offline Check-In Vault
 * 
 * Capabilities:
 * 1. Dynamic Browser Localization & Dynamic Clock (Intl.DateTimeFormat)
 * 2. HTML5 High-Accuracy Geolocation with continuous watch & Geofence metering
 * 3. WebRTC Camera Lifecycle Management (Safe hardware mount, permission guard & clean track release)
 * 4. Offline Attendance Vault with LocalStorage / IndexedDB queue & auto-sync upon reconnect
 * 5. Dynamic QR / Security Code Scanner & In-App verification
 * 6. Synthetic Web Audio feedback chimes (Success, Error, Offline-Queued)
 */

class OfflineAttendanceVault {
  constructor() {
    this.STORAGE_KEY = 'ARDHNARISHWAR_OFFLINE_PUNCH_QUEUE_V2';
  }

  getQueue() {
    try {
      const raw = localStorage.getItem(this.STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch (e) {
      console.warn('[OfflineVault] Error reading queue from storage:', e);
      return [];
    }
  }

  saveQueue(queue) {
    try {
      localStorage.setItem(this.STORAGE_KEY, JSON.stringify(queue));
      this.updateQueueBadge();
    } catch (e) {
      console.error('[OfflineVault] Error persisting queue to storage:', e);
    }
  }

  enqueue(punchData) {
    const queue = this.getQueue();
    const punchId = `OFFLINE-${Date.now()}-${Math.random().toString(36).substr(2, 6).toUpperCase()}`;
    const payload = {
      punch_id: punchId,
      created_at: new Date().toISOString(),
      timestamp_utc: new Date().toISOString(),
      is_offline_sync: true,
      ...punchData
    };
    queue.push(payload);
    this.saveQueue(queue);
    console.log(`[OfflineVault] Queued offline punch (${punchId}) for ${payload.emp_id}. Total in queue: ${queue.length}`);
    return payload;
  }

  remove(punchId) {
    const queue = this.getQueue().filter(p => p.punch_id !== punchId);
    this.saveQueue(queue);
  }

  clear() {
    this.saveQueue([]);
  }

  updateQueueBadge() {
    const queue = this.getQueue();
    const badgeEl = document.getElementById('offline-queue-badge');
    const countEl = document.getElementById('offline-queue-count');
    
    if (badgeEl) {
      if (queue.length > 0) {
        badgeEl.style.display = 'inline-flex';
        badgeEl.className = 'badge badge-amber';
        badgeEl.innerHTML = `📦 <strong>${queue.length}</strong> Offline Punch(es) Queued`;
      } else {
        badgeEl.style.display = 'none';
      }
    }
    if (countEl) countEl.textContent = queue.length;
  }

  async syncWithServer() {
    const queue = this.getQueue();
    if (!queue || queue.length === 0) return { ok: true, synced: 0 };
    if (!navigator.onLine) {
      console.log('[OfflineVault] Device is currently offline. Skipping sync.');
      return { ok: false, error: 'Device is offline' };
    }

    console.log(`[OfflineVault] Initiating batch sync for ${queue.length} queued punch(es)...`);
    try {
      const res = await fetch('/api/attendance/sync-offline', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ punches: queue })
      });
      const data = await res.json();

      if (data.ok) {
        this.clear();
        console.log(`[OfflineVault] Batch sync complete! Synced: ${data.synced_count}, Already marked: ${data.already_marked_count}`);
        if (window.ArdhnarishwarTelemetry) {
          window.ArdhnarishwarTelemetry.playSuccessChime();
        }
        if (typeof showToast === 'function') {
          showToast(`📦 Synchronized ${data.synced_count} offline attendance record(s) to cloud!`, 'success');
        }
        return { ok: true, synced: data.synced_count, data: data };
      } else {
        console.error('[OfflineVault] Sync rejected by server:', data.error);
        return { ok: false, error: data.error };
      }
    } catch (err) {
      console.error('[OfflineVault] Network exception during sync:', err);
      return { ok: false, error: 'Network error during sync' };
    }
  }
}

class PlatformTelemetry {
  constructor() {
    this.userTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
    this.currentPosition = null;
    this.geoWatchId = null;
    this.cameraStream = null;
    this.isOnline = navigator.onLine;
    this.facingMode = 'user';
    this.vault = new OfflineAttendanceVault();
    this.subscribers = { time: [], geo: [], network: [] };

    this._initNetworkMonitoring();
    this._startClockTicker();
    setTimeout(() => this.vault.updateQueueBadge(), 200);
  }

  // ── Web Audio Chimes ───────────────────────────────────────────────────────
  playSuccessChime() {
    try {
      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = 'sine';
      osc.frequency.setValueAtTime(587.33, ctx.currentTime); // D5
      osc.frequency.exponentialRampToValueAtTime(880.00, ctx.currentTime + 0.15); // A5
      gain.gain.setValueAtTime(0.18, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.45);
      osc.start();
      osc.stop(ctx.currentTime + 0.45);
    } catch (e) {}
  }

  playOfflineQueuedChime() {
    try {
      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(440.00, ctx.currentTime); // A4
      osc.frequency.setValueAtTime(659.25, ctx.currentTime + 0.12); // E5
      gain.gain.setValueAtTime(0.15, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.35);
      osc.start();
      osc.stop(ctx.currentTime + 0.35);
    } catch (e) {}
  }

  playErrorChime() {
    try {
      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(220.00, ctx.currentTime);
      osc.frequency.setValueAtTime(160.00, ctx.currentTime + 0.12);
      gain.gain.setValueAtTime(0.12, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.35);
      osc.start();
      osc.stop(ctx.currentTime + 0.35);
    } catch (e) {}
  }

  // ── 1. Dynamic Local Time & Timezone Engine ────────────────────────────────
  getTimezoneInfo() {
    const now = new Date();
    const tzName = this.userTimezone;
    
    const offsetMin = -now.getTimezoneOffset();
    const sign = offsetMin >= 0 ? '+' : '-';
    const absMin = Math.abs(offsetMin);
    const hours = String(Math.floor(absMin / 60)).padStart(2, '0');
    const mins = String(absMin % 60).padStart(2, '0');
    const offsetStr = `UTC${sign}${hours}:${mins}`;

    const timeFormatter = new Intl.DateTimeFormat('en-US', {
      timeZone: tzName,
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true
    });

    const dateFormatter = new Intl.DateTimeFormat('en-US', {
      timeZone: tzName,
      weekday: 'short',
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });

    const utcFormatter = new Intl.DateTimeFormat('en-US', {
      timeZone: 'UTC',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false
    });

    return {
      timezone: tzName,
      offsetStr: offsetStr,
      localTime: timeFormatter.format(now),
      localDate: dateFormatter.format(now),
      utcTime: utcFormatter.format(now),
      isoTimestamp: now.toISOString(),
      rawDate: now
    };
  }

  _startClockTicker() {
    const updateAllClocks = () => {
      const info = this.getTimezoneInfo();

      const elLocalTime = document.getElementById('dynamic-local-time');
      if (elLocalTime) elLocalTime.textContent = info.localTime;

      const elLocalDate = document.getElementById('dynamic-local-date');
      if (elLocalDate) elLocalDate.textContent = info.localDate;

      const elTimezone = document.getElementById('dynamic-timezone-badge');
      if (elTimezone) elTimezone.textContent = `${info.timezone} (${info.offsetStr})`;

      const elUtcTime = document.getElementById('dynamic-utc-time');
      if (elUtcTime) elUtcTime.textContent = info.utcTime;

      const clockTimeEl = document.getElementById('clock-time');
      if (clockTimeEl) clockTimeEl.textContent = info.localTime;
      const clockTzEl = document.getElementById('clock-tz');
      if (clockTzEl) clockTzEl.textContent = info.timezone;

      this.subscribers.time.forEach(fn => fn(info));
    };

    setInterval(updateAllClocks, 1000);
    setTimeout(updateAllClocks, 10);
  }

  onTimeTick(fn) {
    if (typeof fn === 'function') this.subscribers.time.push(fn);
  }

  // ── 2. HTML5 Geolocation API & Geofencing ──────────────────────────────────
  async requestGPSPosition(options = {}) {
    const defaultOptions = {
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 5000,
      ...options
    };

    if (!navigator.geolocation) {
      return { ok: false, error: 'HTML5 Geolocation is not supported by your browser.' };
    }

    return new Promise((resolve) => {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          this.currentPosition = {
            lat: pos.coords.latitude,
            lng: pos.coords.longitude,
            accuracy: Math.round(pos.coords.accuracy),
            altitude: pos.coords.altitude,
            heading: pos.coords.heading,
            speed: pos.coords.speed,
            timestamp: pos.timestamp
          };

          this._updateGeoUI(this.currentPosition);
          this.subscribers.geo.forEach(fn => fn(this.currentPosition));
          resolve({ ok: true, coords: this.currentPosition });
        },
        (err) => {
          let msg = 'Unable to retrieve your location.';
          if (err.code === err.PERMISSION_DENIED) {
            msg = 'GPS Permission Denied: Please enable Location Access in your browser settings to mark attendance.';
          } else if (err.code === err.POSITION_UNAVAILABLE) {
            msg = 'Location Signal Unavailable: Please check your device GPS / Network connection.';
          } else if (err.code === err.TIMEOUT) {
            msg = 'Location Request Timed Out: GPS acquisition took too long.';
          }
          this._updateGeoUI({ error: msg });
          resolve({ ok: false, error: msg, code: err.code });
        },
        defaultOptions
      );
    });
  }

  startContinuousGPSWatch() {
    if (!navigator.geolocation || this.geoWatchId !== null) return;
    this.geoWatchId = navigator.geolocation.watchPosition(
      (pos) => {
        this.currentPosition = {
          lat: pos.coords.latitude,
          lng: pos.coords.longitude,
          accuracy: Math.round(pos.coords.accuracy),
          timestamp: pos.timestamp
        };
        this._updateGeoUI(this.currentPosition);
        this.subscribers.geo.forEach(fn => fn(this.currentPosition));
      },
      (err) => {
        console.warn('[GPS Watch Warning]', err.message);
      },
      { enableHighAccuracy: true, maximumAge: 10000 }
    );
  }

  stopContinuousGPSWatch() {
    if (this.geoWatchId !== null) {
      navigator.geolocation.clearWatch(this.geoWatchId);
      this.geoWatchId = null;
    }
  }

  _updateGeoUI(pos) {
    const pill = document.getElementById('telemetry-gps-pill');
    if (!pill) return;

    if (pos.error) {
      pill.className = 'telemetry-pill warning';
      pill.innerHTML = `<span>⚠️</span> <span>GPS: Offline / Denied</span>`;
    } else {
      pill.className = 'telemetry-pill active';
      const latFmt = `${Math.abs(pos.lat).toFixed(4)}° ${pos.lat >= 0 ? 'N' : 'S'}`;
      const lngFmt = `${Math.abs(pos.lng).toFixed(4)}° ${pos.lng >= 0 ? 'E' : 'W'}`;
      pill.innerHTML = `<span>📍</span> <span>${latFmt}, ${lngFmt} (±${pos.accuracy}m)</span>`;
    }
  }

  calculateDistanceMeters(lat1, lon1, lat2, lon2) {
    const R = 6371000;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.round(R * c);
  }

  // ── 3. WebRTC Camera Lifecycle Management & Hardening ─────────────────────
  isVirtualCameraDevice(label) {
    if (!label) return false;
    const lower = label.toLowerCase();
    const physicalIndicators = ['integrated', 'usb', 'facetime', 'camera', 'webcam', 'logitech', 'brio', 'lenovo', 'dell', 'hp', 'chicony', 'realtek', 'sunplus', 'hardware'];
    const virtualKeywords = [
      'obs-camera', 'obs virtual', 'obs studio', 'manycam', 'camtwist', 'fake webcam', 'fake cam',
      'droidcam', 'vysor', 'splitcam', 'ndi video', 'streamlabs-obs', 'screen-capture-recorder'
    ];
    const isVirtualTool = virtualKeywords.some(kw => lower.includes(kw));
    if (isVirtualTool) return true;
    if (lower.includes('virtual') && !physicalIndicators.some(p => lower.includes(p))) {
      return true;
    }
    return false;
  }

  async startCamera(videoElement, preferredFacing = 'user') {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      return { ok: false, error: 'WebRTC Camera API is not supported in this browser environment.' };
    }

    try {
      this.stopCamera(); // Clean up existing streams to prevent resource leaks
      this.facingMode = preferredFacing;

      // Strictly request physical camera with facingMode (prevent screen capture)
      const constraints = {
        video: {
          facingMode: preferredFacing,
          width: { ideal: 640 },
          height: { ideal: 480 }
        },
        audio: false
      };

      let stream;
      try {
        stream = await navigator.mediaDevices.getUserMedia(constraints);
      } catch (cErr) {
        stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
      }
      const videoTrack = stream.getVideoTracks()[0];

      // Security Check 1: Screen share / displaySurface check
      if (videoTrack && videoTrack.getSettings) {
        const settings = videoTrack.getSettings();
        if (settings.displaySurface) {
          this.stopCamera();
          return {
            ok: false,
            isVirtual: true,
            error: 'Security Alert: Screen sharing / display capture stream detected. Biometric attendance strictly requires an authentic physical camera.'
          };
        }
      }

      // Security Check 2: Virtual Camera Driver Detection (OBS, ManyCam, etc.)
      const deviceLabel = (videoTrack && videoTrack.label) ? videoTrack.label : '';
      if (this.isVirtualCameraDevice(deviceLabel)) {
        this.stopCamera();
        return {
          ok: false,
          isVirtual: true,
          deviceLabel: deviceLabel,
          error: `Security Alert: Virtual camera driver detected ("${deviceLabel}"). You must connect an authentic physical camera hardware device.`
        };
      }

      this.cameraStream = stream;
      this.activeDeviceLabel = deviceLabel || 'Physical Camera Device';

      if (videoElement) {
        videoElement.srcObject = stream;
        videoElement.setAttribute('playsinline', 'true');
        videoElement.muted = true;
        await videoElement.play();
      }
      return { ok: true, stream: stream, deviceLabel: this.activeDeviceLabel };
    } catch (err) {
      let msg = 'Failed to access camera device.';
      if (err.name === 'NotAllowedError' || err.name === 'PermissionDeniedError') {
        msg = 'Camera Access Denied: Please allow camera permissions in your browser address bar to enable photo verification.';
      } else if (err.name === 'NotFoundError' || err.name === 'DevicesNotFoundError') {
        msg = 'Camera Hardware Not Found: No video capture device is detected on your system.';
      } else if (err.name === 'NotReadableError') {
        msg = 'Camera In Use: Your camera is occupied by another application.';
      } else if (err.name === 'OverconstrainedError') {
        msg = 'Requested camera resolution is not supported by your hardware.';
      }
      return { ok: false, error: msg, rawError: err };
    }
  }

  toggleCameraFacing(videoElement) {
    const nextFacing = this.facingMode === 'user' ? 'environment' : 'user';
    return this.startCamera(videoElement, nextFacing);
  }

  stopCamera(videoElement) {
    if (this.cameraStream) {
      this.cameraStream.getTracks().forEach(track => {
        try {
          track.stop();
        } catch (e) {}
      });
      this.cameraStream = null;
    }
    if (videoElement && videoElement.srcObject) {
      videoElement.srcObject = null;
    }
  }

  // ── Liveness Telemetry & Mathematical Frequency Extraction ─────────────────
  extractLuminanceGrid(videoElement, width = 64, height = 64) {
    if (!videoElement || videoElement.videoWidth === 0) return null;
    try {
      const offscreen = document.createElement('canvas');
      offscreen.width = width;
      offscreen.height = height;
      const ctx = offscreen.getContext('2d');
      ctx.drawImage(videoElement, 0, 0, width, height);
      const imgData = ctx.getImageData(0, 0, width, height).data;
      const gray = new Uint8Array(width * height);
      for (let i = 0; i < width * height; i++) {
        const r = imgData[i * 4];
        const g = imgData[i * 4 + 1];
        const b = imgData[i * 4 + 2];
        gray[i] = Math.round(0.299 * r + 0.587 * g + 0.114 * b);
      }
      let binary = '';
      const len = gray.byteLength;
      for (let i = 0; i < len; i++) {
        binary += String.fromCharCode(gray[i]);
      }
      return btoa(binary);
    } catch (e) {
      return null;
    }
  }

  measureMotionDelta(grid1B64, grid2B64) {
    if (!grid1B64 || !grid2B64) return 0.2;
    try {
      const bin1 = atob(grid1B64);
      const bin2 = atob(grid2B64);
      const n = Math.min(bin1.length, bin2.length);
      if (n === 0) return 0.2;
      let totalDiff = 0;
      for (let i = 0; i < n; i++) {
        totalDiff += Math.abs(bin1.charCodeAt(i) - bin2.charCodeAt(i));
      }
      return totalDiff / (n * 255.0);
    } catch (e) {
      return 0.2;
    }
  }

  async requestLivenessChallenge(companyId, empId) {
    try {
      const res = await fetch('/api/attendance/liveness-challenge', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ company_id: companyId, emp_id: empId })
      });
      return await res.json();
    } catch (e) {
      return { ok: false, error: 'Failed to initiate secure liveness session: ' + e.message };
    }
  }

  captureFrameWithWatermark(videoElement, canvasElement, meta = {}) {
    if (!videoElement || videoElement.videoWidth === 0) {
      return { ok: false, error: 'Camera stream is not active or ready.' };
    }

    const width = videoElement.videoWidth || 640;
    const height = videoElement.videoHeight || 480;

    const canvas = canvasElement || document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');

    // Draw raw video frame
    ctx.drawImage(videoElement, 0, 0, width, height);

    // Draw anti-tamper watermark ribbon
    const tzInfo = this.getTimezoneInfo();
    const lat = meta.lat || (this.currentPosition ? this.currentPosition.lat : null);
    const lng = meta.lng || (this.currentPosition ? this.currentPosition.lng : null);
    const acc = meta.accuracy || (this.currentPosition ? this.currentPosition.accuracy : null);
    const empId = meta.empId || 'EMPLOYEE';
    const compId = meta.companyId || 'WORKSPACE';

    ctx.fillStyle = 'rgba(7, 11, 20, 0.82)';
    ctx.fillRect(0, height - 52, width, 52);

    ctx.strokeStyle = '#10B981';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(0, height - 52);
    ctx.lineTo(width, height - 52);
    ctx.stroke();

    ctx.fillStyle = '#FFFFFF';
    ctx.font = 'bold 12.5px "JetBrains Mono", monospace';
    ctx.fillText(`👤 ${compId}:${empId}  🕒 ${tzInfo.localDate} ${tzInfo.localTime} (${tzInfo.timezone})`, 12, height - 30);

    const geoText = (lat !== null && lng !== null)
      ? `📍 GPS: ${lat.toFixed(4)}, ${lng.toFixed(4)} (±${acc || 0}m) | ISO: ${tzInfo.isoTimestamp}`
      : `📍 GPS: Standard Signal | ISO: ${tzInfo.isoTimestamp}`;
    
    ctx.fillStyle = '#34D399';
    ctx.font = '11px "JetBrains Mono", monospace';
    ctx.fillText(geoText, 12, height - 12);

    const dataUrl = canvas.toDataURL('image/jpeg', 0.85);
    const lumGrid = this.extractLuminanceGrid(videoElement, 64, 64);

    return {
      ok: true,
      dataUrl: dataUrl,
      canvas: canvas,
      luminanceGrid: lumGrid,
      deviceLabel: this.activeDeviceLabel || 'Physical Camera',
      timestampIso: tzInfo.isoTimestamp,
      lat: lat,
      lng: lng,
      accuracy: acc,
      timezone: tzInfo.timezone
    };
  }

  // ── 4. Unified Authorized Check-In Flow (Online / Offline Resilient) ───────
  async executeCheckIn(payload) {
    const isOnline = navigator.onLine;
    const finalPayload = {
      ...payload,
      network_status: isOnline ? 'online' : 'offline',
      is_offline_sync: !isOnline,
      client_timestamp: new Date().toISOString()
    };

    if (!isOnline) {
      // Offline: Enqueue locally in vault
      const queued = this.vault.enqueue(finalPayload);
      this.playOfflineQueuedChime();
      return {
        ok: true,
        offline: true,
        status: 'offline_queued',
        punch_id: queued.punch_id,
        message: `⚡ Network is offline. Check-in queued locally (${queued.punch_id}). Will automatically synchronize to cloud once back online.`
      };
    }

    // Online: Submit to backend
    try {
      const res = await fetch('/api/attendance/check-in', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(finalPayload)
      });
      const data = await res.json();

      if (data.ok) {
        this.playSuccessChime();
        return { ok: true, offline: false, ...data };
      } else {
        this.playErrorChime();
        return { ok: false, offline: false, error: data.error || 'Check-in rejected by server', code: data.code };
      }
    } catch (networkErr) {
      console.warn('[Telemetry] Network error encountered during check-in, queuing offline:', networkErr);
      const queued = this.vault.enqueue(finalPayload);
      this.playOfflineQueuedChime();
      return {
        ok: true,
        offline: true,
        status: 'offline_queued',
        punch_id: queued.punch_id,
        message: `⚡ Connection interrupted. Check-in securely queued locally. Will sync automatically upon reconnection.`
      };
    }
  }

  // ── 5. Network Monitoring & Auto-Sync Listener ────────────────────────────
  _initNetworkMonitoring() {
    const updateNetworkBadge = () => {
      this.isOnline = navigator.onLine;
      const badge = document.getElementById('telemetry-network-pill');
      if (badge) {
        if (this.isOnline) {
          badge.className = 'telemetry-pill active';
          badge.innerHTML = `<span>🟢</span> <span>ONLINE</span>`;
        } else {
          badge.className = 'telemetry-pill warning';
          badge.innerHTML = `<span>🔴</span> <span>OFFLINE (Vault Active)</span>`;
        }
      }

      if (this.isOnline) {
        // Automatically sync queued punches when network returns
        this.vault.syncWithServer();
      }

      this.subscribers.network.forEach(fn => fn(this.isOnline));
    };

    window.addEventListener('online', updateNetworkBadge);
    window.addEventListener('offline', updateNetworkBadge);
    setTimeout(updateNetworkBadge, 100);
  }
}

// Global Singleton
window.ArdhnarishwarTelemetry = new PlatformTelemetry();
