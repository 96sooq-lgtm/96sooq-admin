import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/payments/model/transaction_model.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_bloc.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_event.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsDialog extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsDialog({super.key, required this.transaction});

  @override
  State<TransactionDetailsDialog> createState() =>
      _TransactionDetailsDialogState();
}

class _TransactionDetailsDialogState extends State<TransactionDetailsDialog> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(
      LoadTransactionDetails(widget.transaction.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 16,
                top: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DynamicText('Transaction Details', style: AppThemes.f20w600),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE1E1E1)),

            /// Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// User & Amount Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DynamicText(
                                widget.transaction.userName,
                                style: AppThemes.f18w600,
                              ),
                              const SizedBox(height: 4),
                              DynamicText(
                                widget.transaction.id,
                                style: AppThemes.f14w400.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE1E1E1)),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Amount',
                            value:
                                '${widget.transaction.amount.toStringAsFixed(2)} ${widget.transaction.currency}',
                            valueColor: AppColors.primaryColor,
                            boldValue: true,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Status',
                            valueWidget: _StatusChip(
                              status: widget.transaction.status,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Created At',
                            value: _formatDate(widget.transaction.createdAt),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Paymob Txn ID',
                            value:
                                widget.transaction.paymobTransactionId ?? 'N/A',
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFE1E1E1)),
                          const SizedBox(height: 16),

                          BlocBuilder<PaymentBloc, PaymentState>(
                            builder: (context, state) {
                              if (state.detailsStatus ==
                                      PaymentStatus.loading ||
                                  state.detailsStatus ==
                                      PaymentStatus.initial) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (state.detailsStatus == PaymentStatus.error) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'Error fetching details: ${state.errorMessage}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                );
                              }

                              final details = state.transactionDetails;
                              if (details == null ||
                                  details.id != widget.transaction.id) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    label: 'Payment Method',
                                    value: details.paymentMethod.toUpperCase(),
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    label: 'User Email',
                                    value: details.userEmail,
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    label: 'User Phone',
                                    value: details.userPhone,
                                  ),

                                  if (details.metadata.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    const Divider(
                                      height: 1,
                                      color: Color(0xFFE1E1E1),
                                    ),
                                    const SizedBox(height: 16),
                                    DynamicText(
                                      'Metadata',
                                      style: AppThemes.f14w600.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...details.metadata.entries.map((e) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: _InfoRow(
                                          label: e.key
                                              .replaceAll('_', ' ')
                                              .replaceFirst(
                                                e.key[0],
                                                e.key[0].toUpperCase(),
                                              ),
                                          value: e.value.toString(),
                                        ),
                                      );
                                    }),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMM dd, yyyy h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color? valueColor;
  final bool boldValue;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.valueColor,
    this.boldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DynamicText(
          label,
          style: AppThemes.f14w400.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              valueWidget ??
              DynamicText(
                value ?? '',
                style: boldValue
                    ? AppThemes.f16w600.copyWith(color: valueColor)
                    : AppThemes.f14w500.copyWith(color: valueColor),
                textAlign: TextAlign.right,
              ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final lowerStatus = status.toLowerCase();

    // Determine colors
    Color bgColor = const Color(0xFFF3F4F6); // Grey by default
    Color textColor = const Color(0xFF4B5563);

    if (lowerStatus == 'success' || lowerStatus == 'completed') {
      bgColor = const Color(0xFFDBFCE7);
      textColor = const Color(0xFF1E8E4E);
    } else if (lowerStatus == 'pending') {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
    } else if (lowerStatus == 'failed' ||
        lowerStatus == 'error' ||
        lowerStatus == 'cancelled') {
      bgColor = const Color(0xFFFFE2E2);
      textColor = const Color(0xFFF93939);
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: DynamicText(
          status.toUpperCase(),
          style: AppThemes.f12w600.copyWith(color: textColor),
        ),
      ),
    );
  }
}
