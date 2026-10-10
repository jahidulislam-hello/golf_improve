# GolfImprove — Agent Project Map

Flutter golf training app (`golf_training_app`). UI title: **GolfImprove**. Dual role: **Golfer** and **Coach (Pro)**.

Package: `com.example.golf_training_app` (Android) / `com.example.golfTrainingApp` (iOS). Dart SDK `^3.11.4`. Design frame: **393 × 852** via `flutter_screenutil`. Font: **Inter** (bundled).

## Current state

UI is largely complete with **hardcoded mock data**. Auth is fake (`Future.delayed` + field checks). `ApiService` + `ApiConstants` exist but are **not wired** to `AuthController`. Backend: `https://golf.ssh.bd/api/v1`.

Persona used across mocks: **Alex Thompson**, handicap **12.4**, **847 swings**, coach notes often mention **James Keller**.

## Stack

- Navigation: GetX named routes (`lib/helpers/routes.dart`)
- Auth/onboarding state: Provider `AuthController` (`ChangeNotifier`)
- Feature screens: mix of GetX `GetxController` and `ChangeNotifier`
- HTTP: `http` via `lib/services/api_services.dart` (unused by UI yet)
- Camera/video: `camera`, `video_player`, `permission_handler`

## App flow

```
Splash (5s) → Onboarding (4 pages) → Role Selection (golfer|coach) → Sign In
  Sign In success → AppRoutes.goToHomeForRole()
    coach  → CoachNavbar
    golfer → GolferNavbar
  Sign Up:
    coach  → CoachNavbar (skips profile setup)
    golfer → ProfileSetUpScreen ("Tell us about yourself") → GolferNavbar
  Forgot password (Navigator.push, not GetX):
    ForgotPasswordScreen → OtpVerificationScreen → ResetPasswordScreen → SignIn
```

`UserRole` lives in `lib/views/screens/onboarding/role_selection/role_selection_controller.dart`.

GetX registered pages only: splash, onboarding, role selection, sign-in, golfer/coach navbars, home. Other screens use `MaterialPageRoute` / `Get.to`.

## Navigation shells

**GolferNavbar** (5 tabs): Home → Library → Record (hides bottom bar) → Progress → Profile.

**CoachNavbar** (4 tabs): DashBoard → Students → Reviews → Profile.

## Folder map (`lib/`)

- `main.dart` — portrait lock, Provider + ScreenUtil + GetMaterialApp
- `controllers/auth_controller.dart` — all auth/onboarding form state
- `core/` — `AppColors`, `AppTextStyles`, `AppRadii`, `AppCaptureColors`; `app_icons.dart` / `app_images.dart` are **empty stubs** (use raw `assets/...` paths)
- `helpers/routes.dart` — GetX routes + `goToHomeForRole()`
- `services/api_services.dart` — GET/POST/PUT/PATCH/DELETE/multipart + token helpers
- `utils/api_constants.dart` — base URL + auth/profile endpoints
- `views/base/` — golfer + coach navbars
- `views/dummy/` — **ALWAYS SKIP.** Never read, import, edit, or copy from this folder.
- `views/screens/onboarding|auth|choose_plan|golfer|coach/`

No top-level `lib/models/` or `lib/widgets/`. Models and widgets are **colocated with the feature**.

## API layer (in progress)

`ApiConstants.baseUrl = 'https://golf.ssh.bd'`, `apiUrl = '$baseUrl/api/v1'`.

Auth: register, verify-otp, resend-otp, login, forgot-password, forgot-otp-verify, reset-password, change-password, refresh-token.

Profile: `/users/me`, `/users/update-me`, `/user/update-my-profile`, `/users/edit-options`.

`ApiService` expects SharedPreferences keys (`keyAccessToken`, `keyRefreshToken`, `keyUserData`, `keyIsLoggedIn`, expiry keys) that are **not yet defined** on `ApiConstants`.

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
- Choose Plan is opened from golfer profile via `MaterialPageRoute`, not GetX. Trial button is currently a no-op.
