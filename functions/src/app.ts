import cors from "cors";
import express from "express";
import type { RequestHandler } from "express";
import * as logger from "firebase-functions/logger";

import { errorHandler } from "./middleware/errorHandler";
import { createPetsRouter, PetsRepository } from "./routes/pets";
import { createPostsRouter, PostsRepository } from "./routes/posts";
import { createWalksRouter, WalksRepository } from "./routes/walks";
import { HttpError } from "./types";

const localOrigins = [
  "http://localhost:3000",
  "http://localhost:5000",
  "http://localhost:5173",
  "http://localhost:8080",
  "http://localhost:8081",
  "http://127.0.0.1:3000",
  "http://127.0.0.1:5000",
  "http://127.0.0.1:5173",
  "http://127.0.0.1:8080",
  "http://127.0.0.1:8081"
];

function configuredOrigins() {
  return (process.env.CORS_ORIGIN ?? "")
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
}

export interface AppDependencies {
  authMiddleware?: RequestHandler;
  petsRepository?: PetsRepository;
  postsRepository?: PostsRepository;
  walksRepository?: WalksRepository;
}

export function createApp(dependencies: AppDependencies = {}) {
  const app = express();

  app.use(
    cors({
      origin(origin, callback) {
        const allowedOrigins = new Set([...localOrigins, ...configuredOrigins()]);

        if (!origin || allowedOrigins.has(origin)) {
          callback(null, true);
          return;
        }

        callback(new HttpError(403, "forbidden", "CORS origin is not allowed."));
      }
    })
  );

  app.use(express.json({ limit: "1mb" }));

  app.use((req, _res, next) => {
    logger.info("Incoming API request", {
      method: req.method,
      path: req.path
    });
    next();
  });

  app.get("/health", (_req, res) => {
    res.json({ status: "ok" });
  });

  app.use(
    "/posts",
    createPostsRouter(dependencies.postsRepository, dependencies.authMiddleware)
  );
  app.use(
    "/pets",
    createPetsRouter(dependencies.petsRepository, dependencies.authMiddleware)
  );
  app.use(
    "/walks",
    createWalksRouter(dependencies.walksRepository, dependencies.authMiddleware)
  );

  app.use((_req, _res, next) => {
    next(new HttpError(404, "not-found", "Endpoint not found."));
  });

  app.use(errorHandler);

  return app;
}

export const app = createApp();
