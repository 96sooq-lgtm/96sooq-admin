import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/features/promotion/widgets/promotion_slab_listing_widget.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96sooq_admin/features/subcategory/widgets/subcategory_list_widget.dart';
import 'package:flutter/material.dart';

class PromotionViewDesktop extends StatefulWidget {
  const PromotionViewDesktop({super.key});

  @override
  State<PromotionViewDesktop> createState() => _PromotionViewDesktopState();
}

class _PromotionViewDesktopState extends State<PromotionViewDesktop> {
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
                  Text("Promotion Slabs", style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  Text(
                    "Manage promotion plan and pricing",
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
                                Spacer(flex: 3),
                                Expanded(
                                  flex: 1,
                                  child: CustomButton(
                                    text: "+ Create plan",
                                    onPressed: () {},
                                  ),
                                ),
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
                                  flex: 2,
                                  child: Text(
                                    'Plan Name',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      'Price',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      'Duration',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      'Actions',
                                      style: AppThemes.f20w500,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return PromotionSlabListingWidget(
                              name: "Premium Plan",
                              price: '12',
                              duration: "30 Days",
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
