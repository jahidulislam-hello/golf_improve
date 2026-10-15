import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/utils/api_constants.dart';
import 'package:golf_training_app/views/screens/golfer/home/coach_feedback/coach_feedback_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_models.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for the Session Timeline screen.
///
/// Loads the six coaching steps from
/// `GET /share-swing/single/:shareId` or
/// `GET /swing-library/find/:analysisId`.
/// Automatic analysis, scores, and fault lists are left out.
class SessionTimelineController extends ChangeNotifier {
  SessionTimelineController({
    this.shareId,
    this.analysisId,
    this.thumbnailUrl = '',
    this.sessionLabel = '',
  }) {
    _video = SwingVideoState(
      thumbnailUrl: thumbnailUrl,
      isPlaying: false,
      position: Duration.zero,
      duration: const Duration(seconds: 8),
    );
    _journeySteps = _placeholderSteps();
  }

  final String? shareId;
  final String? analysisId;
  final String thumbnailUrl;
  final String sessionLabel;

  static const queuedShareMessage =
      'Sharing queued — will continue automatically later when online';

  bool _disposed = false;

  late SwingVideoState _video;
  SwingVideoState get video => _video;

  late List<JourneyStep> _journeySteps;
  List<JourneyStep> get journeySteps => List.unmodifiable(_journeySteps);

  CoachFeedback? _feedback;
  CoachFeedback? get feedback => _feedback;

  TimelinePrimaryAction? _primaryAction;
  TimelinePrimaryAction? get primaryAction => _primaryAction;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  bool get showReadFeedback =>
      _primaryAction != null &&
      _primaryAction!.isAvailable &&
      _primaryAction!.action == 'read_full_feedback';

  String get feedbackButtonLabel =>
      _primaryAction?.label.trim().isNotEmpty == true
          ? _primaryAction!.label
          : 'Read Full Feedback';

  /// The step the golfer should look at next.
  JourneyStep? get focusStep {
    for (final step in _journeySteps) {
      if (step.status == JourneyStepStatus.queued ||
          step.status == JourneyStepStatus.inProgress) {
        return step;
      }
    }
    for (final step in _journeySteps) {
      if (step.status == JourneyStepStatus.upcoming) return step;
    }
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _notify();

    final queuedLocally = await _shareIsQueued();
    try {
      final service = await _service();
      final response = await _fetchTimeline(service);
      _applyPayload(_unwrap(response), queuedLocally: queuedLocally);
      _isOffline = false;
    } on ApiError catch (error) {
      _isOffline = error.statusCode == 0;
      _applyLocalTimeline(queued: _isOffline || queuedLocally);
    } catch (_) {
      _isOffline = true;
      _applyLocalTimeline(queued: true);
    }

    _isLoading = false;
    _notify();
  }

  Future<Map<String, dynamic>> _fetchTimeline(GolferService service) async {
    final share = shareId?.trim() ?? '';
    final analysis = analysisId?.trim() ?? '';

    if (share.isNotEmpty) {
      return service.getSessionTimeline(shareId: share);
    }
    if (analysis.isEmpty) {
      throw ApiError(
        message: 'This session has no timeline yet.',
        statusCode: 400,
      );
    }

    try {
      return await service.getSessionTimeline(analysisId: analysis);
    } on ApiError catch (error) {
      if (error.statusCode != 404) rethrow;
      return service.getSessionTimeline(shareId: analysis);
    }
  }

  Future<void> refresh() => load();

  void togglePlayback() {
    _video = _video.copyWith(isPlaying: !_video.isPlaying);
    _notify();
  }

  void seekTo(Duration position) {
    final clamped = position < Duration.zero
        ? Duration.zero
        : (position > _video.duration ? _video.duration : position);
    _video = _video.copyWith(position: clamped);
    _notify();
  }

  void seekToFraction(double fraction) {
    final ms = (_video.duration.inMilliseconds * fraction).round();
    seekTo(Duration(milliseconds: ms));
  }

  void onExpandVideo() {}

  void onOpenAnalysisTool() {}

