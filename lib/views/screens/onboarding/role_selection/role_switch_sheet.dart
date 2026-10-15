import 'package:flutter/material.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/helpers/routes.dart';
import 'package:golf_training_app/views/screens/onboarding/role_selection/role_selection_controller.dart';
import 'package:provider/provider.dart';

/// Settings sheet that switches Golfer ↔ Coach via `PATCH /user/update-my-profile`.
Future<void> showRoleSwitchSheet(BuildContext context) async {
  final auth = Provider.of<AuthController>(context, listen: false);
  final current = auth.selectedRole ?? UserRole.golfer;

  final picked = await showModalBottomSheet<UserRole>(
    context: context,
    backgroundColor: AppColors.surfaceWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Account role', style: AppTextStyles.sectionHeader),
              const SizedBox(height: 6),
              Text(
                'Switch between golfer and coach. Your account stays the same.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              _RoleOption(
                title: 'Golfer',
                subtitle: 'Record swings and follow your practice plan',
                selected: current == UserRole.golfer,
                onTap: () => Navigator.of(sheetContext).pop(UserRole.golfer),
              ),
              const SizedBox(height: 8),
              _RoleOption(
                title: 'Coach',
                subtitle: 'Review student swings and write practice plans',
                selected: current == UserRole.coach,
                onTap: () => Navigator.of(sheetContext).pop(UserRole.coach),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (picked == null || picked == current || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final ok = await auth.switchRole(picked);
  if (!context.mounted) return;
  if (!ok) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(auth.errorMessage ?? 'Could not switch role.'),
      ),
    );
    return;
  }
  AppRoutes.goToHomeForRole(picked);
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.cardBackground : AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.ctaBrightBlue : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
