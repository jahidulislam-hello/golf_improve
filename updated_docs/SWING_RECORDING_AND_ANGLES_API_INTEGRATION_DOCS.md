# GolfImprove — Swing Recording, Angles & Processing API Integration Guide
## Client Specification & Production Integration Documentation

*Version: **2.0.0 (Production Release)***  
*Base URL: `http://localhost:9090/api/v1` (Development) / `https://api.golfimprove.com/api/v1` (Production)*  
*Authentication Scheme: `Bearer <JWT_TOKEN>`*

---

## 1. Overview of Section 2 Changes

In strict accordance with the client requirements from **thijnhogeland**, Section 2 (Swing Recording, Angles & Processing) has been upgraded to production grade:

1. **Camera Angles Restricted to Face-On and Down-the-Line:**
   - **"Side On" completely deprecated and removed:**
     - `ICameraAngle` enum in `src/models/swing-library/swing.library.interface.ts` restricted to `['Face On', 'Down The Line', 'All Angles']`.
     - Mongoose models (`Swing` & `SwingLibrary`) strictly disallow `"Side On"`.
     - Category discovery (`GET /api/v1/swing-category/camera`) automatically strips `"Side On"` from top-level and per-category camera angles.
     - Database seeders updated: default categories no longer seed `"Side On"`.
     - Passing `"Side On"` or `"side-on"` to any swing creation, upload, or sync endpoint results in an immediate **`400 Bad Request`** with a descriptive message:
       `"Camera angle 'Side On' is no longer supported. Please select either 'Face-On' or 'Down-the-Line'."`
2. **Support for Hyphenated Formats & Convenient Aliases:**
   - Client applications can pass hyphenated angles (`"Face-On"`, `"Down-the-Line"`) or space-separated angles (`"Face On"`, `"Down The Line"`).
   - Client applications can pass `angle` as an alias for `cameraAngle`, and `club` as an alias for `clubType`.
3. **Swift Swing Processing & Resumable Background Uploads:**
   - `POST /api/v1/swing/analyzer` executes video upload and synchronous/asynchronous kinematic processing.
   - `POST /api/v1/swing/upload-url` and `POST /api/v1/swing/resumable-upload/initiate` issue direct pre-signed S3 URLs so high-framerate clips stream directly to cloud storage without blocking the UI.
4. **Compare Swings (`POST /api/v1/swing/compare`):**
   - **Club Matching Rule:** Swings must be recorded with the **same club** (e.g. Driver with Driver, Irons with Irons). Attempting to compare mismatched clubs returns `400 Bad Request`.
   - **Camera Angle Matching Rule:** Swings must be recorded with the **same camera angle** (Face-On with Face-On, Down-the-Line with Down-the-Line). Attempting to compare mismatched angles returns `400 Bad Request`.
   - **Side On Rejection:** Any attempt to compare a deprecated `"Side On"` swing is rejected.
   - **Duplicate Swing Rejection:** Comparing a swing with itself or with an identical video URL returns `400 Bad Request`.
5. **Swing Library & Swings Querying:**
   - `GET /api/v1/swing-library/my-library` allows filtering by `club` and `angle` simultaneously (e.g. `?club=Driver&angle=Face-On`).
   - `GET /api/v1/swing/my-swings` also supports simultaneous `club` and `angle` filtering.
   - Both endpoints default to sorting newest swings first (`sort: "-createdAt"`).
6. **Admin Dashboard Alignment:**
   - Quick chips for `+ Face On` and `+ Down The Line` added to Swing Categories management.
   - Admin category filter options sanitized.

---

## 2. API Endpoints Specification

### 2.1 Get Camera Screen Categories & Angles

Retrieves active club categories and allowed camera angles for the camera positioning interface.

- **Method:** `GET`
- **Endpoint:** `/swing-category/camera`
- **Auth Required:** Yes (`Bearer <token>`)

