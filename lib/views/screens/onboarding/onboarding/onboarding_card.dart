import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'onboarding_page_data.dart';

/// Reusable full-screen onboarding slide widget — used for screens 2, 3, 4 & 5.
/// Full-bleed background image, top bar (logo + Skip), and a bottom
/// glass/dark card holding eyebrow, title, description, dots and CTA button.
class OnboardingCard extends StatelessWidget {
  final OnboardingPageData data;
  final int currentIndex;
  final int pageCount;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  const OnboardingCard({
    super.key,
    required this.data,
    required this.currentIndex,
    required this.pageCount,
    required this.onSkip,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ---- Background image (unique per slide) ----
        Image.asset(data.backgroundAsset, fit: BoxFit.cover),

        // ---- Top bar: logo (left) + Skip (right) ----
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'GOLFIMPROVE',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ctaBrightBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---- Bottom glass card ----
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.55),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.eyebrow, style: AppTextStyles.onboardingEyebrow),
                  const SizedBox(height: 10),
                  Text(data.title, style: AppTextStyles.onboardingTitle),
                  const SizedBox(height: 10),
                  Text(data.description, style: AppTextStyles.onboardingBody),
                  const SizedBox(height: 18),

                  // ---- Dot indicator ----
                  Row(
                    children: List.generate(pageCount, (i) {
                      final bool active = i == currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        height: 4,
                        width: active ? 24 : 6,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  // ---- CTA button ----
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ctaBrightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(data.buttonLabel, style: AppTextStyles.buttonLabel),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
