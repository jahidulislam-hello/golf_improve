// import 'dart:async';
// import 'package:get/get.dart';

// /// GetX controller backing [AnalysingScreen] (screen 6). Drives the
// /// progress bar shown while the clip is sent off for AI analysis.
// /// Swap the Timer-driven fake progress for a real upload/inference
// /// progress stream once the analysis backend is wired up.
// class AnalysingController extends GetxController {
//   final RxDouble progress = 0.15.obs;
//   Timer? _timer;

//   @override
//   void onInit() {
//     super.onInit();
//     _timer = Timer.periodic(const Duration(milliseconds: 400), (t) {
//       progress.value = (progress.value + 0.12).clamp(0.0, 1.0);
//       if (progress.value >= 1.0) {
//         t.cancel();
//         // TODO: navigate to the AI results screen once analysis completes,
//         // e.g. Get.off(() => const SwingAnalysisResultsScreen());
//       }
//     });
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     super.onClose();
//   }
// }
