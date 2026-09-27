import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import axios from "axios";
import { Send, Loader2, Check, CheckCheck } from "lucide-react";

const BASE_URL = import.meta.env.VITE_API_BASE_URL;
const IST = "Asia/Kolkata";

const TYPE_LABEL = {
  hr: "HR",
  it: "IT",
  superadmin: "Superadmin",
};

const TYPE_COLOR = {
  hr: "text-pink-600",
  it: "text-indigo-600",
  superadmin: "text-amber-600",
};

const initials = (name) => {
  const parts = String(name || "User")
    .trim()
    .split(/\s+/)
    .filter(Boolean);

  if (!parts.length) return "U";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();

  return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
};

/*
 * MySQL DATETIME has no timezone information.
 * Backend returns DB timestamps such as:
 *   2026-09-20 05:52:01
 *
 * Treat those timestamps as server/database time and display
 * them consistently in India time.
 */
const parseDbDate = (value) => {
  if (!value) return null;

  if (value instanceof Date) {
    return value;
  }

  const raw = String(value).trim();

  if (!raw) return null;

  const normalized = raw.includes("T")
    ? raw
    : raw.replace(" ", "T");

  /*
   * The HRMS server/database is expected to operate on IST.
   * Explicitly attach +05:30 when MySQL returned a timezone-less
   * DATETIME so the browser does not reinterpret it incorrectly.
   */
  if (!/[zZ]|[+-]\d{2}:\d{2}$/.test(normalized)) {
    return new Date(`${normalized}+05:30`);
  }

  return new Date(normalized);
};

const formatTime = (value) => {
  const date = parseDbDate(value);

  if (!date || Number.isNaN(date.getTime())) return "";

  return new Intl.DateTimeFormat("en-IN", {
    timeZone: IST,
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  }).format(date);
};

