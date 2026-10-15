# 👨‍🏫 Section 3: Coach Module & Practice Plan Management — Complete Documentation

> **Status:** Production-Ready & Verified  
> **Target Release:** v1.1.0  
> **Base API Route:** `/api/v1`

---

## 📑 Executive Summary of Updates

The sharing and coaching loop between golfers and PGA coaches provides an end-to-end human coaching progression, modern mobile offline sync, 6-step session timeline tracking, coach drawing tools, and AI-synthesized 2-week practice plans:

1. **6-Step Session Journey & Offline Queue Transition:**
   - Full lifecycle statuses: `waiting_to_send`, `sent`, `viewed`, `coach_replied` (with backward compatibility for `pending` and `responded`).
   - Dedicated endpoint `PATCH /api/v1/share-swing/send-queued/:id` to transition offline queued shares directly into `sent` upon reconnection.
   - The 6-step journey reflects the human coaching progression:
     1. `Swing Recorded`
     2. `Shared with Coach`
     3. `Coach Reviewing`
     4. `Feedback Received`
     5. `Drill Recommended`
     6. `Practice Plan Created`
2. **Coach Feedback Form with Primary Correction & Drill Synthesis:**
   - Captures `primaryCorrection`, `detailedComments`, `recommendedDrill`, `drillSubtitle`, and `allowDrawOnVideo`.
   - Automatically synthesizes custom drill cards from coach text notes using `GeminiService.generateDrillFromCoachFeedback`.
3. **Practice Note & Swing Dual Reference:**
   - Golfer shares link both `swingLibraryId` and `practice_note_id` (or `noteId`), giving coaches full context of the player's notes and feelings.
4. **2-Week Practice Plan Tracking (`/practice-plan/`):**
   - Structured 3-phase schedule (`Days 1–3: Foundation`, `Days 4–7: Repetition`, `Days 8–14: Transfer`).
   - Session completion tracking (`isCompleted: boolean`, `completedAt: timestamp`) with completion ratio statistics.

---

## 📑 Feature Status & Endpoints Matrix

| # | Endpoint | Method | Auth Required | Status | Description |
|---|---|---|---|---|---|
| 1 | `/share-swing/create` | `POST` | Bearer Token | `[UPDATED]` | Idempotent share with `idempotencyKey`, `practice_note_id`, `allowDrawOnVideo`, & initial status |
| 2 | `/share-swing/send-queued/:id` | `PATCH` | Bearer Token | `[NEW]` | Transitions offline share from `waiting_to_send` to `sent` |
| 3 | `/share-swing/sent` | `GET` | Bearer Token | `[UPDATED]` | Golfer's sent shares with populated `practice_note_id` |
| 4 | `/share-swing/received` | `GET` | Bearer Token (Coach) | `[UPDATED]` | Coach's incoming reviews with notes and updated statuses |
| 5 | `/share-swing/pending` | `GET` | Bearer Token (Coach) | `[UPDATED]` | Pending/viewed queue (`sent`, `waiting_to_send`, `viewed`) |
| 6 | `/share-swing/find/:id` | `GET` | Bearer Token | `[UPDATED]` | Detailed review screen with 6-step journey, note, & practice plan |
| 7 | `/share-swing/single/:shareId` | `GET` | Bearer Token | `[UPDATED]` | Screen 2 Session Timeline with dynamic `primaryAction` |
| 8 | `/share-swing/view/:id` | `PATCH` | Bearer Token (Coach) | `[UPDATED]` | Transitions status from `sent`/`pending` ➔ `viewed` |
| 9 | `/share-swing/respond/:id` | `PATCH` | Bearer Token (Coach) | `[UPDATED]` | Submits feedback with `primaryCorrection`, `detailedComments`, `drillSubtitle` |
| 10 | `/share-swing/:id/practice-plan` | `PATCH` | Bearer Token (Coach/Admin) | `[UPDATED]` | Coach edits drill, customizes timeline, & approves plan (`is_approved`) |
| 11 | `/practice-plan/start/:shareId` | `POST` | Bearer Token | `[NEW]` | Initializes structured 2-week practice plan (Days 1–3, 4–7, 8–14) |
| 12 | `/practice-plan/toggle-session/:sessionId` | `PATCH` | Bearer Token | `[NEW]` | Toggles practice session completion state (`isCompleted`, `completedAt`) |
| 13 | `/practice-plan/my-plan/:shareId` | `GET` | Bearer Token | `[NEW]` | Fetches active 2-week plan with completion ratio stats |

---

## 1. 🔄 Sharing Flow & Status Tracking

### Status Lifecycle:
```text
[Offline Queue] ──▶ waiting_to_send
                           │
                           ▼ (PATCH /send-queued/:id or online create)
                         sent
                           │
                           ▼ (Coach opens review: PATCH /view/:id)
                        viewed
                           │
                           ▼ (Coach submits feedback: PATCH /respond/:id)
                     coach_replied / responded
```

### Endpoint: `POST /api/v1/share-swing/create`
* **Access:** Authenticated Golfer (`Bearer <ACCESS_TOKEN>`)
* **Idempotency:** When offline queues retry with the same `idempotencyKey` or for the same `coachId` & `swingLibraryId`, the backend returns the existing share rather than returning a 400 conflict.

