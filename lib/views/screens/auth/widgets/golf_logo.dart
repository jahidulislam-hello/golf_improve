import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// Stand-in for the "GOLFIMPROVE" wordmark + flag/wave icon at the top of
/// Sign In, Sign Up and the onboarding screen.
///
/// Replace the [Icon] below with `Image.asset('assets/logo.png')` once you
/// have the real logo asset — everything else (spacing, wordmark, tagline)
/// already matches the screenshots.
class GolfLogo extends StatelessWidget {
  final bool showWordmark;

  const GolfLogo({super.key, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 140,
          height: 80,
          fit: BoxFit.contain,
          color: AppColors.primaryNavy,
        ),
        if (showWordmark) ...[
          const SizedBox(height: 8),
          const Text(
            'GOLFIMPROVE',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'IMPROVE YOUR GAME',
            style: AppTextStyles.type9.copyWith(letterSpacing: 2),
          ),
        ],
      ],
    );
  }
}
