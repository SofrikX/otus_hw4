import { Router } from "express";
import type { RequestHandler } from "express";
import * as logger from "firebase-functions/logger";

import { requireAuth } from "../middleware/auth";
import { createPost, listPosts, togglePostLike } from "../repositories/postsRepository";
import { AuthenticatedRequest, asyncHandler } from "../types";

export interface PostsRepository {
  listPosts: typeof listPosts;
  createPost: typeof createPost;
  togglePostLike: typeof togglePostLike;
}

const defaultPostsRepository: PostsRepository = {
  listPosts,
  createPost,
  togglePostLike
};

export function createPostsRouter(
  repository: PostsRepository = defaultPostsRepository,
  authMiddleware: RequestHandler = requireAuth
) {
  const router = Router();

  router.get(
    "/",
    asyncHandler(async (req, res) => {
      logger.info("GET /posts", { query: req.query });
      const posts = await repository.listPosts(req.query.limit);
      res.json({ data: posts });
    })
  );

  router.post(
    "/",
    authMiddleware,
    asyncHandler(async (req: AuthenticatedRequest, res) => {
      logger.info("POST /posts", { uid: req.user?.uid });
      const post = await repository.createPost(req.body, req.user!.uid);
      res.status(201).json({ data: post });
    })
  );

  router.post(
    "/:postId/like",
    authMiddleware,
    asyncHandler(async (req: AuthenticatedRequest, res) => {
      logger.info("POST /posts/:postId/like", {
        postId: req.params.postId,
        uid: req.user?.uid
      });
      const result = await repository.togglePostLike(req.params.postId, req.user!.uid);
      res.json({ data: result });
    })
  );

  return router;
}

export const postsRouter = createPostsRouter();
