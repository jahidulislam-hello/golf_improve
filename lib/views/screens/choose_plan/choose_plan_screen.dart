import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/choose_plan/choose_plan_controller.dart';
import 'package:golf_training_app/views/screens/choose_plan/subscription_plan.dart';

/// "Choose your plan" screen.
///
/// Plans come from `GET /plan/get-all`. A promo code is checked with
/// `POST /promo-code/validate`, then `POST /promo-code/redeem` activates
/// the subscription. The server records the Klaviyo redemption event.
class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key, this.controller});

  final ChoosePlanController? controller;

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  late final ChoosePlanController _controller =
      widget.controller ?? ChoosePlanController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCta() async {
    final typed = _controller.promoController.text.trim();
    if (typed.isEmpty && _controller.appliedPromo == null) {
      final message = await _controller.startTrial();
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pop(true);
      return;
    }
    final quote = _controller.appliedPromo;
    final ready = quote != null &&
        quote.code.toUpperCase() == typed.toUpperCase();
    if (!ready) {
      if (typed.isEmpty) _controller.promoFocus.requestFocus();
      await _controller.applyPromo();
      return;
    }
    final message = await _controller.redeem();
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final plan = _controller.selectedPlan;
    final quote = _controller.appliedPromo;
    final features = plan?.features ?? const <String>[];

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
                      if (_controller.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.surfaceWhite,
                            ),
                          ),
                        )
                      else if (_controller.errorMessage != null &&
                          _controller.plans.isEmpty)
                        _PlansError(
                          message: _controller.errorMessage!,
                          onRetry: _controller.loadPlans,
                        )
                      else ...[
                        for (var i = 0; i < _controller.plans.length; i++) ...[
                          _PlanCard(
                            selected: _controller.selectedIndex == i,
                            onTap: () => _controller.selectPlan(i),
                            icon: _iconFor(_controller.plans[i]),
                            title: _controller.plans[i].name,
                            subtitle: _subtitleFor(_controller.plans[i], quote),
                            price: _priceFor(_controller.plans[i], quote, i),
                            originalPrice: _originalPriceFor(
                              _controller.plans[i],
                              quote,
                              i,
                            ),
                            period: _controller.plans[i].periodLabel,
                            badgeLabel: _controller.plans[i].badgeLabel,
                          ),
                          if (i != _controller.plans.length - 1)
                            const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 20),
                        _PromoCodeCard(controller: _controller),
                        if (features.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _EverythingIncludedCard(features: features),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              _StartTrialButton(
                label: _controller.ctaLabel,
                isLoading: _controller.isValidating || _controller.isRedeeming,
                onPressed: _controller.plans.isEmpty || _controller.isBusy
                    ? null
                    : _handleCta,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _priceFor(SubscriptionPlan plan, PromoQuote? quote, int index) {
    if (quote != null &&
        quote.changesPrice &&
        index == _controller.selectedIndex) {
      return formatPlanMoney(quote.finalPrice, quote.currency);
    }
    return plan.priceLabel;
  }

  String? _originalPriceFor(SubscriptionPlan plan, PromoQuote? quote, int index) {
    if (quote == null ||
        !quote.changesPrice ||
        index != _controller.selectedIndex) {
      return null;
    }
    return formatPlanMoney(quote.originalPrice, quote.currency);
  }

  String _subtitleFor(SubscriptionPlan plan, PromoQuote? quote) {
    final description = plan.description;
    final trial = quote != null &&
            _controller.selectedPlan?.id == plan.id &&
            quote.trialDays > 0
        ? quote.trialDays
        : plan.trialDays;
    final trialLine = trial > 0
        ? '$trial-day free trial included'
        : '';
    if (description.isEmpty) return trialLine;
    if (trialLine.isEmpty) return description;
    return '$description\n$trialLine';
  }

  IconData _iconFor(SubscriptionPlan plan) {
    final type = plan.planType.toLowerCase();
    if (type.contains('stand')) return Icons.workspace_premium_outlined;
    if (plan.isBestValue) return Icons.workspace_premium_outlined;
    return Icons.monitor_heart_outlined;
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(
            Icons.chevron_left,
            color: AppColors.surfaceWhite,
            size: 28,
          ),
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

class _PromoCodeCard extends StatelessWidget {
  const _PromoCodeCard({required this.controller});

  final ChoosePlanController controller;

  @override
  Widget build(BuildContext context) {
    final message = controller.promoMessage;
    final isError = controller.promoMessageIsError;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withOpacity(0.04),
        borderRadius: AppRadii.cardBorderRadius,
        border: Border.all(color: AppColors.surfaceWhite.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROMO CODE',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.surfaceWhite.withOpacity(0.45),
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.promoController,
                  focusNode: controller.promoFocus,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.surfaceWhite,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                  cursorColor: AppColors.surfaceWhite,
                  decoration: InputDecoration(
                    hintText: 'LAUNCH50',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.surfaceWhite.withOpacity(0.35),
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceWhite.withOpacity(0.06),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.surfaceWhite.withOpacity(0.12),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.surfaceWhite.withOpacity(0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.ctaBrightBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => controller.applyPromo(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isBusy ? null : controller.applyPromo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ctaBrightBlue,
                    disabledBackgroundColor:
                        AppColors.ctaBrightBlue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: controller.isValidating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surfaceWhite,
                          ),
                        )
                      : Text(
                          'Apply',
                          style: AppTextStyles.buttonLabel.copyWith(fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
          if (message != null && message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: isError ? AppColors.destructiveRed : AppColors.successGreen,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlansError extends StatelessWidget {
  const _PlansError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.surfaceWhite.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Try again',
              style: AppTextStyles.buttonLabel.copyWith(
                color: AppColors.surfaceWhite,
              ),
            ),
          ),
        ],
      ),
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
  final String? originalPrice;
  final String period;
  final String? badgeLabel;

  const _PlanCard({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.originalPrice,
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
                          right: badgeLabel != null ? 110 : 0,
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
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.surfaceWhite.withOpacity(0.55),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (originalPrice != null) ...[
                  Text(
                    originalPrice!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.surfaceWhite.withOpacity(0.45),
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.surfaceWhite.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ctaBrightBlue,
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Text(
        label,
        style: AppTextStyles.pillLabel.copyWith(
          color: AppColors.surfaceWhite,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Translucent card listing everything included on the selected plan.
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

class _StartTrialButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  const _StartTrialButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ctaBrightBlue,
            disabledBackgroundColor: AppColors.ctaBrightBlue.withOpacity(0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.surfaceWhite,
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.buttonLabel.copyWith(fontSize: 17),
                ),
        ),
      ),
    );
  }
}
