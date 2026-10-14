# 6. Subscription, Paywall & Feature Flag Bypass Documentation

> **Status:** ✅ Fully Implemented, Tested & Production Ready  
> **Target Service:** `golf-improve-server`  
> **Relevant Models & Files:**  
> - Configuration: [`src/config/index.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/config/index.ts), [`.env`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/.env)  
> - Middleware: [`src/middlewares/paywall.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/middlewares/paywall.ts)  
> - User Service & Profile: [`src/models/user/user.service.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/user/user.service.ts)  
> - Payment Service & Controller: [`src/models/payment/payment.service.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/payment/payment.service.ts), [`src/models/payment/payment.controller.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/payment/payment.controller.ts), [`src/models/payment/payment.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/payment/payment.route.ts)  
> - Premium Routes Protected:  
>   - [`src/models/swing/swing.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing/swing.route.ts)  
>   - [`src/models/swing-library/swing.library.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing-library/swing.library.route.ts)  
>   - [`src/models/share-swing/share.swing.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/share-swing/share.swing.route.ts)

---

## 1. Overview & Architectural Requirements

During initial product rollout, beta testing, and marketing acquisition campaigns, the client required all golfers—including guest sessions and free tier users—to enjoy **unrestricted free access to all platform features** (AI swing analysis, AI Golf Coach queries, video uploads, and coach sharing) without deleting or refactoring the underlying Stripe and In-App Purchase infrastructure.

### Architectural Solution
1. **Feature Flag (`ENABLE_PAYWALL`):**  
   Configured in `.env` and typed in `src/config/index.ts`:
   - `ENABLE_PAYWALL=false`: The paywall barrier is completely disabled. Every user is granted full access without paywall friction.
   - `ENABLE_PAYWALL=true`: The paywall barrier is instantly re-armed across all premium routes, enforcing active paid subscriptions.
2. **Dynamic Paywall Middleware (`checkPaywall`):**  
   Evaluates the `ENABLE_PAYWALL` feature flag. When bypassed, calls `next()` immediately without database lookups. When enabled, verifies `user.subscription.status === 'active'` and `endDate > new Date()`, blocking unsubscribed users with `402 Payment Required`.
3. **Paywall Status API & Profile Flags:**  
   Informs the mobile app and web clients of the current paywall state via `GET /api/v1/payment/paywall-status` and `GET /api/v1/user/get-my-profile` (`hasPremiumAccess: true`, `paywall.bypassActive: true`), preventing client-side in-app purchase sheets from popping up unnecessarily.

---

## 2. Environment Configuration

### `.env`
```dotenv
# Feature Flags
ENABLE_PAYWALL=false
```

### `src/config/index.ts`
```typescript
const envSchema = z.object({
  // ... other configs
  ENABLE_PAYWALL: z
    .string()
    .transform((val) => val === "true")
    .optional()
    .default("false" as any),
});

export const {
  // ... other exports
  ENABLE_PAYWALL,
} = envData;
```

---

## 3. Middleware Architecture (`src/middlewares/paywall.ts`)

```typescript
import { Request, Response, NextFunction } from "express";
import { StatusCodes } from "http-status-codes";
import AppError from "../errors/appError";
import { ENABLE_PAYWALL } from "../config";
import { User } from "../models/user/user.model";
import { JwtUserPayload } from "./auth";

export const isPaywallActive = (): boolean => {
  if (process.env.ENABLE_PAYWALL !== undefined) {
    return process.env.ENABLE_PAYWALL === "true";
  }
  return ENABLE_PAYWALL === true;
};

export const checkPaywall = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  // 1. Feature Flag Bypass Check:
  if (!isPaywallActive()) {
    return next();
  }

  // 2. Paywall Enabled: Verify user authentication
  const userPayload = req.user as JwtUserPayload | undefined;
  if (!userPayload?.id) {
    throw new AppError(StatusCodes.UNAUTHORIZED, "Authentication required");
  }

  // Admins always bypass paywall
  if (userPayload.role === "admin") {
    return next();
  }

  // 3. Verify user's subscription status in database
  const user = await User.findById(userPayload.id)
    .select("subscription")
    .lean();

  if (!user) {
    throw new AppError(StatusCodes.NOT_FOUND, "User not found");
  }

  const sub = user.subscription;
  const isSubscriptionActive =
    sub &&
    sub.status === "active" &&
    new Date(sub.endDate) > new Date();

  if (!isSubscriptionActive) {
    return res.status(StatusCodes.PAYMENT_REQUIRED).json({
      statusCode: StatusCodes.PAYMENT_REQUIRED,
      success: false,
      message: "An active subscription is required to access this premium feature.",
      error: "SUBSCRIPTION_REQUIRED",
      paywall: {
        isLocked: true,
        plansUrl: "/api/v1/plan/get-all",
        upgradeRequired: true,
      },
    });
  }

  next();
};
```

---

## 4. Protected Premium Routes

The `checkPaywall` middleware is mounted directly on all core monetization features:

| Endpoint | Method | Feature Description |
| :--- | :--- | :--- |
| `/api/v1/swing/analyze/video/:id` | `POST` | AI Biomechanical & Kinematic Swing Analysis |
| `/api/v1/swing-library/ask/:id` | `POST` | AI Golf Coach Contextual Diagnosis |
| `/api/v1/swing-library/ask-coach/:id` | `POST` | AI Golf Coach Contextual Diagnosis (Alias) |
| `/api/v1/share-swing/create` | `POST` | Submit Swing Video to Pro Coach for Review |

When `ENABLE_PAYWALL=false`, all four routes execute without requiring subscription payments.

---

## 5. API Endpoints

### 5.1 Paywall Status (`GET /api/v1/payment/paywall-status`)
Allows the frontend to discover if premium features are unlocked globally or behind a paywall.

- **Endpoints:**
  - `GET /api/v1/payment/paywall-status`
  - `GET /api/v1/payment/paywall`
- **Auth:** Optional (`auth` not required; accepts Bearer token if available)
- **Response when `ENABLE_PAYWALL=false` (200 OK):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Paywall status retrieved successfully.",
  "data": {
    "isPaywallEnabled": false,
    "bypassActive": true,
    "hasPremiumAccess": true,
    "status": "bypassed_free_access",
    "subscription": null
  }
}
```

