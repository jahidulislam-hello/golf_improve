import 'package:flutter/material.dart';

/// Controller for the "Share with Coach" screen.
///
/// Owns the selected video reference, the free-text question for the coach,
/// and the two share-permission toggles. Exposed as a [ChangeNotifier] so it
/// can be wired up with `provider`, `ChangeNotifierProvider`, or plain
/// `AnimatedBuilder` / `ListenableBuilder`.
class ShareWithCoachController extends ChangeNotifier {
  ShareWithCoachController({
    String? initialVideoName,
    String? initialQuestion,
    bool initialAllowDrawOnVideo = true,
    bool initialHighQualityExport = true,
  })  : questionController = TextEditingController(text: initialQuestion),
        _selectedVideoName = initialVideoName,
        _allowCoachToDraw = initialAllowDrawOnVideo,
        _highQualityExport = initialHighQualityExport {
    questionController.addListener(notifyListeners);
  }

  /// Backs the "Your Question" text field.
  final TextEditingController questionController;

  String? _selectedVideoName;
  String? get selectedVideoName => _selectedVideoName;
  bool get hasSelectedVideo => _selectedVideoName != null;

  bool _allowCoachToDraw;
  bool get allowCoachToDraw => _allowCoachToDraw;

  bool _highQualityExport;
  bool get highQualityExport => _highQualityExport;

  bool _isSending = false;
  bool get isSending => _isSending;

  /// A video must be picked before this can be sent.
  bool get canSend => _selectedVideoName != null && !_isSending;

  void selectVideo(String fileName) {
    _selectedVideoName = fileName;
    notifyListeners();
  }

  void clearVideo() {
    if (_selectedVideoName == null) return;
    _selectedVideoName = null;
    notifyListeners();
  }

  void toggleAllowCoachToDraw(bool value) {
    if (_allowCoachToDraw == value) return;
    _allowCoachToDraw = value;
    notifyListeners();
  }

  void toggleHighQualityExport(bool value) {
    if (_highQualityExport == value) return;
    _highQualityExport = value;
    notifyListeners();
  }

  /// Sends the video + question + permissions to the coach.
  /// Replace the body with your repository / API call.
  Future<bool> send() async {
    if (!canSend) return false;
    _isSending = true;
    notifyListeners();

    try {
      // TODO: wire up to your data layer, e.g.:
      // await ref.read(coachShareRepositoryProvider).share(
      //   videoRef: selectedVideoName!,
      //   question: questionController.text.trim(),
      //   allowDrawing: allowCoachToDraw,
      //   highQuality: highQualityExport,
      // );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return true;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    questionController.removeListener(notifyListeners);
    questionController.dispose();
    super.dispose();
  }
}
