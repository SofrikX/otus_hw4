import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import { CreatePostInput, HttpError } from "../types";

const postsCollection = () => getFirestore().collection("posts");

function asIso(value: unknown): unknown {
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  if (Array.isArray(value)) {
    return value.map(asIso);
  }

  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).map(([key, nestedValue]) => [key, asIso(nestedValue)])
    );
  }

  return value;
}

function parseLimit(rawLimit: unknown, fallback = 20, max = 50): number {
  if (rawLimit === undefined) {
    return fallback;
  }

  const limit = Number(rawLimit);
  if (!Number.isInteger(limit) || limit < 1 || limit > max) {
    throw new HttpError(
      400,
      "validation-error",
      `limit must be an integer between 1 and ${max}.`
    );
  }

  return limit;
}

function validateCreatePostInput(input: CreatePostInput, uid: string) {
  if (!input || typeof input !== "object") {
    throw new HttpError(400, "validation-error", "Request body is required.");
  }

  if (input.authorId !== uid) {
    throw new HttpError(
      403,
      "forbidden",
      "authorId must match the authenticated user."
    );
  }

  if (!input.petId || typeof input.petId !== "string") {
    throw new HttpError(400, "validation-error", "petId is required.");
  }

  if (input.text !== undefined && typeof input.text !== "string") {
    throw new HttpError(400, "validation-error", "text must be a string.");
  }

  if ((input.text ?? "").length > 1000) {
    throw new HttpError(
      400,
      "validation-error",
      "text must be 1000 characters or fewer."
    );
  }

  if (
    input.imageUrls !== undefined &&
    (!Array.isArray(input.imageUrls) ||
      input.imageUrls.some((url) => typeof url !== "string"))
  ) {
    throw new HttpError(
      400,
      "validation-error",
      "imageUrls must be an array of strings."
    );
  }
}

export async function listPosts(rawLimit: unknown) {
  const limit = parseLimit(rawLimit);
  const snapshot = await postsCollection()
    .orderBy("createdAt", "desc")
    .limit(limit)
    .get();

  logger.info("Loaded posts", { count: snapshot.size, limit });

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...asIso(doc.data())
  }));
}

export async function createPost(input: CreatePostInput, uid: string) {
  validateCreatePostInput(input, uid);

  const now = FieldValue.serverTimestamp();
  const docRef = postsCollection().doc();
  const post = {
    id: docRef.id,
    authorId: uid,
    authorName: input.authorName ?? "",
    petId: input.petId,
    petName: input.petName ?? "",
    petPhotoUrl: input.petPhotoUrl ?? null,
    petEmoji: input.petEmoji ?? null,
    text: input.text?.trim() ?? "",
    imageUrls: input.imageUrls ?? [],
    imageEmoji: input.imageEmoji ?? null,
    likesCount: 0,
    commentsCount: 0,
    visibility: "public",
    createdAt: now,
    updatedAt: now,
    deletedAt: null
  };

  await docRef.set(post);
  const created = await docRef.get();

  logger.info("Created post", { postId: docRef.id, uid });

  return {
    id: docRef.id,
    ...asIso(created.data() ?? post)
  };
}

export async function togglePostLike(postId: string, uid: string) {
  if (!postId) {
    throw new HttpError(400, "validation-error", "postId is required.");
  }

  const db = getFirestore();
  const postRef = postsCollection().doc(postId);
  const likeRef = postRef.collection("likes").doc(uid);

  return db.runTransaction(async (transaction) => {
    const [postSnapshot, likeSnapshot] = await Promise.all([
      transaction.get(postRef),
      transaction.get(likeRef)
    ]);

    if (!postSnapshot.exists) {
      throw new HttpError(404, "not-found", "Post not found.");
    }

    const currentLikes = Number(postSnapshot.get("likesCount") ?? 0);
    const isLiked = likeSnapshot.exists;
    const nextLikesCount = isLiked
      ? Math.max(currentLikes - 1, 0)
      : currentLikes + 1;

    if (isLiked) {
      transaction.delete(likeRef);
    } else {
      transaction.set(likeRef, {
        userId: uid,
        postId,
        createdAt: FieldValue.serverTimestamp()
      });
    }

    transaction.update(postRef, {
      likesCount: nextLikesCount,
      updatedAt: FieldValue.serverTimestamp()
    });

    logger.info("Toggled post like", {
      postId,
      uid,
      isLiked: !isLiked,
      likesCount: nextLikesCount
    });

    return {
      postId,
      isLiked: !isLiked,
      likesCount: nextLikesCount
    };
  });
}
