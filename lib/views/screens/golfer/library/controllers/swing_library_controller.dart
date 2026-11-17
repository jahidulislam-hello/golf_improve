import 'dart:async';
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
      if (swing.openId == id || swing.id == id) return swing;
    }
    return null;
  }

  bool isCompareSelected(SwingVideo swing) =>
      swing.openId == compareAId || swing.openId == compareBId;

  bool isCompareDimmed(SwingVideo swing) {
    if (!compareMode) return false;
    final anchor = compareAnchor;
    if (anchor == null || swing.openId == anchor.openId) return false;
    if (swing.openId == compareBId) return false;
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
    if (swing.isLocal || swing.openId.isEmpty) {
      return 'This swing can be compared after it syncs.';
    }
    final pickId = swing.openId;
    if (pickId == compareAId) {
      compareAId = compareBId;
      compareBId = null;
      notifyListeners();
      return null;
    }
    if (pickId == compareBId) {
      compareBId = null;
      notifyListeners();
      return null;
    }
    final anchor = compareAnchor;
    if (anchor != null && !anchor.sameCompareGroup(swing)) {
      return 'Select another ${anchor.club} ${anchor.angleLabel} swing.';
    }
    if (compareAId != null && compareBId != null) {
      // Allow replacing B so a second pick always works once A is set.
      compareBId = pickId;
    } else if (anchor == null) {
      compareAId = pickId;
    } else {
      compareBId = pickId;
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

      // First open: show the cached library straight away, then refresh.
      if (!hasLoaded) {
        final cached = await _readCache(prefs);
        if (cached.isNotEmpty) {
          swings = _merge(cached, await _localSwings(prefs));
          _recount();
          hasLoaded = true;
          isLoading = false;
          notifyListeners();
        }
      }

      // Stats and the swing list are independent — load them together.
      final statsFuture = service
          .getFilterCategories()
          .then<Map<String, dynamic>?>((r) => _asMap(r['data']))
          .catchError((_) => null);

      List<SwingVideo> remote = const [];
      try {
        remote = await _fetchRemote(service);
        await _cache(prefs, remote);
        errorMessage = null;
      } catch (e) {
        remote = await _readCache(prefs);
        if (remote.isEmpty) errorMessage = _message(e);
      }

      final filterData = await statsFuture;
      if (filterData != null) _applyStats(filterData);

      // Upload clips recorded offline after the list is on screen.
      unawaited(_syncOffline(service));

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

  bool _isSyncing = false;

  Future<void> _syncOffline(GolferService service) async {
    if (_isSyncing) return;
    final prefs = await SharedPreferences.getInstance();
    if ((await OfflineSwingQueue.load(prefs)).isEmpty) return;
    _isSyncing = true;
    try {
      await service.syncPendingSwings();
      await load(showLoader: false);
    } catch (_) {
    } finally {
      _isSyncing = false;
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
    final records = await service.getAllMySwingRecords();
    return records.map(SwingVideo.fromJson).toList();
  }

  /// Instruction shown above the grid while selecting swings to compare.
  String get compareHint {
    final anchor = compareAnchor;
    if (anchor == null) {
      return 'Pick 2 swings recorded with the same club and angle.';
    }
    if (compareBId == null) {
      return 'Now pick another ${anchor.club} · ${anchor.angleLabel} swing.';
    }
    return 'Ready to compare.';
  }

  int get compareSelectedCount =>
      (compareAId != null ? 1 : 0) + (compareBId != null ? 1 : 0);

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
