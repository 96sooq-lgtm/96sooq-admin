import 'package:_96sooq_admin/features/stores/model/store_model.dart';

abstract class StoreEvent {}

class LoadStores extends StoreEvent {
  final bool isRefresh;
  LoadStores({this.isRefresh = false});
}

class LoadMoreStores extends StoreEvent {}

class ToggleStoreStatus extends StoreEvent {
  final StoreModel store;
  final bool isLocking;
  ToggleStoreStatus({required this.store, required this.isLocking});
}
