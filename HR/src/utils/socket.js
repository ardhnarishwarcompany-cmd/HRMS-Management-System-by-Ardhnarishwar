import { io } from "socket.io-client";

// Never fall back to the Vite dev server for Socket.IO. If no backend URL is
// configured, keep the socket disconnected instead of producing a noisy
// WebSocket error in the browser console.
const configuredUrl = import.meta.env.VITE_API_BASE_URL || "";
const BASE_URL = configuredUrl.replace(/\/api\/?$/, "");

export const socket = io(BASE_URL || undefined, {
  transports: ["websocket"],
  autoConnect: Boolean(BASE_URL),
});
