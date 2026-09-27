import { clientUnifiedAuthMiddleware } from "./clientUnifiedAuth.middleware.js";

/**
 * Authentication for CLIENT PORTAL read endpoints.
 *
 * Both client_admin and CLIENT_EMPLOYEE tokens are valid here.
 * clientUnifiedAuthMiddleware also resolves the employee token to the
 * parent client's tenant and attaches req.client, which keeps existing
 * client controllers compatible.
 */
export const clientPortalAuthMiddleware = clientUnifiedAuthMiddleware;
export const clientAuthMiddleware = clientUnifiedAuthMiddleware;