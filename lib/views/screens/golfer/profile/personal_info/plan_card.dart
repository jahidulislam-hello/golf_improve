// import 'package:flutter/material.dart';
// import '../app_colors.dart';
// import '../app_text_styles.dart';

// class PlanCard extends StatelessWidget {
//   const PlanCard({
//     super.key,
//     required this.isFreePlan,
//     required this.onUpgrade,
//   });

//   final bool isFreePlan;
//   final VoidCallback onUpgrade;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: AppColors.heroNavyGradient,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             alignment: Alignment.center,
//             child: const Icon(
//               Icons.workspace_premium_outlined,
//               color: AppColors.upgradeAmber,
//               size: 22,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isFreePlan ? 'Free Plan' : 'Pro Plan',
//                   style: AppTextStyles.body.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   isFreePlan
//                       ? 'Upgrade for unlimited\nAI analysis'
//                       : 'You have unlimited AI analysis',
//                   style: AppTextStyles.caption.copyWith(
//                     color: Colors.white.withOpacity(0.7),
//                     height: 1.25,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isFreePlan) ...[
//             const SizedBox(width: 8),
//             _UpgradePill(onTap: onUpgrade),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _UpgradePill extends StatelessWidget {
//   const _UpgradePill({required this.onTap});

//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AppColors.upgradeAmber,
//       borderRadius: BorderRadius.circular(20),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         child: const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//           child: Text(
//             'Upgrade',
//             style: TextStyle(
//               fontFamily: AppTextStyles.fontFamily,
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: AppColors.primaryNavy,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
