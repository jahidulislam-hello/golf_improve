import 'package:flutter/material.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/helpers/routes.dart';
import 'package:golf_training_app/views/screens/auth/screens/tell_us_about_your.dart';
import 'package:golf_training_app/views/screens/onboarding/role_selection/role_selection_controller.dart';
import 'package:provider/provider.dart';
import '../widgets/auth_app_bar.dart';
import '../widgets/auth_card.dart';
import '../widgets/primary_button.dart';
import 'package:golf_training_app/core/app_radii.dart';

void _showAuthError(BuildContext context, AuthController auth) {
  final message = auth.errorMessage;
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class SignUpOtpVerificationScreen extends StatefulWidget {
  const SignUpOtpVerificationScreen({super.key});

  @override
  State<SignUpOtpVerificationScreen> createState() =>
      _SignUpOtpVerificationScreenState();
}

class _SignUpOtpVerificationScreenState
    extends State<SignUpOtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final email = auth.signUpEmail.trim().isNotEmpty
        ? auth.signUpEmail.trim()
        : 'your email';

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: const AuthAppBar(title: 'Verification Code'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthCard(
                child: Column(
                  children: [
                    Text('OTP Code Verification',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.cardTitle),
                    const SizedBox(height: 8),
                    Text(
                      'We have sent an OTP code to your email $email.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 44,
                          height: 56,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: AppTextStyles.type20
                                .copyWith(fontWeight: FontWeight.w700),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.surfaceWhite,
                              hintText: '-',
                              border: OutlineInputBorder(
                                borderRadius: AppRadii.buttonBorderRadius,
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              auth.updateOtpDigit(index, value);
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Didn't get the code?",
                            style: AppTextStyles.type14),
                        GestureDetector(
                          onTap: () async {
                            final success = await auth.resendOtp();
                            if (!context.mounted) return;
                            for (final c in _controllers) {
                              c.clear();
                            }
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('OTP resent successfully.'),
                                ),
                              );
                            } else {
                              _showAuthError(context, auth);
                            }
                          },
                          child: Text('Resend', style: AppTextStyles.linkText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Verify',
                isLoading: auth.isLoading,
                onPressed: () async {
                  final success = await auth.verifyOtp();
                  if (!context.mounted) return;
                  if (!success) {
                    _showAuthError(context, auth);
                    return;
                  }

                  // Coach → home. Golfer → profile setup.
                  if (auth.selectedRole == UserRole.coach) {
                    AppRoutes.goToHomeForRole(UserRole.coach);
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileSetUpScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
