import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import API from "../../services/api.js";
import toast from "react-hot-toast";
import { Trash2, Save } from "lucide-react";

export default function LeadBatchDetail() {
  const { id } = useParams();
  const [leads, setLeads] = useState([]);
  const [editing, setEditing] = useState({});

  const fetchLeads = async () => {
    try {
      const res = await API.get(`/super-admin/leads?batch_id=${id}`);
      setLeads(res.data.data);
    } catch {
      toast.error("Failed to load leads");
    }
  };

  useEffect(() => {
    fetchLeads();
  }, [id]);

return (
  <div className="p-4 md:p-6 space-y-6">

    {/* HEADER */}
    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-2">
      <h1 className="text-xl md:text-2xl font-bold text-gray-800">
        Lead Details
      </h1>
      <span className="text-sm text-gray-500">
        Total: {leads.length}
      </span>
    </div>

    {/* DESKTOP TABLE */}
    <div className="hidden md:block bg-white rounded-2xl shadow border overflow-hidden">
      <div className="overflow-x-auto"><table className="w-full text-sm">
        
        <thead className="bg-gray-100 text-gray-600 uppercase text-xs">
          <tr>
            <th className="p-3 text-left">Name</th>
            <th className="p-3 text-left">Phone</th>
            <th className="p-3 text-left">Status</th>
            <th className="p-3 text-left">Remarks</th>
            <th className="p-3 text-left">Action</th>
          </tr>
        </thead>

        <tbody>
          {leads.map((l) => {
            const statusColor =
              l.status === "accepted"
                ? "bg-green-100 text-green-700"
                : l.status === "rejected"
                ? "bg-red-100 text-red-700"
                : "bg-yellow-100 text-yellow-700";

            const update = async (lead) => {
    try {
      const d = editing[lead.id] || {};
      await API.put(`/super-admin/leads/${lead.id}`, { name:d.name ?? lead.name ?? "", phone:d.phone ?? lead.phone ?? "", status:d.status ?? lead.status ?? "pending", remarks:d.remarks ?? lead.remarks ?? "" });
      setLeads(rows => rows.map(r => r.id===lead.id ? {...r,...d} : r));
      setEditing(x => { const n={...x}; delete n[lead.id]; return n; });
      toast.success("Lead updated");
    } catch(e) { toast.error(e?.response?.data?.message || "Update failed"); }
  };
  const remove = async (lead) => {
    if (!window.confirm(`Delete lead ${lead.name || `#${lead.id}`}?`)) return;
    try { await API.delete(`/super-admin/leads/${lead.id}`); setLeads(rows => rows.filter(r=>r.id!==lead.id)); toast.success("Lead deleted"); }
    catch(e) { toast.error(e?.response?.data?.message || "Delete failed"); }
  };

  return (
              <tr key={l.id} className="border-t hover:bg-gray-50 transition">
                <td className="p-3 font-medium"><input value={editing[l.id]?.name ?? l.name ?? ""} onChange={e=>setEditing(x=>({...x,[l.id]:{...x[l.id],name:e.target.value}}))} className="w-full min-w-[150px] rounded-lg border px-2 py-1" placeholder="Lead name" /></td>
                <td className="p-3 text-gray-600"><input value={editing[l.id]?.phone ?? l.phone ?? ""} onChange={e=>setEditing(x=>({...x,[l.id]:{...x[l.id],phone:e.target.value}}))} className="w-full min-w-[120px] rounded-lg border px-2 py-1" placeholder="Phone" /></td>

                <td className="p-3">
                  <span className={`px-2 py-1 rounded-full text-xs ${statusColor}`}>
                    {l.status}
                  </span>
                </td>

                <td className="p-3 text-gray-600"><input value={editing[l.id]?.remarks ?? l.remarks ?? ""} onChange={e=>setEditing(x=>({...x,[l.id]:{...x[l.id],remarks:e.target.value}}))} className="w-full min-w-[180px] rounded-lg border px-2 py-1" placeholder="Remarks" /></td>
                <td className="p-3"><div className="flex gap-2"><button onClick={()=>update(l)} disabled={!editing[l.id]} className="inline-flex items-center gap-1 rounded-lg bg-indigo-600 px-3 py-1.5 text-xs font-semibold text-white disabled:opacity-40"><Save size={13}/>Save</button><button onClick={()=>remove(l)} className="inline-flex items-center gap-1 rounded-lg bg-rose-50 px-3 py-1.5 text-xs font-semibold text-rose-700"><Trash2 size={13}/>Delete</button></div></td>
              </tr>
            );
          })}
        </tbody>
      </table></div>
    </div>

    {/* MOBILE CARDS */}
    <div className="md:hidden space-y-4">
      {leads.map((l) => {
        const statusColor =
          l.status === "accepted"
            ? "bg-green-100 text-green-700"
            : l.status === "rejected"
            ? "bg-red-100 text-red-700"
            : "bg-yellow-100 text-yellow-700";

        return (
          <div
            key={l.id}
            className="bg-white p-4 rounded-xl shadow border space-y-2"
          >
            <div className="flex justify-between items-center">
              <h2 className="font-semibold text-gray-800">
                {l.name}
              </h2>
              <span className={`px-2 py-1 text-xs rounded-full ${statusColor}`}>
                {l.status}
              </span>
            </div>

            <p className="text-sm text-gray-600">
              📞 {l.phone}
            </p>

            <p className="text-sm text-gray-500">
              {l.remarks || "No remarks"}
            </p>
          </div>
        );
      })}
    </div>

    {/* EMPTY STATE */}
    {!leads.length && (
      <div className="text-center text-gray-400 py-10">
        No leads found in this batch
      </div>
    )}
  </div>
);
}