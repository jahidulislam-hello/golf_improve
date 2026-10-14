# 👨‍🏫 Section 3: Coach Module & Practice Plan Management — Complete Documentation

> **Status:** Production-Ready & Verified  
> **Target Release:** v1.1.0  
> **Base API Route:** `/api/v1`

---

## 📑 Executive Summary of Updates

Section 3 updates the sharing and coaching loop between golfers and PGA coaches to handle modern mobile app offline sync, structured workflow status transitions, practice note attachments, coach approval permissions, and granular multi-day practice session completion tracking.

1. **Status Tracking & Offline Queue Idempotency:**
   - Full lifecycle statuses: `waiting_to_send`, `sent`, `viewed`, `coach_replied` (with backward compatibility for `pending` and `responded`).
   - Idempotent API handling via `idempotencyKey` and duplicate share resolution to prevent mobile retry crashes.
2. **Practice Note Attachment:**
   - Allows golfers to attach a digital logbook note (`practice_note_id` referencing [`NoteBook`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/note-book/note.book.model.ts)) when sharing swings with a coach.
3. **Coach Review & Practice Plan Edit/Approval:**
   - Coaches can edit recommended drills, modify practice plan timelines, and approve plans via `PATCH /api/v1/share-swing/:id/practice-plan`.
4. **Session Completion Tracking:**
   - Granular session completion tracking (`is_completed: boolean`, `completed_at: timestamp`) for every timeline drill in both coach practice plans and AI practice plans with completion ratios and statistics.

---

## 📑 Feature Status & Endpoints Matrix

| # | Endpoint | Method | Auth Required | Status | Description |
|---|---|---|---|---|---|
| 1 | `/share-swing/create` | `POST` | Bearer Token | **`[UPDATED]`** | Idempotent share with `idempotencyKey`, `practice_note_id`, & initial status |
| 2 | `/share-swing/sent` | `GET` | Bearer Token | **`[UPDATED]`** | Golfer's sent shares with populated `practice_note_id` |
| 3 | `/share-swing/received` | `GET` | Bearer Token (Coach) | **`[UPDATED]`** | Coach's incoming reviews with notes and updated statuses |
| 4 | `/share-swing/pending` | `GET` | Bearer Token (Coach) | **`[UPDATED]`** | Pending/viewed queue (`sent`, `waiting_to_send`, `viewed`) |
| 5 | `/share-swing/find/:id` | `GET` | Bearer Token | **`[UPDATED]`** | Detailed review screen with journey timeline, note, & practice plan |
| 6 | `/share-swing/view/:id` | `PATCH` | Bearer Token (Coach) | **`[UPDATED]`** | Transitions status from `sent`/`pending` ➔ `viewed` |
| 7 | `/share-swing/respond/:id` | `PATCH` | Bearer Token (Coach) | **`[UPDATED]`** | Submits feedback; transitions status ➔ `coach_replied` |
| 8 | `/share-swing/:id/practice-plan` | `PATCH` | Bearer Token (Coach/Admin) | **`[NEW]`** | Coach edits drill, customizes timeline, & approves plan (`is_approved`) |
| 9 | `/share-swing/practice-plan/:id/session/:sessionIndex/complete` | `PATCH` | Bearer Token | **`[NEW]`** | Marks coach practice session complete (`is_completed`, `completed_at`) |
| 10 | `/swing-library/:id/practice-plan/:sessionIndex/complete` | `PATCH` | Bearer Token | **`[NEW]`** | Marks AI coach practice session complete |

---

## 1. 🔄 Sharing Flow & Status Tracking

### Status Lifecycle:
```
[Offline Queue / Draft] ──▶ waiting_to_send
                                   │
                                   ▼ (Pushed / Online)
                                 sent
                                   │
                                   ▼ (Coach opens review)
                                viewed
                                   │
                                   ▼ (Coach responds)
                             coach_replied
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
    "idempotencyKey": "offline_queue_uuid_987654321",
    "message": "Coach, please check my transition tempo with Driver.",
    "isSwingVideo": true,
    "isAiAnalysis": false,
    "isPersonalNotesAndTips": false,
    "status": "sent",
    "createdAt": "2026-10-11T08:00:00.000Z",
    "updatedAt": "2026-10-11T08:00:00.000Z"
  }
}
```

---

## 2. 📝 Practice Note Attachment

When a golfer attaches a `practice_note_id`, the share record automatically stores and populates the logbook entry with its title, feelings, and drills:

