import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Controller for Screen 4 — AI Golf Coach chat.
/// Seeds from find-API `aiConversation` / `suggestedQuestions`, and posts
/// new questions to `/swing-library/ask/:id`.
class AiChatController extends ChangeNotifier {
  AiChatController({
    required this.swingId,
    List<AiConversationEntry> conversation = const [],
    List<String> suggestedQuestions = const [],
  }) {
    inputController.addListener(notifyListeners);
    _seed(conversation, suggestedQuestions);
  }

  final String swingId;
  final TextEditingController inputController = TextEditingController();

  final List<ChatMessage> messages = [];
  List<String> quickReplies = const [];

  String? selectedReply;
  bool isOnline = true;
  bool isSending = false;
  String? errorMessage;

  void _seed(
    List<AiConversationEntry> conversation,
    List<String> suggestedQuestions,
  ) {
    messages.clear();
    for (final entry in conversation) {
      if (entry.question.isNotEmpty) {
        messages.add(ChatMessage(
          text: entry.question,
          isUser: true,
          timestamp: entry.createdAt,
        ));
      }
      if (entry.answer.isNotEmpty) {
        messages.add(ChatMessage(
          text: entry.answer,
          isUser: false,
          timestamp: entry.createdAt,
        ));
      }
    }

    if (messages.isEmpty) {
      messages.add(
        ChatMessage(
          text:
              'Ask me anything about this swing. Pick a suggestion below or type your own question.',
          isUser: false,
        ),
      );
    }

    quickReplies = suggestedQuestions
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> selectQuickReply(String reply) async {
    if (isSending) return;
    selectedReply = reply;
    await askQuestion(reply);
  }

  Future<void> sendMessage([String? text]) async {
    final question = (text ?? inputController.text).trim();
    if (question.isEmpty || isSending) return;
    inputController.clear();
    await askQuestion(question);
  }

  Future<void> askQuestion(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || swingId.isEmpty) return;

    isSending = true;
    errorMessage = null;
    messages.add(ChatMessage(text: trimmed, isUser: true));
    notifyListeners();

    try {
      final service = await _service();
      final response = await service.askSwingQuestion(
        swingId: swingId,
        question: trimmed,
      );
      final answer = _extractAnswer(response);
      messages.add(
        ChatMessage(
          text: answer.isNotEmpty
              ? answer
              : 'Thanks — I received your question.',
          isUser: false,
        ),
      );
    } catch (e) {
      errorMessage = e.toString();
      messages.add(
        ChatMessage(
          text: 'Sorry, I could not answer that right now. Please try again.',
          isUser: false,
        ),
      );
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  String _extractAnswer(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in ['answer', 'response', 'message', 'text']) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    }
    final message = response['message'];
    if (message is String &&
        message.trim().isNotEmpty &&
        !message.toLowerCase().contains('success')) {
      return message.trim();
    }
    return '';
  }

  Future<GolferService> _service() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    return GolferService(apiService: apiService);
  }

  @override
  void dispose() {
    inputController.removeListener(notifyListeners);
    inputController.dispose();
    super.dispose();
  }
}
