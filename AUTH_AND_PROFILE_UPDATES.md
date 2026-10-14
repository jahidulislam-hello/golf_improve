agent# 🏌️‍♂️ Section 1: Auth & User Profile — Complete API & Feature Documentation

> **Status:** Production-Ready & Verified  
> **Version:** v1.1.0  
> **Base URL:** `http://localhost:9090/api/v1` (or production gateway)

This document serves as the comprehensive reference guide for **Auth & User Profile**, detailing both the **Current / Core platform features** and the **Newly Updated features** (marked with `[NEW]` and `[UPDATED]`).

---

## 📑 Feature Status & Quick Matrix

| # | Endpoint | Method | Auth Required | Status | Description |
|---|---|---|---|---|---|
| 1 | `/auth/guest-session` | `POST` | Public | **`[NEW]`** | Create anonymous guest session & token |
| 2 | `/auth/merge-guest` | `POST` | Bearer Token | **`[NEW]`** | Merge guest swings/notes to authenticated user |
| 3 | `/auth/register` | `POST` | Public | **`[UPDATED]`** | Sign-up with **optional name** & auto-merge support |
| 4 | `/auth/resend-otp` | `POST` | Public | **`[UPDATED]`** | Resend OTP with **60s rate limit cooldown** |
| 5 | `/auth/forgot-password` | `POST` | Public | **`[UPDATED]`** | Password recovery with **60s rate limit cooldown** |
| 6 | `/auth/verify-otp` | `POST` | Bearer Token | **`[UPDATED]`** | Activates user & auto-merges guest data |
| 7 | `/auth/login` | `POST` | Public | `[CURRENT]` | Standard email + password login |
| 8 | `/auth/forgot-otp-verify` | `POST` | Bearer Token | `[CURRENT]` | Verify OTP for password reset flow |
| 9 | `/auth/reset-password` | `POST` | Bearer Token | `[CURRENT]` | Set new password after OTP verification |
| 10 | `/auth/change-password` | `POST` | Bearer Token | `[CURRENT]` | Change password with current & new password |
| 11 | `/auth/refresh-token` | `POST` | Public/Cookie | `[CURRENT]` | Issue new access token from refresh token |
| 12 | `/auth/logout` | `GET` | Bearer Token | `[CURRENT]` | Revoke session & clear cookies |
| 13 | `/auth/google` | `GET` | Public | `[CURRENT]` | Google OAuth login initiation |
| 14 | `/auth/apple` | `GET` | Public | `[CURRENT]` | Apple Sign-in initiation |
| 15 | `/user/get-my-profile` | `GET` | Bearer Token | **`[UPDATED]`** | Fetch profile with new schema fields |
| 16 | `/user/update-my-profile`| `PATCH` | Bearer Token | **`[UPDATED]`** | Update profile; **blocks direct email edit** |
| 17 | `/user/request-email-change` | `POST` | Bearer Token | **`[NEW]`** | Step 1 of verified email change (sends OTP) |
| 18 | `/user/verify-email-change`  | `POST` | Bearer Token | **`[NEW]`** | Step 2 of verified email change (updates email) |
| 19 | `/user/get-all` | `GET` | Admin | `[CURRENT]` | Paginated list of all platform users |
| 20 | `/user/find/:id` | `GET` | Admin / User | `[CURRENT]` | Get user profile by ID |
| 21 | `/user/change-status/:id` | `PATCH` | Admin | `[CURRENT]` | Change status (`active`, `suspended`) |
| 22 | `/user/delete/my-account` | `PATCH` | Bearer Token | `[CURRENT]` | Soft delete account |
| 23 | `/user/delete/:id` | `DELETE`| Admin | `[CURRENT]` | Hard delete user |
| 24 | `/user/coach/students` | `GET` | Coach | `[CURRENT]` | List students assigned to coach |
| 25 | `/user/coach/students/:studentId` | `GET` | Coach | `[CURRENT]` | Detailed student stats & recent uploads |

---

## 1. 🥷 Guest / Anonymous Mode & Data Merging

### 1.1 Initiate Guest Session `[NEW]`
Allows golfers to open the mobile app and immediately record swings, log notes, and test the camera without signing up first.

* **Endpoint:** `POST /api/v1/auth/guest-session`
* **Access:** Public

#### Request:
```http
POST /api/v1/auth/guest-session
Content-Type: application/json
```

