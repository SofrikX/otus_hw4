import { getAuth } from "firebase-admin/auth";
import type { NextFunction, Response } from "express";
import * as logger from "firebase-functions/logger";

import { AuthenticatedRequest, HttpError } from "../types";

export type VerifyIdToken = ReturnType<typeof getAuth>["verifyIdToken"];

export function createRequireAuth(
  verifyIdToken: VerifyIdToken = (token) => getAuth().verifyIdToken(token)
) {
  return async function requireAuth(
    req: AuthenticatedRequest,
    _res: Response,
    next: NextFunction
  ) {
    try {
      const header = req.header("authorization") ?? "";
      const match = header.match(/^Bearer (.+)$/i);

      if (!match) {
        throw new HttpError(401, "unauthorized", "Firebase ID token is required.");
      }

      req.user = await verifyIdToken(match[1]);
      logger.info("Authenticated API request", {
        uid: req.user.uid,
        method: req.method,
        path: req.path
      });
      next();
    } catch (error) {
      if (error instanceof HttpError) {
        next(error);
        return;
      }

      logger.warn("Failed to verify Firebase ID token", { error });
      next(new HttpError(401, "unauthorized", "Invalid Firebase ID token."));
    }
  };
}

export const requireAuth = createRequireAuth();
