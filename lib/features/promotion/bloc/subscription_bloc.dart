import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:_96sooq_admin/features/promotion/model/subscription_model.dart';
import 'package:_96sooq_admin/features/promotion/services/subscription_service.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionService service;

  SubscriptionBloc(this.service) : super(SubscriptionInitial()) {
    on<LoadSubscriptions>(_load);
    on<CreateSubscription>(_create);
    on<DeleteSubscription>(_delete);
  }

  Future<void> _load(
    LoadSubscriptions event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final list = await service.fetchAll();
      emit(SubscriptionLoaded(list));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _create(
    CreateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await service.create(event.subscription);
      add(LoadSubscriptions());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _delete(
    DeleteSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await service.delete(event.id);
      add(LoadSubscriptions());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
}
