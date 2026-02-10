import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final token = response.data['access_token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('Invalid token received');
      }

      return token;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw 'Invalid email or password';
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}
