import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/views/screens/golfer/home/coach_feedback/coach_feedback_controller.dart';


/// Coach Feedback screen.
///
/// Loads the share, then starts and toggles the 2-week plan on the server.
class CoachFeedbackScreen extends StatefulWidget {
  const CoachFeedbackScreen({super.key, this.shareId});

  final String? shareId;

  @override
  State<CoachFeedbackScreen> createState() => _CoachFeedbackScreenState();
}

class _CoachFeedbackScreenState extends State<CoachFeedbackScreen> {
  late final CoachFeedbackController _controller;
  bool _planViewExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = CoachFeedbackController(shareId: widget.shareId);
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startPlan() async {
    final ok = await _controller.startPlan();
    if (!mounted) return;
    final message = _controller.errorMessage;
    if (!ok && message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _controller.sessions;
    final notes = [
      if (_controller.drillSubtitle.trim().isNotEmpty) _controller.drillSubtitle.trim(),
      if (_controller.detailedComments.trim().isNotEmpty &&
          _controller.detailedComments.trim() != _controller.primaryCorrection.trim())
        _controller.detailedComments.trim(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _controller.errorMessage != null &&
                          _controller.coachName.isEmpty
                      ? _FeedbackError(
                          message: _controller.errorMessage!,
                          onRetry: _controller.load,
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CoachHeaderCard(
                                name: _controller.coachName,
                                meta: _controller.coachMeta,
                                avatarUrl: _controller.avatarUrl,
                              ),
                              const SizedBox(height: 16),
                              _VideoThumbnail(
                                thumbnailUrl: _controller.thumbnailUrl,
                              ),
                              const SizedBox(height: 16),
                              _CoachingFeedbackCard(
                                primaryCorrection: _controller.primaryCorrection,
                                comments: _controller.detailedComments,
                              ),
                              if (_controller.recommendedDrill.trim().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _RecommendedDrillCard(
                                  title: _controller.recommendedDrill,
                                  subtitle: _controller.drillSubtitle,
                                ),
                              ],
                              if (sessions.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _PracticePlanCard(
                                  sessions: sessions,
                                  started: _controller.planStarted,
                                  completedCount: _controller.completedCount,
                                  onToggle: _controller.toggleSession,
                                ),
                              ],
                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _PracticePlanReviewCard(
                                  coachName: _controller.coachName,
                                  notes: notes,
                                  expanded: _planViewExpanded,
                                  onTap: () {
                                    setState(
                                      () => _planViewExpanded = !_planViewExpanded,
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
            ),
            if (!_controller.isLoading && _controller.coachName.isNotEmpty)
              if (!_controller.planStarted)
                _StartPracticePlanButton(
                  isLoading: _controller.isStarting,
                  onPressed: _controller.canStart ? _startPlan : null,
                )
              else
                _PlanProgressBar(
                  completed: _controller.completedCount,
                  total: sessions.length,
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
                      _controller.coachName.trim().isEmpty
                          ? 'Professional review'
                          : 'Professional review · ${_controller.coachName}',
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
  const _CoachHeaderCard({
    required this.name,
    required this.meta,
    this.avatarUrl,
  });

  final String name;
  final String meta;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final photo = avatarUrl;
    return _CardShell(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 48,
              height: 48,
              color: AppColors.primaryNavy,
              child: photo != null && photo.startsWith('http')
                  ? Image.network(photo, fit: BoxFit.cover)
                  : const Icon(Icons.person, color: AppColors.surfaceWhite),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Your coach' : name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(meta, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Swing video thumbnail.
class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.thumbnailUrl});

  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = thumbnailUrl.startsWith('http');
    return ClipRRect(
      borderRadius: AppRadii.cardBorderRadius,
      child: AspectRatio(
        aspectRatio: 16 / 10.5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.network(thumbnailUrl, fit: BoxFit.cover)
            else
              Container(color: AppColors.textSecondary.withOpacity(0.2)),
            Positioned(
              top: 12,
              right: 12,
              child: _Pill(
                label: 'Coach review',
                background: AppColors.primaryNavy.withOpacity(0.85),
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
  const _CoachingFeedbackCard({
    required this.primaryCorrection,
    required this.comments,
  });

  final String primaryCorrection;
  final String comments;

  @override
  Widget build(BuildContext context) {
    final correction = primaryCorrection.trim().isEmpty
        ? 'Your coach has not named a main correction yet.'
        : primaryCorrection.trim();
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
            correction,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          if (comments.trim().isNotEmpty &&
              comments.trim() != primaryCorrection.trim()) ...[
            const SizedBox(height: 12),
            Text(
              comments.trim(),
              style: AppTextStyles.body.copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

/// Recommended drill written by the coach.
class _RecommendedDrillCard extends StatelessWidget {
  const _RecommendedDrillCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

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
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.quickActionAiIcon,
                  ),
                ),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(subtitle.trim(), style: AppTextStyles.body),
                ],
              ],
            ),
          ),
        ],
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

  final List<PracticeSessionItem> sessions;
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
              icon: _iconForPhase(i),
              days: sessions[i].dayRange,
              description: sessions[i].description,
              showDivider: i < sessions.length - 1,
              showComplete: started,
              completed: sessions[i].isCompleted,
              onToggle: () => onToggle(i),
            ),
        ],
      ),
    );
  }
}

IconData _iconForPhase(int index) {
  switch (index) {
    case 0:
      return Icons.golf_course_outlined;
    case 1:
      return Icons.sports_golf_outlined;
    default:
      return Icons.place_outlined;
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
  final String coachName;
  final List<String> notes;
  final bool expanded;
  final VoidCallback onTap;

  const _PracticePlanReviewCard({
    required this.coachName,
    required this.notes,
    required this.expanded,
    required this.onTap,
  });

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
                          '${coachName.trim().isEmpty ? 'Your coach' : coachName} reviewed this drill and practice plan.',
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
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        for (var i = 0; i < notes.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          _PlanAdjustment(text: notes[i]),
                        ],
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
  const _StartPracticePlanButton({
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: AppColors.backgroundOffWhite,
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ctaBrightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.buttonBorderRadius,
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.surfaceWhite,
                  ),
                )
              : const Text(
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

class _FeedbackError extends StatelessWidget {
  const _FeedbackError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
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
