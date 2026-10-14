import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Controller for Screen 2 — Swing Analysis (AI Golf Coach summary).
/// Loads GET `/swing-library/find/:id` and maps AI metrics, coach share,
/// feedback, and conversation onto the UI.
class SwingAnalysisController extends ChangeNotifier {
  SwingAnalysisController({this.swingId, Map<String, dynamic>? initialData}) {
    final id = (swingId != null && swingId!.isNotEmpty)
        ? swingId
        : _readString(initialData, '_id') ?? _readString(initialData, 'id');

    if (initialData != null) {
      _applyData(initialData);
    }

    if (id != null && id.isNotEmpty) {
      load(id);
    } else if (initialData == null) {
      isLoading = false;
      errorMessage = 'Missing swing id';
    } else {
      isLoading = false;
      hasLoaded = true;
    }
  }

  final String? swingId;

  bool isLoading = true;
  bool hasLoaded = false;
  String? errorMessage;

  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration total = const Duration(seconds: 8);

  String id = '';
  String videoUrl = '';
  String thumbnailUrl = '';
  String clubType = '';
  String cameraAngle = '';
  int overallScore = 0;
  bool isSharedWithCoach = false;

  List<SwingInsight> insights = const [];
  List<String> thingsToTry = const [];
  List<String> suggestedQuestions = const [];
  List<AiConversationEntry> aiConversation = const [];

  /// Share include flags (from `shareDetails` when already shared).
  bool includeSwingVideo = true;
  bool includeAiAnalysis = true;
  bool includePersonalNotes = true;
  String? shareId;
  String shareStatus = '';
  String? practiceNoteId;

  String coachName = 'Coach';
  String? coachId;
  String? coachProfileUrl;
  String? coachCertification;

  String? proInitials;
  String? proQuote;
  String? proImprovement;
  String? feedbackSessionInfo;
  String? feedbackReceivedLabel;

  bool get hasProFeedback =>
      (proQuote != null && proQuote!.trim().isNotEmpty);

