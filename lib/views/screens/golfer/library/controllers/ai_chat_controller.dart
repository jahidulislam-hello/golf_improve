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
  bool isSavingPlan = false;
  String? errorMessage;
  String? recommendedDrill;
  List<Map<String, dynamic>> practicePlan = const [];
  String? clubType;
  bool planSaved = false;

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
      final response = await service.askCoach(
        swingId: swingId,
        question: trimmed,
      );
      final parsed = _parseCoachReply(response);
      final answer = parsed.answer;
      recommendedDrill = parsed.recommendedDrill;
      practicePlan = parsed.practicePlan;
      planSaved = parsed.isSaved;
      if (parsed.suggestedQuestions.isNotEmpty) {
        quickReplies = parsed.suggestedQuestions;
      }
      final drill = parsed.recommendedDrill;
      final buffer = StringBuffer(answer.isNotEmpty ? answer : 'Thanks — I received your question.');
      if (drill != null && drill.isNotEmpty) {
        buffer.write('\n\nDrill: $drill');
      }
      if (parsed.practicePlan.isNotEmpty) {
        buffer.write('\n\nPractice plan:');
        for (final step in parsed.practicePlan) {
          buffer.write(
            '\n• ${step['dayRange'] ?? ''}: ${step['description'] ?? ''}',
          );
        }
      }
      messages.add(ChatMessage(text: buffer.toString().trim(), isUser: false));
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

  Future<bool> savePlan({String? club}) async {
    final drill = recommendedDrill?.trim() ?? '';
    if (drill.isEmpty || isSavingPlan || planSaved) return false;
    isSavingPlan = true;
    errorMessage = null;
    notifyListeners();
    try {
      final service = await _service();
      final response = await service.saveDrillPlan(
        title: drill.length > 80 ? '${drill.substring(0, 77)}...' : drill,
        recommendedDrill: drill,
        practicePlan: practicePlan,
        clubType: club ?? clubType,
        analysisId: swingId,
      );
      final saved = response['data'];
      final noteId = saved is Map ? '${saved['_id'] ?? saved['id'] ?? ''}' : '';
      if (noteId.isNotEmpty && swingId.trim().isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('linked_practice_note_$swingId', noteId);
      }
      planSaved = true;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSavingPlan = false;
      notifyListeners();
    }
  }

  _CoachReply _parseCoachReply(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map) {
      return _CoachReply(answer: _extractAnswer(response));
    }
    final map = Map<String, dynamic>.from(data);
    final plan = <Map<String, dynamic>>[];
    final rawPlan = map['practicePlan'];
    if (rawPlan is List) {
      for (final item in rawPlan) {
        if (item is Map) {
          plan.add({
            'dayRange': '${item['dayRange'] ?? ''}',
            'description': '${item['description'] ?? ''}',
          });
        }
      }
    }
    final questions = <String>[];
    final rawQuestions = map['suggestedQuestions'];
    if (rawQuestions is List) {
      questions.addAll(
        rawQuestions.map((e) => e.toString().trim()).where((e) => e.isNotEmpty),
      );
    }
    final drill = map['recommendedDrill']?.toString().trim();
    return _CoachReply(
      answer: _extractAnswer(response),
      recommendedDrill: (drill == null || drill.isEmpty) ? null : drill,
      practicePlan: plan,
      suggestedQuestions: questions,
      isSaved: map['isSavedToPlan'] == true,
    );
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

class _CoachReply {
  const _CoachReply({
    required this.answer,
    this.recommendedDrill,
    this.practicePlan = const [],
    this.suggestedQuestions = const [],
    this.isSaved = false,
  });

  final String answer;
  final String? recommendedDrill;
  final List<Map<String, dynamic>> practicePlan;
  final List<String> suggestedQuestions;
  final bool isSaved;
}
