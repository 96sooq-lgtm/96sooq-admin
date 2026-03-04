import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/stores/model/store_model.dart';
import 'package:dio/dio.dart';

class StoreService {
  final Dio dio;

  StoreService(this.dio);

  Future<List<StoreModel>> fetchStores({int skip = 0, int limit = 10}) async {
    final response = await dio.get(
      ApiEndpoints.getStores,
      queryParameters: {'skip': skip, 'limit': limit},
    );

    final data = _extractStoreList(response.data);
    return data.map((e) => StoreModel.fromJson(e)).toList();
  }

  Future<void> lockStore(String id) async {
    await dio.put(ApiEndpoints.lockStore(id));
  }

  Future<void> unlockStore(String id) async {
    await dio.put(ApiEndpoints.unlockStore(id));
  }

  List<dynamic> _extractStoreList(dynamic body) {
    if (body is List) {
      return body;
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final stores = data['stores'] ?? data['items'] ?? data['data'];
        if (stores is List) {
          return stores;
        }
      }

      final stores = body['stores'] ?? body['items'] ?? body['data'];
      if (stores is List) {
        return stores;
      }
    }

    return [];
  }
}
