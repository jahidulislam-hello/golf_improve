import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

import '../controllers/ai_chat_controller.dart';
import '../widgets/shared_widgets.dart';

/// Screen 4 — AI Golf Coach chat.
/// Reached from Screen 2 by tapping the "AI Golf Coach" button.
class AiGolfCoachScreen extends StatefulWidget {
  const AiGolfCoachScreen({super.key});

  @override
  State<AiGolfCoachScreen> createState() => _AiGolfCoachScreenState();
}

class _AiGolfCoachScreenState extends State<AiGolfCoachScreen> {
  final AiChatController controller = AiChatController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundOffWhite,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).maybePop(),
                        size: 36,
                      ),
                      const SizedBox(width: 10),
                      Text('AI Golf Coach',
                          style: AppTextStyles.sectionHeader
                              .copyWith(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      if (controller.isOnline)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E9E5B),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final msg = controller.messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ChatBubbleWidget(message: msg),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    children: controller.quickReplies
                        .map(
                          (reply) => QuickReplyChip(
                            label: reply,
                            selected: controller.selectedReply == reply,
                            onTap: () => controller.selectQuickReply(reply),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
