import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import { CreatePetInput, HttpError } from "../types";

const petsCollection = () => getFirestore().collection("pets");

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

function serializeRecord(data: FirebaseFirestore.DocumentData | undefined) {
  return asIso(data ?? {}) as Record<string, unknown>;
}

function requireString(
  value: unknown,
  fieldName: string,
  maxLength: number
): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpError(400, "validation-error", `${fieldName} is required.`);
  }

  const trimmed = value.trim();
  if (trimmed.length > maxLength) {
    throw new HttpError(
      400,
      "validation-error",
      `${fieldName} must be ${maxLength} characters or fewer.`
    );
  }

  return trimmed;
}

function optionalString(
  value: unknown,
  fieldName: string,
  maxLength: number
): string | null {
  if (value === undefined || value === null || value === "") {
    return null;
  }

  if (typeof value !== "string") {
    throw new HttpError(400, "validation-error", `${fieldName} must be a string.`);
  }

  const trimmed = value.trim();
  if (trimmed.length > maxLength) {
    throw new HttpError(
      400,
      "validation-error",
      `${fieldName} must be ${maxLength} characters or fewer.`
    );
  }

  return trimmed;
}

function optionalAge(value: unknown): number | null {
  if (value === undefined || value === null) {
    return null;
  }

  const age = Number(value);
  if (!Number.isInteger(age) || age < 0 || age > 30) {
    throw new HttpError(
      400,
      "validation-error",
      "age must be an integer between 0 and 30."
    );
  }

  return age;
}

function validateCreatePetInput(input: CreatePetInput, uid: string) {
  if (!input || typeof input !== "object") {
    throw new HttpError(400, "validation-error", "Request body is required.");
  }

  if (input.ownerId !== uid) {
    throw new HttpError(
      403,
      "forbidden",
      "ownerId must match the authenticated user."
    );
  }
}

export async function getPetById(petId: string) {
  if (!petId) {
    throw new HttpError(400, "validation-error", "petId is required.");
  }

  const snapshot = await petsCollection().doc(petId).get();
  if (!snapshot.exists) {
    throw new HttpError(404, "not-found", "Pet not found.");
  }

  logger.info("Loaded pet", { petId });

  return {
    id: snapshot.id,
    ...serializeRecord(snapshot.data())
  };
}

export async function listPetsByOwner(ownerId: unknown) {
  if (typeof ownerId !== "string" || ownerId.trim().length === 0) {
    throw new HttpError(400, "validation-error", "ownerId is required.");
  }

  const normalizedOwnerId = ownerId.trim();
  const snapshot = await petsCollection()
    .where("ownerId", "==", normalizedOwnerId)
    .orderBy("createdAt", "desc")
    .get();

  logger.info("Loaded owner pets", {
    ownerId: normalizedOwnerId,
    count: snapshot.size
  });

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...serializeRecord(doc.data())
  }));
}

export async function createPet(input: CreatePetInput, uid: string) {
  validateCreatePetInput(input, uid);

  const now = FieldValue.serverTimestamp();
  const docRef = petsCollection().doc();
  const pet = {
    id: docRef.id,
    ownerId: uid,
    ownerName: requireString(input.ownerName, "ownerName", 80),
    name: requireString(input.name, "name", 50),
    animalType: requireString(input.animalType, "animalType", 30),
    breed: optionalString(input.breed, "breed", 80),
    age: optionalAge(input.age),
    description: optionalString(input.description, "description", 500),
    photoUrl: optionalString(input.photoUrl, "photoUrl", 2000),
    photoEmoji: optionalString(input.photoEmoji, "photoEmoji", 16),
    createdAt: now,
    updatedAt: now
  };

  await docRef.set(pet);
  const created = await docRef.get();

  logger.info("Created pet", { petId: docRef.id, uid });

  return {
    id: docRef.id,
    ...serializeRecord(created.data() ?? pet)
  };
}
