import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

import '../controllers/ai_chat_controller.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

/// Screen 4 — AI Golf Coach chat.
/// Reached from Screen 2 by tapping the "AI Golf Coach" button.
class AiGolfCoachScreen extends StatefulWidget {
  const AiGolfCoachScreen({
    super.key,
    required this.swingId,
    this.conversation = const [],
    this.suggestedQuestions = const [],
  });

  final String swingId;
  final List<AiConversationEntry> conversation;
  final List<String> suggestedQuestions;

  @override
  State<AiGolfCoachScreen> createState() => _AiGolfCoachScreenState();
}

class _AiGolfCoachScreenState extends State<AiGolfCoachScreen> {
  late final AiChatController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = AiChatController(
      swingId: widget.swingId,
      conversation: widget.conversation,
      suggestedQuestions: widget.suggestedQuestions,
    );
    controller.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollToBottom);
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    itemCount: controller.messages.length +
                        (controller.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final msg = controller.messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ChatBubbleWidget(message: msg),
                      );
                    },
                  ),
                ),
                if (controller.quickReplies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Column(
                      children: controller.quickReplies
                          .map(
                            (reply) => QuickReplyChip(
                              label: reply,
                              selected: controller.selectedReply == reply,
                              onTap: controller.isSending
                                  ? () {}
                                  : () => controller.selectQuickReply(reply),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.borderLightGray),
                          ),
                          child: TextField(
                            controller: controller.inputController,
                            enabled: !controller.isSending,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => controller.sendMessage(),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Ask about this swing…',
                              hintStyle: AppTextStyles.type14.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleIconButton(
                        icon: Icons.send,
                        background: AppColors.ctaBrightBlue,
                        iconColor: Colors.white,
                        onTap: controller.isSending
                            ? null
                            : () => controller.sendMessage(),
                      ),
                    ],
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
