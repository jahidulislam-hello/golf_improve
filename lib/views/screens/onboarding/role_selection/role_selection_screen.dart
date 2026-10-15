import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

import 'role_selection_controller.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// Screen 6 — "Choose your role"
class RoleSelectionScreen extends StatefulWidget {
  final ValueChanged<UserRole> onRoleConfirmed;

  const RoleSelectionScreen({super.key, required this.onRoleConfirmed});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final RoleSelectionController _controller = RoleSelectionController();

  void _choose(UserRole role) {
    _controller.selectRole(role);
    widget.onRoleConfirmed(role);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Image.asset(
                'assets/images/logo.png',
                width: 72,
                height: 72,
                color: AppColors.primaryNavy,
              ),
              const SizedBox(height: 20),
              const Text(
                'How Will You Use GolfImprove?',
                style: AppTextStyles.screenTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              RoleCard(
                icon: Icons.sports_golf,
                title: "I'm a Golfer",
                description:
                    'Record and review your swings, track progress and share clips with your coach.',
                selected: _controller.selectedRole == UserRole.golfer,
                onTap: () => _choose(UserRole.golfer),
              ),
              const SizedBox(height: 16),
              RoleCard(
                icon: Icons.workspace_premium_outlined,
                title: "I'm a Coach",
                description:
                    'Record and review student swings, draw lines and share feedback.',
                selected: _controller.selectedRole == UserRole.coach,
                onTap: () => _choose(UserRole.coach),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable role option card used on screen 6.
class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.borderLightGray.withOpacity(selected ? 0.9 : 0.5),
          borderRadius: AppRadii.cardBorderRadius,
          border: Border.all(
            color: selected ? AppColors.ctaBrightBlue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.ctaBrightBlue.withOpacity(0.15),
                borderRadius: AppRadii.cardBorderRadius,
              ),
              child: Icon(icon, color: AppColors.ctaBrightBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.sectionHeader.copyWith(fontSize: 17)),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.caption.copyWith(fontSize: 13.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
