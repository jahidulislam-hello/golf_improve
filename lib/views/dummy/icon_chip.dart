// import 'package:flutter/material.dart';
//
// /// The small circular tinted background behind an icon — used for the
// /// settings list icons, the stand-connected dot, and the log-out icon.
// class IconChip extends StatelessWidget {
//   const IconChip({
//     super.key,
//     required this.icon,
//     required this.background,
//     required this.foreground,
//     this.size = 40,
//     this.iconSize = 20,
//   });
//
//   final IconData icon;
//   final Color background;
//   final Color foreground;
//   final double size;
//   final double iconSize;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: background,
//         shape: BoxShape.circle,
//       ),
//       alignment: Alignment.center,
//       child: Icon(icon, size: iconSize, color: foreground),
//     );
//   }
// }
