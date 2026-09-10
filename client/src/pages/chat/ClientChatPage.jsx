import { useEffect, useRef, useState } from "react";
import API from "../../services/api";
import { Send, Search, MessageCircle, ArrowLeft, UserRound } from "lucide-react";
import { useClientAuth } from "../../context/ClientAuthContext";

const fmt = (d) => {
  const date = new Date(d);
  return Number.isNaN(date.getTime()) ? "" : date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
};

function EmployeeClientChat() {
  const [clientRoom, setClientRoom] = useState(null);
  const [conversationId, setConversationId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [text, setText] = useState("");
  const [sending, setSending] = useState(false);
  const [loading, setLoading] = useState(true);
  const bottom = useRef(null);

  useEffect(() => {
    let cancelled = false;
    const initialize = async () => {
      try {
        const roomResponse = await API.get("/chat/client/assigned-chat");
        if (cancelled) return;
        setClientRoom(roomResponse.data?.data || null);
        const conversationResponse = await API.post("/chat/client/employee/start");
        if (cancelled) return;
        setConversationId(conversationResponse.data?.conversationId || null);
      } catch (error) {
        if (!cancelled) console.error("Client chat initialization failed:", error);
      } finally {
        if (!cancelled) setLoading(false);
      }
    };
    initialize();
    return () => { cancelled = true; };
  }, []);

  useEffect(() => {
    if (!conversationId) return undefined;
    let cancelled = false;
    const load = async () => {
      try {
        const response = await API.get(`/chat/client/employee/messages/${conversationId}`);
        if (!cancelled) setMessages(response.data?.data || []);
      } catch (error) {
        if (!cancelled) console.error("Client chat message load failed:", error);
      }
    };
    load();
    const timer = window.setInterval(load, 2500);
    return () => {
      cancelled = true;
      window.clearInterval(timer);
    };
  }, [conversationId]);

  useEffect(() => {
    bottom.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const send = async () => {
    const message = text.trim();
    if (!message || sending || !conversationId) return;
    setSending(true);
    try {
      await API.post("/chat/client/employee/send", { conversationId, message });
      setMessages((previous) => [...previous, { sender_type: "employee", message, created_at: new Date().toISOString() }]);
      setText("");
    } catch (error) {
      console.error("Client chat send failed:", error);
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="h-[calc(100vh-110px)] min-h-[560px] p-3 sm:p-5">
      <div className="h-full card-premium overflow-hidden flex flex-col">
        <div className="p-4 border-b flex items-center gap-3">
          <div className="w-11 h-11 rounded-full bg-violet-100 text-violet-700 flex items-center justify-center"><UserRound size={20} /></div>
          <div>
            <h2 className="font-bold text-slate-900">My Client Chat</h2>
            <p className="text-xs text-slate-500">{clientRoom?.name ? `Chat with ${clientRoom.name}` : "Only your appointed client chat room is available here."}</p>
          </div>
        </div>
        <div className="flex-1 overflow-y-auto p-5 space-y-3 bg-slate-50/60">
          {loading && <div className="h-full flex items-center justify-center text-sm text-slate-400">Connecting to your client…</div>}
          {!loading && !messages.length && <div className="h-full flex items-center justify-center text-sm text-slate-400">Start a conversation with your client.</div>}
          {messages.map((m, i) => (
            <div key={`${m.created_at}-${i}`} className={`flex ${m.sender_type === "employee" ? "justify-end" : "justify-start"}`}>
              <div className={`max-w-[75%] rounded-2xl px-4 py-3 ${m.sender_type === "employee" ? "bg-indigo-600 text-white rounded-br-md" : "bg-white border text-slate-800 rounded-bl-md"}`}>
                <p className="text-sm whitespace-pre-wrap break-words">{m.message}</p>
                <span className={`text-[10px] block mt-1 ${m.sender_type === "employee" ? "text-indigo-100" : "text-slate-400"}`}>{fmt(m.created_at)}</span>
              </div>
            </div>
          ))}
          <div ref={bottom} />
        </div>
        <div className="p-4 border-t flex gap-2 bg-white">
          <input value={text} onChange={(e) => setText(e.target.value)} onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); } }} placeholder="Write a message to your client…" className="flex-1 border border-slate-200 rounded-xl px-4 py-3 outline-none focus:ring-2 focus:ring-indigo-200" />
          <button onClick={send} disabled={sending || !text.trim() || !conversationId} className="w-12 rounded-xl bg-indigo-600 text-white flex items-center justify-center disabled:opacity-50"><Send size={18} /></button>
        </div>
      </div>
    </div>
  );
}