#### Request:
```json
{
  "coachId": "685c22f08769b793d62e9010",
  "swingLibraryId": "6acb22f08769b793d62e9015",
  "practice_note_id": "6acb22f98769b793d62e9016",
  "idempotencyKey": "offline_queue_uuid_987654321",
  "message": "Coach, please check my transition tempo with Driver.",
  "allowDrawOnVideo": true,
  "status": "sent"
}
```

#### Response (`201 Created` or `200 OK` on idempotency hit):
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Swing shared with coach successfully.",
  "data": {
    "_id": "6acb33f08769b793d62e9030",
    "user": "6a52ffb3fa91f21a312f5b23",
    "coach": "685c22f08769b793d62e9010",
    "swingLibrary": "6acb22f08769b793d62e9015",
    "practice_note_id": "6acb22f98769b793d62e9016",
    "allowDrawOnVideo": true,
    "idempotencyKey": "offline_queue_uuid_987654321",
    "message": "Coach, please check my transition tempo with Driver.",
    "status": "sent",
    "createdAt": "2026-10-14T08:00:00.000Z",
    "updatedAt": "2026-10-14T08:00:00.000Z"
  }
}
```

---

## 2. 📝 Coach Feedback Submission & AI Drill Synthesis

### Endpoint: `PATCH /api/v1/share-swing/respond/:id`
* **Access:** Authenticated Coach (`Bearer <ACCESS_TOKEN>`)

#### Request:
```json
{
  "primaryCorrection": "Early Extension & Open Clubface at Impact",
  "detailedComments": "Great tempo in takeaway, but hips are pushing forward toward the ball at impact causing the face to stay open. Keep chest down and clear the lead hip.",
  "recommendedDrill": "Chair / Wall Drill for Hip Clearance",
  "drillSubtitle": "Rehearse downswing keeping glutes against alignment stick",
  "feedbackText": "Focus on clearing the left hip while keeping the lead wrist flat.",
  "rating": 5
}
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Feedback submitted successfully.",
  "data": {
    "_id": "6acb33f08769b793d62e9030",
    "status": "coach_replied",
    "coachFeedback": {
      "primaryCorrection": "Early Extension & Open Clubface at Impact",
      "detailedComments": "Great tempo in takeaway, but hips are pushing forward...",
      "recommendedDrill": "Chair / Wall Drill for Hip Clearance",
      "drillSubtitle": "Rehearse downswing keeping glutes against alignment stick",
      "feedbackText": "Focus on clearing the left hip while keeping the lead wrist flat.",
      "rating": 5,
      "respondedAt": "2026-10-14T09:30:00.000Z"
    }
  }
}
```

---

## 3. 📅 2-Week Practice Plan Tracking (`/practice-plan/`)

### 3.1 Start 2-Week Plan (`POST /api/v1/practice-plan/start/:shareId`)
Initializes the 3-phase practice plan derived from the coach's feedback:

```bash
curl -X POST "http://localhost:9090/api/v1/practice-plan/start/6acb33f08769b793d62e9030" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json"
```

#### Response (`201 Created`):
```json
{
  "statusCode": 201,
  "success": true,
  "message": "2-week practice plan initialized successfully.",
  "data": {
    "_id": "6b7c890123456789abcdef01",
    "shareId": "6acb33f08769b793d62e9030",
    "user": "6a52ffb3fa91f21a312f5b23",
    "coach": "685c22f08769b793d62e9010",
    "title": "2-Week Early Extension Correction Routine",
    "recommendedDrill": "Chair / Wall Drill for Hip Clearance",
    "sessions": [
      {
        "_id": "session_id_phase_1",
        "phase": "Phase 1: Foundation",
        "dayRange": "Days 1–3",
        "drill": "Slow-motion rehearsals against alignment stick",
        "reps": "20 reps daily",
        "isCompleted": false,
        "completedAt": null
      },
      {
        "_id": "session_id_phase_2",
        "phase": "Phase 2: Repetition",
        "dayRange": "Days 4–7",
        "drill": "Impact bag compressions with 7-iron",
        "reps": "30 balls at 70% speed",
        "isCompleted": false,
        "completedAt": null
      },
      {
        "_id": "session_id_phase_3",
        "phase": "Phase 3: Transfer",
        "dayRange": "Days 8–14",
        "drill": "Full driver routine on target range",
        "reps": "15 driver shots simulating fairways",
        "isCompleted": false,
        "completedAt": null
      }
    ],
    "completionStats": {
      "totalSessions": 3,
      "completedSessions": 0,
      "completionPercentage": 0
    }
  }
}
```

### 3.2 Toggle Practice Session (`PATCH /api/v1/practice-plan/toggle-session/:sessionId`)
Allows golfer to mark a session completed or uncheck it:

```bash
curl -X PATCH "http://localhost:9090/api/v1/practice-plan/toggle-session/session_id_phase_1" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json"
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Practice session updated successfully.",
  "data": {
    "sessionId": "session_id_phase_1",
    "isCompleted": true,
    "completedAt": "2026-10-14T10:15:00.000Z",
    "completionStats": {
      "totalSessions": 3,
      "completedSessions": 1,
      "completionPercentage": 33.3
    }
  }
}
```
