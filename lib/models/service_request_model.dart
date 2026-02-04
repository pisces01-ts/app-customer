class ServiceRequestModel {
  final int requestId;
  final int customerId;
  final int? technicianId;
  final String problemType;
  final String problemDetails;
  final String? problemImage;
  final double locationLat;
  final double locationLng;
  final String status;
  final double price;
  final String? requestTime;
  final String? completedTime;
  
  // Technician info
  final String? techName;
  final String? techPhone;
  final String? vehiclePlate;
  final String? vehicleModel;
  final double? techLat;
  final double? techLng;

  ServiceRequestModel({
    required this.requestId,
    required this.customerId,
    this.technicianId,
    required this.problemType,
    this.problemDetails = '',
    this.problemImage,
    required this.locationLat,
    required this.locationLng,
    required this.status,
    this.price = 0,
    this.requestTime,
    this.completedTime,
    this.techName,
    this.techPhone,
    this.vehiclePlate,
    this.vehicleModel,
    this.techLat,
    this.techLng,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      requestId: _parseInt(json['request_id']),
      customerId: _parseInt(json['customer_id']),
      technicianId: json['technician_id'] != null ? _parseInt(json['technician_id']) : null,
      problemType: json['problem_type'] ?? '',
      problemDetails: json['problem_details'] ?? '',
      problemImage: json['problem_image'],
      locationLat: _parseDouble(json['location_lat'] ?? json['cust_lat']),
      locationLng: _parseDouble(json['location_lng'] ?? json['cust_lng']),
      status: json['status'] ?? 'pending',
      price: _parseDouble(json['price']),
      requestTime: json['request_time'],
      completedTime: json['completed_time'],
      techName: json['tech_name'],
      techPhone: json['tech_phone'],
      vehiclePlate: json['vehicle_plate'],
      vehicleModel: json['vehicle_model'],
      techLat: json['tech_lat'] != null ? _parseDouble(json['tech_lat']) : null,
      techLng: json['tech_lng'] != null ? _parseDouble(json['tech_lng']) : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  bool get hasTechnician => technicianId != null && technicianId! > 0;
  
  bool get canCancel => status == 'pending';
  
  bool get isActive => ['pending', 'accepted', 'traveling', 'working'].contains(status);
  
  bool get isCompleted => status == 'completed';
  
  bool get isCancelled => status == 'cancelled';
}
