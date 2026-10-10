# GolfImprove — Golf Training App 🏌️

A Flutter mobile application for golf swing training and coaching. Golfers record their swings, get AI-powered analysis, track progress, and share videos with coaches. Coaches review submitted swings, give feedback, and manage their students — all in one app with two role-based experiences.

---

## Table of Contents

- [Overview](#overview)
- [Features (A–Z)](#features-a-z)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [App Flow](#app-flow)
- [Design System](#design-system)
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)

---

## Overview

**GolfImprove** is a dual-role app:

| Role | What they do |
|------|--------------|
| 🏌️ **Golfer** | Record swings with the camera, get AI analysis, browse their video library, track progress/handicap, share swings with a coach, chat with an AI golf coach |
| 🎓 **Coach (Pro)** | View a dashboard of pending reviews, watch student swing videos, agree/disagree with AI analysis, write feedback & practice plans, manage students |

The role is chosen once at onboarding and drives which navigation shell (Golfer or Coach navbar) the user lands in after sign-in.

---

## Features (A–Z)

- **A — AI Golf Coach** · Chat-style AI assistant for golfers (`golfer/library/screens/ai_golf_coach_screen.dart`)
- **A — Analysing Screen** · Animated processing screen shown while a recorded swing is analysed
- **A — Authentication** · Sign In, Sign Up, Forgot Password, OTP Verification, Reset Password (`views/screens/auth/`)
- **C — Camera Capture** · Live camera preview + swing recording with overlays (`camera` package, permission handling)
- **C — Coach Dashboard** · Pro dashboard with stat cards, pending review cards, and recent activity feed
- **C — Coach Feedback** · Golfers view feedback sent back from their coach
- **C — Compare Swings** · Side-by-side video comparison with playback speed pills
- **G — Golf Logbook** · Log of rounds/sessions for the golfer
- **G — Golf Stand Activation** · Activate a physical golf stand via activation code or QR scan
- **H — Handicap Tracking** · Handicap progress card + update dialog on the Progress screen
- **H — Home Dashboard (Golfer)** · Hero carousel, quick actions, active session card, coach feedback card, recent activity
- **L — Library (Swing Library)** · Grid/list of all recorded swings with video previews
- **N — Notifications** · Notification screen for the golfer
- **O — Onboarding** · Splash → multi-page onboarding cards → role selection (Golfer / Coach)
- **P — Personal Info** · Editable profile fields (name, age range, gender pills, etc.)
- **P — Practice Plans** · Coaches build day-by-day practice plans in the review flow
- **P — Profile & Settings** · Profile screens for both roles: About Us, Privacy Policy, Terms & Conditions, Help & Support, Community/Legal
- **P — Progress Screen** · Weekly swing charts, streak card, mini stats, trend arrows, line/area chart
- **R — Review Swing (Coach)** · Full review flow: video analysis, AI analysis card, AI agreement (agree/disagree), session notes, feedback tabs, send feedback
- **R — Review Swing (Golfer)** · Review own recorded clip with scrubbing, fullscreen playback
- **R — Reviews Screen (Coach)** · Pending / Completed review sections with pill counters
- **S — Session Timeline** · Journey timeline of sessions with video previews and coach feedback
- **S — Share With Coach** · Golfer shares a swing to a coach with toggles/options
- **S — Students Management** · Coach's student list + student detail screens
- **S — Swing Analysis** · AI-generated swing insights for the golfer
- **S — Swing Tips** · Add swing tips with club-type pills and media

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter (Dart SDK ^3.11.4) |
| State management | `provider` (auth flow) + `get` / GetX (navigation & controllers) |
| Routing | GetX named routes (`lib/helpers/routes.dart`) |
| Responsive UI | `flutter_screenutil` (design size 393 × 852) |
| Camera / Video | `camera`, `video_player`, `permission_handler` |
| Font | **Inter** (bundled in `assets/fonts/`, weights 400–900 + italics) |
| Design | Material 3, custom color & text-style tokens in `lib/core/` |

---

## Project Structure

```
lib/
├── main.dart                     # App entry — ScreenUtil + GetMaterialApp + Inter theme
├── controllers/
│   └── auth_controller.dart      # Single ChangeNotifier for the whole auth/onboarding flow
├── core/                         # Design tokens
│   ├── app_colors.dart           #   Color palette
│   ├── app_capture_colors.dart   #   Camera/capture-specific colors
│   ├── app_styles.dart           #   AppTextStyles — full Inter typography system
│   ├── app_radii.dart            #   Corner radii
│   ├── app_icons.dart            #   Icon asset paths
│   └── app_images.dart           #   Image asset paths
├── helpers/
│   └── routes.dart               # AppRoutes — GetX route names + pages + role-based redirect
└── views/
    ├── base/
    │   ├── golfer_navbar/        # Golfer bottom navigation shell
    │   └── coach_navbar/         # Coach bottom navigation shell
    ├── dummy/                    # Prototype/scratch screens (kept for reference)
    └── screens/
        ├── onboarding/           # Splash, onboarding pages, role selection
        ├── auth/                 # Sign in/up, OTP, forgot/reset password + shared widgets
        ├── choose_plan/          # Subscription plan selection
        ├── golfer/
        │   ├── home/             # Dashboard, swing analysis, compare swings, logbook,
        │   │                     #   session timeline, add swing tip, share with coach
        │   ├── record/           # Camera capture → review swing → analysing flow
        │   ├── library/          # Swing library, AI coach chat, review/share screens
        │   ├── progress/         # Charts, streaks, handicap tracking
        │   └── profile/          # Profile, personal info, golf stand, settings pages
        └── coach/
            ├── dashboard/        # Pro dashboard, stats, review-swing feedback flow
            ├── reviewers/        # Pending/completed reviews list + review screen
            ├── students/         # Student list & detail
            └── profile/          # Coach profile & info screens

assets/
├── fonts/                        # Inter TTFs (Regular → Black + italics)
├── icons/                        # Navbar & UI icons (active/inactive states)
└── images/                       # Logo, splash, onboarding art, settings art
```

---

## App Flow

```
Splash ──▶ Onboarding (4 pages) ──▶ Role Selection ──▶ Sign In
                                        │
                            ┌───────────┴───────────┐
                            ▼                       ▼
                      Golfer Navbar            Coach Navbar
                   ┌────┬─────┬────┬────┐   ┌─────┬─────┬────┬────┐
                   Home Record Libr Prog…   Dash  Reviews Students Profile
```

`AppRoutes.goToHomeForRole()` reads the selected role from `AuthController` and routes to the correct navbar shell after authentication.

---

## Design System

- **Font:** Inter everywhere — set globally via `ThemeData(fontFamily: 'Inter')` and in every `AppTextStyles` token.
- **Typography tokens** (`lib/core/app_styles.dart`): `screenTitle` (32/38 ExtraBold), `sectionHeader` (22/28 SemiBold), `body` (16/22 Regular), `caption` (13/18), `statNumber` (40/44 Bold), plus a full 8–32 pt type ramp and per-feature styles (buttons, inputs, pills, eyebrows, list items…).
- **Colors** (`lib/core/app_colors.dart`): centralized palette — text primary/secondary, CTA blue, destructive red, surfaces, etc.
- **Responsive:** all sizes go through `flutter_screenutil` against a 393 × 852 design frame.

---

## Getting Started

### Prerequisites

- Flutter SDK (Dart ^3.11.4)
- Android Studio / Xcode for device tooling

### Run

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on a connected device or emulator
flutter run
```

> **Note:** Camera features require a real device (or an emulator with camera support) and will prompt for CAMERA / MICROPHONE permissions at runtime.

### Build

```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS (on macOS)
```

---

## Dependencies

Key packages (see `pubspec.yaml` for the full list):

| Package | Purpose |
|---------|---------|
| `get` | Navigation, routing, controllers |
| `provider` | Auth flow state (`AuthController`) |
| `flutter_screenutil` | Responsive sizing |
| `camera` / `video_player` | Swing recording & playback |
| `permission_handler` | Runtime camera/mic permissions |
| `flutter_svg`, `cached_network_image`, `shimmer` | UI & media |
| `pin_code_fields` | OTP input |
| `image_picker` | Media selection |
| `table_calendar`, `syncfusion_flutter_calendar` | Calendar views |
| `google_maps_flutter`, `geolocator`, `geocoding` | Maps & location |
| `shared_preferences` | Local persistence |
| `http` | Networking |

---

*Built with Flutter 💙*
