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

  static String personalInformationScreen = "/personal_information_screen";
  static String editProfileScreen = "/edit_profile_screen";
  static String memberProfileScreen = "/member_profile_screen";
  static String settingsScreen = "/settings_screen";
  static String changePasswordScreen = "/change_password_screen";
  static String privacyPolicyScreen = "/privacy_policy_screen";
  static String termsConditionScreen = "/terms_condition_screen";
  static String aboutusScreen = "/aboutus_screen";
  static String upcomingEventScreen = "/upcoming_event_screen";
  static String eventDetailsScreen = "/details_event_screen";
  static String searchEventScreen = "/search_event_screen";
  static String notificationsScreen = "/notifications_screen";
  static String filterScreen = "/filter_screen";

  static String inviteEventScreen = "/invite_event_screen";
  static String ownershipScreen = "/ownership_screen";
  static String mapScreen = "/map_screen";
  static String createFamilyGroup = "/createFamilyGroup";
  static String updateFamilyGroup = "/updateFamilyGroup";

  //static String bottomMenu ="/bottom_menu";

  static String myFamilyScreen = "/my_family_screen";
  static String createMemberProfileScreen = "/CreateMemberProfileScreen";
  static String myEventScreen = "/myEventScreen";
  static String myTodayEventScreen = "/MyTodayEventScreen";
  static String myEventFilterScreen = "/myEventFilterScreen";
  static String myConnectionScreen = "/myConnectionScreen";
  static String myContributionScreen = "/myContributionScreen";
  static String contributionFilterScreen = "/contributionFilterScreen";
  static String myInvitationPage = "/MyInvitationPage";
  static String shareInvitationPage = "/share_Invitation_Page";
  static String errorScreen = "/errorScreen";
  static String memberProfileDetailsScreen = "/memberProfileDetailsScreen";
  static String ownerProfileDetailsScreen = "/OwnerProfileDetailsScreen";
  static String appliedSearchEventListScreen = "/appliedSearch_Screen";
  static String suggestionDonationPage = "/suggestion_donation_page";
  static String suggestionScreen = "/suggestion_screen";
  static String donationScreen = "/donation_screen";
  static String makePaymentScreen = "/makePayment_screen";
  static String paymentSuccessScreen = "/paymentSuccessScreen";
  static String donationMoodScreen = "/donationMoodScreen";

  static String categoriesFilterScreen = "/categoriesFilterScreen";
  static String categoriesSearchAppliedScreen =
      "/categories_search_applied_screen";
  static String forgetPasswordOtpScreen = "/forgetPasswordOtpScreen";
  static String signUpOtpVerificationScreen = "/signUpOtpVerificationScreen";

  //create event
  static String createEventOne = "/create_event_one";
  static String stepTwoContent = "/stepTwoContent";

  //==============Invitation page================

  static String invitationListPage = "/invitationPage";
  static String familyGroupScreen = "/familyGroupScreen";

