import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// Coach Feedback screen.
///
/// One main correction, the coach's note, a drill created from that note,
/// and a 2-week plan. After the golfer starts the plan, each range session
/// can be marked complete.
class CoachFeedbackScreen extends StatefulWidget {
  const CoachFeedbackScreen({super.key});

  @override
  State<CoachFeedbackScreen> createState() => _CoachFeedbackScreenState();
}

class _PracticeSession {
  _PracticeSession({
    required this.icon,
    required this.days,
    required this.description,
  });

  final IconData icon;
  final String days;
  final String description;
  bool completed = false;
}

class _CoachFeedbackScreenState extends State<CoachFeedbackScreen> {
  bool _planViewExpanded = false;
  bool _planStarted = false;
  final List<_PracticeSession> _sessions = [
    _PracticeSession(
      icon: Icons.golf_course_outlined,
      days: 'Days 1–3',
      description: 'Short range session. Hip-lead drill only, half speed, 3 sets of 8.',
    ),
    _PracticeSession(
      icon: Icons.sports_golf_outlined,
      days: 'Days 4–7',
      description: 'Short range session. Same drill, then a few easy swings at your normal speed.',
    ),
    _PracticeSession(
      icon: Icons.place_outlined,
      days: 'Days 8–14',
      description: 'Short range session. Stay with this one correction and stop when the feeling is clear.',
    ),
  ];

  int get _completedCount =>
      _sessions.where((session) => session.completed).length;

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
                    const _RecommendedDrillCard(),
                    const SizedBox(height: 16),
                    _PracticePlanCard(
                      sessions: _sessions,
                      started: _planStarted,
                      completedCount: _completedCount,
                      onToggle: (index) {
                        setState(() {
                          _sessions[index].completed = !_sessions[index].completed;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _PracticePlanReviewCard(
                      expanded: _planViewExpanded,
                      onTap: () {
                        setState(() => _planViewExpanded = !_planViewExpanded);
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (!_planStarted)
              _StartPracticePlanButton(
                onPressed: () => setState(() => _planStarted = true),
              )
            else
              _PlanProgressBar(
                completed: _completedCount,
                total: _sessions.length,
              ),
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
            'Main correction',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start the downswing with your hips before your shoulders.',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"Great effort, Alex. Keep this as the only change for now: '
            'feel your hips turn toward the target before your shoulders '
            'follow. Use that feeling in short range sessions."',
            style: AppTextStyles.body.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// "Recommended Drill" card with the highlighted lavender drill box.
class _RecommendedDrillCard extends StatelessWidget {
  const _RecommendedDrillCard();

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
              Text('AI Recommended Drill',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Created from your coach's feedback.",
            style: AppTextStyles.caption,
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

/// "2-Week Practice Plan" built around one correction and short range sessions.
class _PracticePlanCard extends StatelessWidget {
  const _PracticePlanCard({
    required this.sessions,
    required this.started,
    required this.completedCount,
    required this.onToggle,
  });

  final List<_PracticeSession> sessions;
  final bool started;
  final int completedCount;
  final ValueChanged<int> onToggle;

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
              Expanded(
                child: Text('2-Week Practice Plan',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (started) ...[
            const SizedBox(height: 8),
            Text(
              '$completedCount of ${sessions.length} sessions completed',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.successGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: sessions.isEmpty ? 0 : completedCount / sessions.length,
                minHeight: 6,
                backgroundColor: AppColors.borderCard,
                color: AppColors.successGreen,
              ),
            ),
          ],
          const SizedBox(height: 4),
          for (var i = 0; i < sessions.length; i++)
            _PlanRow(
              icon: sessions[i].icon,
              days: sessions[i].days,
              description: sessions[i].description,
              showDivider: i < sessions.length - 1,
              showComplete: started,
              completed: sessions[i].completed,
              onToggle: () => onToggle(i),
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
  final bool showComplete;
  final bool completed;
  final VoidCallback? onToggle;

  const _PlanRow({
    required this.icon,
    required this.days,
    required this.description,
    required this.showDivider,
    this.showComplete = false,
    this.completed = false,
    this.onToggle,
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
              if (showComplete)
                InkWell(
                  onTap: onToggle,
                  customBorder: const CircleBorder(),
                  child: Icon(
                    completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 22,
                    color: completed
                        ? AppColors.successGreen
                        : AppColors.textSecondary,
                  ),
                )
              else
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


/// Collapsible coach review of the drill and plan.
class _PracticePlanReviewCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _PracticePlanReviewCard({required this.expanded, required this.onTap});

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
                        Text(
                          "Coach's View on Your Practice Plan",
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'James reviewed your recommended drill and practice plan.',
                          style: AppTextStyles.caption,
                        ),
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
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        _PlanAdjustment(
                          text:
                              'Use 8 reps instead of 10 so each range session stays short.',
                        ),
                        SizedBox(height: 10),
                        _PlanAdjustment(
                          text:
                              'Keep every session on the range and stay with this one hip-lead correction.',
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

class _PlanAdjustment extends StatelessWidget {
  final String text;

  const _PlanAdjustment({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pillInactive,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(height: 1.4),
      ),
    );
  }
}

/// Fixed bottom button that starts the 2-week plan.
class _StartPracticePlanButton extends StatelessWidget {
  const _StartPracticePlanButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: AppColors.backgroundOffWhite,
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ctaBrightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.buttonBorderRadius,
            ),
            elevation: 0,
          ),
          child: const Text(
            'Start This Practice Plan',
            style: AppTextStyles.buttonLabel,
          ),
        ),
      ),
    );
  }
}

class _PlanProgressBar extends StatelessWidget {
  const _PlanProgressBar({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: AppColors.backgroundOffWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$completed of $total sessions completed',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              minHeight: 8,
              backgroundColor: AppColors.borderCard,
              color: AppColors.successGreen,
            ),
          ),
        ],
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
