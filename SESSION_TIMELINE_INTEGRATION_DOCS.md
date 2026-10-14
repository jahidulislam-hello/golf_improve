# 🏌️‍♂️ Golf Improve — Screen 2: Session Timeline Integration Guide

A complete mobile integration guide for **Screen 2 — Session Timeline**, detailing the 6-step human coaching progression timeline, offline sharing queue handling, and the dynamic **"Read Full Feedback"** action button.

---

## 📱 1. Screen 2 UI Overview

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

## 📱 5. Flutter Implementation Example

```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SessionTimelineScreen extends StatefulWidget {
  final String shareId;
  const SessionTimelineScreen({Key? key, required this.shareId}) : super(key: key);

  @override
  State<SessionTimelineScreen> createState() => _SessionTimelineScreenState();
}

class _SessionTimelineScreenState extends State<SessionTimelineScreen> {
  Map<String, dynamic>? sessionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTimeline();
  }

  Future<void> fetchTimeline() async {
    try {
      final response = await Dio().get(
        'https://api.golfimprove.com/api/v1/share-swing/single/${widget.shareId}',
        options: Options(headers: {'Authorization': 'Bearer <ACCESS_TOKEN>'}),
      );
      setState(() {
        sessionData = response.data['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final journey = (sessionData?['journey'] as List? ?? []);
    final primaryAction = sessionData?['primaryAction'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Session Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: journey.length,
              itemBuilder: (context, index) {
                final item = journey[index];
                final isCompleted = item['status'] == 'completed';
                final isCurrent = item['isCurrent'] == true;
                final isQueued = item['status'] == 'queued';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Indicator & Line
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? const Color(0xFF16A34A)
                                : isCurrent
                                    ? const Color(0xFF2563EB)
                                    : isQueued
                                        ? const Color(0xFFD97706)
                                        : Colors.grey.shade800,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : Text(
                                    '${item['step']}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        if (index < journey.length - 1)
                          Container(
                            width: 2,
                            height: 48,
                            color: isCompleted ? const Color(0xFF16A34A) : Colors.grey.shade800,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Step Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCompleted || isCurrent ? Colors.white : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['subtitle'] ?? '',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Main Action Button ("Read Full Feedback")
          if (primaryAction != null && primaryAction['isAvailable'] == true)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Navigate to Coach Feedback screen
                  },
                  child: Text(
                    primaryAction['label'] ?? 'Read Full Feedback',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```
