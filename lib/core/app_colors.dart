import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===== Solid Colors (bound to Figma Variables) =====

  /// primary/navy — Headers, nav, key actions
  static const Color primaryNavy = Color(0xFF0A1628);

  /// cta/bright-blue — Buttons, active states, links
  static const Color ctaBrightBlue = Color(0xFF2563EB);
  static const Color wellcome = Color(0xFF3B82F6);


    static const Color cardBackground = Color(0xFFE4E7F2);

  /// Background of an unselected pill (Gender / Practice sessions).
  static const Color pillInactive = Color(0xFFEEF1F5);

  /// Thin ring around the circular back button in the auth app bar.
  static const Color backButtonBorder = Color(0xFFF7D7DC);

  /// Alternating highlight stripe used in the age scroll-picker.
  static const Color ageStripeHighlight = Color(0xFFD9E1F7);


  /// background/off-white — Screen backgrounds
  static const Color backgroundOffWhite = Color(0xFFF4F6F9);

  /// surface/white — Cards, modals, inputs
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  /// border/light-gray — Dividers, card borders
  static const Color borderLightGray = Color(0xFFE2E8F0);

  /// border/card — Subtle card outline (e.g. Recent Activity card)
  static const Color borderCard = Color(0xFFF1F5F9);

  /// text/primary — Body text, labels
  static const Color textPrimary = Color(0xFF1E293B);

  /// text/secondary — Captions, metadata
  static const Color textSecondary = Color(0xFF64748B);

  // ===== Gradient Styles =====

  /// Hero Navy — Onboarding & splash backgrounds
  static const LinearGradient heroNavyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A1628),
      Color(0xFF060D18), // darker navy shade
    ],
  );

  /// CTA Blue — Primary button depth, premium CTAs
  static const LinearGradient ctaBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3B6CF0),
      Color(0xFF2563EB),
    ],
  );

  /// Video Scrim — Overlay on thumbnails/video for text legibility
  static const LinearGradient videoScrimGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF4B4B4B),
      Color(0xFFFFFFFF),
    ],
  );

  /// Stand Owner Badge — Premium / Stand-verified badge highlight
  static const LinearGradient standOwnerBadgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1628),
      Color(0xFF2563EB),
    ],
  );



  // ===== Extra semantic tints used across dashboard components =====
  // (Not in the original Figma export, but sampled from the dashboard mock
  // so components render pixel-accurate. Keep these here rather than
  // hardcoding hex values inside widgets.)
 
  /// "Coach Reviewing" status pill background
  static const Color statusInfoBg = Color(0xFFDBEAFE);
 
  /// Carousel active-dot accent
  static const Color carouselActiveDot = Color(0xFFDB2777);
 
  /// Unread indicator (coach feedback card)
  static const Color successGreen = Color(0xFF22C55E);
 
  /// Quick action — AI Analysis
  static const Color quickActionAiBg = Color(0xFFE0E7FF);
  static const Color quickActionAiIcon = Color(0xFF6366F1);
 
  /// Quick action — Logbook
  static const Color quickActionLogbookBg = Color(0xFFDCFCE7);
  static const Color quickActionLogbookIcon = Color(0xFF16A34A);
 
  /// Quick action — Share with Coach
  static const Color quickActionShareBg = Color(0xFFFFEDD5);
  static const Color quickActionShareIcon = Color(0xFFF97316);
 
  /// Quick action — Library
  static const Color quickActionLibraryBg = Color(0xFFEDE9FE);
  static const Color quickActionLibraryIcon = Color(0xFF7C3AED);
 
  
  

  static const LinearGradient heroImageScrimGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xE60A1628),
      Color(0x330A1628),
      Color(0x000A1628),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Notification badge red — used on the bell icon's unread-count dot.
  /// (Sampled from the dashboard mock; not in the original Figma export.)
  static const Color notificationBadgeRed = Color(0xFFEF4444);

  // ===== Review Swing screen tints =====
  // (Sampled from the "Review Swing" mock; not in the original Figma export.)

  /// "Your Last Note on Alex" highlight card.
  static const Color noteHighlightBg = Color(0xFFFFFBEB);
  static const Color noteHighlightBorder = Color(0xFFFDE68A);
  static const Color noteHighlightText = Color(0xFF92400E);

  /// "BETA" badge on the AI Analysis card.
  static const Color betaBadgeBg = Color(0xFFFDE68A);
  static const Color betaBadgeText = Color(0xFF92400E);

  /// AI analysis rows flagged as issues (red icon circle).
  static const Color aiWarningBg = Color(0xFFFEE2E2);
  static const Color aiWarningIcon = Color(0xFFEF4444);

  /// Destructive action (delete practice-plan day).
  static const Color destructiveRed = Color(0xFFEF4444);
}
