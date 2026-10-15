# 4. Video Storage, Metadata & Resumable / Offline Sync Documentation

> **Status:** ✅ Fully Implemented, Tested & Production Ready  
> **Target Service:** `golf-improve-server`  
> **Relevant Models & Files:**  
> - Model & Interface: [`src/models/swing/swing.interface.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing/swing.interface.ts), [`src/models/swing/swing.model.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing/swing.model.ts)  
> - Validation Schemas: [`src/models/swing/swing.validation.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing/swing.validation.ts)  
> - Business Logic & Service: [`src/models/swing/swing.service.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing/swing.service.ts)  
> - Controller: [`src/models/swing/swing.controller.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing/swing.controller.ts)  
> - Routes: [`src/models/swing/swing.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing/swing.route.ts)

---

## 1. Overview & Architectural Requirements

To support mobile client recording of high-framerate golf swing videos (60fps, 120fps, 240fps), offline practice sessions at driving ranges, and seamless history filtering, the video storage layer has been structured around four architectural pillars:

1. **Pre-signed S3 Resumable Upload:**  
   Bypasses the Node.js API server for heavy media uploads. The server generates secure, pre-signed AWS S3 `PUT` URLs using `@aws-sdk/s3-request-presigner` and `PutObjectCommand`. Mobile clients stream high-definition video chunks directly into the AWS S3 bucket (`iter-bene`), preserving server CPU and memory.

2. **Offline-First & Batch Background Sync:**  
   When golfers practice without network coverage, swings are recorded and stored in the mobile local database (SQLite / WatermelonDB). Once network connectivity is restored, the mobile client dispatches a batch sync payload via `POST /api/v1/swing/sync/offline`.

3. **Idempotency & Duplicate Prevention:**  
   Network fluctuations or automatic mobile retry policies can cause duplicate sync dispatches. The backend prevents duplicates using `idempotencyKey` and `local_id`. Replayed requests are recognized, returning existing records with `isNew: false`.

4. **Rich Metadata & Compound Index Sorting:**  
   Every swing captures `recorded_at`, `client_session_id`, `fileSize`, `fileType`, and `syncStatus`. Query performance is optimized via MongoDB compound indexes (`{ user: 1, createdAt: -1 }`, `{ user: 1, recorded_at: -1 }`, `{ user: 1, clubType: 1 }`, and `{ user: 1, cameraAngle: 1 }`). By default, swing queries sort in descending order (`createdAt DESC`), ensuring the most recent swings appear first.

---

## 2. Database Schema Updates (`ISwing` & `SwingSchema`)

### Additional Metadata & Sync Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `recorded_at` | `Date` | Timestamp of when the swing was physically recorded on the device (default: `Date.now()`). Indexed. |
| `local_id` | `String` | Unique client-side database ID (UUID) generated on the mobile app. Sparse index. |
| `client_session_id` | `String` | Client practice session batch identifier grouping related swings. Sparse index. |
| `idempotencyKey` | `String` | Unique transaction key preventing duplicate record creation on retries. Sparse index. |
| `fileSize` | `Number` | Video file size in bytes (default: `0`). |
| `fileType` | `String` | MIME type of the uploaded media (e.g., `video/mp4`, `video/quicktime`). |
| `syncStatus` | `Enum` | Sync state: `"local"` \| `"syncing"` \| `"synced"` \| `"failed"` (default: `"synced"`). Indexed. |

### MongoDB Compound Indexes
```typescript
SwingSchema.index({ user: 1, createdAt: -1 });
SwingSchema.index({ user: 1, recorded_at: -1 });
SwingSchema.index({ user: 1, clubType: 1 });
SwingSchema.index({ user: 1, cameraAngle: 1 });
```

---

## 3. API Endpoints

### 3.1 Pre-signed S3 Upload URL Generation
Allows the mobile client to request a temporary, pre-signed AWS S3 `PUT` URL prior to streaming video data.

- **Endpoints:**
  - `POST /api/v1/swing/upload-url`
  - `POST /api/v1/swing/resumable-upload/initiate`
- **Auth:** Bearer JWT (`auth("common")`)
- **Headers:** `Content-Type: application/json`

#### cURL Request:
```bash
curl -X POST "http://localhost:9090/api/v1/swing/upload-url" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "range-session-driver-120fps.mp4",
    "fileType": "video/mp4",
    "club": "Driver",
    "angle": "Face-On",
    "fileSize": 45182900
  }'
```

