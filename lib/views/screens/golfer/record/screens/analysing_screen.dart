import 'dart:async';
import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_capture_colors.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';



/// Screenshot 6 — "Analysing your swing" loading state shown while the
/// clip is sent off for AI analysis. Swap the Timer-driven fake progress
/// for a real upload/inference progress stream when you wire up the
/// analysis backend.
class AnalysingScreen extends StatefulWidget {
  const AnalysingScreen({super.key});

  @override
  State<AnalysingScreen> createState() => _AnalysingScreenState();
}

class _AnalysingScreenState extends State<AnalysingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  double _progress = 0.15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 400), (t) {
      setState(() {
        _progress = (_progress + 0.12).clamp(0.0, 1.0);
      });
      if (_progress >= 1.0) {
        t.cancel();
        // TODO: navigate to the AI results screen once analysis completes.
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppCaptureColors.analysingIconBg,
                    borderRadius: AppRadii.cardBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: RotationTransition(
                    turns: _spinController,
                    child: const Icon(
                      Icons.autorenew,
                      color: AppCaptureColors.analysingSpinner,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Analysing your swing',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionHeader,
                ),
                const SizedBox(height: 12),
                Text(
                  'Examining body position, swing path, weight shift '
                  'and grip. This takes 5-10 seconds.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: AppCaptureColors.analysingProgressTrack,
                    color: AppCaptureColors.analysingProgressFill,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
