class SubcategoryAttributeSchema {
  final String key;
  final String labelEn;
  final String labelAr;
  final String type;
  final bool required;
  final List<String>? options;

  SubcategoryAttributeSchema({
    required this.key,
    required this.labelEn,
    required this.labelAr,
    required this.type,
    required this.required,
    required this.options,
  });

  factory SubcategoryAttributeSchema.fromJson(Map<String, dynamic> json) {
    return SubcategoryAttributeSchema(
      key: json['key'] ?? '',
      labelEn: json['label_en'] ?? '',
      labelAr: json['label_ar'] ?? '',
      type: json['type'] ?? '',
      required: json['required'] ?? false,
      options: json['options'] is List
          ? List<String>.from(json['options'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "label_en": labelEn,
      "label_ar": labelAr,
      "type": type,
      "required": required,
      if (options != null) "options": options,
    };
  }
}

class SubcategoryModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String parentId;
  final String imageUrl;
  final bool isActive;
  final List<SubcategoryAttributeSchema>? attributesSchema;

  SubcategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.parentId,
    required this.imageUrl,
    required this.isActive,
    required this.attributesSchema,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] ?? json['_id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      parentId: json['parent_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isActive: json['is_active'] ?? false,
      attributesSchema: json['attributes_schema'] is List
          ? (json['attributes_schema'] as List)
              .map((e) => SubcategoryAttributeSchema.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      "name_en": nameEn,
      "name_ar": nameAr,
      "parent_id": parentId,
      "image_url": imageUrl,
      "is_active": isActive,
      if (attributesSchema != null)
        "attributes_schema": attributesSchema!.map((e) => e.toJson()).toList(),
    };
  }
}
