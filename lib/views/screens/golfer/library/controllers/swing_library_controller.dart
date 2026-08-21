import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Controller for Screen 1 — Swing Library.
/// Loads filter chips from GET `/meta/filter-categories` and swings from
/// GET `/swing-library/my-library` (refetched when club/angle changes).
class SwingLibraryController extends ChangeNotifier {
  SwingLibraryController() {
    load();
  }

  bool isLoading = true;
  bool isFiltering = false;
  bool hasLoaded = false;
  String? errorMessage;

  String selectedClub = 'All';
  String selectedAngle = 'All Angles';

  List<LibraryFilterOption> clubOptions = const [
    LibraryFilterOption(label: 'All', value: 'all'),
  ];
  List<LibraryFilterOption> angleOptions = const [
    LibraryFilterOption(label: 'All Angles', value: 'all angles'),
  ];

  List<String> get clubs =>
      clubOptions.map((o) => o.label).where((l) => l.isNotEmpty).toList();
  List<String> get angles =>
      angleOptions.map((o) => o.label).where((l) => l.isNotEmpty).toList();

  int totalSwings = 0;
  int sharedWithCoach = 0;

  List<SwingVideo> swings = const [];

  /// Swings shown in the grid (server already filtered).
  List<SwingVideo> get filteredSwings => swings;

  Future<void> load({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final service = await _service();

      final filterResponse = await service.getFilterCategories();
      final filterData = _asMap(filterResponse['data']);
      if (filterData != null) {
        _applyFilterCategories(filterData);
      }

      await _fetchLibrary(service);
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

  Future<void> selectClub(String club) async {
    if (selectedClub == club) return;
    selectedClub = club;
    await _reloadLibraryForFilters();
  }

  Future<void> selectAngle(String angle) async {
    if (selectedAngle == angle) return;
    selectedAngle = angle;
    await _reloadLibraryForFilters();
  }

  Future<void> _reloadLibraryForFilters() async {
    isFiltering = true;
    errorMessage = null;
    notifyListeners();

    try {
      final service = await _service();
      await _fetchLibrary(service);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isFiltering = false;
      notifyListeners();
    }
  }

  Future<void> _fetchLibrary(GolferService service) async {
    final clubType = _queryClubType();
    final cameraAngle = _queryCameraAngle();

    final response = await service.getMyLibrary(
      clubType: clubType,
      cameraAngle: cameraAngle,
    );

    final rawList = response['data'];
    if (rawList is List) {
      swings = rawList
          .whereType<Map>()
          .map((e) => SwingVideo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      swings = const [];
    }
  }

  void _applyFilterCategories(Map<String, dynamic> data) {
    final stats = _asMap(data['stats']);
    if (stats != null) {
      totalSwings = _asInt(stats['totalSwings']);
      sharedWithCoach = _asInt(stats['sharedWithCoach']);
    }

    final clubsRaw = data['clubs'];
    if (clubsRaw is List && clubsRaw.isNotEmpty) {
      clubOptions = clubsRaw
          .whereType<Map>()
          .map((e) => LibraryFilterOption.fromJson(Map<String, dynamic>.from(e)))
          .where((o) => o.label.isNotEmpty)
          .toList();
      if (clubOptions.isNotEmpty &&
          !clubOptions.any((o) => o.label == selectedClub)) {
        selectedClub = clubOptions.first.label;
      }
    }

    final anglesRaw = data['cameraAngles'];
    if (anglesRaw is List && anglesRaw.isNotEmpty) {
      angleOptions = anglesRaw
          .whereType<Map>()
          .map((e) => LibraryFilterOption.fromJson(Map<String, dynamic>.from(e)))
          .where((o) => o.label.isNotEmpty)
          .toList();
      if (angleOptions.isNotEmpty &&
          !angleOptions.any((o) => o.label == selectedAngle)) {
        selectedAngle = angleOptions.first.label;
      }
    }
  }

  /// Query values for `clubType` / `cameraAngle` match the API examples
  /// (`All Clubs`, `All Angles`) and the swing item field strings.
  String _queryClubType() {
    final option = _findOption(clubOptions, selectedClub);
    if (option == null) return selectedClub;

    final value = option.value.trim().toLowerCase();
    if (value == 'all' || selectedClub.trim().toLowerCase() == 'all') {
      return 'All Clubs';
    }
    return option.label;
  }

  String _queryCameraAngle() {
    final option = _findOption(angleOptions, selectedAngle);
    if (option == null) return selectedAngle;

    final value = option.value.trim().toLowerCase();
    if (value == 'all angles' ||
        selectedAngle.trim().toLowerCase() == 'all angles') {
      return 'All Angles';
    }
    return option.label;
  }

  LibraryFilterOption? _findOption(
    List<LibraryFilterOption> options,
    String label,
  ) {
    for (final option in options) {
      if (option.label == label) return option;
    }
    return null;
  }

  Future<GolferService> _service() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    return GolferService(apiService: apiService);
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
}
