class ApiConstants {
  static const String baseUrl = 'https://api.golfimprove.eu';
  static const String apiUrl = '$baseUrl/api/v1';

  // SharedPreferences keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyAccessTokenExpiresAt = 'access_token_expires_at';
  static const String keyRefreshTokenExpiresAt = 'refresh_token_expires_at';
  static const String keyUserData = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyGuestId = 'guest_id';
  static const String keyOfflineSwings = 'offline_swings';
  static const String keyOfflineShares = 'offline_shares';
  static const String keyLibraryCache = 'swing_library_cache';
  static const String keyProgressCache = 'progress_cache';

  // Refresh Token
  static const String refreshToken = '$apiUrl/auth/refresh-token';

  // Auth endpoints
  static const String guestSession = '$apiUrl/auth/guest-session';
  static const String mergeGuest = '$apiUrl/auth/merge-guest';
  static const String register = '$apiUrl/auth/register';
  // Docs v2: /auth/verify-email (legacy: /auth/verify-otp)
  static const String verifyOtp = '$apiUrl/auth/verify-email';
  // static const String verifyOtp = '$apiUrl/auth/verify-otp';
  static const String updateRegisterProfile = '$apiUrl/user/update-my-profile';
  // Docs v2: /auth/resend-code (legacy: /auth/resend-otp)
  static const String resendOTP = '$apiUrl/auth/resend-code';
  // static const String resendOTP = '$apiUrl/auth/resend-otp';
  static const String login = '$apiUrl/auth/login';
  /// Mobile Google Sign-In: send Google `idToken` (and optional role / guestId).
  static const String googleLogin = '$apiUrl/auth/google';
  /// Mobile Apple Sign-In: send Apple identity token.
  static const String appleLogin = '$apiUrl/auth/apple';
  static const String forgotPassword = '$apiUrl/auth/forgot-password';
  static const String forgotPasswordOTPVerify = '$apiUrl/auth/forgot-otp-verify';
  static const String resetPassword = '$apiUrl/auth/reset-password';
  static const String changePassword = '$apiUrl/auth/change-password';
  static const String logout = '$apiUrl/auth/logout';

  // Profile
  static const String getMyProfile = '$apiUrl/user/get-my-profile';
  static const String updateProfile = '$apiUrl/user/update-my-profile';
  /// Register / refresh device push token after login.
  static const String updateFcmToken = '$apiUrl/user/fcm-token';
  static const String requestEmailChange = '$apiUrl/user/request-email-change';
  static const String verifyEmailChange = '$apiUrl/user/verify-email-change';
  static const String downloadMyData = '$apiUrl/user/download-my-data';
  static const String deleteAccount = '$apiUrl/user/delete-account';
  static const String updateHandicapUser = '$apiUrl/user/handicap';
  static const String getSkills = '$apiUrl/users/edit-options';
  static const String paywallStatus = '$apiUrl/payment/paywall-status';
  static const String startTrial = '$apiUrl/payment/start-trial';
  static const String verifyAppleReceipt = '$apiUrl/payment/verify-apple-receipt';
  static const String verifyGoogleReceipt =
      '$apiUrl/payment/verify-google-receipt';

  // Subscription plans & promo codes
  static const String launchPlan = '$apiUrl/plan/launch-plan';
  static const String plans = '$apiUrl/plan/get-all';
  static String planById(String id) => '$apiUrl/plan/find/$id';
  static const String validatePromoCode = '$apiUrl/promo-code/validate';
  static const String redeemPromoCode = '$apiUrl/promo-code/redeem';

  //User/Golfer
  static const String home = '$apiUrl/meta/user';


  //Progress
  static const String progress = '$apiUrl/meta/my-progress';
  static const String updateHandicap = '$apiUrl/meta/update-handicap';



  //Library
  static const String allLibrary = '$apiUrl/swing-library/my-library';
  static const String singleLibrary = '$apiUrl/swing-library/find/:id';
  static String singleLibraryById(String id) =>
      '$apiUrl/swing-library/find/$id';
  static String askSwingQuestion(String id) =>
      '$apiUrl/swing-library/ask/$id';
  static String askCoach(String id) => '$apiUrl/swing-library/ask-coach/$id';
  static const String saveDrillPlan = '$apiUrl/swing-library/save-drill-plan';
  static String completeAiPracticeSession(String id, int sessionIndex) =>
      '$apiUrl/swing-library/$id/practice-plan/$sessionIndex/complete';
  static String fullDetails(String id) => '$apiUrl/share-swing/find/$id';
  static const String filterLibraryCategories = '$apiUrl/meta/filter-categories';

  // AI Camera / Swing analyzer
  static const String cameraCategories = '$apiUrl/swing-category/camera';
  static const String swingAnalyzer = '$apiUrl/swing/analyzer';
  static const String swingUploadUrl = '$apiUrl/swing/upload-url';
  static const String swingResumableUploadInitiate =
      '$apiUrl/swing/resumable-upload/initiate';
  static const String swingCreate = '$apiUrl/swing/create';
  static const String swingSyncOffline = '$apiUrl/swing/sync/offline';
  static const String swingCompare = '$apiUrl/swing/compare';
  static const String swingLibraryCompare = '$apiUrl/swing-library/compare';
  static const String mySwings = '$apiUrl/swing/my-swings';
  static String analyzeSwingVideo(String id) =>
      '$apiUrl/swing/analyze/video/$id';

  // AI Coach (Gemini conversational surface)
  static const String aiCoachChat = '$apiUrl/ai-coach/chat';
  static const String aiCoachSaveToNotes = '$apiUrl/ai-coach/save-to-notes';
  static const String aiCoachShareWithCoach =
      '$apiUrl/ai-coach/share-with-coach';

  // 2-week practice plan tracking
  static String practicePlanStart(String shareId) =>
      '$apiUrl/practice-plan/start/$shareId';
  static String practicePlanToggleSession(String sessionId) =>
      '$apiUrl/practice-plan/toggle-session/$sessionId';
  static String practicePlanMyPlan(String shareId) =>
      '$apiUrl/practice-plan/my-plan/$shareId';







  //Coach
  static const String coachHome = '$apiUrl/meta/coach';
  static const String getCoachProfile = '$apiUrl/user/get-my-profile';

  // Students
  static const String coachStudents = '$apiUrl/user/coach/students';
  static String coachStudentDetails(String studentId) =>
      '$apiUrl/user/coach/students/$studentId';

  // Reviews / shares
  static const String shareCreate = '$apiUrl/share-swing/create';
  static const String shareSent = '$apiUrl/share-swing/sent';
  static const String shareReceived = '$apiUrl/share-swing/received';
  static const String sharePending = '$apiUrl/share-swing/pending';
  static String shareView(String id) => '$apiUrl/share-swing/view/$id';
  static String shareFind(String id) => '$apiUrl/share-swing/find/$id';
  static String shareSingle(String id) => '$apiUrl/share-swing/single/$id';
  static String shareRespond(String id) => '$apiUrl/share-swing/respond/$id';
  static String shareSendQueued(String id) =>
      '$apiUrl/share-swing/send-queued/$id';
  static String updateSharePracticePlan(String id) =>
      '$apiUrl/share-swing/$id/practice-plan';
  // Legacy index-based complete (kept for fallback)
  static String completeCoachPracticeSession(String id, int sessionIndex) =>
      '$apiUrl/share-swing/practice-plan/$id/session/$sessionIndex/complete';

  // Notifications
  static const String notifications = '$apiUrl/notification/get-all';



}
