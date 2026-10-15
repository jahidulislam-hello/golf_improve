# 6. Subscription, Paywall & Feature Flag Bypass Documentation

> **Status:** ✅ Fully Implemented, Tested & Production Ready  
> **Target Service:** `golf-improve-server`  
> **Relevant Models & Files:**  
> - Configuration: [`src/config/index.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/config/index.ts), [`.env`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/.env)  
> - Middleware: [`src/middlewares/paywall.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/middlewares/paywall.ts)  
> - User Service & Profile: [`src/models/user/user.service.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/user/user.service.ts)  
> - Payment Service & Controller: [`src/models/payment/payment.service.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/payment/payment.service.ts), [`src/models/payment/payment.controller.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/payment/payment.controller.ts), [`src/models/payment/payment.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/payment/payment.route.ts)  
> - Plan Service & Route: [`src/models/plan/plan.service.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/plan/plan.service.ts), [`src/models/plan/plan.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/plan/plan.route.ts)  
> - Premium Routes Protected:  
>   - [`src/models/swing/swing.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing/swing.route.ts)  
>   - [`src/models/swing-library/swing.library.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/swing-library/swing.library.route.ts)  
>   - [`src/models/share-swing/share.swing.route.ts`](file:///c:/Sushil%20Hemrom/golf-improve/golf-improve-server/src/models/share-swing/share.swing.route.ts)

---

## 1. Overview & Architectural Requirements

To support flexible rollout strategies, marketing acquisition campaigns, and hardware customer benefits, the platform provides a hybrid access model:

1. **Feature Flag (`ENABLE_PAYWALL`):**  
   Configured in `.env` and typed in `src/config/index.ts`:
   - `ENABLE_PAYWALL=false`: The paywall barrier is completely disabled globally. Every golfer is granted unrestricted free access.
   - `ENABLE_PAYWALL=true`: The paywall barrier is active, enforcing paid subscriptions or valid bypass conditions.
2. **Hardware Owner Bypass (`usesGolfImproveStand`):**  
   Golfers who own the physical GolfImprove Stand (`usesGolfImproveStand: true` / `uses_golfimprove_stand: true`) receive **complimentary lifetime free access** to all premium features, bypassing paywall restrictions automatically even when `ENABLE_PAYWALL=true`.
3. **Core Subscription Tier (€14.99/mo with 3-Day Free Trial):**  
   - Dedicated endpoint `GET /api/v1/plan/launch-plan` returns the primary launch subscription tier.
   - Initial subscriptions and in-app purchase trials receive 3 days free trial period before recurring billing.
4. **Dynamic Paywall Middleware (`checkPaywall`):**  
   Evaluates access in priority order:
   - If `!isPaywallActive()`: `next()`
   - If `role === 'admin'`: `next()`
   - If `user.usesGolfImproveStand`: `next()`
   - If `user.subscription.status === 'active' && endDate > now`: `next()`
   - Else: HTTP `402 Payment Required`

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
  ENABLE_PAYWALL,
} = envData;
```

---

## 3. Middleware Architecture (`src/middlewares/paywall.ts`)

```typescript
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

  // 3. Verify user's subscription and stand owner status in database
  const user = await User.findById(userPayload.id)
    .select("subscription usesGolfImproveStand uses_golfimprove_stand")
    .lean();

  if (!user) {
    throw new AppError(StatusCodes.NOT_FOUND, "User not found");
  }

  // Stand users receive complimentary free premium access
  if (user.usesGolfImproveStand || (user as any).uses_golfimprove_stand) {
    return next();
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

The `checkPaywall` middleware protects all core premium features:

| Endpoint | Method | Feature Description |
| :--- | :--- | :--- |
| `/api/v1/swing/analyze/video/:id` | `POST` | AI Biomechanical & Kinematic Swing Analysis |
| `/api/v1/swing-library/ask/:id` | `POST` | AI Golf Coach Contextual Diagnosis |
| `/api/v1/swing-library/ask-coach/:id` | `POST` | AI Golf Coach Contextual Diagnosis (Alias) |
| `/api/v1/share-swing/create` | `POST` | Submit Swing Video to Pro Coach for Review |

---

## 5. Backend API Endpoints Reference

### 5.1 Paywall Status Discovery (`GET /api/v1/payment/paywall-status`)

Determines current access level, paywall state, and subscription details.

- **Endpoint:** `GET /api/v1/payment/paywall-status` (Alias: `GET /api/v1/payment/paywall`)
- **Auth:** Optional (`Bearer <ACCESS_TOKEN>` if authenticated)
- **Headers:** `Content-Type: application/json`

#### cURL Request:
```bash
curl -X GET "http://localhost:9090/api/v1/payment/paywall-status" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

#### Response Scenarios:

##### A. Paywall Globally Disabled (`ENABLE_PAYWALL=false`)
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Paywall status retrieved successfully.",
  "data": {
    "isPaywallEnabled": false,
    "bypassActive": true,
    "hasPremiumAccess": true,
    "isStandUser": false,
    "isInTrial": false,
    "status": "bypassed_free_access",
    "subscription": null
  }
}
```

##### B. Stand Owner Bypass (`usesGolfImproveStand: true`, even if paywall enabled)
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Paywall status retrieved successfully.",
  "data": {
    "isPaywallEnabled": true,
    "bypassActive": true,
    "hasPremiumAccess": true,
    "isStandUser": true,
    "isInTrial": false,
    "status": "stand_user_free_access",
    "subscription": null
  }
}
```

##### C. Active 3-Day Free Trial User
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Paywall status retrieved successfully.",
  "data": {
    "isPaywallEnabled": true,
    "bypassActive": false,
    "hasPremiumAccess": true,
    "isStandUser": false,
    "isInTrial": true,
    "status": "trial_active",
    "subscription": {
      "planName": "Pro Monthly",
      "status": "active",
      "isInTrial": true,
      "trialEndsAt": "2026-10-18T10:00:00.000Z",
      "startDate": "2026-10-15T10:00:00.000Z",
      "endDate": "2026-10-18T10:00:00.000Z"
    }
  }
}
```

