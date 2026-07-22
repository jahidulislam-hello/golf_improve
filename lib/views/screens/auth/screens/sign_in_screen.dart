import 'package:flutter/material.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/helpers/routes.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_text_field.dart';
import '../widgets/golf_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
              Text('Welcome back.',
                  textAlign: TextAlign.center, style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your training.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              SecondaryButton.google(onPressed: () {}),
              const SizedBox(height: 14),
              SecondaryButton.apple(onPressed: () {}),
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
              AuthTextField(
                label: 'EMAIL',
                hintText: 'alex@example.com',
                keyboardType: TextInputType.emailAddress,
                onChanged: auth.updateSignInEmail,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'PASSWORD',
                hintText: '••••••••',
                obscureText: auth.obscureSignInPassword,
                onToggleObscure: auth.toggleSignInPasswordVisibility,
                onChanged: auth.updateSignInPassword,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  ),
                  child: Text('Forgot password?', style: AppTextStyles.linkText),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Sign In',
                isLoading: auth.isLoading,
                onPressed: () async {
                  final success = await auth.signIn();
                  if (success && context.mounted) {
                    // Coach → CoachNavbar, Golfer → GolferNavbar
                    AppRoutes.goToHomeForRole(auth.selectedRole);
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: AppTextStyles.type14),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: Text('Sign Up',
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
