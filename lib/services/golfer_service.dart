import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/utils/api_constants.dart';

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
}