#### cURL Request:
```bash
curl -X GET "http://localhost:9090/api/v1/swing-category/camera" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Camera categories retrieved successfully.",
  "data": {
    "cameraAngles": [
      "Face On",
      "Down The Line"
    ],
    "recordingModes": [
      "slow-mo",
      "swing",
      "video"
    ],
    "categories": [
      {
        "_id": "6718d7...",
        "name": "Driver",
        "difficulty": "Beginner",
        "cameraAngles": [
          "Face On",
          "Down The Line"
        ],
        "recordingModes": [
          "slow-mo",
          "swing",
          "video"
        ],
        "defaultCameraAngle": "Face On",
        "defaultRecordingMode": "swing",
        "sortOrder": 1,
        "isActive": true
      },
      {
        "_id": "6718d8...",
        "name": "Irons",
        "difficulty": "Beginner",
        "cameraAngles": [
          "Face On",
          "Down The Line"
        ],
        "recordingModes": [
          "slow-mo",
          "swing",
          "video"
        ],
        "defaultCameraAngle": "Face On",
        "defaultRecordingMode": "swing",
        "sortOrder": 2,
        "isActive": true
      }
    ]
  }
}
```

---

### 2.2 Record Swing (JSON / S3 Ingestion)

Creates a new swing record after direct video upload or offline synchronization.

- **Method:** `POST`
- **Endpoint:** `/swing/create`
- **Auth Required:** Yes (`Bearer <token>`)

#### cURL Request:
```bash
curl -X POST "http://localhost:9090/api/v1/swing/create" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "videoUrl": "https://storage.golfimprove.com/swings/user-123-swing.mp4",
    "thumbnailUrl": "https://storage.golfimprove.com/swings/user-123-thumb.jpg",
    "duration": 4.5,
    "angle": "Face-On",
    "club": "Driver",
    "recordingMode": "swing"
  }'
```

#### Request Body (Hyphenated Angles & Aliases Supported):
```json
{
  "videoUrl": "https://storage.golfimprove.com/swings/user-123-swing.mp4",
  "thumbnailUrl": "https://storage.golfimprove.com/swings/user-123-thumb.jpg",
  "duration": 4.5,
  "angle": "Face-On",
  "club": "Driver",
  "recordingMode": "swing",
  "trimStart": 0,
  "trimEnd": 4.5
}
```

#### Field Notes:
| Field | Type | Description |
| :--- | :--- | :--- |
| `videoUrl` | `string` (URL) | **Required.** URL of the recorded clip. |
| `thumbnailUrl` | `string` (URL) | Optional video preview thumbnail URL. |
| `duration` | `number` | **Required.** Duration of the clip in seconds. |
| `angle` / `cameraAngle` | `string` | **Allowed:** `"Face-On"`, `"Face On"`, `"Down-the-Line"`, `"Down The Line"`. Defaults to `"Face On"`. **`"Side On"` is strictly rejected with HTTP 400.** |
| `club` / `clubType` | `string` | **Allowed:** `"Driver"`, `"Irons"`, `"Wedges"`, `"Putter"`, `"All Clubs"`. |
| `recordingMode` | `string` | `"swing"` (default), `"slow-mo"`, `"video"`. |
| `local_id` | `string` | Optional client-side UUID for offline tracking. |
| `idempotencyKey` | `string` | Optional client-side idempotency key to prevent duplicates. |

#### Error Response — When "Side On" is Passed (`400 Bad Request`):
```json
{
  "statusCode": 400,
  "success": false,
  "message": "Validation Error",
  "errorMessages": [
    {
      "path": "cameraAngle",
      "message": "Camera angle 'Side On' is no longer supported. Please select either 'Face-On' or 'Down-the-Line'."
    }
  ]
}
```

#### Success Response (`201 Created`):
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Swing recorded successfully.",
  "data": {
    "_id": "6718e2...",
    "user": "6a5af4...",
    "videoUrl": "https://storage.golfimprove.com/swings/user-123-swing.mp4",
    "thumbnailUrl": "https://storage.golfimprove.com/swings/user-123-thumb.jpg",
    "clubType": "Driver",
    "cameraAngle": "Face On",
    "recordingMode": "swing",
    "duration": 4.5,
    "status": "draft",
    "syncStatus": "local",
    "createdAt": "2026-10-14T17:08:13.123Z"
  }
}
```

---

### 2.3 Upload & Analyze Swing (Multipart Video / Frame Extraction)

Single multipart endpoint used when uploading raw video files directly from mobile. Probes duration and extracts thumbnails automatically if omitted.

- **Method:** `POST`
- **Endpoint:** `/swing/analyzer`
- **Auth Required:** Yes (`Bearer <token>`)
- **Content-Type:** `multipart/form-data`

#### cURL Request:
```bash
curl -X POST "http://localhost:9090/api/v1/swing/analyzer" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -F "video=@/path/to/swing_recording.mp4" \
  -F "club=Driver" \
  -F "angle=Face-On" \
  -F "recordingMode=swing"
