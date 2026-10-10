// import 'package:flutter/material.dart';
// import 'package:golf_training_app/core/app_colors.dart';
// import 'package:golf_training_app/core/app_styles.dart';
//
//
// /// A single tappable row used in settings-style lists: a rounded icon
// /// chip, a title (+ optional subtitle), and a trailing chevron. Used for
// /// "Personal Info", "Logbook", "Privacy & Security", "Log out", etc.
// class SettingsRow extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String? subtitle;
//   final Color iconColor;
//   final Color iconBackground;
//   final Color titleColor;
//   final VoidCallback? onTap;
//
//   const SettingsRow({
//     super.key,
//     required this.icon,
//     required this.title,
//     this.subtitle,
//     this.iconColor = AppColors.ctaBrightBlue,
//     this.iconBackground = AppColors.iconChipBackground,
//     this.titleColor = AppColors.textPrimary,
//     this.onTap,
//   });
//
//   /// Convenience constructor for destructive rows (Log out, Delete Account).
//   const SettingsRow.destructive({
//     super.key,
//     required this.icon,
//     required this.title,
//     this.subtitle,
//     this.onTap,
//   })  : iconColor = const Color(0xFFE53E3E),
//         iconBackground = AppColors.iconChipRedBackground,
//         titleColor = const Color(0xFFE53E3E);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Row(
//           children: [
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: iconBackground,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: iconColor, size: 18),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     title,
//                     style: AppTextStyles.type16.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: titleColor,
//                     ),
//                   ),
//                   if (subtitle != null) ...[
//                     const SizedBox(height: 2),
//                     Text(subtitle!, style: AppTextStyles.type13),
//                   ],
//                 ],
//               ),
//             ),
//             Icon(Icons.chevron_right,
//                 color: titleColor == AppColors.textPrimary
//                     ? AppColors.textSecondary
//                     : titleColor,
//                 size: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
