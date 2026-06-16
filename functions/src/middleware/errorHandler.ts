import type { NextFunction, Request, Response } from "express";
import * as logger from "firebase-functions/logger";

import { ApiErrorBody, HttpError } from "../types";

function requestId(req: Request): string {
  const headerValue = req.header("x-request-id");
  if (headerValue?.trim()) {
    return headerValue.trim();
  }

  return `${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

function logHttpError(error: HttpError, req: Request, id: string) {
  const payload = {
    code: error.code,
    details: error.details,
    message: error.message,
    method: req.method,
    path: req.path,
    requestId: id,
    statusCode: error.statusCode
  };

  if (error.statusCode >= 500) {
    logger.error("API 500 internal-error", payload);
    return;
  }

  if (error.statusCode === 401 || error.statusCode === 403) {
    logger.warn(`API ${error.statusCode} auth/access error`, payload);
    return;
  }

  if (error.statusCode === 400 || error.statusCode === 404) {
    logger.warn(`API ${error.statusCode} request error`, payload);
    return;
  }

  logger.warn("API request failed", payload);
}

function isJsonParseError(error: unknown): error is SyntaxError & { status?: number } {
  return error instanceof SyntaxError && (error as { status?: number }).status === 400;
}

function errorSummary(error: unknown) {
  if (error instanceof Error) {
    return {
      errorMessage: error.message,
      errorName: error.name,
      errorStack: error.stack
    };
  }

  return { error };
}

export function errorHandler(
  error: unknown,
  req: Request,
  res: Response<ApiErrorBody>,
  _next: NextFunction
) {
  const id = requestId(req);

  if (isJsonParseError(error)) {
    const httpError = new HttpError(
      400,
      "validation-error",
      "Request body must be valid JSON.",
      [{ field: "body", message: "Invalid JSON syntax." }]
    );

    logHttpError(httpError, req, id);
    res.status(httpError.statusCode).json({
      error: {
        code: httpError.code,
        details: httpError.details,
        message: httpError.message,
        requestId: id
      }
    });
    return;
  }

  if (error instanceof HttpError) {
    logHttpError(error, req, id);

    res.status(error.statusCode).json({
      error: {
        code: error.code,
        details: error.details,
        message: error.message,
        requestId: id
      }
    });
    return;
  }

  logger.error("Unhandled API error", {
    ...errorSummary(error),
    method: req.method,
    path: req.path,
    requestId: id,
    statusCode: 500
  });

  res.status(500).json({
    error: {
      code: "internal-error",
      message: "Unexpected backend error.",
      requestId: id
    }
  });
}
