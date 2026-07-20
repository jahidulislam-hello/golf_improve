// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../controllers/camera_capture_controller.dart';
// import '../theme/app_capture_colors.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_text_styles.dart';
// import '../widgets/capture_overlays.dart';
// import 'review_swing_screen.dart';

// /// Screens 1-3: live camera capture with alignment guide -> auto-detect
// /// skeleton overlay, mode tabs, and record button.
// class CameraCaptureScreen extends StatefulWidget {
//   const CameraCaptureScreen({super.key});

//   @override
//   State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
// }

// class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
//   late final CameraCaptureController c;

//   @override
//   void initState() {
//     super.initState();
//     c = Get.put(CameraCaptureController());
//   }

//   @override
//   void dispose() {
//     Get.delete<CameraCaptureController>();
//     super.dispose();
//   }

//   Future<void> _onRecordTap() async {
//     final path = await c.toggleRecord();
//     if (path != null && mounted) {
//       Get.to(() => ReviewSwingScreen(videoPath: path));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryNavy,
//       body: SafeArea(
//         child: Obx(() {
//           if (c.permissionError.value != null) {
//             return _PermissionError(message: c.permissionError.value!);
//           }
//           if (!c.cameraInitialized.value || c.cameraController == null) {
//             return const Center(
//               child: CircularProgressIndicator(color: AppColors.ctaBrightBlue),
//             );
//           }
//           return _CameraUi(c: c, onRecordTap: _onRecordTap);
//         }),
//       ),
//     );
//   }
// }

