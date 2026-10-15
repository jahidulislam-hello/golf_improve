/// Response models for GET `/swing-category/camera`.
class CameraCategoriesData {
  const CameraCategoriesData({
    required this.cameraAngles,
    required this.recordingModes,
    required this.categories,
  });

  final List<String> cameraAngles;
  final List<String> recordingModes;
  final List<SwingCategory> categories;

  factory CameraCategoriesData.fromJson(Map<String, dynamic> json) {
    final angles = _stringList(json['cameraAngles']);
    final modes = _stringList(json['recordingModes']);
    final rawCats = json['categories'];
    final cats = <SwingCategory>[];
    if (rawCats is List) {
      for (final item in rawCats) {
        if (item is Map) {
          cats.add(SwingCategory.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      cats.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    final allowed = angles
        .where((a) {
          final n = a.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
          return !n.contains('side') && !n.contains('over');
        })
        .toList();
    return CameraCategoriesData(
      cameraAngles: allowed.isNotEmpty
          ? allowed
          : const ['Face On', 'Down The Line'],
      recordingModes: modes.isNotEmpty
          ? modes
          : const ['slow-mo', 'swing', 'video'],
      categories: cats,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .where((e) {
          final n = e.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
          return !n.contains('side') && !n.contains('over');
        })
        .toList();
  }
}

class SwingCategory {
  const SwingCategory({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.cameraAngles,
    required this.recordingModes,
    required this.defaultCameraAngle,
    required this.defaultRecordingMode,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String difficulty;
  final List<String> cameraAngles;
  final List<String> recordingModes;
  final String defaultCameraAngle;
  final String defaultRecordingMode;
  final int sortOrder;

  factory SwingCategory.fromJson(Map<String, dynamic> json) {
    return SwingCategory(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? '').toString(),
      cameraAngles: CameraCategoriesData._stringList(json['cameraAngles']),
      recordingModes: CameraCategoriesData._stringList(json['recordingModes']),
      defaultCameraAngle: (json['defaultCameraAngle'] ?? 'Face On').toString(),
      defaultRecordingMode:
          (json['defaultRecordingMode'] ?? 'swing').toString(),
      sortOrder: json['sortOrder'] is num
          ? (json['sortOrder'] as num).toInt()
          : int.tryParse('${json['sortOrder']}') ?? 0,
    );
  }
}
