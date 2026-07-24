import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/model.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// Top hero banner: auto-swiping PageView of [HeroBannerModel]s with a
/// dot-indicator row underneath, matching the "Train smarter. Play better."
/// card in the design.
class HeroCarousel extends StatelessWidget {
  const HeroCarousel({
    super.key,
    required this.banners,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onCtaTap,
    required this.onDragStart,
    required this.onDragEnd,
  });

  final List<HeroBannerModel> banners;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onCtaTap;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                onDragStart();
              } else if (notification is ScrollEndNotification) {
                onDragEnd();
              }
              return false;
            },
            child: PageView.builder(
              controller: pageController,
              itemCount: banners.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return _HeroCard(
                  banner: banners[index],
                  onCtaTap: onCtaTap,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        _DotIndicator(count: banners.length, activeIndex: currentIndex),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.banner, required this.onCtaTap});

  final HeroBannerModel banner;
  final VoidCallback onCtaTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: AppRadii.cardBorderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo background. Falls back to the navy gradient if the
            // asset hasn't been bundled yet, so the layout never breaks.
            Image.asset(
              banner.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroNavyGradient,
                ),
              ),
            ),
            // Darken-toward-bottom scrim so white text stays legible.
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.heroImageScrimGradient,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    banner.eyebrow,
                    style: AppTextStyles.type11.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.title,
                    style: AppTextStyles.screenTitle.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      height: 30 / 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StartRecordingButton(
                    label: banner.ctaLabel,
                    onTap: onCtaTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartRecordingButton extends StatelessWidget {
  const _StartRecordingButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 18,
                color: AppColors.primaryNavy,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.type14.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 8 : 6,
          height: isActive ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.carouselActiveDot
                : AppColors.borderLightGray,
          ),
        );
      }),
    );
  }
}
