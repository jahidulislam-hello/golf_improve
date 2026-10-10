import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../models/models.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// Small uppercase gray label used above filter rows ("CLUB", "ANGLE").
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.type11.copyWith(
        letterSpacing: 1.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// A horizontally scrollable row of pill-shaped filter chips.
/// Used for Club and Angle filters on the Swing Library screen.
class FilterChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  /// Background used for the selected chip. Defaults to primary navy.
  final Color selectedColor;

  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.selectedColor = AppColors.primaryNavy,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;
          return GestureDetector(
            onTap: () => onSelect(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : AppColors.surfaceWhite,
                borderRadius: AppRadii.cardBorderRadius,
                border: isSelected ? null : AppRadii.cardBorder,
              ),
              child: Text(
                option,
                style: AppTextStyles.type14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.surfaceWhite
                      : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Dark navy stat card split into two halves by a thin divider.
/// e.g. "847 Total Swings" | "23 Shared w/ Coach".
class StatSplitCard extends StatelessWidget {
  final int leftValue;
  final String leftLabel;
  final int rightValue;
  final String rightLabel;

  const StatSplitCard({
    super.key,
    required this.leftValue,
    required this.leftLabel,
    required this.rightValue,
    required this.rightLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: AppRadii.cardBorderRadius,
      ),
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(value: leftValue, label: leftLabel),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white.withOpacity(0.15),
          ),
          Expanded(
            child: _StatColumn(value: rightValue, label: rightLabel),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: AppTextStyles.statNumber.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.65),
          ),
        ),
      ],
    );
  }
}

/// Grid card thumbnail used in the Swing Library. Shows a network thumbnail
/// (or placeholder), a centered play button, an optional match-percentage
/// pill, and the club/angle caption below.
class SwingThumbnailCard extends StatelessWidget {
  final SwingVideo swing;
  final VoidCallback onTap;

  const SwingThumbnailCard({
    super.key,
    required this.swing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = swing.thumbnailUrl;
    final hasNetworkThumb = thumb.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: AppRadii.cardBorderRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasNetworkThumb)
                    Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ThumbPlaceholder(),
                    )
                  else
                    const _ThumbPlaceholder(),
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  if (swing.matchPercent != null)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${swing.matchPercent}%',
                          style: AppTextStyles.type11.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            swing.club,
            style: AppTextStyles.type14.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            swing.angle,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F7942), Color(0xFF1E3A2B)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.golf_course, color: Colors.white24, size: 40),
      ),
    );
  }
}

/// A circular icon button with a translucent/white background — used for
/// back buttons, share buttons, and video overlay controls.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color background;
  final Color iconColor;
  final double size;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.background = AppColors.surfaceWhite,
    this.iconColor = AppColors.textPrimary,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}

/// Full-width solid blue call-to-action button used across screens
/// (e.g. "AI Golf Coach", "Send to James Keller", "Send to Coach").
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = AppColors.ctaBrightBlue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: AppRadii.buttonBorderRadius,
      child: InkWell(
        borderRadius: AppRadii.buttonBorderRadius,
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.type16.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yellow/orange warning banner: "AI suggestions are experimental...".
class WarningBanner extends StatelessWidget {
  final String text;
  const WarningBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: AppRadii.cardBorderRadius,
        border: Border.all(
          color: AppColors.warningBorder,
          width: AppRadii.cardBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.warningText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.type13.copyWith(
                color: AppColors.warningText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One coaching-insight card ("Head movement", "Lead leg at impact", etc.)
class InsightCard extends StatelessWidget {
  final SwingInsight insight;
  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: insight.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(insight.icon, size: 17, color: insight.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: AppTextStyles.type16.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: AppTextStyles.type14.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The light-blue "Your pro previously said" quote card with an
/// "Improved" confirmation pill underneath.
class ProFeedbackCard extends StatelessWidget {
  final String initials;
  final String quote;
  final String improvementNote;

  const ProFeedbackCard({
    super.key,
    required this.initials,
    required this.quote,
    required this.improvementNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.proFeedbackBg,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: AppColors.primaryNavy,
                child: Text(
                  initials,
                  style: AppTextStyles.type10.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'YOUR PRO PREVIOUSLY SAID',
                style: AppTextStyles.type11.copyWith(
                  color: AppColors.ctaBrightBlue,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"$quote"',
            style: AppTextStyles.type14.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.insightPositiveIconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.insightPositiveIcon,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    improvementNote,
                    style: AppTextStyles.type13.copyWith(
                      color: AppColors.insightPositiveIcon,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One numbered row inside "3 Things to Try".
class NumberedStepTile extends StatelessWidget {
  final int number;
  final String text;
  const NumberedStepTile({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryNavy,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: AppTextStyles.type11.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.type14.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// One row on the "What to include" list on Share With Coach — either a
/// fixed checkmark (always-included) or a toggle switch.
class ShareIncludeTile extends StatelessWidget {
  final ShareIncludeItem item;
  final VoidCallback onToggle;

  const ShareIncludeTile({
    super.key,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 18, color: item.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.type16.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE7B5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.badge!,
                          style: AppTextStyles.type9.copyWith(
                            color: const Color(0xFF8A6D1D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (item.alwaysIncluded)
            const Icon(Icons.check_circle, color: Color(0xFF2E9E5B), size: 22)
          else
            Switch(
              value: item.isOn,
              activeColor: AppColors.primaryNavy,
              onChanged: (_) => onToggle(),
            ),
        ],
      ),
    );
  }
}

/// One chat bubble on the AI Golf Coach chat screen.
class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  const ChatBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppColors.ctaBrightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.ctaBrightBlue
                    : AppColors.chatBubbleAiBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: AppTextStyles.type14.copyWith(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick-reply pill used under the chat, e.g. "Yes, fairly often".
class QuickReplyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const QuickReplyChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.ctaBrightBlue : AppColors.chatBubbleAiBg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: AppTextStyles.type14.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
