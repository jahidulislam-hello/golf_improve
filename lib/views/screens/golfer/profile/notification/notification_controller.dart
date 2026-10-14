import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}

class NotificationController extends ChangeNotifier {
  NotificationController() {
    load();
  }

  static const int pageSize = 10;

  final List<AppNotification> items = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  int _page = 1;
  int _totalPage = 1;

  bool get hasMore => _page < _totalPage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final page = await _fetch(1);
      items
        ..clear()
        ..addAll(page.items);
      _page = page.currentPage;
      _totalPage = page.totalPage;
    } catch (e) {
      errorMessage = e is ApiError ? e.message : e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    notifyListeners();
    try {
      final page = await _fetch(_page + 1);
      items.addAll(page.items);
      _page = page.currentPage;
      _totalPage = page.totalPage;
      errorMessage = null;
    } catch (e) {
      errorMessage = e is ApiError ? e.message : e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<_NotificationPage> _fetch(int page) async {
    final prefs = await SharedPreferences.getInstance();
    final service = GolferService(
      apiService: ApiService(sharedPreferences: prefs),
    );
    final response = await service.getNotifications(page: page, limit: pageSize);
    final data = response['data'];
    final root = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final meta = root['meta'] is Map
        ? Map<String, dynamic>.from(root['meta'] as Map)
        : <String, dynamic>{};
    final raw = root['results'];
    final results = raw is List
        ? raw
            .whereType<Map>()
            .map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <AppNotification>[];
    final current = _asInt(meta['currentPage']) ?? page;
    final total = _asInt(meta['totalPage']) ?? current;
    return _NotificationPage(
      items: results,
      currentPage: current,
      totalPage: total < 1 ? 1 : total,
    );
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}');
  }
}

class _NotificationPage {
  const _NotificationPage({
    required this.items,
    required this.currentPage,
    required this.totalPage,
  });

  final List<AppNotification> items;
  final int currentPage;
  final int totalPage;
}
