import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// "Good morning / Alex Thompson" greeting row with a notification bell
/// (unread dot) and a circular avatar, both tappable.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.avatarInitials,
    required this.hasUnreadNotifications,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  final String greeting;
  final String userName;
  final String avatarInitials;
  final bool hasUnreadNotifications;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                userName,
                style: AppTextStyles.type23.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _IconButtonWithBadge(
          icon: Icons.notifications_none_rounded,
          showBadge: hasUnreadNotifications,
          onTap: onNotificationTap,
        ),
        const SizedBox(width: 12),
        _AvatarButton(initials: avatarInitials, onTap: onProfileTap),
      ],
    );
  }
}

class _IconButtonWithBadge extends StatelessWidget {
  const _IconButtonWithBadge({
    required this.icon,
    required this.showBadge,
    required this.onTap,
  });

  final IconData icon;
  final bool showBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 26),
              if (showBadge)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEF4444),
                      border: Border.all(
                        color: AppColors.backgroundOffWhite,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.initials, required this.onTap});

  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryNavy,
            shape: BoxShape.circle,
          ),
          child: initials.isEmpty
              ? const Icon(Icons.person, color: Colors.white, size: 20)
              : Text(
                  initials,
                  style: AppTextStyles.type13.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
