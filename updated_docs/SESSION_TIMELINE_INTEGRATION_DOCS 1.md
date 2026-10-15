# 🏌️‍♂️ Golf Improve — Session Timeline API Integration Guide
## Backend API Specification & Production Integration Documentation

A comprehensive backend API integration guide for the **Session Timeline**, detailing the 6-step human coaching progression timeline, offline sharing queue handling, and the dynamic **"Read Full Feedback"** action button payload.

---

## 1. Timeline Overview & Architecture

```text
┌────────────────────────────────────────────────────────┐
│  < Session Timeline                                    │
│                                                        │
│  ● 1. Swing Recorded                       Oct 14, 2026 │
│  │    Driver · Face On · 0:12                Completed │
│  │                                                     │
│  ● 2. Shared with Coach                    Oct 14, 2026 │
│  │    Coach Mike notified (video, notes)     Completed │
│  │                                                     │
│  ● 3. Coach Reviewing                      In progress │
│  │    Usually responds within 2 hours                  │
│  │                                                     │
│  ○ 4. Feedback Received                        Pending │
│  │    Awaiting coach response                          │
│  │                                                     │
│  ○ 5. Drill Recommended                        Pending │
│  │    Pending coach assessment                         │
│  │                                                     │
│  ○ 6. Practice Plan Created                    Pending │
│       Pending coach plan                               │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │      [ 💬 Read Full Feedback ]                   │  │ ◄── Main Action Button
│  └──────────────────────────────────────────────────┘  │      (Appears once feedback arrives)
└────────────────────────────────────────────────────────┘
```

---

## 🧭 2. Timeline Specifications & Business Rules

1. **Exact 6-Step Sequence**:
   - `1. Swing Recorded`
   - `2. Shared with Coach`
   - `3. Coach Reviewing`
   - `4. Feedback Received`
   - `5. Drill Recommended`
   - `6. Practice Plan Created`
2. **Automatic Analysis Step Removed**:
   - The session timeline focuses exclusively on the golfer-coach relationship. Automatic AI fault classifications and scores are excluded from this timeline.
3. **Date & Status for Each Step**:
   - Every step returns `timestamp` (ISO-8601 string or `null`) and `status` (`"completed"`, `"in_progress"`, `"pending"`, `"queued"`).
4. **Offline Sharing Queue Support**:
   - If the user shares while offline (or sharing is queued), Step 2 indicates:
     `"Sharing queued — will continue automatically later when online"` with `status: "queued"`.
5. **Dynamic "Read Full Feedback" Button**:
   - Once the coach responds, `primaryAction` returns `action: "read_full_feedback"` with `label: "Read Full Feedback"`.

---

## ⚡ 3. API Endpoints

### Endpoint A: Get Session Timeline from Share Record
- **Method**: `GET`
- **URL**: `/api/v1/share-swing/single/:shareId`
- **Headers**: `Authorization: Bearer <TOKEN>`

### Endpoint B: Get Session Timeline from Swing Library Record
- **Method**: `GET`
- **URL**: `/api/v1/swing-library/find/:analysisId`
- **Headers**: `Authorization: Bearer <TOKEN>`

---

## 📥 4. Example API Response Payload

