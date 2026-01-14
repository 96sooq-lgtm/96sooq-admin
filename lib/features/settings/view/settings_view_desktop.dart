import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/features/offer_listings/widgets/offer_listing_widget.dart';
import 'package:flutter/material.dart';

class SettingsViewDesktop extends StatefulWidget {
  const SettingsViewDesktop({super.key});

  @override
  State<SettingsViewDesktop> createState() => _SettingsViewDesktopState();
}

class _SettingsViewDesktopState extends State<SettingsViewDesktop> {
  String value = "en";
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
                  Text("Admin Settings", style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  Text(
                    "Manage your admin preferences",
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
                            horizontal: 28,
                            vertical: 25,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: .start,
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  "General Settings",
                                  style: AppThemes.f24w500,
                                ),
                                SizedBox(height: 18),
                                Text(
                                  "Language",
                                  style: AppThemes.f20w400.copyWith(
                                    color: Color(0xFF707070),
                                  ),
                                ),
                                SizedBox(height: 18),
                                DropdownButtonFormField<String>(
                                  initialValue: value,
                                  onChanged: (value) {},
                                  borderRadius: BorderRadius.circular(14),
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:  Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE1E1E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE1E1E1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'en',
                                      child: Text('English'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ar',
                                      child: Text('Arabic'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                            horizontal: 28,
                            vertical: 25,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: .start,
                              crossAxisAlignment: .center,
                              children: [
                                Text(
                                  "Reviewed Offers",
                                  style: AppThemes.f24w500,
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
                                    'Offer Title',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      'Seller Name',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      'Date submitted',
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
                            return OfferListingWidget(
                              offerTitle:
                                  "Summer Sale - 50% OFF on Electronics",
                              seller: 'Tech Store',
                              dateOfSubmission: "2025-12-21",
                              isReviewed: true,
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
