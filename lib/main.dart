import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth_controller.dart';
import 'helpers/routes.dart';
import 'services/api_services.dart';
import 'services/auth_service.dart';
import 'services/device_http_overrides.dart';

void main() async {
  HttpOverrides.global = DeviceHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  final apiService = ApiService(sharedPreferences: sharedPreferences);
  final authService = AuthService(apiService: apiService);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController(authService: authService),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
