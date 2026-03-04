class TransactionModel {
  final String id;
  final String? paymobTransactionId;
  final String createdAt;
  final String userName;
  final String status;
  final double amount;
  final String currency;

  TransactionModel({
    required this.id,
    this.paymobTransactionId,
    required this.createdAt,
    required this.userName,
    required this.status,
    required this.amount,
    required this.currency,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      paymobTransactionId: json['paymob_transaction_id'],
      createdAt: json['created_at'] ?? '',
      userName: json['user_name'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? '',
    );
  }
}

class TransactionListResponse {
  final List<TransactionModel> transactions;
  final int total;
  final int page;
  final int limit;
  final int pages;

  TransactionListResponse({
    required this.transactions,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['transactions'] as List? ?? [];
    List<TransactionModel> paymentList = list
        .map((i) => TransactionModel.fromJson(i))
        .toList();

    return TransactionListResponse(
      transactions: paymentList,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
}

class TransactionDetailsModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String? paymobTransactionId;
  final Map<String, dynamic> metadata;
  final String createdAt;
  final String userName;
  final String userEmail;
  final String userPhone;

  TransactionDetailsModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.paymobTransactionId,
    required this.metadata,
    required this.createdAt,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  factory TransactionDetailsModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailsModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? '',
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      paymobTransactionId: json['paymob_transaction_id'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : {},
      createdAt: json['created_at'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userPhone: json['user_phone'] ?? '',
    );
  }
}
