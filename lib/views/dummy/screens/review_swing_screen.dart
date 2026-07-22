// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';

// import '../controllers/review_swing_controller.dart';
// import '../theme/app_capture_colors.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_text_styles.dart';
// import 'analysing_screen.dart';

// /// Screens 4-5: review the just-recorded clip, scrub through it, pick a
// /// playback speed, then either send it for AI analysis or discard it.
// class ReviewSwingScreen extends StatefulWidget {
//   final String videoPath;
//   const ReviewSwingScreen({super.key, required this.videoPath});

//   @override
//   State<ReviewSwingScreen> createState() => _ReviewSwingScreenState();
// }

// class _ReviewSwingScreenState extends State<ReviewSwingScreen> {
//   late final ReviewSwingController c;

//   @override
//   void initState() {
//     super.initState();
//     c = Get.put(ReviewSwingController(videoPath: widget.videoPath));
//   }

//   @override
//   void dispose() {
//     Get.delete<ReviewSwingController>();
//     super.dispose();
//   }

//   void _analyze() {
//     Get.to(() => const AnalysingScreen());
//   }

//   void _discard() {
//     Get.back();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.surfaceWhite,
//       appBar: AppBar(
//         backgroundColor: AppColors.surfaceWhite,
//         elevation: 0,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 12),
//           child: _RoundBackButton(onTap: () => Get.back()),
//         ),
//         leadingWidth: 56,
//         title: Text('Review Swing', style: AppTextStyles.appBarTitle),
//         centerTitle: false,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: TextButton(
//               style: TextButton.styleFrom(
//                 backgroundColor: AppColors.ctaBrightBlue,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               onPressed: () {},
//               child: Text('Save',
//                   style: AppTextStyles.buttonLabel.copyWith(fontSize: 15)),
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             AspectRatio(
//               aspectRatio: 16 / 10,
//               child: Container(
//                 color: Colors.black,
//                 child: Obx(() {
//                   c.tick; // subscribe to ticks so this rebuilds on playback
//                   return c.initialized.value
//                       ? FittedBox(
//                           fit: BoxFit.contain,
//                           child: SizedBox(
//                             width: c.videoController.value.size.width,
//                             height: c.videoController.value.size.height,
//                             child: VideoPlayer(c.videoController),
//                           ),
//                         )
//                       : const Center(
//                           child:
//                               CircularProgressIndicator(color: Colors.white),
//                         );
//                 }),
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _ScrubberCard(c: c),
//                     const SizedBox(height: 20),
//                     SizedBox(
//                       height: 52,
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.ctaBrightBlue,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         onPressed: _analyze,
//                         icon: const Icon(Icons.psychology_alt_outlined),
//                         label: Text('Analyze with AI',
//                             style: AppTextStyles.buttonLabel),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     SizedBox(
//                       height: 52,
//                       child: OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: AppColors.destructiveRed,
//                           side: BorderSide(color: AppColors.borderLightGray),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         onPressed: _discard,
//                         icon: const Icon(Icons.close),
//                         label: Text('Discard Clip',
//                             style: AppTextStyles.buttonLabel
//                                 .copyWith(color: AppColors.destructiveRed)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _RoundBackButton extends StatelessWidget {
//   final VoidCallback onTap;
//   const _RoundBackButton({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       customBorder: const CircleBorder(),
//       child: Container(
//         width: 36,
//         height: 36,
//         decoration: const BoxDecoration(
//           color: AppColors.pillInactive,
//           shape: BoxShape.circle,
//         ),
//         child: const Icon(Icons.chevron_left,
//             color: AppColors.textPrimary, size: 22),
//       ),
//     );
//   }
// }

// class _ScrubberCard extends StatelessWidget {
//   final ReviewSwingController c;
//   const _ScrubberCard({required this.c});

//   String _fmt(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     final ms =
//         (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
//     return '$m:$s.$ms';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       c.tick; // subscribe so position/duration/isPlaying stay current
//       final position =
//           c.initialized.value ? c.videoController.value.position : Duration.zero;
//       final duration =
//           c.initialized.value ? c.videoController.value.duration : Duration.zero;
//       final progress = duration.inMilliseconds == 0
//           ? 0.0
//           : position.inMilliseconds / duration.inMilliseconds;
//       final isPlaying = c.initialized.value && c.videoController.value.isPlaying;

//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.pillInactive,
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Row(
//               children: [
//                 InkWell(
//                   onTap: c.togglePlay,
//                   customBorder: const CircleBorder(),
//                   child: Container(
//                     width: 36,
//                     height: 36,
//                     decoration: const BoxDecoration(
//                       color: AppColors.borderLightGray,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       isPlaying ? Icons.pause : Icons.play_arrow,
//                       color: AppColors.textPrimary,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(_fmt(position),
//                     style: AppTextStyles.type16
//                         .copyWith(color: AppColors.textSecondary)),
//                 const Spacer(),
//                 _CircleIconButton(
//                   icon: Icons.replay,
//                   onTap: () => c.seekBy(const Duration(milliseconds: -200)),
//                 ),
//                 const SizedBox(width: 8),
//                 _CircleIconButton(
//                   icon: Icons.forward,
//                   onTap: () => c.seekBy(const Duration(milliseconds: 200)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 14),
//             _ScrubberRuler(
//               progress: progress.clamp(0.0, 1.0),
//               onScrub: c.seekToFraction,
//             ),
//             const SizedBox(height: 14),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [0.25, 0.5, 1.0].map((s) {
//                 final selected = s == c.speed.value;
//                 return Padding(
//                   padding: const EdgeInsets.only(left: 8),
//                   child: GestureDetector(
//                     onTap: () => c.setSpeed(s),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: selected
//                             ? AppCaptureColors.speedPillActiveBg
//                             : AppCaptureColors.speedPillInactiveBg,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Text(
//                         '${s == 1.0 ? '1' : s}x',
//                         style: AppTextStyles.type13.copyWith(
//                           fontWeight: FontWeight.w700,
//                           color: selected
//                               ? Colors.white
//                               : AppColors.textSecondary,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

// class _CircleIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _CircleIconButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       customBorder: const CircleBorder(),
//       child: Container(
//         width: 32,
//         height: 32,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: AppColors.ctaBrightBlue),
//         ),
//         child: Icon(icon, color: AppColors.ctaBrightBlue, size: 16),
//       ),
//     );
//   }
// }

// /// Ruler-style scrubber: many minor ticks + a filled played-track + a tall
// /// playhead tick, draggable — matches the timeline in screenshots 4-5.
// class _ScrubberRuler extends StatelessWidget {
//   final double progress;
//   final ValueChanged<double> onScrub;
//   const _ScrubberRuler({required this.progress, required this.onScrub});

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       final width = constraints.maxWidth;
//       return GestureDetector(
//         onHorizontalDragUpdate: (details) {
//           final v = (details.localPosition.dx / width).clamp(0.0, 1.0);
//           onScrub(v);
//         },
//         onTapDown: (details) {
//           final v = (details.localPosition.dx / width).clamp(0.0, 1.0);
//           onScrub(v);
//         },
//         child: SizedBox(
//           height: 44,
//           width: width,
//           child: CustomPaint(
//             painter: _RulerPainter(progress: progress),
//           ),
//         ),
//       );
//     });
//   }
// }

// class _RulerPainter extends CustomPainter {
//   final double progress;
//   const _RulerPainter({required this.progress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final bg = Paint()..color = AppCaptureColors.scrubberTrackBg;
//     final rrect =
//         RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10));
//     canvas.drawRRect(rrect, bg);

//     final tickPaint = Paint()
//       ..color = AppCaptureColors.scrubberTickMinor
//       ..strokeWidth = 2;
//     const tickCount = 40;
//     for (var i = 0; i <= tickCount; i++) {
//       final x = size.width / tickCount * i;
//       final tall = i % 5 == 0;
//       canvas.drawLine(
//         Offset(x, size.height / 2 - (tall ? 10 : 5)),
//         Offset(x, size.height / 2 + (tall ? 10 : 5)),
//         tickPaint,
//       );
//     }

//     final playedPaint = Paint()..color = AppCaptureColors.scrubberPlayed;
//     final playheadX = size.width * progress;
//     canvas.drawLine(
//       Offset(playheadX, 4),
//       Offset(playheadX, size.height - 4),
//       Paint()
//         ..color = AppCaptureColors.scrubberPlayhead
//         ..strokeWidth = 3,
//     );
//     canvas.drawCircle(Offset(playheadX, size.height / 2), 6, playedPaint);
//   }

//   @override
//   bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
//       oldDelegate.progress != progress;
// }
