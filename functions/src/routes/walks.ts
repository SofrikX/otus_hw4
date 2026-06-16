import { Router } from "express";
import * as logger from "firebase-functions/logger";

import { requireAuth } from "../middleware/auth";
import { joinWalk, listWalks } from "../repositories/walksRepository";
import { AuthenticatedRequest, asyncHandler } from "../types";

export const walksRouter = Router();

walksRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    logger.info("GET /walks", { query: req.query });
    const walks = await listWalks(req.query.limit);
    res.json({ data: walks });
  })
);

walksRouter.post(
  "/:walkId/join",
  requireAuth,
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    logger.info("POST /walks/:walkId/join", {
      walkId: req.params.walkId,
      uid: req.user?.uid
    });
    const result = await joinWalk(req.params.walkId, req.user!.uid);
    res.json({ data: result });
  })
);
