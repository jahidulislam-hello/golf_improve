# GolfImprove — Authentication & User Profile API Integration Guide
## Client Specification & Production Integration Documentation

*Version: **2.0.0 (Production Release)***  
*Base URL: `http://localhost:9090/api/v1` (Development) / `https://api.golfimprove.com/api/v1` (Production)*  
*Authentication Scheme: `Bearer <JWT_TOKEN>`*

---

## 1. Overview of Changes

In accordance with the latest design updates from **thijnhogeland**, the Authentication and User Profile flows have been updated to production standards:

1. **Streamlined Sign-Up (Email + Password Only):**
   - The `name` (Full Name) field has been removed from initial registration.
   - Registration requires only `email` and `password`. The system cleanly generates an account fallback and allows adding name/details later.
2. **Guest Mode ("Continue without an account"):**
   - Users can film swings immediately without logging in.
   - Local anonymous swings can merge seamlessly using the `/auth/merge-guest` endpoint once the user registers or logs in.
3. **Role Selection & Settings Role Switching:**
   - Role selection screen: Golfer (`"user"`) vs. Coach (`"coach"`).
   - Instant selection: Selecting a role immediately continues.
   - Users can change their role at any time in **Settings** via `PATCH /user/update-my-profile`.
4. **Golf Profile & Handicap Validation:**
   - **Handicap Index Range:** Expanded from **`-9.9` to `54.0`** (supports negative floats, direct typing, and `+`/`−` steppers).
   - **Gender Removed:** Removed from active registration and profile setup screens.
   - **Age Range:** Optional range selection (`"18-99"`).
   - **Practice Sessions:** Optional selection (`1`, `2`, `3+`).
   - **GolfImprove Stand Check:** Added boolean `usesGolfImproveStand` (supports both camelCase and snake_case `uses_golfimprove_stand`).
5. **Reset Password:**
   - Enforces a minimum of 8 characters for both `newPassword` and `confirmPassword`.
6. **Admin Dashboard Integration:**
   - Updated Users table to display user fallback name, formatted handicap (e.g. `+2.4` / `-1.2`), and "Stand Owner" status badge.
   - Cleaned up user details modal: replaced gender with Stand User status, Age Range, and Practice Sessions.

---

## 2. API Endpoints Specification

### 2.1 Register (Sign Up)

Registers a new user using email and password only. Sends a 6-digit verification OTP.

- **Method:** `POST`
- **Endpoint:** `/auth/register`
- **Auth Required:** No

#### Request Headers:
```http
Content-Type: application/json
```

#### Request Body:
```json
{
  "email": "golfer@example.com",
  "password": "Password123",
  "role": "user"
}
```

> **Note on `role`:** Optional, defaults to `"user"`. Can be `"user"` or `"coach"`.  
> **Note on `name`:** Optional. Can be omitted or sent as null.

#### Success Response (`201 Created` or `200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "OTP has been sent to your email address. Please verify it to activate your account.",
  "data": {
    "email": "golfer@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 2.2 Verify OTP (Check Your Email)

Validates the 6-digit numerical OTP.

- **Method:** `POST`
- **Endpoint:** `/auth/verify-email`
- **Auth Required:** No

#### Request Headers:
```http
Content-Type: application/json
```

#### Request Body:
```json
{
  "email": "golfer@example.com",
  "otp": "123456"
}
```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Email verified successfully.",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 2.3 Resend Verification Code

Resends a 6-digit OTP to the specified email with rate-limiting cooldown protection (60s).

- **Method:** `POST`
- **Endpoint:** `/auth/resend-code`
- **Auth Required:** No

#### Request Body:
```json
{
  "email": "golfer@example.com"
}
```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Verification code resent successfully."
}
```

---

### 2.4 Sign In (Login)

- **Method:** `POST`
- **Endpoint:** `/auth/login`
- **Auth Required:** No

#### Request Body:
```json
{
  "email": "golfer@example.com",
  "password": "Password123"
}
```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Login successful.",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 2.5 Forgot Password & Reset Password Flow

#### Step 1: Request Reset Link / OTP
- **Method:** `POST`
- **Endpoint:** `/auth/forgot-password`
```json
{
  "email": "golfer@example.com"
}
```

#### Step 2: Reset Password (Minimum 8 Characters)
- **Method:** `POST`
- **Endpoint:** `/auth/reset-password`
- **Headers:** `Authorization: Bearer <RESET_TOKEN>`
```json
{
  "newPassword": "NewSecurePassword123",
  "confirmPassword": "NewSecurePassword123"
}
```
#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Password reset successful."
}
```

---

### 2.6 Get My Profile (Golf Profile)

Retrieves the authenticated user's profile including handicap, stand ownership, and practice settings.

