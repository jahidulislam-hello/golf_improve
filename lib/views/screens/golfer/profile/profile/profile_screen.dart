import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/profile/personal_info/personal_info_screen.dart';
import 'package:golf_training_app/views/screens/golfer/profile/profile/profile_controller.dart';
import 'package:golf_training_app/views/screens/golfer/profile/profile/settings_list_item.dart';


class GolferProfileScreen extends StatefulWidget {
  const GolferProfileScreen({super.key, GolferProfileController? controller})
      : _injectedController = controller;

  final GolferProfileController? _injectedController;

  @override
  State<GolferProfileScreen> createState() => _GolferProfileScreenState();
}

class _GolferProfileScreenState extends State<GolferProfileScreen> {
  late final GolferProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget._injectedController ?? GolferProfileController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (widget._injectedController == null) _controller.dispose();
    super.dispose();
  }

  void _openPersonalInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GolferPersonalInfoScreen(
          name: _controller.name,
          handicap: _controller.handicap,
          onSaved: (name, handicap) {
            _controller.applyPersonalInfo(name: name, handicap: handicap);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ProfileHeader(controller: _controller),
            const SizedBox(height: 20),
            _PlanUpsellCard(controller: _controller),
            const SizedBox(height: 16),
            _GolfStandConnectedRow(controller: _controller),
            const SizedBox(height: 16),
            _SettingsListCard(onPersonalInfoTap: _openPersonalInfo),
            const SizedBox(height: 16),
            _LogOutRow(onTap: _controller.logOut),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller});
  final GolferProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.cardBackground,
          backgroundImage: controller.avatarUrl != null
              ? NetworkImage(controller.avatarUrl!)
              : null,
          child: controller.avatarUrl == null
              ? const Icon(Icons.person, color: AppColors.textSecondary)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.name, style: AppTextStyles.profileName),
              const SizedBox(height: 2),
              Text(controller.handicapLabel, style: AppTextStyles.caption),
            ],
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.pillInactive,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _PlanUpsellCard extends StatelessWidget {
  const _PlanUpsellCard({required this.controller});
  final GolferProfileController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isFreePlan) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroNavyGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.military_tech_outlined, color: AppColors.surfaceWhite, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Free Plan',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.surfaceWhite,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(
                  'Upgrade for unlimited AI analysis',
                  style: AppTextStyles.type13.copyWith(color: AppColors.borderLightGray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: controller.upgradePlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('Upgrade', style: AppTextStyles.pillLabel),
          ),
        ],
      ),
    );
  }
}

class _GolfStandConnectedRow extends StatelessWidget {
  const _GolfStandConnectedRow({required this.controller});
  final GolferProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.successGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.golfStandConnected ? 'Golf Stand Connected' : 'Golf Stand Not Connected',
              style: AppTextStyles.listItemTitle,
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _SettingsListCard extends StatelessWidget {
  const _SettingsListCard({required this.onPersonalInfoTap});
  final VoidCallback onPersonalInfoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SettingsListItem(
            icon: Icons.person_outline,
            title: 'Personal Info',
            subtitle: 'Name, email, handicap',
            onTap: onPersonalInfoTap,
          ),
          SettingsListItem(
            icon: Icons.menu_book_outlined,
            title: 'Logbook',
            subtitle: 'Tips & reminders',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Reminders & alerts',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Contact us anytime',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.grid_view_rounded,
            title: 'Community & Legal',
            subtitle: 'Privacy, data & more',
            onTap: () {},
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _LogOutRow extends StatelessWidget {
  const _LogOutRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SettingsListItem(
        icon: Icons.logout,
        title: 'Log out',
        subtitle: '',
        iconBackgroundColor: AppColors.backButtonBorder,
        iconColor: AppColors.destructiveRed,
        titleStyle: AppTextStyles.destructiveLabel,
        showDivider: false,
        onTap: onTap,
      ),
    );
  }
}
