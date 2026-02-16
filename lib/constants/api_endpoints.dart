class ApiEndpoints {
  static const String baseUrl = "https://nine6sooq-backend.onrender.com";

  static const String login = "$baseUrl/api/admin/login";
  static const String addCategory = "$baseUrl/api/admin/categories/";
  static const String showAllCategory = "$baseUrl/api/admin/categories/list";
  static const String uploadToS3 = "$baseUrl/storage/upload";
  static String deleteCategory(String id) => "$baseUrl/api/admin/categories/$id";
  static String updateCategory(String id) => "$baseUrl/api/admin/categories/$id";
  static const String createSubscription = "$baseUrl/api/admin/subscriptions/";
  static const String getAllSubscriptions = "$baseUrl/api/admin/subscriptions/";
  static String deleteSubscription(String id) =>
      "$baseUrl/api/admin/subscriptions/$id";
  static const String getAllSubcategories =
      "$baseUrl/api/admin/categories/subcategories/";
}
