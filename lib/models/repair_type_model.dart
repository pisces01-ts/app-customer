class RepairTypeModel {
  final int id;
  final String name;
  final String? description;
  final double basePrice;
  final String? icon;

  RepairTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.basePrice = 0,
    this.icon,
  });

  factory RepairTypeModel.fromJson(Map<String, dynamic> json) {
    return RepairTypeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? json['type_name'] ?? '',
      description: json['description'],
      basePrice: json['base_price'] != null 
          ? (json['base_price'] is double 
              ? json['base_price'] 
              : double.tryParse(json['base_price'].toString()) ?? 0)
          : 0,
      icon: json['icon'],
    );
  }
}
