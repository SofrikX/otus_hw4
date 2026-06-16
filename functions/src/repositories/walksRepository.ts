import {
  FieldValue,
  GeoPoint,
  Timestamp,
  getFirestore
} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import { HttpError } from "../types";

const walksCollection = () => getFirestore().collection("walks");

function asIso(value: unknown): unknown {
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  if (value instanceof GeoPoint) {
    return {
      latitude: value.latitude,
      longitude: value.longitude
    };
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

export async function listWalks(rawLimit: unknown) {
  const limit = parseLimit(rawLimit);
  const snapshot = await walksCollection()
    .orderBy("startsAt", "asc")
    .limit(limit)
    .get();

  logger.info("Loaded walks", { count: snapshot.size, limit });

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...asIso(doc.data())
  }));
}

export async function joinWalk(walkId: string, uid: string) {
  if (!walkId) {
    throw new HttpError(400, "validation-error", "walkId is required.");
  }

  const walkRef = walksCollection().doc(walkId);

  return getFirestore().runTransaction(async (transaction) => {
    const walkSnapshot = await transaction.get(walkRef);

    if (!walkSnapshot.exists) {
      throw new HttpError(404, "not-found", "Walk not found.");
    }

    const data = walkSnapshot.data() ?? {};
    if (data.status !== "active") {
      throw new HttpError(403, "forbidden", "Walk is not available to join.");
    }

    const participantIds = Array.isArray(data.participantIds)
      ? data.participantIds
      : [];
    const alreadyJoined = participantIds.includes(uid);
    const participantsCount = Number(data.participantsCount ?? participantIds.length);

    if (alreadyJoined) {
      return {
        walkId,
        isJoined: true,
        participantsCount
      };
    }

    const nextParticipantsCount = participantsCount + 1;
    transaction.update(walkRef, {
      participantIds: FieldValue.arrayUnion(uid),
      participantsCount: nextParticipantsCount,
      updatedAt: FieldValue.serverTimestamp()
    });

    logger.info("Joined walk", {
      walkId,
      uid,
      participantsCount: nextParticipantsCount
    });

    return {
      walkId,
      isJoined: true,
      participantsCount: nextParticipantsCount
    };
  });
}
