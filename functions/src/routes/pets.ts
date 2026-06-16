import { Router } from "express";
import * as logger from "firebase-functions/logger";

import { requireAuth } from "../middleware/auth";
import { createPet, getPetById, listPetsByOwner } from "../repositories/petsRepository";
import { AuthenticatedRequest, asyncHandler } from "../types";

export const petsRouter = Router();

petsRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    logger.info("GET /pets", { query: req.query });
    const pets = await listPetsByOwner(req.query.ownerId);
    res.json({ data: pets });
  })
);

petsRouter.get(
  "/:petId",
  asyncHandler(async (req, res) => {
    logger.info("GET /pets/:petId", { petId: req.params.petId });
    const pet = await getPetById(req.params.petId);
    res.json({ data: pet });
  })
);

petsRouter.post(
  "/",
  requireAuth,
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    logger.info("POST /pets", { uid: req.user?.uid });
    const pet = await createPet(req.body, req.user!.uid);
    res.status(201).json({ data: pet });
  })
);
