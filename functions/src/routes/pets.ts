import { Router } from "express";
import type { RequestHandler } from "express";
import * as logger from "firebase-functions/logger";

import { requireAuth } from "../middleware/auth";
import { createPet, getPetById, listPetsByOwner } from "../repositories/petsRepository";
import { AuthenticatedRequest, asyncHandler } from "../types";

export interface PetsRepository {
  listPetsByOwner: typeof listPetsByOwner;
  getPetById: typeof getPetById;
  createPet: typeof createPet;
}

const defaultPetsRepository: PetsRepository = {
  listPetsByOwner,
  getPetById,
  createPet
};

export function createPetsRouter(
  repository: PetsRepository = defaultPetsRepository,
  authMiddleware: RequestHandler = requireAuth
) {
  const router = Router();

  router.get(
    "/",
    asyncHandler(async (req, res) => {
      logger.info("GET /pets", { query: req.query });
      const pets = await repository.listPetsByOwner(req.query.ownerId);
      res.json({ data: pets });
    })
  );

  router.get(
    "/:petId",
    asyncHandler(async (req, res) => {
      logger.info("GET /pets/:petId", { petId: req.params.petId });
      const pet = await repository.getPetById(req.params.petId);
      res.json({ data: pet });
    })
  );

  router.post(
    "/",
    authMiddleware,
    asyncHandler(async (req: AuthenticatedRequest, res) => {
      logger.info("POST /pets", { uid: req.user?.uid });
      const pet = await repository.createPet(req.body, req.user!.uid);
      res.status(201).json({ data: pet });
    })
  );

  return router;
}

export const petsRouter = createPetsRouter();
