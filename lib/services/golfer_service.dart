import 'dart:convert';
import 'dart:io';

import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/offline_swing_queue.dart';
import 'package:golf_training_app/utils/api_constants.dart';
import 'package:http_parser/http_parser.dart';

class GolferService {
  GolferService({required ApiService apiService}) : _api = apiService;

  final ApiService _api;

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _api.get(ApiConstants.getMyProfile);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getHomeSummary() async {
    final response = await _api.get(ApiConstants.home);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getMyProgress() async {
    final response = await _api.get(ApiConstants.progress);
    return Map<String, dynamic>.from(response as Map);
  }

  /// GET `/meta/compare-six-weeks` — this week vs the same week 6 weeks ago.
  Future<Map<String, dynamic>> getCompareSixWeeks() async {
    final response = await _api.get(ApiConstants.compareSixWeeks);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> updateHandicap(num handicap) async {
    try {
      final response = await _api.put(
        ApiConstants.updateHandicapUser,
        body: {'handicap': handicap},
      );
      return Map<String, dynamic>.from(response as Map);
    } on ApiError catch (e) {
      if (e.statusCode != 404 && e.statusCode != 405) rethrow;
      final response = await _api.patch(
        ApiConstants.updateHandicap,
        body: {'handicap': handicap},
      );
      return Map<String, dynamic>.from(response as Map);
    }
  }

  Future<Map<String, dynamic>> getPaywallStatus() async {
    final response = await _api.get(ApiConstants.paywallStatus);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getPlans() async {
    final response = await _api.get(ApiConstants.plans);
    return Map<String, dynamic>.from(response as Map);
  }

  /// Primary €14.99/mo launch plan with 3-day trial.
  Future<Map<String, dynamic>> getLaunchPlan() async {
    final response = await _api.get(ApiConstants.launchPlan);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> startTrial({required String planId}) async {
    final response = await _api.post(
      ApiConstants.startTrial,
      body: {'planId': planId},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> verifyAppleReceipt({
    required String receiptData,
    required String productId,
    String? transactionId,
  }) async {
    final body = <String, dynamic>{
      'receiptData': receiptData,
      'productId': productId,
    };
    if (transactionId != null && transactionId.isNotEmpty) {
      body['transactionId'] = transactionId;
    }
    final response =
        await _api.post(ApiConstants.verifyAppleReceipt, body: body);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> verifyGoogleReceipt({
    required String purchaseToken,
    required String productId,
    required String packageName,
  }) async {
    final response = await _api.post(
      ApiConstants.verifyGoogleReceipt,
      body: {
        'purchaseToken': purchaseToken,
        'productId': productId,
        'packageName': packageName,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> validatePromoCode({
    required String code,
    required String planId,
  }) async {
    final response = await _api.post(
      ApiConstants.validatePromoCode,
      body: {
        'code': code.trim().toUpperCase(),
        'planId': planId,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> redeemPromoCode({
    required String code,
    required String planId,
  }) async {
    final response = await _api.post(
      ApiConstants.redeemPromoCode,
      body: {
        'code': code.trim().toUpperCase(),
        'planId': planId,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> requestEmailChange({
    required String newEmail,
  }) async {
    final response = await _api.post(
      ApiConstants.requestEmailChange,
      body: {'newEmail': newEmail},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> verifyEmailChange({
    required String newEmail,
    required String otp,
  }) async {
    final response = await _api.post(
      ApiConstants.verifyEmailChange,
      body: {'newEmail': newEmail, 'otp': otp},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> downloadMyData() async {
    final response = await _api.get(ApiConstants.downloadMyData);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> deleteAccount({
    String? password,
    String? confirmation,
  }) async {
    final body = <String, dynamic>{};
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    if (confirmation != null && confirmation.isNotEmpty) {
      body['confirmation'] = confirmation;
    }
    final response = await _api.post(ApiConstants.deleteAccount, body: body);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> updateMyProfile({
    required String name,
    required String age,
    // Gender removed from docs v2 — optional / ignored when omitted.
    String? gender,
    required double handicap,
    required String practiceSessionPerWeek,
    bool? usesGolfImproveStand,
    String? profileImagePath,
    String? role,
  }) async {
    final ageRange = age.replaceAll('–', '-').replaceAll('—', '-');
    final handicapValue = handicap.toStringAsFixed(1);
    final fields = <String, String>{
      'name': name,
      'age_range': ageRange,
      // 'gender': gender ?? 'other',
      'handicap_index': handicapValue,
      'handicap': handicapValue,
      'practice_sessions_per_week': practiceSessionPerWeek,
      'practiceSessionPerWeek': practiceSessionPerWeek,
    };
    // if (gender != null && gender.isNotEmpty) {
    //   fields['gender'] = gender;
    // }
    if (role != null && role.isNotEmpty) {
      fields['role'] = role;
    }
    if (usesGolfImproveStand != null) {
      fields['usesGolfImproveStand'] = usesGolfImproveStand.toString();
      fields['uses_golfimprove_stand'] = usesGolfImproveStand.toString();
    }
    final files = <String, String>{};
    final types = <String, MediaType>{};
    final names = <String, String>{};
    final imagePath = profileImagePath?.trim() ?? '';
    if (imagePath.isNotEmpty) {
      files['profile'] = imagePath;
      types['profile'] = _imageContentType(imagePath);
      names['profile'] = _imageFileName(imagePath);
    }
    final response = await _api.multipartRequest(
      ApiConstants.updateRegisterProfile,
      method: 'PATCH',
      fields: fields,
      files: files.isEmpty ? null : files,
      fileContentTypes: types.isEmpty ? null : types,
      fileNames: names.isEmpty ? null : names,
    );
    return Map<String, dynamic>.from(response as Map);
  }

  MediaType _imageContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    return MediaType('image', 'jpeg');
  }

  String _imageFileName(String path) {
    final name = path.replaceAll('\\', '/').split('/').last.trim();
    if (name.contains('.')) return name;
    return 'profile.jpg';
  }

  /// POST `/swing/compare`. Accepts Swing or SwingLibrary ids.
  Future<Map<String, dynamic>> compareSwings({
    required String firstSwingId,
    required String secondSwingId,
  }) async {
    final body = {
      'firstSwingId': firstSwingId,
      'secondSwingId': secondSwingId,
    };
    try {
      final response = await _api.post(ApiConstants.swingCompare, body: body);
      return Map<String, dynamic>.from(response as Map);
    } on ApiError catch (error) {
      if (error.statusCode != 404) rethrow;
      final response =
          await _api.post(ApiConstants.swingLibraryCompare, body: body);
      return Map<String, dynamic>.from(response as Map);
    }
  }

  Future<Map<String, dynamic>> createShare({
    required String coachId,
    required String swingLibraryId,
    String? practiceNoteId,
    String? message,
    String? idempotencyKey,
    String status = 'sent',
    bool isSwingVideo = true,
    bool isAiAnalysis = false,
    bool isPersonalNotesAndTips = false,
    bool allowDrawOnVideo = false,
    // Legacy alias — prefer [allowDrawOnVideo].
    bool allowCoachToDraw = false,
  }) async {
    final drawAllowed = allowDrawOnVideo || allowCoachToDraw;
    final body = <String, dynamic>{
      'coachId': coachId,
      'swingLibraryId': swingLibraryId,
      'idempotencyKey': idempotencyKey ??
          'share_${coachId}_$swingLibraryId',
      'status': status,
      'isSwingVideo': isSwingVideo,
      'isAiAnalysis': isAiAnalysis,
      'isPersonalNotesAndTips': isPersonalNotesAndTips,
      'allowDrawOnVideo': drawAllowed,
      // 'allowCoachToDraw': drawAllowed, // legacy field name
    };
    if (message != null && message.trim().isNotEmpty) {
      body['message'] = message.trim();
    }
    if (practiceNoteId != null && practiceNoteId.isNotEmpty) {
      body['practice_note_id'] = practiceNoteId;
    }
    final response = await _api.post(ApiConstants.shareCreate, body: body);
    return Map<String, dynamic>.from(response as Map);
  }

  /// Transitions an offline queued share `waiting_to_send` → `sent`.
  Future<Map<String, dynamic>> sendQueuedShare(String shareId) async {
    final response = await _api.patch(
      ApiConstants.shareSendQueued(shareId),
      body: <String, dynamic>{},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getSentShares() async {
    final response = await _api.get(ApiConstants.shareSent);
    return Map<String, dynamic>.from(response as Map);
  }

  /// Posts queued share payloads created while the device was offline.
  /// Network and server errors stay in the queue. Other failures are dropped
  /// so a rejected payload does not retry forever.
  Future<void> flushQueuedShares() async {
    final prefs = _api.sharedPreferences;
    final raw = prefs.getString(ApiConstants.keyOfflineShares);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return;

    final remaining = <Map<String, dynamic>>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final coachId = '${map['coachId'] ?? ''}'.trim();
      final swingLibraryId = '${map['swingLibraryId'] ?? ''}'.trim();
      if (coachId.isEmpty || swingLibraryId.isEmpty) continue;
      try {
        final existingShareId =
            '${map['_id'] ?? map['shareId'] ?? map['id'] ?? ''}'.trim();
        final queuedStatus = '${map['status'] ?? ''}'.trim();
        if (existingShareId.isNotEmpty &&
            (queuedStatus == 'waiting_to_send' ||
                map['queuedLocally'] == true)) {
          await sendQueuedShare(existingShareId);
        } else {
          await createShare(
            coachId: coachId,
            swingLibraryId: swingLibraryId,
            practiceNoteId: map['practice_note_id']?.toString(),
            message: map['message']?.toString(),
            idempotencyKey: map['idempotencyKey']?.toString(),
            status: 'sent',
            isSwingVideo: true,
            isAiAnalysis: map['isAiAnalysis'] == true,
            isPersonalNotesAndTips: map['isPersonalNotesAndTips'] == true,
            allowDrawOnVideo: map['allowDrawOnVideo'] == true ||
                map['allowCoachToDraw'] == true,
          );
        }
      } on ApiError catch (error) {
        if (error.statusCode == 0 || error.statusCode >= 500) {
          remaining.add(map);
        }
      } catch (_) {
        remaining.add(map);
      }
    }

    if (remaining.isEmpty) {
      await prefs.remove(ApiConstants.keyOfflineShares);
    } else {
      await prefs.setString(ApiConstants.keyOfflineShares, jsonEncode(remaining));
    }
  }

  Future<Map<String, dynamic>> startPracticePlan(String shareId) async {
    final response = await _api.post(
      ApiConstants.practicePlanStart(shareId),
      body: <String, dynamic>{},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getPracticePlan(String shareId) async {
    final response = await _api.get(ApiConstants.practicePlanMyPlan(shareId));
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> togglePracticeSession({
    required String sessionId,
  }) async {
    final response = await _api.patch(
      ApiConstants.practicePlanToggleSession(sessionId),
      body: <String, dynamic>{},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Prefer session-id toggle; fall back to legacy index-based complete.
  Future<Map<String, dynamic>> completeCoachPracticeSession({
    required String shareId,
    required int sessionIndex,
    String? sessionId,
    bool isCompleted = true,
  }) async {
    final id = sessionId?.trim() ?? '';
    if (id.isNotEmpty) {
      try {
        return await togglePracticeSession(sessionId: id);
      } on ApiError catch (e) {
        if (e.statusCode != 404 && e.statusCode != 405) rethrow;
      }
    }
    final response = await _api.patch(
      ApiConstants.completeCoachPracticeSession(shareId, sessionIndex),
      body: {'is_completed': isCompleted},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> completeAiPracticeSession({
    required String swingLibraryId,
    required int sessionIndex,
    bool isCompleted = true,
  }) async {
    final response = await _api.patch(
      ApiConstants.completeAiPracticeSession(swingLibraryId, sessionIndex),
      body: {'is_completed': isCompleted},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> saveDrillPlan({
    required String title,
    required String recommendedDrill,
    required List<Map<String, dynamic>> practicePlan,
    String? clubType,
    String? analysisId,
    String? conversationId,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'recommendedDrill': recommendedDrill,
      'practicePlan': practicePlan,
    };
    if (clubType != null && clubType.isNotEmpty) body['clubType'] = clubType;
    if (analysisId != null && analysisId.isNotEmpty) {
      body['analysisId'] = analysisId;
    }
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversationId'] = conversationId;
    }
    if (note != null && note.isNotEmpty) body['note'] = note;

    // Prefer live AI coach notes endpoint; fall back to legacy save-drill-plan.
    try {
      final response =
          await _api.post(ApiConstants.aiCoachSaveToNotes, body: body);
      return Map<String, dynamic>.from(response as Map);
    } on ApiError catch (e) {
      if (e.statusCode != 404 && e.statusCode != 405) rethrow;
      final response = await _api.post(ApiConstants.saveDrillPlan, body: body);
      return Map<String, dynamic>.from(response as Map);
    }
  }

  /// Conversational AI coach (`POST /ai-coach/chat`).
  Future<Map<String, dynamic>> aiCoachChat({
    required String message,
    String? clubType,
    String? sessionId,
    List<Map<String, dynamic>> conversationHistory = const [],
  }) async {
    final body = <String, dynamic>{
      'message': message,
      if (clubType != null && clubType.isNotEmpty) 'clubType': clubType,
      if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
      if (conversationHistory.isNotEmpty)
        'conversationHistory': conversationHistory,
    };
    final response = await _api.post(
      ApiConstants.aiCoachChat,
      body: body,
      timeout: _api.analyzeTimeout,
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> aiCoachShareWithCoach({
    required String conversationId,
    required String coachId,
    String? message,
    String? planTitle,
    String? recommendedDrill,
  }) async {
    final body = <String, dynamic>{
      'conversationId': conversationId,
      'coachId': coachId,
      if (message != null && message.isNotEmpty) 'message': message,
      if (planTitle != null && planTitle.isNotEmpty) 'planTitle': planTitle,
      if (recommendedDrill != null && recommendedDrill.isNotEmpty)
        'recommendedDrill': recommendedDrill,
    };
    final response =
        await _api.post(ApiConstants.aiCoachShareWithCoach, body: body);
    return Map<String, dynamic>.from(response as Map);
  }

  /// Asks the AI coach. Prefers `/ai-coach/chat`, then ask-coach / ask aliases.
  Future<Map<String, dynamic>> askCoach({
    required String swingId,
    required String question,
    String? clubType,
    List<Map<String, dynamic>> conversationHistory = const [],
  }) async {
    try {
      return await aiCoachChat(
        message: question,
        clubType: clubType,
        sessionId: swingId,
        conversationHistory: conversationHistory,
      );
    } on ApiError catch (e) {
      if (e.statusCode != 404 && e.statusCode != 405) rethrow;
    }
    try {
      final response = await _api.post(
        ApiConstants.askCoach(swingId),
        body: {'question': question},
        timeout: _api.analyzeTimeout,
      );
      return Map<String, dynamic>.from(response as Map);
    } on ApiError catch (e) {
      if (e.statusCode != 404 && e.statusCode != 405) rethrow;
      return askSwingQuestion(swingId: swingId, question: question);
    }
  }

  /// Unread badge count for the Home bell.
  Future<int> getUnreadNotificationCount() async {
    final response = await _api.get(ApiConstants.notificationsUnreadCount);
    final data = response is Map ? response['data'] : null;
    final count = data is Map ? data['unreadCount'] : null;
    return count is num ? count.toInt() : 0;
  }

  Future<void> markAllNotificationsRead() async {
    await _api.patch(ApiConstants.notificationsMarkAllRead, body: const {});
  }

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse(ApiConstants.notifications).replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
      },
    );
    final response = await _api.get(uri.toString());
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getFilterCategories() async {
    final response = await _api.get(ApiConstants.filterLibraryCategories);
    return Map<String, dynamic>.from(response as Map);
  }

  /// GET `/swing/my-swings` — newest first, with club, angle, and date filters.
  Future<Map<String, dynamic>> getMySwings({
    String? clubType,
    String? cameraAngle,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
    String sort = '-createdAt',
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      'sort': sort,
    };
    if (clubType != null && clubType.isNotEmpty) query['clubType'] = clubType;
    if (cameraAngle != null && cameraAngle.isNotEmpty) {
      query['cameraAngle'] = cameraAngle;
    }
    if (startDate != null && startDate.isNotEmpty) query['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) query['endDate'] = endDate;

    final uri = Uri.parse(ApiConstants.mySwings).replace(queryParameters: query);
    final response = await _api.get(uri.toString());
    return Map<String, dynamic>.from(response as Map);
  }

  /// Every swing of the golfer as shown in the Swing Library: analyses from
  /// `/swing-library/my-library` first (they open the full analysis), then
  /// recorded swings from `/swing/my-swings` that have no analysis yet
  /// (tagged `hasAnalysis: false`). Each recording appears once.
  ///
  /// Library, Compare and Progress all use this, so a swing id picked on one
  /// screen is always found on the others.
  Future<List<Map<String, dynamic>>> getAllMySwingRecords() async {
    final collected = <Map<String, dynamic>>[];
    Object? libraryError;
    try {
      final library = await getMyLibrary(limit: 100);
      collected.addAll(_recordMaps(library['data']));
    } catch (e) {
      libraryError = e;
    }

    final seen = <String>{
      for (final item in collected) ..._recordIdentityKeys(item),
    };
    try {
      for (var page = 1; page <= 5; page++) {
        final response = await getMySwings(
          page: page,
          limit: 50,
          sort: '-createdAt',
        );
        for (final item in _recordMaps(response['data'])) {
          final keys = _recordIdentityKeys(item);
          if (keys.any(seen.contains)) continue;
          seen.addAll(keys);
          // Already analyzed on the Swing doc — skip duplicate library row.
          final analyzed = item['isAnalyzed'] == true ||
              (item['analysisId']?.toString().trim().isNotEmpty ?? false);
          if (analyzed) continue;
          collected.add({...item, 'hasAnalysis': false});
        }
        final meta = response['meta'];
        final rawTotal = meta is Map ? meta['totalPage'] : null;
        final totalPage = rawTotal is num ? rawTotal.toInt() : 1;
        if (page >= totalPage || totalPage == 0) break;
      }
    } on ApiError catch (error) {
      final notAvailable = error.statusCode == 404 || error.statusCode == 405;
      if (!notAvailable && collected.isEmpty) rethrow;
    }
    if (collected.isEmpty && libraryError != null) throw libraryError;
    return collected;
  }

  /// Recordings that exist in `/swing/my-swings` but not yet in
  /// `/swing-library/my-library`. Calls `POST /swing/analyze/video/:id`
  /// so the backend creates the library analysis rows.
  Future<int> backfillMissingLibraryAnalyses({int maxItems = 8}) async {
    final records = await getAllMySwingRecords();
    final pending = <String>[];
    for (final item in records) {
      if (item['hasAnalysis'] == false) {
        final id = extractSwingId(item) ??
            item['_id']?.toString() ??
            item['id']?.toString();
        if (id != null && id.trim().isNotEmpty) {
          pending.add(id.trim());
        }
      }
    }
    if (pending.isEmpty) return 0;

    var created = 0;
    for (final swingId in pending.take(maxItems)) {
      try {
        await analyzeSwingVideo(swingId);
        created++;
      } on ApiError catch (error) {
        // Paywall / not found — stop hammering; leave the rest pending.
        if (error.statusCode == 402 ||
            error.statusCode == 403 ||
            error.statusCode == 404) {
          break;
        }
      } catch (_) {}
    }
    return created;
  }

  static List<Map<String, dynamic>> _recordMaps(dynamic data) {
    List<dynamic> list = const [];
    if (data is List) {
      list = data;
    } else if (data is Map) {
      for (final key in ['results', 'swings', 'items', 'docs', 'data']) {
        final value = data[key];
        if (value is List) {
          list = value;
          break;
        }
      }
    }
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Keys that identify the same recording across both endpoints
  /// (swing id, linked swing id, video file).
  static Set<String> _recordIdentityKeys(Map<String, dynamic> item) {
    String? idOf(dynamic raw) {
      if (raw is Map) raw = raw['_id'] ?? raw['id'];
      final value = raw?.toString().trim() ?? '';
      return value.isEmpty ? null : value;
    }

    final keys = <String>{};
    final swingId = idOf(item['swingId']) ?? idOf(item['swing']);
    if (swingId != null) keys.add('id:$swingId');
    final id = idOf(item['_id']) ?? idOf(item['id']);
    if (id != null) keys.add('id:$id');
    final analysisId = idOf(item['analysisId']);
    if (analysisId != null) keys.add('id:$analysisId');
    final video = (item['videoUrl'] ?? '').toString().split('?').first.trim();
    if (video.isNotEmpty) keys.add('video:$video');
    return keys;
  }

  Future<Map<String, dynamic>> getMyLibrary({
    String? clubType,
    String? cameraAngle,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (clubType != null && clubType.isNotEmpty) {
      query['clubType'] = clubType;
    }
    if (cameraAngle != null && cameraAngle.isNotEmpty) {
      query['cameraAngle'] = cameraAngle;
    }

    final uri = Uri.parse(ApiConstants.allLibrary).replace(
      queryParameters: query,
    );
    final response = await _api.get(uri.toString());
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getSwingLibraryById(String id) async {
    final response = await _api.get(ApiConstants.singleLibraryById(id));
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getShareFullDetails(String id) async {
    final response = await _api.get(ApiConstants.fullDetails(id));
    return Map<String, dynamic>.from(response as Map);
  }

  /// Session Timeline.
  /// Share records use `GET /share-swing/single/:shareId`, then
  /// `GET /share-swing/find/:id` when that route is not available.
  /// Library records use `GET /swing-library/find/:analysisId`.
  Future<Map<String, dynamic>> getSessionTimeline({
    String? shareId,
    String? analysisId,
  }) async {
    final share = shareId?.trim() ?? '';
    final analysis = analysisId?.trim() ?? '';

    if (share.isNotEmpty) {
      try {
        final response = await _api.get(ApiConstants.shareSingle(share));
        return Map<String, dynamic>.from(response as Map);
      } on ApiError catch (error) {
        if (error.statusCode != 404 && error.statusCode != 405) rethrow;
        final response = await _api.get(ApiConstants.shareFind(share));
        return Map<String, dynamic>.from(response as Map);
      }
    }

    if (analysis.isNotEmpty) {
      return getSwingLibraryById(analysis);
    }

    throw ApiError(
      message: 'This session has no timeline yet.',
      statusCode: 400,
    );
  }

  Future<Map<String, dynamic>> askSwingQuestion({
    required String swingId,
    required String question,
  }) async {
    final response = await _api.post(
      ApiConstants.askSwingQuestion(swingId),
      body: {'question': question},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// GET `/swing-category/camera` — angles, modes, and club categories.
  Future<Map<String, dynamic>> getCameraCategories() async {
    final response = await _api.get(ApiConstants.cameraCategories);
    return Map<String, dynamic>.from(response as Map);
  }

  /// POST `/swing/analyzer` — multipart video upload with telemetry.
  Future<Map<String, dynamic>> uploadSwingForAnalysis({
    required String videoPath,
    required String clubType,
    required String cameraAngle,
    required String recordingMode,
    required String handedness,
    required num duration,
    required num trimStart,
    required num trimEnd,
    required Map<String, dynamic> cameraData,
    required Map<String, dynamic> calibration,
    required Map<String, dynamic> swingPhases,
  }) async {
    // Import normalizer via capture_session would create a views→services cycle.
    // Keep lightweight inline normalization here for API safety.
    String normMode(String raw) {
      final n = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
      if (n.contains('slow')) return 'slow-mo';
      if (n.contains('video')) return 'video';
      return 'swing';
    }

    String normAngle(String raw) {
      final n = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
      if (n.contains('face')) return 'Face On';
      if (n.contains('down') || n.contains('line') || n.contains('dtl')) {
        return 'Down The Line';
      }
      // Side On / Overhead deprecated — API rejects with 400.
      // if (n.contains('side')) return 'Side On';
      // if (n.contains('over')) return 'Overhead';
      return 'Face On';
    }

    String normClub(String raw) {
      final n = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
      if (n.contains('face') ||
          n.contains('line') ||
          n.contains('side') ||
          n.contains('over') ||
          n.contains('slow') ||
          n == 'swing' ||
          n == 'video' ||
          n.isEmpty) {
        return 'Driver';
      }
      if (n.contains('driver')) return 'Driver';
      if (n.contains('iron')) return 'Irons';
      if (n.contains('wedge')) return 'Wedges';
      if (n.contains('putt')) return 'Putter';
      return raw.trim();
    }

    final safeClub = normClub(clubType);
    final safeAngle = normAngle(cameraAngle);
    final safeMode = normMode(recordingMode);
    final safeHand =
        handedness.toLowerCase().contains('left') ? 'left' : 'right';
    final safeDuration = duration < 1 ? 1 : duration;
    final safeTrimStart = trimStart < 0 ? 0 : trimStart;
    final safeTrimEnd =
        trimEnd <= safeTrimStart ? safeDuration : trimEnd;

    final fields = <String, String>{
      'clubType': safeClub,
      'cameraAngle': safeAngle,
      'recordingMode': safeMode,
      'handedness': safeHand,
      'duration': safeDuration.toString(),
      'trimStart': safeTrimStart.toString(),
      'trimEnd': safeTrimEnd.toString(),
      'cameraData': jsonEncode({
        ...cameraData,
        'view': safeAngle.toLowerCase().contains('face')
            ? 'face_on'
            : 'down_the_line',
      }),
      'calibration': jsonEncode(calibration),
      'swingPhases': jsonEncode(swingPhases),
    };

    final response = await _api.multipartRequest(
      ApiConstants.swingAnalyzer,
      method: 'POST',
      fields: fields,
      files: {'video': videoPath},
      fileNames: {'video': 'swing_clip.mp4'},
      fileContentTypes: {'video': MediaType('video', 'mp4')},
      timeout: const Duration(minutes: 3),
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// POST `/swing/analyze/video/:id` — run AI analysis on an uploaded swing.
  Future<Map<String, dynamic>> analyzeSwingVideo(String swingId) async {
    final response = await _api.post(
      ApiConstants.analyzeSwingVideo(swingId),
      body: <String, dynamic>{},
      timeout: _api.analyzeTimeout,
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Production record path:
  /// 1) `POST /swing/analyzer` — upload video + telemetry (saves the clip)
  /// 2) `POST /swing/analyze/video/:id` — generate library analysis cards
  Future<Map<String, dynamic>> uploadAndAnalyzeSwing({
    required String videoPath,
    required String clubType,
    required String cameraAngle,
    required String recordingMode,
    required String handedness,
    required num duration,
    required num trimStart,
    required num trimEnd,
    required Map<String, dynamic> cameraData,
    required Map<String, dynamic> calibration,
    required Map<String, dynamic> swingPhases,
  }) async {
    final upload = await uploadSwingForAnalysis(
      videoPath: videoPath,
      clubType: clubType,
      cameraAngle: cameraAngle,
      recordingMode: recordingMode,
      handedness: handedness,
      duration: duration,
      trimStart: trimStart,
      trimEnd: trimEnd,
      cameraData: cameraData,
      calibration: calibration,
      swingPhases: swingPhases,
    );

    final uploadData = _asResponseMap(upload['data']) ?? upload;
    final swingId = extractSwingId(uploadData) ?? extractSwingId(upload);
    if (swingId == null || swingId.isEmpty) {
      return upload;
    }

    try {
      final analysis = await analyzeSwingVideo(swingId);
      final analysisData = _asResponseMap(analysis['data']) ?? analysis;
      return {
        ...upload,
        'data': {
          ...uploadData,
          ...analysisData,
          'swingId': swingId,
        },
        'swingId': swingId,
      };
    } on ApiError catch (error) {
      // Clip is already saved; analysis can finish later from the detail screen.
      if (error.statusCode == 0 || error.statusCode >= 500) {
        return {
          ...upload,
          'swingId': swingId,
          'analysisPending': true,
        };
      }
      rethrow;
    }
  }

  /// Prefer analyzer + analyze/video. Falls back to pre-signed create when
  /// the analyzer route is unavailable. Network failures enqueue for sync.
  Future<Map<String, dynamic>> recordSwing({
    required String videoPath,
    required String clubType,
    required String cameraAngle,
    required String recordingMode,
    required String handedness,
    required num duration,
    required num trimStart,
    required num trimEnd,
    required Map<String, dynamic> cameraData,
    required Map<String, dynamic> calibration,
    required Map<String, dynamic> swingPhases,
  }) async {
    final file = File(videoPath);
    final fileSize = await file.exists() ? await file.length() : 0;
    final localId = 'mob_${DateTime.now().microsecondsSinceEpoch}';
    final idempotencyKey = 'sync_$localId';
    final recordedAt = DateTime.now().toUtc().toIso8601String();

    try {
      return await uploadAndAnalyzeSwing(
        videoPath: videoPath,
        clubType: clubType,
        cameraAngle: cameraAngle,
        recordingMode: recordingMode,
        handedness: handedness,
        duration: duration,
        trimStart: trimStart,
        trimEnd: trimEnd,
        cameraData: cameraData,
        calibration: calibration,
        swingPhases: swingPhases,
      );
    } on ApiError catch (e) {
      if (e.statusCode == 0) {
        await OfflineSwingQueue.enqueue(
          _api.sharedPreferences,
          {
            'local_id': localId,
            'idempotencyKey': idempotencyKey,
            'client_session_id': 'session_$localId',
            'videoPath': videoPath,
            'clubType': clubType,
            'cameraAngle': cameraAngle,
            'recordingMode': recordingMode,
            'handedness': handedness,
            'duration': duration,
            'trimStart': trimStart,
            'trimEnd': trimEnd,
            'recorded_at': recordedAt,
            'fileSize': fileSize,
            'fileType': 'video/mp4',
            'cameraData': cameraData,
            'calibration': calibration,
            'swingPhases': swingPhases,
            'useAnalyzer': true,
          },
        );
        throw ApiError(
          message:
              'No connection. Your swing was saved and will sync when you are back online.',
          statusCode: 0,
        );
      }
      if (e.statusCode == 404 || e.statusCode == 405) {
        final created = await _recordViaPresigned(
          videoPath: videoPath,
          clubType: clubType,
          cameraAngle: cameraAngle,
          recordingMode: recordingMode,
          duration: duration,
          trimStart: trimStart,
          trimEnd: trimEnd,
          localId: localId,
          idempotencyKey: idempotencyKey,
          recordedAt: recordedAt,
          fileSize: fileSize,
        );
        final createdData = _asResponseMap(created['data']) ?? created;
        final swingId = extractSwingId(createdData) ?? extractSwingId(created);
        if (swingId != null && swingId.isNotEmpty) {
          try {
            final analysis = await analyzeSwingVideo(swingId);
            return {
              ...created,
              'data': analysis['data'] ?? analysis,
              'swingId': swingId,
            };
          } catch (_) {
            return {...created, 'swingId': swingId, 'analysisPending': true};
          }
        }
        return created;
      }
      rethrow;
    }
  }

  Future<void> syncPendingSwings() async {
    final prefs = _api.sharedPreferences;
    final pending = await OfflineSwingQueue.load(prefs);
    if (pending.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    final payloads = <Map<String, dynamic>>[];

    for (final item in pending) {
      final path = item['videoPath']?.toString() ?? '';
      if (!OfflineSwingQueue.fileExists(path)) continue;
      try {
        if (_offlineItemHasTelemetry(item) || item['useAnalyzer'] == true) {
          await _syncOfflineViaAnalyzer(item);
        } else {
          payloads.add(await _uploadOfflinePayload(item));
        }
      } on ApiError catch (e) {
        if (e.statusCode == 0 || e.statusCode >= 500) {
          remaining.add(item);
        }
      } catch (_) {
        remaining.add(item);
      }
    }

    if (payloads.isNotEmpty) {
      try {
        final syncResponse = await _api.post(
          ApiConstants.swingSyncOffline,
          body: {'swings': payloads},
        );
        final syncedIds = _extractSyncedSwingIds(syncResponse);
        for (final swingId in syncedIds) {
          try {
            await analyzeSwingVideo(swingId);
          } catch (_) {}
        }
      } on ApiError catch (e) {
        if (e.statusCode == 0 || e.statusCode >= 500) {
          remaining.addAll(
            pending.where((item) {
              final key = '${item['idempotencyKey'] ?? ''}';
              return payloads.any((p) => p['idempotencyKey'] == key);
            }),
          );
        }
      }
    }

    await OfflineSwingQueue.save(prefs, remaining);
  }

  Future<void> _syncOfflineViaAnalyzer(Map<String, dynamic> item) async {
    final path = item['videoPath'].toString();
    final cameraData = _asResponseMap(item['cameraData']) ??
        <String, dynamic>{'view': 'face_on', 'fps': 30};
    final calibration = _asResponseMap(item['calibration']) ??
        <String, dynamic>{
          'groundPlane': {'detected': true, 'confidence': 0.9},
          'golferDistanceCm': 280,
        };
    final swingPhases = _asResponseMap(item['swingPhases']) ??
        <String, dynamic>{};

    await uploadAndAnalyzeSwing(
      videoPath: path,
      clubType: '${item['clubType'] ?? 'Driver'}',
      cameraAngle: '${item['cameraAngle'] ?? 'Face On'}',
      recordingMode: '${item['recordingMode'] ?? 'swing'}',
      handedness: '${item['handedness'] ?? 'right'}',
      duration: item['duration'] is num ? item['duration'] as num : 1,
      trimStart: item['trimStart'] is num ? item['trimStart'] as num : 0,
      trimEnd: item['trimEnd'] is num ? item['trimEnd'] as num : 1,
      cameraData: cameraData,
      calibration: calibration,
      swingPhases: swingPhases,
    );
  }

  bool _offlineItemHasTelemetry(Map<String, dynamic> item) {
    return item['cameraData'] != null ||
        item['calibration'] != null ||
        item['swingPhases'] != null;
  }

  Map<String, dynamic>? _asResponseMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  List<String> _extractSyncedSwingIds(dynamic response) {
    final root = _asResponseMap(response);
    if (root == null) return const [];
    final data = root['data'];
    final ids = <String>[];
    void collect(dynamic value) {
      final id = extractSwingId(_asResponseMap(value) ?? {});
      if (id != null && id.isNotEmpty) ids.add(id);
    }

    if (data is List) {
      for (final item in data) {
        collect(item);
      }
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in ['swings', 'results', 'items', 'docs']) {
        final list = map[key];
        if (list is List) {
          for (final item in list) {
            collect(item);
          }
          return ids;
        }
      }
      collect(map);
    }
    return ids;
  }

  /// Pulls the raw swing document id from analyzer / create / analyze payloads.
  static String? extractSwingId(Map<String, dynamic> data) {
    String? asId(dynamic raw) {
      if (raw == null) return null;
      if (raw is Map) {
        raw = raw['_id'] ?? raw['id'];
      }
      final text = raw?.toString().trim() ?? '';
      if (text.isEmpty) return null;
      return text;
    }

    return asId(data['swingId']) ??
        asId(data['swing']) ??
        asId(data['_id']) ??
        asId(data['id']);
  }

  Future<Map<String, dynamic>> _uploadOfflinePayload(
    Map<String, dynamic> item,
  ) async {
    final path = item['videoPath'].toString();
    final fileSize = item['fileSize'] is num
        ? (item['fileSize'] as num).toInt()
        : await File(path).length();
    final clubType = '${item['clubType'] ?? 'Driver'}';
    final cameraAngle = '${item['cameraAngle'] ?? 'Face On'}';
    final fileName = path.replaceAll('\\', '/').split('/').last;
    final urlResponse = await _api.post(
      ApiConstants.swingUploadUrl,
      body: {
        'fileName': fileName.isEmpty ? 'swing.mp4' : fileName,
        'fileType': 'video/mp4',
        'clubType': clubType,
        'cameraAngle': cameraAngle,
        'fileSize': fileSize,
      },
    );
    final urlData = urlResponse is Map ? urlResponse['data'] : null;
    if (urlData is! Map) {
      throw ApiError(message: 'Upload URL was not returned.', statusCode: 0);
    }
    final uploadUrl = urlData['uploadUrl']?.toString() ?? '';
    final videoUrl = urlData['videoUrl']?.toString() ?? '';
    if (uploadUrl.isEmpty || videoUrl.isEmpty) {
      throw ApiError(message: 'Upload URL was not returned.', statusCode: 0);
    }
    await _api.putFile(uploadUrl, path, contentType: 'video/mp4');
    return {
      'local_id': item['local_id'],
      'idempotencyKey': item['idempotencyKey'],
      'client_session_id': item['client_session_id'],
      'videoUrl': videoUrl,
      'clubType': clubType,
      'cameraAngle': cameraAngle,
      'recordingMode': item['recordingMode'] ?? 'swing',
      'duration': item['duration'],
      'trimStart': item['trimStart'],
      'trimEnd': item['trimEnd'],
      'recorded_at': item['recorded_at'],
      'fileSize': fileSize,
      'fileType': 'video/mp4',
    };
  }

  Future<Map<String, dynamic>> _recordViaPresigned({
    required String videoPath,
    required String clubType,
    required String cameraAngle,
    required String recordingMode,
    required num duration,
    required num trimStart,
    required num trimEnd,
    required String localId,
    required String idempotencyKey,
    required String recordedAt,
    required int fileSize,
    String? clientSessionId,
  }) async {
    final fileName = videoPath.replaceAll('\\', '/').split('/').last;
    final urlResponse = await _api.post(
      ApiConstants.swingUploadUrl,
      body: {
        'fileName': fileName.isEmpty ? 'swing.mp4' : fileName,
        'fileType': 'video/mp4',
        'clubType': clubType,
        'cameraAngle': cameraAngle,
        'fileSize': fileSize,
      },
    );
    final urlData = urlResponse is Map ? urlResponse['data'] : null;
    if (urlData is! Map) {
      throw ApiError(message: 'Upload URL was not returned.', statusCode: 0);
    }
    final uploadUrl = urlData['uploadUrl']?.toString() ?? '';
    final videoUrl = urlData['videoUrl']?.toString() ?? '';
    if (uploadUrl.isEmpty || videoUrl.isEmpty) {
      throw ApiError(message: 'Upload URL was not returned.', statusCode: 0);
    }
    final headers = urlData['headers'];
    final contentType = headers is Map
        ? (headers['Content-Type']?.toString() ?? 'video/mp4')
        : 'video/mp4';
    await _api.putFile(uploadUrl, videoPath, contentType: contentType);

    final response = await _api.post(
      ApiConstants.swingCreate,
      body: {
        'videoUrl': videoUrl,
        'clubType': clubType,
        'cameraAngle': cameraAngle,
        'recordingMode': recordingMode,
        'duration': duration,
        'trimStart': trimStart,
        'trimEnd': trimEnd,
        'local_id': localId,
        'idempotencyKey': idempotencyKey,
        'client_session_id': clientSessionId ?? 'session_$localId',
        'recorded_at': recordedAt,
        'fileSize': fileSize,
        'fileType': 'video/mp4',
        'syncStatus': 'synced',
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  // ── Practice notes / Golf Logbook (`/note-book`) ──────────────────────────

  Future<Map<String, dynamic>> getMyNotes({
    String? club,
    String sort = 'newest',
    int page = 1,
    int limit = 50,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      'sort': sort,
    };
    if (club != null && club.isNotEmpty && club != 'All Clubs') {
      query['club'] = club;
    }
    final uri =
        Uri.parse(ApiConstants.noteBookMyNotes).replace(queryParameters: query);
    final response = await _api.get(uri.toString());
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> createNote({
    required String title,
    required String description,
    bool isImportant = false,
    bool isPinned = false,
    String clubType = 'All Clubs',
    String? swingId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'note': description,
      'isImportant': isImportant,
      'isPinned': isPinned,
      'pinnedAsReminder': isPinned,
      'clubType': clubType,
      'club': clubType,
    };
    if (swingId != null && swingId.trim().isNotEmpty) {
      body['swingId'] = swingId.trim();
    }
    final response = await _api.post(ApiConstants.noteBookCreate, body: body);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> updateNote({
    required String id,
    String? title,
    String? description,
    bool? isImportant,
    bool? isPinned,
    String? clubType,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) {
      body['description'] = description;
      body['note'] = description;
    }
    if (isImportant != null) body['isImportant'] = isImportant;
    if (isPinned != null) {
      body['isPinned'] = isPinned;
      body['pinnedAsReminder'] = isPinned;
    }
    if (clubType != null) {
      body['clubType'] = clubType;
      body['club'] = clubType;
    }
    final response =
        await _api.patch(ApiConstants.noteBookUpdate(id), body: body);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> togglePinNote(String id, {bool? isPinned}) async {
    final body = <String, dynamic>{};
    if (isPinned != null) {
      body['isPinned'] = isPinned;
      body['pinnedAsReminder'] = isPinned;
    }
    final response =
        await _api.patch(ApiConstants.noteBookTogglePin(id), body: body);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> deleteNote(String id) async {
    final response = await _api.delete(ApiConstants.noteBookDelete(id));
    return Map<String, dynamic>.from(response as Map);
  }

  /// Lightweight coach/golfer profile name + avatar update.
  Future<Map<String, dynamic>> updateProfileBasics({
    required String name,
    String? profileImagePath,
    String? email,
    String? ageRange,
    double? handicap,
    String? practiceSessionPerWeek,
    bool? usesGolfImproveStand,
  }) async {
    return updateMyProfile(
      name: name,
      age: ageRange ?? '25-34',
      handicap: handicap ?? 0,
      practiceSessionPerWeek: practiceSessionPerWeek ?? '3',
      profileImagePath: profileImagePath,
      usesGolfImproveStand: usesGolfImproveStand,
    );
  }
}
