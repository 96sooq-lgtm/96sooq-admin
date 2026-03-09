class ApiEndpoints {
  static const String baseUrl = "https://nine6sooq-backend-1.onrender.com";

  static const String login = "$baseUrl/api/admin/login";
  static const String addCategory = "$baseUrl/api/admin/categories/";
  static const String showAllCategory = "$baseUrl/api/admin/categories/list";
  static const String uploadToS3 = "$baseUrl/storage/upload";
  static String deleteCategory(String id) =>
      "$baseUrl/api/admin/categories/$id";
  static String updateCategory(String id) =>
      "$baseUrl/api/admin/categories/$id";
  static const String createSubscription = "$baseUrl/api/admin/subscriptions/";
  static const String getAllSubscriptions = "$baseUrl/api/admin/subscriptions/";
  static const String createBanner = "$baseUrl/api/admin/banners/";
  static const String getAllBanners = "$baseUrl/api/admin/banners/";
  static String updateBanner(String id) => "$baseUrl/api/admin/banners/$id";
  static String deleteBanner(String id) => "$baseUrl/api/admin/banners/$id";
  static String updateSubscription(String id) =>
      "$baseUrl/api/admin/subscriptions/$id";
  static String deleteSubscription(String id) =>
      "$baseUrl/api/admin/subscriptions/$id";
  static const String getAllSubcategories =
      "$baseUrl/api/admin/categories/subcategories/";
  static String deleteSubcategoryAttribute(String id, String attributeName) =>
      "$baseUrl/api/admin/categories/$id/attributes/$attributeName";
  static String createSubcategoryAttribute(String id) =>
      "$baseUrl/api/admin/categories/$id/attributes";
  static String updateSubcategoryAttribute(String id, String attributeName) =>
      "$baseUrl/api/admin/categories/$id/attributes/$attributeName";
  static String editCategoryAttributes(String id) =>
      "$baseUrl/api/admin/categories/$id/attributes";
  static const String getDashboard = "$baseUrl/api/admin/dashboard";
  static const String getStores = "$baseUrl/api/admin/stores/";
  static String lockStore(String id) => "$baseUrl/api/admin/stores/$id/lock";
  static String unlockStore(String id) =>
      "$baseUrl/api/admin/stores/$id/unlock";
  static String getListings(String status, {int skip = 0, int limit = 10}) =>
      "$baseUrl/api/admin/listings/?status=$status&skip=$skip&limit=$limit";
  static String approveListing(String id) =>
      "$baseUrl/api/admin/listings/$id/approve";
  static String rejectListing(String id, String reason) =>
      "$baseUrl/api/admin/listings/$id/reject?reason=$reason";
  static String getUsers({int page = 1, int limit = 20}) =>
      "$baseUrl/api/admin/users/?page=$page&limit=$limit";
  static String getUserDetails(String id) => "$baseUrl/api/admin/users/$id";
  static String getTransactions({int page = 1, int limit = 20}) =>
      "$baseUrl/api/admin/payments/transactions?page=$page&limit=$limit";
  static String getTransactionDetails(String id) =>
      "$baseUrl/api/admin/payments/transactions/$id";
}
