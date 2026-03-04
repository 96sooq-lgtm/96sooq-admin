import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {
  final bool isRefresh;
  const LoadUsers({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class LoadMoreUsers extends UserEvent {}

class LoadUserDetails extends UserEvent {
  final String id;
  const LoadUserDetails(this.id);

  @override
  List<Object?> get props => [id];
}
