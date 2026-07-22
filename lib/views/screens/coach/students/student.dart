import 'package:flutter/material.dart';

class Student {
  final String name;
  final double handicap;
  final int swingsThisWeek;
  final int avgScore;
  final Color progressColor;
  final int totalSwings;
  final int sessions;
  final List<Map<String, dynamic>> recentUploads;

  const Student({
    required this.name,
    required this.handicap,
    required this.swingsThisWeek,
    required this.avgScore,
    required this.progressColor,
    this.totalSwings = 0,
    this.sessions = 0,
    this.recentUploads = const [],
  });

  String get initials {
    final p = name.trim().split(' ');
    return p.length > 1 ? p[0][0] + p[1][0] : p[0][0];
  }
}