import { useCallback, useEffect, useMemo, useState } from "react";
import axios from "axios";
import toast from "react-hot-toast";
import {
  BarChart3, Users, PhoneCall, UserPlus, Handshake, Receipt, ClipboardCheck,
  Target, TrendingUp, Package, BriefcaseBusiness, RefreshCw, Download,
  Search, CheckCircle2, Clock3, XCircle
} from "lucide-react";

const BASE_URL = import.meta.env.VITE_API_BASE_URL;
const tabs = [
  ["sales", "Sales", BarChart3], ["leads", "Leads", UserPlus], ["calls", "Calls", PhoneCall],
  ["proposals", "Proposals", Handshake], ["invoices", "Invoices", Receipt], ["team", "Sales Team", Users],
  ["targets", "Targets", Target], ["eod", "EOD", ClipboardCheck], ["performance", "Performance", TrendingUp],
  ["inventory", "Inventory", Package], ["services", "Services", BriefcaseBusiness],
];

const token = () => localStorage.getItem("hrms_admin_token");
const money = (v) => `₹${Number(v || 0).toLocaleString("en-IN", { maximumFractionDigits: 2 })}`;
const date = (v) => v ? new Date(v).toLocaleDateString("en-IN") : "—";

function statusClass(s) {
  const v = String(s || "").toUpperCase();
  if (["PAID", "ACCEPTED", "COMPLETED", "APPROVED", "SOLD", "ACTIVE"].includes(v)) return "bg-emerald-50 text-emerald-700 ring-emerald-200";
  if (["PENDING_APPROVAL", "PENDING", "FOLLOW_UP", "PARTIAL", "IN_PROGRESS", "DRAFT"].includes(v)) return "bg-amber-50 text-amber-700 ring-amber-200";
  if (["REJECTED", "CANCELLED", "FAILED", "LOST"].includes(v)) return "bg-rose-50 text-rose-700 ring-rose-200";
  return "bg-slate-100 text-slate-600 ring-slate-200";
}

