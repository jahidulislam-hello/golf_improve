import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/services/offline_swing_queue.dart';
import 'package:golf_training_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Controller for Screen 1 — Swing Library.
///
/// Club and angle come from the recording metadata. The grid is newest
/// first, and swings saved on the device stay visible without a network.
class SwingLibraryController extends ChangeNotifier {
  SwingLibraryController() {
    load();
  }

  static const clubChoices = <LibraryFilterOption>[
    LibraryFilterOption(label: 'All', value: 'All Clubs'),
    LibraryFilterOption(label: 'Driver', value: 'Driver'),
    LibraryFilterOption(label: 'Irons', value: 'Irons'),
    LibraryFilterOption(label: 'Wedges', value: 'Wedges'),
    LibraryFilterOption(label: 'Putter', value: 'Putter'),
  ];

  static const angleChoices = <LibraryFilterOption>[
    LibraryFilterOption(label: 'All Angles', value: 'All Angles'),
    LibraryFilterOption(label: 'Face-On', value: 'Face On'),
    LibraryFilterOption(label: 'Down-the-Line', value: 'Down The Line'),
  ];

  bool isLoading = true;
  bool isFiltering = false;
  bool hasLoaded = false;
  bool searchOpen = false;
  bool compareMode = false;
  String? errorMessage;
  String searchQuery = '';
  String? compareAId;
  String? compareBId;

  String selectedClub = 'All';
  String selectedAngle = 'All Angles';

  List<String> get clubs => clubChoices.map((o) => o.label).toList();
  List<String> get angles => angleChoices.map((o) => o.label).toList();

  int totalSwings = 0;
  int sharedWithCoach = 0;

  List<SwingVideo> swings = const [];