```json
{
  "statusCode": 200,
  "success": true,
  "message": "Share fetched successfully.",
  "data": {
    "_id": "6a85677f944c817cb6b96aeb",
    "status": "responded",
    "journey": [
      {
        "step": 1,
        "key": "swing_recorded",
        "title": "Swing Recorded",
        "subtitle": "Driver · Face On · 0:12",
        "timestamp": "2026-10-14T08:15:00.000Z",
        "status": "completed",
        "isCurrent": false
      },
      {
        "step": 2,
        "key": "shared_with_coach",
        "title": "Shared with Coach",
        "subtitle": "James Keller notified (video, notes included)",
        "timestamp": "2026-10-14T08:18:00.000Z",
        "status": "completed",
        "isCurrent": false
      },
      {
        "step": 3,
        "key": "coach_reviewing",
        "title": "Coach Reviewing",
        "subtitle": "Review completed",
        "statusText": "Completed",
        "status": "completed",
        "isCurrent": false,
        "timestamp": "2026-10-14T09:00:00.000Z"
      },
      {
        "step": 4,
        "key": "feedback_received",
        "title": "Feedback Received",
        "subtitle": "Feedback received from James Keller",
        "timestamp": "2026-10-14T09:30:00.000Z",
        "status": "completed",
        "isCurrent": false
      },
      {
        "step": 5,
        "key": "drill_recommended",
        "title": "Drill Recommended",
        "subtitle": "Towel Under Trail Arm & Alignment Gate Drill",
        "timestamp": "2026-10-14T09:30:00.000Z",
        "status": "completed",
        "isCurrent": false
      },
      {
        "step": 6,
        "key": "practice_plan_created",
        "title": "Practice Plan Created",
        "subtitle": "3 practice sessions scheduled",
        "timestamp": "2026-10-14T09:30:00.000Z",
        "status": "completed",
        "isCurrent": true
      }
    ],
    "primaryAction": {
      "label": "Read Full Feedback",
      "action": "read_full_feedback",
      "shareId": "6a85677f944c817cb6b96aeb",
      "feedbackId": "6a85677f944c817cb6b96aeb",
      "isAvailable": true
    },
    "feedbackCard": {
      "coach": {
        "name": "James Keller",
        "profileUrl": "https://s3.amazonaws.com/coaches/jk.png",
        "certification": "PGA Master Professional"
      },
      "sessionInfo": "Driver, Face On",
      "receivedAt": "2026-10-14T09:30:00.000Z",
      "feedbackQuote": "Great tempo on the backswing! Focus on maintaining lead hip rotation through impact.",
      "recommendedDrill": "Towel Under Trail Arm & Alignment Gate Drill",
      "mainButton": "Read Full Feedback"
    }
  }
}
```

---

## 5. Backend API Integration & Execution Workflow

### 5.1 Fetching Timeline via cURL

```bash
# Retrieve Session Timeline and Coach Review Status
curl -X GET "http://localhost:9090/api/v1/share-swing/single/6a85677f944c817cb6b96aeb" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json"
```

### 5.2 Transitioning Queued Offline Shares (`PATCH /share-swing/send-queued/:id`)

When a share was queued offline (`status: "waiting_to_send"`), the client sends it to the coach once network is restored:

```bash
curl -X PATCH "http://localhost:9090/api/v1/share-swing/send-queued/6a85677f944c817cb6b96aeb" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json"
```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Share sent to coach successfully.",
  "data": {
    "_id": "6a85677f944c817cb6b96aeb",
    "status": "sent",
    "journey": [
      { "step": 1, "key": "swing_recorded", "status": "completed" },
      { "step": 2, "key": "shared_with_coach", "status": "completed" },
      { "step": 3, "key": "coach_reviewing", "status": "in_progress" }
    ]
  }
}
```

---

## 6. Real-time Status Transitions & Socket Events

For apps implementing real-time updates without aggressive HTTP polling:

| Event Name | Trigger | Payload | Client Action |
| :--- | :--- | :--- | :--- |
| `share:viewed` | Coach opens swing review | `{ "shareId": "...", "status": "viewed" }` | Mark Step 3 as active in journey |
| `share:responded` | Coach submits feedback & drill | `{ "shareId": "...", "status": "coach_replied", "feedback": { ... } }` | Complete Steps 4-6, enable "Read Full Feedback" |
| `plan:updated` | Coach alters practice schedule | `{ "shareId": "...", "practicePlan": [ ... ] }` | Re-render practice session checklist |

---

## 7. Verification & Production Checklist

- [x] **Strict 6-Step Journey:** Removed legacy automated AI steps; 100% focused on Golfer-to-PGA-Coach review.
- [x] **No Mobile Client Code:** Clean backend API endpoints, JSON payloads, and cURL commands.
- [x] **Offline Queue Resolution:** Queued shares (`waiting_to_send`) cleanly transition to `sent` via `/share-swing/send-queued/:id`.
- [x] **Primary Action Validation:** `primaryAction` payload dynamically exposes `read_full_feedback` only when coach feedback exists.
