// import 'package:flutter/material.dart';
// import 'package:golf_training_app/core/app_colors.dart';
// import 'package:golf_training_app/core/app_styles.dart';


// /// One card in the Reviews screen's "Pending" section: a video thumbnail
// /// with a play button, the student's name/club/angle overlaid at the
// /// bottom, "AI Included" + duration badges, the student's quoted
// /// question, and a "Review Now" button. The whole card is tappable.
// class PendingReviewVideoCard extends StatelessWidget {
//   const PendingReviewVideoCard({
//     super.key,
//     required this.item,
//     required this.onTap,
//   });

//   final PendingReviewItem item;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceWhite,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.borderCard),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryNavy.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _VideoHeader(item: item),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '"${item.quote}"',
//                       style: AppTextStyles.body.copyWith(
//                         fontSize: 15,
//                         height: 1.35,
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: _ReviewNowButton(onTap: onTap),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _VideoHeader extends StatelessWidget {
//   const _VideoHeader({required this.item});

//   final PendingReviewItem item;

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 4 / 3.3,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.network(
//             item.videoThumbnailUrl,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) =>
//                 Container(color: AppColors.primaryNavy),
//           ),
//           // Bottom scrim for text legibility.
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             height: 90,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     AppColors.primaryNavy.withOpacity(0.85),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Center play button.
//           Center(
//             child: Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.35),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.play_arrow_rounded,
//                 color: Colors.white,
//                 size: 26,
//               ),
//             ),
//           ),
//           // Name + club/angle, bottom-left.
//           Positioned(
//             left: 14,
//             right: 14,
//             bottom: 12,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         item.studentName,
//                         style: const TextStyle(
//                           fontFamily: AppTextStyles.fontFamily,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         item.subtitleLine,
//                         style: TextStyle(
//                           fontFamily: AppTextStyles.fontFamily,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white.withOpacity(0.85),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (item.hasAiIncluded) ...[
//                   const _AiIncludedBadge(),
//                   const SizedBox(width: 6),
//                 ],
//                 _DurationBadge(label: item.durationLabel),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AiIncludedBadge extends StatelessWidget {
//   const _AiIncludedBadge();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//       decoration: BoxDecoration(
//         color: AppColors.betaBadgeBg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.auto_awesome, size: 11, color: AppColors.betaBadgeText),
//           const SizedBox(width: 4),
//           Text(
//             'AI Included',
//             style: TextStyle(
//               fontFamily: AppTextStyles.fontFamily,
//               fontSize: 10.5,
//               fontWeight: FontWeight.w700,
//               color: AppColors.betaBadgeText,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DurationBadge extends StatelessWidget {
//   const _DurationBadge({required this.label});

//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.45),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontFamily: AppTextStyles.fontFamily,
//           fontSize: 11,
//           fontWeight: FontWeight.w700,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }

// class _ReviewNowButton extends StatelessWidget {
//   const _ReviewNowButton({required this.onTap});

//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AppColors.primaryNavy,
//       borderRadius: BorderRadius.circular(24),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(24),
//         child: const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
//           child: Text(
//             'Review Now',
//             style: TextStyle(
//               fontFamily: AppTextStyles.fontFamily,
//               fontSize: 13.5,
//               fontWeight: FontWeight.w700,
//               color: AppColors.surfaceWhite,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
