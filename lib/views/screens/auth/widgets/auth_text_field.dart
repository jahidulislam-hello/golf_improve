import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// The white rounded input field used across every auth screen.
///
/// Two visual variants, matching the screenshots:
/// - `label` above the value (Sign In / Sign Up style — EMAIL, PASSWORD)
/// - `leadingIcon` + placeholder only, no label (Forgot Password / Reset
///   Password style — mail icon / key icon)
class AuthTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final IconData? leadingIcon;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.onToggleObscure,
    this.leadingIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!, style: AppTextStyles.inputLabel),
            const SizedBox(height: 2),
          ],
          Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: AppTextStyles.inputValue,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: AppTextStyles.inputValue
                        .copyWith(color: AppColors.textSecondary.withOpacity(0.7)),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: label != null ? 8 : 18),
                  ),
                ),
              ),
              if (onToggleObscure != null)
                GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
            ],
          ),
          if (label != null) const SizedBox(height: 12),
        ],
      ),
    );
  }
}
