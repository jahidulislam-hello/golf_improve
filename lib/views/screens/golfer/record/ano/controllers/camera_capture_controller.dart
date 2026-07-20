// import 'dart:async';
// import 'package:camera/camera.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../widgets/capture_overlays.dart';

// enum SwingView { faceOn, downTheLine, sideOn }

// enum CaptureMode { slowMo, swing, video }

// /// GetX controller backing [CameraCaptureScreen] (screens 1-3). Holds the
// /// live [CameraController], the recording timer, and the auto-detect /
// /// pose overlay state.
// class CameraCaptureController extends GetxController {
//   CameraController? cameraController;
//   List<CameraDescription> cameras = [];
//   int cameraIndex = 0;

//   final Rx<SwingView> view = SwingView.downTheLine.obs;
//   final Rx<CaptureMode> mode = CaptureMode.swing.obs;

//   final RxBool cameraInitialized = false.obs;
//   final RxBool isRecording = false.obs;
//   final Rx<Duration> elapsed = Duration.zero.obs;
//   Timer? _recordTimer;

//   /// Simulated pose-detection state. Wire this up to a real ML Kit /
//   /// TFLite pose model — update `autoDetectReady` / `joints` from your
//   /// model's output on each camera frame instead of the timers below.
//   final RxBool autoDetectReady = false.obs;
//   final RxBool showAlignmentTip = false.obs;
//   final RxList<Joint> joints = <Joint>[].obs;

//   final RxnString permissionError = RxnString();

//   @override
//   void onInit() {
//     super.onInit();
//     _init();
//   }

//   Future<void> _init() async {
//     final camStatus = await Permission.camera.request();
//     final micStatus = await Permission.microphone.request();

//     if (!camStatus.isGranted || !micStatus.isGranted) {
//       permissionError.value =
//           'Camera and microphone access are required to record your swing. '
//           'Enable them in Settings to continue.';
//       return;
//     }

//     try {
//       cameras = await availableCameras();
//       if (cameras.isEmpty) {
//         permissionError.value = 'No camera found on this device.';
//         return;
//       }
//       await startCamera(cameras.first);
//     } catch (e) {
//       permissionError.value = 'Could not start the camera: $e';
//     }
//   }

//   Future<void> startCamera(CameraDescription description) async {
//     final previous = cameraController;
//     final controller = CameraController(
//       description,
//       ResolutionPreset.high,
//       enableAudio: true,
//     );
//     cameraController = controller;
//     await controller.initialize();
//     await previous?.dispose();
//     cameraInitialized.value = true;
//     _beginAutoDetectSimulation();
//   }

//   /// Mirrors the flow across screenshots 1 -> 2 -> 3: no detection yet, then
//   /// "AUTO DETECT · READY" with an alignment tip, then the tip clears.
//   void _beginAutoDetectSimulation() {
//     autoDetectReady.value = false;
//     showAlignmentTip.value = false;
//     joints.clear();

//     Future.delayed(const Duration(seconds: 2), () {
//       autoDetectReady.value = true;
//       showAlignmentTip.value = true;
//       joints.assignAll(defaultSwingJoints);
//     });
//     Future.delayed(const Duration(seconds: 5), () {
//       showAlignmentTip.value = false;
//     });
//   }

//   Future<void> flipCamera() async {
//     if (cameras.length < 2) return;
//     cameraIndex = (cameraIndex + 1) % cameras.length;
//     await startCamera(cameras[cameraIndex]);
//   }

//   void selectView(SwingView v) => view.value = v;
//   void selectMode(CaptureMode m) => mode.value = m;

//   /// Returns the recorded file path once recording stops, or null while
//   /// still recording / on failure.
//   Future<String?> toggleRecord() async {
//     final controller = cameraController;
//     if (controller == null || !controller.value.isInitialized) return null;

//     if (isRecording.value) {
//       _recordTimer?.cancel();
//       final file = await controller.stopVideoRecording();
//       isRecording.value = false;
//       return file.path;
//     } else {
//       await controller.prepareForVideoRecording();
//       await controller.startVideoRecording();
//       isRecording.value = true;
//       elapsed.value = Duration.zero;
//       _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//         elapsed.value += const Duration(seconds: 1);
//       });
//       return null;
//     }
//   }

//   String get formattedElapsed {
//     final d = elapsed.value;
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   @override
//   void onClose() {
//     _recordTimer?.cancel();
//     cameraController?.dispose();
//     super.onClose();
//   }
// }
