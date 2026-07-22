// import 'package:flutter/material.dart';


// /// One row in the "Completed" section: a green checkmark, the student's
// /// name, and "Club · Angle · time ago".
// class CompletedReviewTile extends StatelessWidget {
//   const CompletedReviewTile({
//     super.key,
//     required this.item,
//     this.onTap,
//     this.showDivider = true,
//   });

//   final CompletedReviewItem item;
//   final VoidCallback? onTap;
//   final bool showDivider;

//   @override
//   Widget build(BuildContext context) {
//     final row = InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         child: Row(
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: AppColors.quickActionLogbookBg,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.check_rounded,
//                 size: 18,
//                 color: AppColors.quickActionLogbookIcon,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.studentName,
//                     style: AppTextStyles.body.copyWith(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(item.subtitleLine, style: AppTextStyles.caption),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (!showDivider) return row;

//     return Column(
//       children: [row, Divider(height: 1, color: AppColors.borderLightGray)],
//     );
//   }
// }
