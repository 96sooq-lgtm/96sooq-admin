import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/home/model/dashboard_model.dart';
import 'package:dio/dio.dart';

class DashboardService {
  final Dio _dio;

  DashboardService(this._dio);

  Future<DashboardModel> fetchDashboardMetrics() async {
    try {
      final response = await _dio.get(ApiEndpoints.getDashboard);

      if (response.statusCode == 200) {
        return DashboardModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load dashboard metrics: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error details: $e');
    }
  }
}
