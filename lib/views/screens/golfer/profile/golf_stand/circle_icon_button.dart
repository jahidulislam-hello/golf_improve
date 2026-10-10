import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';


/// A round, softly-filled icon button used for back/menu/add actions in
/// screen headers (matches the circular buttons in the Students and
/// Student Detail mocks).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.iconSize = 20,
    this.background = AppColors.pillInactive,
    this.iconColor = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}