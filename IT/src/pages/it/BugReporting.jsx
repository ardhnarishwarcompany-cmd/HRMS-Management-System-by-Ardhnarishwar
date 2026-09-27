import { useCallback, useEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import { Bug, Plus, X, AlertOctagon, Wrench, CheckCircle2, RotateCcw, User2, FolderKanban, MoreVertical, Eye, Pencil, Trash2 } from "lucide-react";
import API from "../../api/axios";
import ITShell from "./ITShell";
import MagicCard, { MagicStat, MagicEmpty } from "../../components/common/MagicCard";

const SEVERITIES = ["Low", "Medium", "High", "Critical"];
const STATUSES = ["Open", "In Progress", "Fixed", "Closed", "Reopened"];

const SEV = {
  Low: { pill: "bg-gray-100 text-gray-600 ring-gray-200", glow: "100 116 139", bar: "bg-slate-300" },
  Medium: { pill: "bg-blue-50 text-blue-700 ring-blue-100", glow: "59 130 246", bar: "bg-blue-400" },
  High: { pill: "bg-amber-50 text-amber-700 ring-amber-100", glow: "245 158 11", bar: "bg-amber-400" },
  Critical: { pill: "bg-red-50 text-red-700 ring-red-100", glow: "239 68 68", bar: "bg-red-500" },
};

const STATUS_STYLE = {
  Open: "bg-red-50 text-red-700 border-red-100",
  Reopened: "bg-red-50 text-red-700 border-red-100",
  "In Progress": "bg-amber-50 text-amber-700 border-amber-100",
  Fixed: "bg-emerald-50 text-emerald-700 border-emerald-100",
  Closed: "bg-gray-100 text-gray-500 border-gray-200",
};

const FILTERS = ["All", "Open", "In Progress", "Fixed", "Closed"];
const EMPTY = { title: "", description: "", severity: "Medium", project: "", assigned_to: "" };

const initials = (n = "") =>
  String(n || "").split(" ").filter(Boolean).slice(0, 2).map((s) => s[0]?.toUpperCase()).join("") || "?";

const ago = (d) => {
  const diff = (Date.now() - new Date(d).getTime()) / 1000;
  if (diff < 60) return "just now";
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
  return `${Math.floor(diff / 86400)}d ago`;
};

export default function BugReporting() {
  const [rows, setRows] = useState([]);
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [saving, setSaving] = useState(false);
  const [filter, setFilter] = useState("All");
  const [form, setForm] = useState(EMPTY);
  const [editingBug, setEditingBug] = useState(null);
  const [viewBug, setViewBug] = useState(null);
  const [menuId, setMenuId] = useState(null);

  const fetchAll = useCallback(async () => {
    try {
      const [b, e] = await Promise.all([API.get("/it/bugs"), API.get("/it/employees")]);
      setRows(b.data || []);
      setEmployees(e.data || []);
    } catch {
      toast.error("Failed to load bugs");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchAll();
  }, [fetchAll]);

  const report = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await API.post("/it/bugs", { ...form, assigned_to: form.assigned_to || null });
      toast.success("Bug reported");
      setShowModal(false);
      setForm(EMPTY);
      fetchAll();
    } catch (err) {
      toast.error(err.response?.data?.message || "Failed to report bug");
    } finally {
      setSaving(false);
    }
  };

  const editBug = (row) => {
    setEditingBug(row);
    setForm({
      title: row.title || "",
      description: row.description || "",
      severity: row.severity || "Medium",
      project: row.project || "",
      assigned_to: row.assigned_to ? String(row.assigned_to) : "",
    });
    setShowModal(true);
    setMenuId(null);
  };

  const saveBug = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      if (editingBug) {
        await API.patch(`/it/bugs/${editingBug.id}`, {
          ...form,
          assigned_to: form.assigned_to || null,
        });
        toast.success("Bug updated");
      } else {
        await API.post("/it/bugs", {
          ...form,
          assigned_to: form.assigned_to || null,
        });
        toast.success("Bug reported");
      }

      setShowModal(false);
      setEditingBug(null);
      setForm(EMPTY);
      await fetchAll();
    } catch (err) {
      toast.error(err.response?.data?.message || "Failed to save bug");
    } finally {
      setSaving(false);
    }
  };

  const deleteBug = async (row) => {
    if (!row?.id) return;

    if (!window.confirm(`Delete bug "${row.title}"?`)) return;

    try {
      await API.delete(`/it/bugs/${row.id}`);
      toast.success("Bug deleted");
      setMenuId(null);
      setViewBug(null);
      await fetchAll();
    } catch (err) {
      toast.error(err.response?.data?.message || "Failed to delete bug");
    }
  };

  const setStatus = async (row, status) => {
    try {
      await API.patch(`/it/bugs/${row.id}/status`, { status });
      fetchAll();
    } catch {
      toast.error("Failed to update bug");
    }
  };

  const stats = useMemo(() => {
    const open = rows.filter((r) => ["Open", "Reopened"].includes(r.status)).length;
    const progress = rows.filter((r) => r.status === "In Progress").length;
    const fixed = rows.filter((r) => ["Fixed", "Closed"].includes(r.status)).length;
    const critical = rows.filter((r) => r.severity === "Critical" && !["Fixed", "Closed"].includes(r.status)).length;
    return { open, progress, fixed, critical };
  }, [rows]);

  const visible = useMemo(() => {
    const list = filter === "All" ? rows : rows.filter((r) => (filter === "Open" ? ["Open", "Reopened"].includes(r.status) : r.status === filter));
    const rank = { Critical: 0, High: 1, Medium: 2, Low: 3 };
    return [...list].sort((a, b) => (rank[a.severity] ?? 9) - (rank[b.severity] ?? 9) || new Date(b.updated_at) - new Date(a.updated_at));
  }, [rows, filter]);

  const openCount = stats.open + stats.progress;

  return (
    <ITShell
      title="Bug Reporting"
      subtitle={`${openCount} bug${openCount === 1 ? "" : "s"} currently open`}
      icon={Bug}
      action={
        <button
          onClick={() => { setEditingBug(null); setForm(EMPTY); setShowModal(true); }}
          className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-br from-rose-600 to-red-600 px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-red-500/25 transition hover:shadow-red-500/40 hover:-translate-y-0.5"
        >
          <Plus size={16} /> Report Bug
        </button>
      }
    >
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <MagicStat label="Open" value={stats.open} icon={Bug} glow="239 68 68" accent="text-red-600 bg-red-50" />
        <MagicStat label="In progress" value={stats.progress} icon={Wrench} glow="245 158 11" accent="text-amber-600 bg-amber-50" />
        <MagicStat label="Fixed / closed" value={stats.fixed} icon={CheckCircle2} glow="16 185 129" accent="text-emerald-600 bg-emerald-50" />
        <MagicStat
          label="Critical live"
          value={stats.critical}
          hint={stats.critical ? "Needs attention now" : "All clear"}
          icon={AlertOctagon}
          glow="220 38 38"
          accent={stats.critical ? "text-red-700 bg-red-100" : "text-emerald-600 bg-emerald-50"}
        />
      </div>

      {/* filter chips */}
      <div className="flex flex-wrap gap-2 mb-4">
        {FILTERS.map((f) => {
          const n = f === "All" ? rows.length : f === "Open" ? stats.open : rows.filter((r) => r.status === f).length;
          const active = filter === f;
          return (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`inline-flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-xs font-semibold transition ${
                active
                  ? "bg-gray-900 text-white shadow dark:bg-white dark:text-slate-900"
                  : "bg-white text-gray-600 border border-gray-200 hover:border-gray-300 dark:bg-slate-800 dark:text-slate-300 dark:border-slate-700"
              }`}
            >
              {f}
              <span className={`rounded-md px-1.5 text-[10px] tabular-nums ${active ? "bg-white/20" : "bg-gray-100 dark:bg-slate-700"}`}>{n}</span>
            </button>
          );
        })}
      </div>

      {loading ? (
        <div className="flex flex-col gap-3">
          {[0, 1, 2].map((i) => <div key={i} className="h-24 rounded-2xl bg-gray-100/70 animate-pulse" />)}
        </div>
      ) : visible.length === 0 ? (
        <MagicCard glow="16 185 129">
          <MagicEmpty
            icon={CheckCircle2}
            title={filter === "All" ? "No bugs reported. Great job!" : `No ${filter.toLowerCase()} bugs`}
            text="Reported bugs appear here and in the Super Admin IT Developer dashboard."
          />
        </MagicCard>
      ) : (
        <div className="flex flex-col gap-3">
          {visible.map((b, i) => {
            const sev = SEV[b.severity] || SEV.Medium;
            const closed = ["Fixed", "Closed"].includes(b.status);
            return (
              <MagicCard key={b.id} glow={sev.glow} className={`magic-rise ${closed ? "opacity-80" : ""}`} style={{ animationDelay: `${i * 40}ms` }}>
                <div className="flex">
                  {/* severity bar */}
                  <span className={`w-1 shrink-0 rounded-l-[15px] ${sev.bar}`} aria-hidden />
                  <div className="flex-1 p-4 flex flex-col sm:flex-row sm:items-center gap-4">
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className={`text-[11px] font-semibold px-2 py-0.5 rounded-full ring-1 ${sev.pill}`}>{b.severity}</span>
                        <span className={`text-[11px] font-semibold px-2 py-0.5 rounded-full border ${STATUS_STYLE[b.status]}`}>
                          {b.status === "Reopened" && <RotateCcw size={10} className="inline mr-1 -mt-0.5" />}
                          {b.status}
                        </span>
                        {b.project && (
                          <span className="inline-flex items-center gap-1 text-[11px] text-gray-400">
                            <FolderKanban size={11} /> {b.project}
                          </span>
                        )}
                        <span className="ml-auto text-[11px] text-gray-400">{ago(b.updated_at)}</span>
                      </div>
                      <p className={`mt-1.5 text-sm font-semibold text-gray-900 dark:text-white text-pretty ${closed ? "line-through decoration-gray-300" : ""}`}>
                        {b.title}
                      </p>
                      {b.description && <p className="mt-0.5 text-xs text-gray-500 dark:text-slate-400 line-clamp-2">{b.description}</p>}
                      <div className="mt-2.5 flex items-center gap-4 text-[11px] text-gray-500">
                        <span className="inline-flex items-center gap-1.5">
                          <span className="inline-flex h-5 w-5 items-center justify-center rounded-full bg-gray-100 text-[9px] font-bold text-gray-600 dark:bg-slate-700 dark:text-slate-200">
                            {initials(b.reported_by_name)}
                          </span>
                          reported by <span className="font-medium text-gray-700 dark:text-slate-200">{b.reported_by_name || "—"}</span>
                        </span>
                        <span className="inline-flex items-center gap-1.5">
                          <span className="inline-flex h-5 w-5 items-center justify-center rounded-full bg-gradient-to-br from-indigo-500 to-violet-500 text-[9px] font-bold text-white">
                            {b.assigned_to_name ? initials(b.assigned_to_name) : <User2 size={10} />}
                          </span>
                          <span className="font-medium text-gray-700 dark:text-slate-200">{b.assigned_to_name || "Unassigned"}</span>
                        </span>
                      </div>
                    </div>
                    <div className="relative flex shrink-0 items-center gap-2">
                      <select
                        value={b.status}
                        onChange={(e) => setStatus(b, e.target.value)}
                        aria-label={`Status of ${b.title}`}
                        className="rounded-xl border border-gray-200 bg-gray-50 px-3 py-2 text-xs font-medium text-gray-700 outline-none transition focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100 dark:bg-slate-900 dark:border-slate-700 dark:text-slate-200"
                      >
                        {STATUSES.map((s) => <option key={s}>{s}</option>)}
                      </select>

                      <button
                        type="button"
                        onClick={() => setMenuId(menuId === b.id ? null : b.id)}
                        className="grid h-9 w-9 place-items-center rounded-xl border border-gray-200 bg-white text-gray-500 hover:bg-indigo-50 hover:text-indigo-600 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-400"
                        title="More actions"
                      >
                        <MoreVertical size={17} />
                      </button>

                      {menuId === b.id && (
                        <div className="absolute right-0 top-11 z-50 w-40 overflow-hidden rounded-xl border border-gray-200 bg-white p-1.5 shadow-xl dark:border-slate-700 dark:bg-slate-900">
                          <button
                            type="button"
                            onClick={() => { setViewBug(b); setMenuId(null); }}
                            className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-700 dark:text-slate-200 dark:hover:bg-indigo-500/10"
                          >
                            <Eye size={15} /> View
                          </button>
                          <button
                            type="button"
                            onClick={() => editBug(b)}
                            className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-700 dark:text-slate-200 dark:hover:bg-indigo-500/10"
                          >
                            <Pencil size={15} /> Edit
                          </button>
                          <button
                            type="button"
                            onClick={() => deleteBug(b)}
                            className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm text-red-600 hover:bg-red-50 dark:text-red-300 dark:hover:bg-red-500/10"
                          >
                            <Trash2 size={15} /> Delete
                          </button>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </MagicCard>
            );
          })}
        </div>
      )}

      {viewBug && (
        <div
          className="fixed inset-0 z-[100] flex items-center justify-center bg-slate-950/60 p-4 backdrop-blur-sm"
          onClick={() => setViewBug(null)}
        >
          <div
            className="w-full max-w-2xl overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-2xl dark:border-slate-700 dark:bg-slate-900"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between border-b border-gray-100 px-6 py-5 dark:border-slate-800">
              <div>
                <p className="text-xs font-bold uppercase tracking-wider text-rose-500">Bug Report</p>
                <h2 className="mt-1 text-xl font-bold text-gray-900 dark:text-white">{viewBug.title}</h2>
              </div>
              <button
                type="button"
                onClick={() => setViewBug(null)}
                className="grid h-9 w-9 place-items-center rounded-xl text-gray-400 hover:bg-gray-100 dark:hover:bg-slate-800"
              >
                <X size={18} />
              </button>
            </div>

            <div className="max-h-[75vh] overflow-y-auto p-6">
              <div className="grid gap-3 sm:grid-cols-3">
                <div className="rounded-xl bg-gray-50 p-4 dark:bg-slate-800">
                  <p className="text-[10px] font-bold uppercase tracking-wider text-gray-400">Severity</p>
                  <p className="mt-1 text-sm font-bold">{viewBug.severity || "-"}</p>
                </div>
                <div className="rounded-xl bg-gray-50 p-4 dark:bg-slate-800">
                  <p className="text-[10px] font-bold uppercase tracking-wider text-gray-400">Status</p>
                  <p className="mt-1 text-sm font-bold">{viewBug.status || "-"}</p>
                </div>
                <div className="rounded-xl bg-gray-50 p-4 dark:bg-slate-800">
                  <p className="text-[10px] font-bold uppercase tracking-wider text-gray-400">Project</p>
                  <p className="mt-1 text-sm font-bold">{viewBug.project || "-"}</p>
                </div>
              </div>

              <div className="mt-5">
                <p className="mb-2 text-xs font-bold uppercase tracking-wider text-gray-400">Description</p>
                <div className="whitespace-pre-wrap rounded-xl border border-gray-200 bg-gray-50 p-5 text-sm leading-7 text-gray-700 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200">
                  {viewBug.description || "No description provided."}
                </div>
              </div>

              <div className="mt-5 grid gap-3 sm:grid-cols-2">
                <div className="rounded-xl border border-gray-100 p-4 dark:border-slate-700">
                  <p className="text-[10px] font-bold uppercase tracking-wider text-gray-400">Reported By</p>
                  <p className="mt-1 text-sm font-semibold">{viewBug.reported_by_name || "-"}</p>
                </div>
                <div className="rounded-xl border border-gray-100 p-4 dark:border-slate-700">
                  <p className="text-[10px] font-bold uppercase tracking-wider text-gray-400">Assigned To</p>
                  <p className="mt-1 text-sm font-semibold">{viewBug.assigned_to_name || "Unassigned"}</p>
                </div>
              </div>
            </div>

            <div className="flex justify-end border-t border-gray-100 bg-gray-50 px-6 py-4 dark:border-slate-800 dark:bg-slate-800/60">
              <button
                type="button"
                onClick={() => setViewBug(null)}
                className="rounded-xl bg-gray-900 px-5 py-2.5 text-sm font-semibold text-white hover:bg-gray-800"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4">
          <MagicCard glow="239 68 68" className="w-full max-w-md">
            <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100 dark:border-slate-800">
              <div>
                <h2 className="font-bold text-gray-900 dark:text-white">{editingBug ? "Edit Bug" : "Report a Bug"}</h2>
                <p className="text-xs text-gray-400">{editingBug ? "Update the existing bug details" : "Visible to the IT team and Super Admin"}</p>
              </div>
              <button onClick={() => setShowModal(false)} className="p-1.5 rounded-lg text-gray-400 hover:bg-gray-100 dark:hover:bg-slate-800" aria-label="Close">
                <X size={16} />
              </button>
            </div>
            <form onSubmit={saveBug} className="p-6 flex flex-col gap-4">
              <label className="flex flex-col gap-1.5">
                <span className="text-xs font-semibold text-gray-500">Title *</span>
                <input value={form.title} onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))} placeholder="Short, specific summary" className="input" required />
              </label>
              <label className="flex flex-col gap-1.5">
                <span className="text-xs font-semibold text-gray-500">Details</span>
                <textarea value={form.description} onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))} rows={3} placeholder="Steps to reproduce / expected vs actual" className="input" />
              </label>
              <div className="grid grid-cols-2 gap-4">
                <label className="flex flex-col gap-1.5">
                  <span className="text-xs font-semibold text-gray-500">Severity</span>
                  <div className="grid grid-cols-2 gap-1.5">
                    {SEVERITIES.map((s) => (
                      <button
                        type="button"
                        key={s}
                        onClick={() => setForm((f) => ({ ...f, severity: s }))}
                        className={`rounded-lg px-2 py-1.5 text-[11px] font-semibold ring-1 transition ${SEV[s].pill} ${form.severity === s ? "ring-2 ring-offset-1 ring-gray-900 dark:ring-white" : "opacity-70 hover:opacity-100"}`}
                      >
                        {s}
                      </button>
                    ))}
                  </div>
                </label>
                <label className="flex flex-col gap-1.5">
                  <span className="text-xs font-semibold text-gray-500">Project</span>
                  <input value={form.project} onChange={(e) => setForm((f) => ({ ...f, project: e.target.value }))} placeholder="HRMS" className="input" />
                </label>
              </div>
              <label className="flex flex-col gap-1.5">
                <span className="text-xs font-semibold text-gray-500">Assign to</span>
                <select value={form.assigned_to} onChange={(e) => setForm((f) => ({ ...f, assigned_to: e.target.value }))} className="input">
                  <option value="">Unassigned</option>
                  {employees.map((emp) => <option key={emp.id} value={emp.id}>{emp.name}</option>)}
                </select>
              </label>
              <div className="flex justify-end gap-2 pt-1">
                <button type="button" onClick={() => setShowModal(false)} className="px-4 py-2 rounded-xl text-sm text-gray-600 hover:bg-gray-100 dark:text-slate-300 dark:hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={saving} className="px-4 py-2 rounded-xl text-sm font-semibold bg-gradient-to-br from-rose-600 to-red-600 text-white shadow-md shadow-red-500/25 disabled:opacity-50">
                  {saving ? (editingBug ? "Saving..." : "Reporting...") : (editingBug ? "Save Changes" : "Report Bug")}
                </button>
              </div>
            </form>
          </MagicCard>
        </div>
      )}
    </ITShell>
  );
}
