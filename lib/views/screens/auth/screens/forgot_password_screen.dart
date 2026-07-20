import 'package:flutter/material.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:provider/provider.dart';
import '../widgets/auth_app_bar.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: const AuthAppBar(title: 'Enter Email'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Forgot Password',
                        textAlign: TextAlign.center, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome Back! Please enter your details.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      hintText: 'Input your email',
                      leadingIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: auth.updateResetEmail,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Continue',
                isLoading: auth.isLoading,
                onPressed: () async {
                  final success = await auth.sendResetCode();
                  if (success && context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OtpVerificationScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