```

#### Multipart Form Fields:
- `video` (file): MP4/MOV recorded video file.
- `thumbnail` (file, optional): Video thumbnail frame image.
- `angle` or `cameraAngle` (text): `"Face-On"` or `"Down-the-Line"`.
- `club` or `clubType` (text): `"Driver"`, `"Irons"`, `"Wedges"`, `"Putter"`.
- `recordingMode` (text): `"swing"`, `"slow-mo"`.

---

### 2.4 Generate S3 Pre-Signed Upload URL (Resumable Streaming)

Allows the mobile app to upload large high-speed camera files directly to S3 before calling `/swing/create`.

- **Method:** `POST`
- **Endpoint:** `/swing/upload-url`
- **Auth Required:** Yes (`Bearer <token>`)

#### cURL Request:
```bash
curl -X POST "http://localhost:9090/api/v1/swing/upload-url" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "swing-session-001.mp4",
    "fileType": "video/mp4",
    "club": "Driver",
    "angle": "Face-On",
    "fileSize": 18450200
  }'
```

#### Request Body:
```json
{
  "fileName": "swing-session-001.mp4",
  "fileType": "video/mp4",
  "club": "Driver",
  "angle": "Face-On",
  "fileSize": 18450200
}
```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Pre-signed S3 upload URL generated successfully.",
  "data": {
    "uploadUrl": "https://golfimprove-bucket.s3.amazonaws.com/swings/...",
    "videoUrl": "https://storage.golfimprove.com/swings/...",
    "key": "swings/user-6a5af4/1728921893-swing.mp4",
    "expiresInSeconds": 3600,
    "headers": {
      "Content-Type": "video/mp4"
    }
  }
}
```

---

### 2.5 Compare Swings (Strict Compatibility Validation)

Performs side-by-side comparative analysis of two swing videos. Strictly enforces that both swings were recorded with the **same club** and the **same camera angle**.

- **Method:** `POST`
- **Endpoint:** `/swing/compare`
- **Auth Required:** Yes (`Bearer <token>`)

#### cURL Request:
```bash
curl -X POST "http://localhost:9090/api/v1/swing/compare" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "firstSwingId": "6718e2001...",
    "secondSwingId": "6718e2002..."
  }'
```

#### Request Body:
```json
{
  "firstSwingId": "6718e2001...",
  "secondSwingId": "6718e2002..."
}
```
*(Also accepts alias keys `swingAId`/`swingBId` or `swing1Id`/`swing2Id`)*

#### Compatibility Validation Rules:
1. **Mismatched Clubs:**
   ```json
   {
     "statusCode": 400,
     "success": false,
     "message": "Cannot compare different clubs (Driver vs Irons). Swings must be recorded with the same club."
   }
   ```
2. **Mismatched Angles:**
   ```json
   {
     "statusCode": 400,
     "success": false,
     "message": "Cannot compare different camera angles (Face On vs Down The Line). Swings must be recorded with the same camera angle."
   }
   ```
3. **Deprecated Side On Swing:**
   ```json
   {
     "statusCode": 400,
     "success": false,
     "message": "Cannot compare swings recorded with deprecated 'Side On' angle. Swings must be 'Face-On' or 'Down-the-Line'."
   }
   ```