export default function SalesManagement() {
  const [data, setData] = useState(null);
  const [tab, setTab] = useState("sales");
  const [q, setQ] = useState("");
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${BASE_URL}/super-admin/sales/overview`, { headers: { Authorization: `Bearer ${token()}` } });
      setData(res.data.data || null);
    } catch (e) {
      toast.error(e?.response?.data?.message || "Unable to load Sales Management data");
    } finally { setLoading(false); }
  }, []);

  useEffect(() => { load(); }, [load]);

  const rows = useMemo(() => {
    const source = data?.[tab] || [];
    const needle = q.trim().toLowerCase();
    if (!needle) return source;
    return source.filter(r => JSON.stringify(r).toLowerCase().includes(needle));
  }, [data, tab, q]);

  const exportCsv = () => {
    if (!rows.length) return toast.error("No data to export");
    const keys = [...new Set(rows.flatMap(r => Object.keys(r)))].filter(k => !rows.some(r => r[k] && typeof r[k] === "object"));
    const csv = [keys.join(","), ...rows.map(r => keys.map(k => `"${String(r[k] ?? "").replaceAll('"', '""')}"`).join(","))].join("\n");
    const url = URL.createObjectURL(new Blob([csv], { type: "text/csv;charset=utf-8" }));
    const a = document.createElement("a"); a.href = url; a.download = `sales-${tab}-${new Date().toISOString().slice(0,10)}.csv`; a.click(); URL.revokeObjectURL(url);
  };

  const s = data?.stats || {};
  const cards = [
    ["Sales value", money(s.salesValue), BarChart3, "bg-indigo-50 text-indigo-600"],
    ["Collected", money(s.collected), CheckCircle2, "bg-emerald-50 text-emerald-600"],
    ["Active leads", s.leads, UserPlus, "bg-blue-50 text-blue-600"],
    ["Proposals", s.proposals, Handshake, "bg-violet-50 text-violet-600"],
    ["Proposal value", money(s.proposalValue), TrendingUp, "bg-amber-50 text-amber-600"],
    ["Sales team", s.team, Users, "bg-slate-100 text-slate-600"],
  ];

  return <div className="space-y-5">
    <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
      <div><div className="mb-1 text-xs font-bold uppercase tracking-[.16em] text-indigo-600">Super Admin · Sales</div><h2 className="text-2xl font-black tracking-tight text-slate-900">Sales Management</h2><p className="mt-1 text-sm text-slate-500">One live view of the Sales portal — sales, leads, calls, proposals, invoices, targets and team activity.</p></div>
      <div className="flex gap-2"><button onClick={load} className="flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-3.5 py-2.5 text-xs font-semibold text-slate-700 shadow-sm hover:bg-slate-50"><RefreshCw size={15} className={loading ? "animate-spin" : ""}/> Refresh</button><button onClick={exportCsv} className="flex items-center gap-2 rounded-xl bg-slate-900 px-3.5 py-2.5 text-xs font-semibold text-white shadow-sm hover:bg-slate-800"><Download size={15}/> Export CSV</button></div>
    </div>

    <div className="grid grid-cols-2 gap-3 xl:grid-cols-6">{cards.map(([label,value,Icon,cls]) => <div key={label} className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm"><div className={`mb-3 flex h-9 w-9 items-center justify-center rounded-xl ${cls}`}><Icon size={17}/></div><div className="text-xl font-black text-slate-900">{value}</div><div className="mt-1 text-[11px] font-medium text-slate-500">{label}</div></div>)}</div>

    <div className="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
      <div className="flex flex-col gap-3 border-b border-slate-100 p-3 lg:flex-row lg:items-center lg:justify-between">
        <div className="flex gap-1 overflow-x-auto pb-1">{tabs.map(([key,label,Icon]) => <button key={key} onClick={() => {setTab(key); setQ("")}} className={`flex shrink-0 items-center gap-2 rounded-xl px-3 py-2 text-xs font-semibold transition ${tab===key ? "bg-indigo-600 text-white shadow-sm" : "text-slate-500 hover:bg-slate-50 hover:text-slate-800"}`}><Icon size={14}/>{label}</button>)}</div>
        <div className="flex min-w-[220px] items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-3 py-2"><Search size={15} className="text-slate-400"/><input value={q} onChange={e=>setQ(e.target.value)} placeholder={`Search ${tab}...`} className="w-full bg-transparent text-xs outline-none"/></div>
      </div>
      <div className="overflow-auto">
        {loading ? <div className="flex h-56 items-center justify-center text-sm text-slate-400">Loading Sales data…</div> : <DataTable tab={tab} rows={rows}/>} 
      </div>
    </div>
  </div>;
}

function DataTable({ tab, rows }) {
  if (!rows.length) return <div className="flex h-52 flex-col items-center justify-center text-center"><div className="mb-2 flex h-10 w-10 items-center justify-center rounded-full bg-slate-100"><Clock3 size={18} className="text-slate-400"/></div><div className="text-sm font-semibold text-slate-700">No records found</div><div className="mt-1 text-xs text-slate-400">The Sales portal has no matching data yet.</div></div>;
  const configs = {
    sales: ["client_code","client_name","plan_name","amount","amount_paid","payment_status","due_date"],
    leads: ["company_name","owner_name","phone","employee_name","status","next_followup_date"],
    calls: ["call_id","customer_name","phone","employee_name","status","call_date","follow_up_datetime"],
    proposals: ["proposal_number","client_company","title","total","status","sales_employee_name","updated_at"],
    invoices: ["invoice_no","client_name","total_amount","status","created_at"],
    team: ["name","email","department"],
    targets: ["title","employee_name","target_value","current_value","status","priority","created_at"],
    eod: ["employee_name","department","report_date","tasks_completed","tasks_in_progress","status","submitted_at"],
    performance: ["employee_name","department","period","avg_score","status","reviewed_by"],
    inventory: ["name","category","quantity","unit_price","status","updated_at"],
    services: ["name","category","price","status","created_at"],
  };
  const cols = configs[tab] || Object.keys(rows[0]).slice(0,7);
  const label = k => k.replaceAll("_", " ").replace(/\b\w/g, c=>c.toUpperCase());
  const render = (k,v) => {
    if (k.includes("amount") || k.includes("price") || k === "total" || k.includes("value")) return money(v);
    if (k.includes("date") || k.endsWith("_at")) return date(v);
    if (k === "status") return <span className={`inline-flex rounded-full px-2.5 py-1 text-[10px] font-bold uppercase ring-1 ${statusClass(v)}`}>{String(v || "—").replaceAll("_"," ")}</span>;
    return v === null || v === undefined || v === "" ? "—" : String(v);
  };
  return <table className="min-w-full text-left text-sm"><thead className="sticky top-0 z-10 bg-slate-50"><tr>{cols.map(c=><th key={c} className="whitespace-nowrap border-b border-slate-200 px-5 py-3 text-[10px] font-bold uppercase tracking-wider text-slate-500">{label(c)}</th>)}</tr></thead><tbody className="divide-y divide-slate-100">{rows.map((r,i)=><tr key={r.id ?? i} className="hover:bg-slate-50/80">{cols.map(c=><td key={c} className="whitespace-nowrap px-5 py-3.5 text-xs text-slate-600">{c === cols[0] ? <span className="font-semibold text-slate-900">{render(c,r[c])}</span> : render(c,r[c])}</td>)}</tr>)}</tbody></table>;
}
