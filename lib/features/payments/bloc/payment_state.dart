import 'package:_96sooq_admin/features/payments/model/transaction_model.dart';
import 'package:equatable/equatable.dart';

enum PaymentStatus { initial, loading, loaded, error }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final List<TransactionModel> transactions;
  final bool hasReachedMax;
  final String? errorMessage;
  final int currentPage; // Added property

  // Details specific state
  final PaymentStatus detailsStatus; // Added property
  final TransactionDetailsModel? transactionDetails; // Added property

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.transactions = const <TransactionModel>[], // Updated default value
    this.hasReachedMax = false,
    this.errorMessage,
    this.currentPage = 1, // Added default value
    this.detailsStatus = PaymentStatus.initial, // Added default value
    this.transactionDetails, // Added default value
  });

  PaymentState copyWith({
    PaymentStatus? status,
    List<TransactionModel>? transactions,
    bool? hasReachedMax,
    String? errorMessage,
    int? currentPage, // Added parameter
    PaymentStatus? detailsStatus, // Added parameter
    TransactionDetailsModel? transactionDetails, // Added parameter
  }) {
    return PaymentState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage, // Updated copyWith
      detailsStatus: detailsStatus ?? this.detailsStatus, // Updated copyWith
      transactionDetails:
          transactionDetails ?? this.transactionDetails, // Updated copyWith
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    hasReachedMax,
    errorMessage,
    currentPage, // Added to props
    detailsStatus, // Added to props
    transactionDetails, // Added to props
  ];
}
