import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Use localhost for web, 10.0.2.2 for Android emulator
  static String get baseUrl => kIsWeb ? 'http://localhost/REPAIR_API' : 'http://10.0.2.2/REPAIR_API';
  
  // Auth endpoints
  static String get login => '$baseUrl/customer/login.php';
  static String get register => '$baseUrl/customer/register.php';
  static String get forgotPassword => '$baseUrl/customer/forgot_password.php';
  static String get resetPassword => '$baseUrl/customer/reset_password.php';
  static String get getProfile => '$baseUrl/customer/get_profile.php';
  static String get updateProfile => '$baseUrl/customer/update_profile.php';
  static String get checkCurrentJob => '$baseUrl/customer/check_current_job.php';
  
  // Customer endpoints
  static String get getServices => '$baseUrl/customer/get_repair_types.php';
  static String get submitRequest => '$baseUrl/customer/submit_request.php';
  static String get getRequests => '$baseUrl/customer/get_requests.php';
  static String get cancelRequest => '$baseUrl/customer/cancel_request.php';
  static String get getServiceHistory => '$baseUrl/customer/get_requests.php';
  static String get submitReview => '$baseUrl/customer/submit_review.php';
  static String get findNearbyTechnicians => '$baseUrl/customer/find_nearby_technicians.php';
  static String get getTechnicianProfile => '$baseUrl/customer/get_technician_profile.php';
  static String get selectTechnician => '$baseUrl/customer/select_technician.php';
  static String get uploadImage => '$baseUrl/customer/upload_image.php';
  static String get notifications => '$baseUrl/customer/notifications.php';
  static String get updateLocation => '$baseUrl/customer/update_location.php';
  
  // Chat endpoints
  static String get sendMessage => '$baseUrl/chat/send_message.php';
  static String get getMessages => '$baseUrl/chat/get_messages.php';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
