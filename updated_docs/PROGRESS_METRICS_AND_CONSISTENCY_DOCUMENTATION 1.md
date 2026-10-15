# 5. Progress Metrics, Weekly Consistency Ratio & Handicap Documentation

> **Status:** ✅ Fully Implemented, Tested & Production Ready  
> **Target Service:** `golf-improve-server`  
> **Relevant Models & Files:**  
> - User Model: [`src/models/user/user.model.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/user/user.model.ts)  
> - User Controller & Routes: [`src/models/user/user.controller.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/user/user.controller.ts), [`src/models/user/user.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/user/user.route.ts)  
> - Meta Service & Controller: [`src/models/meta/meta.service.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/meta/meta.service.ts), [`src/models/meta/meta.controller.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/meta/meta.controller.ts), [`src/models/meta/meta.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/meta/meta.route.ts)  
> - Handicap History Model: [`src/models/handicap-history/handicap.history.mode.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/handicap-history/handicap.history.mode.ts)  
> - Validation Schema: [`src/models/handicap-history/handicap.history.validation.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/handicap-history/handicap.history.validation.ts)

---

## 1. Overview & Architectural Shift

Following modern golf training principles, golfers do not practice every consecutive calendar day. Traditional rigid "daily streaks" penalize realistic practice habits and demoralize users. The progress tracking engine has undergone three major upgrades:

1. **Deprecate Daily Streaks in Favor of Weekly Consistency Ratio:**  
   Instead of checking consecutive active calendar days, the system evaluates the golfer's adherence against their configured weekly practice frequency:
   $$\text{Consistency Ratio} = \frac{\text{completed\_sessions\_count}}{\text{weekly\_target\_sessions}}$$
   - If a golfer targets 3 sessions per week and completes 3, the ratio is **$1.0$ (100%)** $\rightarrow$ `status: "goal_achieved"`.
   - If they complete 2 sessions, the ratio is **$0.67$ (67%)** $\rightarrow$ `status: "on_track"`.
   - The legacy `practiceStreak` object remains included in response payloads marked with `isDeprecated: true` to prevent breaking existing mobile app screens.

2. **Weekly Practice Time Aggregation (Minutes Practiced):**  
   Calculates realistic range time spent by aggregating recorded clip durations along with physical session span (elapsed time from first to last recorded swing per active practice day, minimum 15 minutes per session). Provides weekly delta and trend (`"up" | "down" | "same"`).

3. **Direct Handicap Updates (`PUT /api/v1/user/handicap`):**  
   Enables golfers to manually update their current handicap index from either profile settings or progress dashboard.
   - **Range Supported:** **`-9.9` to `54.0`** (supports negative handicaps / plus golfers, e.g. `-2.4`).
   - Automatically logs historical milestones into `HandicapHistory` and recalculates net improvement.

---

## 2. API Endpoints

### 2.1 My Progress Dashboard (`GET /api/v1/meta/my-progress`)
Returns complete weekly performance metrics, consistency ratio, minutes practiced, handicap trajectory, and 7-day activity charts.

- **Endpoint:** `GET /api/v1/meta/my-progress` (also available via `GET /api/meta/my-progress`)
- **Auth:** Bearer JWT (`auth("user")`)

#### cURL Request:
```bash
curl -X GET "http://localhost:9090/api/v1/meta/my-progress" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

- **Response (200 OK):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "My progress retrieved successfully.",
  "data": {
    "consistency": {
      "weeklyTargetSessions": 3,
      "completedSessions": 2,
      "ratio": 0.67,
      "percentage": 67,
      "status": "on_track",
      "message": "2 of 3 sessions completed this week (1 remaining)."
    },
    "minutesPracticed": {
      "thisWeek": 45,
      "lastWeek": 30,
      "delta": 15,
      "trend": "up",
      "message": "+15 mins vs last week"
    },
    "thisWeek": {
      "minutesPracticed": 45,
      "sessionsCompleted": 2,
      "targetSessions": 3,
      "consistencyRatio": 0.67,
      "consistencyPercentage": 67,
      "swings": 14,
      "lastWeekSwings": 8,
      "delta": 6,
      "trend": "up",
      "isBestWeek": true,
      "message": "Up from 8 swings last week"
    },
    "practiceStreak": {
      "days": 2,
      "personalBest": 5,
      "isPersonalBest": false,
      "isDeprecated": true,
      "deprecatedNotice": "Daily streaks are deprecated in favor of weekly consistency ratio (completed_sessions / weekly_target)."
    },
    "handicap": {
      "current": 14.8,
      "starting": 18.2,
      "improvement": -3.4,
      "isImproved": true,
      "lastUpdatedAt": "2026-10-11T08:50:00.000Z",
      "history": [
        {
          "handicap": 16.5,
          "previousHandicap": 18.2,
          "change": -1.7,
          "isImprovement": true,
          "createdAt": "2026-09-15T10:00:00.000Z"
        },
        {
          "handicap": 14.8,
          "previousHandicap": 16.5,
          "change": -1.7,
          "isImprovement": true,
          "createdAt": "2026-10-11T08:50:00.000Z"
        }
      ]
    },
    "weeklyActivityChart": [
      { "day": "Sun", "swings": 6, "minutes": 25 },
      { "day": "Mon", "swings": 0, "minutes": 0 },
      { "day": "Tue", "swings": 8, "minutes": 20 },
      { "day": "Wed", "swings": 0, "minutes": 0 },
      { "day": "Thu", "swings": 0, "minutes": 0 },
      { "day": "Fri", "swings": 0, "minutes": 0 },
      { "day": "Sat", "swings": 0, "minutes": 0 }
    ],
    "weeklySwingsChart": [
      { "day": "Sun", "count": 6 },
      { "day": "Mon", "count": 0 },
      { "day": "Tue", "count": 8 },
      { "day": "Wed", "count": 0 },
      { "day": "Thu", "count": 0 },
      { "day": "Fri", "count": 0 },
      { "day": "Sat", "count": 0 }
    ],
    "totals": {
      "totalSessions": 12,
      "totalSwings": 48,
      "totalPracticeMinutes": 240
    }
  }
}
```

