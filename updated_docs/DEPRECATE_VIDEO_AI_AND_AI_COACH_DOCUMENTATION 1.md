# 🏌️‍♂️ Section 7 & AI Engine: Conversational Golf Coach & Dynamic Swing Analysis

> **Status:** Production-Ready & Verified with Live Google Gemini AI  
> **Target Release:** v1.1.0  
> **Base API Route:** `/api/v1`  
> **Live Engine:** [`src/utils/openai.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/utils/openai.ts) (`Google Gemini AI: gemini-2.5-flash / gemini-1.5-flash / gemini-2.0-flash`)

---

## 📑 Executive Summary of Updates

All responses across conversational coaching and swing analysis are dynamically synthesized via **Google Gemini AI** ([`src/utils/openai.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/utils/openai.ts)). Hardcoded responses, mock placeholders, and false video claims have been eliminated:

1. **Conversational Practice Coach (`/api/v1/ai-coach/`):**
   - **Strict No-Video-Viewing Constraint:** The AI coach explicitly never claims to have watched or diagnosed the swing video directly.
   - **One Recommendation at a Time:** Focuses the golfer on a single biomechanical priority rather than overwhelming them.
   - **Structured 2-Week Plan:** Outputs three progressive sessions (`Days 1–3: Foundation`, `Days 4–7: Repetition`, `Days 8–14: Transfer`).
   - **Practice Follow-Up Questions:** Ends with contextual questions assessing the golfer's shot tendencies and feels.
2. **Save to Notes & Share with Coach:**
   - `POST /api/v1/ai-coach/save-to-notes`: Persists the AI practice plan directly into the golfer's [`NoteBook`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/note-book/note.book.model.ts).
   - `POST /api/v1/ai-coach/share-with-coach`: Dispatches the AI plan to the golfer's assigned coach with in-app notification.
3. **Admin Token & Audit Logs (`GET /api/v1/ai-coach/admin/logs`):**
   - Provides complete audit visibility over AI usage, prompt lengths, model fallbacks, and token consumption.
4. **Swing Kinematic Analysis (`POST /api/v1/swing/analyze/video/:id`):**
   - Dynamic Gemini evaluation of swing kinematics, generating observation cards, coach comparison quotes, and actionable range drills.

---

## 📑 Feature Status & Endpoints Matrix

| # | Endpoint | Method | Auth Required | Status | Description |
|---|---|---|---|---|---|
| 1 | `/ai-coach/chat` | `POST` | Bearer Token | `[LIVE GEMINI AI]` | Primary conversational coach (no video claim, 1 recommendation, 2-week plan) |
| 2 | `/ai-coach/save-to-notes` | `POST` | Bearer Token | `[NEW]` | Saves AI generated drill & plan directly to `NoteBook` |
| 3 | `/ai-coach/share-with-coach` | `POST` | Bearer Token | `[NEW]` | Dispatches AI plan to human coach with notifications |
| 4 | `/ai-coach/admin/logs` | `GET` | Bearer Token (Admin) | `[NEW]` | Audit logs with model tracking and token usage aggregation |
| 5 | `/swing-library/ask/:id` | `POST` | Bearer Token | `[COMPATIBLE]` | Context-based swing Q&A alias |
| 6 | `/swing-library/ask-coach/:id` | `POST` | Bearer Token | `[COMPATIBLE]` | Mobile alias for AI Golf Coach assistant |
| 7 | `/swing/analyze/video/:id` | `POST` | Bearer Token | `[LIVE GEMINI AI]` | Swing kinematic analysis with observations and drills |

---

## 1. 🤖 Primary AI Coach Chat (`POST /api/v1/ai-coach/chat`)

* **Endpoint:** `POST /api/v1/ai-coach/chat`
* **Access:** Authenticated (`Bearer <ACCESS_TOKEN>`)
* **Headers:** `Content-Type: application/json`

### Request Body:
```json
{
  "message": "I am slicing my driver to the right and losing distance off the tee.",
  "clubType": "Driver",
  "sessionId": "session_range_morning_1",
  "conversationHistory": [
    {
      "role": "user",
      "content": "Hello coach, I need help dialing in my driver."
    },
    {
      "role": "assistant",
      "content": "Welcome! Let's get your driver straightened out. What specific miss are you seeing?"
    }
  ]
}
```

### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "AI coach response generated successfully.",
  "data": {
    "conversationId": "6b8c901234567890abcdef12",
    "answer": "A driver slice is almost always caused by an open clubface relative to your swing path at impact. For mid-handicap golfers, this usually stems from an over-the-top move where the upper body starts the downswing too early.",
    "recommendation": "Focus entirely on keeping your back facing the target a split-second longer in transition to allow the club to drop down on an inside path.",
    "recommendedDrill": "Split-Grip Release Drill",
    "practicePlan": [
      {
        "phase": "Phase 1: Foundation",
        "days": "Days 1–3",
        "drill": "Slow-motion rehearsals with split hands feeling the toe pass the heel",
        "description": "25 rehearsal swings in front of a mirror focusing on forearm rotation"
      },
      {
        "phase": "Phase 2: Repetition",
        "days": "Days 4–7",
        "drill": "70% speed strikes using alignment stick gate",
        "description": "30 balls hitting gentle push-draws into the fairway corridor"
      },
      {
        "phase": "Phase 3: Transfer",
        "days": "Days 8–14",
        "drill": "Full speed target routine simulating tight driving holes",
        "description": "15 drives alternating targets with full pre-shot routine"
      }
    ],
    "followUpQuestions": [
      "Does your slice start left and curve right (pull-slice), or start right and curve further right (push-slice)?",
      "Where on the driver face is your contact usually centered—heel, toe, or low?"
    ],
    "metadata": {
      "modelUsed": "gemini-2.5-flash",
      "estimatedTokens": 482
    }
  }
}
```

---

## 2. 💾 Save AI Practice Plan to Notes (`POST /api/v1/ai-coach/save-to-notes`)

Persists the AI-generated drill and multi-day schedule into [`NoteBook`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/note-book/note.book.model.ts).

### Request:
```json
{
  "conversationId": "6b8c901234567890abcdef12",
  "title": "AI Practice Plan: Split-Grip Release Drill",
  "note": "Felt great on range, focus on soft grip pressure.",
  "recommendedDrill": "Split-Grip Release Drill",
  "clubType": "Driver",
  "practicePlan": [
    {
      "phase": "Phase 1: Foundation",
      "days": "Days 1–3",
      "drill": "Slow feel rehearsal",
      "description": "30 mirror reps"
    },
    {
      "phase": "Phase 2: Repetition",
      "days": "Days 4–7",
      "drill": "50% speed reps",
      "description": "30 practice balls"
    },
    {
      "phase": "Phase 3: Transfer",
      "days": "Days 8–14",
      "drill": "Full speed target routine",
      "description": "On-course transfer"
    }
  ]
}
```

### Response (`201 Created`):
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Practice plan saved to notebook successfully.",
  "data": {
    "_id": "6acb22f98769b793d62e9016",
    "user": "6a52ffb3fa91f21a312f5b23",
    "title": "AI Practice Plan: Split-Grip Release Drill",
    "description": "Recommended Drill: Split-Grip Release Drill\n\nNotes: Felt great on range, focus on soft grip pressure.\n\nPractice Schedule:\n• Days 1–3 (Phase 1: Foundation): Slow feel rehearsal — 30 mirror reps\n• Days 4–7 (Phase 2: Repetition): 50% speed reps — 30 practice balls\n• Days 8–14 (Phase 3: Transfer): Full speed target routine — On-course transfer",
    "clubType": "Driver",
    "isImportant": true,
    "createdAt": "2026-10-15T09:00:00.000Z"
  }
}
```

---

## 3. 👥 Share AI Plan with Coach (`POST /api/v1/ai-coach/share-with-coach`)

Dispatches the AI-generated practice plan to the golfer's assigned human coach and triggers an in-app notification.

### Request:
```json
{
  "conversationId": "6b8c901234567890abcdef12",
  "coachId": "685c22f08769b793d62e9010",
  "message": "Coach, check out this 2-week practice plan I generated for my driver release.",
  "planTitle": "2-Week Driver Slice Correction",
  "recommendedDrill": "Split-Grip Release Drill"
}
```

### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Practice plan shared with coach successfully.",
  "data": {
    "shared": true,
    "coachId": "685c22f08769b793d62e9010",
    "planTitle": "2-Week Driver Slice Correction",
    "notificationSent": true
  }
}
```

---

## 4. 📊 Admin Audit & Token Logs (`GET /api/v1/ai-coach/admin/logs`)

Allows administrators to review conversation activity, prompt statistics, and token consumption.

* **Endpoint:** `GET /api/v1/ai-coach/admin/logs?page=1&limit=20`
* **Access:** Authenticated Admin (`Bearer <ACCESS_TOKEN>`)

### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "AI coach logs retrieved successfully.",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 142,
    "totalPage": 8
  },
  "data": {
    "summary": {
      "totalConversations": 142,
      "totalEstimatedTokens": 68420,
      "activeModel": "gemini-2.5-flash"
    },
    "logs": [
      {
        "_id": "6b8c901234567890abcdef12",
        "user": {
          "_id": "6a52ffb3fa91f21a312f5b23",
          "name": "Tiger Golfer",
          "email": "tiger@example.com"
        },
        "clubType": "Driver",
        "question": "I am slicing my driver to the right and losing distance off the tee.",
        "recommendedDrill": "Split-Grip Release Drill",
        "estimatedTokens": 482,
        "modelUsed": "gemini-2.5-flash",
        "createdAt": "2026-10-15T09:00:00.000Z"
      }
    ]
  }
}
```
