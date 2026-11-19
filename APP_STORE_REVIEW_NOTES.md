# App Store Connect — App Review Information Notes

Paste the **Reviewer Notes** block below into App Store Connect → App Review Information → Notes, then attach the screen recording and resubmit.

Replace every `REPLACE_*` value before submitting.

Also fill the dedicated App Review Information fields:

| Field | Value |
| --- | --- |
| Sign-in required | Yes |
| Demo Golfer username | `REPLACE_GOLFER_EMAIL` |
| Demo Golfer password | `REPLACE_GOLFER_PASSWORD` |
| Contact email / phone | Your real review contact |

---

## Reviewer Notes (copy from here)

```
APP NAME: GolfImprove
iOS BUNDLE ID (submitted binary): com.limitit.digitalbalance
Android applicationId: com.golfimprove.app
BACKEND: https://api.golfimprove.eu/api/v1

============================================================
1) SCREEN RECORDING
============================================================
A screen recording captured on a physical iPhone running the latest iOS is attached / linked here:

Recording URL (if not attached in ASC): REPLACE_SCREEN_RECORDING_URL

The recording shows:
- Cold launch → onboarding (if first launch) → role selection
- Account registration (email + OTP) OR sign-in with the demo accounts below
- Golfer main flow: Home → Record a swing → analysis → Library → Progress → Profile
- Share swing with coach (private 1:1 content)
- Subscription / Choose Plan screen (trial / promo access)
- Account deletion: Profile → Privacy & Legal / Community & Legal → Delete Account
- Coach account flow with the coach demo credentials (Dashboard → Reviews → Students → Profile → Community & Legal → Delete Account path is demonstrated on a disposable account, not the shared demo account)

============================================================
2) PURPOSE & TARGET AUDIENCE
============================================================
GolfImprove helps golfers improve their swing and coaches manage students remotely.

Problem: Amateur and club golfers lack affordable, structured swing feedback between lessons. Coaches lack a single place to review student videos, leave notes, and assign practice plans.

Value:
- Golfers record swings on-device, receive AI swing insights, track handicap/progress, chat with an AI golf coach, and share clips privately with their coach.
- Coaches review pending shares, agree/disagree with AI findings, write feedback, and create practice plans.

Target audience: Amateur golfers, golf students, and teaching professionals / coaches. Ages 17+. Not a medical device and not a regulated financial product.

============================================================
3) SETUP / HOW TO ACCESS MAIN FEATURES
============================================================
DEMO ACCOUNTS (please use these; do not delete them):

A) Golfer
   Email:    REPLACE_GOLFER_EMAIL
   Password: REPLACE_GOLFER_PASSWORD
   Role:     Select “Golfer” on role selection if prompted.

B) Coach (Pro)
   Email:    REPLACE_COACH_EMAIL
   Password: REPLACE_COACH_PASSWORD
   Role:     Select “Coach” / Pro on role selection if prompted.

Guest access: “Continue as guest” creates a temporary guest session without email/password.

Suggested review path (Golfer):
1. Launch app → choose Golfer → Sign In with demo golfer credentials.
2. Home: browse dashboard / recent activity.
3. Record tab: allow Camera + Microphone → record a short practice swing (or use an existing library clip if device conditions require).
4. Library: open a swing → view AI analysis / AI Golf Coach chat.
5. Progress: view charts / handicap.
6. Profile → Subscription: view plans, start free trial or redeem promo code REPLACE_PROMO_CODE (optional).
7. Share with Coach: from a swing detail / share flow, share to the demo coach account.
8. Account deletion path (please use a NEW disposable account you create, not the shared demo):
   Profile → Privacy & Legal (Golfer) or Community & Legal (Coach) → Delete Account → enter password (or type DELETE for Google/Apple accounts).

Suggested review path (Coach):
1. Sign out → choose Coach → Sign In with demo coach credentials.
2. Dashboard / Reviews: open a pending shared swing → watch video → leave feedback / practice plan.
3. Students: open student list / detail.
4. Profile → Community & Legal shows Privacy, Download my data, and Delete Account.

No sample media files are required; the camera and existing demo swings on the accounts are sufficient. Camera and microphone permission prompts are expected for Record.

============================================================
4) EXTERNAL SERVICES / PLATFORMS
============================================================
- GolfImprove backend API: https://golf.ssh.bd (auth, profiles, swings, shares, plans)
- AWS S3: swing video / thumbnail storage via presigned upload URLs
- Google Gemini AI (server-side): swing analysis and AI Golf Coach responses
- Google ML Kit Pose Detection (on-device): pose overlay during capture
- Firebase Cloud Messaging: push notifications
- Google Sign-In / Sign in with Apple: social authentication
- Klaviyo (server-side): marketing / subscription lifecycle events
- Promo-code / trial activation via our backend (Choose Plan). Apple In-App Purchase receipt verification endpoint exists for store purchases when IAP products are used.

============================================================
5) REGIONAL DIFFERENCES
============================================================
The app functions consistently across all regions. There are no region-locked features or region-specific content catalogs. Language and currency display follow the plan data returned by the API; core golf training features are the same worldwide.

============================================================
6) REGULATED INDUSTRY / PROTECTED MATERIAL
============================================================
GolfImprove is a consumer sports training / coaching app. It is not a medical device, does not provide clinical diagnosis, and does not operate in a highly regulated industry requiring special licenses. We do not redistribute protected third-party broadcast / league content. User swing videos are private user content shared only with a selected coach account.

USER-GENERATED CONTENT NOTE:
Content is limited to private golfer↔coach swing shares and coaching notes (not a public social feed or open comments). Users can remove their own content and permanently delete their account (and associated data) from Profile → Privacy & Legal / Community & Legal → Delete Account. Support contact is available under Help & Support. Public content reporting / blocking is not applicable because there is no public UGC feed; inappropriate coach/golfer contact is handled by ending the coaching relationship and/or deleting the account, and via support email.

PAID FEATURES NOTE FOR REVIEW:
During this review build, premium golf features (additional swing recordings beyond the free allowance, AI Golf Coach, etc.) can be accessed with the demo accounts and/or by starting the free trial / redeeming promo code REPLACE_PROMO_CODE from Profile → Subscription. If paywall bypass is enabled server-side for launch, demo accounts already have full access.

Please contact us at REPLACE_SUPPORT_EMAIL if anything blocks testing.
```

