import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/compare_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Playback speed options shown as pills on each clip row.
enum PlaybackSpeed {
  quarter(0.25),
  half(0.5),
  normal(1.0);

  const PlaybackSpeed(this.multiplier);
  final double multiplier;

  String get label => multiplier == 1.0
      ? '1×'
      : '${multiplier.toString().replaceAll(RegExp(r'\.0$'), '')}×';
}

/// State for a single swing clip (the "A" or "B" side).
class SwingClip {
  SwingClip({
    required this.badgeLetter,
    required this.badgeColor,
    required this.label,
    this.thumbnailImage,
    PlaybackSpeed speed = PlaybackSpeed.normal,
    double progress = 0,
    bool isPlaying = false,
  })  : _speed = speed,
        _progress = progress,
        _isPlaying = isPlaying;

  /// "A" or "B" — shown inside the small circular badge.
  final String badgeLetter;

  /// Badge / active-speed-pill tint (navy for A, bright blue for B in the
  /// reference design — but pass whatever fits your palette).
  final Color badgeColor;

  /// e.g. "Driver · Face On"
  String label;

  /// Optional thumbnail; swap for your actual video-thumbnail provider.
  ImageProvider? thumbnailImage;

  String? videoUrl;

  PlaybackSpeed _speed;
  PlaybackSpeed get speed => _speed;

  /// 0.0–1.0 scrub position.
  double _progress;
  double get progress => _progress;

  bool _isPlaying;
  bool get isPlaying => _isPlaying;
}

/// Controller for the "Compare Swings" screen — loads the golfer's library,
/// calls POST `/swing/compare`, and drives side-by-side playback.
class CompareSwingsController extends ChangeNotifier {
  CompareSwingsController({this.initialSwingAId, this.initialSwingBId}) {
    load();
  }

  final String? initialSwingAId;
  final String? initialSwingBId;

  static const sameSwingMessage =
      'Cannot compare a swing with itself. Please select two different swings.';
  static const sameVideoMessage =
      'Cannot compare identical swings or swings with the same video URL. Please select two distinct swing videos.';
  static const incompatibleMessage =
      'Select two swings recorded with the same club and angle.';

  final SwingClip clipA = SwingClip(
    badgeLetter: 'A',
    badgeColor: AppColors.primaryNavy,
    label: 'Select swing A',
  );
  final SwingClip clipB = SwingClip(
    badgeLetter: 'B',
    badgeColor: AppColors.ctaBrightBlue,
    label: 'Select swing B',
  );

  List<CompareSwingOption> options = const [];
  String? swingAId;
  String? swingBId;
  SwingComparisonResult? result;

  bool isLoading = true;
  bool isComparing = false;
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;
  String? errorMessage;
  int playRequest = 0;

  bool get canCompare =>
      swingAId != null &&
      swingBId != null &&
      swingAId!.isNotEmpty &&
      swingBId!.isNotEmpty &&
      !isComparing;

  CompareSwingOption? get selectedA => _option(swingAId);
  CompareSwingOption? get selectedB => _option(swingBId);

