import jwt from "jsonwebtoken";
import { ENV } from "../config/env.js";
import { clientUnifiedAuthMiddleware } from "./clientUnifiedAuth.middleware.js";
import { protect } from "./auth.middleware.js";
export const complaintPortalAuth = async (req,res,next) => {
  try {
    const auth=String(req.headers.authorization||''); if(!auth.startsWith('Bearer ')) return res.status(401).json({success:false,message:'Unauthorized: Token missing'});
    const decoded=jwt.verify(auth.slice(7).trim(),ENV.JWT_SECRET); const role=String(decoded.role||'').toUpperCase();
    if(role==='CLIENT_ADMIN'||role==='CLIENT_EMPLOYEE') return clientUnifiedAuthMiddleware(req,res,next);
    return protect(["SUPER_ADMIN","MANAGER","hr","client_admin","sales","it"])(req,res,next);
  } catch(e){ return res.status(401).json({success:false,message:'Invalid or expired token'}); }
};
