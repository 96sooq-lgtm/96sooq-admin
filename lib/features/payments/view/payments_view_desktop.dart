import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/payments/widgets/payments_listing_widget.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_bloc.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_event.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_state.dart';
import 'package:_96sooq_admin/features/payments/widgets/transaction_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentsViewDesktop extends StatefulWidget {
  const PaymentsViewDesktop({super.key});

  @override
  State<PaymentsViewDesktop> createState() => _PaymentsViewDesktopState();
}

class _PaymentsViewDesktopState extends State<PaymentsViewDesktop> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _mainScrollController.removeListener(_onScroll);
    _mainScrollController.dispose();
    searchController.dispose();
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
                  const SizedBox(height: 36),
                  DynamicText("Transactions ", style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  DynamicText(
                    "Track and manage all transaction",
                    style: AppThemes.f20w400,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE1E1E1)),
                    ),
                    child: Column(
                      children: [
                        /// Top Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 55,
                            vertical: 55,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: .center,
                              crossAxisAlignment: .center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: CustomTextFormField(
                                    controller: searchController,
                                    onChanged: (_) => setState(() {}),
                                    labelText:
                                        "Search by user or transaction ID...",
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Color(0xFF99A1Af),
                                    ),
                                  ),
                                ),
                                Spacer(flex: 2),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF9FAFB),
                            border: Border.all(color: Color(0xFFE1E1E1)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: const [
                                SizedBox(width: 40),
                                Expanded(
                                  flex: 1,
                                  child: DynamicText(
                                    'T-ID',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: DynamicText(
                                    'Name',
                                    style: AppThemes.f16w600,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: DynamicText(
                                      'Amount',
                                      style: AppThemes.f16w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: DynamicText(
                                      'Date',
                                      style: AppThemes.f16w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: DynamicText(
                                      'Status',
                                      style: AppThemes.f16w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 24),
                              ],
                            ),
                          ),
                        ),
                        BlocBuilder<PaymentBloc, PaymentState>(
                          builder: (context, state) {
                            if (state.status == PaymentStatus.loading ||
                                state.status == PaymentStatus.initial) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
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
                                    state.errorMessage ?? 'An error occurred',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                            }

                            final allPayments = state.transactions;
                            final filteredPayments = allPayments.where((p) {
                              if (query.isEmpty) return true;
                              return p.id.toLowerCase().contains(query) ||
                                  p.userName.toLowerCase().contains(query) ||
                                  p.status.toLowerCase().contains(query);
                            }).toList();

                            if (filteredPayments.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: DynamicText('No results found'),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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
                                    hoverColor: Colors.black.withOpacity(0.04),
                                    child: PaymentsListingWidget(
                                      name: payment.userName,
                                      status: payment.status,
                                      transactionId: payment.id,
                                      amount:
                                          '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                                      date: payment.createdAt,
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
