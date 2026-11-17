import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';


/// Screen 1 — Splash Screen
/// Single full-bleed background image (golf course sunrise) with the
/// GOLFIMPROVE logo + tagline centered, and a circular progress ring
/// at the bottom that runs for exactly 5 seconds before navigating on.
class SplashScreen extends StatefulWidget {
  /// Route (or callback) to run once the 5s splash timer completes.
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  /// Session restore is synchronous, so the splash only needs to be long
  /// enough for the brand moment and to warm up Home's images.
  static const Duration _splashDuration = Duration(milliseconds: 1400);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _splashDuration,
    )..forward();

    Future.delayed(_splashDuration, () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode Home's hero images while the splash is showing so the first
    // Home frame paints without image pop-in.
    for (final asset in const [
      'assets/images/golf_01.png',
      'assets/images/golf_02.png',
      'assets/images/golf_03.png',
    ]) {
      precacheImage(AssetImage(asset), context).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- Background image (single image, exactly like screen 1) ----
          Image.asset(
            'assets/images/neww.png',
            fit: BoxFit.cover,
          ),

          // Subtle top-to-bottom darkening so logo/loader stay legible
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Colors.transparent,
                  Color(0x66000000),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ---- Centered logo + wordmark ----
          // Center(
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Image.asset(
          //         'assets/images/logo_mark.png',
          //         width: 96,
          //         height: 96,
          //         color: Colors.black,
          //       ),
          //       const SizedBox(height: 16),
          //       const Text(
          //         'GOLFIMPROVE',
          //         style: TextStyle(
          //           fontFamily: 'Inter',
          //           fontSize: 30,
          //           fontWeight: FontWeight.w800,
          //           letterSpacing: 2,
          //           color: Colors.black,
          //         ),
          //       ),
          //       const SizedBox(height: 6),
          //       Text(
          //         'IMPROVE YOUR GAME',
          //         style: TextStyle(
          //           fontFamily: 'Inter',
          //           fontSize: 12,
          //           fontWeight: FontWeight.w500,
          //           letterSpacing: 3,
          //           color: Colors.black.withOpacity(0.65),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // ---- Bottom loading ring (fills over exactly 5 seconds) ----
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: _controller.value,
                      strokeWidth: 14,
                      backgroundColor: Colors.white.withOpacity(0.35),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.ctaBrightBlue,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