  void onReadFullFeedback(BuildContext context) {
    final id = _primaryAction?.shareId?.trim().isNotEmpty == true
        ? _primaryAction!.shareId
        : shareId;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CoachFeedbackScreen(shareId: id)),
    );
  }

  static String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString();
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<JourneyStep> _placeholderSteps() {
    return _buildSteps(
      recorded: _stepInput(
        subtitle: sessionLabel.trim().isEmpty
            ? 'Recorded on this device'
            : sessionLabel.trim(),
        status: 'completed',
      ),
    );
  }

  void _applyLocalTimeline({required bool queued}) {
    _feedback = null;
    _primaryAction = null;
    _journeySteps = _buildSteps(
      recorded: _stepInput(
        subtitle: sessionLabel.trim().isEmpty
            ? 'Recorded on this device'
            : sessionLabel.trim(),
        status: 'completed',
        timestamp: DateTime.now().toUtc().toIso8601String(),
      ),
      shared: queued
          ? _stepInput(
              subtitle: queuedShareMessage,
              status: 'queued',
            )
          : null,
    );
  }

  void _applyPayload(
    Map<String, dynamic> data, {
    required bool queuedLocally,
  }) {
    final share = _asMap(data['shareDetails']) ?? _asMap(data['share']) ?? data;
    final shareStatus = (_readString(share, 'status') ??
            _readString(data, 'status') ??
            '')
        .toLowerCase();
    final waiting = shareStatus == 'waiting_to_send' || queuedLocally;
    final byKey = _indexJourney(
      data['journey'] ?? share['journey'],
    );

    final recordedSubtitle = _cleanSubtitle(
      byKey['swing_recorded']?.subtitle,
      fallback: _sessionSubtitle(data),
    );

    _journeySteps = _buildSteps(
      recorded: _merge(
        byKey['swing_recorded'],
        fallbackSubtitle: recordedSubtitle,
        fallbackStatus: 'completed',
      ),
      shared: _merge(
        byKey['shared_with_coach'],
        fallbackSubtitle: waiting
            ? queuedShareMessage
            : 'Waiting to share with your coach',
        fallbackStatus: waiting ? 'queued' : null,
        forceQueued: waiting &&
            byKey['shared_with_coach']?.status != 'completed',
      ),
      reviewing: _merge(byKey['coach_reviewing']),
      feedback: _merge(byKey['feedback_received']),
      drill: _merge(byKey['drill_recommended']),
      plan: _merge(byKey['practice_plan_created']),
    );

    if (waiting) {
      _journeySteps = [
        for (final step in _journeySteps)
          step.step == 2 && step.status != JourneyStepStatus.completed
              ? JourneyStep(
                  step: step.step,
                  title: step.title,
                  subtitle: queuedShareMessage,
                  status: JourneyStepStatus.queued,
                  statusLabel: 'Queued',
                  dateLabel: step.dateLabel,
                )
              : step,
      ];
    }

    final cardSource = Map<String, dynamic>.from(data);
    cardSource['feedbackCard'] ??= share['feedbackCard'];
    cardSource['primaryAction'] ??= share['primaryAction'];

    _feedback = _feedbackFrom(cardSource);
    _primaryAction = _actionFrom(cardSource);
    _applyVideo(data);
  }

  Map<String, _RawStep> _indexJourney(dynamic raw) {
    final indexed = <String, _RawStep>{};
    if (raw is! List) return indexed;

    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final key = _canonicalKey(_readString(map, 'key') ?? '');
      final title = _readString(map, 'title') ?? '';
      if (_isRemovedStep(key, title)) continue;
      final resolved = key.isEmpty ? _canonicalKey(title) : key;
      if (resolved.isEmpty || _isRemovedStep(resolved, title)) continue;
      indexed[resolved] = _RawStep(
        subtitle: _readString(map, 'subtitle'),
        status: (_readString(map, 'status') ?? '').toLowerCase(),
        statusText: _readString(map, 'statusText'),
        timestamp: _readString(map, 'timestamp'),
      );
    }
    return indexed;
  }

  List<JourneyStep> _buildSteps({
    _RawStep? recorded,
    _RawStep? shared,
    _RawStep? reviewing,
    _RawStep? feedback,
    _RawStep? drill,
    _RawStep? plan,
  }) {
    const titles = [
      'Swing Recorded',
      'Shared with Coach',
      'Coach Reviewing',
      'Feedback Received',
      'Drill Recommended',
      'Practice Plan Created',
    ];
    const fallbacks = [
      'Your swing is saved',
      'Not shared yet',
      'Usually responds within 2 hours',
      'Awaiting coach response',
      'Pending coach assessment',
      'Pending coach plan',
    ];
    final inputs = [recorded, shared, reviewing, feedback, drill, plan];

    return [
      for (var i = 0; i < titles.length; i++)
        _toStep(
          step: i + 1,
          title: titles[i],
          raw: inputs[i],
          fallbackSubtitle: fallbacks[i],
          fallbackStatus: i == 0 ? 'completed' : 'pending',
        ),
    ];
  }

  JourneyStep _toStep({
    required int step,
    required String title,
    required _RawStep? raw,
    required String fallbackSubtitle,
    required String fallbackStatus,
  }) {
    final statusName = raw?.status.isNotEmpty == true ? raw!.status : fallbackStatus;
    final status = _statusFrom(statusName);
    final subtitle = status == JourneyStepStatus.queued
        ? queuedShareMessage
        : _cleanSubtitle(raw?.subtitle, fallback: fallbackSubtitle);
    return JourneyStep(
      step: step,
      title: title,
      subtitle: subtitle,
      status: status,
      statusLabel: _statusLabel(status, raw?.statusText),
      dateLabel: _formatDate(raw?.timestamp),
    );
  }

  _RawStep _merge(
    _RawStep? incoming, {
    String? fallbackSubtitle,
    String? fallbackStatus,
    bool forceQueued = false,
  }) {
    if (forceQueued) {
      return _RawStep(
        subtitle: queuedShareMessage,
        status: 'queued',
        statusText: 'Queued',
        timestamp: incoming?.timestamp,
      );
    }
    return _RawStep(
      subtitle: incoming?.subtitle ?? fallbackSubtitle,
      status: incoming?.status.isNotEmpty == true
          ? incoming!.status
          : (fallbackStatus ?? 'pending'),
      statusText: incoming?.statusText,
      timestamp: incoming?.timestamp,
    );
  }

  _RawStep _stepInput({
    required String subtitle,
    required String status,
    String? timestamp,
  }) {
    return _RawStep(
      subtitle: subtitle,
      status: status,
      statusText: null,
      timestamp: timestamp,
    );
  }

  CoachFeedback? _feedbackFrom(Map<String, dynamic> data) {
    final card = _asMap(data['feedbackCard']);
    if (card == null) return null;
    final coach = _asMap(card['coach']);
    final name = _readString(coach, 'name') ?? 'Your coach';
    final quote = _readString(card, 'feedbackQuote') ?? '';
    if (quote.trim().isEmpty) return null;
    final received = _formatDate(_readString(card, 'receivedAt'));
    return CoachFeedback(
      coachName: name,
      initials: _initials(name),
      receivedAtLabel: received == null
          ? 'Feedback received'
          : 'Feedback received · $received',
      quote: quote.trim(),
    );
  }

  TimelinePrimaryAction? _actionFrom(Map<String, dynamic> data) {
    final action = _asMap(data['primaryAction']);
    if (action == null) {
      final feedbackDone = _journeySteps.any(
        (step) =>
            step.step == 4 && step.status == JourneyStepStatus.completed,
      );
      if (!feedbackDone) return null;
      return TimelinePrimaryAction(
        label: 'Read Full Feedback',
        action: 'read_full_feedback',
        isAvailable: true,
        shareId: shareId,
      );
    }

    final name = (_readString(action, 'action') ?? '').toLowerCase();
    final available = action['isAvailable'] == true;
    if (!available || name != 'read_full_feedback') return null;
    return TimelinePrimaryAction(
      label: _readString(action, 'label') ?? 'Read Full Feedback',
      action: 'read_full_feedback',
      isAvailable: true,
      shareId: _readString(action, 'shareId') ?? shareId,
    );
  }

  void _applyVideo(Map<String, dynamic> data) {
    final thumb = _thumbnailOf(data);
    final seconds = _durationSeconds(data);
    if (thumb == null && seconds == null) return;
    _video = _video.copyWith(
      thumbnailUrl: thumb ?? _video.thumbnailUrl,
      duration: seconds == null
          ? _video.duration
          : Duration(milliseconds: (seconds * 1000).round()),
    );
  }

  String? _thumbnailOf(Map<String, dynamic> data) {
    const keys = ['thumbnailUrl', 'thumbnail', 'posterUrl', 'coverUrl'];
    for (final key in keys) {
      final value = _readString(data, key);
      if (_isImageUrl(value)) return value;
    }
    for (final nestedKey in ['swing', 'swingLibrary', 'swingDetails', 'library']) {
      final nested = _asMap(data[nestedKey]);
      if (nested == null) continue;
      for (final key in keys) {
        final value = _readString(nested, key);
        if (_isImageUrl(value)) return value;
      }
      final video = _readString(nested, 'videoUrl');
      if (_isImageUrl(video)) return video;
    }
    final rootVideo = _readString(data, 'videoUrl');
    if (_isImageUrl(rootVideo)) return rootVideo;
    if (thumbnailUrl.trim().isNotEmpty) return thumbnailUrl;
    return null;
  }

  double? _durationSeconds(Map<String, dynamic> data) {
    final details = _asMap(data['swingDetails']) ??
        _asMap(_asMap(data['swingLibrary'])?['swingDetails']);
    final raw = details?['duration'] ?? data['duration'];
    if (raw is num && raw > 0) return raw.toDouble();
    return null;
  }

  String _sessionSubtitle(Map<String, dynamic> data) {
    final card = _asMap(data['feedbackCard']);
    final fromCard = _readString(card, 'sessionInfo');
    if (fromCard != null && fromCard.isNotEmpty) return fromCard;
    if (sessionLabel.trim().isNotEmpty) return sessionLabel.trim();
    final recorded = _asMap(data['swing']) ?? _asMap(data['swingLibrary']);
    final club = _readString(recorded, 'clubType') ?? _readString(data, 'clubType');
    final angle =
        _readString(recorded, 'cameraAngle') ?? _readString(data, 'cameraAngle');
    final parts = [club, angle].whereType<String>().where((e) => e.isNotEmpty);
    if (parts.isEmpty) return 'Your swing is saved';
    return parts.join(' · ');
  }

  bool _isRemovedStep(String key, String title) {
    const removed = {
      'ai_analysis',
      'automatic_analysis',
      'auto_analysis',
      'analysis',
      'score',
      'scores',
      'faults',
      'technical_feedback',
    };
    if (removed.contains(key)) return true;
    final lower = title.toLowerCase();
    return lower.contains('ai analysis') ||
        lower.contains('automatic') ||
        lower.contains('score') ||
        lower.contains('fault');
  }

  String _canonicalKey(String raw) {
    final key = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    switch (key) {
      case 'swing_recorded':
      case 'recorded':
        return 'swing_recorded';
      case 'shared_with_coach':
      case 'shared':
        return 'shared_with_coach';
      case 'coach_reviewing':
      case 'reviewing':
        return 'coach_reviewing';
      case 'feedback_received':
      case 'coach_feedback':
      case 'feedback':
        return 'feedback_received';
      case 'drill_recommended':
      case 'recommended_drill':
      case 'drill':
        return 'drill_recommended';
      case 'practice_plan_created':
      case 'practice_plan':
      case 'practice_session':
        return 'practice_plan_created';
      default:
        return key;
    }
  }

  JourneyStepStatus _statusFrom(String raw) {
    switch (raw) {
      case 'completed':
      case 'done':
        return JourneyStepStatus.completed;
      case 'in_progress':
      case 'inprogress':
      case 'current':
        return JourneyStepStatus.inProgress;
      case 'queued':
      case 'waiting_to_send':
        return JourneyStepStatus.queued;
      default:
        return JourneyStepStatus.upcoming;
    }
  }

  String _statusLabel(JourneyStepStatus status, String? statusText) {
    final custom = statusText?.trim() ?? '';
    if (custom.isNotEmpty && !_looksTechnical(custom)) return custom;
    switch (status) {
      case JourneyStepStatus.completed:
        return 'Completed';
      case JourneyStepStatus.inProgress:
        return 'In progress';
      case JourneyStepStatus.queued:
        return 'Queued';
      case JourneyStepStatus.upcoming:
        return 'Pending';
    }
  }

  String _cleanSubtitle(String? raw, {required String fallback}) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty || _looksTechnical(text)) return fallback;
    return text;
  }

  bool _looksTechnical(String text) {
    final lower = text.toLowerCase();
    return lower.contains('score') ||
        lower.contains('%') ||
        lower.contains('fault') ||
        lower.contains('observation') ||
        lower.contains('swing path') ||
        lower.contains('ai analysis') ||
        lower.contains('body position');
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return DateFormat('MMM d, yyyy').format(parsed.toLocal());
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  bool _isImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final lower = value.toLowerCase();
    return lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.webp') ||
        lower.contains('unsplash') ||
        lower.contains('images');
  }

  Future<bool> _shareIsQueued() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(ApiConstants.keyOfflineShares);
    if (raw == null || raw.isEmpty) return false;
    final decoded = jsonDecode(raw);
    if (decoded is! List || decoded.isEmpty) return false;

    final analysis = analysisId?.trim() ?? '';
    final share = shareId?.trim() ?? '';
    if (analysis.isEmpty && share.isEmpty) return true;

    for (final item in decoded) {
      if (item is! Map) continue;
      final swingId = '${item['swingLibraryId'] ?? ''}'.trim();
      final itemShare = '${item['shareId'] ?? item['_id'] ?? ''}'.trim();
      if (analysis.isNotEmpty && swingId == analysis) return true;
      if (share.isNotEmpty && itemShare == share) return true;
    }
    return false;
  }

  Future<GolferService> _service() async {
    final preferences = await SharedPreferences.getInstance();
    return GolferService(
      apiService: ApiService(sharedPreferences: preferences),
    );
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return response;
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String? _readString(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    final value = map[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

class _RawStep {
  const _RawStep({
    required this.subtitle,
    required this.status,
    required this.statusText,
    required this.timestamp,
  });

  final String? subtitle;
  final String status;
  final String? statusText;
  final String? timestamp;
}
