// import 'package:flutter/foundation.dart';


// /// Drives the Reviews screen: the Pending list, the Completed list, and
// /// the "N Pending" count badge. Marking a review complete moves it from
// /// one list to the other so the UI and the count stay in sync.
// class ReviewsController extends ChangeNotifier {
//   ReviewsController({
//     List<PendingReviewItem>? pending,
//     List<CompletedReviewItem>? completed,
//   }) {
//     _pending = pending ?? _mockPending();
//     _completed = completed ?? _mockCompleted();
//   }

//   late List<PendingReviewItem> _pending;
//   late List<CompletedReviewItem> _completed;

//   List<PendingReviewItem> get pendingReviews => List.unmodifiable(_pending);
//   List<CompletedReviewItem> get completedReviews =>
//       List.unmodifiable(_completed);

//   int get pendingCount => _pending.length;

//   bool isLoading = false;

//   /// Call after feedback has been sent for [itemId] (e.g. once
//   /// ReviewSwingScreen's "Send Feedback" completes) to move it from
//   /// Pending into Completed.
//   void markCompleted(String itemId, {String completedTimeLabel = 'Just now'}) {
//     final index = _pending.indexWhere((p) => p.id == itemId);
//     if (index == -1) return;
//     final item = _pending.removeAt(index);
//     _completed.insert(
//       0,
//       CompletedReviewItem(
//         id: item.id,
//         studentName: item.studentName,
//         club: item.club,
//         angle: item.angle,
//         completedTimeLabel: completedTimeLabel,
//       ),
//     );
//     notifyListeners();
//   }

//   Future<void> refresh() async {
//     isLoading = true;
//     notifyListeners();
//     // Hook your real repository call here.
//     await Future<void>.delayed(const Duration(milliseconds: 400));
//     isLoading = false;
//     notifyListeners();
//   }

//   static List<PendingReviewItem> _mockPending() => const [
//         PendingReviewItem(
//           id: 'alex_thompson_driver_faceon',
//           studentName: 'Alex Thompson',
//           studentAvatarUrl: 'https://i.pravatar.cc/150?img=12',
//           club: 'Driver',
//           angle: 'Face On',
//           durationLabel: '0:12',
//           quote:
//               'My downswing path feels off — can you check my transition?',
//           videoThumbnailUrl:
//               'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=800',
//           hasAiIncluded: true,
//         ),
//         PendingReviewItem(
//           id: 'sarah_chen_7iron_dtl',
//           studentName: 'Sarah Chen',
//           studentAvatarUrl: 'https://i.pravatar.cc/150?img=32',
//           club: '7 Iron',
//           angle: 'Down the Line',
//           durationLabel: '0:09',
//           quote: 'Does my hip rotation look better than last week?',
//           videoThumbnailUrl:
//               'https://images.unsplash.com/photo-1591491634026-4114cb9563cf?w=800',
//         ),
//         PendingReviewItem(
//           id: 'mike_rodriguez_wedge_sideon',
//           studentName: 'Mike Rodriguez',
//           studentAvatarUrl: 'https://i.pravatar.cc/150?img=51',
//           club: 'Wedge',
//           angle: 'Side On',
//           durationLabel: '0:15',
//           quote: 'What am I doing wrong with the follow-through?',
//           videoThumbnailUrl:
//               'https://images.unsplash.com/photo-1622547748225-3fc4abd2cca0?w=800',
//           hasAiIncluded: true,
//         ),
//       ];

//   static List<CompletedReviewItem> _mockCompleted() => const [
//         CompletedReviewItem(
//           id: 'emma_park_driver_faceon_done',
//           studentName: 'Emma Park',
//           club: 'Driver',
//           angle: 'Face On',
//           completedTimeLabel: '2 days ago',
//         ),
//         CompletedReviewItem(
//           id: 'alex_thompson_iron_dtl_done',
//           studentName: 'Alex Thompson',
//           club: 'Iron',
//           angle: 'Down the Line',
//           completedTimeLabel: '3 days ago',
//         ),
//       ];
// }
