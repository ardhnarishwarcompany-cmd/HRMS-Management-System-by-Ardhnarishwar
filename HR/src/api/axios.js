import axios from "axios";

const baseURL =
  import.meta.env.VITE_API_BASE_URL ||
  (import.meta.env.DEV ? "http://localhost:5000/api" : "");

const instance = axios.create({ baseURL });

instance.interceptors.request.use((config) => {
  const token =
    localStorage.getItem("hrms_hr_Token") ||
    localStorage.getItem("hrToken") ||
    localStorage.getItem("token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export default instance;
