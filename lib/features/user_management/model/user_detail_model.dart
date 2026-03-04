class UserDetailModel {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final bool isActive;
  final String? provider;
  final String? profilePicture;
  final String? createdAt;
  final String? updatedAt;
  final bool isStore;
  final StoreDetailsModel? storeDetails;
  final UserStatsModel? stats;

  UserDetailModel({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    required this.isActive,
    this.provider,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
    required this.isStore,
    this.storeDetails,
    this.stats,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      phoneNumber: json['phone_number'],
      email: json['email'],
      isActive: json['is_active'] ?? false,
      provider: json['provider'],
      profilePicture: json['profile_picture'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isStore: json['is_store'] ?? false,
      storeDetails: json['store_details'] != null
          ? StoreDetailsModel.fromJson(json['store_details'])
          : null,
      stats: json['stats'] != null
          ? UserStatsModel.fromJson(json['stats'])
          : null,
    );
  }
}

class StoreDetailsModel {
  final String id;
  final String name;
  final String status;
  final String? planId;
  final String? createdAt;

  StoreDetailsModel({
    required this.id,
    required this.name,
    required this.status,
    this.planId,
    this.createdAt,
  });

  factory StoreDetailsModel.fromJson(Map<String, dynamic> json) {
    return StoreDetailsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'pending',
      planId: json['plan_id'],
      createdAt: json['created_at'],
    );
  }
}

class UserStatsModel {
  final int totalListings;
  final int totalTransactions;
  final double totalSpend;

  UserStatsModel({
    required this.totalListings,
    required this.totalTransactions,
    required this.totalSpend,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalListings: json['total_listings'] ?? 0,
      totalTransactions: json['total_transactions'] ?? 0,
      totalSpend: (json['total_spend'] ?? 0.0).toDouble(),
    );
  }
}