- **Request Body:**
```json
{
  "fileName": "range-session-driver-120fps.mp4",
  "fileType": "video/mp4",
  "clubType": "Driver",
  "cameraAngle": "Face On",
  "fileSize": 45182900
}
```
- **Response (200 OK):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Pre-signed S3 upload URL generated successfully.",
  "data": {
    "uploadUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/6acb4.../1791707...mp4?X-Amz-Algorithm=AWS4-HMAC-SHA256...",
    "videoUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/6acb4.../1791707...mp4",
    "key": "swings/6acb4.../1791707...mp4",
    "expiresInSeconds": 3600,
    "headers": {
      "Content-Type": "video/mp4"
    }
  }
}
```

> **Client Upload Workflow:**  
> 1. Request pre-signed URL via `POST /api/v1/swing/upload-url`.  
> 2. Perform HTTP `PUT` directly to `data.uploadUrl` with the video binary file and `Content-Type` header.  
> 3. After upload completes, create the swing entry via `POST /api/v1/swing/create` using `data.videoUrl`.

---

### 3.2 Offline Batch Sync
Synchronizes multiple offline-recorded swings in a single batch once network connectivity is re-established.

- **Endpoints:**
  - `POST /api/v1/swing/sync/offline`
  - `POST /api/v1/swing/sync/batch`
- **Auth:** Bearer JWT (`auth("common")`)
- **Headers:** `Content-Type: application/json`

#### cURL Request:
```bash
curl -X POST "http://localhost:9090/api/v1/swing/sync/offline" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "swings": [
      {
        "local_id": "mob_uuid_1001",
        "idempotencyKey": "sync_idem_78912345",
        "client_session_id": "session_morning_range_1",
        "videoUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/video1.mp4",
        "thumbnailUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/thumb1.jpg",
        "club": "Driver",
        "angle": "Face-On",
        "duration": 4.2,
        "recorded_at": "2026-10-11T07:15:00.000Z"
      }
    ]
  }'
```

- **Request Body (Batch):**
```json
{
  "swings": [
    {
      "local_id": "mob_uuid_1001",
      "idempotencyKey": "sync_idem_78912345",
      "client_session_id": "session_morning_range_1",
      "videoUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/video1.mp4",
      "thumbnailUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/thumb1.jpg",
      "clubType": "Driver",
      "cameraAngle": "Face On",
      "recordingMode": "swing",
      "duration": 4.2,
      "trimStart": 0.5,
      "trimEnd": 3.8,
      "recorded_at": "2026-10-11T07:15:00.000Z",
      "fileSize": 25410980,
      "fileType": "video/mp4"
    },
    {
      "local_id": "mob_uuid_1002",
      "idempotencyKey": "sync_idem_78912346",
      "client_session_id": "session_morning_range_1",
      "videoUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/video2.mp4",
      "thumbnailUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/thumb2.jpg",
      "clubType": "Irons",
      "cameraAngle": "Down The Line",
      "recordingMode": "swing",
      "duration": 3.9,
      "trimStart": 0.3,
      "trimEnd": 3.4,
      "recorded_at": "2026-10-11T07:18:00.000Z",
      "fileSize": 21840120,
      "fileType": "video/mp4"
    }
  ]
}
```
- **Response (200 OK):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Offline swings synchronized successfully.",
  "data": {
    "totalReceived": 2,
    "syncedCount": 2,
    "failedCount": 0,
    "syncedSwings": [
      {
        "swing": {
          "_id": "67a3f890bc...",
          "user": "6acb...",
          "local_id": "mob_uuid_1001",
          "clubType": "Driver",
          "cameraAngle": "Face On",
          "syncStatus": "synced",
          "recorded_at": "2026-10-11T07:15:00.000Z",
          "createdAt": "2026-10-11T08:35:13.814Z"
        },
        "isNew": true,
        "local_id": "mob_uuid_1001"
      },
      {
        "swing": {
          "_id": "67a3f890bd...",
          "user": "6acb...",
          "local_id": "mob_uuid_1002",
          "clubType": "Irons",
          "cameraAngle": "Down The Line",
          "syncStatus": "synced",
          "recorded_at": "2026-10-11T07:18:00.000Z",
          "createdAt": "2026-10-11T08:35:14.207Z"
        },
        "isNew": true,
        "local_id": "mob_uuid_1002"
      }
    ],
    "errors": []
  }
}
```

> **Idempotent Replay Resolution:**  
> If an offline batch request is retried due to temporary timeout, the server locates existing records matching `idempotencyKey` or `local_id`, returns them with `isNew: false`, and prevents duplicate database entries.

---