#### Response (`201 Created`):
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Guest session initialized successfully.",
  "data": {
    "results": {
      "_id": "6acb203402a9126ccdeecf44",
      "name": "Guest Golfer",
      "email": "guest_348910d8a1@guest.golfimprove.com",
      "role": "user",
      "isGuest": true,
      "status": "active"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "isGuest": true
  }
}
```

---

### 1.2 Merge Guest Data into Account `[NEW]`
When a guest golfer subsequently registers or signs in, their recorded swings (`Swing`), swing library entries (`SwingLibrary`), and notebooks (`NoteBook`) are permanently merged into their new user ID.

#### Option A: Automatic Merge upon Registration
Pass `guestId` in the registration payload:
```json
{
  "email": "john.golfer@example.com",
  "password": "Password123",
  "guestId": "6acb203402a9126ccdeecf44"
}
```
When `POST /auth/verify-otp` succeeds, the backend merges all data automatically.

#### Option B: Explicit Merge Endpoint
* **Endpoint:** `POST /api/v1/auth/merge-guest`
* **Access:** Authenticated (`Bearer <ACCESS_TOKEN>`)

#### Request:
```json
{
  "guestId": "6acb203402a9126ccdeecf44"
}
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Guest swings and data merged successfully into user account",
  "data": {
    "success": true,
    "message": "Guest swings and data merged successfully into user account",
    "mergedCount": {
      "swings": 4,
      "libraries": 4,
      "notes": 2,
      "shares": 0
    }
  }
}
```

---

## 2. 🔐 Authentication Endpoints

### 2.1 User Registration `[UPDATED]`
The `name` field is now **optional**. If omitted, the server defaults the user's name to their email handle or `"Golfer"`.
Also enforces a **60-second cooldown** if an OTP was recently sent.

* **Endpoint:** `POST /api/v1/auth/register`
* **Access:** Public

#### Request Body:
```json
{
  "email": "john@example.com",
  "password": "Password123",
  "name": "John Doe",              // Optional (can be omitted or null)
  "role": "user",                   // Optional (default: "user")
  "guestId": "6acb203402a9126ccde"  // Optional (for guest data auto-merge)
}
```

#### Response (`201 Created`):
```json
{
  "statusCode": 201,
  "success": true,
  "message": "OTP has been sent to your email address. Please verify it to activate your account.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 2.2 Verify Registration OTP `[UPDATED]`
Verifies OTP code and activates the account. If a `guestId` was attached to the registration, all guest swings and notes are migrated automatically.

* **Endpoint:** `POST /api/v1/auth/verify-otp`
* **Headers:** `Authorization: Bearer <REGISTRATION_TOKEN>`

#### Request Body:
```json
{
  "otp": "491823"
}
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "OTP verified successfully. User activated.",
  "data": {
    "user": {
      "_id": "6a52ffb3fa91f21a312f5b23",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user",
      "status": "active"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 2.3 Resend OTP with 60-Second Cooldown `[UPDATED]`
Generates a new verification code. Enforces rate limiting so rapid requests are rejected.

* **Endpoint:** `POST /api/v1/auth/resend-otp`
* **Access:** Public

#### Request Body:
```json
{
  "email": "john@example.com"
}
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "OTP has been resent to your email address.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### Error Response if within 60s cooldown (`429 Too Many Requests`):
```json
{
  "success": false,
  "message": "Please wait 48 seconds before requesting a new code.",
  "errorMessages": [
    {
      "path": "",
      "message": "Please wait 48 seconds before requesting a new code."
    }
  ]
}
```

---

### 2.4 User Login `[CURRENT]`
Authenticates a user via email and password, returning user profile details and tokens.

* **Endpoint:** `POST /api/v1/auth/login`
* **Access:** Public

#### Request Body:
```json
{
  "email": "john@example.com",
  "password": "Password123"
}
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Login successfully.",
  "data": {
    "results": {
      "_id": "6a52ffb3fa91f21a312f5b23",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user",
      "uses_golfimprove_stand": false,
      "status": "active"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 2.5 Forgot Password & Reset Password Flow `[CURRENT & UPDATED]`

1. **Request Reset Code (`POST /auth/forgot-password`) `[UPDATED - 60s cooldown]`**
   ```json
   { "email": "john@example.com" }
   ```
2. **Verify Forgot Code (`POST /auth/forgot-otp-verify`)**
   Headers: `Authorization: Bearer <FORGOT_TOKEN>`
   ```json
   { "otp": "592810" }
   ```
3. **Set New Password (`POST /auth/reset-password`)**
   Headers: `Authorization: Bearer <RESET_TOKEN>`
   ```json
   {
     "newPassword": "NewPassword123"
   }
   ```

---

### 2.6 Change Password `[CURRENT]`
* **Endpoint:** `POST /api/v1/auth/change-password`
* **Access:** Authenticated (`Bearer <ACCESS_TOKEN>`)

```json
{
  "currentPassword": "OldPassword123",
  "newPassword": "NewPassword123"
}
```

---

### 2.7 Refresh Token & Logout `[CURRENT]`
* **Refresh Token:** `POST /api/v1/auth/refresh-token` (Sends new access token)
* **Logout:** `GET /api/v1/auth/logout` (Revokes server-side session)

---

## 3. ✉️ Verified Email Change Flow `[NEW]`

Direct email modification via `PATCH /user/update-my-profile` is blocked. Users must follow this two-step verification workflow.

### 3.1 Step 1: Request Email Change `[NEW]`
Validates new email address, verifies it is not taken, enforces 60s cooldown, sends OTP to the new email, and sets `pendingEmail` on the user account.

* **Endpoint:** `POST /api/v1/user/request-email-change`
* **Access:** Authenticated (`Bearer <ACCESS_TOKEN>`)

#### Request:
```json
{
  "newEmail": "new.email@example.com"
}
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Verification code sent to your new email address.",
  "data": {
    "email": "new.email@example.com",
    "message": "Verification code sent to your new email address."
  }
}
```

---

### 3.2 Step 2: Verify & Confirm Email Change `[NEW]`
Verifies the OTP code sent to the new email address, ensures email uniqueness, updates `user.email`, and clears `pendingEmail`.

* **Endpoint:** `POST /api/v1/user/verify-email-change`
* **Access:** Authenticated (`Bearer <ACCESS_TOKEN>`)

#### Request:
```json
{
  "newEmail": "new.email@example.com",
  "otp": "481920"
}
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Email changed successfully.",
  "data": {
    "_id": "6a52ffb3fa91f21a312f5b23",
    "name": "John Doe",
    "email": "new.email@example.com",
    "role": "user"
  }
}
```

---

## 4. 👤 User Profile Management

### 4.1 Get My Profile `[UPDATED]`
Returns complete user profile, including the newly added schema fields.

* **Endpoint:** `GET /api/v1/user/get-my-profile`
* **Access:** Authenticated (`Bearer <ACCESS_TOKEN>`)

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "My profile retrieved successfully.",
  "data": {
    "_id": "6a52ffb3fa91f21a312f5b23",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user",
    "handicap": 12.4,
    "handicap_index": 12.4,
    "startingHandicap": 15.0,
    "uses_golfimprove_stand": true,
    "age_range": "25-34",
    "practice_sessions_per_week": "3",
    "isGuest": false,
    "profileUrl": "https://iter-bene.s3.eu-north-1.amazonaws.com/profile.png",
    "country": "United States",
    "gender": "male",
    "status": "active"
  }
}
```

