import 'package:flutter/material.dart';
import '../models/models.dart';

/// Controller for Screen 4 — AI Golf Coach chat.
class AiChatController extends ChangeNotifier {
  final TextEditingController inputController = TextEditingController();

  final List<ChatMessage> messages = [
    ChatMessage(
      text:
          'Your head is moving during the backswing — this is disrupting your weight shift. Record face-on and watch your right ear: it should barely move from address to the top.',
      isUser: false,
    ),
    ChatMessage(
      text: 'Do you often miss shots to the right when this happens?',
      isUser: false,
    ),
    ChatMessage(text: 'Sometimes', isUser: true),
  ];

  final List<String> quickReplies = [
    'Yes, fairly often',
    'Sometimes',
    'No, I usually go left',
  ];

  String? selectedReply = 'Sometimes';
  bool isOnline = true;

  void selectQuickReply(String reply) {
    selectedReply = reply;
    messages.add(ChatMessage(text: reply, isUser: true));
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(text: text.trim(), isUser: true));
    inputController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}
