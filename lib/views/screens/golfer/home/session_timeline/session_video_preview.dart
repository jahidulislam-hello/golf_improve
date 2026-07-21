// import 'package:flutter/material.dart';
// import '../models/session_timeline_models.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_text_styles.dart';
// import '../controllers/session_timeline_controller.dart';
//
// /// Full-bleed swing video preview with:
// ///  - dark bottom-scrim + caption text
// ///  - centered translucent play button
// ///  - top-right floating "expand" and "aim/annotate" circular buttons
// ///  - bottom scrub bar with a play icon + "0:02/0:08" time label
// class SessionVideoPreview extends StatelessWidget {
//   const SessionVideoPreview({
//     super.key,
//     required this.video,
//     required this.onTogglePlay,
//     required this.onExpand,
//     required this.onOpenAnalysisTool,
//     required this.onScrub,
//   });
//
//   final SwingVideoState video;
//   final VoidCallback onTogglePlay;
//   final VoidCallback onExpand;
//   final VoidCallback onOpenAnalysisTool;
//   final ValueChanged<double> onScrub;
//
//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 4 / 3.1,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Background image / video frame.
//           Image.network(
//             video.thumbnailUrl,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) => Container(
//               color: AppColors.primaryNavy,
//             ),
//           ),
//
//           // Bottom scrim so the caption + scrub bar stay legible.
//           const DecoratedBox(
//             decoration: BoxDecoration(gradient: AppColors.heroImageScrimGradient),
//           ),
//
//           // Center play/pause button.
//           Center(
//             child: GestureDetector(
//               onTap: onTogglePlay,
//               child: Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.black.withOpacity(0.28),
//                   border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.5),
//                 ),
//                 child: Icon(
//                   video.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
//                   color: AppColors.surfaceWhite,
//                   size: 28,
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
//                 _CircleIconButton(
//                   icon: Icons.open_in_full_rounded,
//                   background: AppColors.ctaBrightBlue,
//                   iconColor: AppColors.surfaceWhite,
//                   onTap: onExpand,
//                 ),
//                 const SizedBox(height: 10),
//                 _CircleIconButton(
//                   icon: Icons.adjust_rounded,
//                   background: Colors.black.withOpacity(0.35),
//                   iconColor: AppColors.surfaceWhite,
//                   onTap: onOpenAnalysisTool,
//                 ),
//               ],
//             ),
//           ),
//
//           // Caption + scrub bar pinned to the bottom.
//           Positioned(
//             left: 16,
//             right: 16,
//             bottom: 14,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   video.caption,
//                   style: AppTextStyles.thumbnailSubtitle.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 _ScrubBar(video: video, onTogglePlay: onTogglePlay, onScrub: onScrub),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _CircleIconButton extends StatelessWidget {
//   const _CircleIconButton({
//     required this.icon,
//     required this.background,
//     required this.iconColor,
//     required this.onTap,
//   });
//
//   final IconData icon;
//   final Color background;
//   final Color iconColor;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(shape: BoxShape.circle, color: background),
//         child: Icon(icon, color: iconColor, size: 18),
//       ),
//     );
//   }
// }
//
// class _ScrubBar extends StatelessWidget {
//   const _ScrubBar({
//     required this.video,
//     required this.onTogglePlay,
//     required this.onScrub,
//   });
//
//   final SwingVideoState video;
//   final VoidCallback onTogglePlay;
//   final ValueChanged<double> onScrub;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 30,
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.38),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: onTogglePlay,
//             child: Icon(
//               video.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
//               color: AppColors.surfaceWhite,
//               size: 18,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: SliderTheme(
//               data: SliderTheme.of(context).copyWith(
//                 trackHeight: 3,
//                 thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
//                 overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
//                 activeTrackColor: AppColors.surfaceWhite,
//                 inactiveTrackColor: Colors.white.withOpacity(0.35),
//                 thumbColor: AppColors.surfaceWhite,
//               ),
//               child: Slider(
//                 value: video.progress.clamp(0.0, 1.0),
//                 onChanged: onScrub,
//               ),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             '${SessionTimelineController.formatDuration(video.position)}/'
//             '${SessionTimelineController.formatDuration(video.duration)}',
//             style: AppTextStyles.type11.copyWith(
//               color: AppColors.surfaceWhite,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
