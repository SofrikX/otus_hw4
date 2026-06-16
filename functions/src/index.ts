import { getApps, initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2";
import { onRequest } from "firebase-functions/v2/https";

import { app } from "./app";

if (getApps().length === 0) {
  initializeApp();
}

setGlobalOptions({
  region: process.env.FIREBASE_REGION || "us-central1"
});

export const api = onRequest(app);
