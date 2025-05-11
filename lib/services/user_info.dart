// lib/services/user_info.dart
class UserInfoService {
  static String? userId;
  static String? email;

  // Method to set user info
  static void setUserInfo({required String uid, required String userEmail}) {
    userId = uid;
    email = userEmail;
  }

  // Method to get user ID
  static String? getUserId() {
    return userId;
  }

  // Method to get email
  static String? getEmail() {
    return email;
  }
}
