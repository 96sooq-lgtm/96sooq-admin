import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/promotion/model/subscription_model.dart';
import 'package:dio/dio.dart';

class SubscriptionService {
  final Dio dio;

  SubscriptionService(this.dio);

  Future<List<SubscriptionModel>> fetchAll() async {
    final response = await dio.get(ApiEndpoints.getAllSubscriptions);
    final data = response.data;
    if (data is List) {
      return data.map((e) => SubscriptionModel.fromJson(e)).toList();
    }
    throw Exception('Unexpected subscriptions response format');
  }

  Future<SubscriptionModel> create(SubscriptionModel input) async {
    final response = await dio.post(
      ApiEndpoints.createSubscription,
      data: input.toCreateJson(),
    );
    if (response.data is Map<String, dynamic>) {
      return SubscriptionModel.fromJson(response.data);
    }
    throw Exception('Unexpected subscription create response format');
  }

  Future<void> delete(String id) async {
    await dio.delete(ApiEndpoints.deleteSubscription(id));
  }
}
