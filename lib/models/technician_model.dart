class TechnicianModel {
  final int userId;
  final String fullname;
  final String phone;
  final String expertise;
  final String vehiclePlate;
  final String vehicleModel;
  final double currentLat;
  final double currentLng;
  final double distance;
  final double avgRating;
  final int completedJobs;
  final String? profileImage;

  TechnicianModel({
    required this.userId,
    required this.fullname,
    required this.phone,
    this.expertise = '',
    this.vehiclePlate = '',
    this.vehicleModel = '',
    this.currentLat = 0,
    this.currentLng = 0,
    this.distance = 0,
    this.avgRating = 0,
    this.completedJobs = 0,
    this.profileImage,
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      fullname: json['fullname'] ?? '',
      phone: json['phone'] ?? '',
      expertise: json['expertise'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      vehicleModel: json['vehicle_model'] ?? '',
      currentLat: _parseDouble(json['current_lat']),
      currentLng: _parseDouble(json['current_lng']),
      distance: _parseDouble(json['distance']),
      avgRating: _parseDouble(json['avg_rating']),
      completedJobs: json['completed_jobs'] is int 
          ? json['completed_jobs'] 
          : int.tryParse(json['completed_jobs'].toString()) ?? 0,
      profileImage: json['profile_image'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  List<String> get expertiseList => expertise.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}
