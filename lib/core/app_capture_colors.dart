import 'package:flutter/material.dart';

/// Extra tints needed for the Camera Capture / Review Swing / Analysing
/// screens. Sampled directly from the provided mocks — kept in their own
/// file rather than editing `AppColors`, so the original Figma-bound file
/// stays untouched.
class AppCaptureColors {
  AppCaptureColors._();

  // ---- Capture screen (dark camera UI) ----

  /// Translucent black pill background (timer chip, mode-tab bar, icon
  /// buttons) sitting on top of the live camera feed.
  static const Color scrimPillBg = Color(0x99000000);

  /// Selected segment inside the Face On / Down the Line / Side On tab bar.
  static const Color modeTabSelectedBg = Color(0xFFFFFFFF);
  static const Color modeTabSelectedText = Color(0xFF0A1628);
  static const Color modeTabUnselectedText = Color(0xFFE2E8F0);

  /// Dashed alignment-guide lines/box shown before a body is detected.
  static const Color guideDashed = Color(0xFF8A93A6);
  static const Color guideGridLine = Color(0x33FFFFFF);

  /// Green "AUTO DETECT · READY" state — pill, frame corners, dot.
  static const Color autoDetectGreen = Color(0xFF22C55E);
  static const Color autoDetectPillBg = Color(0xFF16A34A);

  /// Skeleton overlay drawn once a swing is detected.
  static const Color skeletonLine = Color(0xFFD9F99D);
  static const Color skeletonJoint = Color(0xFF3B82F6);

  /// "ALIGNMENT · Step back 40cm" instruction card.
  static const Color alignmentCardBg = Color(0xE60A1628);
  static const Color alignmentProgressTrack = Color(0x33FFFFFF);

  /// Record button.
  static const Color recordButtonRed = Color(0xFFEF4444);
  static const Color recordButtonRing = Color(0xFFFFFFFF);

  /// Bottom capture-mode tab bar (SLOW-MO / SWING / VIDEO).
  static const Color captureTabInactive = Color(0xFF8A93A6);
  static const Color captureTabActiveDot = Color(0xFF22C55E);

  // ---- Review Swing screen ----

  /// Scrubber ruler ticks + played portion of the track.
  static const Color scrubberTrackBg = Color(0xFF0A1628);
  static const Color scrubberTickMinor = Color(0x4DFFFFFF);
  static const Color scrubberPlayed = Color(0xFF2563EB);
  static const Color scrubberPlayhead = Color(0xFF2563EB);

  /// Speed-toggle pill group (0.25x / 0.5x / 1x).
  static const Color speedPillInactiveBg = Color(0xFFEEF1F5);
  static const Color speedPillActiveBg = Color(0xFF2563EB);

  /// Swing-path analysis overlay drawn on the reviewed clip.
  static const Color swingPathClub = Color(0xFFFACC15);
  static const Color swingPathBall = Color(0xFF86EFAC);
  static const Color swingSkeletonLine = Color(0xFF22D3EE);

  // ---- Analysing (AI loading) screen ----

  static const Color analysingIconBg = Color(0xFFFFFFFF);
  static const Color analysingSpinner = Color(0xFF6366F1);
  static const Color analysingProgressTrack = Color(0xFFE2E8F0);
  static const Color analysingProgressFill = Color(0xFF6366F1);
}
