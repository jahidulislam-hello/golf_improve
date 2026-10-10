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
    String? recommendedDrill,
    List<Map<String, dynamic>> practicePlan = const [],
    String? aiAnalysisVerdict,
    String? aiAnalysisNote,
    List<String> filePaths = const [],
  }) async {
    final fields = <String, String>{
      'feedbackText': feedbackText,
    };
    if (recommendedDrill != null && recommendedDrill.isNotEmpty) {
      fields['recommendedDrill'] = recommendedDrill;
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
}
