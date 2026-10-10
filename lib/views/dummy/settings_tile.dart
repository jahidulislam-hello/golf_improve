// import 'package:flutter/material.dart';
// import '../app_colors.dart';
// import '../app_text_styles.dart';
// import 'icon_chip.dart';
//
// /// A single row inside the grouped settings card: icon chip, title,
// /// optional subtitle, trailing chevron.
// class SettingsTile extends StatelessWidget {
//   const SettingsTile({
//     super.key,
//     required this.icon,
//     required this.title,
//     this.subtitle,
//     this.iconBackground = AppColors.iconChipGray,
//     this.iconColor = AppColors.textPrimary,
//     this.titleColor = AppColors.textPrimary,
//     this.chevronColor = AppColors.textSecondary,
//     this.showDivider = true,
//     this.onTap,
//   });
//
//   final IconData icon;
//   final String title;
//   final String? subtitle;
//   final Color iconBackground;
//   final Color iconColor;
//   final Color titleColor;
//   final Color chevronColor;
//   final bool showDivider;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: onTap,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               child: Row(
//                 children: [
//                   IconChip(
//                     icon: icon,
//                     background: iconBackground,
//                     foreground: iconColor,
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: AppTextStyles.body.copyWith(
//                             fontWeight: FontWeight.w700,
//                             color: titleColor,
//                           ),
//                         ),
//                         if (subtitle != null) ...[
//                           const SizedBox(height: 2),
//                           Text(subtitle!, style: AppTextStyles.caption),
//                         ],
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.chevron_right, color: chevronColor),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         if (showDivider)
//           const Divider(height: 1, color: AppColors.borderLightGray),
//       ],
//     );
//   }
// }
//
// /// A group of [SettingsTile]s wrapped in one white rounded card, matching
// /// the "Personal Info / Logbook / Notifications / Help & Support /
// /// Community & Legal" block in the design.
// class SettingsListCard extends StatelessWidget {
//   const SettingsListCard({super.key, required this.tiles});
//
//   final List<SettingsTile> tiles;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceWhite,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x0A0A1628),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           for (int i = 0; i < tiles.length; i++)
//             i == tiles.length - 1
//                 ? SettingsTile(
//                     icon: tiles[i].icon,
//                     title: tiles[i].title,
//                     subtitle: tiles[i].subtitle,
//                     iconBackground: tiles[i].iconBackground,
//                     iconColor: tiles[i].iconColor,
//                     titleColor: tiles[i].titleColor,
//                     chevronColor: tiles[i].chevronColor,
//                     onTap: tiles[i].onTap,
//                     showDivider: false,
//                   )
//                 : tiles[i],
//         ],
//       ),
//     );
//   }
// }
