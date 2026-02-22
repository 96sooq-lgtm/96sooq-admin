import 'package:_96sooq_admin/features/ad_bannner/model/ad_banner_model.dart';

abstract class AdBannerState {}

class AdBannerInitial extends AdBannerState {}

class AdBannerLoading extends AdBannerState {}

class AdBannerLoaded extends AdBannerState {
  final List<AdBannerModel> banners;

  AdBannerLoaded(this.banners);
}

class AdBannerMutating extends AdBannerState {
  final List<AdBannerModel> banners;
  final String action;

  AdBannerMutating(this.banners, {required this.action});
}

class AdBannerError extends AdBannerState {
  final String message;
  final List<AdBannerModel> banners;

  AdBannerError(this.message, {this.banners = const []});
}
