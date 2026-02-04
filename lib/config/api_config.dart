class ApiConfig {
  // เปลี่ยน baseUrl ตาม environment
  // สำหรับ Android Emulator ใช้ 10.0.2.2
  // สำหรับ iOS Simulator ใช้ localhost
  // สำหรับ Physical Device ใช้ IP ของเครื่อง server
  
  static const String baseUrl = 'http://10.0.2.2/REPAIR_API';
  // static const String baseUrl = 'http://localhost/REPAIR_API';
  // static const String baseUrl = 'http://192.168.1.xxx/REPAIR_API';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login.php';
  static const String register = '$baseUrl/auth/register_customer.php';
  static const String forgotPassword = '$baseUrl/auth/forgot_password.php';
  static const String resetPassword = '$baseUrl/auth/reset_password.php';
  static const String getProfile = '$baseUrl/auth/get_user_profile.php';
  static const String updateProfile = '$baseUrl/auth/update_profile.php';
  static const String checkCurrentJob = '$baseUrl/auth/check_current_job.php';
  
  // Customer endpoints
  static const String getServices = '$baseUrl/customer/get_services.php';
  static const String submitRequest = '$baseUrl/customer/submit_request.php';
  static const String getRequestStatus = '$baseUrl/customer/get_request_status.php';
  static const String cancelRequest = '$baseUrl/customer/cancel_request.php';
  static const String getServiceHistory = '$baseUrl/customer/get_service_history.php';
  static const String submitReview = '$baseUrl/customer/submit_review.php';
  static const String nearbyTechnicians = '$baseUrl/customer/nearby_technicians.php';
  static const String uploadImage = '$baseUrl/customer/upload_image.php';
  static const String notifications = '$baseUrl/customer/notifications.php';
  static const String updateLocation = '$baseUrl/customer/update_location.php';
  static const String getPriceEstimate = '$baseUrl/customer/get_price_estimate.php';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
