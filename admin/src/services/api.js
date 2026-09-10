import axios from "axios";

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  (import.meta.env.DEV ? "http://localhost:5000/api" : "/api");

const API = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: false, // later we can make true if using cookies
});

API.interceptors.request.use((config) => {
  const token = localStorage.getItem("hrms_admin_token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
export default API;
