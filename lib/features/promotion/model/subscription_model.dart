import 'package:_96sooq_admin/constants/enums/subsciption_enums.dart';

class SubscriptionModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final SubscriptionType type;
  final double price;
  final int durationDays;
  final String description;
  final Map<String, dynamic>? features;
  final bool isActive;
  final DateTime? createdAt;

  SubscriptionModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.type,
    required this.price,
    required this.durationDays,
    required this.description,
    required this.features,
    required this.isActive,
    required this.createdAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      type: _parseType(json['type']),
      price: (json['price'] ?? 0).toDouble(),
      durationDays: json['duration_days'] ?? 0,
      description: json['description'] ?? '',
      features: json['features'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['features'])
          : null,
      isActive: json['is_active'] ?? false,
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      "name_en": nameEn,
      "name_ar": nameAr,
      "type": type.apiValue,
      "price": price,
      "duration_days": durationDays,
      "description": description,
      "is_active": isActive,
      if (features != null) "features": features,
    };
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

SubscriptionType _parseType(dynamic value) {
  final type = value?.toString().toLowerCase();
  switch (type) {
    case 'listing':
      return SubscriptionType.productListing;
    case 'ad':
    case 'advertisement':
      return SubscriptionType.advertisement;
    default:
      return SubscriptionType.productListing;
  }
}
