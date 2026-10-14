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
    required String gender,
    required double handicap,
    required String practiceSessionPerWeek,
    bool? usesGolfImproveStand,
    String? profileImagePath,
  }) async {
    final ageRange = age.replaceAll('–', '-').replaceAll('—', '-');
    final handicapValue = handicap.toStringAsFixed(1);
    final fields = <String, String>{
      'name': name,
      'age_range': ageRange,
      'gender': gender,
      'handicap_index': handicapValue,
      'handicap': handicapValue,
      'practice_sessions_per_week': practiceSessionPerWeek,
      'practiceSessionPerWeek': practiceSessionPerWeek,
    };
    if (usesGolfImproveStand != null) {
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
    bool allowCoachToDraw = false,
  }) async {
    final body = <String, dynamic>{
      'coachId': coachId,
      'swingLibraryId': swingLibraryId,
      'idempotencyKey': idempotencyKey ??
          'share_${coachId}_$swingLibraryId',
      'status': status,
      'isSwingVideo': isSwingVideo,
      'isAiAnalysis': isAiAnalysis,
      'isPersonalNotesAndTips': isPersonalNotesAndTips,
    };
    if (message != null && message.trim().isNotEmpty) {
      body['message'] = message.trim();
    }
    if (practiceNoteId != null && practiceNoteId.isNotEmpty) {
      body['practice_note_id'] = practiceNoteId;
    }
    body['allowCoachToDraw'] = allowCoachToDraw;
    final response = await _api.post(ApiConstants.shareCreate, body: body);
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
        await createShare(
          coachId: coachId,
          swingLibraryId: swingLibraryId,
          practiceNoteId: map['practice_note_id']?.toString(),
          message: map['message']?.toString(),
          idempotencyKey: map['idempotencyKey']?.toString(),
          status: 'sent',
          isSwingVideo: true,
          isAiAnalysis: false,
          isPersonalNotesAndTips: map['isPersonalNotesAndTips'] == true,
          allowCoachToDraw: map['allowCoachToDraw'] == true,
        );
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

  Future<Map<String, dynamic>> completeCoachPracticeSession({
    required String shareId,
    required int sessionIndex,
    bool isCompleted = true,
  }) async {
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
    final response = await _api.post(ApiConstants.saveDrillPlan, body: body);
    return Map<String, dynamic>.from(response as Map);
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
      if (n.contains('side')) return 'Side On';
      if (n.contains('over')) return 'Overhead';
      if (n.contains('slow') || n == 'swing' || n == 'video') return 'Face On';
      return raw.trim().isEmpty ? 'Face On' : raw.trim();
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
            : safeAngle.toLowerCase().contains('side')
                ? 'side_on'
                : safeAngle.toLowerCase().contains('over')
                    ? 'overhead'
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

  /// Asks the AI coach. Falls back to `/ask/:id` if the mobile alias is missing.
  Future<Map<String, dynamic>> askCoach({
    required String swingId,
    required String question,
  }) async {
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

  /// Pre-signed S3 upload, then `POST /swing/create`.
  /// Network failures are queued for `syncPendingSwings`.
  /// A missing upload-url route falls back to multipart `/swing/analyzer`.
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
      return await _recordViaPresigned(
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
          },
        );
        throw ApiError(
          message:
              'No connection. Your swing was saved and will sync when you are back online.',
          statusCode: 0,
        );
      }
      if (e.statusCode == 404 || e.statusCode == 405) {
        return uploadSwingForAnalysis(
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
        payloads.add(await _uploadOfflinePayload(item));
      } on ApiError catch (e) {
        if (e.statusCode == 0 || e.statusCode >= 500) {
          remaining.add(item);
        }
      }
    }

    if (payloads.isNotEmpty) {
      try {
        await _api.post(
          ApiConstants.swingSyncOffline,
          body: {'swings': payloads},
        );
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
}
