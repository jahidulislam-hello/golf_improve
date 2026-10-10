import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'onboarding_page_data.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// Reusable full-screen onboarding slide widget — used for screens 2, 3, 4 & 5.
/// Full-bleed background image and a bottom glass/dark card holding eyebrow,
/// title, description, dots and CTA button.
/// Top logo + Skip live on [OnboardingScreen]'s AppBar, not in this card.
class OnboardingCard extends StatelessWidget {
  final OnboardingPageData data;
  final int currentIndex;
  final int pageCount;
  final VoidCallback onContinue;

  const OnboardingCard({
    super.key,
    required this.data,
    required this.currentIndex,
    required this.pageCount,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ---- Background image (unique per slide) ----
        Image.asset(data.backgroundAsset, fit: BoxFit.cover),

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

                  // ---- CTA button: label + arrow ----
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ctaBrightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.buttonBorderRadius,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data.buttonLabel,
                            style: AppTextStyles.buttonLabel,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Colors.white,
                          ),
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
