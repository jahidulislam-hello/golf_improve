// import 'package:flutter/material.dart';
//
// import 'app_colors.dart';
// import 'app_text_styles.dart';
// import 'models/swing_insight.dart';
// import 'swing_analysis_controller.dart';
//
// /// "Swing Analysis" screen: video player with a scrub bar and a
// /// freehand angle-drawing overlay, an "AI Golf Coach" CTA, and a list
// /// of AI-generated insight cards.
// ///
// /// This widget is purely presentational — all state lives in
// /// [SwingAnalysisController], which is passed in so the screen can be
// /// dropped into any navigator / DI setup you're already using.
// class SwingAnalysisScreen extends StatelessWidget {
//   const SwingAnalysisScreen({
//     super.key,
//     required this.controller,
//     this.onBack,
//     this.onMorePressed,
//   });
//
//   final SwingAnalysisController controller;
//   final VoidCallback? onBack;
//   final VoidCallback? onMorePressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundOffWhite,
//       body: SafeArea(
//         bottom: false,
//         child: AnimatedBuilder(
//           animation: controller,
//           builder: (context, _) {
//             return CustomScrollView(
//               slivers: [
//                 SliverToBoxAdapter(child: _AppBar(onBack: onBack, onMore: onMorePressed)),
//                 SliverToBoxAdapter(child: _VideoSection(controller: controller)),
//                 SliverToBoxAdapter(child: _AiCoachButton(controller: controller)),
//                 SliverPadding(
//                   padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
//                   sliver: SliverList.separated(
//                     itemCount: controller.insights.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 12),
//                     itemBuilder: (context, index) {
//                       return _InsightCard(insight: controller.insights[index]);
//                     },
//                   ),
//                 ),
//                 const SliverToBoxAdapter(child: SizedBox(height: 24)),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================= App bar ===
//
// class _AppBar extends StatelessWidget {
//   const _AppBar({this.onBack, this.onMore});
//
//   final VoidCallback? onBack;
//   final VoidCallback? onMore;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
//       child: Row(
//         children: [
//           _CircleIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
//           const SizedBox(width: 12),
//           Text('Swing Analysis', style: AppTextStyles.appBarTitle),
//           const Spacer(),
//           _CircleIconButton(icon: Icons.more_horiz, onTap: onMore),
//         ],
//       ),
//     );
//   }
// }
//
// class _CircleIconButton extends StatelessWidget {
//   const _CircleIconButton({
//     required this.icon,
//     this.onTap,
//     this.size = 38,
//     this.background = AppColors.pillInactive,
//     this.iconColor = AppColors.textPrimary,
//     this.iconSize = 18,
//   });
//
//   final IconData icon;
//   final VoidCallback? onTap;
//   final double size;
//   final Color background;
//   final Color iconColor;
//   final double iconSize;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: background,
//       shape: const CircleBorder(),
//       child: InkWell(
//         onTap: onTap,
//         customBorder: const CircleBorder(),
//         child: SizedBox(
//           width: size,
//           height: size,
//           child: Icon(icon, size: iconSize, color: iconColor),
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================ Video ======
//
// class _VideoSection extends StatelessWidget {
//   const _VideoSection({required this.controller});
//
//   final SwingAnalysisController controller;
//
//   static const double _height = 320;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: _height,
//       width: double.infinity,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Video / poster frame.
//           Image(image: controller.videoThumbnail, fit: BoxFit.cover),
//
//           // Bottom-to-top scrim so overlay text/controls stay legible.
//           const DecoratedBox(
//             decoration: BoxDecoration(gradient: AppColors.heroImageScrimGradient),
//           ),
//
//           // Freehand draw layer — drag anywhere on the video to draw the
//           // angle line, exactly like "Scrub to the moment... Then draw."
//           Positioned.fill(
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onPanStart: (details) => controller.startDrawing(details.localPosition),
//               onPanUpdate: (details) => controller.updateDrawing(details.localPosition),
//               onPanEnd: (_) => controller.endDrawing(),
//               child: CustomPaint(
//                 painter: _DrawOverlayPainter(
//                   start: controller.drawStart,
//                   end: controller.drawEnd,
//                 ),
//               ),
//             ),
//           ),
//
//           // Top-right floating controls.
//           Positioned(
//             top: 16,
//             right: 16,
//             child: Column(
//               children: [
//                 _RoundActionButton(
//                   icon: Icons.open_in_full,
//                   onTap: () {},
//                 ),
//                 const SizedBox(height: 10),
//                 _RoundActionButton(
//                   icon: Icons.track_changes_outlined,
//                   onTap: controller.clearDrawing,
//                 ),
//               ],
//             ),
//           ),
//
//           // Center play/pause button.
//           if (!controller.isPlaying)
//             Center(
//               child: _PlayButton(onTap: controller.togglePlayPause),
//             ),
//
//           // Bottom hint text + scrub bar.
//           Positioned(
//             left: 16,
//             right: 16,
//             bottom: 14,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Scrub to the moment you want to analyse. Then draw.',
//                   textAlign: TextAlign.center,
//                   style: AppTextStyles.videoOverlayHint,
//                 ),
//                 const SizedBox(height: 10),
//                 _ScrubBar(controller: controller),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _RoundActionButton extends StatelessWidget {
//   const _RoundActionButton({required this.icon, required this.onTap});
//
//   final IconData icon;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AppColors.ctaBrightBlue,
//       shape: const CircleBorder(),
//       elevation: 2,
//       child: InkWell(
//         onTap: onTap,
//         customBorder: const CircleBorder(),
//         child: SizedBox(
//           width: 38,
//           height: 38,
//           child: Icon(icon, size: 18, color: AppColors.surfaceWhite),
//         ),
//       ),
//     );
//   }
// }
//
// class _PlayButton extends StatelessWidget {
//   const _PlayButton({required this.onTap});
//
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AppColors.surfaceWhite.withOpacity(0.9),
//       shape: const CircleBorder(),
//       elevation: 3,
//       child: InkWell(
//         onTap: onTap,
//         customBorder: const CircleBorder(),
//         child: const SizedBox(
//           width: 56,
//           height: 56,
//           child: Icon(Icons.play_arrow, size: 30, color: AppColors.primaryNavy),
//         ),
//       ),
//     );
//   }
// }
//
// class _ScrubBar extends StatelessWidget {
//   const _ScrubBar({required this.controller});
//
//   final SwingAnalysisController controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.45),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               GestureDetector(
//                 onTap: controller.togglePlayPause,
//                 child: Icon(
//                   controller.isPlaying ? Icons.pause : Icons.play_arrow,
//                   size: 14,
//                   color: AppColors.surfaceWhite,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 '${controller.positionLabel}/${controller.totalDurationLabel}',
//                 style: AppTextStyles.videoTimestamp,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTapDown: (details) {
//                   controller.seekToFraction(details.localPosition.dx / constraints.maxWidth);
//                 },
//                 onHorizontalDragUpdate: (details) {
//                   controller.seekToFraction(details.localPosition.dx / constraints.maxWidth);
//                 },
//                 child: SizedBox(
//                   height: 14,
//                   child: Center(
//                     child: Stack(
//                       children: [
//                         Container(
//                           height: 3,
//                           decoration: BoxDecoration(
//                             color: AppColors.surfaceWhite.withOpacity(0.35),
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         FractionallySizedBox(
//                           widthFactor: controller.progress,
//                           child: Container(
//                             height: 3,
//                             decoration: BoxDecoration(
//                               color: AppColors.surfaceWhite,
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// /// Draws the blue annotation line + dot the user drags out on the video,
// /// matching the hand-drawn angle line in the design.
// class _DrawOverlayPainter extends CustomPainter {
//   _DrawOverlayPainter({required this.start, required this.end});
//
//   final Offset? start;
//   final Offset? end;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (start == null || end == null) return;
//
//     final linePaint = Paint()
//       ..color = AppColors.ctaBrightBlue
//       ..strokeWidth = 3
//       ..strokeCap = StrokeCap.round;
//
//     canvas.drawLine(start!, end!, linePaint);
//
//     final dotPaint = Paint()..color = AppColors.ctaBrightBlue;
//     canvas.drawCircle(start!, 5, dotPaint);
//   }
//
//   @override
//   bool shouldRepaint(covariant _DrawOverlayPainter oldDelegate) {
//     return oldDelegate.start != start || oldDelegate.end != end;
//   }
// }
//
// // ======================================================= AI Coach CTA ====
//
// class _AiCoachButton extends StatelessWidget {
//   const _AiCoachButton({required this.controller});
//
//   final SwingAnalysisController controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(28),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(28),
//           onTap: controller.isAnalysing ? null : controller.requestAiAnalysis,
//           child: Ink(
//             height: 56,
//             decoration: BoxDecoration(
//               gradient: AppColors.ctaBlueGradient,
//               borderRadius: BorderRadius.circular(28),
//             ),
//             child: Center(
//               child: controller.isAnalysing
//                   ? const SizedBox(
//                       width: 22,
//                       height: 22,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.4,
//                         color: AppColors.surfaceWhite,
//                       ),
//                     )
//                   : Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(
//                           Icons.psychology_outlined,
//                           size: 20,
//                           color: AppColors.surfaceWhite,
//                         ),
//                         const SizedBox(width: 10),
//                         Text('AI Golf Coach', style: AppTextStyles.aiCoachButtonLabel),
//                       ],
//                     ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ========================================================== Insight card =
//
// class _InsightCard extends StatelessWidget {
//   const _InsightCard({required this.insight});
//
//   final SwingInsight insight;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceWhite,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryNavy.withOpacity(0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: insight.iconBackground,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(insight.icon, size: 18, color: insight.iconColor),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(insight.title, style: AppTextStyles.insightCardTitle),
//                 const SizedBox(height: 4),
//                 Text(insight.description, style: AppTextStyles.insightCardBody),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
