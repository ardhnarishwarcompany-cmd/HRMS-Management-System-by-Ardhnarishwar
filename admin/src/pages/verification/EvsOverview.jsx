import { useEffect, useState } from "react";
import { ShieldCheck, RefreshCw, UserRound, GraduationCap, Landmark, BriefcaseBusiness } from "lucide-react";
import API from "../../services/api";

const EVS_APP = import.meta.env.VITE_EVS_APP_URL || "http://localhost:5180";

async function openEvsPortal() {
  try {
    const res = await API.get("/super-admin/evs/sso-url");
    window.open(res?.data?.url || EVS_APP, "_blank", "noopener,noreferrer");
  } catch { window.open(EVS_APP, "_blank", "noopener,noreferrer"); }
}

const tone = {
  Verified: "bg-emerald-50 text-emerald-700",
  Pending: "bg-amber-50 text-amber-700",
  Rejected: "bg-red-50 text-red-700",
  "Not Submitted": "bg-slate-100 text-slate-500",
  "In Progress": "bg-blue-50 text-blue-700",
};
const Pill = ({ value }) => <span className={`inline-block rounded-full px-2 py-0.5 text-[11px] font-bold ${tone[value] || tone["Not Submitted"]}`}>{value || "Not Submitted"}</span>;

export default function EvsOverview() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const load = async () => { setLoading(true); try { const r = await API.get("/verification/employee-overview"); setData(r.data); } catch {} finally { setLoading(false); } };
  useEffect(() => { load(); }, []);
  return <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
    <div className="mb-4 flex flex-wrap items-center gap-3"><div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-violet-600 to-indigo-700 text-white shadow-lg"><ShieldCheck size={20} /></div><div className="min-w-[220px] flex-1"><h2 className="text-base font-extrabold text-slate-900">Verification Status Matrix</h2><p className="text-xs text-slate-500">Identity, education, bank documents and background checks.</p></div><button onClick={load} className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-2 text-sm font-bold text-slate-700"><RefreshCw size={14} className={loading ? "animate-spin" : ""} /> Refresh</button><button onClick={openEvsPortal} className="rounded-lg bg-slate-900 px-4 py-2 text-sm font-bold text-white">Open Employee Portal</button></div>
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-4"><div className="rounded-xl border p-3"><UserRound size={16} className="text-violet-600" /><small className="mt-2 block text-[10px] font-bold uppercase text-slate-400">Employees</small><b className="text-xl">{data?.employees?.length || 0}</b></div><div className="rounded-xl border p-3"><GraduationCap size={16} className="text-violet-600" /><small className="mt-2 block text-[10px] font-bold uppercase text-slate-400">Education</small><b className="text-xl">{data?.education_completed || 0}</b></div><div className="rounded-xl border p-3"><Landmark size={16} className="text-violet-600" /><small className="mt-2 block text-[10px] font-bold uppercase text-slate-400">Bank Details</small><b className="text-xl">{data?.bank_completed || 0}</b></div><div className="rounded-xl border p-3"><BriefcaseBusiness size={16} className="text-violet-600" /><small className="mt-2 block text-[10px] font-bold uppercase text-slate-400">Background</small><b className="text-xl">{data?.background_verified || 0}</b></div></div>
    <div className="mt-4 max-h-[300px] overflow-auto rounded-xl border border-slate-100"><table className="min-w-[980px] w-full text-sm"><thead className="sticky top-0 z-10 bg-white text-left text-[11px] uppercase text-slate-500"><tr>{["Employee","Identity","Graduation","Post Graduation","Bank","Background","Overall"].map(h => <th key={h} className="px-3 py-2.5">{h}</th>)}</tr></thead><tbody>{(data?.employees || []).map(e => <tr key={e.id} className="border-t border-slate-50"><td className="px-3 py-2.5 font-bold">{e.name}<div className="text-[10px] font-normal text-slate-400">{e.department || "—"}</div></td><td className="px-3"><Pill value={e.identity_status} /></td><td className="px-3"><Pill value={e.graduation_status} /></td><td className="px-3"><Pill value={e.post_graduation_status} /></td><td className="px-3"><Pill value={e.bank_status} /></td><td className="px-3"><Pill value={e.background_status} /></td><td className="px-3"><Pill value={e.overall_status} /></td></tr>)}</tbody></table></div>
  </div>;
}
