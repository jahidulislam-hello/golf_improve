# GolfImprove — Agent Project Map

Flutter golf training app (`golf_training_app`). UI title: **GolfImprove**. Dual role: **Golfer** and **Coach (Pro)**.

Package: `com.golfimprove.app` (Android) / `eu.golfimprove` (iOS). Dart SDK `^3.11.4`. Design frame: **393 × 852** via `flutter_screenutil`. Font: **Inter** (bundled).

## Current state

UI is largely built. Auth, profile, home, progress, library, swing upload, coach reviews, plans, and promo redemption call the live API at `https://golf.ssh.bd/api/v1`. Some screens can still fall back to local copy. Google and Apple sign-in buttons are empty callbacks.

Persona used in leftover mocks: **Alex Thompson**, handicap **12.4**, **847 swings**, coach notes often mention **James Keller**.

## Stack

- Navigation: GetX named routes (`lib/helpers/routes.dart`)
- Auth/onboarding state: Provider `AuthController` (`ChangeNotifier`) → `AuthService`
- Feature data: `GolferService`, `CoachService`; offline clips in `OfflineSwingQueue`
- Feature screens: mix of GetX `GetxController` and `ChangeNotifier`
- HTTP: `http` via `lib/services/api_services.dart`; `DeviceHttpOverrides` in `main`
- Camera/video/pose: `camera`, `video_player`, `permission_handler`, `google_mlkit_pose_detection`

## App flow

```
Splash → restore session if token + role exist, else Onboarding (4 pages)
  → Role Selection (golfer|coach) → Sign In
  Sign In success → AppRoutes.goToHomeForRole()
    coach  → CoachNavbar
    golfer → GolferNavbar
  Continue as guest → POST /auth/guest-session → home for role
  Sign Up → OTP → profile setup → home
    golfer → ProfileSetUpScreen
    coach  → CoachProfileSetUpScreen
  Forgot password (Navigator.push, not GetX):
    ForgotPasswordScreen → OtpVerificationScreen → ResetPasswordScreen → SignIn
```

`UserRole` lives in `lib/views/screens/onboarding/role_selection/role_selection_controller.dart`.

GetX registered pages only: splash, onboarding, role selection, sign-in, golfer/coach navbars, home. Other screens use `MaterialPageRoute` / `Get.to`.

## Navigation shells

**GolferNavbar** (5 tabs): Home → Library → Record (hides bottom bar) → Progress → Profile.

**CoachNavbar** (4 tabs): DashBoard → Students → Reviews → Profile.

## Folder map (`lib/`)

- `main.dart` — portrait lock, `DeviceHttpOverrides`, Provider + ScreenUtil + GetMaterialApp
- `controllers/auth_controller.dart` — auth/onboarding form state; calls `AuthService`
- `core/` — `AppColors`, `AppTextStyles`, `AppRadii`, `AppCaptureColors`; `app_icons.dart` / `app_images.dart` are **empty stubs** (use raw `assets/...` paths)
- `helpers/routes.dart` — GetX routes + `goToHomeForRole()` + `handleSplashFinished()`
- `services/api_services.dart` — GET/POST/PUT/PATCH/DELETE/multipart, S3 `putFile`, token helpers
- `services/auth_service.dart` — register, OTP, login, reset, guest session, merge-guest, logout
- `services/golfer_service.dart` — profile, home, progress, library, swing upload/analyze, shares, plans, promo, GDPR export/delete
- `services/coach_service.dart` — coach home, students, received shares, respond, practice plan
- `services/offline_swing_queue.dart` — SharedPreferences queue (`keyOfflineSwings`)
- `utils/api_constants.dart` — base URL, endpoints, SharedPreferences keys
- `views/base/` — golfer + coach navbars
- `views/dummy/` — **ALWAYS SKIP.** Never read, import, edit, or copy from this folder.
- `views/screens/onboarding|auth|choose_plan|golfer|coach/`

No top-level `lib/models/` or `lib/widgets/`. Models and widgets are **colocated with the feature**.

## API layer

`ApiConstants.baseUrl = 'https://golf.ssh.bd'`, `apiUrl = '$baseUrl/api/v1'`.

Auth: guest-session, merge-guest, register, verify-otp, resend-otp, login, forgot-password, forgot-otp-verify, reset-password, change-password, refresh-token, logout.

Profile: `/user/get-my-profile`, `/user/update-my-profile`, email-change OTP, `/user/handicap`, `/user/download-my-data`, `/user/delete-account`.

Golfer: `/meta/user`, `/meta/my-progress`, swing library, camera categories, presigned upload (`/swing/upload-url` + `/swing/create`), `/swing/sync/offline`, `/swing/analyze/video/:id`, AI ask, share-swing, practice-session complete.

Coach: `/meta/coach`, `/user/coach/students`, share received/pending/view/respond, practice-plan edit.

Billing: `/plan/get-all`, `/promo-code/validate`, `/promo-code/redeem`, `/payment/paywall-status`. Paywall can be bypassed on the server (`ENABLE_PAYWALL=false`).

Token keys are defined on `ApiConstants` (`keyAccessToken`, `keyRefreshToken`, `keyUserData`, `keyIsLoggedIn`, expiry, `keyGuestId`, `keyOfflineSwings`).

Root markdown specs (backend, not this app’s source): `AUTH_AND_PROFILE_UPDATES.md`, `DEPRECATE_VIDEO_AI_AND_AI_COACH_DOCUMENTATION.md`, `COACH_AND_PRACTICE_PLAN_DOCUMENTATION.md`, `VIDEO_STORAGE_AND_OFFLINE_SYNC_DOCUMENTATION.md`, `PROGRESS_METRICS_AND_CONSISTENCY_DOCUMENTATION.md`, `SUBSCRIPTION_AND_PAYWALL_BYPASS_DOCUMENTATION.md`, `SECURITY_AND_GDPR_COMPLIANCE_DOCUMENTATION.md`, `SUBSCRIPTION_PROMO_AND_KLAVIYO_DOCUMENTATION.md`.

## Design tokens (use these; do not hardcode hex)

- Navy `#0A1628` (`AppColors.primaryNavy`), CTA blue `#2563EB`
- Text primary `#1E293B`, secondary `#64748B`, off-white bg `#F4F6F9`
- Cards radius 20, buttons 16 (`AppRadii`)
- Typography: `AppTextStyles.screenTitle` / `sectionHeader` / `body` / `caption` / `statNumber`

## Conventions for future work

- Match existing file placement (feature-local controllers, models, widgets).
- Prefer `AppColors` / `AppTextStyles` / `AppRadii` / `.w/.h/.sp` over raw sizes and hex.
- Always skip `lib/views/dummy/`. Never read, import, edit, or copy from it.
- Duplicate class names exist (`ReviewSwingScreen`, `ShareWithCoachScreen`, `SwingAnalysisScreen`, `StatCard`) — import the **feature-specific** path.
- Native CAMERA / MIC / location permission strings are **not** in AndroidManifest / Info.plist yet; Dart already calls `permission_handler`.
- Choose Plan is opened from golfer profile via `MaterialPageRoute`, not GetX. `ChoosePlanController` loads live plans and redeems promo codes. Stripe / store purchase is not in this controller.