### 3.3 List & Filter Swings (Metadata & Sorting)
- **Endpoint:** `GET /api/v1/swing/my-swings`
- **Auth:** Bearer JWT (`auth("common")`)
- **Query Parameters:**
  - `page`: Page number (default: `1`)
  - `limit`: Items per page (default: `10`)
  - `club` / `clubType`: Filter by club (`"Driver"`, `"Irons"`, `"Wedges"`, `"Putter"`, or `"All Clubs"`)
  - `angle` / `cameraAngle`: Filter by camera angle (`"Face On"`, `"Down The Line"`, or `"All Angles"`. Hyphenated formats `"Face-On"` / `"Down-the-Line"` supported. Note: `"Side On"` is strictly deprecated and rejected with HTTP 400)
  - `recordingMode`: Filter by mode (`"swing"`, `"video"`, `"slow-mo"`)
  - `isAnalyzed`: `true` or `false`
  - `startDate`: Filter recordings from date (`YYYY-MM-DD`)
  - `endDate`: Filter recordings up to date (`YYYY-MM-DD`)
  - `sort`: Sorting field (default: `"-createdAt"` for latest recordings first)

#### cURL Request:
```bash
curl -X GET "http://localhost:9090/api/v1/swing/my-swings?club=Driver&angle=Face-On&page=1&limit=10" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

- **Response (200 OK):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Swings retrieved successfully.",
  "meta": {
    "totalResult": 42,
    "currentPage": 1,
    "limit": 10,
    "totalPage": 5
  },
  "data": [
    {
      "_id": "67a3f890bd...",
      "user": "6acb...",
      "videoUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/...",
      "thumbnailUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/...",
      "clubType": "Irons",
      "cameraAngle": "Down The Line",
      "recordingMode": "swing",
      "duration": 3.9,
      "trimStart": 0.3,
      "trimEnd": 3.4,
      "status": "draft",
      "isAnalyzed": false,
      "recorded_at": "2026-10-11T07:18:00.000Z",
      "local_id": "mob_uuid_1002",
      "syncStatus": "synced",
      "createdAt": "2026-10-11T08:35:14.207Z"
    }
  ]
}
```

---

### 3.4 Standard Swing Creation (Post-Direct S3 Upload)
After completing a direct client-to-S3 upload, the mobile app registers the swing record with server-side validation.

- **Endpoint:** `POST /api/v1/swing/create`
- **Auth:** Bearer JWT (`auth("common")`)
- **Headers:** `Content-Type: application/json`

#### cURL Request:
```bash
curl -X POST "http://localhost:9090/api/v1/swing/create" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "videoUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/video.mp4",
    "thumbnailUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/thumb.jpg",
    "club": "Driver",
    "angle": "Face-On",
    "duration": 4.5,
    "local_id": "mob_uuid_1003",
    "idempotencyKey": "direct_idem_12345"
  }'
```

- **Request Body:**
```json
{
  "videoUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/video.mp4",
  "thumbnailUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/thumb.jpg",
  "clubType": "Driver",
  "cameraAngle": "Face On",
  "recordingMode": "swing",
  "duration": 4.5,
  "trimStart": 0.5,
  "trimEnd": 3.8,
  "local_id": "mob_uuid_1003",
  "idempotencyKey": "direct_idem_12345",
  "recorded_at": "2026-10-11T08:00:00.000Z",
  "fileSize": 32100450,
  "fileType": "video/mp4"
}
```
- **Response (201 Created):**
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Swing recorded successfully.",
  "data": {
    "_id": "67a3f890be...",
    "user": "6acb...",
    "videoUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/swings/user/video.mp4",
    "clubType": "Driver",
    "cameraAngle": "Face On",
    "syncStatus": "synced",
    "isAnalyzed": false,
    "createdAt": "2026-10-11T08:36:00.000Z"
  }
}
```

---

## 4. Verification & Testing Results

- **AWS S3 Pre-signed URL Test:** Verified live URL generation using `@aws-sdk/s3-request-presigner` against the active S3 bucket (`iter-bene` in `eu-north-1`).
- **Offline Batch Sync & Deduplication:** Successfully synchronized batch payloads. Repeated submissions were correctly identified as existing records (`isNew: false`) without creating duplicates.
- **Sorting & Filtering:** Validated that `GET /api/v1/swing/my-swings` defaults to `-createdAt` (descending order), correctly placing the newest swings first.
- **TypeScript Integrity:** Compiled with `npx tsc --noEmit` across both `golf-improve-server` and `golf-improve-dashboard` with **0 errors**.
