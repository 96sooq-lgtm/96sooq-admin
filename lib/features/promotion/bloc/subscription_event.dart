part of 'subscription_bloc.dart';

sealed class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class LoadSubscriptions extends SubscriptionEvent {}

class CreateSubscription extends SubscriptionEvent {
  final SubscriptionModel subscription;

  const CreateSubscription(this.subscription);

  @override
  List<Object> get props => [subscription];
}

class UpdateSubscription extends SubscriptionEvent {
  final String id;
  final SubscriptionModel subscription;

  const UpdateSubscription({required this.id, required this.subscription});

  @override
  List<Object> get props => [id, subscription];
}

class DeleteSubscription extends SubscriptionEvent {
  final String id;

  const DeleteSubscription(this.id);

  @override
  List<Object> get props => [id];
}
