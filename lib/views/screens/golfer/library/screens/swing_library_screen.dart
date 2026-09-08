import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../controllers/swing_library_controller.dart';
import '../widgets/shared_widgets.dart';
import 'swing_analysis_screen.dart';

/// Screen 1 — Swing Library.
/// Shows scrollable Club / Angle filter chips, a stats card, and a 2-column
/// grid of swing video thumbnails. Tapping any thumbnail opens Screen 2.
class SwingLibraryScreen extends StatefulWidget {
  const SwingLibraryScreen({super.key});

  @override
  State<SwingLibraryScreen> createState() => _SwingLibraryScreenState();
}

class _SwingLibraryScreenState extends State<SwingLibraryScreen> {
  final SwingLibraryController controller = SwingLibraryController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _openAnalysis(String swingId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SwingAnalysisScreen(swingId: swingId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundOffWhite,
          body: SafeArea(child: _buildBody()),
        );
      },
    );
  }

  Widget _buildBody() {
    if (controller.isLoading && !controller.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null && !controller.hasLoaded) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => controller.load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.ctaBrightBlue,
      onRefresh: () => controller.load(showLoader: false),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Swing Library', style: AppTextStyles.screenTitle),
                  const CircleIconButton(
                    icon: Icons.search,
                    background: AppColors.surfaceWhite,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('CLUB'),
                  const SizedBox(height: 10),
                  FilterChipRow(
                    options: controller.clubs,
                    selected: controller.selectedClub,
                    onSelect: controller.selectClub,
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('ANGLE'),
                  const SizedBox(height: 10),
                  FilterChipRow(
                    options: controller.angles,
                    selected: controller.selectedAngle,
                    onSelect: controller.selectAngle,
                    selectedColor: AppColors.ctaBrightBlue,
                  ),
                  const SizedBox(height: 20),
                  StatSplitCard(
                    leftValue: controller.totalSwings,
                    leftLabel: 'Total Swings',
                    rightValue: controller.sharedWithCoach,
                    rightLabel: 'Shared w/ Coach',
                  ),
                  const SizedBox(height: 20),
                  if (controller.isFiltering)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  if (controller.errorMessage != null && controller.hasLoaded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        controller.errorMessage!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (controller.filteredSwings.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('No swings found', style: AppTextStyles.body),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.76,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final swing = controller.filteredSwings[index];
                  return SwingThumbnailCard(
                    swing: swing,
                    onTap: () => _openAnalysis(swing.id),
                  );
                }, childCount: controller.filteredSwings.length),
              ),
            ),
        ],
      ),
    );
  }
}
