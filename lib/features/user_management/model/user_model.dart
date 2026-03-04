class UserModel {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final bool isActive;
  final bool isStore;

  UserModel({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    required this.isActive,
    required this.isStore,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      phoneNumber: json['phone_number'],
      email: json['email'],
      isActive: json['is_active'] ?? false,
      isStore: json['is_store'] ?? false,
    );
  }
}

class UserListResponse {
  final List<UserModel> users;
  final int total;
  final int page;
  final int limit;
  final int pages;

  UserListResponse({
    required this.users,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      users:
          (json['users'] as List?)
              ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
}
