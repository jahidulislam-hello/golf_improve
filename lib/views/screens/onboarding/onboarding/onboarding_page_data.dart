/// Data for a single onboarding slide (screens 2-5).
class OnboardingPageData {
  final String backgroundAsset;
  final String eyebrow; // e.g. "WELCOME", "FILM EVERY SWING"
  final String title; // e.g. "Train Smarter, Play Better."
  final String description;
  final String buttonLabel; // "Continue" or "Get Started"
  final bool isLast;

  const OnboardingPageData({
    required this.backgroundAsset,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.buttonLabel = 'Continue',
    this.isLast = false,
  });
}

/// The exact 4 onboarding slides from screens 2-5.
final List<OnboardingPageData> onboardingPages = [
  const OnboardingPageData(
    backgroundAsset: 'assets/images/onboarding_one.png',
    eyebrow: 'WELCOME',
    title: 'Train Smarter, Play Better.',
    description:
        'Your personal golf training companion. Record, analyze and improve every single swing.',
  ),
  const OnboardingPageData(
    backgroundAsset: 'assets/images/onboarding_two.png',
    eyebrow: 'FILM EVERY SWING',
    title: 'Record with Precision.',
    description:
        'Set up your Golf Stand, tap record, and let auto-detection capture every swing automatically.',
  ),
  const OnboardingPageData(
    backgroundAsset: 'assets/images/onboarding_three.png',
    eyebrow: 'AI ANALYSIS',
    title: 'Learn From Every Shot.',
    description:
        'AI breaks down your swing plane, tempo and consistency — the same insights TrackMan gives pros.',
  ),
  const OnboardingPageData(
    backgroundAsset: 'assets/images/onboarding_four.png',
    eyebrow: 'READY TO PLAY',
    title: 'Your Golf Journey Starts Now.',
    description: 'Join thousands of golfers improving their game with Golfimprove.',
    buttonLabel: 'Get Started',
    isLast: true,
  ),
];
