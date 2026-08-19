import 'package:flutter/material.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:provider/provider.dart';
import '../widgets/auth_app_bar.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';
import 'sign_in_screen.dart';

void _showAuthError(BuildContext context, AuthController auth) {
  final message = auth.errorMessage;
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: const AuthAppBar(title: 'Reset Password'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Reset Password',
                        textAlign: TextAlign.center, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 20),
                    AuthTextField(
                      hintText: 'Enter New Password',
                      leadingIcon: Icons.key_outlined,
                      obscureText: auth.obscureNewPassword,
                      onToggleObscure: auth.toggleNewPasswordVisibility,
                      onChanged: auth.updateNewPassword,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      hintText: 'Confirm New Password',
                      leadingIcon: Icons.key_outlined,
                      obscureText: auth.obscureConfirmPassword,
                      onToggleObscure: auth.toggleConfirmPasswordVisibility,
                      onChanged: auth.updateConfirmPassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Reset Password',
                icon: null,
                isLoading: auth.isLoading,
                onPressed: () async {
                  final success = await auth.resetPassword();
                  if (!context.mounted) return;
                  if (!success) {
                    _showAuthError(context, auth);
                    return;
                  }
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
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