---

### 4.2 Update My Profile `[UPDATED]`
Updates profile details. 

> **Important:** If `"email"` is provided in this payload, it is **silently ignored/stripped** to protect the account from unverified email takeovers.

* **Endpoint:** `PATCH /api/v1/user/update-my-profile`
* **Access:** Authenticated (`Bearer <ACCESS_TOKEN>`)
* **Content-Type:** `multipart/form-data` or `application/json`

#### Supported Payload Fields:
```json
{
  "name": "John Doe",
  "uses_golfimprove_stand": true,
  "handicap_index": 9.2,
  "age_range": "25-34",
  "practice_sessions_per_week": 4,
  "country": "United Kingdom",
  "gender": "male"
}
```

#### Uploading Profile Picture (`multipart/form-data`):
* Key: `profile` (File: image/jpeg, image/png, image/webp)

---

### 4.3 Soft Delete Account `[CURRENT]`
* **Endpoint:** `PATCH /api/v1/user/delete/my-account`
* **Access:** Authenticated (`Bearer <ACCESS_TOKEN>`)
Sets user status to `"deleted"`.

---

## 5. 👨‍🏫 Coach & Admin User Management `[CURRENT]`

* **Get Coach's Students:** `GET /api/v1/user/coach/students` (Lists students assigned to coach)
* **Get Single Student Stats:** `GET /api/v1/user/coach/students/:studentId` (Detailed sessions & scores)
* **Admin Get All Users:** `GET /api/v1/user/get-all?page=1&limit=10&searchTerm=...`
* **Admin Change User Status:** `PATCH /api/v1/user/change-status/:id` (`{ "status": "suspended" | "active" }`)
* **Admin Delete User:** `DELETE /api/v1/user/delete/:id`

---

## 6. 📊 Database Schema Summary (User Document)

```typescript
{
  _id: ObjectId,
  name: String,                              // Optional; defaults to email handle or "Golfer"
  email: String,                             // Unique, verified
  password: String,                          // Hashed with bcrypt
  role: "user" | "coach" | "admin",
  isGuest: Boolean,                          // [NEW] True if anonymous session
  uses_golfimprove_stand: Boolean,           // [NEW] True if golfer owns the stand
  age_range: String,                         // [NEW] Age bracket (e.g. "18-24", "25-34")
  handicap: Number,                          // Float: -9.9 to 54.0
  handicap_index: Number,                    // Float alias mirroring handicap
  startingHandicap: Number,                  // Baseline handicap
  practiceSessionPerWeek: String,            // Goal count string
  practice_sessions_per_week: Number|String, // [NEW] Goal count
  pendingEmail: String | null,               // [NEW] Stored during email change verification
  profileUrl: String,                        // AWS S3 profile picture URL
  country: String,
  gender: "male" | "female" | "other",       // Optional
  status: "pending" | "active" | "suspended" | "deleted",
  createdAt: Date,
  updatedAt: Date
}
```