---

## Screen recording checklist (physical device)

Record on a real iPhone with the latest iOS. Start from a killed app (cold launch).

1. Launch → onboarding (skip quickly if already seen) → role Golfer → Sign In  
2. Home tour (few seconds)  
3. Record a short swing (grant Camera/Mic) → review / analysis  
4. Library → open swing → AI insights / AI coach (brief)  
5. Progress tab  
6. Profile → Subscription / Choose Plan (show trial or promo)  
7. Share with Coach (if a coach is linked on the demo account)  
8. Create a **throwaway** account (or use a second test user) → Profile → Privacy & Legal → Delete Account  
9. Sign in as Coach → Dashboard/Reviews → open shared swing → leave short feedback  
10. Coach Profile → Community & Legal (show Delete Account exists; do **not** delete the shared demo coach)

Upload the video to a private unlisted link (YouTube/Drive/Dropbox) if App Store Connect attachment size is limited, and paste the URL in section 1.

---

## Before you resubmit (QA)

- [ ] Demo golfer + coach credentials work on the **exact binary** you submit  
- [ ] Account deletion works for email/password users (Golfer and Coach)  
- [ ] Screenshots show real in-app UI (not splash/login-only)  
- [ ] If you sell digital subscriptions on iOS, IAP products are created in App Store Connect and submitted with the app (Guideline 3.1.1)  
- [ ] Help & Support shows a real support email (not a placeholder)  
- [ ] Privacy Policy & Terms are real legal copy (not lorem ipsum) and match the App Store privacy URL  
- [ ] Release push: `aps-environment` is `production` for App Store / TestFlight production builds (currently `development` in `Runner.entitlements`)  
- [ ] Confirm ASC app record matches iOS bundle `com.limitit.digitalbalance` (Android is `com.golfimprove.app`)  
- [ ] TestFlight install on a physical device has been smoke-tested end-to-end  
- [ ] Notes field contains the block above with all `REPLACE_*` filled  
- [ ] Screen recording attached or linked  
