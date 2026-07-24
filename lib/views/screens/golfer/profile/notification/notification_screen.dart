// import 'package:flutter/material.dart';
// import 'package:massrat/features/setings/privacy_screen.dart';
// import 'package:massrat/features/setings/terms_condition.dart';
// import '../../../core/utils/app_colors.dart';
// import 'privacy_security_screen.dart';
// import 'help_support_screen.dart';
//
// class OthersScreen extends StatelessWidget {
//   const OthersScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: _buildAppBar(context),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: _MenuCard(
//           items: [
//             _MenuItem(
//               icon: Icons.shield_outlined,
//               label: 'Privacy & Security',
//               color: AppColors.primary,
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const PrivacyScreen(),
//                 ),
//               ),
//             ),
//             _MenuItem(
//               icon: Icons.description_outlined,
//               label: 'Term & Conditions',
//               color: AppColors.primary,
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const TermsCondition(
//                   ),
//                 ),
//               ),
//             ),
//             _MenuItem(
//               icon: Icons.delete_outline_rounded,
//               label: 'Delete Account',
//               color: const Color(0xFFE53935),
//               labelColor: const Color(0xFFE53935),
//               onTap: () => _showDeleteDialog(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,
//       leading: Padding(
//         padding: const EdgeInsets.all(8),
//         child: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               color: Colors.black,
//               size: 24,
//             ),
//           ),
//         ),
//       ),
//       title: const Text(
//         'Community & Legal',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w700,
//           color: AppColors.textPrimary,
//         ),
//       ),
//     );
//   }
//
//   void _showDeleteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.45),
//       builder: (_) => const _DeleteAccountDialog(),
//     );
//   }
// }
//
// // ─── White card wrapping menu items ──────────────────────────────────────────
// class _MenuCard extends StatelessWidget {
//   final List<_MenuItem> items;
//   const _MenuCard({required this.items});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: List.generate(items.length, (i) {
//           final isLast = i == items.length - 1;
//           return Column(
//             children: [
//               _MenuRow(item: items[i], isLast: isLast),
//               if (!isLast)
//                 const Divider(
//                   height: 1,
//                   indent: 56,
//                   color: Color(0xFFF2F2F2),
//                 ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }
//
// // ─── Single menu row ──────────────────────────────────────────────────────────
// class _MenuRow extends StatelessWidget {
//   final _MenuItem item;
//   final bool isLast;
//   const _MenuRow({required this.item, this.isLast = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: item.onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Padding(
//         padding: EdgeInsets.only(
//           left: 16,
//           right: 16,
//           top: 15,
//           bottom: isLast ? 8 : 15, // ← tighter bottom on last row
//         ),
//         child: Row(
//           children: [
//             // Icon circle
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: item.color.withOpacity(0.10),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(item.icon, color: item.color, size: 18),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Text(
//                 item.label,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: item.labelColor ?? AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             Icon(
//               Icons.chevron_right_rounded,
//               color: AppColors.textSecondary,
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Delete Account Dialog ────────────────────────────────────────────────────
// class _DeleteAccountDialog extends StatelessWidget {
//   const _DeleteAccountDialog();
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 32),
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title row with X
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Delete Account',
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w800,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     width: 28,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF2F2F2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.close_rounded,
//                       size: 16,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             // Body text
//             const Text(
//               'Are you sure you want to delete\nyour account?',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: AppColors.textSecondary,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Buttons
//             Row(
//               children: [
//                 // Cancel
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       height: 46,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF2F2F2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           'Cancel',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.textPrimary,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//
//                 // Delete
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                       // TODO: handle account deletion
//                     },
//                     child: Container(
//                       height: 46,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFE53935),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           'Delete',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Data class ───────────────────────────────────────────────────────────────
// class _MenuItem {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final Color? labelColor;
//   final VoidCallback onTap;
//
//   const _MenuItem({
//     required this.icon,
//     required this.label,
//     required this.color,
//     this.labelColor,
//     required this.onTap,
//   });
// }