##### D. Active Paid Subscriber
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Paywall status retrieved successfully.",
  "data": {
    "isPaywallEnabled": true,
    "bypassActive": false,
    "hasPremiumAccess": true,
    "isStandUser": false,
    "isInTrial": false,
    "status": "subscribed",
    "subscription": {
      "planName": "Pro Monthly",
      "status": "active",
      "startDate": "2026-10-15T10:00:00.000Z",
      "endDate": "2026-11-15T10:00:00.000Z"
    }
  }
}
```

##### E. Unsubscribed / Paywalled User (`402 Payment Required` on premium routes)
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Paywall status retrieved successfully.",
  "data": {
    "isPaywallEnabled": true,
    "bypassActive": false,
    "hasPremiumAccess": false,
    "isStandUser": false,
    "isInTrial": false,
    "status": "unsubscribed",
    "subscription": null
  }
}
```

---

### 5.2 Launch Subscription Plan Discovery (`GET /api/v1/plan/launch-plan`)

Returns the primary pre-configured €14.99/mo subscription tier with 3-day free trial.

- **Method:** `GET`
- **Endpoint:** `/api/v1/plan/launch-plan`
- **Auth Required:** No

#### cURL Request:
```bash
curl -X GET "http://localhost:9090/api/v1/plan/launch-plan"
```

#### Success Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Launch plan retrieved successfully.",
  "data": {
    "_id": "6acb22f08769b793d62e9015",
    "name": "Pro Monthly",
    "planType": "pro",
    "price": 14.99,
    "currency": "EUR",
    "billingInterval": "monthly",
    "trialDays": 3,
    "hasTrial": true,
    "trialOfferText": "3-Day Free Trial",
    "features": [
      { "label": "3-Day Free Trial Included", "included": true },
      { "label": "AI Golf Coach Dynamic Swing Feedback", "included": true },
      { "label": "Unlimited Swing Video Uploads & Storage", "included": true },
      { "label": "Personalized Drills & Practice Plans", "included": true },
      { "label": "Weekly Consistency & Handicap Progress", "included": true }
    ]
  }
}
```

---

### 5.3 User Profile Paywall Metadata (`GET /api/v1/user/get-my-profile`)

User profile automatically includes `paywall` and `hasPremiumAccess`:

```bash
curl -X GET "http://localhost:9090/api/v1/user/get-my-profile" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

#### Response (`200 OK`):
```json
{
  "statusCode": 200,
  "success": true,
  "message": "My profile retrieved successfully.",
  "data": {
    "_id": "6acb4...",
    "name": "Alex Golfer",
    "email": "golfer@example.com",
    "role": "user",
    "usesGolfImproveStand": true,
    "uses_golfimprove_stand": true,
    "hasPremiumAccess": true,
    "paywall": {
      "isPaywallEnabled": false,
      "bypassActive": true,
      "hasPremiumAccess": true,
      "isStandUser": true
    }
  }
}
```

---

## 6. Verification & Production Checklist

- [x] **Global Feature Flag:** When `ENABLE_PAYWALL=false`, all premium endpoints execute freely without paywall intercepts.
- [x] **Stand Owner Bypass:** Golfers with `usesGolfImproveStand: true` automatically bypass paywall checks in both `checkPaywall` middleware and `getPaywallStatus`.
- [x] **3-Day Free Trial:** Correctly reflected in `isInTrial: true` and `status: "trial_active"`.
- [x] **No Mobile Client Code:** 100% backend API specifications with cURL snippets and JSON responses.
- [x] **TypeScript Validation:** Compiles cleanly with zero errors (`npx tsc --noEmit`).
