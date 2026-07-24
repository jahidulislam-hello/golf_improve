import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// "Choose your plan" screen.
///
/// Two selectable plan cards (tap to switch selection — the selected card
/// gets the bright-blue glow border seen on "Golfimprove Stand User" in
/// the mock), a translucent "Everything Included" checklist card, and a
/// fixed CTA button at the bottom.
class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key});

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  int _selectedIndex = 0;

  static const _features = [
    'Unlimited swing library',
    'Full AI analysis toolkit',
    'Side-by-side comparison',
    'Cloud backup & sync',
    'Share with Pro',
    'Basic AI fault detection',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroNavyGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAppBar(context),
                      const SizedBox(height: 20),
                      _PlanCard(
                        selected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                        icon: Icons.workspace_premium_outlined,
                        title: 'Golfimprove Stand User',
                        subtitle:
                            'Requires a GolfImprove Stand and a valid activation code',
                        price: '€19.95',
                        period: '/month',
                        badgeLabel: 'BEST VALUE',
                      ),
                      const SizedBox(height: 16),
                      _PlanCard(
                        selected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                        icon: Icons.monitor_heart_outlined,
                        title: 'Standard',
                        subtitle: 'No Golf Stand required',
                        price: '€29.95',
                        period: '/Annual',
                        badgeLabel: null,
                      ),
                      const SizedBox(height: 20),
                      _EverythingIncludedCard(features: _features),
                    ],
                  ),
                ),
              ),
              _StartTrialButton(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.chevron_left,
              color: AppColors.surfaceWhite, size: 28),
        ),
        const SizedBox(width: 12),
        Text(
          'Choose your plan',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.surfaceWhite,
            fontSize: 28,
          ),
        ),
      ],
    );
  }
}

/// One selectable plan card. Selected state gets a bright-blue border,
/// a subtle blue-tinted fill, and a soft glow — matching the mock.
class _PlanCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final String period;
  final String? badgeLabel;

  const _PlanCard({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.ctaBrightBlue.withOpacity(0.16)
              : AppColors.surfaceWhite.withOpacity(0.04),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? AppColors.ctaBrightBlue
                : AppColors.surfaceWhite.withOpacity(0.12),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.ctaBrightBlue.withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (badgeLabel != null)
              Positioned(
                top: 0,
                right: 0,
                child: _BestValueBadge(label: badgeLabel!),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.ctaBrightBlue.withOpacity(0.25)
                            : AppColors.surfaceWhite.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: selected
                            ? AppColors.wellcome
                            : AppColors.surfaceWhite.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: badgeLabel != null ? 78 : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.surfaceWhite,
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.surfaceWhite.withOpacity(0.55),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: AppTextStyles.statNumber.copyWith(
                          color: AppColors.surfaceWhite,
                          fontSize: 34,
                        ),
                      ),
                      TextSpan(
                        text: period,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.surfaceWhite.withOpacity(0.55),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BestValueBadge extends StatelessWidget {
  final String label;
  const _BestValueBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ctaBrightBlue,
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Text(
        label,
        style: AppTextStyles.pillLabel.copyWith(
          color: AppColors.surfaceWhite,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Translucent card listing everything included across plans.
class _EverythingIncludedCard extends StatelessWidget {
  final List<String> features;
  const _EverythingIncludedCard({required this.features});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withOpacity(0.04),
        borderRadius: AppRadii.cardBorderRadius,
        border: Border.all(color: AppColors.surfaceWhite.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EVERYTHING INCLUDED',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.surfaceWhite.withOpacity(0.45),
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          for (int i = 0; i < features.length; i++) ...[
            _FeatureRow(label: features[i]),
            if (i != features.length - 1) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  const _FeatureRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.ctaBrightBlue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: AppColors.surfaceWhite),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.surfaceWhite.withOpacity(0.85),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fixed bottom CTA — "Start 7-Day Free Trial".
class _StartTrialButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _StartTrialButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ctaBrightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: Text(
            'Start 7-Day Free Trial',
            style: AppTextStyles.buttonLabel.copyWith(fontSize: 17),
          ),
        ),
      ),
    );
  }
}
