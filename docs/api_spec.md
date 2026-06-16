# API Spec — PetConnect Cloud Functions HTTP API

## Overview

PetConnect HW5 uses Firebase Cloud Functions with an Express HTTP API. The API works with Cloud Firestore through Firebase Admin SDK and replaces the generic Supabase API requirement from the original homework.

Exported function:

```text
api
```

Local emulator base URL:

```text
http://127.0.0.1:5001/{FIREBASE_PROJECT_ID}/{FIREBASE_REGION}/api
```

Default region:

```text
us-central1
```

## Authentication

Protected endpoints require a Firebase ID token:

```http
Authorization: Bearer <firebase-id-token>
```

The backend verifies the token with Firebase Admin SDK and uses `uid` as the trusted user id.

## CORS

The API allows common local Flutter Web origins by default:

- `http://localhost:3000`
- `http://localhost:5000`
- `http://localhost:5173`
- `http://localhost:8080`
- `http://localhost:8081`
- `http://127.0.0.1:3000`
- `http://127.0.0.1:5000`
- `http://127.0.0.1:5173`
- `http://127.0.0.1:8080`
- `http://127.0.0.1:8081`

Production origins can be configured with comma-separated environment variable:

```text
CORS_ORIGIN=https://petconnect.example.com,https://app.petconnect.example.com
```

## Error Model

All errors use one response shape:

```json
{
  "error": {
    "code": "validation-error",
    "message": "Human readable error message."
  }
}
```

Supported status/code pairs:

| Status | Code | Meaning |
|---|---|---|
| `400` | `validation-error` | Invalid input |
| `401` | `unauthorized` | Missing or invalid Firebase ID token |
| `403` | `forbidden` | Authenticated user cannot perform the operation |
| `404` | `not-found` | Resource not found |
| `500` | `internal-error` | Unexpected backend error |

## Endpoints

### GET /health

Returns API health status.

Response:

```json
{
  "status": "ok"
}
```

### GET /pets/:petId

Returns one pet profile by Firestore document id.

Auth: not required by HTTP middleware for HW5 read-only MVP. Firestore Admin SDK bypasses Security Rules, so public exposure should be decided before production deploy.

Response:

```json
{
  "data": {
    "id": "pet-1",
    "ownerId": "user-1",
    "ownerName": "Аня",
    "name": "Бруно",
    "animalType": "dog",
    "breed": "Корги",
    "age": 3,
    "description": "Обожает мячики, людей и короткие пробежки в парке.",
    "photoUrl": "https://storage.googleapis.com/petconnect/pets/user-1/pet-1.jpg",
    "photoEmoji": "dog",
    "createdAt": "2026-06-16T09:10:00.000Z",
    "updatedAt": "2026-06-16T09:10:00.000Z"
  }
}
```

Errors:

- `400 validation-error` if `petId` is empty;
- `404 not-found` if the pet document does not exist.

### GET /pets

Returns pets for one owner sorted by `createdAt desc`.

Auth: not required by HTTP middleware for HW5 read-only MVP.

Query:

| Name | Type | Required | Description |
|---|---|---|---|
| `ownerId` | `string` | Yes | Firebase Auth UID of the pet owner |

Response:

```json
{
  "data": [
    {
      "id": "pet-1",
      "ownerId": "user-1",
      "ownerName": "Аня",
      "name": "Бруно",
      "animalType": "dog",
      "breed": "Корги",
      "age": 3
    }
  ]
}
```

### POST /pets

Creates a pet profile.

Auth: required.

Headers:

```http
Authorization: Bearer <firebase-id-token>
Content-Type: application/json
```

Request:

```json
{
  "ownerId": "user-1",
  "ownerName": "Аня",
  "name": "Бруно",
  "animalType": "dog",
  "breed": "Корги",
  "age": 3,
  "description": "Обожает мячики, людей и короткие пробежки в парке.",
  "photoUrl": "https://storage.googleapis.com/petconnect/pets/user-1/pet-1.jpg",
  "photoEmoji": "dog"
}
```

Validation:

- `ownerId` must match Firebase Auth `uid`;
- `ownerName`, `name` and `animalType` are required strings;
- `name` must be 50 characters or fewer;
- `breed` must be 80 characters or fewer;
- `age`, if present, must be an integer from 0 to 30;
- `description` must be 500 characters or fewer;
- `photoUrl` and `photoEmoji` are optional.

Response:

```json
{
  "data": {
    "id": "pet-1",
    "ownerId": "user-1",
    "ownerName": "Аня",
    "name": "Бруно",
    "animalType": "dog",
    "breed": "Корги",
    "age": 3
  }
}
```

### GET /posts

Returns posts sorted by `createdAt desc`.

Auth: not required by HTTP middleware. Firestore Admin SDK bypasses Security Rules, so public exposure should be decided at API gateway/deploy level. For HW5 this endpoint is intentionally read-only.

Query:

| Name | Type | Required | Description |
|---|---|---|---|
| `limit` | `number` | No | Integer from 1 to 50. Default: 20 |

Response:

```json
{
  "data": [
    {
      "id": "post-1",
      "authorId": "user-1",
      "petId": "pet-1",
      "text": "Сегодня Бруно отлично погулял.",
      "likesCount": 18,
      "commentsCount": 4,
      "createdAt": "2026-06-16T09:30:00.000Z"
    }
  ]
}
```

### POST /posts

Creates a post.

Auth: required.

Headers:

```http
Authorization: Bearer <firebase-id-token>
Content-Type: application/json
```

Request:

```json
{
  "authorId": "user-1",
  "petId": "pet-1",
  "text": "Сегодня Бруно отлично погулял.",
  "imageUrls": [
    "https://storage.googleapis.com/petconnect/posts/user-1/post-1/photo-1.jpg"
  ],
  "authorName": "Аня",
  "petName": "Бруно"
}
```

Validation:

- `authorId` must match Firebase Auth `uid`;
- `petId` is required;
- `text` must be a string and 1000 characters or fewer;
- `imageUrls`, if present, must be an array of strings.

Response:

```json
{
  "data": {
    "id": "post-1",
    "authorId": "user-1",
    "petId": "pet-1",
    "text": "Сегодня Бруно отлично погулял.",
    "likesCount": 0,
    "commentsCount": 0,
    "visibility": "public"
  }
}
```

### POST /posts/:postId/like

Toggles current user's like for a post.

Auth: required.

Response:

```json
{
  "data": {
    "postId": "post-1",
    "isLiked": true,
    "likesCount": 19
  }
}
```

### GET /walks

Returns walks sorted by `startsAt asc`.

Query:

| Name | Type | Required | Description |
|---|---|---|---|
| `limit` | `number` | No | Integer from 1 to 50. Default: 20 |

Response:

```json
{
  "data": [
    {
      "id": "walk-1",
      "title": "Корги-встреча в парке",
      "place": "Парк Горького",
      "participantsCount": 6,
      "status": "active"
    }
  ]
}
```

### POST /walks/:walkId/join

Adds current user to `participantIds` and increments `participantsCount`.

Auth: required.

Response:

```json
{
  "data": {
    "walkId": "walk-1",
    "isJoined": true,
    "participantsCount": 7
  }
}
```

## Logging

The API logs:

- incoming operations;
- successful important events such as post creation, like toggle, walk join;
- authentication failures;
- handled and unhandled backend errors.

Logs use Firebase Functions logger.

## Manual Commands

Install dependencies:

```bash
npm install --prefix functions
```

Build:

```bash
npm run build --prefix functions
```

Run local emulators:

```bash
npm run serve --prefix functions
```
