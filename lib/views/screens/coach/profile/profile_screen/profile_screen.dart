import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/coach/profile/profile_info_screen/profile_info_screen.dart';
import 'profile_controller.dart';
import 'package:golf_training_app/core/app_radii.dart';


class ProfileScreen extends StatefulWidget {
  final ProfileController controller;
  const ProfileScreen({super.key, required this.controller});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // ---- Header ----
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.quickActionAiBg,
                  backgroundImage: c.avatarUrl != null ? NetworkImage(c.avatarUrl!) : null,
                  child: c.avatarUrl == null
                      ? Icon(Icons.person, color: AppColors.quickActionAiIcon, size: 28)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(c.title, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Plan card ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.heroNavyGradient,
                borderRadius: AppRadii.cardBorderRadius,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.military_tech, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.planName,
                            style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(c.planSubtitle,
                            style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  if (c.planActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.betaBadgeBg,
                        borderRadius: AppRadii.cardBorderRadius,
                      ),
                      child: Text('Active',
                          style: AppTextStyles.pillLabel.copyWith(color: AppColors.betaBadgeText)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Stat cards ----
            Row(
              children: [
                Expanded(child: _StatCard(value: '${c.studentsCount}', label: 'Students')),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(value: '${c.reviewsCount}', label: 'Reviews Done')),
              ],
            ),
            const SizedBox(height: 16),

            // ---- Menu card ----
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: AppRadii.cardBorderRadius,
                border: AppRadii.cardBorder,
              ),
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.person_outline,
                    title: 'Personal Info',
                    subtitle: 'Name, email, handicap',
                    onTap: () {
                      // ---- Navigation to the second screen ----
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PersonalInfoScreen(controller: c),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.borderCard),
                  _MenuTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    subtitle: 'Reminders & alerts',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.borderCard),
                  _MenuTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Contact us anytime',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.borderCard),
                  _MenuTile(
                    icon: Icons.apps,
                    title: 'Community & Legal',
                    subtitle: 'Privacy, data & more',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Log out ----
            Material(
              color: AppColors.surfaceWhite,
              borderRadius: AppRadii.cardBorderRadius,
              child: InkWell(
                borderRadius: AppRadii.cardBorderRadius,
                onTap: () {
                  c.logOut();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.cardBorderRadius,
                    border: AppRadii.cardBorder,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.aiWarningBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.logout, color: AppColors.destructiveRed, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Log out',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.destructiveRed, fontWeight: FontWeight.w700)),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.destructiveRed),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.statNumber.copyWith(fontSize: 24, height: 1)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.pillInactive, shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}