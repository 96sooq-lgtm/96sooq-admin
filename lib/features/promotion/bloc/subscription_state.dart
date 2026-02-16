part of 'subscription_bloc.dart';

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();
  
  @override
  List<Object> get props => [];
}

final class SubscriptionInitial extends SubscriptionState {}

final class SubscriptionLoading extends SubscriptionState {}

final class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionModel> subscriptions;
  const SubscriptionLoaded(this.subscriptions);

  @override
  List<Object> get props => [subscriptions];
}

final class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}
