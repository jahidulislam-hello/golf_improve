import 'package:flutter/material.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/helpers/routes.dart';
import 'package:provider/provider.dart';

import '../widgets/age_picker_sheet.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/golf_logo.dart';
import '../widgets/pill_selector.dart';
import '../widgets/primary_button.dart';

void _showAuthError(BuildContext context, AuthController auth) {
  final message = auth.errorMessage;
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class CoachProfileSetUpScreen extends StatelessWidget {
  const CoachProfileSetUpScreen({super.key});

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GolfLogo(showWordmark: false),
              const SizedBox(height: 16),
              Text('Tell us about yourself Coach',
                  textAlign: TextAlign.center, style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Text(
                'Helps us personalise your experience. Takes 30s .',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AGE RANGE', style: AppTextStyles.inputLabel),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showAgePickerSheet(
                          context,
                          currentValue: auth.ageRange,
                        );
                        if (picked != null) {
                          auth.setAgeRange(picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: AppRadii.cardBorderRadius,
                          border: AppRadii.cardBorder,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              auth.ageRange ?? 'Select Your Age',
                              style: AppTextStyles.inputValue.copyWith(
                                color: auth.ageRange == null
                                    ? AppColors.textSecondary.withOpacity(0.7)
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GENDER', style: AppTextStyles.inputLabel),
                    const SizedBox(height: 12),
                    PillSelector(
                      options: const [
                        'Man',
                        'Woman',
                        'Non-binary',
                        'Prefer not to say'
                      ],
                      selected: auth.gender,
                      onSelected: auth.setGender,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'CERTIFICATE NAME',
                hintText: 'PGA Certificate',
                onChanged: auth.setCertificateName,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'EXPERIENCE',
                hintText: '15 years experience',
                keyboardType: TextInputType.number,
                onChanged: auth.setExperienceYear,
              ),
              const SizedBox(height: 26),
              PrimaryButton(
                label: 'Continue',
                icon: Icons.chevron_right,
                isLoading: auth.isLoading,
                onPressed: () async {
                  final success = await auth.completeCoachOnboarding();
                  if (!context.mounted) return;
                  if (!success) {
                    _showAuthError(context, auth);
                    return;
                  }
                  AppRoutes.goToHomeForRole(auth.selectedRole);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
