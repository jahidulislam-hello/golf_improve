// import 'package:flutter/material.dart';
// import '../app_colors.dart';
// import '../app_text_styles.dart';

// class ProfileHeader extends StatelessWidget {
//   const ProfileHeader({
//     super.key,
//     required this.name,
//     required this.handicapLabel,
//     this.avatarUrl,
//   });

//   final String name;
//   final String handicapLabel;
//   final String? avatarUrl;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.surfaceWhite,
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: AppColors.borderLightGray,
//             backgroundImage:
//                 avatarUrl != null ? NetworkImage(avatarUrl!) : null,
//             child: avatarUrl == null
//                 ? const Icon(Icons.person, color: AppColors.textSecondary)
//                 : null,
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(handicapLabel, style: AppTextStyles.body.copyWith(
//                   color: AppColors.textSecondary,
//                   fontSize: 15,
//                 )),
//               ],
//             ),
//           ),
//           const CircleAvatar(
//             radius: 20,
//             backgroundColor: AppColors.backgroundOffWhite,
//           ),
//         ],
//       ),
//     );
//   }
// }
