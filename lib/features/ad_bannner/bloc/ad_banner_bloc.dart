import 'package:_96sooq_admin/features/ad_bannner/bloc/ad_banner_event.dart';
import 'package:_96sooq_admin/features/ad_bannner/bloc/ad_banner_state.dart';
import 'package:_96sooq_admin/features/ad_bannner/model/ad_banner_model.dart';
import 'package:_96sooq_admin/features/ad_bannner/services/ad_banner_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdBannerBloc extends Bloc<AdBannerEvent, AdBannerState> {
  final AdBannerService service;

  AdBannerBloc(this.service) : super(AdBannerInitial()) {
    on<LoadBanners>(_loadBanners);
    on<CreateBanner>(_createBanner);
    on<UpdateBanner>(_updateBanner);
    on<DeleteBanner>(_deleteBanner);
  }

  Future<void> _loadBanners(
    LoadBanners event,
    Emitter<AdBannerState> emit,
  ) async {
    final previous = _extractExistingBanners(state);
    emit(AdBannerLoading());
    try {
      final banners = await service.fetchAllBanners();
      emit(AdBannerLoaded(banners));
    } catch (e) {
      emit(AdBannerError(e.toString(), banners: previous));
    }
  }

  Future<void> _createBanner(
    CreateBanner event,
    Emitter<AdBannerState> emit,
  ) async {
    await _runMutation(
      emit: emit,
      action: 'create',
      mutate: () => service.createBanner(event.banner),
    );
  }

  Future<void> _updateBanner(
    UpdateBanner event,
    Emitter<AdBannerState> emit,
  ) async {
    await _runMutation(
      emit: emit,
      action: 'update',
      mutate: () => service.updateBanner(event.id, event.banner),
    );
  }

  Future<void> _deleteBanner(
    DeleteBanner event,
    Emitter<AdBannerState> emit,
  ) async {
    await _runMutation(
      emit: emit,
      action: 'delete',
      mutate: () => service.deleteBanner(event.id),
    );
  }

  List<AdBannerModel> _extractExistingBanners(AdBannerState current) {
    if (current is AdBannerLoaded) return current.banners;
    if (current is AdBannerMutating) return current.banners;
    if (current is AdBannerError) return current.banners;
    return const [];
  }

  Future<void> _runMutation({
    required Emitter<AdBannerState> emit,
    required String action,
    required Future<void> Function() mutate,
  }) async {
    final previous = _extractExistingBanners(state);
    if (previous.isNotEmpty) {
      emit(AdBannerMutating(previous, action: action));
    } else {
      emit(AdBannerLoading());
    }

    try {
      await mutate();
      final banners = await service.fetchAllBanners();
      emit(AdBannerLoaded(banners));
    } catch (e) {
      emit(AdBannerError(e.toString(), banners: previous));
    }
  }
}
