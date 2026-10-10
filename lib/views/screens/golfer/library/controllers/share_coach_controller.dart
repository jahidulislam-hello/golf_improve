import 'package:flutter/material.dart';
import '../models/models.dart';

/// Controller for Screen 3 — Share with Coach.
class ShareCoachController extends ChangeNotifier {
  ShareCoachController({
    this.coachName = 'Coach',
    this.coachProfileUrl,
    bool includeSwingVideo = true,
    bool includeAiAnalysis = false,
    bool includePersonalNotes = false,
    String? initialQuestion,
  }) {
    questionController = TextEditingController(text: initialQuestion ?? '');
    questionController.addListener(notifyListeners);

    includeItems = [
      ShareIncludeItem(
        title: 'Swing Video',
        subtitle: 'Always included',
        icon: Icons.videocam_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFE3ECFC),
        alwaysIncluded: true,
        isOn: includeSwingVideo,
      ),
      ShareIncludeItem(
        title: 'AI Analysis',
        subtitle: 'Coach can agree, correct or add to it',
        icon: Icons.psychology_outlined,
        iconColor: const Color(0xFFE8A13B),
        iconBg: const Color(0xFFFCF0DD),
        isOn: includeAiAnalysis,
        badge: 'BETA',
      ),
      ShareIncludeItem(
        title: 'Personal Notes & Tips',
        subtitle: 'Logbook entries from this session',
        icon: Icons.menu_book_outlined,
        iconColor: const Color(0xFF2E9E5B),
        iconBg: const Color(0xFFE1F5E8),
        isOn: includePersonalNotes,
      ),
    ];
  }

  final String coachName;
  final String? coachProfileUrl;

  late final TextEditingController questionController;
  late final List<ShareIncludeItem> includeItems;

  bool isSending = false;
  String? errorMessage;

  void toggleItem(int index) {
    if (includeItems[index].alwaysIncluded) return;
    includeItems[index].isOn = !includeItems[index].isOn;
    notifyListeners();
  }

  /// Returns true if the message was accepted (has a video attached, always true here).
  bool send() {
    return true;
  }

  @override
  void dispose() {
    questionController.removeListener(notifyListeners);
    questionController.dispose();
    super.dispose();
  }
}
