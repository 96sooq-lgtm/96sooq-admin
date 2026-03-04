import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/user_management/model/user_detail_model.dart';
import 'package:_96sooq_admin/features/user_management/model/user_model.dart';
import 'package:dio/dio.dart';

class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<UserListResponse> fetchUsers({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getUsers(page: page, limit: limit),
      );

      if (response.statusCode == 200) {
        return UserListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error details: $e');
    }
  }

  Future<UserDetailModel> fetchUserDetails(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.getUserDetails(id));

      if (response.statusCode == 200) {
        return UserDetailModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load user details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error details: $e');
    }
  }
}
