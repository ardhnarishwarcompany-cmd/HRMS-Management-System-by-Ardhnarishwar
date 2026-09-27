import { useEffect, useMemo, useState } from "react";
import { BarChart3, TrendingUp, IndianRupee, Plus, RefreshCw, ShoppingCart } from "lucide-react";
import { BarChart, Bar, LineChart, Line, Tooltip, ResponsiveContainer, XAxis, YAxis, CartesianGrid, Legend } from "recharts";
import API from "../../services/api";
import { useClientAuth } from "../../context/ClientAuthContext";
import PageHeader from "../../components/common/PageHeader";
import AddEditSaleModal from "../../components/sales/AddEditSaleModal";
import toast from "react-hot-toast";

const money = (n) => `₹${Number(n || 0).toLocaleString("en-IN")}`;

export default function SalesReports() {
  const { client } = useClientAuth();
  const isEmployee = String(client?.role || "").toUpperCase() === "CLIENT_EMPLOYEE";
  const token = localStorage.getItem("hrms_client_Token");
  const BASE_URL = import.meta.env.VITE_API_BASE_URL;
  const [rows, setRows] = useState([]);
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [editingSale, setEditingSale] = useState(null);
  const [chartsReady, setChartsReady] = useState(false);

  const fetchReport = async () => {
    try {
      setLoading(true);
      const r = await API.get("/client/sales-report");
      setRows(Array.isArray(r.data?.data) ? r.data.data : []);
    } catch (e) {
      toast.error(e?.response?.data?.message || "Failed to load sales report");
    } finally { setLoading(false); }
  };

  const fetchEmployees = async () => {
    if (isEmployee) return;
    try {
      const r = await API.get("/client/employees");
      setEmployees(r.data?.data || r.data?.employees || []);
    } catch (e) { console.error(e); }
  };

  useEffect(() => { fetchReport(); fetchEmployees(); }, [isEmployee]);
  useEffect(() => { const t=setTimeout(()=>setChartsReady(true),100); return ()=>clearTimeout(t); }, []);

  const byEmployee = useMemo(() => {
    const map = {};
    rows.forEach((r) => {
      const key = r.employee_id || "unassigned";
      const name = r.employee_name || (key === "unassigned" ? "Unassigned" : `Employee #${key}`);
      if (!map[key]) map[key] = { name, amount: 0, paid: 0, count: 0 };
      map[key].amount += Number(r.amount || 0);
      map[key].paid += Number(r.amount_paid || 0);
      map[key].count += 1;
    });
    return Object.values(map).sort((a,b)=>b.amount-a.amount);
  }, [rows]);

  const monthly = useMemo(() => {
    const map = {};
    rows.forEach(r => {
      const d = r.purchase_date ? new Date(r.purchase_date) : null;
      if (!d || Number.isNaN(d.getTime())) return;
      const key = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,"0")}`;
      if (!map[key]) map[key] = { month: d.toLocaleDateString("en-IN", { month:"short", year:"numeric" }), amount:0, paid:0, orders:0, sort:key };
      map[key].amount += Number(r.amount || 0);
      map[key].paid += Number(r.amount_paid || 0);
      map[key].orders += 1;
    });
    return Object.values(map).sort((a,b)=>a.sort.localeCompare(b.sort));
  }, [rows]);

  const total = rows.reduce((s,r)=>s+Number(r.amount||0),0);
  const paid = rows.reduce((s,r)=>s+Number(r.amount_paid||0),0);
  const pending = Math.max(total-paid,0);

  return (
    <div className="space-y-6">
      <PageHeader icon={<BarChart3 size={22}/>} title="Sales Report" desc={isEmployee ? "Record your purchases and track your sales performance." : "Track employee sales, purchases, revenue and payment analysis."} actions={<div className="flex gap-2"><button onClick={fetchReport} className="btn-secondary-premium"><RefreshCw size={15}/> Refresh</button><button onClick={()=>{setEditingSale(null);setShowAdd(true)}} className="btn-primary-premium"><Plus size={16}/> Add Sales Record</button></div>} />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="stat-premium"><p className="stat-premium-label">Total Purchase Value</p><p className="stat-premium-value">{money(total)}</p></div>
        <div className="stat-premium"><p className="stat-premium-label">Amount Paid</p><p className="stat-premium-value">{money(paid)}</p></div>
        <div className="stat-premium"><p className="stat-premium-label">Outstanding</p><p className="stat-premium-value">{money(pending)}</p></div>
        <div className="stat-premium"><p className="stat-premium-label">Purchase Orders</p><p className="stat-premium-value">{rows.length}</p></div>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
        <div className="card-premium p-5 min-w-0">
          <h2 className="font-bold text-slate-900 flex items-center gap-2"><TrendingUp size={18}/> Purchase / Sales by Employee</h2>
          <div className="mt-4 h-[330px] w-full min-w-0 overflow-hidden">{chartsReady && byEmployee.length ? <ResponsiveContainer width="100%" height="100%" minWidth={0} minHeight={280} debounce={50}><BarChart data={byEmployee} margin={{ top: 10, right: 15, left: 0, bottom: 10 }}><CartesianGrid strokeDasharray="3 3"/><XAxis dataKey="name" tick={{fontSize:11}}/><YAxis/><Tooltip formatter={(v)=>money(v)}/><Legend/><Bar dataKey="amount" name="Purchase Value" fill="#6366f1"/></BarChart></ResponsiveContainer> : <div className="h-full flex items-center justify-center text-slate-400">No sales records yet. Click “Add Sales Record” to start.</div>}</div>
        </div>
        <div className="card-premium p-5 min-w-0">
          <h2 className="font-bold text-slate-900 flex items-center gap-2"><ShoppingCart size={18}/> Purchase Trend</h2>
          <div className="mt-4 h-[330px] w-full min-w-0 overflow-hidden">{chartsReady && monthly.length ? <ResponsiveContainer width="100%" height="100%" minWidth={0} minHeight={280} debounce={50}><LineChart data={monthly}><CartesianGrid strokeDasharray="3 3"/><XAxis dataKey="month"/><YAxis/><Tooltip formatter={(v)=>money(v)}/><Legend/><Line type="monotone" dataKey="amount" name="Purchase Value" stroke="#7c3aed" strokeWidth={3}/><Line type="monotone" dataKey="paid" name="Paid" stroke="#10b981" strokeWidth={2}/></LineChart></ResponsiveContainer> : <div className="h-full flex items-center justify-center text-slate-400">Purchase trend will appear here.</div>}</div>
        </div>
      </div>

      <div className="card-premium overflow-hidden">
        <div className="p-5 border-b border-slate-100 flex items-center justify-between"><div><h2 className="font-bold text-slate-900">Purchase / Sales Records</h2><p className="text-xs text-slate-500 mt-1">Every purchase recorded by the client or employee is listed here.</p></div><span className="text-xs px-3 py-1.5 rounded-full bg-indigo-50 text-indigo-700 font-semibold">{rows.length} records</span></div>
        <div className="overflow-x-auto"><table className="w-full min-w-[1000px]"><thead className="bg-slate-50"><tr>{["Date","Plan / Order","Employee","Amount","Paid","Payment","Subscription","Due Date","Action"].map(h=><th key={h} className="px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase">{h}</th>)}</tr></thead><tbody className="divide-y divide-slate-100">{loading ? <tr><td colSpan="9" className="p-10 text-center text-slate-400">Loading...</td></tr> : rows.length===0 ? <tr><td colSpan="9" className="p-10 text-center text-slate-400">No records found. Add the first sales / purchase record.</td></tr> : rows.map(r=><tr key={r.id} className="hover:bg-slate-50/70"><td className="px-4 py-4 text-sm">{r.purchase_date ? new Date(r.purchase_date).toLocaleDateString("en-IN") : "-"}</td><td className="px-4 py-4"><div className="font-semibold text-slate-800">{r.plan_name}</div><div className="text-xs text-slate-400">{r.billing_months} month{Number(r.billing_months)!==1?"s":""}</div></td><td className="px-4 py-4 text-sm">{r.employee_name || "Unassigned"}</td><td className="px-4 py-4 font-semibold">{money(r.amount)}</td><td className="px-4 py-4">{money(r.amount_paid)}</td><td className="px-4 py-4 text-xs capitalize">{r.payment_status} · {r.payment_method}</td><td className="px-4 py-4 text-xs capitalize">{r.subscription_status}</td><td className="px-4 py-4 text-sm">{r.due_date ? new Date(r.due_date).toLocaleDateString("en-IN") : "-"}</td><td className="px-4 py-4"><button onClick={()=>{setEditingSale(r);setShowAdd(true)}} className="px-3 py-1.5 rounded-lg bg-indigo-50 text-indigo-700 text-xs font-semibold">Edit</button></td></tr>)}</tbody></table></div>
      </div>

      <AddEditSaleModal isOpen={showAdd} onClose={()=>setShowAdd(false)} editingSale={editingSale} refresh={fetchReport} BASE_URL={BASE_URL} token={token} employees={employees} isEmployee={isEmployee}/>
    </div>
  );
}
