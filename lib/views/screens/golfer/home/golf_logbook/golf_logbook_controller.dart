import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LogbookSort { newest, oldest }

class LogbookTip {
  const LogbookTip({
    required this.id,
    required this.title,
    required this.description,
    required this.club,
    required this.important,
    required this.pinned,
  });

  final String id;
  final String title;
  final String description;
  final String club;
  final bool important;
  final bool pinned;

  factory LogbookTip.fromJson(Map<String, dynamic> json) {
    final club = '${json['club'] ?? json['clubType'] ?? 'All Clubs'}'.trim();
    return LogbookTip(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      title: '${json['title'] ?? ''}'.trim(),
      description:
          '${json['description'] ?? json['note'] ?? ''}'.trim(),
      club: club.isEmpty ? 'All Clubs' : club,
      important: json['isImportant'] == true,
      pinned: json['isPinned'] == true || json['pinnedAsReminder'] == true,
    );
  }
}

class GolfLogbookController extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;
  LogbookSort sort = LogbookSort.newest;
  List<LogbookTip> tips = const [];
  LogbookTip? pinnedReminder;

  Future<GolferService> _service() async {
    final prefs = await SharedPreferences.getInstance();
    return GolferService(
      apiService: ApiService(sharedPreferences: prefs),
    );
  }

  Future<void> load({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }
    try {
      final service = await _service();
      final response = await service.getMyNotes(
        sort: sort == LogbookSort.newest ? 'newest' : 'oldest',
      );
      final raw = response['data'];
      final list = <LogbookTip>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map) {
            list.add(LogbookTip.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
      tips = list;
      final meta = response['meta'];
      LogbookTip? pinned;
      if (meta is Map && meta['pinnedNote'] is Map) {
        pinned = LogbookTip.fromJson(
          Map<String, dynamic>.from(meta['pinnedNote'] as Map),
        );
      }
      pinned ??= tips.cast<LogbookTip?>().firstWhere(
            (t) => t?.pinned == true,
            orElse: () => null,
          );
      pinnedReminder = pinned;
      errorMessage = null;
    } on ApiError catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSort(LogbookSort next) async {
    if (sort == next) return;
    sort = next;
    notifyListeners();
    await load(showLoader: false);
  }

  Future<void> deleteTip(String id) async {
    final service = await _service();
    await service.deleteNote(id);
    await load(showLoader: false);
  }

  Future<void> dismissPinned() async {
    final id = pinnedReminder?.id;
    if (id == null || id.isEmpty) {
      pinnedReminder = null;
      notifyListeners();
      return;
    }
    final service = await _service();
    await service.togglePinNote(id, isPinned: false);
    await load(showLoader: false);
  }
}
