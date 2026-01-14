import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/features/category/widgets/category_list_widget.dart';
import 'package:_96sooq_admin/features/payments/widgets/payments_listing_widget.dart';
import 'package:flutter/material.dart';

class PaymentsViewDesktop extends StatefulWidget {
  const PaymentsViewDesktop({super.key});

  @override
  State<PaymentsViewDesktop> createState() => _PaymentsViewDesktopState();
}

class _PaymentsViewDesktopState extends State<PaymentsViewDesktop> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
                  Text("Transactions ", style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  Text(
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
                                  child: TextFormField(
                                    controller: searchController,
                                    cursorColor: AppColors.primaryColor,
                                    decoration: InputDecoration(
                                      label: Text(
                                        "Search by user or transaction ID...",
                                        style: AppThemes.f20w400.copyWith(
                                          color: Color(0xFF99A1Af),
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Color(0xFFEFEFEF),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Color(0xFFEFEFEF),
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Color(0xFF99A1Af),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(14),
                                        ),
                                        borderSide: BorderSide(
                                          color: Color(0xFFEFEFEF),
                                        ),
                                      ),
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
                                  child: Text(
                                    'T-ID',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: Text('Name', style: AppThemes.f20w500),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      'Category',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      'Amount',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      'Date',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      'Status',
                                      style: AppThemes.f20w500,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                                 SizedBox(width: 24,)
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return PaymentsListingWidget(
                              name: "John Doe",
                              status: "Success",
                              transactionId: 'TXN001234',
                              category: ' Promotions',
                              amount: '12',
                              date: '2025-12-20',
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
