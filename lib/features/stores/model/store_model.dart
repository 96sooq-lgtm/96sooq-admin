class StoreModel {
  final String id;
  final String name;
  final String nameAr;
  final String logo;
  final bool isLocked;
  final bool isLoading;

  StoreModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logo,
    this.isLocked = false,
    this.isLoading = false,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      logo: json['logo'] ?? '',
      isLocked: json['status'] == 'inactive',
      isLoading: json['isLoading'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'logo': logo,
      'status': isLocked ? 'inactive' : 'active',
      'isLoading': isLoading,
    };
  }

  StoreModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? logo,
    bool? isLocked,
    bool? isLoading,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      logo: logo ?? this.logo,
      isLocked: isLocked ?? this.isLocked,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
