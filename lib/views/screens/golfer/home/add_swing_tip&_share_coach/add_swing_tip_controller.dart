import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for the "Add Swing Tip" screen → `POST /note-book/create`.
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

  final TextEditingController reminderController;

  static const List<String> clubTypes = [
    'All Clubs',
    'Driver',
    'Irons',
    'Wedges',
  ];

  bool _markAsImportant;
  bool get markAsImportant => _markAsImportant;

  String _selectedClubType;
  String get selectedClubType => _selectedClubType;

  String? _attachedVideoName;
  String? get attachedVideoName => _attachedVideoName;
  bool get hasAttachedVideo => _attachedVideoName != null;

  String? _swingId;
  String? get swingId => _swingId;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? errorMessage;
  String? lastCreatedNoteId;

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

  void attachVideo(String fileName, {String? swingId}) {
    _attachedVideoName = fileName;
    _swingId = swingId;
    notifyListeners();
  }

  void removeVideo() {
    if (_attachedVideoName == null && _swingId == null) return;
    _attachedVideoName = null;
    _swingId = null;
    notifyListeners();
  }

  Future<bool> save() async {
    if (!canSave) return false;
    _isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final text = reminderController.text.trim();
      final title = text.length > 80 ? '${text.substring(0, 77)}...' : text;
      final prefs = await SharedPreferences.getInstance();
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final response = await service.createNote(
        title: title,
        description: text,
        isImportant: markAsImportant,
        isPinned: markAsImportant,
        clubType: selectedClubType,
        swingId: _swingId,
      );
      final data = response['data'];
      if (data is Map) {
        lastCreatedNoteId = '${data['_id'] ?? data['id'] ?? ''}'.trim();
      }
      return true;
    } on ApiError catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
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
