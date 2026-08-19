import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';

class StudentUpload {
  const StudentUpload({
    required this.title,
    required this.time,
    required this.score,
    this.thumbnailUrl = '',
  });

  final String title;
  final String time;
  final int score;
  final String thumbnailUrl;
}

class Student {
  const Student({
    required this.id,
    required this.name,
    required this.handicap,
    required this.swingsThisWeek,
    required this.avgScore,
    this.profileUrl = '',
    this.isActive = true,
    this.totalSwings = 0,
    this.sessions = 0,
    this.recentUploads = const [],
  });

  final String id;
  final String name;
  final String profileUrl;
  final double handicap;
  final int swingsThisWeek;
  final int avgScore;
  final bool isActive;
  final int totalSwings;
  final int sessions;
  final List<StudentUpload> recentUploads;

  Color get progressColor {
    if (avgScore >= 85) return AppColors.successGreen;
    if (avgScore >= 75) return AppColors.ctaBrightBlue;
    return AppColors.quickActionShareIcon;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return '';
    final list = parts.toList();
    if (list.length == 1) return list.first[0].toUpperCase();
    return '${list.first[0]}${list.last[0]}'.toUpperCase();
  }

  Student copyWith({
    String? name,
    String? profileUrl,
    double? handicap,
    bool? isActive,
    int? avgScore,
    int? totalSwings,
    int? sessions,
    List<StudentUpload>? recentUploads,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      profileUrl: profileUrl ?? this.profileUrl,
      handicap: handicap ?? this.handicap,
      swingsThisWeek: swingsThisWeek,
      avgScore: avgScore ?? this.avgScore,
      isActive: isActive ?? this.isActive,
      totalSwings: totalSwings ?? this.totalSwings,
      sessions: sessions ?? this.sessions,
      recentUploads: recentUploads ?? this.recentUploads,
    );
  }
}
