import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';


/// The golf-course hero photo at the top of the Golf Stand screen, with
/// the "GOLFIMPROVE APP" wordmark + tagline overlaid on a dark scrim.
class GolfStandHeroBanner extends StatelessWidget {
  const GolfStandHeroBanner({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.primaryNavy),
          ),
          // Dark scrim so the wordmark stays legible over sky/grass.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryNavy.withOpacity(0.55),
                  AppColors.primaryNavy.withOpacity(0.05),
                  AppColors.primaryNavy.withOpacity(0.35),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 22,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.golf_course_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GOLFIMPROVE APP',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'PLAY YOUR GAME. TRACK YOUR IMPROVEMENT.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}