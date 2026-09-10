import { useCallback, useEffect, useState } from "react";
import toast from "react-hot-toast";
import { Clock3, RefreshCw, ShieldCheck, Code2, Timer, Coffee } from "lucide-react";

import PageHeader from "../../components/common/PageHeader";
import { getShiftSettings, getITShiftTimings } from "../../services/attendanceService";

const EMPTY_SETTINGS = {
  shiftStartTime: "",
  shiftEndTime: "",
  lateThreshold: "",
  halfDayThreshold: "",
  autoPresentEnabled: false,
  autoAbsentEnabled: false,
  gracePeriod: "",
};

function normalizeSettings(response) {
  const payload = response?.data;
  const value = payload?.data || payload?.settings || payload;
  if (!value || typeof value !== "object" || Array.isArray(value)) return null;

  return {
    shiftStartTime: value.shiftStartTime ?? value.shift_start_time ?? "",
    shiftEndTime: value.shiftEndTime ?? value.shift_end_time ?? "",
    lateThreshold: value.lateThreshold ?? value.late_threshold ?? "",
    halfDayThreshold: value.halfDayThreshold ?? value.half_day_threshold ?? "",
    autoPresentEnabled: Boolean(value.autoPresentEnabled ?? value.auto_present_enabled ?? false),
    autoAbsentEnabled: Boolean(value.autoAbsentEnabled ?? value.auto_absent_enabled ?? false),
    gracePeriod: value.gracePeriod ?? value.grace_period ?? "",
  };
}

