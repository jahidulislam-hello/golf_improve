import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/compare_swings_screen.dart';
import '../controllers/swing_library_controller.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/video_preview.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _openSwing(SwingVideo swing) {
    if (controller.compareMode) {
      final message = controller.toggleCompareSelection(swing);
      if (message != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }
    if (swing.isLocal) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _LocalSwingScreen(swing: swing)),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SwingAnalysisScreen(swingId: swing.id),
      ),
    );
  }

  void _openCompare() {
    final first = controller.compareAId;
    final second = controller.compareBId;
    if (first == null || second == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompareSwingsScreen(
          initialSwingAId: first,
          initialSwingBId: second,
        ),
      ),
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
            child: Column(
              children: [
                Expanded(child: _buildBody()),
                if (controller.compareMode && controller.canCompare)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: PrimaryButton(
                      label: 'Compare',
                      icon: Icons.compare_arrows,
                      onTap: _openCompare,
                    ),
                  ),
              ],
            ),
          ),
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
                  const Text('Swing Library', style: AppTextStyles.screenTitle),
                  CircleIconButton(
                    icon: Icons.search,
                    background: AppColors.surfaceWhite,
                    onTap: controller.toggleSearch,
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
                  if (controller.searchOpen) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: AppRadii.cardBorderRadius,
                        border: AppRadii.cardBorder,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: controller.setSearch,
                        style: AppTextStyles.type14,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search club, date, or session',
                          hintStyle: AppTextStyles.type14.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  StatSplitCard(
                    leftValue: controller.totalSwings,
                    leftLabel: 'Total Swings',
                    rightValue: controller.sharedWithCoach,
                    rightLabel: 'Shared with Coach',
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: controller.toggleCompareMode,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: controller.compareMode
                            ? AppColors.primaryNavy
                            : AppColors.surfaceWhite,
                        borderRadius: AppRadii.cardBorderRadius,
                        border: controller.compareMode
                            ? null
                            : AppRadii.cardBorder,
                      ),
                      child: Text(
                        controller.compareMode
                            ? 'Cancel'
                            : 'Select to Compare',
                        style: AppTextStyles.type14.copyWith(
                          fontWeight: FontWeight.w700,
                          color: controller.compareMode
                              ? AppColors.surfaceWhite
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
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
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final swing = controller.filteredSwings[index];
                  return SwingThumbnailCard(
                    swing: swing,
                    selected: controller.isCompareSelected(swing),
                    dimmed: controller.isCompareDimmed(swing),
                    onTap: () => _openSwing(swing),
                  );
                }, childCount: controller.filteredSwings.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _LocalSwingScreen extends StatelessWidget {
  const _LocalSwingScreen({required this.swing});

  final SwingVideo swing;

  @override
  Widget build(BuildContext context) {
    final details = [
      swing.club,
      swing.angleLabel,
      if (swing.recordedDateLabel.isNotEmpty) swing.recordedDateLabel,
      if (swing.recordedTimeLabel.isNotEmpty) swing.recordedTimeLabel,
    ].join(' · ');
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.of(context).maybePop(),
                    size: 36,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Saved on this device',
                      style: AppTextStyles.sectionHeader.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: VideoPreview(
                videoUrl: swing.videoUrl,
                thumbnailUrl: swing.thumbnailUrl,
                aspectRatio: 16 / 11,
                borderRadius: AppRadii.cardBorderRadius,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(details, style: AppTextStyles.body),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
