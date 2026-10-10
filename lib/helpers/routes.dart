import 'package:get/get.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/views/base/coach_navbar/coach_navbar.dart';
import 'package:golf_training_app/views/base/golfer_navbar/golfer_navbar.dart';
import 'package:golf_training_app/views/screens/auth/screens/sign_in_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/screen/home_screen.dart';
import 'package:golf_training_app/views/screens/onboarding/onboarding/onboarding_screen.dart';
import 'package:golf_training_app/views/screens/onboarding/role_selection/role_selection_controller.dart';
import 'package:golf_training_app/views/screens/onboarding/role_selection/role_selection_screen.dart';
import 'package:golf_training_app/views/screens/onboarding/splash/splash_screen.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static String splashScreen = "/splash_screen";
  static String roleSelectionScreen = "/role_selection_screen";

  static String homeScreen = "/home_screen";
  static String golferNavbar = "/golfer_navbar";
  static String coachNavbar = "/coach_navbar";
  static String categoriesScreen = "/categories_screen";
  static String calenderScreen = "/calender_screen";
  static String profileScreen = "/profile_screen";

  static String walletScreen = "/wallet_screen";
  static String onboardScreen = "/onboarding_screen";
  static String onboardSecondScreen = "/onboard_second_screen";
  static String signInScreen = "/sign_in_screen";
  static String signUpScreen = "/sign_up_screen";
  static String createAccountScreen = "/create_account_screen";
  static String forgotPasswordScreen = "/forgot_password_screen";
  static String verificationCodeScreen = "/verification_code_screen";
  static String resetPasswordScreen = "/reset_password_screen";

  /// After auth: coach → CoachNavbar, golfer → GolferNavbar.
  static void goToHomeForRole([UserRole? role]) {
    final resolved = role ??
        (Get.context != null
            ? Provider.of<AuthController>(Get.context!, listen: false)
                .selectedRole
            : null);
    if (resolved == UserRole.coach) {
      Get.offAllNamed(coachNavbar);
    } else {
      Get.offAllNamed(golferNavbar);
    }
  }

  /// Splash finished: auto-login when token + role exist, else onboarding.
  static void handleSplashFinished() {
    final context = Get.context;
    if (context == null) {
      Get.offNamed(onboardScreen);
      return;
    }

    final auth = Provider.of<AuthController>(context, listen: false);
    final role = auth.restoreSession();
    if (role != null) {
      goToHomeForRole(role);
    } else {
      Get.offNamed(onboardScreen);
    }
  }


//======================>>>> List PAge
  static List<GetPage> page = [
    GetPage(
        name: splashScreen,
        page: () => SplashScreen(
              onFinished: AppRoutes.handleSplashFinished,
            )),
    GetPage(
        name: onboardScreen,
        page: () => OnboardingScreen(
              onComplete: () => Get.offNamed(roleSelectionScreen),
            )),
    GetPage(
        name: roleSelectionScreen,
        page: () => RoleSelectionScreen(
              onRoleConfirmed: (role) {
                final auth = Provider.of<AuthController>(
                  Get.context!,
                  listen: false,
                );
                auth.setSelectedRole(role);
                Get.toNamed(signInScreen);
              },
            )),
    GetPage(
        name: signInScreen,
        page: () => const SignInScreen()),

    GetPage(
        name: golferNavbar,
        page: () => const GolferNavbar(),
        transition: Transition.noTransition),
    GetPage(
        name: coachNavbar,
        page: () => const CoachNavbar(),
        transition: Transition.noTransition),
    GetPage(
        name: homeScreen,
        page: () => const HomeScreen(),
        transition: Transition.noTransition),

  ];
}