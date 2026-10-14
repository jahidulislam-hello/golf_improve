import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';

/// Practice, goals, and drills chat. It does not discuss a recorded clip.
class PracticeCoachChatScreen extends StatefulWidget {
  const PracticeCoachChatScreen({super.key});

  @override
  State<PracticeCoachChatScreen> createState() =>
      _PracticeCoachChatScreenState();
}

class _PracticeCoachChatScreenState extends State<PracticeCoachChatScreen> {
  final TextEditingController _input = TextEditingController();
  final List<_ChatLine> _lines = [
    const _ChatLine(
      text: 'Ask about your practice, a goal, or a drill.',
      fromUser: false,
    ),
  ];

  static const _suggestions = [
    'Plan this week’s practice',
    'Set a practice goal',
    'Suggest a drill',
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    _input.clear();
    setState(() {
      _lines.add(_ChatLine(text: text, fromUser: true));
      _lines.add(_ChatLine(text: _replyFor(text), fromUser: false));
    });
  }

  String _replyFor(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('goal')) {
      return 'Pick one goal for this week and practise it in short sessions. '
          'Keep the same setup so you can tell what is changing.';
    }
    if (lower.contains('drill')) {
      return 'Try ten slow swings, then ten at your normal speed. '
          'Pause between them and reset your stance each time.';
    }
    if (lower.contains('practice') || lower.contains('practise')) {
      return 'A simple session is a short warm-up, one thing to focus on, '
          'then a few swings at your normal speed.';
    }
    return 'I can help with practice, goals, and drills. '
        'What would you like to work on?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        title: const Text(
          'AI Golf Coach',
          style: AppTextStyles.appBarTitle,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Practice, goals and drills',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _lines.length,
                itemBuilder: (context, index) {
                  final line = _lines[index];
                  return Align(
                    alignment: line.fromUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                      ),
                      decoration: BoxDecoration(
                        color: line.fromUser
                            ? AppColors.ctaBrightBlue
                            : AppColors.pillInactive,
                        borderRadius: AppRadii.cardBorderRadius,
                      ),
                      child: Text(
                        line.text,
                        style: AppTextStyles.body.copyWith(
                          color: line.fromUser
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = _suggestions[index];
                  return ActionChip(
                    label: Text(label, style: AppTextStyles.type13),
                    onPressed: () => _send(label),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Ask about practice, goals, or drills',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.pillInactive,
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.buttonBorderRadius,
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _send(),
                    icon: const Icon(
                      Icons.send,
                      color: AppColors.ctaBrightBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatLine {
  const _ChatLine({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;
}
