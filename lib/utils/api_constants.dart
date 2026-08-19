class ApiConstants {
  static const String baseUrl = 'https://golf.ssh.bd';
  static const String apiUrl = '$baseUrl/api/v1';

  // SharedPreferences keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyAccessTokenExpiresAt = 'access_token_expires_at';
  static const String keyRefreshTokenExpiresAt = 'refresh_token_expires_at';
  static const String keyUserData = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';

  // Refresh Token
  static const String refreshToken = '$apiUrl/auth/refresh-token';

  // Auth endpoints
  static const String register = '$apiUrl/auth/register';
  static const String verifyOtp = '$apiUrl/auth/verify-otp';
  static const String updateRegisterProfile = '$apiUrl/user/update-my-profile';
  static const String resendOTP = '$apiUrl/auth/resend-otp';
  static const String login = '$apiUrl/auth/login';
  static const String forgotPassword = '$apiUrl/auth/forgot-password';
  static const String forgotPasswordOTPVerify = '$apiUrl/auth/forgot-otp-verify';
  static const String resetPassword = '$apiUrl/auth/reset-password';
  static const String changePassword = '$apiUrl/auth/change-password';

  // Profile
  static const String getMyProfile = '$apiUrl/user/get-my-profile';
  static const String updateProfile = '$apiUrl/users/update-me';
  static const String deleteAccount = '$apiUrl/users/me';
  static const String getSkills = '$apiUrl/users/edit-options';

  //User/Golfer
  static const String home = '$apiUrl/meta/user';


  //Progress
  static const String progress = '$apiUrl/meta/my-progress';
  static const String updateHandicap = '$apiUrl/meta/update-handicap';



  //Library
  static const String allLibrary = '$apiUrl/swing-library/my-library';
  static const String singleLibrary = '$apiUrl/swing-library/find/:id';









  //Coach
  static const String coachHome = '$apiUrl/meta/coach';
  static const String getCoachProfile = '$apiUrl/user/get-my-profile';

  // Students
  static const String coachStudents = '$apiUrl/user/coach/students';
  static String coachStudentDetails(String studentId) =>
      '$apiUrl/user/coach/students/$studentId';

  // Reviews / shares
  static const String shareReceived = '$apiUrl/share-swing/received';
  static const String sharePending = '$apiUrl/share-swing/pending';
  static String shareView(String id) => '$apiUrl/share-swing/view/$id';
  static String shareFind(String id) => '$apiUrl/share-swing/find/$id';
  static String shareRespond(String id) => '$apiUrl/share-swing/respond/$id';



}
