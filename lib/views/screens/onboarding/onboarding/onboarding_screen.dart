import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'onboarding_card.dart';
import 'onboarding_controller.dart';

/// Screens 2, 3, 4 & 5 — single PageView built from the reusable
/// OnboardingCard widget, driven by OnboardingController.
class OnboardingScreen extends StatefulWidget {
  /// Called once the user finishes (taps "Get Started" on the last
  /// slide) or taps "Skip" on any slide.
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 56,
              height: 44,
              color: Color(0xFF1E293B),
            ),
            const SizedBox(width: 8),
            const Text(
              'GOLFIMPROVE',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _controller.skip(widget.onComplete),
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
          const SizedBox(width: 8),
        ],
      ),
      body: PageView.builder(
        controller: _controller.pageController,
        itemCount: _controller.pages.length,
        onPageChanged: _controller.onPageChanged,
        itemBuilder: (context, index) {
          final data = _controller.pages[index];
          return OnboardingCard(
            data: data,
            currentIndex: _controller.currentIndex,
            pageCount: _controller.pages.length,
            onContinue: () => _controller.next(widget.onComplete),
          );
        },
      ),
    );
  }
}
