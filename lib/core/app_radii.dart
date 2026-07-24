import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';

/// Shared corner-radius and card-outline tokens used across the app.
class AppRadii {
  AppRadii._();

  /// Outer cards, panels, list shells.
  static const double card = 20;

  /// Primary / secondary / CTA buttons.
  static const double button = 16;

  /// Card outline stroke width (1.11px).
  static const double cardBorderWidth = 1.11;

  static BorderRadius get cardBorderRadius => BorderRadius.circular(card);

  static BorderRadius get buttonBorderRadius => BorderRadius.circular(button);

  static Border get cardBorder => Border.all(
        color: AppColors.borderCard,
        width: cardBorderWidth,
      );

  static RoundedRectangleBorder get buttonShape => RoundedRectangleBorder(
        borderRadius: buttonBorderRadius,
      );

  static RoundedRectangleBorder get cardShape => RoundedRectangleBorder(
        borderRadius: cardBorderRadius,
        side: const BorderSide(
          color: AppColors.borderCard,
          width: cardBorderWidth,
        ),
      );
}
