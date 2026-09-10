import { useEffect, useState } from "react";
import axios from "axios";
import toast from "react-hot-toast";
import { X, IndianRupee, CalendarDays, CreditCard, UserRound, FileText } from "lucide-react";

const initialForm = {
  plan_name: "",
  billing_months: 1,
  amount: "",
  amount_paid: "",
  payment_status: "unpaid",
  payment_method: "online",
  purchase_date: "",
  start_date: "",
  due_date: "",
  subscription_status: "active",
  remarks: "",
  employee_id: "",
};

const Field = ({ label, required, children, className = "" }) => (
  <div className={`space-y-1.5 ${className}`}>
    <label className="text-xs font-semibold uppercase tracking-wide text-slate-600">{label}{required && <span className="text-rose-500 ml-1">*</span>}</label>
    {children}
  </div>
);

const inputClass = "w-full rounded-xl border border-slate-200 bg-white px-3.5 py-3 text-sm text-slate-800 outline-none transition focus:border-indigo-400 focus:ring-4 focus:ring-indigo-500/10";

export default function AddEditSaleModal({ isOpen, onClose, editingSale, refresh, BASE_URL, token, employees = [], isEmployee = false }) {
  const [form, setForm] = useState(initialForm);
  const [saving, setSaving] = useState(false);
  const isEdit = Boolean(editingSale);

  useEffect(() => {
    if (!isOpen) return;
    if (editingSale) {
      setForm({ ...initialForm, ...editingSale, billing_months: editingSale.billing_months || 1 });
    } else {
      setForm({ ...initialForm, purchase_date: new Date().toISOString().slice(0, 10), start_date: new Date().toISOString().slice(0, 10) });
    }
  }, [isOpen, editingSale]);

  useEffect(() => {
    if (!isOpen) return undefined;
    const onKeyDown = (event) => { if (event.key === "Escape" && !saving) onClose(); };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [isOpen, saving, onClose]);

  const handleChange = (event) => setForm((previous) => ({ ...previous, [event.target.name]: event.target.value }));

  const handleSubmit = async (event) => {
    event.preventDefault();
    if (!form.plan_name.trim()) return toast.error("Plan name is required");
    if (Number(form.amount) <= 0) return toast.error("Enter a valid sales amount");
    if (Number(form.amount_paid || 0) < 0) return toast.error("Paid amount cannot be negative");
    setSaving(true);
    try {
      const config = { headers: { Authorization: `Bearer ${token}` } };
      const payload = { ...form, amount: Number(form.amount), amount_paid: Number(form.amount_paid || 0), billing_months: Number(form.billing_months) };
      if (isEdit) await axios.put(`${BASE_URL}/client/sales-report/${editingSale.id}`, payload, config);
      else await axios.post(`${BASE_URL}/client/sales-report`, payload, config);
      toast.success(isEdit ? "Sales record updated" : "Sales record added successfully");
      await refresh();
      onClose();
    } catch (error) {
      console.error("Sale save error:", error);
      toast.error(error.response?.data?.message || "Failed to save sales record");
    } finally { setSaving(false); }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-slate-950/55 p-3 sm:p-5" onMouseDown={(e) => { if (e.target === e.currentTarget && !saving) onClose(); }}>
      <div className="w-full max-w-3xl max-h-[92vh] overflow-hidden rounded-3xl bg-white shadow-2xl">
        <div className="flex items-start justify-between border-b border-slate-100 px-5 py-4 sm:px-7">
          <div><div className="flex items-center gap-2 text-indigo-600"><FileText size={18} /><span className="text-xs font-bold uppercase tracking-wider">Sales Management</span></div><h2 className="mt-1 text-xl font-bold text-slate-900">{isEdit ? "Edit Sales Record" : "Add Sales Record"}</h2><p className="mt-1 text-sm text-slate-500">{isEmployee ? "Record your customer subscription and payment details." : "Capture customer subscription, payment and ownership details."}</p></div>
          <button type="button" onClick={onClose} disabled={saving} className="rounded-xl p-2 text-slate-400 hover:bg-slate-100 hover:text-slate-700"><X size={20} /></button>
        </div>
        <form onSubmit={handleSubmit} className="max-h-[calc(92vh-92px)] overflow-y-auto px-5 py-5 sm:px-7">
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <Field label="Plan name" required><input name="plan_name" value={form.plan_name} onChange={handleChange} placeholder="e.g. Premium HRMS Plan" className={inputClass} /></Field>
            {!isEmployee && <Field label="Assigned employee"><div className="relative"><UserRound className="absolute left-3 top-3.5 text-slate-400" size={16} /><select name="employee_id" value={form.employee_id || ""} onChange={handleChange} className={`${inputClass} pl-10`}><option value="">Unassigned / Client Admin</option>{employees.map((employee) => <option key={employee.id} value={employee.id}>{employee.employeeCode || employee.employee_code || `EMP-${employee.id}`} — {employee.name}</option>)}</select></div></Field>}
            <Field label="Billing period"><select name="billing_months" value={form.billing_months} onChange={handleChange} className={inputClass}>{Array.from({ length: 12 }, (_, i) => <option key={i + 1} value={i + 1}>{i + 1} {i === 0 ? "Month" : "Months"}</option>)}</select></Field>
            <Field label="Sales amount" required><div className="relative"><IndianRupee className="absolute left-3 top-3.5 text-slate-400" size={16} /><input name="amount" type="number" min="0" step="0.01" value={form.amount} onChange={handleChange} placeholder="0.00" className={`${inputClass} pl-9`} /></div></Field>
            <Field label="Amount paid"><div className="relative"><IndianRupee className="absolute left-3 top-3.5 text-slate-400" size={16} /><input name="amount_paid" type="number" min="0" step="0.01" value={form.amount_paid} onChange={handleChange} placeholder="0.00" className={`${inputClass} pl-9`} /></div></Field>
            <Field label="Payment status"><select name="payment_status" value={form.payment_status} onChange={handleChange} className={inputClass}><option value="paid">Paid</option><option value="partial">Partial</option><option value="unpaid">Unpaid</option></select></Field>
            <Field label="Payment method"><div className="relative"><CreditCard className="absolute left-3 top-3.5 text-slate-400" size={16} /><select name="payment_method" value={form.payment_method} onChange={handleChange} className={`${inputClass} pl-10`}><option value="online">Online</option><option value="cash">Cash</option></select></div></Field>
            <Field label="Purchase date" required><div className="relative"><CalendarDays className="absolute left-3 top-3.5 text-slate-400" size={16} /><input name="purchase_date" type="date" value={form.purchase_date || ""} onChange={handleChange} className={`${inputClass} pl-10`} /></div></Field>
            <Field label="Subscription start" required><input name="start_date" type="date" value={form.start_date || ""} onChange={handleChange} className={inputClass} /></Field>
            <Field label="Payment due date"><input name="due_date" type="date" value={form.due_date || ""} onChange={handleChange} className={inputClass} /></Field>
            <Field label="Subscription status"><select name="subscription_status" value={form.subscription_status} onChange={handleChange} className={inputClass}><option value="active">Active</option><option value="expired">Expired</option><option value="cancelled">Cancelled</option></select></Field>
            <Field label="Remarks" className="md:col-span-2"><textarea name="remarks" rows={4} value={form.remarks || ""} onChange={handleChange} placeholder="Add customer or payment notes…" className={`${inputClass} resize-none`} /></Field>
          </div>
          <div className="mt-6 flex flex-col-reverse gap-3 border-t border-slate-100 pt-5 sm:flex-row sm:justify-end"><button type="button" onClick={onClose} disabled={saving} className="rounded-xl border border-slate-200 px-5 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50 disabled:opacity-50">Cancel</button><button type="submit" disabled={saving} className="rounded-xl bg-indigo-600 px-6 py-3 text-sm font-semibold text-white shadow-lg shadow-indigo-600/20 hover:bg-indigo-700 disabled:cursor-not-allowed disabled:opacity-60">{saving ? "Saving…" : isEdit ? "Update Sales Record" : "Add Sales Record"}</button></div>
        </form>
      </div>
    </div>
  );
}
