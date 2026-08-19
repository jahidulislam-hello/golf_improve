import 'package:flutter/foundation.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/coach_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student.dart';

class StudentDetailController extends ChangeNotifier {
  StudentDetailController({required Student initial}) : student = initial {
    loadDetails();
  }

  Student student;
  bool isLoading = true;
  bool hasLoaded = false;
  String? errorMessage;

  Future<void> loadDetails({bool showLoader = true}) async {
    if (student.id.isEmpty) {
      isLoading = false;
      notifyListeners();
      return;
    }
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final service = CoachService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final response = await service.getStudentDetails(student.id);
      final data = _asMap(response['data']);
      if (data != null) {
        _apply(data);
      }
      hasLoaded = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _apply(Map<String, dynamic> data) {
    final info = _asMap(data['student']);
    final stats = _asMap(data['stats']);
    final uploads = <StudentUpload>[];
    final rawUploads = data['recentUploads'];
    if (rawUploads is List) {
      for (final item in rawUploads) {
        final map = _asMap(item);
        if (map == null) continue;
        final club = (map['clubType'] ?? '').toString();
        final angle = (map['cameraAngle'] ?? '').toString();
        uploads.add(
          StudentUpload(
            title: [club, angle].where((e) => e.isNotEmpty).join(' · '),
            time: _friendlyDate(map['createdAt']?.toString()),
            score: _asInt(map['overallScore']),
            thumbnailUrl: (map['thumbnailUrl'] ?? map['videoUrl'] ?? '').toString(),
          ),
        );
      }
    }

    student = student.copyWith(
      name: info == null ? student.name : (info['name'] ?? student.name).toString(),
      profileUrl: info == null
          ? student.profileUrl
          : (info['profileUrl'] ?? student.profileUrl).toString(),
      handicap: info == null
          ? student.handicap
          : _asDouble(info['handicap'] ?? student.handicap),
      isActive: info == null
          ? student.isActive
          : (info.containsKey('isActive')
              ? info['isActive'] == true
              : (info['status'] ?? '').toString().toLowerCase() == 'active'),
      avgScore: stats == null ? student.avgScore : _asInt(stats['avgScore']),
      totalSwings:
          stats == null ? student.totalSwings : _asInt(stats['totalSwings']),
      sessions: stats == null ? student.sessions : _asInt(stats['totalSessions']),
      recentUploads: uploads,
    );
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

  String _friendlyDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '';
    final local = parsed.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    final time = _timeLabel(local);
    if (diff == 0) return 'Today, $time';
    if (diff == 1) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, $time';
  }

  String _timeLabel(DateTime local) {
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute $suffix';
  }
}
