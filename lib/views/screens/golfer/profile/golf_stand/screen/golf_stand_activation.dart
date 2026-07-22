import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/profile/golf_stand/activation_code_filled.dart';
import 'package:golf_training_app/views/screens/golfer/profile/golf_stand/app_header_bar.dart';
import 'package:golf_training_app/views/screens/golfer/profile/golf_stand/screen/golf_stand_activation_controller.dart';
import 'package:golf_training_app/views/screens/golfer/profile/golf_stand/hero_banner.dart';
import 'package:golf_training_app/views/screens/golfer/profile/golf_stand/info_callout_card.dart';
import 'package:golf_training_app/views/screens/golfer/profile/golf_stand/primary_gradient_button.dart';
import 'package:golf_training_app/views/screens/golfer/profile/golf_stand/scan_qr_button.dart';

/// "Golf Stand" activation screen: hero banner, activation-code field,
/// QR scan alternative, a help callout, and the bottom Activate button.
class GolfStandActivationScreen extends StatefulWidget {
  const GolfStandActivationScreen({super.key, this.controller});

  final GolfStandActivationController? controller;

  @override
  State<GolfStandActivationScreen> createState() =>
      _GolfStandActivationScreenState();
}

class _GolfStandActivationScreenState
    extends State<GolfStandActivationScreen> {
  late final GolfStandActivationController _controller =
      widget.controller ?? GolfStandActivationController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleScanQr() {
    // Hook up a real scanner package (e.g. mobile_scanner) here, then
    // call _controller.applyScannedCode(result) with the decoded value.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Open QR scanner'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _handleActivate() async {
    final success = await _controller.activate();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Golf Stand activated!'),
          duration: Duration(milliseconds: 900),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: AppHeaderBar(
                title: 'Golf Stand',
                subtitle: 'Activate your Golf Stand',
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const GolfStandHeroBanner(
                    imageUrl:
                    'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=900',
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect Your Golf Stand',
                          style: AppTextStyles.sectionHeader.copyWith(
                            fontSize: 21,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Enter the activation code included inside your '
                              'Golf Stand package. Once verified, your stand '
                              'will be linked permanently to your GolfImprove '
                              'account.',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14.5,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ActivationCodeField(
                          controller: _controller.codeController,
                          errorText: _controller.status ==
                              ActivationStatus.error
                              ? _controller.errorMessage
                              : null,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'or',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ScanQrButton(onTap: _handleScanQr),
                        const SizedBox(height: 18),
                        const InfoCalloutCard(
                          title: 'Where is my code?',
                          body: 'Your activation code is printed inside the '
                              'Golf Stand package.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: PrimaryGradientButton(
                  label: 'Activate Golf Stand',
                  isLoading: _controller.isSubmitting,
                  onPressed: _handleActivate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}