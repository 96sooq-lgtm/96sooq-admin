import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';
import 'package:dio/dio.dart';

class SubcategoryService {
  final Dio dio;

  SubcategoryService(this.dio);

  Future<List<SubcategoryModel>> fetchAllSubcategories({
    int skip = 0,
    int limit = 10,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getAllSubcategories,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => SubcategoryModel.fromJson(e)).toList();
    }
    if (data is Map<String, dynamic>) {
      final raw = data['data'];
      if (raw is List) {
        return raw.map((e) => SubcategoryModel.fromJson(e)).toList();
      }
      final nested = data['subcategories'];
      if (nested is List) {
        return nested.map((e) => SubcategoryModel.fromJson(e)).toList();
      }
    }
    throw Exception('Unexpected subcategories response format');
  }

  Future<void> createSubcategory(SubcategoryModel model) async {
    await dio.post(ApiEndpoints.addCategory, data: model.toCreateJson());
  }

  Future<void> updateSubcategory(String id, SubcategoryModel model) async {
    await dio.put(ApiEndpoints.updateCategory(id), data: model.toCreateJson());
  }

  Future<void> deleteSubcategory(String id) async {
    await dio.delete(ApiEndpoints.deleteCategory(id));
  }

  Future<void> deleteAttribute(
    String subcategoryId,
    String attributeName,
  ) async {
    await dio.delete(
      ApiEndpoints.deleteSubcategoryAttribute(subcategoryId, attributeName),
    );
  }

  Future<void> createAttribute(
    String subcategoryId,
    Map<String, dynamic> payload,
  ) async {
    await dio.post(
      ApiEndpoints.createSubcategoryAttribute(subcategoryId),
      data: payload,
    );
  }

  Future<void> updateAttribute(
    String subcategoryId,
    String attributeName,
    Map<String, dynamic> payload,
  ) async {
    await dio.patch(
      ApiEndpoints.updateSubcategoryAttribute(subcategoryId, attributeName),
      data: payload,
    );
  }

  Future<void> editAttributes(
    String subcategoryId,
    List<Map<String, dynamic>> attributes,
  ) async {
    await dio.patch(
      ApiEndpoints.editCategoryAttributes(subcategoryId),
      data: attributes,
    );
  }
}
