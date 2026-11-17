import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class GolferNavbarController extends GetxController {
  static const int homeTab = 0;
  static const int libraryTab = 1;
  static const int recordTab = 2;
  static const int progressTab = 3;
  static const int profileTab = 4;

  final currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  /// Calls [onShown] every time [tab] becomes the visible tab again.
  /// Tabs are kept alive, so screens use this to refresh silently.
  /// Dispose the returned worker in the screen's `dispose`.
  static Worker? onTabShown(int tab, VoidCallback onShown) {
    if (!Get.isRegistered<GolferNavbarController>()) return null;
    final controller = Get.find<GolferNavbarController>();
    return ever<int>(controller.currentIndex, (index) {
      if (index == tab) onShown();
    });
  }
}
