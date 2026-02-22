class ApiEndpoints {
  static const String baseUrl = "https://nine6sooq-backend.onrender.com";

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
}
