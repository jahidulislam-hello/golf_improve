import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// "Activation Code" label + a rounded, bordered text field for the
/// 12-digit code, matching the mock.
class ActivationCodeField extends StatelessWidget {
  const ActivationCodeField({
    super.key,
    required this.controller,
    this.errorText,
  });

  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activation Code', style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14.5,
        )),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLength: 12,
          textCapitalization: TextCapitalization.characters,
          style: AppTextStyles.inputValue.copyWith(letterSpacing: 1.2),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Enter 12-digit activation code',
            hintStyle: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: AppRadii.buttonBorderRadius,
              borderSide: BorderSide(color: AppColors.borderLightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.buttonBorderRadius,
              borderSide: BorderSide(color: AppColors.borderLightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.buttonBorderRadius,
              borderSide: const BorderSide(
                color: AppColors.ctaBrightBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadii.buttonBorderRadius,
              borderSide: const BorderSide(color: AppColors.destructiveRed),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}