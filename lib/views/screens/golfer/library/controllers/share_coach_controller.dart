import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Controller for Screen 3 — Share with Coach.
class ShareCoachController extends ChangeNotifier {
  ShareCoachController({
    this.coachName = 'Coach',
    this.coachProfileUrl,
    this.coachId,
    this.swingLibraryId,
    this.practiceNoteId,
    this.initialStatus = '',
    String? initialQuestion,
  }) {
    questionController = TextEditingController(text: initialQuestion ?? '');
    shareStatus = initialStatus ?? '';
    _idempotencyKey =
        'share_${coachId ?? 'coach'}_${swingLibraryId ?? 'swing'}';
    _rebuildIncludes();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) {
      flushQueuedShare();
    });
    _restoreExistingShare();
  }

  String coachName;
  String? coachProfileUrl;
  String? coachId;
  final String? swingLibraryId;
  String? practiceNoteId;
  final String? initialStatus;

  late final TextEditingController questionController;
  List<ShareIncludeItem> includeItems = [];
  late final String _idempotencyKey;

  StreamSubscription<dynamic>? _connectivitySub;
  Timer? _statusTimer;

  bool isSending = false;
  String? errorMessage;
  String shareStatus = '';
  String? shareId;

  bool get hasLinkedPracticeNote =>
      practiceNoteId != null && practiceNoteId!.trim().isNotEmpty;

  String get shareStatusLabel => labelForShareStatus(shareStatus);

  bool get canSend => !isSending && shareStatus.isEmpty;

  static String labelForShareStatus(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'waiting_to_send':
      case 'waiting':
        return 'Waiting to Send';
      case 'sent':
      case 'pending':
        return 'Sent';
      case 'viewed':
        return 'Viewed';
      case 'coach_replied':
      case 'responded':
        return 'Coach Replied';
      default:
        return '';
    }
  }

  void toggleItem(int index) {
    if (!canSend || includeItems[index].alwaysIncluded) return;
    includeItems[index].isOn = !includeItems[index].isOn;
    notifyListeners();
  }

  void _rebuildIncludes() {
    final drawOn = _isOn('Allow Coach to Draw on Video');
    final noteOn = _isOn('Include Practice Note');
    includeItems = [
      ShareIncludeItem(
        title: 'Swing Video',
        subtitle: 'Always included',
        icon: Icons.videocam_outlined,
        iconColor: AppColors.ctaBrightBlue,
        iconBg: AppColors.accentBlueBg,
        alwaysIncluded: true,
        isOn: true,
      ),
      ShareIncludeItem(
        title: 'Allow Coach to Draw on Video',
        subtitle: 'Coach can annotate technique on the frame',
        icon: Icons.draw_outlined,
        iconColor: AppColors.accentOrange,
        iconBg: AppColors.accentOrangeBg,
        isOn: drawOn,
      ),
      if (hasLinkedPracticeNote)
        ShareIncludeItem(
          title: 'Include Practice Note',
          subtitle: 'The note linked to this swing',
          icon: Icons.menu_book_outlined,
          iconColor: AppColors.accentGreen,
          iconBg: AppColors.insightPositiveIconBg,
          isOn: noteOn,
        ),
    ];
  }

  /// Shares the swing. Offline sends stay queued as `waiting_to_send`.
  Future<bool> send() async {
    if (isSending || shareStatus.isNotEmpty) return false;
    final swingId = swingLibraryId?.trim() ?? '';
    if (swingId.isEmpty) {
      errorMessage = 'This swing is not ready to share yet.';
      notifyListeners();
      return false;
    }

    isSending = true;
    errorMessage = null;
    notifyListeners();
    var resolvedCoachId = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      resolvedCoachId = await _resolveCoachId(service);
      if (resolvedCoachId.isEmpty) {
        errorMessage = 'No coach is assigned to your account yet.';
        return false;
      }

      final payload = _payload(resolvedCoachId, swingId);
      if (!await _isOnline()) {
        await _queue(prefs, payload);
        shareStatus = 'waiting_to_send';
        return true;
      }

      final response = await service.createShare(
        coachId: resolvedCoachId,
        swingLibraryId: swingId,
        practiceNoteId: payload['practice_note_id'] as String?,
        message: payload['message'] as String?,
        idempotencyKey: _idempotencyKey,
        status: 'sent',
        isSwingVideo: true,
        isAiAnalysis: false,
        isPersonalNotesAndTips: payload['isPersonalNotesAndTips'] == true,
        allowDrawOnVideo: payload['allowDrawOnVideo'] == true ||
            payload['allowCoachToDraw'] == true,
      );
      _applyShareResponse(response);
      _watchStatus();
      return true;
    } on ApiError catch (e) {
      if (e.statusCode == 0 && resolvedCoachId.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await _queue(prefs, _payload(resolvedCoachId, swingId));
        shareStatus = 'waiting_to_send';
        return true;
      }
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> flushQueuedShare() async {
    if (!await _isOnline()) return;
    final prefs = await SharedPreferences.getInstance();
    final service = GolferService(
      apiService: ApiService(sharedPreferences: prefs),
    );
    final hadMine = (await _loadQueue(prefs)).any(
      (item) => item['idempotencyKey'] == _idempotencyKey,
    );
    try {
      await service.flushQueuedShares();
    } catch (_) {
      return;
    }
    final stillQueued = (await _loadQueue(prefs)).any(
      (item) => item['idempotencyKey'] == _idempotencyKey,
    );
    if (stillQueued) {
      shareStatus = 'waiting_to_send';
      notifyListeners();
      return;
    }
    if (hadMine && shareStatus == 'waiting_to_send') {
      shareStatus = 'sent';
    }
    await _applySentMatch(service);
    _watchStatus();
    notifyListeners();
  }

  Future<void> _restoreExistingShare() async {
    final prefs = await SharedPreferences.getInstance();
    final queued = await _loadQueue(prefs);
    final mine = queued.where(
      (item) => item['idempotencyKey'] == _idempotencyKey,
    );
    if (mine.isNotEmpty && !await _isOnline()) {
      shareStatus = 'waiting_to_send';
      notifyListeners();
      return;
    }
    if (await _isOnline()) await _loadAssignedCoach();
    await _loadLinkedNote();
    await flushQueuedShare();
  }

  Future<void> _loadAssignedCoach() async {
    final named = coachName.trim().isNotEmpty && coachName != 'Coach';
    if (named && (coachId?.trim().isNotEmpty ?? false)) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final profile = await service.getMyProfile();
      final data = profile['data'];
      if (data is! Map) return;
      final coach = data['coach'];
      if (coach is! Map) return;
      final name = '${coach['name'] ?? ''}'.trim();
      final photo = '${coach['profileUrl'] ?? coach['avatar'] ?? ''}'.trim();
      final id = '${coach['_id'] ?? coach['id'] ?? ''}'.trim();
      if (!named && name.isNotEmpty) coachName = name;
      if ((coachProfileUrl == null || coachProfileUrl!.isEmpty) &&
          photo.startsWith('http')) {
        coachProfileUrl = photo;
      }
      if ((coachId == null || coachId!.trim().isEmpty) && id.isNotEmpty) {
        coachId = id;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadLinkedNote() async {
    if (hasLinkedPracticeNote) return;
    final swingId = swingLibraryId?.trim() ?? '';
    if (swingId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('linked_practice_note_$swingId');
    if (cached != null && cached.trim().isNotEmpty) {
      practiceNoteId = cached.trim();
      _rebuildIncludes();
      notifyListeners();
      return;
    }
    try {
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final response = await service.getSwingLibraryById(swingId);
      final data = response['data'];
      if (data is! Map) return;
      final id = _noteIdFrom(Map<String, dynamic>.from(data));
      if (id == null) return;
      practiceNoteId = id;
      _rebuildIncludes();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _applySentMatch(GolferService service) async {
    final swingId = swingLibraryId?.trim() ?? '';
    if (swingId.isEmpty) return;
    try {
      final response = await service.getSentShares();
      final match = _matchShare(_asList(response['data']), swingId);
      if (match != null) _applyShareMap(match);
    } catch (_) {}
  }

  String? _noteIdFrom(Map<String, dynamic> source) {
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
      'swingLibrary',
    ];
    for (final key in objectKeys) {
      final value = source[key];
      final id = _idOf(value);
      if (id != null && key != 'swingLibrary') return id;
      if (value is Map) {
        final nested = _noteIdFrom(Map<String, dynamic>.from(value));
        if (nested != null) return nested;
      }
    }
    final notes = source['notes'] ?? source['practiceNotes'];
    if (notes is List && notes.isNotEmpty) return _idOf(notes.first);
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

  void _watchStatus() {
    _statusTimer?.cancel();
    final id = shareId;
    if (id == null || id.isEmpty) return;
    final current = shareStatus.toLowerCase();
    if (current == 'coach_replied' || current == 'responded') return;
    _statusTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final service = GolferService(
          apiService: ApiService(sharedPreferences: prefs),
        );
        final response = await service.getShareFullDetails(id);
        final data = response['data'];
        if (data is Map) {
          final next = '${data['status'] ?? ''}'.trim();
          if (next.isNotEmpty && next != shareStatus) {
            shareStatus = next;
            notifyListeners();
          }
          if (labelForShareStatus(next) == 'Coach Replied') {
            _statusTimer?.cancel();
          }
        }
      } catch (_) {}
    });
  }

  Map<String, dynamic> _payload(String resolvedCoachId, String swingId) {
    final noteOn = _isOn('Include Practice Note');
    return {
      'coachId': resolvedCoachId,
      'swingLibraryId': swingId,
      'idempotencyKey': _idempotencyKey,
      'message': questionController.text.trim(),
      'practice_note_id': noteOn ? practiceNoteId : null,
      'allowDrawOnVideo': _isOn('Allow Coach to Draw on Video'),
      // 'allowCoachToDraw': _isOn('Allow Coach to Draw on Video'),
      'isPersonalNotesAndTips': noteOn && hasLinkedPracticeNote,
      'status': 'waiting_to_send',
    };
  }

  bool _isOn(String title) {
    for (final item in includeItems) {
      if (item.title == title) return item.isOn;
    }
    return false;
  }

  Future<String> _resolveCoachId(GolferService service) async {
    var resolved = coachId?.trim() ?? '';
    if (resolved.isNotEmpty) return resolved;
    final profile = await service.getMyProfile();
    final data = profile['data'];
    if (data is Map) {
      final direct = '${data['coachId'] ?? data['assignedCoach'] ?? ''}'.trim();
      if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(direct)) return direct;
      final coach = data['coach'];
      if (coach is Map) {
        resolved = '${coach['_id'] ?? coach['id'] ?? ''}';
      } else if (coach != null) {
        resolved = coach.toString();
      }
    }
    return resolved;
  }

  void _applyShareResponse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      _applyShareMap(Map<String, dynamic>.from(data));
    }
    if (shareStatus.isEmpty) shareStatus = 'sent';
  }

  void _applyShareMap(Map<String, dynamic> data) {
    final id = '${data['_id'] ?? data['id'] ?? ''}'.trim();
    if (id.isNotEmpty) shareId = id;
    final status = '${data['status'] ?? ''}'.trim();
    if (status.isNotEmpty) shareStatus = status;
  }

  Map<String, dynamic>? _matchShare(List<dynamic> items, String swingId) {
    for (final item in items) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final swing = map['swingLibrary'];
      final swingValue = swing is Map
          ? '${swing['_id'] ?? swing['id'] ?? ''}'
          : '${swing ?? map['swingLibraryId'] ?? ''}';
      if (swingValue == swingId) return map;
    }
    return null;
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['results', 'shares', 'items', 'docs', 'data']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Future<bool> _isOnline() async {
    try {
      final dynamic result = await Connectivity().checkConnectivity();
      if (result is List) {
        return result.any((item) => item != ConnectivityResult.none);
      }
      return result != ConnectivityResult.none;
    } catch (_) {
      return true;
    }
  }

  Future<void> _queue(SharedPreferences prefs, Map<String, dynamic> item) async {
    final items = await _loadQueue(prefs);
    items.removeWhere((e) => e['idempotencyKey'] == item['idempotencyKey']);
    items.add(item);
    await _saveQueue(prefs, items);
  }

  Future<List<Map<String, dynamic>>> _loadQueue(SharedPreferences prefs) async {
    final raw = prefs.getString(ApiConstants.keyOfflineShares);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveQueue(
    SharedPreferences prefs,
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) {
      await prefs.remove(ApiConstants.keyOfflineShares);
      return;
    }
    await prefs.setString(ApiConstants.keyOfflineShares, jsonEncode(items));
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _connectivitySub?.cancel();
    questionController.dispose();
    super.dispose();
  }
}
