import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

/// "Student's Session Notes" white card: icon + title, paragraph, and a
/// wrap of small gray tag pills (e.g. "takeaway", "downswing", "tempo").
class SessionNotesCard extends StatelessWidget {
  const SessionNotesCard({
    super.key,
    required this.notes,
    required this.tags,
  });

  final String notes;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                "Student's Session Notes",
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notes,
            style: AppTextStyles.body.copyWith(
              fontSize: 14.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((t) => TagChip(label: t)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small rounded gray pill used for session-note tags.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pillInactive,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
