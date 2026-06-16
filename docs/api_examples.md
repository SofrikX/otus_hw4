# API Examples — PetConnect Cloud Functions

Base URL for local Firebase Emulator Suite:

```bash
API_BASE_URL="http://127.0.0.1:5001/demo-petconnect/us-central1/api"
```

Protected endpoints require a Firebase ID token:

```bash
FIREBASE_ID_TOKEN="<firebase-id-token>"
```

## GET /posts

```bash
curl -X GET "${API_BASE_URL}/posts?limit=20" \
  -H "Accept: application/json"
```

## POST /posts

```bash
curl -X POST "${API_BASE_URL}/posts" \
  -H "Authorization: Bearer ${FIREBASE_ID_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "authorId": "user-anya",
    "authorName": "Аня",
    "petId": "pet-bruno",
    "petName": "Бруно",
    "text": "Сегодня Бруно отлично погулял.",
    "imageUrls": [
      "https://storage.googleapis.com/petconnect/posts/user-anya/post-1/photo-1.jpg"
    ]
  }'
```

## Like Post

```bash
curl -X POST "${API_BASE_URL}/posts/post-1/like" \
  -H "Authorization: Bearer ${FIREBASE_ID_TOKEN}" \
  -H "Accept: application/json"
```

## GET /walks

```bash
curl -X GET "${API_BASE_URL}/walks?limit=20" \
  -H "Accept: application/json"
```

## Join Walk

```bash
curl -X POST "${API_BASE_URL}/walks/walk-1/join" \
  -H "Authorization: Bearer ${FIREBASE_ID_TOKEN}" \
  -H "Accept: application/json"
```

## Error Examples

Missing token for protected endpoints returns:

```json
{
  "error": {
    "code": "unauthorized",
    "message": "Firebase ID token is required."
  }
}
```

Invalid post payload returns:

```json
{
  "error": {
    "code": "validation-error",
    "message": "petId is required."
  }
}
```
