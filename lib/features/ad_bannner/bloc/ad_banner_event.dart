import 'package:_96sooq_admin/features/ad_bannner/model/ad_banner_model.dart';

abstract class AdBannerEvent {}

class LoadBanners extends AdBannerEvent {}

class CreateBanner extends AdBannerEvent {
  final AdBannerModel banner;

  CreateBanner(this.banner);
}

class UpdateBanner extends AdBannerEvent {
  final String id;
  final AdBannerModel banner;

  UpdateBanner({required this.id, required this.banner});
}

class DeleteBanner extends AdBannerEvent {
  final String id;

  DeleteBanner(this.id);
}