export default function ShiftTimings() {
  const [settings, setSettings] = useState(EMPTY_SETTINGS);
  const [loading, setLoading] = useState(true);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [itShifts, setItShifts] = useState([]);
  const [itShiftLoading, setItShiftLoading] = useState(true);

  const loadSettings = useCallback(async () => {
    setLoading(true);
    setItShiftLoading(true);
    try {
      const response = await getShiftSettings();
      const normalized = normalizeSettings(response);
      if (!normalized) throw new Error("Attendance settings response is empty");
      setSettings(normalized);
      setLastUpdated(new Date());
    } catch (error) {
      console.error("Attendance settings load failed:", error);
      setSettings(EMPTY_SETTINGS);
      toast.error(error?.response?.data?.message || "Unable to load actual attendance settings");
    } finally {
      setLoading(false);
    }

    try {
      const response = await getITShiftTimings();
      const payload = response?.data?.data || response?.data?.shifts || [];
      setItShifts(Array.isArray(payload) ? payload : []);
    } catch (error) {
      console.error("IT shift timings load failed:", error);
      setItShifts([]);
      toast.error(error?.response?.data?.message || "Unable to load IT Developer shift timings");
    } finally {
      setItShiftLoading(false);
    }
  }, []);

  useEffect(() => {
    loadSettings();
  }, [loadSettings]);

  const cards = [
    ["Shift Start", settings.shiftStartTime || "—", "Official attendance shift start time"],
    ["Shift End", settings.shiftEndTime || "—", "Official attendance shift end time"],
    ["Late Threshold", settings.lateThreshold !== "" ? `${settings.lateThreshold} min` : "—", "Minutes after shift start before late status"],
    ["Grace Period", settings.gracePeriod !== "" ? `${settings.gracePeriod} min` : "—", "Allowed grace period for attendance"],
    ["Half Day Threshold", settings.halfDayThreshold !== "" ? `${settings.halfDayThreshold} min` : "—", "Configured half-day attendance threshold"],
  ];

  return (
    <div>
      <PageHeader
        title="Shift Timings"
        desc="View the live shift and attendance automation settings used by the Admin attendance system."
        icon={Clock3}
        actions={
          <button
            type="button"
            onClick={loadSettings}
            disabled={loading}
            className="inline-flex items-center gap-2 rounded-xl bg-white/15 px-4 py-2.5 text-sm font-semibold text-white border border-white/20 hover:bg-white/20 disabled:opacity-60"
          >
            <RefreshCw size={16} className={loading ? "animate-spin" : ""} />
            Refresh
          </button>
        }
      />

      <div className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm mb-6">
        <div className="flex items-start gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600">
            <ShieldCheck size={20} />
          </div>
          <div>
            <h2 className="font-bold text-gray-900">Live attendance configuration</h2>
            <p className="mt-1 text-sm text-gray-500">
              These values are read directly from the attendance settings API. No dummy shift timings are used here.
            </p>
            {lastUpdated && (
              <p className="mt-1 text-xs text-gray-400">Last loaded: {lastUpdated.toLocaleString()}</p>
            )}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-5 md:grid-cols-2 xl:grid-cols-3">
        {cards.map(([label, value, description]) => (
          <div key={label} className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
            <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">{label}</p>
            <p className="mt-3 text-3xl font-bold text-gray-900">{loading ? "..." : value}</p>
            <p className="mt-2 text-sm text-gray-500">{description}</p>
          </div>
        ))}
      </div>

      <div className="mt-6 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
        <div className="flex items-start justify-between gap-4">
          <div className="flex items-start gap-3">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-violet-50 text-violet-600">
              <Code2 size={20} />
            </div>
            <div>
              <h2 className="text-lg font-bold text-gray-900">IT Developer Shift Timings</h2>
              <p className="mt-1 text-sm text-gray-500">
                Live shift timings added from the IT Developer attendance section. Admin sees the same shared shift configuration.
              </p>
            </div>
          </div>
          <span className="rounded-full bg-violet-50 px-3 py-1 text-xs font-semibold text-violet-700">
            {itShiftLoading ? "Loading..." : `${itShifts.length} shift${itShifts.length === 1 ? "" : "s"}`}
          </span>
        </div>

        {itShiftLoading ? (
          <div className="mt-5 rounded-xl bg-gray-50 p-5 text-sm text-gray-500">Loading IT Developer shift timings...</div>
        ) : itShifts.length === 0 ? (
          <div className="mt-5 rounded-xl border border-dashed border-gray-200 p-6 text-center text-sm text-gray-500">
            No IT Developer shift timings have been added yet.
          </div>
        ) : (
          <div className="mt-5 grid grid-cols-1 gap-4 lg:grid-cols-2">
            {itShifts.map((shift) => (
              <div key={shift.id} className="rounded-xl border border-gray-100 bg-gray-50 p-5">
                <div className="flex items-center justify-between gap-3">
                  <h3 className="font-bold text-gray-900">{shift.name || "Unnamed Shift"}</h3>
                  <Timer size={18} className="text-violet-600" />
                </div>
                <div className="mt-4 grid grid-cols-2 gap-3 text-sm">
                  <div className="rounded-lg bg-white p-3">
                    <p className="text-xs font-semibold uppercase tracking-wide text-gray-400">Check-in</p>
                    <p className="mt-1 font-semibold text-gray-800">{shift.checkInStart || "—"} – {shift.checkInEnd || "—"}</p>
                  </div>
                  <div className="rounded-lg bg-white p-3">
                    <p className="text-xs font-semibold uppercase tracking-wide text-gray-400">Check-out</p>
                    <p className="mt-1 font-semibold text-gray-800">{shift.checkOutStart || "—"} – {shift.checkOutEnd || "—"}</p>
                  </div>
                </div>
                <div className="mt-3 flex items-center gap-2 text-sm text-gray-500">
                  <Coffee size={15} /> Grace period: <span className="font-semibold text-gray-700">{shift.graceMinutes ?? 0} min</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="mt-6 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
        <h2 className="text-lg font-bold text-gray-900">Automation Rules</h2>
        <div className="mt-5 grid grid-cols-1 gap-4 md:grid-cols-2">
          <div className="rounded-xl border border-gray-100 bg-gray-50 p-4">
            <p className="text-sm font-semibold text-gray-700">Auto-Present</p>
            <p className={`mt-1 text-sm font-bold ${settings.autoPresentEnabled ? "text-green-600" : "text-gray-500"}`}>
              {loading ? "Loading..." : settings.autoPresentEnabled ? "Enabled" : "Disabled"}
            </p>
          </div>
          <div className="rounded-xl border border-gray-100 bg-gray-50 p-4">
            <p className="text-sm font-semibold text-gray-700">Auto-Absent</p>
            <p className={`mt-1 text-sm font-bold ${settings.autoAbsentEnabled ? "text-green-600" : "text-gray-500"}`}>
              {loading ? "Loading..." : settings.autoAbsentEnabled ? "Enabled" : "Disabled"}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