---

### 2.2 Manual Handicap Update (`PUT /api/v1/user/handicap`)
Allows the golfer to update their official handicap index.

- **Endpoints Supported:**
  - `PUT /api/v1/user/handicap`
  - `PATCH /api/v1/user/handicap`
  - `PUT /api/v1/meta/handicap`
  - `PATCH /api/v1/meta/update-handicap`
- **Auth:** Bearer JWT (`auth("common")` or `auth("user")`)
- **Headers:** `Content-Type: application/json`

#### cURL Request:
```bash
curl -X PUT "http://localhost:9090/api/v1/user/handicap" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "handicap": 14.8 }'
```

- **Request Body (Accepts either `handicap` or `handicap_index`):**
```json
{
  "handicap": 14.8
}
```
*or:*
```json
{
  "handicap_index": 14.8
}
```
- **Response (200 OK):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Handicap updated successfully.",
  "data": {
    "handicap": {
      "current": 14.8,
      "starting": 18.2,
      "previous": 16.5,
      "change": -1.7,
      "improvement": -3.4,
      "isImproved": true,
      "isImprovement": true,
      "lastUpdatedAt": "2026-10-11T08:50:00.000Z"
    },
    "historyEntry": {
      "_id": "67a3fd918b...",
      "user": "6acb...",
      "handicap": 14.8,
      "previousHandicap": 16.5,
      "change": -1.7,
      "isImprovement": true,
      "createdAt": "2026-10-11T08:50:00.000Z"
    }
  }
}
```

---

### 2.3 User Summary Dashboard (`GET /api/v1/meta/user`)
The lightweight home summary endpoint now includes both `minutesPracticedThisWeek` and the `consistency` ratio:

#### cURL Request:
```bash
curl -X GET "http://localhost:9090/api/v1/meta/user" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

```json
{
  "statusCode": 200,
  "success": true,
  "message": "User summary successfully.",
  "data": {
    "summary": {
      "totalSessions": 12,
      "swingsThisWeek": 14,
      "totalAiAnalyses": 9,
      "minutesPracticedThisWeek": 45,
      "consistency": {
        "weeklyTargetSessions": 3,
        "completedSessions": 2,
        "ratio": 0.67,
        "percentage": 67
      }
    },
    "activeSession": { ... },
    "quickAction": { ... },
    "recentActivities": [ ... ]
  }
}
```

---

## 3. Verification & Live Testing Summary

- **Consistency Ratio Calculation:** Verified with test users targeting 3 sessions. When 1 session was recorded, the service accurately calculated `completedSessions: 1`, `ratio: 0.33`, `percentage: 33`, and status `"needs_practice"`.
- **Practice Minutes Calculation:** Verified active day estimation and video duration aggregation (e.g. 15 mins for active practice day).
- **Handicap Update Workflow:** Verified updating from 18.4 to 15.2 correctly recognized `change: -3.2`, flagged `isImprovement: true`, updated `user.handicap` and `user.handicap_index` in the database, and created an entry in `HandicapHistory`.
- **Backward Compatibility:** Confirmed that legacy mobile clients reading `practiceStreak` still receive valid objects containing `days`, `personalBest`, and `isDeprecated: true`.
- **TypeScript Integrity:** Compiled with `npx tsc --noEmit` across both `golf-improve-server` and `golf-improve-dashboard` with **0 errors**.
