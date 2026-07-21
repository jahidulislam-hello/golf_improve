
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'coach_navbar_controller.dart';


class CoachNavbar extends StatefulWidget {
  const CoachNavbar({super.key});

  @override
  State<CoachNavbar> createState() => _CoachNavbarState();
}

class _CoachNavbarState extends State<CoachNavbar> {
  final CoachNavbarController controller = Get.put(CoachNavbarController());

  final List<Widget> pages = [


  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Colors.transparent, // Ensure the scaffold background is transparent
      extendBody:
      true, // Extend body to allow content to overlap the transparent parts
      body: Obx(() {
        // Listen to changes in the selected index of the bottom navigation
        return pages[controller.currentIndex.value];
      }),
      bottomNavigationBar: Container(
        //margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          //color: Color(0xFFBFBFBF1A).withValues(alpha: 0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), // Adjust the curve size
            topRight: Radius.circular(30), // Adjust the curve size
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                activeImage: "assets/icons/act_date.png",
                passiveImage: "assets/icons/pass_date.png",
                index: 0,
              ),
              _buildNavItem(
                activeImage: "assets/icons/act_calendar.png",
                passiveImage: "assets/icons/pass_calendar.png",
                index: 1,
              ),
              _buildNavItem(
                activeImage: "assets/icons/act_analytics.png",
                passiveImage: "assets/icons/pass_analytics.png",
                index: 2,
              ),
              _buildNavItem(
                activeImage: "assets/icons/act_settings.png",
                passiveImage: "assets/icons/pass_settings.png",
                index: 3,
              ),



            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String   activeImage,
    required String passiveImage,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        controller.changeIndex(index);
      },
      child: Obx(() {
        final isSelected = controller.currentIndex.value == index;
        return Image.asset(
          isSelected ? activeImage : passiveImage,
          height: 30, // Set the desired height

          fit: BoxFit.contain, // Ensures the image scales properly
        );
      }),
    );
  }
}