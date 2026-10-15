import 'dart:convert';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/utils/api_constants.dart';

class CoachService {
  CoachService({required ApiService apiService}) : _api = apiService;

  final ApiService _api;

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _api.get(ApiConstants.getCoachProfile);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getCoachHome() async {
    final response = await _api.get(ApiConstants.coachHome);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getCoachStudents({
    int page = 1,
    int limit = 50,
    String? searchTerm,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      params['searchTerm'] = searchTerm.trim();
    }
    final url = Uri.parse(ApiConstants.coachStudents)
        .replace(queryParameters: params)
        .toString();
    final response = await _api.get(url);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getStudentDetails(String studentId) async {
    final response = await _api.get(ApiConstants.coachStudentDetails(studentId));
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getReceivedShares({
    required String status,
    int page = 1,
    int limit = 50,
  }) async {
    final url = Uri.parse(ApiConstants.shareReceived).replace(
      queryParameters: {
        'status': status,
        'page': '$page',
        'limit': '$limit',
      },
    ).toString();
    final response = await _api.get(url);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> markShareViewed(String shareId) async {
    final response = await _api.patch(ApiConstants.shareView(shareId), body: {});
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getShare(String shareId) async {
    final response = await _api.get(ApiConstants.shareFind(shareId));
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> respondToShare({
    required String shareId,
    required String feedbackText,
    String? primaryCorrection,
    String? detailedComments,
    String? recommendedDrill,
    String? drillSubtitle,
    List<Map<String, dynamic>> practicePlan = const [],
    String? aiAnalysisVerdict,
    String? aiAnalysisNote,
    List<String> filePaths = const [],
    int? rating,
  }) async {
    final fields = <String, String>{
      'feedbackText': feedbackText,
      'detailedComments':
          (detailedComments != null && detailedComments.trim().isNotEmpty)
              ? detailedComments.trim()
              : feedbackText,
    };
    if (primaryCorrection != null && primaryCorrection.trim().isNotEmpty) {
      fields['primaryCorrection'] = primaryCorrection.trim();
    }
    if (recommendedDrill != null && recommendedDrill.isNotEmpty) {
      fields['recommendedDrill'] = recommendedDrill;
    }
    if (drillSubtitle != null && drillSubtitle.trim().isNotEmpty) {
      fields['drillSubtitle'] = drillSubtitle.trim();
    }
    if (rating != null) {
      fields['rating'] = '$rating';
    }
    if (practicePlan.isNotEmpty) {
      fields['practicePlan'] = jsonEncode(practicePlan);
    }
    if (aiAnalysisVerdict != null && aiAnalysisVerdict.isNotEmpty) {
      fields['aiAnalysisVerdict'] = aiAnalysisVerdict;
    }
    if (aiAnalysisNote != null && aiAnalysisNote.isNotEmpty) {
      fields['aiAnalysisNote'] = aiAnalysisNote;
    }

    final files = <String, String>{};
    for (var i = 0; i < filePaths.length && i < 5; i++) {
      final path = filePaths[i];
      if (path.isEmpty) continue;
      files[i == 0 ? 'files' : 'files[$i]'] = path;
    }

    final response = await _api.multipartRequest(
      ApiConstants.shareRespond(shareId),
      method: 'PATCH',
      fields: fields,
      files: files.isEmpty ? null : files,
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> updatePracticePlan({
    required String shareId,
    required String recommendedDrill,
    required List<Map<String, dynamic>> practicePlan,
    bool isApproved = true,
  }) async {
    final response = await _api.patch(
      ApiConstants.updateSharePracticePlan(shareId),
      body: {
        'recommendedDrill': recommendedDrill,
        'practicePlan': practicePlan,
        'is_approved': isApproved,
      },
    );
    return Map<String, dynamic>.from(response as Map);
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

  Future<Map<String, dynamic>> completePracticeSession({
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
}
