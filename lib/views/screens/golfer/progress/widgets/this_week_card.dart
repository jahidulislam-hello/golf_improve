// import 'package:flutter/material.dart';
// import '../app_colors.dart';
// import '../app_text_styles.dart';
// import '../controllers/progress_controller.dart';
// import 'charts/trend_arrow_icon.dart';
// import 'section_card.dart';

// class ThisWeekCard extends StatelessWidget {
//   const ThisWeekCard({super.key, required this.controller});
//   final ProgressController controller;

//   @override
//   Widget build(BuildContext context) {
//     return SectionCard(
//       child: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             right: 0,
//             child: TrendArrowIcon(size: 46),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'THIS WEEK',
//                 style: AppTextStyles.caption.copyWith(
//                   color: AppColors.ctaBrightBlue,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.6,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.baseline,
//                 textBaseline: TextBaseline.alphabetic,
//                 children: [
//                   Text(
//                     '${controller.thisWeekSwings}',
//                     style: AppTextStyles.statNumber,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'swings',
//                     style: AppTextStyles.body.copyWith(
//                       color: AppColors.textSecondary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.arrow_upward_rounded,
//                       size: 16, color: AppColors.accentGreen),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       'Up from ${controller.lastWeekSwings} last week — '
//                       '${controller.isBestWeek ? "your best week yet." : "keep it up."}',
//                       style: AppTextStyles.caption.copyWith(
//                         color: AppColors.accentGreen,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
