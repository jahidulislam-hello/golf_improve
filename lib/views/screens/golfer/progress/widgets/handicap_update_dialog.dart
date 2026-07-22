import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// The "Handicap Index" popup shown when the user taps the "Update HCP"
/// button on the Handicap Progress card. Returns the new value via
/// `Navigator.pop(context, newValue)` when Update is pressed, or `null`
/// when cancelled.
class HandicapUpdateDialog extends StatefulWidget {
  const HandicapUpdateDialog({
    super.key,
    required this.initialValue,
    this.min = 0.0,
    this.max = 36.0,
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
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _increment() {
    setState(() {
      _value = (_value + widget.step).clamp(widget.min, widget.max);
    });
  }

  void _decrement() {
    setState(() {
      _value = (_value - widget.step).clamp(widget.min, widget.max);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ((_value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

    return Dialog(
      backgroundColor: AppColors.surfaceWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Handicap Index', style: AppTextStyles.sectionHeader.copyWith(fontSize: 20)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.backgroundOffWhite,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StepperButton(icon: Icons.remove, onTap: _decrement),
                      Text(
                        _value.toStringAsFixed(1),
                        style: AppTextStyles.statNumber.copyWith(fontSize: 32),
                      ),
                      _StepperButton(icon: Icons.add, onTap: _increment),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: AppColors.borderLightGray,
                      valueColor: const AlwaysStoppedAnimation(AppColors.ctaBrightBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PRO LEVEL', style: AppTextStyles.caption.copyWith(letterSpacing: 0.5)),
                Text('BEGINNER', style: AppTextStyles.caption.copyWith(letterSpacing: 0.5)),
              ],
            ),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ctaBrightBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Update', style: TextStyle(fontWeight: FontWeight.w600)),
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
