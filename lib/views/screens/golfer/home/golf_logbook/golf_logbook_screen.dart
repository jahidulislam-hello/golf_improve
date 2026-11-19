import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/add_swing_tip_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/golf_logbook/golf_logbook_controller.dart';
import 'package:golf_training_app/views/screens/golfer/library/screens/share_with_coach_screen.dart';

/// Golf Logbook — live practice notes from `GET /note-book/get-my-notes`.
class GolfLogbookScreen extends StatefulWidget {
  const GolfLogbookScreen({super.key});

  @override
  State<GolfLogbookScreen> createState() => _GolfLogbookScreenState();
}

class _GolfLogbookScreenState extends State<GolfLogbookScreen> {
  late final GolfLogbookController _controller;
  bool _reminderDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = GolfLogbookController()..addListener(_onChange);
    _controller.load();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTip() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddSwingTipScreen()),
    );
    if (saved == true) await _controller.load(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    final pinned = _controller.pinnedReminder;
    final showReminder = !_reminderDismissed && pinned != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _controller.load(showLoader: false),
                    child: _buildBody(showReminder: showReminder, pinned: pinned),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: _AddTipButton(onPressed: _addTip),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool showReminder,
    required LogbookTip? pinned,
  }) {
    if (_controller.isLoading && _controller.tips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.errorMessage != null && _controller.tips.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            _controller.errorMessage!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _controller.load(),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        if (showReminder && pinned != null) ...[
          _ActiveReminderCard(
            text: pinned.title.isNotEmpty ? pinned.title : pinned.description,
            onDismiss: () async {
              setState(() => _reminderDismissed = true);
              await _controller.dismissPinned();
            },
          ),
          const SizedBox(height: 20),
        ],
        _buildTipsHeader(),
        const SizedBox(height: 12),
        if (_controller.tips.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              'No tips yet. Tap + to add your first practice reminder.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          for (final tip in _controller.tips) ...[
            _TipCard(
              tip: tip,
              onShare: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShareWithCoachScreen(
                      practiceNoteId: tip.id,
                      includeAiAnalysis: false,
                    ),
                  ),
                );
              },
              onDelete: () async {
                await _controller.deleteTip(tip.id);
              },
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Text('Golf Logbook', style: AppTextStyles.sectionHeader),
        ],
      ),
    );
  }

  Widget _buildTipsHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Tips',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        _SortToggle(
          sort: _controller.sort,
          onChanged: _controller.setSort,
        ),
      ],
    );
  }
}

class _ActiveReminderCard extends StatelessWidget {
  const _ActiveReminderCard({required this.text, required this.onDismiss});

  final String text;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 18,
              color: AppColors.surfaceWhite,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE REMINDER',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.surfaceWhite,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortToggle extends StatelessWidget {
  const _SortToggle({required this.sort, required this.onChanged});

  final LogbookSort sort;
  final ValueChanged<LogbookSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.pillInactive,
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment('Newest', LogbookSort.newest),
          _segment('Oldest', LogbookSort.oldest),
        ],
      ),
    );
  }

  Widget _segment(String label, LogbookSort value) {
    final selected = sort == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.ctaBrightBlue : Colors.transparent,
          borderRadius: AppRadii.cardBorderRadius,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.surfaceWhite : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tip,
    required this.onShare,
    required this.onDelete,
  });

  final LogbookTip tip;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Badge(tip.club),
                    if (tip.important) ...[
                      const SizedBox(width: 8),
                      const _Badge('Important', emphasize: true),
                    ],
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'share') onShare();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'share',
                          child: Text('Share with pro'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      child: const Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tip.title.isEmpty ? tip.description : tip.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                if (tip.description.isNotEmpty &&
                    tip.description != tip.title) ...[
                  const SizedBox(height: 6),
                  Text(
                    tip.description,
                    style: AppTextStyles.caption.copyWith(height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, {this.emphasize = false});

  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: emphasize
            ? AppColors.accentOrangeBg
            : AppColors.accentBlueBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: emphasize ? AppColors.accentOrange : AppColors.ctaBrightBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AddTipButton extends StatelessWidget {
  const _AddTipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ctaBrightBlue,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
