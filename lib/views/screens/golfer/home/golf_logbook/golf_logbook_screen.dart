import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/add_swing_tip_screen.dart';


/// Golf Logbook screen — active reminder banner, Newest/Oldest toggle,
/// and a list of tip cards. Tapping the ⋮ on any card opens the
/// Edit / Share with pro / Delete popup shown in screen 2, anchored
/// right under that card's icon.
class GolfLogbookScreen extends StatefulWidget {
  const GolfLogbookScreen({super.key});

  @override
  State<GolfLogbookScreen> createState() => _GolfLogbookScreenState();
}

enum _SortOrder { newest, oldest }

class _GolfLogbookScreenState extends State<GolfLogbookScreen> {
  _SortOrder _sort = _SortOrder.newest;
  bool _reminderVisible = true;

  final List<_TipData> _tips = const [
    _TipData(
      badges: ['Driver'],
      important: true,
      title: 'Hip rotation timing',
      description: 'Initiate from the ground up — hips lead before shoulders unwind.',
    ),
    _TipData(
      badges: ['All Clubs'],
      important: false,
      title: 'Grip pressure at address',
      description: 'Hold at 4 out of 10. Tension kills tempo.',
    ),
    _TipData(
      badges: ['Wedges'],
      important: false,
      title: 'Wedge follow-through',
      description: 'Finish with shaft vertical, hands at chest height.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      if (_reminderVisible) ...[
                        _ActiveReminderCard(
                          onDismiss: () => setState(() => _reminderVisible = false),
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildTipsHeader(),
                      const SizedBox(height: 12),
                      for (final tip in _tips) ...[
                        _TipCard(data: tip),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: _AddTipButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddSwingTipScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
          child: Text('Recent Tips',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              )),
        ),
        _SortToggle(
          sort: _sort,
          onChanged: (s) => setState(() => _sort = s),
        ),
      ],
    );
  }
}

class _TipData {
  final List<String> badges;
  final bool important;
  final String title;
  final String description;

  const _TipData({
    required this.badges,
    required this.important,
    required this.title,
    required this.description,
  });
}

/// Dark "Active Reminder" banner with bell icon and dismiss (X).
class _ActiveReminderCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const _ActiveReminderCard({required this.onDismiss});

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
            child: const Icon(Icons.notifications_none,
                size: 18, color: AppColors.surfaceWhite),
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
                  'Keep your left arm straight through impact — Driver session today',
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
            child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Segmented "Newest / Oldest" toggle.
class _SortToggle extends StatelessWidget {
  final _SortOrder sort;
  final ValueChanged<_SortOrder> onChanged;

  const _SortToggle({required this.sort, required this.onChanged});

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
          _segment('Newest', _SortOrder.newest),
          _segment('Oldest', _SortOrder.oldest),
        ],
      ),
    );
  }

  Widget _segment(String label, _SortOrder value) {
    final bool selected = sort == value;
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

/// One tip card: badges row + ⋮ menu button, bold title, caption description.
class _TipCard extends StatelessWidget {
  final _TipData data;
  const _TipCard({required this.data});

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
                    if (data.important) ...[
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'IMPORTANT',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    for (final badge in data.badges) _BadgePill(label: badge),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  data.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.description,
                  style: AppTextStyles.caption.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          _TipMenuButton(
            onEdit: () {},
            onShareWithPro: () {},
            onDelete: () {},
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  const _BadgePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pillInactive,
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// The ⋮ button on a tip card. Opens the Edit / Share with pro / Delete
/// popup shown in screen 2, anchored directly under this button.
class _TipMenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onShareWithPro;
  final VoidCallback onDelete;

  const _TipMenuButton({
    required this.onEdit,
    required this.onShareWithPro,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 36),
      color: Colors.transparent,
      elevation: 0,
      shape: AppRadii.buttonShape,
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 180),
      itemBuilder: (context) => [
        _menuItem(value: 'edit', label: 'Edit', background: AppColors.statusInfoBg, textColor: AppColors.textPrimary),
        _menuItem(value: 'share', label: 'Share with pro', background: AppColors.quickActionShareBg, textColor: AppColors.textPrimary),
        _menuItem(value: 'delete', label: 'Delete', background: AppColors.surfaceWhite, textColor: AppColors.destructiveRed),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'share':
            onShareWithPro();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.pillInactive,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
      ),
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required String label,
    required Color background,
    required Color textColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: EdgeInsets.zero,
      height: 44,
      child: Container(
        width: double.infinity,
        height: 44,
        alignment: Alignment.center,
        color: background,
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// Blue circular floating "+" button, bottom right.
class _AddTipButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddTipButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ctaBrightBlue,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.add, color: AppColors.surfaceWhite, size: 26),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pillInactive,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