  Future<void> load(String id, {bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final service = await _service();
      final response = await service.getSwingLibraryById(id);
      final data = _asMap(response['data']);
      if (data != null) {
        _applyData(data);
      }
      hasLoaded = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      if (!showLoader) rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyData(Map<String, dynamic> data) {
    // Share-find payload nests the library under `swingLibrary`.
    final library = _asMap(data['swingLibrary']) ?? data;

    id = _readString(library, '_id') ??
        _readString(library, 'id') ??
        _readString(data, '_id') ??
        id;
    videoUrl = _readString(library, 'videoUrl') ??
        _readString(data, 'videoUrl') ??
        '';
    thumbnailUrl = _readString(library, 'thumbnailUrl') ??
        videoUrl;
    clubType = _readString(library, 'clubType') ??
        _readString(data, 'clubType') ??
        '';
    cameraAngle = _readString(library, 'cameraAngle') ??
        _readString(data, 'cameraAngle') ??
        '';
    overallScore = _asInt(library['overallScore'] ?? data['overallScore']);
    isSharedWithCoach = library['isSharedWithCoach'] == true ||
        data['isSharedWithCoach'] == true ||
        _asMap(data['shareDetails']) != null;
    practiceNoteId = _extractPracticeNoteId(library) ??
        _extractPracticeNoteId(data) ??
        practiceNoteId;

    final metrics = library['aiMetrics'] ?? data['aiMetrics'];
    if (metrics is List) {
      insights = metrics
          .whereType<Map>()
          .map((e) => _insightFromMetric(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      insights = const [];
    }

    final tips = library['thingsToTry'] ?? data['thingsToTry'];
    if (tips is List) {
      thingsToTry =
          tips.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    } else {
      thingsToTry = const [];
    }

    final questions = library['suggestedQuestions'] ?? data['suggestedQuestions'];
    if (questions is List) {
      suggestedQuestions =
          questions.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    } else {
      suggestedQuestions = const [];
    }

    final conversation = library['aiConversation'] ?? data['aiConversation'];
    if (conversation is List) {
      aiConversation = conversation
          .whereType<Map>()
          .map((e) =>
              AiConversationEntry.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.question.isNotEmpty || e.answer.isNotEmpty)
          .toList();
    } else {
      aiConversation = const [];
    }

    final swingDetails = _asMap(data['swingDetails']) ??
        _asMap(library['swingDetails']);
    if (swingDetails != null) {
      final durationSec = swingDetails['duration'];
      if (durationSec is num && durationSec > 0) {
        total = Duration(milliseconds: (durationSec * 1000).round());
      }
      if (videoUrl.isEmpty) {
        videoUrl = _readString(swingDetails, 'videoUrl') ?? videoUrl;
      }
    }

    final share = _asMap(data['shareDetails']);
    if (share != null) {
      shareId = _readString(share, '_id');
      shareStatus = _readString(share, 'status') ?? '';
      includeSwingVideo = share['isSwingVideo'] != false;
      includeAiAnalysis = share['isAiAnalysis'] == true;
      includePersonalNotes = share['isPersonalNotesAndTips'] == true;

      final coach = _asMap(share['coach']);
      if (coach != null) {
        coachId = _readString(coach, '_id') ?? _readString(coach, 'id') ?? coachId;
        coachName = _readString(coach, 'name') ?? coachName;
        coachProfileUrl = _readString(coach, 'profileUrl');
      }
    } else if (_asMap(data['coach']) != null) {
      // Share-find root `coach` object.
      final coach = _asMap(data['coach'])!;
      coachId = _readString(coach, '_id') ?? _readString(coach, 'id') ?? coachId;
      coachName = _readString(coach, 'name') ?? coachName;
      coachProfileUrl = _readString(coach, 'profileUrl');
      shareId = _readString(data, '_id') ?? shareId;
      shareStatus = _readString(data, 'status') ?? shareStatus;
      includeSwingVideo = data['isSwingVideo'] != false;
      includeAiAnalysis = data['isAiAnalysis'] == true;
      includePersonalNotes = data['isPersonalNotesAndTips'] == true;
    }

    final feedback = _asMap(data['feedbackCard']);
    if (feedback != null) {
      final coach = _asMap(feedback['coach']);
      if (coach != null) {
        coachName = _readString(coach, 'name') ?? coachName;
        coachProfileUrl = _readString(coach, 'profileUrl') ?? coachProfileUrl;
        coachCertification = _readString(coach, 'certification');
        proInitials = _initialsFrom(coachName);
      }
      proQuote = _readString(feedback, 'feedbackQuote') ?? proQuote;
      feedbackSessionInfo = _readString(feedback, 'sessionInfo');
      final receivedAt = _readString(feedback, 'receivedAt');
      feedbackReceivedLabel = _friendlyDate(receivedAt);
      if ((proImprovement == null || proImprovement!.isEmpty) &&
          (coachCertification != null && coachCertification!.isNotEmpty)) {
        proImprovement = coachCertification;
      }
    }

    // Nested coachFeedback on share-find.
    final coachFeedback = _asMap(data['coachFeedback']);
    if (coachFeedback != null && (proQuote == null || proQuote!.isEmpty)) {
      proQuote = _readString(coachFeedback, 'feedbackText');
      proInitials = _initialsFrom(coachName);
    }

    if (proQuote == null || proQuote!.isEmpty) {
      proQuote = _readString(data, 'proQuote') ?? _readString(data, 'coachQuote');
    }

    final coachComparison =
        _asMap(library['coachComparison']) ?? _asMap(data['coachComparison']);
    if (coachComparison != null) {
      proQuote ??= _readString(coachComparison, 'proQuote');
      proImprovement ??=
          _readString(coachComparison, 'improvedStatusText');
      proInitials ??= _initialsFrom(coachName);
    }
  }

  SwingInsight _insightFromMetric(Map<String, dynamic> json) {
    final status = (_readString(json, 'status') ?? 'warning').toLowerCase();
    final style = _styleForStatus(status);

    return SwingInsight(
      icon: style.icon,
      iconColor: style.iconColor,
      iconBg: style.iconBg,
      title: _readString(json, 'title') ?? 'Insight',
      description: _readString(json, 'description') ?? '',
    );
  }

  _InsightStyle _styleForStatus(String status) {
    switch (status) {
      case 'success':
      case 'positive':
      case 'ok':
      case 'good':
        return const _InsightStyle(
          icon: Icons.check,
          iconColor: AppColors.insightPositiveIcon,
          iconBg: AppColors.insightPositiveIconBg,
        );
      case 'error':
      case 'negative':
      case 'danger':
        return const _InsightStyle(
          icon: Icons.error_outline,
          iconColor: AppColors.insightNegativeIcon,
          iconBg: AppColors.insightNegativeIconBg,
        );
      case 'warning':
      default:
        return const _InsightStyle(
          icon: Icons.info_outline,
          iconColor: AppColors.warningText,
          iconBg: AppColors.warningBg,
        );
    }
  }

  void togglePlay() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void seek(Duration newPosition) {
    position = newPosition;
    notifyListeners();
  }

  Future<GolferService> _service() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    return GolferService(apiService: apiService);
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String? _extractPracticeNoteId(Map<String, dynamic> source) {
    const directKeys = [
      'practice_note_id',
      'practiceNoteId',
      'noteId',
      'note_id',
      'logbookNoteId',
      'noteBookId',
      'notebookId',
    ];
    for (final key in directKeys) {
      final id = _idOf(source[key]);
      if (id != null) return id;
    }
    const objectKeys = [
      'practiceNote',
      'practice_note',
      'note',
      'noteBook',
      'notebook',
      'logbookNote',
      'drillPlan',
      'savedDrill',
    ];
    for (final key in objectKeys) {
      final id = _idOf(source[key]);
      if (id != null) return id;
    }
    final notes = source['notes'] ?? source['practiceNotes'];
    if (notes is List && notes.isNotEmpty) {
      return _idOf(notes.first);
    }
    return null;
  }

  String? _idOf(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final text = value.trim();
      if (!RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(text)) return null;
      return text;
    }
    if (value is Map) {
      final id = value['_id'] ?? value['id'];
      if (id == null) return null;
      final text = '$id'.trim();
      if (!RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(text)) return null;
      return text;
    }
    return null;
  }

  String? _readString(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    final value = map[key];
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  int _asInt(dynamic raw) {
    if (raw is num) return raw.round();
    return int.tryParse('${raw ?? ''}') ?? 0;
  }

  String? _initialsFrom(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String? _friendlyDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return null;
    final local = parsed.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

class _InsightStyle {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _InsightStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}
