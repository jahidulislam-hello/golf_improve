import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// Coach Feedback screen.
///
/// The "Coach's View on AI Analysis" card at the bottom is collapsible.
/// Tapping it expands in place (screen 1) to reveal the three AI-observation
/// rows shown in screen 2 — nothing navigates away, it's the same screen
/// growing taller.
class CoachFeedbackScreen extends StatefulWidget {
  const CoachFeedbackScreen({super.key});

  @override
  State<CoachFeedbackScreen> createState() => _CoachFeedbackScreenState();
}

class _CoachFeedbackScreenState extends State<CoachFeedbackScreen> {
  bool _aiAnalysisExpanded = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CoachHeaderCard(),
                    const SizedBox(height: 16),
                    _VideoThumbnail(),
                    const SizedBox(height: 16),
                    _CoachingFeedbackCard(),
                    const SizedBox(height: 16),
                    _RecommendedDrillCard(),
                    const SizedBox(height: 16),
                    _PracticePlanCard(),
                    const SizedBox(height: 16),
                    _AiAnalysisCard(
                      expanded: _aiAnalysisExpanded,
                      onTap: () {
                        setState(() => _aiAnalysisExpanded = !_aiAnalysisExpanded);
                      },
                    ),
                  ],
                ),
              ),
            ),
            _MarkPracticeDoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Coach Feedback', style: AppTextStyles.sectionHeader),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: AppColors.successGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Professional review · James Keller',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White card at the top: avatar, coach name, credentials line.
