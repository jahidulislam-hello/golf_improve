import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// The scrollable age list with alternating white / light-blue stripes,
/// exactly like the picker demo screenshot. Call [showAgePickerSheet] to
/// open it and await the chosen age as a String (e.g. "24").
class AgePickerSheet extends StatelessWidget {
  final int minAge;
  final int maxAge;
  final String? currentValue;

  const AgePickerSheet({
    super.key,
    this.minAge = 16,
    this.maxAge = 90,
    this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final ages = List<int>.generate(maxAge - minAge + 1, (i) => minAge + i);

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Select Your Age', style: AppTextStyles.appBarTitle),
            ),
            const Divider(height: 1, color: AppColors.borderLightGray),
            Expanded(
              child: ListView.builder(
                itemCount: ages.length,
                itemBuilder: (context, index) {
                  final age = ages[index];
                  final isCurrent = currentValue == '$age';
                  final stripe = index.isEven
                      ? AppColors.surfaceWhite
                      : AppColors.ageStripeHighlight;

                  return InkWell(
                    onTap: () => Navigator.of(context).pop('$age'),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      alignment: Alignment.center,
                      color: isCurrent ? AppColors.ctaBrightBlue.withOpacity(0.12) : stripe,
                      child: Text(
                        '$age',
                        style: AppTextStyles.type18.copyWith(
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                          color: isCurrent ? AppColors.ctaBrightBlue : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the age picker as a bottom sheet and returns the picked age
/// (as a String), or null if dismissed without a selection.
Future<String?> showAgePickerSheet(
  BuildContext context, {
  String? currentValue,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => AgePickerSheet(currentValue: currentValue),
  );
}
