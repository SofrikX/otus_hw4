import assert from "node:assert/strict";
import { createServer, request, Server } from "node:http";
import test from "node:test";

import type { RequestHandler } from "express";

import { createApp } from "../app";
import { createPost } from "../repositories/postsRepository";
import type { PostsRepository } from "../routes/posts";
import type { WalksRepository } from "../routes/walks";
import type { AuthenticatedRequest } from "../types";

let socketCounter = 0;

async function startApi(
  options: Parameters<typeof createApp>[0] = {}
): Promise<{ socketPath: string; close: () => Promise<void> }> {
  const server = createServer(createApp(options));
  socketCounter += 1;
  const socketPath = `/tmp/pc-${process.pid}-${socketCounter}.sock`;

  await new Promise<void>((resolve) => {
    server.listen(socketPath, resolve);
  });

  return {
    socketPath,
    close: () => closeServer(server)
  };
}

async function closeServer(server: Server): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    server.close((error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });
}

async function requestJson(
  socketPath: string,
  path: string,
  init: {
    method?: string;
    headers?: Record<string, string>;
    body?: string;
  } = {}
): Promise<{ status: number; body: any }> {
  const rawBody = await new Promise<string>((resolve, reject) => {
    const req = request(
      {
        socketPath,
        path,
        method: init.method ?? "GET",
        headers: {
          "content-type": "application/json",
          ...(init.body ? { "content-length": Buffer.byteLength(init.body) } : {}),
          ...init.headers
        }
      },
      (res) => {
        const chunks: Buffer[] = [];

        res.on("data", (chunk) => chunks.push(Buffer.from(chunk)));
        res.on("end", () => {
          resolve(
            JSON.stringify({
              status: res.statusCode ?? 0,
              body: JSON.parse(Buffer.concat(chunks).toString("utf8"))
            })
          );
        });
      }
    );

    req.on("error", reject);
    req.end(init.body);
  });

  return JSON.parse(rawBody);
}

const authenticatedUser: RequestHandler = (req, _res, next) => {
  (req as AuthenticatedRequest).user = {
    uid: "user-anya"
  } as AuthenticatedRequest["user"];
  next();
};

const postsRepository: PostsRepository = {
  async listPosts(rawLimit) {
    assert.equal(rawLimit, "2");
    return [
      {
        id: "post-1",
        authorId: "user-anya",
        petId: "pet-bruno",
        text: "Сегодня Бруно отлично погулял.",
        likesCount: 18,
        commentsCount: 4
      }
    ];
  },
  async createPost(input, uid) {
    return {
      id: "post-created",
      authorId: uid,
      petId: input.petId,
      text: input.text ?? "",
      likesCount: 0,
      commentsCount: 0,
      visibility: "public"
    };
  },
  async togglePostLike(postId, uid) {
    assert.equal(postId, "post-1");
    assert.equal(uid, "user-anya");
    return {
      postId,
      isLiked: true,
      likesCount: 19
    };
  }
};

const walksRepository: WalksRepository = {
  async listWalks(rawLimit) {
    assert.equal(rawLimit, "3");
    return [
      {
        id: "walk-1",
        title: "Корги-встреча в парке",
        place: "Парк Горького",
        participantsCount: 6,
        status: "active"
      }
    ];
  },
  async joinWalk(walkId, uid) {
    return {
      walkId,
      uid,
      isJoined: true,
      participantsCount: 7
    };
  }
};

test("GET /posts returns posts", async () => {
  const api = await startApi({ postsRepository });
  try {
    const result = await requestJson(api.socketPath, "/posts?limit=2");

    assert.equal(result.status, 200);
    assert.deepEqual(result.body, {
      data: [
        {
          id: "post-1",
          authorId: "user-anya",
          petId: "pet-bruno",
          text: "Сегодня Бруно отлично погулял.",
          likesCount: 18,
          commentsCount: 4
        }
      ]
    });
  } finally {
    await api.close();
  }
});

test("POST /posts without Authorization returns unauthorized", async () => {
  const api = await startApi({ postsRepository });
  try {
    const result = await requestJson(api.socketPath, "/posts", {
      method: "POST",
      body: JSON.stringify({
        authorId: "user-anya",
        petId: "pet-bruno",
        text: "Новый пост"
      })
    });

    assert.equal(result.status, 401);
    assert.equal(result.body.error.code, "unauthorized");
  } finally {
    await api.close();
  }
});

test("POST /posts returns validation error for invalid body", async () => {
  const api = await startApi({
    authMiddleware: authenticatedUser,
    postsRepository: {
      ...postsRepository,
      createPost
    }
  });
  try {
    const result = await requestJson(api.socketPath, "/posts", {
      method: "POST",
      headers: {
        authorization: "Bearer test-token"
      },
      body: JSON.stringify({
        authorId: "user-anya",
        text: "Пост без petId"
      })
    });

    assert.equal(result.status, 400);
    assert.deepEqual(result.body, {
      error: {
        code: "validation-error",
        message: "petId is required."
      }
    });
  } finally {
    await api.close();
  }
});

test("POST /posts/:postId/like toggles like for authenticated user", async () => {
  const api = await startApi({
    authMiddleware: authenticatedUser,
    postsRepository
  });
  try {
    const result = await requestJson(api.socketPath, "/posts/post-1/like", {
      method: "POST",
      headers: {
        authorization: "Bearer test-token"
      }
    });

    assert.equal(result.status, 200);
    assert.deepEqual(result.body, {
      data: {
        postId: "post-1",
        isLiked: true,
        likesCount: 19
      }
    });
  } finally {
    await api.close();
  }
});

test("GET /walks returns walks", async () => {
  const api = await startApi({ walksRepository });
  try {
    const result = await requestJson(api.socketPath, "/walks?limit=3");

    assert.equal(result.status, 200);
    assert.deepEqual(result.body, {
      data: [
        {
          id: "walk-1",
          title: "Корги-встреча в парке",
          place: "Парк Горького",
          participantsCount: 6,
          status: "active"
        }
      ]
    });
  } finally {
    await api.close();
  }
});

test("POST /walks/:walkId/join without Authorization returns unauthorized", async () => {
  const api = await startApi({ walksRepository });
  try {
    const result = await requestJson(api.socketPath, "/walks/walk-1/join", {
      method: "POST"
    });

    assert.equal(result.status, 401);
    assert.equal(result.body.error.code, "unauthorized");
  } finally {
    await api.close();
  }
});
