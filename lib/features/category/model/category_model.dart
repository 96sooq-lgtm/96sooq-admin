class CategoryModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String imageUrl;
  final String? parentId;
  final List<CategoryAttribute> attributesSchema;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.imageUrl,
    required this.parentId,
    required this.attributesSchema,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes_schema'];
    return CategoryModel(
      id: json['id'] ?? json['_id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      imageUrl: json['image_url'] ?? '',
      parentId: json['parent_id'],
      attributesSchema: attributes is List
          ? attributes
              .map((e) => CategoryAttribute.fromJson(e))
              .toList()
          : const [],
      isActive: json['is_active'] ?? false,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name_en": nameEn,
      "name_ar": nameAr,
      "image_url": imageUrl,
      "parent_id": parentId,
      "attributes_schema": attributesSchema.map((e) => e.toJson()).toList(),
      "is_active": isActive,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      "name_en": nameEn,
      "name_ar": nameAr,
      "image_url": imageUrl,
      "is_active": isActive,
    };
  }
}

class CategoryAttribute {
  final String name;
  final String type;
  final String labelAr;
  final String labelEn;
  final bool required;
  final String? accept;

  CategoryAttribute({
    required this.name,
    required this.type,
    required this.labelAr,
    required this.labelEn,
    required this.required,
    required this.accept,
  });

  factory CategoryAttribute.fromJson(Map<String, dynamic> json) {
    return CategoryAttribute(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      labelAr: json['label_ar'] ?? '',
      labelEn: json['label_en'] ?? '',
      required: json['required'] ?? false,
      accept: json['accept'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
      "label_ar": labelAr,
      "label_en": labelEn,
      "required": required,
      "accept": accept,
    };
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
