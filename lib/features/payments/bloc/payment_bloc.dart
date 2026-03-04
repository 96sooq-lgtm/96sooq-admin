import 'package:_96sooq_admin/features/payments/bloc/payment_event.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_state.dart';
import 'package:_96sooq_admin/features/payments/services/payment_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _paymentService;
  int _currentPage = 1;
  final int _limit = 20;
  bool _isFetchingMore = false;

  PaymentBloc(this._paymentService) : super(const PaymentState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<LoadTransactionDetails>(_onLoadTransactionDetails);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<PaymentState> emit,
  ) async {
    _isFetchingMore = false;
    emit(state.copyWith(status: PaymentStatus.loading));
    try {
      _currentPage = 1;
      final response = await _paymentService.fetchTransactions(
        page: _currentPage,
        limit: _limit,
      );
      emit(
        state.copyWith(
          status: PaymentStatus.loaded,
          transactions: response.transactions,
          hasReachedMax: response.page >= response.pages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: PaymentStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<PaymentState> emit,
  ) async {
    if (state.status == PaymentStatus.loading || state.hasReachedMax) return;
    if (_isFetchingMore) return;

    _isFetchingMore = true;
    _currentPage++;
    try {
      final response = await _paymentService.fetchTransactions(
        page: _currentPage,
        limit: _limit,
      );

      if (response.transactions.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.loaded,
            transactions: List.of(state.transactions)
              ..addAll(response.transactions),
            hasReachedMax: response.page >= response.pages,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: PaymentStatus.error, errorMessage: e.toString()),
      );
    } finally {
      _isFetchingMore = false;
    }
  }

  Future<void> _onLoadTransactionDetails(
    LoadTransactionDetails event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(detailsStatus: PaymentStatus.loading));
    try {
      final details = await _paymentService.fetchTransactionDetails(
        event.transactionId,
      );
      emit(
        state.copyWith(
          detailsStatus: PaymentStatus.loaded,
          transactionDetails: details,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          detailsStatus: PaymentStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
