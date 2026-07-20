import 'package:flutter/material.dart';
import 'onboarding_page_data.dart';

/// Controller for the onboarding PageView (screens 2-5).
/// Owns the PageController + current index and exposes
/// next / skip / continue actions.
class OnboardingController extends ChangeNotifier {
  final PageController pageController = PageController();
  final List<OnboardingPageData> pages = onboardingPages;

  int currentIndex = 0;

  bool get isLastPage => currentIndex == pages.length - 1;

  void onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }

  /// Called from the Continue / Get Started button.
  void next(VoidCallback onOnboardingComplete) {
    if (isLastPage) {
      onOnboardingComplete();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Called from the Skip button — jumps straight to the end of onboarding.
  void skip(VoidCallback onOnboardingComplete) {
    onOnboardingComplete();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