- **Method:** `GET`
- **Endpoint:** `/user/get-my-profile`
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "My profile retrieved successfully.",
  "data": {
    "_id": "6a5af4ae87e95d41f6cd9f9d",
    "name": "Alex Thompson",
    "email": "golfer@example.com",
    "role": "user",
    "profileUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/avatar.png",
    "handicap": 12.4,
    "handicap_index": 12.4,
    "startingHandicap": 16.6,
    "usesGolfImproveStand": true,
    "uses_golfimprove_stand": true,
    "age": "25-34",
    "age_range": "25-34",
    "practiceSessionPerWeek": "3",
    "practice_sessions_per_week": 3,
    "coach": null,
    "createdAt": "2026-10-10T12:00:00.000Z"
  }
}
```

---

### 2.7 Update My Profile ("Save Profile" & Settings)

Updates profile attributes including name, handicap, stand check status, practice sessions, age, and role.

- **Method:** `PATCH`
- **Endpoint:** `/user/update-my-profile`
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`
- **Content-Type:** `application/json` (or `multipart/form-data` if uploading new avatar image via `profile`)

#### Request Body Options:

##### Updating Golf Profile & Stand Check (Onboarding / Settings):
```json
{
  "name": "Alex Thompson",
  "usesGolfImproveStand": true,
  "age_range": "25-34",
  "handicap": 12.4,
  "practice_sessions_per_week": 3
}
```

##### Switching Role in Settings (Golfer &harr; Coach):
```json
{
  "role": "coach"
}
```
*(Can be `"user"` or `"coach"`)*

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "_id": "6a5af4ae87e95d41f6cd9f9d",
    "name": "Alex Thompson",
    "role": "coach",
    "handicap": 12.4,
    "usesGolfImproveStand": true,
    "uses_golfimprove_stand": true,
    "age": "25-34",
    "practiceSessionPerWeek": "3",
    "updatedAt": "2026-10-14T10:40:46.000Z"
  }
}
```

---

### 2.8 Update Handicap Index

Dedicated, atomic endpoint for updating the player's handicap. Automatically logs the change in handicap history and calculates improvement.

- **Method:** `PATCH` or `PUT`
- **Endpoint:** `/user/handicap` (also available via `/meta/handicap`)
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`
- **Content-Type:** `application/json`

#### Validation Rules:
* Permitted range: **`-9.9` to `54.0`** (supports floats, e.g. `-2.4`, `0.0`, `14.2`).
* Direct numeric typing and stepper values both supported.

#### Request Body:
```json
{
  "handicap": -2.4
}
```
*(Accepts either `"handicap"` or `"handicap_index"`)*

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Handicap updated successfully.",
  "data": {
    "handicap": {
      "current": -2.4,
      "starting": 12.4,
      "previous": 0.5,
      "change": -2.9,
      "improvement": -14.8,
      "isImproved": true,
      "isImprovement": true,
      "lastUpdatedAt": "2026-10-14T10:40:45.720Z"
    },
    "historyEntry": {
      "_id": "6acf5c2d7da800d9b98af189",
      "user": "6a5af4ae87e95d41f6cd9f9d",
      "handicap": -2.4,
      "previousHandicap": 0.5,
      "change": -2.9,
      "isImprovement": true,
      "createdAt": "2026-10-14T10:40:45.846Z"
    }
  }
}
```

---

### 2.9 Merge Guest Account Swings (`/auth/merge-guest`)

Merges swings recorded under an anonymous guest session identifier into an authenticated user account upon signup or login.

- **Method:** `POST`
- **Endpoint:** `/auth/merge-guest`
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`
- **Content-Type:** `application/json`

#### Request Body:
```json
{
  "guestId": "guest_uuid_9876543210"
}
```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Guest swings merged successfully into your account.",
  "data": {
    "mergedCount": 3,
    "guestId": "guest_uuid_9876543210",
    "userId": "6a5af4ae87e95d41f6cd9f9d"
  }
}
```

---

## 3. Backend HTTP & cURL Integration Workflows

### 3.1 Stand Check Submission (`PATCH /user/update-my-profile`)

Dispatched when user selects whether they use the GolfImprove Stand (`usesGolfImproveStand: true | false`). Stand ownership automatically grants free premium access bypass on the platform.

```bash
curl -X PATCH "http://localhost:9090/api/v1/user/update-my-profile" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "usesGolfImproveStand": true
  }'
```

### 3.2 Handicap Index Update (`PATCH /user/handicap`)

Submits manual handicap index value between `-9.9` and `54.0` (floats supported).

```bash
curl -X PATCH "http://localhost:9090/api/v1/user/handicap" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "handicap": -2.4
  }'
```

### 3.3 Merge Guest Sessions (`POST /auth/merge-guest`)

Transfers local guest session records to authenticated account:

```bash
curl -X POST "http://localhost:9090/api/v1/auth/merge-guest" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "guestId": "guest_device_uuid_456"
  }'
```

---

## 4. Verification & QA Checklist

- [x] **Registration:** Successfully registers with email + password without requiring name.
- [x] **Reset Password:** Enforces minimum 8 characters.
- [x] **Negative Handicap Values:** Validated with values like `-2.4` and `-9.9` with successful 200 responses.
- [x] **Stand Ownership Flag:** `usesGolfImproveStand` persisted and retrieved accurately.
- [x] **Role Switching:** User can seamlessly switch between `user` and `coach` in Settings without error.
- [x] **Admin Escalation Guard:** Users cannot escalate their role to `admin`.
- [x] **Admin Dashboard:** Users table and Details modal accurately show Stand ownership, negative handicaps, and omit gender.