// class _PermissionError extends StatelessWidget {
//   final String message;
//   const _PermissionError({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(32),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.videocam_off, color: Colors.white54, size: 48),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: AppTextStyles.body.copyWith(color: Colors.white70),
//           ),
//           const SizedBox(height: 20),
//           TextButton(
//             onPressed: () => openAppSettings(),
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _CameraUi extends StatelessWidget {
//   final CameraCaptureController c;
//   final VoidCallback onRecordTap;
//   const _CameraUi({required this.c, required this.onRecordTap});

//   @override
//   Widget build(BuildContext context) {
//     final controller = c.cameraController!;
//     return Column(
//       children: [
//         Obx(() => _TopBar(
//               isRecording: c.isRecording.value,
//               elapsed: c.formattedElapsed,
//               onClose: () => Get.back(),
//             )),
//         const SizedBox(height: 12),
//         Obx(() => _ModeTabs(selected: c.view.value, onSelect: c.selectView)),
//         const SizedBox(height: 16),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   CameraPreview(controller),
//                   Obx(() => CustomPaint(
//                         painter: c.autoDetectReady.value
//                             ? AutoDetectFramePainter(joints: c.joints)
//                             : const AlignmentGuidePainter(),
//                       )),
//                   Obx(() => c.autoDetectReady.value
//                       ? Positioned(
//                           top: 14,
//                           left: 0,
//                           right: 0,
//                           child: Center(child: _AutoDetectPill()),
//                         )
//                       : const SizedBox.shrink()),
//                   Obx(() => c.showAlignmentTip.value
//                       ? const Positioned(
//                           left: 16,
//                           right: 16,
//                           top: 64,
//                           child: _AlignmentTipCard(),
//                         )
//                       : const SizedBox.shrink()),
//                   Obx(() => Positioned(
//                         right: 12,
//                         top: c.autoDetectReady.value ? 64 : 14,
//                         child: _SideIconRail(onFlip: c.flipCamera),
//                       )),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 18),
//         Obx(() => _BottomControls(
//               isRecording: c.isRecording.value,
//               onRecord: onRecordTap,
//               onFlip: c.flipCamera,
//             )),
//         const SizedBox(height: 14),
//         Obx(() => _CaptureModeTabs(selected: c.mode.value, onSelect: c.selectMode)),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
// }

// class _RoundIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _RoundIconButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       customBorder: const CircleBorder(),
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: const BoxDecoration(
//           color: AppCaptureColors.scrimPillBg,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: Colors.white, size: 20),
//       ),
//     );
//   }
// }

// class _TopBar extends StatelessWidget {
//   final bool isRecording;
//   final String elapsed;
//   final VoidCallback onClose;

//   const _TopBar({
//     required this.isRecording,
//     required this.elapsed,
//     required this.onClose,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           _RoundIconButton(icon: Icons.close, onTap: onClose),
//           const Spacer(),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//             decoration: BoxDecoration(
//               color: AppCaptureColors.scrimPillBg,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.circle,
//                     size: 10,
//                     color: isRecording
//                         ? AppCaptureColors.recordButtonRed
//                         : Colors.white70),
//                 const SizedBox(width: 6),
//                 Text(elapsed,
//                     style: AppTextStyles.type14.copyWith(
//                         color: Colors.white, fontWeight: FontWeight.w600)),
//               ],
//             ),
//           ),
//           const Spacer(),
//           _RoundIconButton(icon: Icons.crop_free, onTap: () {}),
//         ],
//       ),
//     );
//   }
// }

// class _ModeTabs extends StatelessWidget {
//   final SwingView selected;
//   final ValueChanged<SwingView> onSelect;
//   const _ModeTabs({required this.selected, required this.onSelect});

//   @override
//   Widget build(BuildContext context) {
//     Widget tab(String label, SwingView value) {
//       final isSelected = value == selected;
//       return GestureDetector(
//         onTap: () => onSelect(value),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 150),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? AppCaptureColors.modeTabSelectedBg
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: Text(
//             label,
//             style: AppTextStyles.type13.copyWith(
//               fontWeight: FontWeight.w600,
//               color: isSelected
//                   ? AppCaptureColors.modeTabSelectedText
//                   : AppCaptureColors.modeTabUnselectedText,
//             ),
//           ),
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(4),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: AppCaptureColors.scrimPillBg,
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           tab('Face On', SwingView.faceOn),
//           tab('Down the Line', SwingView.downTheLine),
//           tab('Side On', SwingView.sideOn),
//         ],
//       ),
//     );
//   }
// }

// class _AutoDetectPill extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppCaptureColors.autoDetectPillBg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.circle, size: 8, color: Colors.white),
//           const SizedBox(width: 6),
//           Text('AUTO DETECT · READY',
//               style: AppTextStyles.type11.copyWith(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: 0.4,
//               )),
//         ],
//       ),
//     );
//   }
// }

// class _AlignmentTipCard extends StatelessWidget {
//   const _AlignmentTipCard();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppCaptureColors.alignmentCardBg,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('ALIGNMENT',
//               style: AppTextStyles.type11.copyWith(
//                 color: AppCaptureColors.autoDetectGreen,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: 0.6,
//               )),
//           const SizedBox(height: 4),
//           Text('Step back 40cm',
//               style: AppTextStyles.type18.copyWith(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//               )),
//           const SizedBox(height: 10),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: 0.55,
//               minHeight: 6,
//               backgroundColor: AppCaptureColors.alignmentProgressTrack,
//               color: AppCaptureColors.autoDetectGreen,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SideIconRail extends StatelessWidget {
//   final VoidCallback onFlip;
//   const _SideIconRail({required this.onFlip});

//   @override
//   Widget build(BuildContext context) {
//     Widget btn(IconData icon, VoidCallback onTap) => Padding(
//           padding: const EdgeInsets.only(bottom: 10),
//           child: _RoundIconButton(icon: icon, onTap: onTap),
//         );
//     return Column(
//       children: [
//         btn(Icons.menu, () {}),
//         btn(Icons.add, () {}),
//         btn(Icons.crop_square, onFlip),
//       ],
//     );
//   }
// }

// class _BottomControls extends StatelessWidget {
//   final bool isRecording;
//   final VoidCallback onRecord;
//   final VoidCallback onFlip;

//   const _BottomControls({
//     required this.isRecording,
//     required this.onRecord,
//     required this.onFlip,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 32),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white24, width: 2),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                     'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=200'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: onRecord,
//             child: Container(
//               width: 74,
//               height: 74,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                     color: AppCaptureColors.recordButtonRing, width: 4),
//               ),
//               padding: const EdgeInsets.all(6),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 150),
//                 decoration: BoxDecoration(
//                   color: AppCaptureColors.recordButtonRed,
//                   borderRadius: BorderRadius.circular(isRecording ? 8 : 32),
//                 ),
//               ),
//             ),
//           ),
//           _RoundIconButton(icon: Icons.cameraswitch, onTap: onFlip),
//         ],
//       ),
//     );
//   }
// }

// class _CaptureModeTabs extends StatelessWidget {
//   final CaptureMode selected;
//   final ValueChanged<CaptureMode> onSelect;
//   const _CaptureModeTabs({required this.selected, required this.onSelect});

//   @override
//   Widget build(BuildContext context) {
//     Widget tab(String label, CaptureMode value) {
//       final isSelected = value == selected;
//       return GestureDetector(
//         onTap: () => onSelect(value),
//         child: Column(
//           children: [
//             Text(
//               label,
//               style: AppTextStyles.type13.copyWith(
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 1.0,
//                 color: isSelected
//                     ? AppCaptureColors.captureTabActiveDot
//                     : AppCaptureColors.captureTabInactive,
//               ),
//             ),
//             const SizedBox(height: 4),
//             if (isSelected)
//               Container(
//                 width: 5,
//                 height: 5,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppCaptureColors.captureTabActiveDot,
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         tab('SLOW-MO', CaptureMode.slowMo),
//         tab('SWING', CaptureMode.swing),
//         tab('VIDEO', CaptureMode.video),
//       ],
//     );
//   }
// }
