class UserModel {
  final int userId;
  final String fullname;
  final String phone;
  final String email;
  final String address;
  final String role;
  final String status;
  final String? profileImage;

  UserModel({
    required this.userId,
    required this.fullname,
    required this.phone,
    this.email = '',
    this.address = '',
    this.role = 'customer',
    this.status = 'active',
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      fullname: json['fullname'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'customer',
      status: json['status'] ?? 'active',
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fullname': fullname,
      'phone': phone,
      'email': email,
      'address': address,
      'role': role,
      'status': status,
      'profile_image': profileImage,
    };
  }

  UserModel copyWith({
    int? userId,
    String? fullname,
    String? phone,
    String? email,
    String? address,
    String? role,
    String? status,
    String? profileImage,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullname: fullname ?? this.fullname,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
