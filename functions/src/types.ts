import type { DecodedIdToken } from "firebase-admin/auth";
import type { NextFunction, Request, Response } from "express";

export type ErrorCode =
  | "validation-error"
  | "unauthorized"
  | "forbidden"
  | "not-found"
  | "internal-error";

export interface ApiErrorBody {
  error: {
    code: ErrorCode;
    message: string;
    details?: ValidationErrorDetail[];
    requestId?: string;
  };
}

export interface ValidationErrorDetail {
  field: string;
  message: string;
}

export class HttpError extends Error {
  constructor(
    public readonly statusCode: number,
    public readonly code: ErrorCode,
    message: string,
    public readonly details?: ValidationErrorDetail[]
  ) {
    super(message);
    this.name = "HttpError";
  }
}

export interface AuthenticatedRequest extends Request {
  user?: DecodedIdToken;
}

export type AsyncHandler<TReq extends Request = Request> = (
  req: TReq,
  res: Response,
  next: NextFunction
) => Promise<void>;

export function asyncHandler<TReq extends Request = Request>(
  handler: AsyncHandler<TReq>
) {
  return (req: Request, res: Response, next: NextFunction) => {
    handler(req as TReq, res, next).catch(next);
  };
}

export interface CreatePostInput {
  authorId: string;
  petId: string;
  text?: string;
  imageUrls?: string[];
  authorName?: string;
  petName?: string;
  petPhotoUrl?: string | null;
  petEmoji?: string | null;
  imageEmoji?: string | null;
}

export interface CreatePetInput {
  ownerId: string;
  ownerName: string;
  name: string;
  animalType: string;
  breed?: string | null;
  age?: number | null;
  description?: string | null;
  photoUrl?: string | null;
  photoEmoji?: string | null;
}