const dayKey = (value) => {
  const date = parseDbDate(value);

  if (!date || Number.isNaN(date.getTime())) return "";

  return new Intl.DateTimeFormat("en-CA", {
    timeZone: IST,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
};

const dayLabel = (value) => {
  const date = parseDbDate(value);

  if (!date || Number.isNaN(date.getTime())) return "";

  const today = new Date();

  const todayKey = new Intl.DateTimeFormat("en-CA", {
    timeZone: IST,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(today);

  const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);

  const yesterdayKey = new Intl.DateTimeFormat("en-CA", {
    timeZone: IST,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(yesterday);

  const currentKey = dayKey(value);

  if (currentKey === todayKey) return "Today";
  if (currentKey === yesterdayKey) return "Yesterday";

  return new Intl.DateTimeFormat("en-IN", {
    timeZone: IST,
    day: "numeric",
    month: "short",
    year: "numeric",
  }).format(date);
};

const sameMessage = (a, b) => {
  if (!a || !b) return false;

  if (a.id && b.id) {
    return Number(a.id) === Number(b.id);
  }

  return (
    String(a.message || "") === String(b.message || "") &&
    String(a.created_at || "") === String(b.created_at || "") &&
    Number(a.sender_id || 0) === Number(b.sender_id || 0)
  );
};

export default function InternalChatWindow({ activeChat, myType }) {
  const [messages, setMessages] = useState([]);
  const [text, setText] = useState("");
  const [sending, setSending] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const bottomRef = useRef(null);
  const firstLoadRef = useRef(true);
  const mountedRef = useRef(true);

  const token = localStorage.getItem("hrms_it_Token");
  const room = activeChat?.room;

  const auth = useMemo(
    () => ({
      headers: {
        Authorization: `Bearer ${token}`,
      },
    }),
    [token],
  );

  const markRead = useCallback(async () => {
    if (!room) return;

    try {
      await axios.post(
        `${BASE_URL}/chat/internal/read`,
        { room },
        auth,
      );
    } catch (err) {
      console.error("Mark internal chat read error:", err);
    }
  }, [room, auth]);

  const load = useCallback(
    async (showLoader = false) => {
      if (!room) return;

      if (showLoader) {
        setLoading(true);
      }

      try {
        const res = await axios.get(
          `${BASE_URL}/chat/internal/${encodeURIComponent(room)}`,
          auth,
        );

        const serverMessages = Array.isArray(res.data?.data)
          ? res.data.data
          : [];

        if (!mountedRef.current) return;

        setMessages(serverMessages);
        setError("");

        /*
         * Opening an active chat means messages received from
         * the other employee are now read.
         */
        await markRead();
      } catch (err) {
        if (!mountedRef.current) return;

        console.error("Internal chat load error:", err);

        const message =
          err?.response?.data?.message ||
          "Unable to load conversation.";

        setError(message);
      } finally {
        if (mountedRef.current) {
          setLoading(false);
        }
      }
    },
    [room, auth, markRead],
  );

  useEffect(() => {
    mountedRef.current = true;

    firstLoadRef.current = true;
    setMessages([]);
    setText("");
    setError("");

    if (!room) {
      setLoading(false);
      return undefined;
    }

    load(true);

    const interval = setInterval(() => {
      load(false);
    }, 2500);

    return () => {
      mountedRef.current = false;
      clearInterval(interval);
    };
  }, [room, load]);

  useEffect(() => {
    if (firstLoadRef.current) {
      if (messages.length > 0) {
        bottomRef.current?.scrollIntoView();
      }

      firstLoadRef.current = false;
      return;
    }

    const container = bottomRef.current?.parentElement;

    if (!container) return;

    const nearBottom =
      container.scrollHeight -
        container.scrollTop -
        container.clientHeight <
      160;

    if (nearBottom) {
      bottomRef.current?.scrollIntoView({
        behavior: "smooth",
      });
    }
  }, [messages]);

  const sendMessage = async () => {
    const cleanText = text.trim();

    if (!cleanText || sending || !room) return;

    setSending(true);
    setError("");

    try {
      const res = await axios.post(
        `${BASE_URL}/chat/internal/send`,
        {
          room,
          recipientId: Number(activeChat?.recipientId),
          message: cleanText,
          senderType: myType,
        },
        auth,
      );

      const sentMessage = res.data?.data;

      if (!sentMessage?.id) {
        throw new Error("Server did not return the sent message.");
      }

      /*
       * Server response is the source of truth.
       * Never create a fake frontend timestamp/message object.
       */
      setMessages((prev) => {
        const exists = prev.some((item) =>
          sameMessage(item, sentMessage),
        );

        if (exists) return prev;

        return [...prev, sentMessage];
      });

      setText("");

      /*
       * Reload immediately so the list and room both reflect
       * the actual database state.
       */
      await load(false);
    } catch (err) {
      console.error("Send internal message error:", err);

      setError(
        err?.response?.data?.message ||
          err?.message ||
          "Message could not be sent.",
      );
    } finally {
      setSending(false);
    }
  };

  const handleKey = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      if (e.nativeEvent?.isComposing || e.keyCode === 229) return;

      e.preventDefault();
      sendMessage();
    }
  };

  if (!activeChat) return null;

  let lastDay = null;

  return (
    <div className="flex min-h-0 flex-1 flex-col">
      {/* HEADER */}
      <div className="flex h-16 shrink-0 items-center gap-3 border-b bg-white px-5">
        <div className="group relative h-10 w-10 shrink-0">
          <div className="flex h-10 w-10 items-center justify-center overflow-hidden rounded-full bg-gradient-to-r from-indigo-500 to-violet-500 font-bold text-white shadow-sm ring-2 ring-white transition-all duration-200 group-hover:-translate-y-0.5 group-hover:scale-110 group-hover:animate-bounce">
            {activeChat.avatar ? (
              <img
                src={activeChat.avatar}
                alt={activeChat.name || "Employee"}
                className="h-full w-full object-cover"
                onError={(e) => {
                  e.currentTarget.style.display = "none";
                }}
              />
            ) : (
              initials(activeChat.name)
            )}
          </div>

          <span className="absolute bottom-0 right-0 h-2.5 w-2.5 rounded-full border-2 border-white bg-emerald-500" />
        </div>

        <div className="min-w-0">
          <div className="truncate font-semibold text-gray-800">
            {activeChat.name || "Employee"}
          </div>

          <div className="flex items-center gap-1 text-xs text-green-600">
            <span className="inline-block h-1.5 w-1.5 rounded-full bg-green-500" />
            {TYPE_LABEL[activeChat.contactType] || "Employee"}
          </div>
        </div>
      </div>

      {/* ERROR */}
      {error && (
        <div className="shrink-0 border-b border-red-100 bg-red-50 px-4 py-2 text-xs font-medium text-red-600">
          {error}
        </div>
      )}

      {/* MESSAGES */}
      <div className="flex-1 overflow-y-auto bg-[#eae6df] px-4 py-4 md:px-10">
        {loading && messages.length === 0 ? (
          <div className="flex h-full items-center justify-center text-sm text-slate-400">
            <Loader2
              size={18}
              className="mr-2 animate-spin"
            />
            Loading messages...
          </div>
        ) : messages.length === 0 ? (
          <div className="flex h-full items-center justify-center">
            <div className="rounded-2xl bg-white/80 px-5 py-3 text-center text-xs text-slate-400 shadow-sm">
              No messages yet.
              <br />
              Start a private conversation with{" "}
              <span className="font-semibold text-slate-600">
                {activeChat.name || "this employee"}
              </span>
              .
            </div>
          </div>
        ) : (
          messages.map((msg, index) => {
            const isMine = msg.sender_type === myType;
            const day = dayLabel(msg.created_at);
            const showDay = day !== lastDay;

            lastDay = day;

            return (
              <div key={msg.id || `message-${index}`}>
                {showDay && (
                  <div className="my-3 flex justify-center">
                    <span className="rounded-lg bg-white px-3 py-1 text-[11px] font-medium text-gray-500 shadow-sm">
                      {day}
                    </span>
                  </div>
                )}

                <div
                  className={`mb-2 flex items-end gap-2 ${
                    isMine ? "justify-end" : "justify-start"
                  }`}
                >
                  {!isMine && (
                    <div className="group h-7 w-7 shrink-0 overflow-hidden rounded-full bg-white shadow-sm ring-1 ring-slate-200 transition-transform duration-200 hover:-translate-y-0.5 hover:scale-110 hover:animate-bounce">
                      {msg.sender_avatar ? (
                        <img
                          src={msg.sender_avatar}
                          alt={msg.sender_name || "Employee"}
                          className="h-full w-full object-cover"
                          onError={(e) => {
                            e.currentTarget.style.display = "none";
                          }}
                        />
                      ) : (
                        <div className="flex h-full w-full items-center justify-center text-[9px] font-bold text-indigo-500">
                          {initials(msg.sender_name)}
                        </div>
                      )}
                    </div>
                  )}

                  <div
                    className={`relative max-w-[70%] px-3 py-1.5 text-sm leading-relaxed shadow-sm ${
                      isMine
                        ? "rounded-lg rounded-tr-none bg-[#d9fdd3] text-gray-900"
                        : "rounded-lg rounded-tl-none bg-white text-gray-900"
                    }`}
                  >
                    {!isMine && (
                      <div
                        className={`mb-0.5 text-[11px] font-semibold ${
                          TYPE_COLOR[msg.sender_type] ||
                          "text-gray-500"
                        }`}
                      >
                        {msg.sender_name ||
                          TYPE_LABEL[msg.sender_type] ||
                          msg.sender_type}
                      </div>
                    )}

                    <span className="whitespace-pre-line break-words align-middle">
                      {msg.message}
                    </span>

                    <span className="float-right ml-2 mt-2 flex select-none items-center gap-1 text-[10px] text-gray-500">
                      {formatTime(msg.created_at)}

                      {isMine &&
                        (msg.read_at ? (
                          <CheckCheck
                            size={13}
                            className="text-blue-500"
                          />
                        ) : (
                          <Check size={13} />
                        ))}
                    </span>
                  </div>

                  {isMine && (
                    <div className="group h-7 w-7 shrink-0 overflow-hidden rounded-full bg-white shadow-sm ring-1 ring-slate-200 transition-transform duration-200 hover:-translate-y-0.5 hover:scale-110 hover:animate-bounce">
                      {msg.sender_avatar || activeChat.avatar ? (
                        <img
                          src={
                            msg.sender_avatar ||
                            activeChat.avatar
                          }
                          alt="You"
                          className="h-full w-full object-cover"
                          onError={(e) => {
                            e.currentTarget.style.display = "none";
                          }}
                        />
                      ) : (
                        <div className="flex h-full w-full items-center justify-center text-[9px] font-bold text-pink-500">
                          You
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>
            );
          })
        )}

        <div ref={bottomRef} />
      </div>

      {/* INPUT */}
      <div className="shrink-0 border-t bg-[#f0f2f5] px-4 py-3">
        <div className="flex items-center gap-2">
          <input
            value={text}
            onChange={(e) => {
              setText(e.target.value);
              if (error) setError("");
            }}
            onKeyDown={handleKey}
            placeholder={`Message ${
              activeChat.name || "employee"
            }`}
            disabled={sending}
            className="flex-1 rounded-full border border-transparent bg-white px-5 py-2.5 text-sm outline-none shadow-sm focus:border-purple-300 disabled:bg-slate-100"
          />

          <button
            type="button"
            onClick={sendMessage}
            disabled={!text.trim() || sending}
            aria-label="Send message"
            className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-gradient-to-r from-purple-500 to-pink-500 text-white transition hover:scale-105 disabled:from-gray-300 disabled:to-gray-300"
          >
            {sending ? (
              <Loader2
                className="animate-spin"
                size={19}
              />
            ) : (
              <Send size={19} />
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
