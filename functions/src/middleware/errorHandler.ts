import type { NextFunction, Request, Response } from "express";
import * as logger from "firebase-functions/logger";

import { ApiErrorBody, HttpError } from "../types";

export function errorHandler(
  error: unknown,
  req: Request,
  res: Response<ApiErrorBody>,
  _next: NextFunction
) {
  if (error instanceof HttpError) {
    logger.warn("API request failed", {
      code: error.code,
      message: error.message,
      method: req.method,
      path: req.path,
      statusCode: error.statusCode
    });

    res.status(error.statusCode).json({
      error: {
        code: error.code,
        message: error.message
      }
    });
    return;
  }

  logger.error("Unhandled API error", {
    error,
    method: req.method,
    path: req.path
  });

  res.status(500).json({
    error: {
      code: "internal-error",
      message: "Unexpected backend error."
    }
  });
}
