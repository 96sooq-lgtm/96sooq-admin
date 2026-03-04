import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends PaymentEvent {
  const LoadTransactions();
}

class LoadMoreTransactions extends PaymentEvent {
  const LoadMoreTransactions();
}

class LoadTransactionDetails extends PaymentEvent {
  final String transactionId;

  const LoadTransactionDetails(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}
