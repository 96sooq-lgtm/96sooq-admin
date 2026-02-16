import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/category/model/category_model.dart';
import 'package:dio/dio.dart';

class CategoryServices {
  final Dio dio;

  CategoryServices(this.dio);

  /// GET CATEGORIES
  Future<List<CategoryModel>> fetchCategories({
    int skip = 0,
    int limit = 3,
  }) async {
    final response = await dio.get(
      ApiEndpoints.showAllCategory,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final data = _extractCategoryList(response.data);
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  /// CREATE CATEGORY
  Future<void> createCategory(CategoryModel category) async {
    await dio.post(ApiEndpoints.addCategory, data: category.toCreateJson());
  }

  /// UPDATE CATEGORY
  Future<void> updateCategory(String id, CategoryModel category) async {
    await dio.put(ApiEndpoints.updateCategory(id), data: category.toCreateJson());
  }

  /// DELETE CATEGORY
  Future<void> deleteCategory(String id) async {
    await dio.delete(ApiEndpoints.deleteCategory(id));
  }

  List<dynamic> _extractCategoryList(dynamic body) {
    if (body is List) {
      return body;
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final categories = data['categories'];
        if (categories is List) {
          return categories;
        }
      }

      final categories = body['categories'];
      if (categories is List) {
        return categories;
      }
    }

    throw Exception('Unexpected categories response format');
  }
}
