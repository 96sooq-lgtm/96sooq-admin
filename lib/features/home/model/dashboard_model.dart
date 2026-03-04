class DashboardModel {
  final int totalUsers;
  final int totalStores;
  final int totalListings;
  final int pendingRequests;
  final double totalRevenue;
  final int totalTransactions;

  DashboardModel({
    required this.totalUsers,
    required this.totalStores,
    required this.totalListings,
    required this.pendingRequests,
    required this.totalRevenue,
    required this.totalTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalUsers: json['total_users'] ?? 0,
      totalStores: json['total_stores'] ?? 0,
      totalListings: json['total_listings'] ?? 0,
      pendingRequests: json['pending_requests'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_stores': totalStores,
      'total_listings': totalListings,
      'pending_requests': pendingRequests,
      'total_revenue': totalRevenue,
      'total_transactions': totalTransactions,
    };
  }

  DashboardModel copyWith({
    int? totalUsers,
    int? totalStores,
    int? totalListings,
    int? pendingRequests,
    double? totalRevenue,
    int? totalTransactions,
  }) {
    return DashboardModel(
      totalUsers: totalUsers ?? this.totalUsers,
      totalStores: totalStores ?? this.totalStores,
      totalListings: totalListings ?? this.totalListings,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalTransactions: totalTransactions ?? this.totalTransactions,
    );
  }
}
