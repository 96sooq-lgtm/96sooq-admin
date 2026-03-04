import 'package:_96sooq_admin/features/stores/bloc/store_event.dart';
import 'package:_96sooq_admin/features/stores/bloc/store_state.dart';
import 'package:_96sooq_admin/features/stores/services/store_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreService storeService;

  StoreBloc(this.storeService) : super(StoreInitial()) {
    on<LoadStores>(_onLoadStores);
    on<LoadMoreStores>(_onLoadMoreStores);
    on<ToggleStoreStatus>(_onToggleStoreStatus);
  }

  int _skip = 0;
  final int _limit = 10;
  bool _isFetching = false;

  Future<void> _onToggleStoreStatus(
    ToggleStoreStatus event,
    Emitter<StoreState> emit,
  ) async {
    final currentState = state;
    if (currentState is StoreLoaded) {
      try {
        // Optimistically set isLoading to true
        final loadingStores = currentState.stores.map((store) {
          if (store.id == event.store.id) {
            return store.copyWith(isLoading: true);
          }
          return store;
        }).toList();
        emit(currentState.copyWith(stores: loadingStores));

        // Perform the API call
        if (event.isLocking) {
          await storeService.lockStore(event.store.id);
        } else {
          await storeService.unlockStore(event.store.id);
        }

        // Apply correct isLocked status and remove isLoading
        final updatedStores = loadingStores.map((store) {
          if (store.id == event.store.id) {
            return store.copyWith(isLocked: event.isLocking, isLoading: false);
          }
          return store;
        }).toList();

        emit(currentState.copyWith(stores: updatedStores));
      } catch (e) {
        // Ensure isLoading is removed on error
        final errorStores = currentState.stores.map((store) {
          if (store.id == event.store.id) {
            return store.copyWith(isLoading: false);
          }
          return store;
        }).toList();
        emit(currentState.copyWith(stores: errorStores));
      }
    }
  }

  Future<void> _onLoadStores(LoadStores event, Emitter<StoreState> emit) async {
    if (event.isRefresh) {
      _skip = 0;
      _isFetching = false;
      emit(StoreLoading());
    } else {
      emit(StoreLoading());
      _skip = 0;
    }

    try {
      final stores = await storeService.fetchStores(skip: _skip, limit: _limit);
      final hasReachedMax = stores.length < _limit;
      emit(StoreLoaded(stores: stores, hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }

  Future<void> _onLoadMoreStores(
    LoadMoreStores event,
    Emitter<StoreState> emit,
  ) async {
    final currentState = state;
    if (currentState is StoreLoaded &&
        !currentState.hasReachedMax &&
        !_isFetching) {
      _isFetching = true;
      try {
        _skip += _limit;
        final moreStores = await storeService.fetchStores(
          skip: _skip,
          limit: _limit,
        );

        if (moreStores.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          final updatedStores = List.of(currentState.stores)
            ..addAll(moreStores);
          emit(
            currentState.copyWith(
              stores: updatedStores,
              hasReachedMax: moreStores.length < _limit,
            ),
          );
        }
      } catch (e) {
        emit(StoreError(e.toString()));
      } finally {
        _isFetching = false;
      }
    }
  }
}
