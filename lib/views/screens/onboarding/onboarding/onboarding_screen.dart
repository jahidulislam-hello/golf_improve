import 'package:flutter/material.dart';
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
            onSkip: () => _controller.skip(widget.onComplete),
            onContinue: () => _controller.next(widget.onComplete),
          );
        },
      ),
    );
  }
}
