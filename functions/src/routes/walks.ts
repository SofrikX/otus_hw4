import { Router } from "express";
import type { RequestHandler } from "express";
import * as logger from "firebase-functions/logger";

import { requireAuth } from "../middleware/auth";
import { joinWalk, listWalks } from "../repositories/walksRepository";
import { AuthenticatedRequest, asyncHandler } from "../types";

export interface WalksRepository {
  listWalks: typeof listWalks;
  joinWalk: typeof joinWalk;
}

const defaultWalksRepository: WalksRepository = {
  listWalks,
  joinWalk
};

export function createWalksRouter(
  repository: WalksRepository = defaultWalksRepository,
  authMiddleware: RequestHandler = requireAuth
) {
  const router = Router();

  router.get(
    "/",
    asyncHandler(async (req, res) => {
      logger.info("GET /walks", { query: req.query });
      const walks = await repository.listWalks(req.query.limit);
      res.json({ data: walks });
    })
  );

  router.post(
    "/:walkId/join",
    authMiddleware,
    asyncHandler(async (req: AuthenticatedRequest, res) => {
      logger.info("POST /walks/:walkId/join", {
        walkId: req.params.walkId,
        uid: req.user?.uid
      });
      const result = await repository.joinWalk(req.params.walkId, req.user!.uid);
      res.json({ data: result });
    })
  );

  return router;
}

export const walksRouter = createWalksRouter();
