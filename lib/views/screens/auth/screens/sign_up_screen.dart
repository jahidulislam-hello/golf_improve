import 'package:flutter/material.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/helpers/routes.dart';
import 'package:golf_training_app/views/screens/auth/screens/sign_up_otp_verification_screen.dart';
import 'package:golf_training_app/views/screens/onboarding/role_selection/role_selection_controller.dart';
import 'package:provider/provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/golf_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'sign_in_screen.dart';

void _showAuthError(BuildContext context, AuthController auth) {
  final message = auth.errorMessage;
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GolfLogo(),
              const SizedBox(height: 32),
              Text('Create account.',
                  textAlign: TextAlign.center, style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Text(
                'Start improving your golf today.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              SecondaryButton.google(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final success = await auth.signInWithGoogle();
                        if (!context.mounted) return;
                        if (!success) {
                          _showAuthError(context, auth);
                          return;
                        }
                        AppRoutes.goToHomeForRole(
                          auth.selectedRole ?? UserRole.golfer,
                        );
                      },
              ),
              const SizedBox(height: 14),
              SecondaryButton.apple(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Apple Sign-In is available on iPhone. On Android, use Google or email.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.borderLightGray)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: AppTextStyles.type13),
                  ),
                  const Expanded(child: Divider(color: AppColors.borderLightGray)),
                ],
              ),
              const SizedBox(height: 22),
              // Full name removed from register (docs v2: email + password only).
              // Collect name later in profile setup.
              // AuthTextField(
              //   label: 'FULL NAME',
              //   hintText: 'Alex Thompson',
              //   onChanged: auth.updateFullName,
              // ),
              // const SizedBox(height: 14),
              AuthTextField(
                label: 'EMAIL',
                hintText: 'alex@example.com',
                keyboardType: TextInputType.emailAddress,
                onChanged: auth.updateSignUpEmail,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'PASSWORD',
                hintText: '••••••••',
                obscureText: auth.obscureSignUpPassword,
                onToggleObscure: auth.toggleSignUpPasswordVisibility,
                onChanged: auth.updateSignUpPassword,
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Create Account',
                isLoading: auth.isLoading,
                onPressed: () async {
                  final success = await auth.signUp();
                  if (!context.mounted) return;
                  if (!success) {
                    _showAuthError(context, auth);
                    return;
                  }

                  // Both roles → OTP verification after register API
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const SignUpOtpVerificationScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: AppTextStyles.type14),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    ),
                    child: Text('Sign In',
                        style: AppTextStyles.linkText.copyWith(fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
