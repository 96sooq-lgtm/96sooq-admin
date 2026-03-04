import 'package:_96sooq_admin/constants/enums/subsciption_enums.dart';

class SubscriptionModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final SubscriptionType type;
  final double price;
  final int durationDays;
  final int quota;
  final String description;
  final Map<String, dynamic>? features;
  final String? targetAudience;
  final String? adSubType;
  final bool isActive;
  final bool isBestValue;
  final DateTime? createdAt;

  SubscriptionModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.type,
    required this.price,
    required this.durationDays,
    required this.quota,
    required this.description,
    required this.features,
    required this.targetAudience,
    this.adSubType,
    required this.isActive,
    required this.isBestValue,
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
      quota: _parseInt(json['quota'], fallback: 0),
      description: json['description'] ?? '',
      features: json['features'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['features'])
          : null,
      targetAudience: json['target_audience']?.toString(),
      adSubType: json['ad_sub_type']?.toString(),
      isActive: json['is_active'] ?? false,
      isBestValue: json['is_best_value'] ?? json['isBestValue'] ?? false,
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
      "quota": quota,
      "description": description,
      "is_active": isActive,
      "isBestValue": isBestValue,
      if (targetAudience != null && targetAudience!.isNotEmpty)
        "target_audience": targetAudience,
      if (type == SubscriptionType.advertisement &&
          adSubType != null &&
          adSubType!.isNotEmpty)
        "ad_sub_type": adSubType,
      if (features != null) "features": features,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "name_en": nameEn,
      "name_ar": nameAr,
      "type": type.apiValue,
      "price": price,
      "duration_days": durationDays,
      "quota": quota,
      "description": description,
      "is_active": isActive,
      "is_best_value": isBestValue,
      if (targetAudience != null && targetAudience!.isNotEmpty)
        "target_audience": targetAudience,
      if (type == SubscriptionType.advertisement &&
          adSubType != null &&
          adSubType!.isNotEmpty)
        "ad_sub_type": adSubType,
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

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
