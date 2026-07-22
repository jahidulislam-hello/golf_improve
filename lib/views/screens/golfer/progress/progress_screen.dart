import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/progress/progress_controller.dart';
import 'widgets/handicap_progress_card.dart';
import 'widgets/mini_stat_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/this_week_card.dart';
import 'widgets/weekly_swings_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, this.controller});

  final ProgressController? controller;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final ProgressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProgressController();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLightGray),
                ),
              ),
              child: Text('My Progress', style: AppTextStyles.screenTitle),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ThisWeekCard(controller: _controller),
                  StreakCard(controller: _controller),
                  HandicapProgressCard(controller: _controller),
                  WeeklySwingsCard(controller: _controller),
                  Row(
                    children: [
                      Expanded(
                        child: MiniStatCard(
                          icon: Icons.access_time_rounded,
                          iconColor: AppColors.ctaBrightBlue,
                          iconBackground: AppColors.accentBlueBg,
                          value: '${_controller.totalSessions}',
                          label: 'Total Sessions',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MiniStatCard(
                          icon: Icons.bolt_rounded,
                          iconColor: AppColors.accentPurple,
                          iconBackground: AppColors.accentPurpleBg,
                          value: '${_controller.totalSwings}',
                          label: 'Total Swings',
                        ),
                      ),
                    ],
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
