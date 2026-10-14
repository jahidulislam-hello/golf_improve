import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';

import '../models/capture_session.dart';
import 'review_swing_screen.dart';

/// Recording no longer waits here. Review opens immediately and saves
/// the trimmed clip in the background.
class AnalysingScreen extends StatefulWidget {
  const AnalysingScreen({super.key, required this.session});

  final CaptureSession session;

  @override
  State<AnalysingScreen> createState() => _AnalysingScreenState();
}

class _AnalysingScreenState extends State<AnalysingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReviewSwingScreen(session: widget.session),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: AppColors.backgroundOffWhite);
  }
}
