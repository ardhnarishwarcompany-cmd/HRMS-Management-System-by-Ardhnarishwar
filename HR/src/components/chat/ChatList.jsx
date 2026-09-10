import { useEffect, useMemo, useState } from "react";
import axios from "axios";
import { MessageCircle, Search, Users, Code2, UserRound } from "lucide-react";

const BASE_URL = import.meta.env.VITE_API_BASE_URL;

export default function ChatList({ setActiveChat, activeChat }) {
  const [clients, setClients] = useState([]);
  const [itContacts, setItContacts] = useState([]);
  const [hrContacts, setHrContacts] = useState([]);
  const [search, setSearch] = useState("");
  const token = localStorage.getItem("hrms_hr_Token");

  const auth = { headers: { Authorization: `Bearer ${token}` } };

  const load = async () => {
    try {
      const [clientsRes, itRes, hrRes] = await Promise.all([
        axios.get(`${BASE_URL}/chat/hr/clients`, auth),
        axios.get(`${BASE_URL}/chat/internal/it-contacts`, auth),
        axios.get(`${BASE_URL}/chat/internal/hrs`, auth),
      ]);
      setClients(clientsRes.data?.data || []);
      setItContacts(itRes.data?.data || []);
      setHrContacts(hrRes.data?.data || []);
    } catch (err) {
      console.error("Chat contacts load error:", err);
    }
  };

  useEffect(() => {
    load();
    const interval = setInterval(load, 5000);
    return () => clearInterval(interval);
  }, []);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return clients;
    return clients.filter((c) =>
      [c.company_name, c.client_name, c.email].some((v) => String(v || "").toLowerCase().includes(q))
    );
  }, [clients, search]);

  const openInternal = (contact) => {
    setActiveChat({
      internal: true,
      room: contact.room,
      recipientId: Number(contact.id),
      name: contact.name,
      email: contact.email,
      contactType: contact.contactType || "it",
    });
  };

  const openClient = async (client) => {
    try {
      const res = await axios.post(`${BASE_URL}/chat/hr/start`, { clientId: client.id }, auth);
      setActiveChat({
        conversation_id: res.data.conversationId,
        company_name: client.company_name,
        client_name: client.client_name,
      });
    } catch (err) {
      console.error("Client chat start error:", err);
    }
  };

  const Section = ({ title, icon: Icon, tone = "indigo", children, count }) => (
    <div>
      <div className="flex items-center justify-between px-4 pb-2 pt-4 text-[11px] font-semibold uppercase tracking-widest text-slate-400">
        <span className="flex items-center gap-2"><Icon size={13} />{title}</span>
        {typeof count === "number" && <span className={`rounded-full px-2 py-0.5 text-[10px] ${tone === "violet" ? "bg-violet-50 text-violet-600" : "bg-indigo-50 text-indigo-600"}`}>{count}</span>}
      </div>
      {children}
    </div>
  );

  const Contact = ({ contact, type }) => {
    const isActive = activeChat?.internal && activeChat?.room === contact.room;
    return (
      <button
        type="button"
        onClick={() => openInternal(contact)}
        className={`flex w-full items-center gap-3 border-b border-slate-100 border-l-4 p-3.5 text-left transition-colors ${isActive ? "border-l-indigo-500 bg-indigo-50" : "border-l-transparent hover:bg-slate-50"}`}
      >
        <div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl text-sm font-bold ring-1 ${type === "it" ? "bg-sky-50 text-sky-600 ring-sky-100" : "bg-violet-50 text-violet-600 ring-violet-100"}`}>
          {contact.name?.charAt(0)?.toUpperCase() || "U"}
        </div>
        <div className="min-w-0">
          <div className="truncate text-sm font-semibold text-slate-900">{contact.name}</div>
          <div className="truncate text-xs text-slate-500">{contact.email || (type === "it" ? "IT employee" : "HR employee")}</div>
        </div>
        {contact.last_message_at && <span className="ml-auto h-2 w-2 shrink-0 rounded-full bg-emerald-500" title="Has conversation" />}
      </button>
    );
  };

  return (
    <div className="flex w-[285px] shrink-0 flex-col border-r border-slate-200 bg-white">
      <div className="relative overflow-hidden border-b border-slate-800 bg-slate-900 p-4">
        <div className="absolute -right-10 -top-10 h-28 w-28 rounded-full bg-indigo-600/25 blur-2xl" />
        <div className="relative">
          <p className="text-[10px] font-semibold uppercase tracking-widest text-indigo-300">Messaging</p>
          <h2 className="mb-3 mt-0.5 text-lg font-bold text-white">HR Chat</h2>
          <div className="relative">
            <Search size={15} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search contacts..." className="w-full rounded-xl border border-slate-700 bg-slate-800/70 py-2 pl-9 pr-3 text-sm text-white placeholder-slate-400 outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/25" />
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        <Section title="IT Employees" icon={Code2} tone="indigo" count={itContacts.length}>
          {itContacts.length ? itContacts.map((c) => <Contact key={`it-${c.id}`} contact={{...c, contactType:"it"}} type="it" />) : (
            <div className="px-4 py-5 text-xs text-slate-400">IT employees who message you will appear here.</div>
          )}
        </Section>

        <Section title="HR Contacts" icon={Users} tone="violet" count={hrContacts.length}>
          {hrContacts.map((c) => <Contact key={`hr-${c.id}`} contact={{...c, contactType:"hr"}} type="hr" />)}
        </Section>

        <Section title="Clients" icon={UserRound} count={filtered.length}>
          {filtered.length === 0 ? (
            <div className="flex flex-col items-center justify-center px-4 py-8 text-slate-400"><MessageCircle size={32} className="mb-2 text-slate-200" /><p className="text-xs">No clients found</p></div>
          ) : filtered.map((client) => {
            const isActive = activeChat?.company_name === client.company_name;
            return (
              <button type="button" key={client.id} onClick={() => openClient(client)} className={`flex w-full items-center gap-3 border-b border-slate-100 border-l-4 p-3.5 text-left transition-colors ${isActive ? "border-l-indigo-500 bg-indigo-50" : "border-l-transparent hover:bg-slate-50"}`}>
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-indigo-50 text-sm font-bold text-indigo-600 ring-1 ring-indigo-100">{client.company_name?.charAt(0)?.toUpperCase()}</div>
                <div className="min-w-0"><div className="truncate text-sm font-semibold text-slate-900">{client.company_name}</div><div className="truncate text-xs text-slate-500">{client.client_name}</div></div>
              </button>
            );
          })}
        </Section>
      </div>

      <div className="border-t border-slate-200 bg-slate-50 p-3"><div className="flex items-center gap-2"><div className="h-2 w-2 animate-pulse rounded-full bg-emerald-500" /><span className="text-xs text-slate-500">Connected</span></div></div>
    </div>
  );
}
