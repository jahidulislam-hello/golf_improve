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

  void _openAnalysis() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SwingAnalysisScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundOffWhite,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Swing Library', style: AppTextStyles.screenTitle),
                        CircleIconButton(
                          icon: Icons.search,
                          background: AppColors.surfaceWhite,
                          onTap: () {},
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
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final swing = controller.filteredSwings[index];
                        return SwingThumbnailCard(
                          swing: swing,
                          onTap: _openAnalysis,
                        );
                      },
                      childCount: controller.filteredSwings.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
