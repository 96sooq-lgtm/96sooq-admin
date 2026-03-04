import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/listing_model.dart';
import '../services/listing_service.dart';

// --- Events ---
abstract class ListingEvent extends Equatable {
  const ListingEvent();

  @override
  List<Object?> get props => [];
}

class LoadListings extends ListingEvent {
  final String status;
  final bool isRefresh;

  const LoadListings({required this.status, this.isRefresh = false});

  @override
  List<Object?> get props => [status, isRefresh];
}

class LoadMoreListings extends ListingEvent {
  final String status;

  const LoadMoreListings({required this.status});

  @override
  List<Object?> get props => [status];
}

class ApproveListing extends ListingEvent {
  final String id;

  const ApproveListing({required this.id});

  @override
  List<Object?> get props => [id];
}

class RejectListing extends ListingEvent {
  final String id;
  final String reason;

  const RejectListing({required this.id, required this.reason});

  @override
  List<Object?> get props => [id, reason];
}

// --- States ---
abstract class ListingState extends Equatable {
  const ListingState();

  @override
  List<Object?> get props => [];
}

class ListingInitial extends ListingState {}

class ListingLoading extends ListingState {}

class ListingLoaded extends ListingState {
  final List<ListingModel> listings;
  final bool hasReachedMax;

  const ListingLoaded(this.listings, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [listings, hasReachedMax];

  ListingLoaded copyWith({List<ListingModel>? listings, bool? hasReachedMax}) {
    return ListingLoaded(
      listings ?? this.listings,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ListingError extends ListingState {
  final String message;

  const ListingError(this.message);

  @override
  List<Object?> get props => [message];
}

class ListingActionLoading extends ListingState {}

class ListingActionSuccess extends ListingState {
  final String message;

  const ListingActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ListingActionError extends ListingState {
  final String message;

  const ListingActionError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final ListingService _listingService;
  int _currentSkip = 0;
  final int _limit = 10;
  bool _isFetchingMore = false;

  ListingBloc(this._listingService) : super(ListingInitial()) {
    on<LoadListings>(_onLoadListings);
    on<LoadMoreListings>(_onLoadMoreListings);
    on<ApproveListing>(_onApproveListing);
    on<RejectListing>(_onRejectListing);
  }

  Future<void> _onLoadListings(
    LoadListings event,
    Emitter<ListingState> emit,
  ) async {
    emit(ListingLoading());
    try {
      _currentSkip = 0;
      final listings = await _listingService.fetchListings(
        status: event.status,
        skip: _currentSkip,
        limit: _limit,
      );
      emit(ListingLoaded(listings, hasReachedMax: listings.length < _limit));
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onLoadMoreListings(
    LoadMoreListings event,
    Emitter<ListingState> emit,
  ) async {
    if (_isFetchingMore) return;
    if (state is ListingLoaded) {
      final currentState = state as ListingLoaded;
      if (currentState.hasReachedMax) return;

      _isFetchingMore = true;
      try {
        _currentSkip += _limit;
        final moreListings = await _listingService.fetchListings(
          status: event.status,
          skip: _currentSkip,
          limit: _limit,
        );

        if (moreListings.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              listings: List.of(currentState.listings)..addAll(moreListings),
              hasReachedMax: moreListings.length < _limit,
            ),
          );
        }
      } catch (e) {
        emit(ListingError(e.toString()));
      } finally {
        _isFetchingMore = false;
      }
    }
  }

  Future<void> _onApproveListing(
    ApproveListing event,
    Emitter<ListingState> emit,
  ) async {
    emit(ListingActionLoading());
    try {
      await _listingService.approveListing(id: event.id);
      emit(const ListingActionSuccess('Listing approved successfully.'));
    } catch (e) {
      emit(ListingActionError(e.toString()));
    }
  }

  Future<void> _onRejectListing(
    RejectListing event,
    Emitter<ListingState> emit,
  ) async {
    emit(ListingActionLoading());
    try {
      await _listingService.rejectListing(id: event.id, reason: event.reason);
      emit(const ListingActionSuccess('Listing rejected successfully.'));
    } catch (e) {
      emit(ListingActionError(e.toString()));
    }
  }
}
