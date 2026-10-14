import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// One card in the "Practice Plan Builder": a blue "Days X-Y" pill, a
/// delete button, and an editable description field on a gray backdrop.
class PracticePlanDayCard extends StatefulWidget {
  const PracticePlanDayCard({
    super.key,
    required this.dayRangeLabel,
    required this.initialDescription,
    required this.onDescriptionChanged,
    required this.onDelete,
  });

  final String dayRangeLabel;
  final String initialDescription;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onDelete;

  @override
  State<PracticePlanDayCard> createState() => _PracticePlanDayCardState();
}

class _PracticePlanDayCardState extends State<PracticePlanDayCard> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialDescription);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.ctaBrightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.dayRangeLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.surfaceWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: widget.onDelete,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.destructiveRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pillInactive,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _controller,
              onChanged: widget.onDescriptionChanged,
              maxLines: null,
              style: AppTextStyles.inputValue.copyWith(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Short range session for the one main correction',
                hintStyle: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
