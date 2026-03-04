import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_bloc.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_event.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_state.dart';
import 'package:_96sooq_admin/features/payments/widgets/transaction_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PaymentsViewMobile extends StatefulWidget {
  const PaymentsViewMobile({super.key});

  @override
  State<PaymentsViewMobile> createState() => _PaymentsViewMobileState();
}

class _PaymentsViewMobileState extends State<PaymentsViewMobile> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _tableScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _mainScrollController.removeListener(_onScroll);
    searchController.dispose();
    _mainScrollController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_mainScrollController.position.pixels >=
        _mainScrollController.position.maxScrollExtent - 200) {
      context.read<PaymentBloc>().add(const LoadMoreTransactions());
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: CustomScrollView(
        controller: _mainScrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  DynamicText('Transactions', style: AppThemes.f20w600),
                  const SizedBox(height: 6),
                  DynamicText(
                    'Track and manage all transaction',
                    style: AppThemes.f14w400,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomTextFormField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      labelText: 'Search by user or transaction ID...',
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF99A1Af),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE1E1E1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Scrollbar(
                        controller: _tableScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _tableScrollController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1240,
                            child: Column(
                              children: [
                                _PaymentsTableHeader(),
                                BlocBuilder<PaymentBloc, PaymentState>(
                                  builder: (context, state) {
                                    if (state.status == PaymentStatus.loading ||
                                        state.status == PaymentStatus.initial) {
                                      return Column(
                                        children: List.generate(
                                          8,
                                          (index) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: index == 7 ? 0 : 16,
                                            ),
                                            child:
                                                const _PaymentsShimmerRowMobile(),
                                          ),
                                        ),
                                      );
                                    }

                                    if (state.status == PaymentStatus.error) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Center(
                                          child: Text(
                                            state.errorMessage ??
                                                'An error occurred',
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final allPayments = state.transactions;
                                    final filteredPayments = allPayments.where((
                                      p,
                                    ) {
                                      if (query.isEmpty) return true;
                                      return p.id.toLowerCase().contains(
                                            query,
                                          ) ||
                                          p.userName.toLowerCase().contains(
                                            query,
                                          ) ||
                                          p.status.toLowerCase().contains(
                                            query,
                                          );
                                    }).toList();

                                    if (filteredPayments.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Center(
                                          child: DynamicText(
                                            'No results found',
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: filteredPayments.length,
                                      itemBuilder: (context, index) {
                                        final payment = filteredPayments[index];
                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    TransactionDetailsDialog(
                                                      transaction: payment,
                                                    ),
                                              );
                                            },
                                            hoverColor: Colors.black
                                                .withOpacity(0.04),
                                            child: _PaymentsRowMobile(
                                              transactionId: payment.id,
                                              name: payment.userName,
                                              amount:
                                                  '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                                              date: payment.createdAt,
                                              status: payment.status,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: const [
            SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: DynamicText('Transaction ID', style: AppThemes.f14w600),
            ),
            Expanded(
              flex: 3,
              child: DynamicText('Name', style: AppThemes.f14w600),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: DynamicText('Amount', style: AppThemes.f14w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: DynamicText('Date', style: AppThemes.f14w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: DynamicText('Status', style: AppThemes.f14w600),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

class _PaymentsRowMobile extends StatelessWidget {
  final String transactionId;
  final String name;
  final String amount;
  final String date;
  final String status;

  const _PaymentsRowMobile({
    required this.transactionId,
    required this.name,
    required this.amount,
    required this.date,
    required this.status,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: DynamicText(
              transactionId.substring(0, 8),
              style: AppThemes.f14w400,
            ),
          ),
          Expanded(flex: 3, child: DynamicText(name, style: AppThemes.f14w400)),
          Expanded(
            flex: 2,
            child: Center(
              child: DynamicText(
                amount,
                style: AppThemes.f14w500.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DynamicText(_formatDate(date), style: AppThemes.f14w400),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _StatusChip(status: status)),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _PaymentsShimmerRowMobile extends StatelessWidget {
  const _PaymentsShimmerRowMobile();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.85),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Row(
            children: const [
              SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: _ShimmerBoxMobile(width: double.infinity, height: 16),
              ),
              Expanded(
                flex: 3,
                child: _ShimmerBoxMobile(width: double.infinity, height: 16),
              ),
              Expanded(
                flex: 2,
                child: Center(child: _ShimmerBoxMobile(width: 60, height: 16)),
              ),
              Expanded(
                flex: 2,
                child: Center(child: _ShimmerBoxMobile(width: 90, height: 16)),
              ),
              Expanded(
                flex: 2,
                child: Center(child: _ShimmerBoxMobile(width: 60, height: 16)),
              ),
              SizedBox(width: 20),
            ],
          ),
        );
      },
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
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: DynamicText(
          status.toUpperCase(),
          style: AppThemes.f10w500.copyWith(color: textColor),
        ),
      ),
    );
  }
}

class _ShimmerBoxMobile extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBoxMobile({
    required this.width,
    required this.height,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
