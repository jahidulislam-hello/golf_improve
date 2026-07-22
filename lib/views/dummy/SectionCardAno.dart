// import 'package:flutter/material.dart';
// import '../app_colors.dart';
//
// /// The plain white rounded-corner card container that shows up everywhere
// /// in the design (settings rows, form fields, the stat card, etc).
// class SectionCardAno extends StatelessWidget {
//   const SectionCardAno({
//     super.key,
//     required this.child,
//     this.padding = const EdgeInsets.all(16),
//     this.margin,
//     this.radius = 18,
//     this.color = AppColors.surfaceWhite,
//     this.onTap,
//   });
//
//   final Widget child;
//   final EdgeInsetsGeometry padding;
//   final EdgeInsetsGeometry? margin;
//   final double radius;
//   final Color color;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final card = Container(
//       margin: margin,
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(radius),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x0A0A1628),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: onTap == null
//           ? Padding(padding: padding, child: child)
//           : Material(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(radius),
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(radius),
//                 onTap: onTap,
//                 child: Padding(padding: padding, child: child),
//               ),
//             ),
//     );
//     return card;
//   }
// }
