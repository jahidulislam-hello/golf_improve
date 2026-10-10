import 'dart:convert';

import 'package:golf_training_app/services/api_services.dart';
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
    final response = await _api.patch(
      ApiConstants.updateHandicap,
      body: {'handicap': handicap},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> updateMyProfile({
    required String name,
    required String age,
    required String gender,
    required double handicap,
    required String practiceSessionPerWeek,
  }) async {
    final response = await _api.multipartRequest(
      ApiConstants.updateRegisterProfile,
      method: 'PATCH',
      fields: {
        'name': name,
        'age': age,
        'gender': gender,
        'handicap': handicap.toStringAsFixed(1),
        'practiceSessionPerWeek': practiceSessionPerWeek,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getFilterCategories() async {
    final response = await _api.get(ApiConstants.filterLibraryCategories);
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
}