- **Response when `ENABLE_PAYWALL=true` (for active subscriber) (200 OK):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Paywall status retrieved successfully.",
  "data": {
    "isPaywallEnabled": true,
    "bypassActive": false,
    "hasPremiumAccess": true,
    "status": "subscribed",
    "subscription": {
      "planName": "Pro Yearly",
      "status": "active",
      "startDate": "2026-10-01T00:00:00.000Z",
      "endDate": "2027-10-01T00:00:00.000Z"
    }
  }
}
```

---

### 5.2 User Profile Integration (`GET /api/v1/user/get-my-profile`)
The profile response automatically contains paywall metadata:

```json
{
  "statusCode": 200,
  "success": true,
  "message": "My profile retrieved successfully.",
  "data": {
    "_id": "6acb4...",
    "name": "Golfer User",
    "email": "golfer@example.com",
    "role": "user",
    "hasPremiumAccess": true,
    "paywall": {
      "isPaywallEnabled": false,
      "bypassActive": true,
      "hasPremiumAccess": true
    }
  }
}
```

---

## 6. Verification & Live Testing Summary

- **Bypass Verification (`ENABLE_PAYWALL=false`):**
  - Free, unsubscribed users successfully bypass `checkPaywall` middleware (`next()` invoked).
  - `PaymentService.getPaywallStatus` returned `isPaywallEnabled: false, bypassActive: true, hasPremiumAccess: true`.
  - `UserService.getMyProfile` confirmed `hasPremiumAccess: true`.
- **Enforcement Verification (`ENABLE_PAYWALL=true`):**
  - Unsubscribed users were blocked with HTTP `402 Payment Required` and structured paywall metadata.
  - Active subscribed users passed through with `next()`.
  - Admins bypassed paywall checks automatically.
- **TypeScript Integrity:** Compiled with `npx tsc --noEmit` across both `golf-improve-server` and `golf-improve-dashboard` with **0 errors**.
