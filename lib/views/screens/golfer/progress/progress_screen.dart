import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/progress/progress_controller.dart';
import 'widgets/compare_six_weeks_card.dart';
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
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ProgressController();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (_ownsController) {
      _controller.dispose();
    }
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
              child: const Text('My Progress', style: AppTextStyles.screenTitle),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && !_controller.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null && !_controller.hasLoaded) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _controller.loadProgress(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.ctaBrightBlue,
      onRefresh: () => _controller.loadProgress(showLoader: false),
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ThisWeekCard(controller: _controller),
          StreakCard(controller: _controller),
          HandicapProgressCard(controller: _controller),
          CompareSixWeeksCard(controller: _controller),
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
              const SizedBox(width: 12),
              Expanded(
                child: MiniStatCard(
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.accentPurple,
                  iconBackground: AppColors.accentPurpleBg,
                  value: '${_controller.totalSwings}',
                  label: 'Total Swings',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MiniStatCard(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.accentGreen,
                  iconBackground: AppColors.insightPositiveIconBg,
                  value: '${_controller.totalPracticeMinutes}',
                  label: 'Minutes Practised',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
