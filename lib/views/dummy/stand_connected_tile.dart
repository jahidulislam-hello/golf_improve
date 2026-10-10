// import 'package:flutter/material.dart';
// import 'icon_chip.dart';
//
// class StandConnectedTile extends StatelessWidget {
//   const StandConnectedTile({
//     super.key,
//     required this.isConnected,
//     this.onTap,
//   });
//
//   final bool isConnected;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return SectionCard(
//       onTap: onTap,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       child: Row(
//         children: [
//           IconChip(
//             icon: Icons.circle,
//             background: AppColors.statusGreenSoft,
//             foreground: AppColors.statusGreen,
//             iconSize: 12,
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Text(
//               isConnected ? 'Golf Stand Connected' : 'Golf Stand Disconnected',
//               style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
//             ),
//           ),
//           const Icon(Icons.chevron_right, color: AppColors.textSecondary),
//         ],
//       ),
//     );
//   }
// }
