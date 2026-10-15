import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One row in the 2-week plan (`Days 1–3`, `Days 4–7`, `Days 8–14`).
class PracticeSessionItem {
  PracticeSessionItem({
    required this.id,
    required this.phase,
    required this.dayRange,
    required this.description,
    this.isCompleted = false,
  });

  final String id;
  final String phase;
  final String dayRange;
  final String description;
  bool isCompleted;
}

/// Loads a coach reply and the golfer's 2-week practice plan.
class CoachFeedbackController extends ChangeNotifier {
  CoachFeedbackController({this.shareId}) {
    load();
  }

  final String? shareId;

  bool isLoading = true;
  bool isStarting = false;
  bool isToggling = false;
  bool planStarted = false;
  String? errorMessage;

  String coachName = '';
  String coachMeta = '';
  String? avatarUrl;
  String thumbnailUrl = '';
  String primaryCorrection = '';
  String detailedComments = '';
  String recommendedDrill = '';
  String drillSubtitle = '';
  List<PracticeSessionItem> sessions = [];

  bool _disposed = false;

  int get completedCount =>
      sessions.where((session) => session.isCompleted).length;

  bool get canStart =>
      (shareId?.trim().isNotEmpty ?? false) && !planStarted && !isStarting;

  Future<void> load() async {
    final id = shareId?.trim() ?? '';
    isLoading = true;
    errorMessage = null;
    _notify();

    if (id.isEmpty) {
      isLoading = false;
      errorMessage = 'This feedback is not linked to a shared swing yet.';
      _notify();
      return;
    }

    try {
      final service = await _service();
      final timeline = await service.getSessionTimeline(shareId: id);
      final data = _asMap(timeline['data']) ?? timeline;
      _applyShare(data);
      try {
        await _loadPlan(service, id);
      } on ApiError {
        planStarted = false;
      }
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<bool> startPlan() async {
    final id = shareId?.trim() ?? '';
    if (id.isEmpty || isStarting || planStarted) return false;
    isStarting = true;
    errorMessage = null;
    _notify();
    try {
      final service = await _service();
      final response = await service.startPracticePlan(id);
      final data = _asMap(response['data']);
      if (data != null) _applyPlan(data, started: true);
      planStarted = true;
      return true;
    } on ApiError catch (error) {
      if (error.statusCode == 404 || error.statusCode == 409) {
        await _loadPlan(await _service(), id);
        if (planStarted) return true;
      }
      errorMessage = error.message;
      return false;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isStarting = false;
      _notify();
    }
  }

  Future<void> toggleSession(int index) async {
    if (!planStarted || isToggling) return;
    if (index < 0 || index >= sessions.length) return;
    final session = sessions[index];
    if (session.id.isEmpty) return;

    final previous = session.isCompleted;
    session.isCompleted = !previous;
    isToggling = true;
    errorMessage = null;
    _notify();

    try {
      final service = await _service();
      final response = await service.togglePracticeSession(sessionId: session.id);
      final data = _asMap(response['data']);
      if (data != null) {
        if (data['isCompleted'] is bool) {
          session.isCompleted = data['isCompleted'] == true;
        }
        _applyCompletionStats(data['completionStats']);
      }
    } on ApiError catch (error) {
      session.isCompleted = previous;
      errorMessage = error.message;
    } catch (error) {
      session.isCompleted = previous;
      errorMessage = error.toString();
    } finally {
      isToggling = false;
      _notify();
    }
  }

  Future<void> _loadPlan(GolferService service, String id) async {
    try {
      final response = await service.getPracticePlan(id);
      final data = _asMap(response['data']);
      if (data == null) return;
      _applyPlan(data, started: true);
    } on ApiError catch (error) {
      if (error.statusCode == 404) {
        planStarted = false;
        return;
      }
      rethrow;
    }
  }

  void _applyShare(Map<String, dynamic> data) {
    final card = _asMap(data['feedbackCard']);
    final feedback = _asMap(data['coachFeedback']);
    final coach = _asMap(data['coach']) ?? _asMap(card?['coach']);
    final swing = _asMap(data['swingLibrary']) ?? _asMap(data['swing']);

    coachName = _text(coach?['name']) ??
        _text(_asMap(card?['coach'])?['name']) ??
        'Your coach';
    avatarUrl = _text(coach?['profileUrl']);
    final certification = _text(coach?['certification']) ??
        _text(_asMap(card?['coach'])?['certification']);
    final sessionInfo = _text(card?['sessionInfo']) ??
        [
          _text(swing?['clubType']),
          _text(swing?['cameraAngle']),
        ].whereType<String>().join(' · ');
    final received = _text(card?['receivedAt']) ?? _text(feedback?['respondedAt']);
    coachMeta = [
      certification,
      sessionInfo,
      _formatWhen(received),
    ].whereType<String>().where((part) => part.isNotEmpty).join(' · ');

    thumbnailUrl = _text(swing?['thumbnailUrl']) ?? _text(swing?['videoUrl']) ?? '';
    primaryCorrection = _text(feedback?['primaryCorrection']) ?? '';
    detailedComments = _text(feedback?['detailedComments']) ??
        _text(feedback?['feedbackText']) ??
        _text(card?['feedbackQuote']) ??
        '';
    recommendedDrill = _text(feedback?['recommendedDrill']) ??
        _text(card?['recommendedDrill']) ??
        '';
    drillSubtitle = _text(feedback?['drillSubtitle']) ?? '';

    if (sessions.isEmpty) {
      sessions = _sessionsFrom(feedback?['practicePlan'] ?? data['practicePlan']);
    }
  }

  void _applyPlan(Map<String, dynamic> data, {required bool started}) {
    final parsed = _sessionsFrom(data['sessions'] ?? data['practicePlan']);
    if (parsed.isNotEmpty) sessions = parsed;
    planStarted = started || data['sessions'] is List;
    final title = _text(data['recommendedDrill']);
    if (title != null && recommendedDrill.isEmpty) recommendedDrill = title;
    _applyCompletionStats(data['completionStats']);
  }

  void _applyCompletionStats(dynamic raw) {
    final stats = _asMap(raw);
    if (stats == null) return;
    final completed = stats['completedSessions'];
    if (completed is! num) return;
    final target = completed.round();
    var marked = sessions.where((session) => session.isCompleted).length;
    if (marked == target) return;
    for (final session in sessions) {
      session.isCompleted = marked < target;
      if (session.isCompleted) marked++;
    }
  }

  List<PracticeSessionItem> _sessionsFrom(dynamic raw) {
    if (raw is! List) return [];
    final items = <PracticeSessionItem>[];
    for (final entry in raw) {
      final map = _asMap(entry);
      if (map == null) continue;
      final dayRange = _text(map['dayRange']) ?? _text(map['days']) ?? '';
      final phase = _text(map['phase']) ?? '';
      final drill = _text(map['drill']) ?? _text(map['description']) ?? '';
      final reps = _text(map['reps']) ?? '';
      final description = [drill, reps].where((part) => part.isNotEmpty).join(' · ');
      if (dayRange.isEmpty && phase.isEmpty && description.isEmpty) continue;
      items.add(
        PracticeSessionItem(
          id: _text(map['_id']) ?? _text(map['id']) ?? '',
          phase: phase,
          dayRange: dayRange.isNotEmpty ? dayRange : phase,
          description: description,
          isCompleted: map['isCompleted'] == true || map['is_completed'] == true,
        ),
      );
    }
    return items;
  }

  String? _formatWhen(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('MMM d, y · h:mm a').format(parsed.toLocal());
  }

  Future<GolferService> _service() async {
    final prefs = await SharedPreferences.getInstance();
    return GolferService(apiService: ApiService(sharedPreferences: prefs));
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String? _text(dynamic raw) {
    final value = '${raw ?? ''}'.trim();
    return value.isEmpty ? null : value;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
