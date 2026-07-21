import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'helpers/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController(),
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
