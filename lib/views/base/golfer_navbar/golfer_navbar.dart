import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/screen/home_screen.dart';
import 'package:golf_training_app/views/screens/golfer/library/screens/swing_library_screen.dart';
import 'package:golf_training_app/views/screens/golfer/profile/profile/profile_screen.dart';
import 'package:golf_training_app/views/screens/golfer/progress/progress_screen.dart';
import 'package:golf_training_app/views/screens/golfer/record/screens/camera_capture_screen.dart';
import 'golfer_navbar_controller.dart';

class GolferNavbar extends StatefulWidget {
  const GolferNavbar({super.key});

  @override
  State<GolferNavbar> createState() => _GolferNavbarState();
}

class _GolferNavbarState extends State<GolferNavbar> {
  final GolferNavbarController controller = Get.put(GolferNavbarController());

  static const int _recordTabIndex = 2;

  late final List<Widget> pages = [
    const HomeScreen(),
    const SwingLibraryScreen(),
    CameraCaptureScreen(
      onClose: () => controller.changeIndex(0),
    ),
    const ProgressScreen(),
    const GolferProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRecordTab = controller.currentIndex.value == _recordTabIndex;

      return Scaffold(
        backgroundColor: Colors.white,
        extendBody: false,
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: isRecordTab
            ? null
            : Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xffE2E8F0), width: 1),
                    left: BorderSide(color: Color(0xffE2E8F0), width: 1),
                    right: BorderSide(color: Color(0xffE2E8F0), width: 1),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildNavItem(
                            title: "Home",
                            activeImage: "assets/icons/act_home.png",
                            passiveImage: "assets/icons/home.png",
                            index: 0,
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            title: "Library",
                            activeImage: "assets/icons/act_library.png",
                            passiveImage: "assets/icons/library.png",
                            index: 1,
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            title: "Record",
                            activeImage: "assets/icons/record.png",
                            passiveImage: "assets/icons/record.png",
                            index: 2,
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            title: "Progress",
                            activeImage: "assets/icons/act_progress.png",
                            passiveImage: "assets/icons/progress.png",
                            index: 3,
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            title: "Profile",
                            activeImage: "assets/icons/act_profile.png",
                            passiveImage: "assets/icons/profile.png",
                            index: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildNavItem({
    required String title,
    required String activeImage,
    required String passiveImage,
    required int index,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.changeIndex(index);
      },
      child: Obx(() {
        final isSelected = controller.currentIndex.value == index;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// Top Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 38,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xff15253D)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            const SizedBox(height: 10),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Image.asset(
                isSelected ? activeImage : passiveImage,
                key: ValueKey(isSelected),
                width: 28,
                height: 28,
              ),
            ),

            const SizedBox(height: 6),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xff15253D)
                    : const Color(0xff99A6BB),
              ),
              child: Text(title),
            ),
          ],
        );
      }),
    );
  }
}