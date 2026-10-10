import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:golf_training_app/views/screens/coach/dashboard/dashboard_screen/screens/pro_dashboard_screen.dart';
import 'package:golf_training_app/views/screens/coach/profile/profile_screen/profile_controller.dart';
import 'package:golf_training_app/views/screens/coach/profile/profile_screen/profile_screen.dart';
import 'package:golf_training_app/views/screens/coach/reviewers/reviews_screen.dart';
import 'package:golf_training_app/views/screens/coach/students/students_list_screen.dart';

import 'coach_navbar_controller.dart';

class CoachNavbar extends StatefulWidget {
  const CoachNavbar({super.key});

  @override
  State<CoachNavbar> createState() => _CoachNavbarState();
}

class _CoachNavbarState extends State<CoachNavbar> {
  final CoachNavbarController controller = Get.put(CoachNavbarController());
  final ProfileController profileController = ProfileController();

  late final List<Widget> pages = [
    const ProDashboardScreen(),
    const StudentsScreen(),
    const ReviewsScreen(),
    ProfileScreen(controller: profileController),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: false,
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Container(
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
                    title: "DashBoard",
                    activeImage: "assets/icons/act_dashboard.png",
                    passiveImage: "assets/icons/dashboard.png",
                    index: 0,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    title: "Students",
                    activeImage: "assets/icons/act_students.png",
                    passiveImage: "assets/icons/students.png",
                    index: 1,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    title: "Reviews",
                    activeImage: "assets/icons/act_reviews.png",
                    passiveImage: "assets/icons/reviews.png",
                    index: 2,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    title: "Profile",
                    activeImage: "assets/icons/act_profile.png",
                    passiveImage: "assets/icons/profile.png",
                    index: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
