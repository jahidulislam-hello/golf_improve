// import 'package:flutter/material.dart';
// import 'package:golf_training_app/views/screens/coach/reviewers/ano/reviews_controller.dart';
// import '../../controllers/reviews_controller.dart';
// import '../../models/review_item.dart';
// import '../../models/swing_review.dart';
// import '../../theme/app_colors.dart';
// import '../../theme/app_text_styles.dart';
// import '../../widgets/reviews/completed_review_tile.dart';
// import '../../widgets/reviews/pending_count_pill.dart';
// import '../../widgets/reviews/pending_review_video_card.dart';
// import '../review_swing_screen.dart';

// /// "Reviews" screen: header with a "N Pending" badge, a Pending section
// /// of tappable video cards, and a Completed section list. Tapping a
// /// pending card (or its "Review Now" button) opens [ReviewSwingScreen].
// class ReviewsScreen extends StatefulWidget {
//   const ReviewsScreen({super.key, this.controller});

//   final ReviewsController? controller;

//   @override
//   State<ReviewsScreen> createState() => _ReviewsScreenState();
// }

// class _ReviewsScreenState extends State<ReviewsScreen> {
//   late final ReviewsController _controller =
//       widget.controller ?? ReviewsController();

//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(_onChanged);
//   }

//   void _onChanged() => setState(() {});

//   @override
//   void dispose() {
//     _controller.removeListener(_onChanged);
//     if (widget.controller == null) _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _openPendingReview(PendingReviewItem item) async {
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => ReviewSwingScreen(
//           review: SwingReview.fromPendingReviewItem(item),
//         ),
//       ),
//     );
//     // Optional: once the coach sends feedback and returns here, you can
//     // call `_controller.markCompleted(item.id);` to move the card into
//     // the Completed section. Left manual so you can trigger it from the
//     // real "Send Feedback" success callback instead of on every pop.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundOffWhite,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: _controller.refresh,
//           child: CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Container(
//                   color: AppColors.surfaceWhite,
//                   padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Reviews',
//                         style: AppTextStyles.screenTitle.copyWith(
//                           fontSize: 32,
//                         ),
//                       ),
//                       PendingCountPill(count: _controller.pendingCount),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverPadding(
//                 padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
//                 sliver: SliverToBoxAdapter(
//                   child: Text('PENDING', style: AppTextStyles.inputLabel),
//                 ),
//               ),
//               SliverPadding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 sliver: SliverList(
//                   delegate: SliverChildListDelegate([
//                     for (final item in _controller.pendingReviews)
//                       PendingReviewVideoCard(
//                         key: ValueKey(item.id),
//                         item: item,
//                         onTap: () => _openPendingReview(item),
//                       ),
//                   ]),
//                 ),
//               ),
//               if (_controller.completedReviews.isNotEmpty) ...[
//                 SliverPadding(
//                   padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
//                   sliver: SliverToBoxAdapter(
//                     child: Text('COMPLETED', style: AppTextStyles.inputLabel),
//                   ),
//                 ),
//                 SliverPadding(
//                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
//                   sliver: SliverToBoxAdapter(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 14),
//                       decoration: BoxDecoration(
//                         color: AppColors.surfaceWhite,
//                         borderRadius: BorderRadius.circular(18),
//                         border: Border.all(color: AppColors.borderCard),
//                       ),
//                       child: Column(
//                         children: [
//                           for (int i = 0;
//                               i < _controller.completedReviews.length;
//                               i++)
//                             CompletedReviewTile(
//                               item: _controller.completedReviews[i],
//                               showDivider: i !=
//                                   _controller.completedReviews.length - 1,
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