//======================>>>> List PAge
  static List<GetPage> page = [
    GetPage(
        name: splashScreen,
        page: () => SplashScreen(
              onFinished: () => Get.offNamed(onboardScreen),
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
  //   GetPage(
  //       name: categoriesScreen,
  //       page: () => const CategoriesScreen(),
  //       transition: Transition.noTransition),
  //   // GetPage(
  //   //     name: createAccountScreen,
  //   //     page: () => CreateAccountScreen(),
  //   //     transition: Transition.noTransition),
  //   GetPage(
  //       name: calenderScreen,
  //       page: () => const CalenderScreen(),
  //       transition: Transition.noTransition),
  //   GetPage(
  //       name: profileScreen,
  //       page: () => const ProfileScreen(),
  //       transition: Transition.noTransition),
  //   GetPage(name: walletScreen, page: () => const WalletScreen()),
  //   GetPage(name: onboardScreen, page: () => const OnboardScreen()),
  //   GetPage(name: signInScreen, page: () => const SignInScreen()),
  //   GetPage(name: signUpScreen, page: () => const SignUpScreen()),
  //   GetPage(
  //       name: forgotPasswordScreen, page: () => const ForgotPasswordScreen()),
  //   GetPage(
  //       name: verificationCodeScreen,
  //       page: () => const VerificationCodeScreen()),
  //   GetPage(name: resetPasswordScreen, page: () => const ResetPasswordScreen()),
  //   GetPage(
  //       name: personalInformationScreen,
  //       page: () => const PersonalInformationScreen()),
  //   GetPage(name: editProfileScreen, page: () => const EditProfileScreen()),
  //   GetPage(name: memberProfileScreen, page: () => const MemberProfileScreen()),
  //   GetPage(name: settingsScreen, page: () => const SettingsScreen()),
  //   GetPage(
  //       name: changePasswordScreen, page: () => const ChangePasswordScreen()),
  //   GetPage(name: privacyPolicyScreen, page: () => PrivacyPolicyScreen()),
  //   GetPage(name: termsConditionScreen, page: () => TermsConditionScreen()),
  //   GetPage(name: aboutusScreen, page: () => AboutusScreen()),
  //   GetPage(name: upcomingEventScreen, page: () => const UpcomingEventScreen()),
  //   GetPage(name: eventDetailsScreen, page: () => const EventDetailsScreen()),
  //   GetPage(name: searchEventScreen, page: () => const SearchEventScreen()),
  //   GetPage(name: notificationsScreen, page: () => const NotificationsScreen()),
  //   GetPage(name: filterScreen, page: () => const FilterScreen()),

  //   GetPage(name: createEventOne, page: () => const CreateEventOne()),
  //   GetPage(name: stepTwoContent, page: () => const StepTwoForm()),
  //   GetPage(name: inviteEventScreen, page: () => const InviteEventScreen()),
  //   GetPage(name: ownershipScreen, page: () => const OwnershipScreen()),
  //   GetPage(name: mapScreen, page: () => const MapScreen()),
  //   GetPage(name: familyGroupScreen, page: () => const FamilyGroupScreen()),
  //   GetPage(name: createFamilyGroup, page: () => const CreateFamilyGroup()),
  //   GetPage(name: updateFamilyGroup, page: () => const UpdateFamilyGroup()),
  //   //GetPage(name:bottomMenu, page: ()=> BottomMenu()),

  //   //==============================>>>> Profile section <<<<< ============
  //   GetPage(name: myFamilyScreen, page: () => const MyFamilyScreen()),
  //   GetPage(
  //       name: createMemberProfileScreen,
  //       page: () => const CreateMemberProfileScreen()),
  //   GetPage(
  //       name: myEventScreen,
  //       page: () => const MyEventScreen(),
  //       transition: Transition.noTransition),
  //   GetPage(
  //       name: myTodayEventScreen,
  //       page: () => const MyTodayEventScreen(),
  //       transition: Transition.noTransition),
  //   GetPage(name: myEventFilterScreen, page: () => const MyEventFilterScreen()),
  //   GetPage(name: myConnectionScreen, page: () => const MyConnectionScreen()),

  //   GetPage(name: myContributionScreen, page: () => const MyContributionScreen()),
  //   GetPage(
  //       name: contributionFilterScreen, page: () => const ContributionFilterScreen()),
  //   GetPage(name: myInvitationPage, page: () => const MyInvitationPage()),
  //   GetPage(name: shareInvitationPage, page: () => const ShareInvitationPage()),
  //   GetPage(name: errorScreen, page: () => const ErrorScreen()),

  //   GetPage(
  //       name: memberProfileDetailsScreen,
  //       page: () => const MemberProfileDetailsScreen()),
  //   GetPage(
  //       name: ownerProfileDetailsScreen,
  //       page: () => const OwnerProfileDetailsScreen()),
  //   GetPage(
  //       name: appliedSearchEventListScreen,
  //       page: () => const AppliedSearchEventListScreen()),

  //   //home
  //   GetPage(name: suggestionDonationPage, page: () => SuggestionDonationPage()),
  //   GetPage(name: suggestionScreen, page: () => SuggestionScreen()),
  //   GetPage(name: donationScreen, page: () => DonationScreen()),
  //   GetPage(name: donationMoodScreen, page: () => DonationMoodScreen()),

  //   GetPage(name: makePaymentScreen, page: () => const MakePaymentScreen()),
  //   GetPage(name: paymentSuccessScreen, page: () => PaymentSuccessScreen()),
  //   GetPage(
  //       name: forgetPasswordOtpScreen, page: () => const ForgetPasswordOtpScreen()),
  //   GetPage(
  //       name: signUpOtpVerificationScreen,
  //       page: () => const SignUpOtpVerificationScreen()),

  //   //category
  //   GetPage(name: categoriesFilterScreen, page: () => const CategoriesFilterScreen()),
  //   GetPage(
  //       name: categoriesSearchAppliedScreen,
  //       page: () => CategoriesSearchAppliedScreen(category: Get.arguments),
  //       binding: BindingsBuilder(() {
  //         Get.lazyPut(() => ApiService(sharedPreferences: Get.find()));
  //       })),
  //   //========Invitation page
  //   GetPage(
  //       name: invitationListPage,
  //       page: () => const Invitationlist(),
  //       binding: BindingsBuilder(() {
  //         Get.lazyPut(() => InvitationListController());
  //       })),
  //
  ];
}