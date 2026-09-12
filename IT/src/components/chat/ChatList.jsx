import { useEffect, useState } from "react";
import axios from "axios";
import { Search } from "lucide-react";

const BASE_URL = import.meta.env.VITE_API_BASE_URL;

// NOTE (12 Sep 2026): the "Clients" section used to be shown here so IT
// staff could message a client directly. That message *did* save to the
// database, but the Client portal's own chat page never had any way to
// see it: the client UI only ever loads HR-department contacts
// (`/chat/client/hrs` is hard-filtered to department = 'HR') and never
// calls the generic `/chat/client/conversations` endpoint that would show
// a conversation started by IT. So a client could never see or reply to
// an IT-initiated chat — it looked "sent" on the IT side but went
// nowhere. Rather than ship a half-working feature, the Clients list has
// been removed from IT chat entirely; IT <-> HR internal chat below is
// unaffected and works normally.
export default function ChatList({ setActiveChat, activeChat }) {
  const [hrs, setHrs] = useState([]);
  const [search, setSearch] = useState("");
  const token = localStorage.getItem("hrms_it_Token");

  useEffect(() => {
    const headers = { Authorization: `Bearer ${token}` };

    axios
      .get(`${BASE_URL}/chat/internal/hrs`, {
        headers: { ...headers, "X-Portal-Type": "it" },
      })
      .then((res) => setHrs(res.data?.data || []))
      .catch((err) => console.error("HR directory load error:", err));
  }, []);

  const filteredHrs = hrs.filter((hr) =>
    hr.name?.toLowerCase().includes(search.toLowerCase()) ||
    hr.email?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="w-72 border-r flex flex-col bg-white">
      <div className="p-4 border-b bg-gradient-to-r from-purple-600 to-pink-600">
        <h2 className="text-white font-bold text-lg mb-3">IT Chat</h2>
        <div className="relative">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-white/60" />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search HR..."
            className="w-full pl-9 pr-3 py-2 bg-white/20 text-white placeholder-white/60 rounded-xl text-sm outline-none focus:bg-white/30"
          />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        <div className="px-4 pt-3 pb-1 text-[11px] font-semibold text-gray-400 uppercase tracking-wider">
          Internal
        </div>
        {filteredHrs.length === 0 ? (
          <div className="px-4 py-3 text-xs text-gray-400">No HR contacts found</div>
        ) : filteredHrs.map((hr) => {
          // BUGFIX (12 Sep 2026): the backend (getInternalHRs) already
          // computes and returns the correct private room id as `hr.room`
          // (format hr-it:<hrId>:<itId>). This used to be rebuilt locally
          // as `hr-it:${hr.id}` (missing the logged-in IT employee's own
          // id), which pointed at a different room than the one
          // `sendInternalMessage` actually writes to on the backend.
          // Result: messages appeared to send, but disappeared again on
          // the next 3s poll because GET and POST used different room
          // strings. Using the server-provided room keeps both in sync.
          const room = hr.room || `hr-it:${hr.id}`;
          const isActive = activeChat?.internal && activeChat?.room === room;
          return (
            <div
              key={room}
              onClick={() =>
                setActiveChat({
                  internal: true,
                  room,
                  hr_id: hr.id,
                  name: hr.name,
                  email: hr.email,
                })
              }
              className={`p-4 border-b cursor-pointer transition-all ${
                isActive
                  ? "bg-amber-50 border-l-4 border-l-amber-500"
                  : "hover:bg-gray-50 border-l-4 border-l-transparent"
              }`}
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-gradient-to-r from-amber-500 to-orange-500 flex items-center justify-center text-white font-bold text-sm">
                  {hr.name?.charAt(0)}
                </div>
                <div>
                  <div className="font-semibold text-gray-800 text-sm">
                    {hr.name}
                  </div>
                  <div className="text-xs text-gray-500">{hr.email}</div>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <div className="p-3 border-t bg-gray-50">
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
          <span className="text-xs text-gray-500">Connected</span>
        </div>
      </div>
    </div>
  );
}
