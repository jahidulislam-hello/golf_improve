
import 'package:flutter/material.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/helpers/routes.dart';
import 'package:provider/provider.dart';

import '../widgets/age_picker_sheet.dart';
import '../widgets/golf_logo.dart';
import '../widgets/pill_selector.dart';
import '../widgets/primary_button.dart';
import 'package:golf_training_app/core/app_radii.dart';

class ProfileSetUpScreen extends StatelessWidget {
  const ProfileSetUpScreen({super.key});

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
              Text('Tell us about yourself',
                  textAlign: TextAlign.center, style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Text(
                'Helps us personalise your experience. Takes 30s .',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // ---- Age range ----
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

              // ---- Gender ----
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GENDER', style: AppTextStyles.inputLabel),
                    const SizedBox(height: 12),
                    PillSelector(
                      options: const ['Man', 'Woman', 'Non-binary', 'Prefer not to say'],
                      selected: auth.gender,
                      onSelected: auth.setGender,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- Handicap index ----
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Handicap Index', style: AppTextStyles.type14
                        .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _roundIconButton(
                          icon: Icons.remove,
                          onTap: auth.decrementHandicap,
                        ),
                        Text(
                          auth.handicapIndex.toStringAsFixed(1),
                          style: AppTextStyles.statNumber,
                        ),
                        _roundIconButton(
                          icon: Icons.add,
                          onTap: auth.incrementHandicap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayShape: SliderComponentShape.noOverlay,
                        activeTrackColor: AppColors.ctaBrightBlue,
                        inactiveTrackColor: AppColors.borderLightGray,
                        thumbColor: AppColors.ctaBrightBlue,
                      ),
                      child: Slider(
                        min: 0,
                        max: 40,
                        value: auth.handicapIndex.clamp(0, 40),
                        onChanged: (value) {
                          // snap through the +/- helpers so state stays in sync
                          final diff = value - auth.handicapIndex;
                          if (diff > 0) {
                            auth.incrementHandicap();
                          } else if (diff < 0) {
                            auth.decrementHandicap();
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PRO LEVEL', style: AppTextStyles.type11),
                        Text('BEGINNER', style: AppTextStyles.type11),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- Practice sessions per week ----
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRACTICE SESSIONS PER WEEK', style: AppTextStyles.inputLabel),
                    const SizedBox(height: 12),
                    PillSelector(
                      options: const ['1', '2', '3+'],
                      selected: auth.practiceSessionsPerWeek,
                      onSelected: auth.setPracticeSessions,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              PrimaryButton(
                label: 'Continue',
                icon: Icons.chevron_right,
                isLoading: auth.isLoading,
                onPressed: () async {
                  final success = await auth.completeOnboarding();
                  if (success && context.mounted) {
                    // Golfer profile setup complete → GolferNavbar
                    AppRoutes.goToHomeForRole(auth.selectedRole);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryNavy,
        ),
        child: Icon(icon, color: AppColors.surfaceWhite, size: 20),
      ),
    );
  }
}
