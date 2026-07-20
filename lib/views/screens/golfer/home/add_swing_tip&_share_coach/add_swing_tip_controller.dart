import 'package:flutter/material.dart';

/// Controller for the "Add Swing Tip" screen.
///
/// Owns the reminder text field, the "Mark as Important" toggle, the
/// selected club type, and the attached video reference. Exposed as a
/// [ChangeNotifier] so it can be wired up with `provider`, `ChangeNotifierProvider`,
/// or plain `AnimatedBuilder` / `ListenableBuilder` — whichever the app already uses.
class AddSwingTipController extends ChangeNotifier {
  AddSwingTipController({
    String? initialReminder,
    bool initialMarkAsImportant = false,
    String initialClubType = 'All Clubs',
  })  : reminderController = TextEditingController(text: initialReminder),
        _markAsImportant = initialMarkAsImportant,
        _selectedClubType = initialClubType {
    reminderController.addListener(notifyListeners);
  }

  /// Backs the "What's the reminder?" text field.
  final TextEditingController reminderController;

  /// Available club type filter pills, in display order.
  static const List<String> clubTypes = [
    'All Clubs',
    'Driver',
    'Irons',
    'Wedges',
    'Putter',
  ];

  bool _markAsImportant;
  bool get markAsImportant => _markAsImportant;

  String _selectedClubType;
  String get selectedClubType => _selectedClubType;

  /// Display name of the attached clip, or null if nothing is attached yet.
  String? _attachedVideoName;
  String? get attachedVideoName => _attachedVideoName;
  bool get hasAttachedVideo => _attachedVideoName != null;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// Reminder text is required to save.
  bool get canSave =>
      reminderController.text.trim().isNotEmpty && !_isSaving;

  void toggleMarkAsImportant(bool value) {
    if (_markAsImportant == value) return;
    _markAsImportant = value;
    notifyListeners();
  }

  void selectClubType(String type) {
    if (_selectedClubType == type) return;
    _selectedClubType = type;
    notifyListeners();
  }

  void attachVideo(String fileName) {
    _attachedVideoName = fileName;
    notifyListeners();
  }

  void removeVideo() {
    if (_attachedVideoName == null) return;
    _attachedVideoName = null;
    notifyListeners();
  }

  /// Persists the tip. Replace the body with your repository / API call.
  Future<bool> save() async {
    if (!canSave) return false;
    _isSaving = true;
    notifyListeners();

    try {
      // TODO: wire up to your data layer, e.g.:
      // await ref.read(swingTipRepositoryProvider).createTip(
      //   reminder: reminderController.text.trim(),
      //   isImportant: markAsImportant,
      //   clubType: selectedClubType,
      //   videoRef: attachedVideoName,
      // );
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return true;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    reminderController.removeListener(notifyListeners);
    reminderController.dispose();
    super.dispose();
  }
}
