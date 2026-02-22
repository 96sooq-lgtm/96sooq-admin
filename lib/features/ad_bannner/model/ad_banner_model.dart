class AdBannerModel {
  final String id;
  final String name;
  final String type;
  final int durationDays;
  final String imageUrl;
  final String linkUrl;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdBannerModel({
    required this.id,
    required this.name,
    required this.type,
    required this.durationDays,
    required this.imageUrl,
    required this.linkUrl,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdBannerModel.fromJson(Map<String, dynamic> json) {
    dynamic imgObj = json['image_url'] ?? json['images'];
    String imgStr = '';
    if (imgObj is List) {
      imgStr = imgObj.map((e) => e.toString()).join(',');
    } else {
      imgStr = imgObj?.toString() ?? '';
    }

    return AdBannerModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'carousel',
      durationDays: _parseInt(json['duration_days']),
      imageUrl: imgStr,
      linkUrl: json['link_url'] ?? '',
      description: json['description'] ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    if (type == 'offer' || type == 'offers') {
      return {
        "name": name,
        "type": "offers",
        "duration_days": durationDays,
        "images": imageUrl.isEmpty
            ? []
            : imageUrl.split(',').map((e) => e.trim()).toList(),
        "link_url": linkUrl,
        "description": description,
      };
    } else {
      return {
        "name": name,
        "type": "carousel",
        "duration_days": durationDays,
        "image_url": imageUrl,
        "link_url": linkUrl,
        "description": description,
      };
    }
  }

  Map<String, dynamic> toUpdateJson() {
    if (type == 'offer' || type == 'offers') {
      return {
        "name": name,
        "type": "offers",
        "duration_days": durationDays,
        "images": imageUrl.isEmpty
            ? []
            : imageUrl.split(',').map((e) => e.trim()).toList(),
        "link_url": linkUrl,
        "description": description,
      };
    } else {
      return {
        "name": name,
        "type": "carousel",
        "duration_days": durationDays,
        "image_url": imageUrl,
        "link_url": linkUrl,
        "description": description,
      };
    }
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
