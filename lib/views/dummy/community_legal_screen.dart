// import 'package:flutter/material.dart';
// import 'package:golf_training_app/core/app_colors.dart';
// import 'package:golf_training_app/views/screens/golfer/profile/personal_info/profile_controller.dart';
// import 'package:provider/provider.dart';
//
//
//
// class CommunityLegalScreen extends StatelessWidget {
//   const CommunityLegalScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final profile = context.read<ProfileController>();
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundOffWhite,
//       appBar: const SimpleAppBar(title: 'Community & Legal'),
//       body: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
//           child: Container(
//             decoration: BoxDecoration(
//               color: AppColors.surfaceWhite,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Column(
//               children: [
//                 const SettingsRow(
//                   icon: Icons.shield_outlined,
//                   title: 'Privacy & Security',
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Divider(height: 1, color: AppColors.borderLightGray),
//                 ),
//                 const SettingsRow(
//                   icon: Icons.edit_document,
//                   title: 'Term & Conditions',
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Divider(height: 1, color: AppColors.borderLightGray),
//                 ),
//                 const SettingsRow(
//                   icon: Icons.info_outline,
//                   title: 'About GolfImprove',
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Divider(height: 1, color: AppColors.borderLightGray),
//                 ),
//                 SettingsRow.destructive(
//                   icon: Icons.delete_outline,
//                   title: 'Delete Account',
//                   onTap: () async {
//                     final confirmed = await showDialog<bool>(
//                       context: context,
//                       builder: (_) => AlertDialog(
//                         title: const Text('Delete Account'),
//                         content: const Text(
//                             'This will permanently delete your account. This cannot be undone.'),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.of(context).pop(false),
//                             child: const Text('Cancel'),
//                           ),
//                           TextButton(
//                             onPressed: () => Navigator.of(context).pop(true),
//                             child: const Text('Delete'),
//                           ),
//                         ],
//                       ),
//                     );
//                     if (confirmed == true) {
//                       await profile.deleteAccount();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
