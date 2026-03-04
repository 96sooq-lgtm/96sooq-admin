import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/request_approval/model/listing_model.dart';
import 'package:dio/dio.dart';

class ListingService {
  final Dio _dio;

  ListingService(this._dio);

  Future<List<ListingModel>> fetchListings({
    required String status,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getListings(status, skip: skip, limit: limit),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ListingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load listings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error details: $e');
    }
  }

  Future<void> approveListing({required String id}) async {
    try {
      final response = await _dio.put(ApiEndpoints.approveListing(id));
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to approve listing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unexpected error details: $e');
    }
  }

  Future<void> rejectListing({
    required String id,
    required String reason,
  }) async {
    try {
      final response = await _dio.put(ApiEndpoints.rejectListing(id, reason));
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to reject listing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unexpected error details: $e');
    }
  }
}