### Endpoint: `GET /api/v1/share-swing/find/:id`
* **Access:** Authenticated Golfer or Coach (`Bearer <ACCESS_TOKEN>`)

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Share fetched successfully.",
  "data": {
    "_id": "6acb33f08769b793d62e9030",
    "status": "sent",
    "practice_note_id": {
      "_id": "6acb22f98769b793d62e9016",
      "title": "Drop-Step Driver Slice Correction Plan",
      "description": "Felt great holding my finish on the left heel...",
      "clubType": "Driver",
      "isImportant": true
    },
    "user": {
      "_id": "6a52ffb3fa91f21a312f5b23",
      "name": "Tiger Golfer",
      "email": "tiger@example.com"
    },
    "coach": {
      "_id": "685c22f08769b793d62e9010",
      "name": "PGA Master Coach John",
      "certificationName": "PGA Certified Class A"
    },
    "journey": [
      { "step": 1, "key": "swing_recorded", "title": "Swing Recorded", "status": "completed" },
      { "step": 2, "key": "ai_analysis", "title": "AI Analysis", "status": "completed" },
      { "step": 3, "key": "shared_with_coach", "title": "Shared with Coach", "status": "completed" },
      { "step": 4, "key": "coach_reviewing", "title": "Coach Reviewing", "status": "in_progress" },
      { "step": 5, "key": "coach_feedback", "title": "Coach Feedback", "status": "pending" },
      { "step": 6, "key": "practice_session", "title": "Practice Session", "status": "pending" }
    ]
  }
}
```

---

## 3. ✍️ Coach Review & Practice Plan Edit/Approval

Coaches have direct permission to edit the recommended drill, customize timeline items, and approve the plan:

### Endpoint: `PATCH /api/v1/share-swing/:id/practice-plan`
* **Access:** Authenticated Coach or Admin (`Bearer <ACCESS_TOKEN>`)

#### Request:
```json
{
  "recommendedDrill": "Modified Inside-Path Alignment Rod Gate Drill (15 reps at 80% tempo)",
  "practicePlan": [
    {
      "dayRange": "Days 1-2",
      "description": "Slow motion rehearsals feeling the club drop from the inside.",
      "is_completed": false
    },
    {
      "dayRange": "Days 3-4",
      "description": "Impact tape test: 20 balls hitting sweet spot at 80% speed.",
      "is_completed": false
    },
    {
      "dayRange": "Days 5-7",
      "description": "Driver target simulation: hit fairways on virtual holes.",
      "is_completed": false
    }
  ],
  "is_approved": true
}
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Practice plan updated and reviewed successfully.",
  "data": {
    "_id": "6acb33f08769b793d62e9030",
    "status": "coach_replied",
    "coachFeedback": {
      "feedbackText": "Coach updated practice plan and drills.",
      "recommendedDrill": "Modified Inside-Path Alignment Rod Gate Drill (15 reps at 80% tempo)",
      "is_approved": true,
      "approved_at": "2026-10-11T08:05:00.000Z",
      "practicePlan": [
        {
          "_id": "6acb44f08769b793d62e9041",
          "dayRange": "Days 1-2",
          "description": "Slow motion rehearsals feeling the club drop from the inside.",
          "is_completed": false,
          "completed_at": null
        },
        {
          "_id": "6acb44f08769b793d62e9042",
          "dayRange": "Days 3-4",
          "description": "Impact tape test: 20 balls hitting sweet spot at 80% speed.",
          "is_completed": false,
          "completed_at": null
        },
        {
          "_id": "6acb44f08769b793d62e9043",
          "dayRange": "Days 5-7",
          "description": "Driver target simulation: hit fairways on virtual holes.",
          "is_completed": false,
          "completed_at": null
        }
      ]
    }
  }
}
```

---

## 4. ✅ Session Completion Tracking (`is_completed`)

Allows golfers to check off each practice session day range once completed on the range:

### Endpoint: `PATCH /api/v1/share-swing/practice-plan/:id/session/:sessionIndex/complete`
* **Access:** Authenticated Golfer or Coach (`Bearer <ACCESS_TOKEN>`)

#### Request:
```json
{
  "is_completed": true
}
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Practice session completion status updated successfully.",
  "data": {
    "shareId": "6acb33f08769b793d62e9030",
    "updatedSession": {
      "_id": "6acb44f08769b793d62e9041",
      "dayRange": "Days 1-2",
      "description": "Slow motion rehearsals feeling the club drop from the inside.",
      "is_completed": true,
      "completed_at": "2026-10-11T08:06:12.345Z"
    },
    "stats": {
      "totalSessions": 3,
      "completedSessions": 1,
      "isAllCompleted": false,
      "completionRatio": 0.3333333333333333
    }
  }
}
```

### AI Practice Plan Completion:
* **Endpoint:** `PATCH /api/v1/swing-library/:id/practice-plan/:sessionIndex/complete`
* **Request:** `{ "is_completed": true }`
* **Response:** Updates `SwingLibrary.aiConversation[].practicePlan[sessionIndex]` with `is_completed: true`, `completed_at`, and returns completion ratio stats.
