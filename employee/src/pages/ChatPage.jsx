import React, { useEffect, useRef, useState } from "react";
import API from "../api/axios";
import { Send, Bot, User, Loader2, Sparkles, ShieldCheck } from "lucide-react";
export default function ChatPage() {
  const [messages, setMessages] = useState([
    { role: "bot", content: "Hello! I am your HR Assistant. How can I help you today?", time: new Date() },
  ]);
  const [sessionId, setSessionId] = useState(null);
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, loading]);

  const sendMessage = async () => {
    const userText = text.trim();
    if (!userText || loading) return;
    setMessages((prev) => [...prev, { role: "user", content: userText, time: new Date() }]);
    setText("");
    setLoading(true);
    try {
      const res = await API.post("/ai-chat/ask", {
        message: userText,
        session_id: sessionId,
        user_type: "EMPLOYEE",
      });
      const aiText = res.data?.answer || res.data?.data?.response || "I could not find an answer for that.";
      setSessionId(res.data?.session_id || res.data?.data?.session_id || sessionId);
      setMessages((prev) => [...prev, { role: "bot", content: aiText, time: new Date() }]);
    } catch (err) {
      const msg = err?.response?.data?.message || "Connection error. Please try again.";
      setMessages((prev) => [...prev, { role: "bot", content: msg, time: new Date() }]);
    } finally {
      setLoading(false);
    }
  };

  const handleKey = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const fmt = (d) => new Date(d).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });

  return (
    <div className="employee-chat-page">
      <main className="employee-chat-wrap">
        <section className="employee-chat-card">
          <header className="employee-chat-hero">
            <div className="employee-chat-avatar"><Bot size={24} /></div>
            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-2 flex-wrap">
                <h1 className="employee-chat-title">HR Assistant</h1>
                <span className="employee-chat-live"><span /> Online</span>
              </div>
              <p className="employee-chat-subtitle">Your private HRMS assistant for employee questions and company policies.</p>
            </div>
            <div className="employee-chat-secure"><ShieldCheck size={16} /> Employee data</div>
          </header>

          <div className="employee-chat-messages">
            <div className="employee-chat-welcome"><Sparkles size={15} /><span>AI-powered HR support</span></div>
            {messages.map((msg, i) => (
              <div key={i} className={`employee-chat-message-row ${msg.role === "user" ? "is-user" : ""}`}>
                <div className={`employee-chat-message-icon ${msg.role === "user" ? "is-user" : ""}`}>
                  {msg.role === "user" ? <User size={16} /> : <Bot size={16} />}
                </div>
                <div className={`employee-chat-bubble ${msg.role === "user" ? "is-user" : ""}`}>
                  <p>{msg.content}</p>
                  <span>{fmt(msg.time)}</span>
                </div>
              </div>
            ))}
            {loading && (
              <div className="employee-chat-message-row">
                <div className="employee-chat-message-icon"><Bot size={16} /></div>
                <div className="employee-chat-bubble typing"><i /><i /><i /></div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          <footer className="employee-chat-composer">
            <div className="employee-chat-input-row">
              <input
                value={text}
                onChange={(e) => setText(e.target.value)}
                onKeyDown={handleKey}
                placeholder="Ask about your leave, salary, attendance, assignments..."
                className="employee-chat-input"
                disabled={loading}
              />
              <button onClick={sendMessage} disabled={!text.trim() || loading} className="employee-chat-send" aria-label="Send message">
                {loading ? <Loader2 className="animate-spin" size={20} /> : <Send size={20} />}
              </button>
            </div>
            <p className="employee-chat-hint">Press Enter to send · Shift + Enter for a new line</p>
          </footer>
        </section>
      </main>
    </div>
  );
}
