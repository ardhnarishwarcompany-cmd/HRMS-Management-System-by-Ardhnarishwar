import axios from "axios";

const HRMS_API = axios.create({
  baseURL: import.meta.env.VITE_HRMS_API_URL || "http://localhost:5000/api",
});

HRMS_API.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

HRMS_API.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem("token");
      localStorage.removeItem("role");
      localStorage.removeItem("email");
      window.location.href = "/";
    }
    return Promise.reject(error);
  },
);

export default HRMS_API;
