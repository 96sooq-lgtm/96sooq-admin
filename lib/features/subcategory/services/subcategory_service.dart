import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';
import 'package:dio/dio.dart';

class SubcategoryService {
  final Dio dio;

  SubcategoryService(this.dio);

  Future<List<SubcategoryModel>> fetchAllSubcategories() async {
    final response = await dio.get(ApiEndpoints.getAllSubcategories);
    final data = response.data;
    if (data is List) {
      return data.map((e) => SubcategoryModel.fromJson(e)).toList();
    }
    throw Exception('Unexpected subcategories response format');
  }

  Future<void> createSubcategory(SubcategoryModel model) async {
    await dio.post(
      ApiEndpoints.addCategory,
      data: model.toCreateJson(),
    );
  }

  Future<void> updateSubcategory(String id, SubcategoryModel model) async {
    await dio.put(
      ApiEndpoints.updateCategory(id),
      data: model.toCreateJson(),
    );
  }

  Future<void> deleteSubcategory(String id) async {
    await dio.delete(ApiEndpoints.deleteCategory(id));
  }
}
