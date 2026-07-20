import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // ===== Named Styles (from Typography System) =====

  /// Screen Title — Inter Extra Bold · 32/38
  /// e.g. "Your swing, analysed."
  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 38 / 32, // line-height / font-size
    fontWeight: FontWeight.w800, // Extra Bold
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Section Header — Inter Semi Bold · 22/28
  /// e.g. "Video Library"
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600, // Semi Bold
    color: AppColors.textPrimary,
  );

  /// Body — Inter Regular · 16/22
  /// e.g. "Position your phone at hip height, five feet away."
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
  );

  /// Caption — Inter Regular · 13/18
  /// e.g. "14 swings this week · Driver"
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Stat Number — Inter Bold · 40/44
  /// e.g. "14"
  static const TextStyle statNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 44 / 40,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
  );

  // ===== Type Scale (base 16, ratio 1.125 — full reference ramp) =====

  static const TextStyle type32 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle type29 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 29,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle type26 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle type23 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 23,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle type20 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle type18 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle type16 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle type14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle type13 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle type11 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle type10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle type9 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle type8 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ===== Onboarding =====

  static const TextStyle onboardingEyebrow = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.wellcome,
  );

  static const TextStyle onboardingTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.surfaceWhite,
  );

  static const TextStyle onboardingBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ===== Buttons & Inputs =====

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.surfaceWhite,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  /// Value typed/shown inside an input field.
  static const TextStyle inputValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Centered title used in AuthAppBar ("Enter Email", "Reset Password"...).
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Title inside a lavender AuthCard ("Forgot Password", "Reset Password").
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  /// "Forgot password?" / "Sign Up" / "Resend" style links.
  static const TextStyle linkText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.ctaBrightBlue,
  );

  // ===== Reviews screen specific =====

  /// "Reviews" H1 in the app bar.
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// "PENDING" / "COMPLETED" section eyebrow labels.
  static const TextStyle sectionEyebrow = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );

  /// Golfer name overlaid on the video thumbnail.
  static const TextStyle thumbnailName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.surfaceWhite,
  );

  /// "Driver · Face On" subtitle overlaid on the video thumbnail.
  static const TextStyle thumbnailSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFFE2E8F0),
  );

  /// Small pill labels ("AI Included", "0:12", "3 Pending").
  static const TextStyle pillLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  /// Italic quote under the thumbnail.
  static const TextStyle quoteText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: AppColors.textPrimary,
  );

  /// "Review Now" button label.
  static const TextStyle reviewNowLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.surfaceWhite,
  );
}