class _CoachHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primaryNavy,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('James Keller',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'PGA Certified · Driver · Face On · Today\n11:30 AM',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Swing video thumbnail with "Coach Annotated" pill and frame label.
class _VideoThumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.cardBorderRadius,
      child: AspectRatio(
        aspectRatio: 16 / 10.5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder for the golfer video frame / thumbnail image.
            Container(color: AppColors.textSecondary.withOpacity(0.2)),
            // Coach annotation line drawings would be layered here as a
            // CustomPaint / overlay image in the real implementation.
            Positioned(
              top: 12,
              right: 12,
              child: _Pill(
                label: 'Coach Annotated',
                background: AppColors.primaryNavy.withOpacity(0.85),
                textColor: AppColors.surfaceWhite,
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: _Pill(
                label: 'Frame 0:04 — Transition point',
                background: Colors.black.withOpacity(0.55),
                textColor: AppColors.surfaceWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Coaching Feedback" card with the PROFESSIONAL badge and quoted notes.
class _CoachingFeedbackCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Coaching Feedback',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              ),
              _Badge(
                label: 'PROFESSIONAL',
                background: AppColors.insightPositiveIconBg,
                textColor: AppColors.insightPositiveIcon,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"Great effort, Alex. I can see the transition issue clearly '
            'in frame 0:04. Your upper body is firing before your hips have '
            'cleared — this creates an out-to-in path which is why you\'re '
            'seeing pushes and slices.\n\n'
            'The good news: your setup and takeaway are solid. The problem '
            'starts at the top of the backswing. Focus on the feeling of '
            'your left hip turning towards the target before your right '
            'shoulder begins to drop."',
            style: AppTextStyles.body.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// "Recommended Drill" card with the highlighted lavender drill box.
class _RecommendedDrillCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.golf_course_outlined,
                  size: 18, color: AppColors.quickActionAiIcon),
              const SizedBox(width: 8),
              Text('Recommended Drill',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.quickActionAiBg,
              borderRadius: AppRadii.cardBorderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hip Lead Drill — 10 reps',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.quickActionAiIcon,
                  ),
                ),
                const SizedBox(height: 8),
                _NumberedLine(number: 1, text: 'Take your normal address position.'),
                _NumberedLine(number: 2, text: 'Place a club across your hips, parallel to the ground.'),
                _NumberedLine(
                    number: 3,
                    text: 'On the downswing, initiate by pointing the grip end of the club towards the target first.'),
                _NumberedLine(
                    number: 4,
                    text: 'Your right shoulder should NOT drop until the club grip has moved at least 10 cm.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedLine extends StatelessWidget {
  final int number;
  final String text;
  const _NumberedLine({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '$number. $text',
        style: AppTextStyles.body.copyWith(height: 1.4),
      ),
    );
  }
}

/// "2-Week Practice Plan" card with the three day-range rows.
class _PracticePlanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text('2-Week Practice Plan',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          _PlanRow(
            icon: Icons.golf_course_outlined,
            days: 'Days 1–3',
            description: 'Hip Lead Drill only — 50% speed, 3 sets of 10',
            showDivider: true,
          ),
          _PlanRow(
            icon: Icons.camera_alt_outlined,
            days: 'Days 4–7',
            description: 'Add full swings. Film face-on and compare transition frame',
            showDivider: true,
          ),
          _PlanRow(
            icon: Icons.place_outlined,
            days: 'Days 8–14',
            description: 'On-course practice. Focus on hip initiation under pressure',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final IconData icon;
  final String days;
  final String description;
  final bool showDivider;

  const _PlanRow({
    required this.icon,
    required this.days,
    required this.description,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(days,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(description, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.borderCard),
      ],
    );
  }
}

/// The collapsible "Coach's View on AI Analysis" card.
///
/// Collapsed = header row only (screen 1's default state).
/// Expanded  = header row + the three observation rows from screen 2,
/// rendered in an AnimatedSize so the card grows smoothly in place.
class _AiAnalysisCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _AiAnalysisCard({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: AppRadii.cardBorderRadius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.betaBadgeBg.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.public,
                        size: 18, color: AppColors.betaBadgeText),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "Coach's View on AI Analysis",
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _Badge(
                              label: 'BETA',
                              background: AppColors.betaBadgeBg,
                              textColor: AppColors.betaBadgeText,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('James Keller reviewed the AI observations',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: const [
                        _AiObservationRow(
                          agreed: true,
                          title: 'Head movement — Agreed',
                          verdict: 'Agreed',
                          description:
                              'Confirmed — the head shift is a secondary effect of the hip issue. Fix the hips and this will self-correct.',
                        ),
                        SizedBox(height: 10),
                        _AiObservationRow(
                          agreed: false,
                          title: 'Lead leg at impact — Corrected',
                          verdict: 'Corrected',
                          description:
                              'Partially correct. The bent leg is mostly caused by the early upper body — not a standalone issue.',
                        ),
                        SizedBox(height: 10),
                        _AiObservationRow(
                          agreed: true,
                          title: 'Takeaway path — Agreed',
                          verdict: 'Agreed',
                          description:
                              'Takeaway looks fine to me as well. No changes needed here.',
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// One observation row inside the expanded AI Analysis card — green for
/// "Agreed", amber for "Corrected", matching screen 2 exactly.
class _AiObservationRow extends StatelessWidget {
  final bool agreed;
  final String title;
  final String verdict;
  final String description;

  const _AiObservationRow({
    required this.agreed,
    required this.title,
    required this.verdict,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = agreed ? AppColors.insightPositiveIconBg : AppColors.warningBg;
    final Color border = agreed ? AppColors.insightPositiveIconBg : AppColors.warningBorder;
    final Color iconColor = agreed ? AppColors.insightPositiveIcon : AppColors.warningText;
    final Color titleColor = agreed ? AppColors.insightPositiveIcon : AppColors.warningText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            agreed ? Icons.thumb_up_alt_outlined : Icons.thumb_down_alt_outlined,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.85),
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

/// Fixed bottom "Mark Practice as Done" CTA button.
class _MarkPracticeDoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: AppColors.backgroundOffWhite,
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ctaBrightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.buttonBorderRadius,
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check, size: 18, color: AppColors.surfaceWhite),
              const SizedBox(width: 8),
              Text('Mark Practice as Done', style: AppTextStyles.buttonLabel),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Shared small pieces =====

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _CardShell({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const _Pill({required this.label, required this.background, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Text(
        label,
        style: AppTextStyles.pillLabel.copyWith(color: textColor, fontSize: 11),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const _Badge({required this.label, required this.background, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: textColor,
        ),
      ),
    );
  }
}
