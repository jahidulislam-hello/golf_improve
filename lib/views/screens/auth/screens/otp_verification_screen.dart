import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:provider/provider.dart';
import '../widgets/auth_app_bar.dart';
import '../widgets/auth_card.dart';
import '../widgets/primary_button.dart';
import 'reset_password_screen.dart';

void _showAuthError(BuildContext context, AuthController auth) {
  final message = auth.errorMessage;
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _resendTicker;

  @override
  void initState() {
    super.initState();
    _resendTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final auth = context.read<AuthController>();
      if (auth.otpResendSecondsLeft > 0) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _resendTicker?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _syncControllersFromAuth(AuthController auth) {
    for (var i = 0; i < 6; i++) {
      final digit = i < auth.otpDigits.length ? auth.otpDigits[i] : '';
      if (_controllers[i].text != digit) {
        _controllers[i].text = digit;
      }
    }
  }

  void _onDigitChanged(AuthController auth, int index, String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 1) {
      auth.applyOtpCode(digitsOnly);
      _syncControllersFromAuth(auth);
      final focusAt = (digitsOnly.length >= 6 ? 5 : digitsOnly.length)
          .clamp(0, 5);
      _focusNodes[focusAt].requestFocus();
      return;
    }

    auth.updateOtpDigit(index, digitsOnly);
    if (digitsOnly.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (digitsOnly.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resend(AuthController auth) async {
    final success = await auth.resendOtp();
    if (!mounted) return;
    for (final c in _controllers) {
      c.clear();
    }
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully.')),
      );
      setState(() {});
    } else {
      _showAuthError(context, auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final email = auth.resetEmail.trim().isNotEmpty
        ? auth.resetEmail.trim()
        : 'your email';
    final resendLeft = auth.otpResendSecondsLeft;

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
                    Text(
                      'OTP Code Verification',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.cardTitle,
                    ),
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
                            textInputAction: index == 5
                                ? TextInputAction.done
                                : TextInputAction.next,
                            style: AppTextStyles.type20
                                .copyWith(fontWeight: FontWeight.w700),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
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
                            onChanged: (value) =>
                                _onDigitChanged(auth, index, value),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Didn't get the code?",
                          style: AppTextStyles.type14,
                        ),
                        GestureDetector(
                          onTap: auth.isLoading || !auth.canResendOtp
                              ? null
                              : () => _resend(auth),
                          child: Text(
                            resendLeft > 0
                                ? 'Resend (${resendLeft}s)'
                                : 'Resend',
                            style: AppTextStyles.linkText.copyWith(
                              color: auth.canResendOtp && !auth.isLoading
                                  ? AppColors.ctaBrightBlue
                                  : AppColors.textSecondary,
                            ),
                          ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP verified. Set your new password.'),
                    ),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ResetPasswordScreen(),
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
