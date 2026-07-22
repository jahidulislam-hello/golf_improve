import 'package:flutter/material.dart';

enum ActivationStatus { idle, submitting, success, error }

/// Drives the Golf Stand activation screen: the code text field,
/// validation, the QR-scan hook, and the submit/activate flow.
class GolfStandActivationController extends ChangeNotifier {
  GolfStandActivationController() {
    codeController.addListener(() {
      // Clear a stale error as soon as the person edits the code again.
      if (status == ActivationStatus.error) {
        status = ActivationStatus.idle;
        errorMessage = null;
        notifyListeners();
      }
    });
  }

  final TextEditingController codeController = TextEditingController();

  ActivationStatus status = ActivationStatus.idle;
  String? errorMessage;

  static const int codeLength = 12;

  bool get isCodeComplete =>
      codeController.text.trim().length == codeLength;

  bool get isSubmitting => status == ActivationStatus.submitting;

  /// Wire this to your QR/barcode scanner package (e.g. mobile_scanner).
  /// For now it just accepts an already-decoded [scannedCode] string,
  /// so the scan button's UI works end-to-end before that's plugged in.
  void applyScannedCode(String scannedCode) {
    codeController.text = scannedCode.trim().toUpperCase();
    notifyListeners();
  }

  Future<bool> activate() async {
    if (!isCodeComplete) {
      status = ActivationStatus.error;
      errorMessage = 'Enter the full 12-digit activation code.';
      notifyListeners();
      return false;
    }

    status = ActivationStatus.submitting;
    errorMessage = null;
    notifyListeners();

    try {
      // Hook your real activation API call here, e.g.:
      // await golfStandRepository.activate(codeController.text);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      status = ActivationStatus.success;
      notifyListeners();
      return true;
    } catch (_) {
      status = ActivationStatus.error;
      errorMessage = 'Something went wrong — please try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
}