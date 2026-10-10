import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// The outlined "Scan QR / Activation code" button between the text
/// field and the info callout.
class ScanQrButton extends StatelessWidget {
  const ScanQrButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.buttonBorderRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: AppRadii.buttonBorderRadius,
              border: Border.all(color: AppColors.primaryNavy, width: 1.4),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 19,
                  color: AppColors.primaryNavy,
                ),
                const SizedBox(width: 9),
                Text(
                  'Scan QR / Activation code',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}