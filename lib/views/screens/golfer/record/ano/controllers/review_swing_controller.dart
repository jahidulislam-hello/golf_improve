// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';

// /// GetX controller backing [ReviewSwingScreen] (screens 4-5).
// class ReviewSwingController extends GetxController {
//   final String videoPath;
//   ReviewSwingController({required this.videoPath});

//   late final VideoPlayerController videoController;
//   final RxBool initialized = false.obs;
//   final RxDouble speed = 1.0.obs;

//   /// Bumped on every VideoPlayerController tick purely so `Obx` widgets that
//   /// read `videoController.value` directly know when to rebuild (the
//   /// controller itself isn't an Rx type).
//   final RxInt _tick = 0.obs;
//   int get tick => _tick.value;

//   @override
//   void onInit() {
//     super.onInit();
//     videoController = VideoPlayerController.file(File(videoPath))
//       ..initialize().then((_) {
//         initialized.value = true;
//         _tick.value++;
//       });
//     videoController.addListener(() => _tick.value++);
//   }

//   void setSpeed(double value) {
//     speed.value = value;
//     videoController.setPlaybackSpeed(value);
//   }

//   void togglePlay() {
//     videoController.value.isPlaying
//         ? videoController.pause()
//         : videoController.play();
//   }

//   void seekBy(Duration delta) {
//     final target = videoController.value.position + delta;
//     final duration = videoController.value.duration;
//     final clamped = target < Duration.zero
//         ? Duration.zero
//         : (target > duration ? duration : target);
//     videoController.seekTo(clamped);
//   }

//   void seekToFraction(double fraction) {
//     if (!initialized.value) return;
//     videoController.seekTo(videoController.value.duration * fraction);
//   }

//   @override
//   void onClose() {
//     videoController.dispose();
//     super.onClose();
//   }
// }
