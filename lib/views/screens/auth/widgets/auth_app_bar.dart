import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// The app bar used on Forgot Password / OTP Verification / Reset Password:
/// a circular back button with a soft pink ring on the left, and a
/// centered bold title.
class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackTap;

  const AuthAppBar({
    super.key,
    required this.title,
    this.onBackTap,
  });

  static const double _buttonSize = 44;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: SizedBox(
          height: _buttonSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: _buttonSize,
                    height: _buttonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceWhite,
                      border: Border.all(
                        color: AppColors.backButtonBorder,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(title, style: AppTextStyles.appBarTitle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_buttonSize + 20);
}