  List<SwingVideo> get filteredSwings {
    final query = searchQuery.trim().toLowerCase();
    final visible = swings.where((swing) {
      if (SwingVideo.angleFamily(swing.angle) == 'side') return false;
      if (!_clubMatches(swing)) return false;
      if (!_angleMatches(swing)) return false;
      if (query.isEmpty) return true;
      final haystack = [
        swing.club,
        swing.angle,
        swing.angleLabel,
        swing.sessionId,
        swing.localId,
        swing.recordedDateLabel,
        swing.recordedTimeLabel,
        swing.recordedStamp?.toIso8601String() ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
    visible.sort((a, b) {
      final aStamp = a.recordedStamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bStamp = b.recordedStamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bStamp.compareTo(aStamp);
    });
    return visible;
  }

  SwingVideo? get compareAnchor {
    final id = compareAId;
    if (id == null) return null;
    for (final swing in swings) {
      if (swing.id == id) return swing;
    }
    return null;
  }

  bool isCompareSelected(SwingVideo swing) =>
      swing.id == compareAId || swing.id == compareBId;

  bool isCompareDimmed(SwingVideo swing) {
    if (!compareMode) return false;
    final anchor = compareAnchor;
    if (anchor == null || swing.id == anchor.id) return false;
    if (swing.id == compareBId) return false;
    return swing.isLocal || !anchor.sameCompareGroup(swing);
  }

  bool get canCompare =>
      compareAId != null &&
      compareBId != null &&
      compareAId != compareBId;

  void toggleSearch() {
    searchOpen = !searchOpen;
    if (!searchOpen) searchQuery = '';
    notifyListeners();
  }

  void setSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void toggleCompareMode() {
    compareMode = !compareMode;
    compareAId = null;
    compareBId = null;
    notifyListeners();
  }

  /// Returns a message when the swing cannot be added to the comparison.
  String? toggleCompareSelection(SwingVideo swing) {
    if (swing.isLocal || swing.id.isEmpty) {
      return 'This swing can be compared after it syncs.';
    }
    if (swing.id == compareAId) {
      compareAId = compareBId;
      compareBId = null;
      notifyListeners();
      return null;
    }
    if (swing.id == compareBId) {
      compareBId = null;
      notifyListeners();
      return null;
    }
    final anchor = compareAnchor;
    if (anchor != null && !anchor.sameCompareGroup(swing)) {
      return 'Select another ${anchor.club} ${anchor.angleLabel} swing.';
    }
    if (anchor == null) {
      compareAId = swing.id;
    } else {
      compareBId = swing.id;
    }
    notifyListeners();
    return null;
  }

  Future<void> load({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );

      try {
        await service.syncPendingSwings();
      } catch (_) {}

      try {
        final filterResponse = await service.getFilterCategories();
        final filterData = _asMap(filterResponse['data']);
        if (filterData != null) _applyStats(filterData);
      } catch (_) {}

      List<SwingVideo> remote = const [];
      try {
        remote = await _fetchRemote(service);
        await _cache(prefs, remote);
        errorMessage = null;
      } catch (e) {
        remote = await _readCache(prefs);
        if (remote.isEmpty) errorMessage = _message(e);
      }

      final local = await _localSwings(prefs);
      swings = _merge(remote, local);
      if (swings.isNotEmpty) errorMessage = null;
      _recount();
      hasLoaded = true;
    } catch (e) {
      errorMessage = _message(e);
      if (!showLoader) rethrow;
    } finally {
      isLoading = false;
      isFiltering = false;
      notifyListeners();
    }
  }

  Future<void> selectClub(String club) async {
    if (selectedClub == club) return;
    selectedClub = club;
    notifyListeners();
  }

  Future<void> selectAngle(String angle) async {
    if (selectedAngle == angle) return;
    selectedAngle = angle;
    notifyListeners();
  }

  Future<List<SwingVideo>> _fetchRemote(GolferService service) async {
    final collected = <Map<String, dynamic>>[];
    try {
      for (var page = 1; page <= 5; page++) {
        final response = await service.getMySwings(
          page: page,
          limit: 50,
          sort: '-createdAt',
        );
        collected.addAll(_maps(_asResultList(response['data'])));
        final meta = _asMap(response['meta']);
        final totalPage = meta == null ? 1 : _asInt(meta['totalPage']);
        if (page >= totalPage || totalPage == 0) break;
      }
    } on ApiError catch (error) {
      if (error.statusCode != 404 && error.statusCode != 405) rethrow;
    }

    try {
      final library = await service.getMyLibrary(limit: 100);
      collected.addAll(_maps(_asResultList(library['data'])));
    } catch (_) {
      if (collected.isEmpty) rethrow;
    }
    return collected.map(SwingVideo.fromJson).toList();
  }

  Future<List<SwingVideo>> _localSwings(SharedPreferences prefs) async {
    final queued = await OfflineSwingQueue.load(prefs);
    return queued
        .where((item) {
          final path = '${item['videoPath'] ?? ''}';
          return OfflineSwingQueue.fileExists(path);
        })
        .map((item) => SwingVideo.fromJson({...item, 'isLocal': true}))
        .where((swing) => swing.id.isNotEmpty || swing.videoUrl.isNotEmpty)
        .toList();
  }

  List<SwingVideo> _merge(List<SwingVideo> remote, List<SwingVideo> local) {
    final byKey = <String, SwingVideo>{};
    for (final swing in remote) {
      if (swing.id.isEmpty) continue;
      byKey[swing.id] = swing;
    }
    for (final swing in local) {
      final alreadySynced = remote.any((item) => _sameRecording(item, swing));
      if (alreadySynced) continue;
      final key = swing.localId.isNotEmpty
          ? swing.localId
          : (swing.id.isNotEmpty ? swing.id : swing.videoUrl);
      byKey.putIfAbsent(key, () => swing);
    }
    return byKey.values.toList();
  }

  bool _sameRecording(SwingVideo remote, SwingVideo local) {
    if (local.localId.isNotEmpty &&
        (local.localId == remote.localId || local.localId == remote.id)) {
      return true;
    }
    if (local.id.isNotEmpty && local.id == remote.id) return true;
    return false;
  }

  bool _clubMatches(SwingVideo swing) {
    if (selectedClub == 'All') return true;
    return SwingVideo.clubFamily(swing.club) ==
        SwingVideo.clubFamily(selectedClub);
  }

  bool _angleMatches(SwingVideo swing) {
    if (selectedAngle == 'All Angles') return true;
    return SwingVideo.angleFamily(swing.angle) ==
        SwingVideo.angleFamily(selectedAngle);
  }

  void _applyStats(Map<String, dynamic> data) {
    final stats = _asMap(data['stats']);
    if (stats == null) return;
    totalSwings = _asInt(stats['totalSwings']);
    sharedWithCoach = _asInt(stats['sharedWithCoach']);
  }

  void _recount() {
    if (totalSwings == 0) totalSwings = swings.length;
    if (sharedWithCoach == 0) {
      sharedWithCoach = swings.where((swing) => swing.isSharedWithCoach).length;
    }
  }

  Future<void> _cache(SharedPreferences prefs, List<SwingVideo> remote) async {
    final payload = {
      'totalSwings': totalSwings,
      'sharedWithCoach': sharedWithCoach,
      'swings': remote.where((swing) => !swing.isLocal).map((e) => e.toJson()).toList(),
    };
    await prefs.setString(ApiConstants.keyLibraryCache, jsonEncode(payload));
  }

  Future<List<SwingVideo>> _readCache(SharedPreferences prefs) async {
    final raw = prefs.getString(ApiConstants.keyLibraryCache);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const [];
      totalSwings = _asInt(decoded['totalSwings']);
      sharedWithCoach = _asInt(decoded['sharedWithCoach']);
      final swingsRaw = decoded['swings'];
      if (swingsRaw is! List) return const [];
      return swingsRaw
          .whereType<Map>()
          .map((e) => SwingVideo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  List<Map<String, dynamic>> _maps(List<dynamic> raw) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  List<dynamic> _asResultList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['results', 'swings', 'items', 'docs', 'data']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
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

  String _message(Object error) {
    if (error is ApiError) return error.message;
    return error.toString();
  }
}
