// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../controllers/analysing_controller.dart';
// import '../theme/app_capture_colors.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_text_styles.dart';

// /// Screenshot 6 — "Analysing your swing" loading state shown while the
// /// clip is sent off for AI analysis.
// class AnalysingScreen extends StatefulWidget {
//   const AnalysingScreen({super.key});

//   @override
//   State<AnalysingScreen> createState() => _AnalysingScreenState();
// }

// class _AnalysingScreenState extends State<AnalysingScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnalysingController c;
//   late final AnimationController _spinController;

//   @override
//   void initState() {
//     super.initState();
//     c = Get.put(AnalysingController());
//     _spinController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _spinController.dispose();
//     Get.delete<AnalysingController>();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundOffWhite,
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 88,
//                   height: 88,
//                   decoration: BoxDecoration(
//                     color: AppCaptureColors.analysingIconBg,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.06),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: RotationTransition(
//                     turns: _spinController,
//                     child: const Icon(
//                       Icons.autorenew,
//                       color: AppCaptureColors.analysingSpinner,
//                       size: 34,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 28),
//                 Text(
//                   'Analysing your swing',
//                   textAlign: TextAlign.center,
//                   style: AppTextStyles.sectionHeader,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Examining body position, swing path, weight shift '
//                   'and grip. This takes 5-10 seconds.',
//                   textAlign: TextAlign.center,
//                   style:
//                       AppTextStyles.body.copyWith(color: AppColors.textSecondary),
//                 ),
//                 const SizedBox(height: 24),
//                 Obx(() => ClipRRect(
//                       borderRadius: BorderRadius.circular(4),
//                       child: LinearProgressIndicator(
//                         value: c.progress.value,
//                         minHeight: 6,
//                         backgroundColor:
//                             AppCaptureColors.analysingProgressTrack,
//                         color: AppCaptureColors.analysingProgressFill,
//                       ),
//                     )),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