  Future<void> load({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }
    try {
      final service = await _service();
      final response = await service.getMyLibrary(limit: 100);
      final seen = <String>{};
      options = _optionsFrom(response['data'])
          .where((option) => option.id.isNotEmpty && seen.add(option.id))
          .toList();
      if (swingAId != null && _option(swingAId) == null) swingAId = null;
      if (swingBId != null && _option(swingBId) == null) swingBId = null;
      if (swingAId == null && initialSwingAId != null) {
        swingAId = initialSwingAId;
      }
      if (swingBId == null && initialSwingBId != null) {
        swingBId = initialSwingBId;
      }
      _applySelection(clipA, selectedA);
      _applySelection(clipB, selectedB);
      errorMessage = null;
    } catch (e) {
      errorMessage = _message(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
    if (selectedA != null && selectedB != null) {
      await _compareIfReady();
    }
  }

  void selectSwingA(String? id) {
    swingAId = id;
    _applySelection(clipA, _option(id));
    result = null;
    errorMessage = null;
    notifyListeners();
    _compareIfReady();
  }

  void selectSwingB(String? id) {
    swingBId = id;
    _applySelection(clipB, _option(id));
    result = null;
    errorMessage = null;
    notifyListeners();
    _compareIfReady();
  }

  Future<void> compare() => _compareIfReady(force: true);

  void setSpeed(SwingClip clip, PlaybackSpeed speed) {
    if (clip._speed == speed) return;
    clip._speed = speed;
    notifyListeners();
  }

  void setProgress(SwingClip clip, double progress) {
    clip._progress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  void togglePlay(SwingClip clip) {
    clip._isPlaying = !clip._isPlaying;
    if (clip._isPlaying) playRequest++;
    notifyListeners();
  }

  void pauseAll() {
    clipA._isPlaying = false;
    clipB._isPlaying = false;
    notifyListeners();
  }

  /// Starts both clips together.
  void playBoth() {
    if ((clipA.videoUrl ?? '').isEmpty && (clipB.videoUrl ?? '').isEmpty) {
      return;
    }
    clipA._isPlaying = true;
    clipB._isPlaying = true;
    playRequest++;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await load(showLoader: false);
      if (swingAId != null && swingBId != null) {
        await _compareIfReady(force: true);
      }
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _compareIfReady({bool force = false}) async {
    final a = selectedA;
    final b = selectedB;
    if (a == null || b == null) return;
    final blocked = _clientError(a, b);
    if (blocked != null) {
      result = null;
      errorMessage = blocked;
      notifyListeners();
      return;
    }
    if (!force && result != null) return;

    isComparing = true;
    errorMessage = null;
    notifyListeners();
    try {
      final service = await _service();
      final response = await service.compareSwings(
        firstSwingId: a.id,
        secondSwingId: b.id,
      );
      result = SwingComparisonResult.fromResponse(response);
      _applyCompared(clipA, result!.swingA, fallback: a);
      _applyCompared(clipB, result!.swingB, fallback: b);
    } catch (e) {
      result = null;
      errorMessage = _message(e);
    } finally {
      isComparing = false;
      notifyListeners();
    }
  }

  List<CompareSwingOption> optionsForPicker({
    required String? value,
    required String? otherId,
  }) {
    final other = _option(otherId);
    final list = options.where((option) {
      if (_angleFamily(option.cameraAngle) == 'side') return false;
      if (other == null) return true;
      if (option.id == other.id) return false;
      return _sameGroup(option, other);
    }).toList();
    final current = _option(value);
    if (current != null && !list.any((option) => option.id == current.id)) {
      list.insert(0, current);
    }
    return list;
  }

  String? _clientError(CompareSwingOption a, CompareSwingOption b) {
    if (a.id == b.id) return sameSwingMessage;
    final urlA = _normalizeUrl(a.videoUrl);
    final urlB = _normalizeUrl(b.videoUrl);
    if (urlA.isNotEmpty && urlA == urlB) return sameVideoMessage;
    if (!_sameGroup(a, b)) return incompatibleMessage;
    return null;
  }

  bool _sameGroup(CompareSwingOption a, CompareSwingOption b) {
    return _clubFamily(a.clubType) == _clubFamily(b.clubType) &&
        _angleFamily(a.cameraAngle) == _angleFamily(b.cameraAngle) &&
        _angleFamily(a.cameraAngle) != 'side' &&
        _clubFamily(a.clubType).isNotEmpty;
  }

  String _clubFamily(String raw) {
    final n = raw.toLowerCase();
    if (n.contains('wedge')) return 'wedges';
    if (n.contains('iron')) return 'irons';
    if (n.contains('putt')) return 'putter';
    if (n.contains('driver')) return 'driver';
    return n.trim();
  }

  String _angleFamily(String raw) {
    final n = raw.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (n.contains('down') || n.contains('downtheline')) return 'dtl';
    if (n.contains('face')) return 'face';
    if (n.contains('side')) return 'side';
    return n;
  }

  String _normalizeUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return trimmed.toLowerCase();
    return uri.replace(query: '', fragment: '').toString().toLowerCase();
  }

  void _applySelection(SwingClip clip, CompareSwingOption? option) {
    if (option == null) {
      clip.label = clip.badgeLetter == 'A' ? 'Select swing A' : 'Select swing B';
      clip.videoUrl = null;
      clip.thumbnailImage = null;
      clip._progress = 0;
      clip._isPlaying = false;
      return;
    }
    clip.label = option.label;
    clip.videoUrl = option.videoUrl;
    clip.thumbnailImage = option.thumbnailUrl.startsWith('http')
        ? NetworkImage(option.thumbnailUrl)
        : null;
  }

  void _applyCompared(
    SwingClip clip,
    ComparedSwing swing, {
    required CompareSwingOption fallback,
  }) {
    final label = swing.label.trim().isEmpty ? fallback.label : swing.label;
    clip.label = label;
    final video = swing.videoUrl.isNotEmpty ? swing.videoUrl : fallback.videoUrl;
    clip.videoUrl = video;
    final thumb =
        swing.thumbnailUrl.isNotEmpty ? swing.thumbnailUrl : fallback.thumbnailUrl;
    clip.thumbnailImage =
        thumb.startsWith('http') ? NetworkImage(thumb) : clip.thumbnailImage;
  }

  CompareSwingOption? _option(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  List<CompareSwingOption> _optionsFrom(dynamic data) {
    final list = _asList(data);
    return list
        .whereType<Map>()
        .map((e) => CompareSwingOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['results', 'swings', 'items', 'docs', 'data']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  String _message(Object error) {
    if (error is ApiError) return error.message;
    return error.toString();
  }

  Future<GolferService> _service() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    return GolferService(apiService: apiService);
  }
}
