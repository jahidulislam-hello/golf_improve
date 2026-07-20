import 'package:flutter/material.dart';
import '../models/models.dart';

/// Controller for Screen 1 — Swing Library.
/// Owns the club/angle filter state and the filtered grid of swings.
class SwingLibraryController extends ChangeNotifier {
  String selectedClub = 'All';
  String selectedAngle = 'All Angles';

  final List<String> clubs = ['All', 'Driver', 'Irons', 'Wedges', 'Putter'];
  final List<String> angles = [
    'All Angles',
    'Face On',
    'Down the Line',
    'Side On'
  ];

  final int totalSwings = 847;
  final int sharedWithCoach = 23;

  final List<SwingVideo> allSwings = const [
    SwingVideo(id: '1', club: 'Driver', angle: 'Face On', thumbnailAsset: ''),
    SwingVideo(
        id: '2',
        club: 'Irons',
        angle: 'Down the Line',
        thumbnailAsset: '',
        matchPercent: 91),
    SwingVideo(
        id: '3',
        club: 'Wedges',
        angle: 'Side On',
        thumbnailAsset: '',
        matchPercent: 76),
    SwingVideo(
        id: '4',
        club: 'Driver',
        angle: 'Face On',
        thumbnailAsset: '',
        matchPercent: 88),
    SwingVideo(
        id: '5',
        club: 'Driver',
        angle: 'Side On',
        thumbnailAsset: '',
        matchPercent: 95),
    SwingVideo(
        id: '6',
        club: 'Driver',
        angle: 'Face On',
        thumbnailAsset: '',
        matchPercent: 82),
  ];

  List<SwingVideo> get filteredSwings {
    return allSwings.where((s) {
      final clubMatch = selectedClub == 'All' || s.club == selectedClub;
      final angleMatch =
          selectedAngle == 'All Angles' || s.angle == selectedAngle;
      return clubMatch && angleMatch;
    }).toList();
  }

  void selectClub(String club) {
    if (selectedClub == club) return;
    selectedClub = club;
    notifyListeners();
  }

  void selectAngle(String angle) {
    if (selectedAngle == angle) return;
    selectedAngle = angle;
    notifyListeners();
  }
}
