import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_models.dart';


/// Dark navy card at the bottom of the screen showing the coach's
/// avatar/name/timestamp, an italic quote, and a "Read Full Feedback"
/// white pill button.
class CoachFeedbackCard extends StatelessWidget {
  const CoachFeedbackCard({
    super.key,
    required this.feedback,
    required this.onReadFullFeedback,
  });

  final CoachFeedback feedback;
  final VoidCallback onReadFullFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.ctaBrightBlue,
                child: Text(
                  feedback.initials,
                  style: AppTextStyles.buttonLabel.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feedback.coachName, style: AppTextStyles.coachName),
                    const SizedBox(height: 2),
                    Text(feedback.receivedAtLabel, style: AppTextStyles.coachMeta),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('"${feedback.quote}"', style: AppTextStyles.coachQuote),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onReadFullFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                foregroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text('Read Full Feedback', style: AppTextStyles.readFullFeedback),
            ),
          ),
        ],
      ),
    );
  }
}