4. **Identical Video URL / Same Swing:**
   ```json
   {
     "statusCode": 400,
     "success": false,
     "message": "Cannot compare identical swings or swings with the same video URL. Please select two distinct swing videos."
   }
   ```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Swings compared successfully.",
  "data": {
    "swingA": {
      "_id": "6718e2001...",
      "videoUrl": "https://storage.golfimprove.com/swings/swing-1.mp4",
      "clubType": "Driver",
      "cameraAngle": "Face On",
      "overallScore": 78
    },
    "swingB": {
      "_id": "6718e2002...",
      "videoUrl": "https://storage.golfimprove.com/swings/swing-2.mp4",
      "clubType": "Driver",
      "cameraAngle": "Face On",
      "overallScore": 84
    },
    "scoreComparison": {
      "scoreA": 78,
      "scoreB": 84,
      "diff": 6,
      "status": "improved",
      "percentageChange": 7.7
    },
    "tempoComparison": {
      "tempoRatio": {
        "swingA": "3.2:1",
        "swingB": "3.0:1",
        "pgaTourStandard": "3.0:1",
        "closestToStandard": "swingB"
      }
    },
    "metricComparisons": [
      {
        "key": "lead_arm_impact",
        "title": "Lead Arm Extension at Impact",
        "valueA": "158°",
        "statusA": "bent",
        "valueB": "167°",
        "statusB": "straight",
        "difference": "+9°",
        "improvement": "improved",
        "target": "> 165° (straight lead arm)"
      }
    ]
  }
}
```

---

### 2.6 Swing Library Filtering (Compatible Pairs Selection)

Populates compatible swings for comparison. Allows querying by `club` and `angle` simultaneously. Swings are sorted newest first.

- **Method:** `GET`
- **Endpoint:** `/swing-library/my-library?club=Driver&angle=Face-On`
- **Auth Required:** Yes (`Bearer <token>`)

#### cURL Request:
```bash
curl -X GET "http://localhost:9090/api/v1/swing-library/my-library?club=Driver&angle=Face-On&page=1&limit=20" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

#### Query Parameters:
| Parameter | Type | Example | Description |
| :--- | :--- | :--- | :--- |
| `club` / `clubType` | `string` | `Driver` | Filter by club (`Driver`, `Irons`, `Wedges`, `Putter`). Omit or pass `All` for all clubs. |
| `angle` / `cameraAngle` | `string` | `Face-On` | Filter by angle (`Face-On`, `Down-the-Line`). Hyphenated or space format. |
| `sort` | `string` | `-createdAt` | Sort order (defaults to `-createdAt` = newest first). |
| `page` | `number` | `1` | Pagination page number. |
| `limit` | `number` | `20` | Results per page. |

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Swing library fetched successfully.",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 12,
    "totalPage": 1
  },
  "data": [
    {
      "_id": "6718e3...",
      "clubType": "Driver",
      "cameraAngle": "Face On",
      "videoUrl": "https://storage.golfimprove.com/...",
      "thumbnailUrl": "https://storage.golfimprove.com/...",
      "overallScore": 82,
      "isSharedWithCoach": false,
      "createdAt": "2026-10-14T17:08:14.000Z"
    }
  ]
}
```

---

### 2.7 My Swings Querying

Queries raw swing recordings filtered by club and angle.

- **Method:** `GET`
- **Endpoint:** `/swing/my-swings?club=Driver&angle=Face-On`
- **Auth Required:** Yes (`Bearer <token>`)

#### cURL Request:
```bash
curl -X GET "http://localhost:9090/api/v1/swing/my-swings?club=Driver&angle=Face-On&page=1&limit=10" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Swings retrieved successfully.",
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 3,
    "totalPage": 1
  },
  "data": [
    {
      "_id": "6718e2002...",
      "clubType": "Driver",
      "cameraAngle": "Face On",
      "recordingMode": "swing",
      "duration": 4.8,
      "status": "draft",
      "createdAt": "2026-10-14T17:08:13.600Z"
    }
  ]
}
```

---

## 3. Summary of Status for Section 2

| Requirement | Implementation Detail | Status |
| :--- | :--- | :--- |
| **Strict Camera Angles** | Restricted to `Face-On` and `Down-the-Line`. Deprecated `"Side On"` with 400 rejection in Zod & controller. | 🟢 **Complete & Verified** |
| **Strip Side On from Categories** | `GET /api/v1/swing-category/camera` automatically strips `"Side On"`. Seeders updated. | 🟢 **Complete & Verified** |
| **Swift Processing & Resumable Upload** | Asynchronous S3 pre-signed upload URLs and rapid `/analyzer` ingest. | 🟢 **Complete & Verified** |
| **Compare Swings Validation** | Compares only matching club and matching angle; rejects mismatches with clean 400 errors. | 🟢 **Complete & Verified** |
| **Simultaneous Filtering** | `GET /swing-library/my-library` and `GET /swing/my-swings` support simultaneous `club` and `angle` filters, sorted newest first. | 🟢 **Complete & Verified** |
