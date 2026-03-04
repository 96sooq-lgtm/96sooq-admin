class ListingModel {
  final String id;
  final String userId;
  final String? storeId;
  final String categoryId;
  final String title;
  final String description;
  final String condition;
  final String place;
  final double price;
  final String currency;
  final String status;
  final String? rejectionReason;
  final Map<String, dynamic>? attributesValues;
  final String locationId;
  final Map<String, dynamic>? locationDetails;
  final String createdAt;
  final String sellerType;
  final String? userName;
  final String? userProfilePicture;
  final String? storeName;
  final String? storeLogo;
  final List<String> images;
  final String? sellerPhoneNumber;
  final String? categoryNameEn;
  final String? categoryNameAr;
  final String? parentCategoryNameEn;
  final String? parentCategoryNameAr;
  final String? wilayatNameEn;
  final String? wilayatNameAr;

  // Derived location fields from locationDetails
  String? get governorateNameEn =>
      locationDetails?['governorate_name_en'] as String?;
  String? get governorateNameAr =>
      locationDetails?['governorate_name_ar'] as String?;

  ListingModel({
    required this.id,
    required this.userId,
    this.storeId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.condition,
    required this.place,
    required this.price,
    required this.currency,
    required this.status,
    this.rejectionReason,
    this.attributesValues,
    required this.locationId,
    this.locationDetails,
    required this.createdAt,
    required this.sellerType,
    this.userName,
    this.userProfilePicture,
    this.storeName,
    this.storeLogo,
    required this.images,
    this.sellerPhoneNumber,
    this.categoryNameEn,
    this.categoryNameAr,
    this.parentCategoryNameEn,
    this.parentCategoryNameAr,
    this.wilayatNameEn,
    this.wilayatNameAr,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      storeId: json['store_id'] as String?,
      categoryId: json['category_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      place: json['place'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
      status: json['status'] as String? ?? '',
      rejectionReason: json['rejection_reason'] as String?,
      attributesValues: json['attributes_values'] as Map<String, dynamic>?,
      locationId: json['location_id'] as String? ?? '',
      locationDetails: json['location_details'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String? ?? '',
      sellerType: json['seller_type'] as String? ?? '',
      userName: json['user_name'] as String?,
      userProfilePicture: json['user_profile_picture'] as String?,
      storeName: json['store_name'] as String?,
      storeLogo: json['store_logo'] as String?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sellerPhoneNumber: json['seller_phone_number'] as String?,
      categoryNameEn: json['category_name_en'] as String?,
      categoryNameAr: json['category_name_ar'] as String?,
      parentCategoryNameEn: json['parent_category_name_en'] as String?,
      parentCategoryNameAr: json['parent_category_name_ar'] as String?,
      wilayatNameEn: json['wilayat_name_en'] as String?,
      wilayatNameAr: json['wilayat_name_ar'] as String?,
    );
  }
}
