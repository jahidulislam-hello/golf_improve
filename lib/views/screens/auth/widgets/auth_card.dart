import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';


/// The soft lavender rounded panel that "Forgot Password", "OTP Code
/// Verification" and "Reset Password" sit inside on screen 3, 4 and 5.
class AuthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AuthCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 28, 20, 28),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }
}
