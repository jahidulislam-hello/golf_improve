import 'package:flutter/foundation.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/coach_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student.dart';

class StudentsController extends ChangeNotifier {
  StudentsController() {
    loadStudents();
  }

  bool isLoading = true;
  bool hasLoaded = false;
  String? errorMessage;
  int totalStudents = 0;
  List<Student> students = const [];

  Future<void> loadStudents({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final service = await _service();
      final response = await service.getCoachStudents();
      final meta = _asMap(response['meta']);
      if (meta != null) {
        totalStudents = _asInt(meta['totalStudents'] ?? meta['totalResult']);
      }

      final raw = response['data'];
      if (raw is List) {
        students = raw
            .map((e) => _asMap(e))
            .whereType<Map<String, dynamic>>()
            .map(_studentFromApi)
            .toList();
      } else {
        students = const [];
      }
      if (meta == null) {
        totalStudents = students.length;
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

  Future<void> refresh() => loadStudents(showLoader: false);

  Student _studentFromApi(Map<String, dynamic> json) {
    final student = _asMap(json['student']);
    return Student(
      id: (student?['_id'] ?? json['studentId'] ?? '').toString(),
      name: (student?['name'] ?? '').toString(),
      profileUrl: (student?['profileUrl'] ?? '').toString(),
      handicap: _asDouble(json['handicap'] ?? student?['handicap']),
      swingsThisWeek: _asInt(json['swingsThisWeek']),
      avgScore: _asInt(json['avgScore'] ?? json['progress']),
      isActive: (student?['status'] ?? '').toString().toLowerCase() != 'inactive',
      totalSwings: _asInt(json['totalAnalyses']),
      sessions: 0,
    );
  }

  Future<CoachService> _service() async {
    final prefs = await SharedPreferences.getInstance();
    return CoachService(apiService: ApiService(sharedPreferences: prefs));
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  int _asInt(dynamic raw) {
    if (raw is num) return raw.round();
    return int.tryParse('${raw ?? ''}') ?? 0;
  }

  double _asDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse('${raw ?? ''}') ?? 0;
  }
}
