import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/payments/model/transaction_model.dart';
import 'package:dio/dio.dart';

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  Future<TransactionListResponse> fetchTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getTransactions(page: page, limit: limit),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TransactionListResponse.fromJson(response.data);
      } else {
        throw Exception("Failed to load transactions.");
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw Exception(
          e.response!.data['message'] ?? 'Failed to load transactions',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<TransactionDetailsModel> fetchTransactionDetails(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.getTransactionDetails(id));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TransactionDetailsModel.fromJson(response.data);
      } else {
        throw Exception("Failed to load transaction details.");
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw Exception(
          e.response!.data['message'] ?? 'Failed to load transaction details',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
