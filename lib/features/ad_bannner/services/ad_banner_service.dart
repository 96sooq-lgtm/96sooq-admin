import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/ad_bannner/model/ad_banner_model.dart';
import 'package:dio/dio.dart';

class AdBannerService {
  final Dio dio;

  AdBannerService(this.dio);

  Future<List<AdBannerModel>> fetchAllBanners() async {
    final response = await dio.get(ApiEndpoints.getAllBanners);
    final list = _extractBannerList(response.data);
    return list.map((e) => AdBannerModel.fromJson(e)).toList();
  }

  Future<void> createBanner(AdBannerModel model) async {
    await dio.post(ApiEndpoints.createBanner, data: model.toCreateJson());
  }

  Future<void> updateBanner(String id, AdBannerModel model) async {
    await dio.patch(ApiEndpoints.updateBanner(id), data: model.toUpdateJson());
  }

  Future<void> deleteBanner(String id) async {
    await dio.delete(ApiEndpoints.deleteBanner(id));
  }

  List<Map<String, dynamic>> _extractBannerList(dynamic body) {
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }

      if (data is Map<String, dynamic>) {
        final banners = data['banners'];
        if (banners is List) {
          return banners.whereType<Map<String, dynamic>>().toList();
        }
      }

      final banners = body['banners'];
      if (banners is List) {
        return banners.whereType<Map<String, dynamic>>().toList();
      }
    }

    throw Exception('Unexpected banners response format');
  }
}