function AdminHRChat() {
  const [hrs, setHrs] = useState([]);
  const [employeeChats, setEmployeeChats] = useState([]);
  const [mode, setMode] = useState("hr");
  const [search, setSearch] = useState("");
  const [active, setActive] = useState(null);
  const [conversationId, setConversationId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(true);
  const [chatLoading, setChatLoading] = useState(false);
  const bottom = useRef(null);

  const loadEmployeeChats = async () => {
    try {
      const response = await API.get("/chat/client/employee/conversations");
      setEmployeeChats(response.data?.data || []);
    } catch (error) {
      console.error("Employee chat list load failed:", error);
    }
  };

  useEffect(() => {
    let cancelled = false;
    const load = async () => {
      try {
        const [hrResponse, employeeResponse] = await Promise.all([
          API.get("/chat/client/hrs"),
          API.get("/chat/client/employee/conversations"),
        ]);
        if (!cancelled) {
          setHrs(hrResponse.data?.data || []);
          setEmployeeChats(employeeResponse.data?.data || []);
        }
      } catch (error) {
        if (!cancelled) console.error("Client chat lists load failed:", error);
      } finally {
        if (!cancelled) setLoading(false);
      }
    };
    load();
    const timer = window.setInterval(loadEmployeeChats, 5000);
    return () => {
      cancelled = true;
      window.clearInterval(timer);
    };
  }, []);

  useEffect(() => {
    setConversationId(null);
    setMessages([]);
    if (!active) return undefined;

    let cancelled = false;
    const startOrSelect = async () => {
      setChatLoading(true);
      try {
        if (mode === "hr") {
          const response = await API.post("/chat/client/start", { hrId: active.id });
          if (!cancelled) setConversationId(response.data?.conversationId || null);
        } else {
          if (!cancelled) setConversationId(active.conversation_id);
        }
      } catch (error) {
        if (!cancelled) console.error("Conversation open failed:", error);
      } finally {
        if (!cancelled) setChatLoading(false);
      }
    };
    startOrSelect();
    return () => { cancelled = true; };
  }, [active, mode]);

  useEffect(() => {
    if (!conversationId) return undefined;
    let cancelled = false;

    const load = async () => {
      try {
        const endpoint = mode === "employee"
          ? `/chat/client/employee/conversations/${conversationId}/messages`
          : `/chat/messages/${conversationId}`;
        const response = await API.get(endpoint);
        if (!cancelled) setMessages(response.data?.data || []);
      } catch (error) {
        if (!cancelled) console.error("Chat message load failed:", error);
      }
    };

    load();
    const timer = window.setInterval(load, 2500);
    return () => {
      cancelled = true;
      window.clearInterval(timer);
    };
  }, [conversationId, mode]);

  useEffect(() => {
    bottom.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const selectMode = (nextMode) => {
    setMode(nextMode);
    setSearch("");
    setActive(null);
    setConversationId(null);
    setMessages([]);
    setText("");
  };

  const send = async () => {
    const message = text.trim();
    if (!message || !conversationId) return;

    try {
      const endpoint = mode === "employee"
        ? "/chat/client/employee/conversations/send"
        : "/chat/client/send";

      const response = await API.post(endpoint, { conversationId, message });
      const saved = response.data?.data || {
        sender_type: mode === "employee" ? "client" : "client",
        message,
        created_at: new Date().toISOString(),
      };

      setMessages((previous) => [...previous, saved]);
      setText("");

      if (mode === "employee") {
        await loadEmployeeChats();
      }
    } catch (error) {
      console.error("Chat send failed:", error);
    }
  };

  const selectHR = (hr) => {
    setMode("hr");
    setActive(hr);
  };

  const selectEmployee = (chat) => {
    setMode("employee");
    setActive(chat);
  };

  return (
    <div className="h-[calc(100vh-110px)] min-h-[560px] p-3 sm:p-5">
      <div className="h-full card-premium overflow-hidden flex">
        <aside className={`${active ? "hidden md:flex" : "flex"} w-full md:w-80 border-r flex-col bg-white`}>
          <div className="p-4 border-b">
            <div className="flex gap-2">
              <button
                onClick={() => selectMode("hr")}
                className={`flex-1 rounded-xl px-3 py-2 text-sm font-semibold transition ${mode === "hr" ? "bg-indigo-600 text-white" : "bg-slate-100 text-slate-600"}`}
              >
                HR Support
              </button>
              <button
                onClick={() => selectMode("employee")}
                className={`flex-1 rounded-xl px-3 py-2 text-sm font-semibold transition ${mode === "employee" ? "bg-indigo-600 text-white" : "bg-slate-100 text-slate-600"}`}
              >
                Employees {employeeChats.length > 0 && `(${employeeChats.length})`}
              </button>
            </div>

            <div className="mt-3 flex items-center gap-2 bg-slate-100 rounded-xl px-3 py-2">
              <Search size={15} />
              <input
                value={search}
                placeholder={mode === "hr" ? "Search HR" : "Search employee chats"}
                className="bg-transparent outline-none text-sm w-full"
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
          </div>

          <div className="flex-1 overflow-y-auto">
            {loading && <p className="p-5 text-sm text-slate-400">Loading chats…</p>}

            {!loading && mode === "hr" && !hrs.length && (
              <p className="p-5 text-sm text-slate-400">No HR members available.</p>
            )}

            {!loading && mode === "employee" && !employeeChats.length && (
              <div className="p-5 text-center">
                <MessageCircle size={30} className="mx-auto mb-2 text-slate-300" />
                <p className="text-sm text-slate-500">No employee messages yet.</p>
                <p className="text-xs text-slate-400 mt-1">Messages sent by client employees will appear here automatically.</p>
              </div>
            )}

            {mode === "hr" && hrs
              .filter((hr) => String(hr.name || "").toLowerCase().includes(search.toLowerCase()))
              .map((hr) => (
              <button
                key={hr.id}
                onClick={() => selectHR(hr)}
                className={`w-full text-left p-4 border-b flex items-center gap-3 ${active?.id === hr.id && mode === "hr" ? "bg-violet-50" : "hover:bg-slate-50"}`}
              >
                <div className="w-10 h-10 rounded-full bg-violet-600 text-white flex items-center justify-center font-bold">
                  {hr.name?.[0] || "H"}
                </div>
                <div className="min-w-0">
                  <p className="font-semibold text-sm text-slate-900 truncate">{hr.name}</p>
                  <p className="text-xs text-slate-500">HR Team</p>
                </div>
              </button>
            ))}

            {mode === "employee" && employeeChats
              .filter((chat) => String(chat.employee_name || "").toLowerCase().includes(search.toLowerCase()))
              .map((chat) => (
              <button
                key={chat.conversation_id}
                onClick={() => selectEmployee(chat)}
                className={`w-full text-left p-4 border-b flex items-center gap-3 ${active?.conversation_id === chat.conversation_id && mode === "employee" ? "bg-indigo-50" : "hover:bg-slate-50"}`}
              >
                <div className="w-10 h-10 shrink-0 rounded-full bg-indigo-600 text-white flex items-center justify-center font-bold">
                  {chat.employee_name?.[0] || "E"}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between gap-2">
                    <p className="font-semibold text-sm text-slate-900 truncate">{chat.employee_name}</p>
                    {chat.last_message_at && <span className="text-[10px] text-slate-400 shrink-0">{fmt(chat.last_message_at)}</span>}
                  </div>
                  <p className="text-xs text-slate-500 truncate">
                    {chat.last_message || "Conversation started"}
                  </p>
                </div>
              </button>
            ))}
          </div>
        </aside>

        <main className={`${active ? "flex" : "hidden md:flex"} flex-1 flex-col min-w-0`}>
          {active ? (
            <>
              <div className="p-4 border-b flex items-center gap-3 bg-white">
                <button onClick={() => setActive(null)} className="md:hidden">
                  <ArrowLeft size={18} />
                </button>
                <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold ${mode === "employee" ? "bg-indigo-100 text-indigo-700" : "bg-violet-100 text-violet-700"}`}>
                  {active.name?.[0] || active.employee_name?.[0] || (mode === "employee" ? "E" : "H")}
                </div>
                <div className="min-w-0">
                  <p className="font-bold text-slate-900 truncate">
                    {mode === "employee" ? active.employee_name : active.name}
                  </p>
                  <p className="text-xs text-slate-500">
                    {mode === "employee" ? "Client Employee" : "HR Support"}
                  </p>
                </div>
              </div>

              <div className="flex-1 overflow-y-auto p-5 space-y-3 bg-slate-50/60">
                {chatLoading && <div className="h-full flex items-center justify-center text-sm text-slate-400">Opening conversation…</div>}
                {!chatLoading && !messages.length && (
                  <div className="h-full flex items-center justify-center text-sm text-slate-400">
                    {mode === "employee" ? "No messages in this employee conversation yet." : "Start a conversation with HR."}
                  </div>
                )}
                {!chatLoading && messages.map((m, i) => {
                  const mine = m.sender_type === "client";
                  return (
                    <div key={`${m.id || m.created_at}-${i}`} className={`flex ${mine ? "justify-end" : "justify-start"}`}>
                      <div className={`max-w-[75%] px-4 py-3 rounded-2xl ${mine ? "bg-indigo-600 text-white rounded-br-md" : "bg-white border text-slate-800 rounded-bl-md"}`}>
                        <p className="text-sm whitespace-pre-wrap break-words">{m.message}</p>
                        <span className={`text-[10px] block mt-1 ${mine ? "text-indigo-100" : "text-slate-400"}`}>
                          {fmt(m.created_at)}
                        </span>
                      </div>
                    </div>
                  );
                })}
                <div ref={bottom} />
              </div>

              <div className="p-4 border-t flex gap-2 bg-white">
                <input
                  value={text}
                  onChange={(e) => setText(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" && !e.shiftKey) {
                      e.preventDefault();
                      send();
                    }
                  }}
                  placeholder={mode === "employee" ? "Reply to employee…" : "Message HR…"}
                  className="flex-1 border border-slate-200 rounded-xl px-4 py-3 outline-none focus:ring-2 focus:ring-indigo-200"
                />
                <button
                  onClick={send}
                  disabled={!conversationId || !text.trim()}
                  className="w-12 rounded-xl bg-indigo-600 text-white flex items-center justify-center disabled:opacity-50"
                >
                  <Send size={18} />
                </button>
              </div>
            </>
          ) : (
            <div className="flex-1 flex items-center justify-center text-slate-400">
              <div className="text-center">
                <MessageCircle size={40} className="mx-auto mb-3" />
                <p>{mode === "employee" ? "Select an employee conversation." : "Select an HR member to start chatting."}</p>
              </div>
            </div>
          )}
        </main>
      </div>
    </div>
  );
}

export default function ClientChatPage() {
  const { client } = useClientAuth();
  const isEmployee = String(client?.role || "").toUpperCase() === "CLIENT_EMPLOYEE";
  return isEmployee ? <EmployeeClientChat /> : <AdminHRChat />;
}
