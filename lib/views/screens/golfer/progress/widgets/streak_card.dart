// import 'package:flutter/material.dart';
// import '../app_colors.dart';
// import '../app_text_styles.dart';
// import '../controllers/progress_controller.dart';
// import 'section_card.dart';

// class StreakCard extends StatelessWidget {
//   const StreakCard({super.key, required this.controller});
//   final ProgressController controller;

//   @override
//   Widget build(BuildContext context) {
//     return SectionCard(
//       child: Row(
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: AppColors.accentOrangeBg,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(
//               Icons.local_fire_department_rounded,
//               color: AppColors.accentOrange,
//               size: 26,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.baseline,
//                   textBaseline: TextBaseline.alphabetic,
//                   children: [
//                     Text(
//                       '${controller.streakDays}',
//                       style: AppTextStyles.sectionHeader.copyWith(
//                         fontSize: 26,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Days',
//                       style: AppTextStyles.sectionHeader.copyWith(
//                         fontSize: 26,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'Practice Streak',
//                   style: AppTextStyles.body.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (controller.isPersonalBestStreak)
//             const Pill(
//               label: 'Personal Best',
//               background: AppColors.accentOrangeBg,
//               foreground: AppColors.accentOrange,
//             ),
//         ],
//       ),
//     );
//   }
// }
