import { Router } from "express";
import * as logger from "firebase-functions/logger";

import { requireAuth } from "../middleware/auth";
import { createPost, listPosts, togglePostLike } from "../repositories/postsRepository";
import { AuthenticatedRequest, asyncHandler } from "../types";

export const postsRouter = Router();

postsRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    logger.info("GET /posts", { query: req.query });
    const posts = await listPosts(req.query.limit);
    res.json({ data: posts });
  })
);

postsRouter.post(
  "/",
  requireAuth,
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    logger.info("POST /posts", { uid: req.user?.uid });
    const post = await createPost(req.body, req.user!.uid);
    res.status(201).json({ data: post });
  })
);

postsRouter.post(
  "/:postId/like",
  requireAuth,
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    logger.info("POST /posts/:postId/like", {
      postId: req.params.postId,
      uid: req.user?.uid
    });
    const result = await togglePostLike(req.params.postId, req.user!.uid);
    res.json({ data: result });
  })
);
