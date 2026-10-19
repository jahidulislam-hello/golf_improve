import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth_controller.dart';
import 'helpers/routes.dart';
import 'services/api_services.dart';
import 'services/auth_service.dart';
import 'services/device_http_overrides.dart';
import 'services/paywall_gate.dart';
import 'services/push_notification_service.dart';

void main() async {
  HttpOverrides.global = DeviceHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  _forceAndroidPhotoPicker();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  final apiService = ApiService(sharedPreferences: sharedPreferences);
  final authService = AuthService(apiService: apiService);

  await PushNotificationService.initialize(apiService: apiService);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController(authService: authService),
      child: const MyApp(),
    ),
  );
}

/// Use the system Photo Picker on Android so the app never needs
/// READ_MEDIA_IMAGES / READ_MEDIA_VIDEO (Play policy).
void _forceAndroidPhotoPicker() {
  if (kIsWeb) return;
  final impl = ImagePickerPlatform.instance;
  if (impl is ImagePickerAndroid) {
    impl.useAndroidPhotoPicker = true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ApiService.onPaymentRequired ??= PaywallGate.open;
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: 'GolfImprove',
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: Colors.white,
          ),
          defaultTransition: Transition.topLevel,
          transitionDuration: const Duration(milliseconds: 500),
          getPages: AppRoutes.page,
          initialRoute: AppRoutes.splashScreen,
        );
      },
    );
  }
}
