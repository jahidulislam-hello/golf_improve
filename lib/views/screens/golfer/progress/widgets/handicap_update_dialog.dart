import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// The "Handicap Index" popup shown when the user taps the "Update HCP"
/// button on the Handicap Progress card. Returns the new value via
/// `Navigator.pop(context, newValue)` when Update is pressed, or `null`
/// when cancelled. The value is only what the golfer enters.
class HandicapUpdateDialog extends StatefulWidget {
  const HandicapUpdateDialog({
    super.key,
    required this.initialValue,
    this.min = -9.9,
    this.max = 54.0,
    this.step = 0.1,
  });

  final double initialValue;
  final double min;
  final double max;
  final double step;

  @override
  State<HandicapUpdateDialog> createState() => _HandicapUpdateDialogState();
}

class _HandicapUpdateDialogState extends State<HandicapUpdateDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final start = _round(_clamp(widget.initialValue));
    _controller = TextEditingController(text: start.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() => _write(_current + widget.step);

  void _decrement() => _write(_current - widget.step);

  double get _current {
    final parsed = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    return parsed ?? widget.initialValue;
  }

  void _write(double value) {
    final next = _round(_clamp(value));
    final text = next.toStringAsFixed(1);
    setState(() {
      _error = null;
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  void _submit() {
    final parsed = double.tryParse(
      _controller.text.trim().replaceAll(',', '.'),
    );
    if (parsed == null || parsed < widget.min || parsed > widget.max) {
      setState(() {
        _error = 'Enter a handicap from ${widget.min} to ${widget.max}.';
      });
      return;
    }
    Navigator.of(context).pop(_round(parsed));
  }

  double _clamp(double value) => value.clamp(widget.min, widget.max);

  double _round(double value) => double.parse(value.toStringAsFixed(1));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: AppRadii.cardBorderRadius),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Handicap Index',
              style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your current official or playing handicap.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.backgroundOffWhite,
                borderRadius: AppRadii.cardBorderRadius,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _StepperButton(icon: Icons.remove, onTap: _decrement),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d{0,2}\.?\d{0,1}$'),
                            ),
                          ],
                          style: AppTextStyles.statNumber.copyWith(fontSize: 32),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) {
                            if (_error != null) setState(() => _error = null);
                          },
                        ),
                      ),
                      _StepperButton(icon: Icons.add, onTap: _increment),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.ctaBrightBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LOWER',
                  style: AppTextStyles.caption.copyWith(letterSpacing: 0.5),
                ),
                Text(
                  'HIGHER',
                  style: AppTextStyles.caption.copyWith(letterSpacing: 0.5),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.destructiveRed,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.backgroundOffWhite,
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.buttonBorderRadius,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ctaBrightBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.buttonBorderRadius,
                      ),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.primaryNavy,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
