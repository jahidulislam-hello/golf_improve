import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/coach/reviewers/review_models.dart';
import 'package:golf_training_app/core/app_radii.dart';



/// Coach-facing screen for reviewing a single swing video and leaving
/// feedback. Pops `true` when the coach submits, so the Reviews list can
/// move the item from Pending to Completed.
class ReviewSwingScreen extends StatefulWidget {
  const ReviewSwingScreen({super.key, required this.review});

  final PendingReview review;

  @override
  State<ReviewSwingScreen> createState() => _ReviewSwingScreenState();
}

class _ReviewSwingScreenState extends State<ReviewSwingScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    setState(() => _submitting = true);
    // TODO: send `_noteController.text` + widget.review.id to your backend.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Review Swing', style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          _VideoPlayer(review: review),
          const SizedBox(height: 18),
          Text(review.golferName, style: AppTextStyles.sectionHeader),
          const SizedBox(height: 2),
          Text(review.subtitle, style: AppTextStyles.caption),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.noteHighlightBg,
              border: Border.all(color: AppColors.noteHighlightBorder),
              borderRadius: AppRadii.cardBorderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Last Note on ${review.golferName.split(' ').first}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.noteHighlightText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\u201C${review.quote}\u201D',
                  style: AppTextStyles.body.copyWith(color: AppColors.noteHighlightText),
                ),
              ],
            ),
          ),
          if (review.aiIncluded) ...[
            const SizedBox(height: 20),
            _AiAnalysisCard(),
          ],
          const SizedBox(height: 20),
          Text('Your Feedback', style: AppTextStyles.sectionHeader.copyWith(fontSize: 18)),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 5,
            style: AppTextStyles.inputValue,
            decoration: InputDecoration(
              hintText: 'Write notes on this swing…',
              filled: true,
              fillColor: AppColors.surfaceWhite,
              border: OutlineInputBorder(
                borderRadius: AppRadii.cardBorderRadius,
                borderSide: BorderSide(color: AppColors.borderLightGray),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonBorderRadius),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('Send Feedback', style: AppTextStyles.buttonLabel),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoPlayer extends StatelessWidget {
  const _VideoPlayer({required this.review});

  final PendingReview review;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.cardBorderRadius,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              review.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.primaryNavy),
            ),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiAnalysisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.quickActionAiIcon),
              const SizedBox(width: 8),
              Text('AI Analysis', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.betaBadgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'BETA',
                  style: AppTextStyles.pillLabel.copyWith(
                    color: AppColors.betaBadgeText,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AiFinding(text: 'Early hip rotation detected in the transition.'),
          const SizedBox(height: 8),
          _AiFinding(text: 'Slight over-the-top move at the top of the backswing.'),
        ],
      ),
    );
  }
}

class _AiFinding extends StatelessWidget {
  const _AiFinding({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.only(top: 1),
          decoration: const BoxDecoration(color: AppColors.aiWarningBg, shape: BoxShape.circle),
          child: const Icon(Icons.priority_high_rounded, size: 15, color: AppColors.aiWarningIcon),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}
