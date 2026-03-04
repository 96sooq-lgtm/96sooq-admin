import 'package:_96sooq_admin/features/stores/model/store_model.dart';
import 'package:equatable/equatable.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object> get props => [];
}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<StoreModel> stores;
  final bool hasReachedMax;

  const StoreLoaded({required this.stores, this.hasReachedMax = false});

  StoreLoaded copyWith({List<StoreModel>? stores, bool? hasReachedMax}) {
    return StoreLoaded(
      stores: stores ?? this.stores,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [stores, hasReachedMax];
}

class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object> get props => [message];
}
