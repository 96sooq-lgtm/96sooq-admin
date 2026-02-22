import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';

enum AttributeType { radio, dropdown, textField }

class AttributeUiItem {
  final String key;
  final String nameEn;
  final String nameAr;
  final AttributeType type;
  final List<String> options;
  final bool isActive;

  const AttributeUiItem({
    required this.key,
    required this.nameEn,
    required this.nameAr,
    required this.type,
    required this.options,
    required this.isActive,
  });

  AttributeUiItem copyWith({
    String? key,
    String? nameEn,
    String? nameAr,
    AttributeType? type,
    List<String>? options,
    bool? isActive,
  }) {
    return AttributeUiItem(
      key: key ?? this.key,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      type: type ?? this.type,
      options: options ?? this.options,
      isActive: isActive ?? this.isActive,
    );
  }

  String get typeLabel {
    switch (type) {
      case AttributeType.radio:
        return 'Radio button';
      case AttributeType.dropdown:
        return 'Dropdown';
      case AttributeType.textField:
        return 'Text field';
    }
  }

  static AttributeUiItem fromSchema(SubcategoryAttributeSchema schema) {
    return AttributeUiItem(
      key: schema.key,
      nameEn: schema.labelEn.isNotEmpty ? schema.labelEn : schema.key,
      nameAr: schema.labelAr,
      type: _fromTypeString(schema.type),
      options: schema.options ?? const <String>[],
      isActive: true,
    );
  }

  static AttributeType _fromTypeString(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('radio')) {
      return AttributeType.radio;
    }
    if (normalized.contains('drop') || normalized.contains('select')) {
      return AttributeType.dropdown;
    }
    return AttributeType.textField;
  }
}
