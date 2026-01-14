import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';

class TermsAndConditionViewDesktop extends StatefulWidget {
  const TermsAndConditionViewDesktop({super.key});

  @override
  State<TermsAndConditionViewDesktop> createState() =>
      _TermsAndConditionViewDesktopState();
}

class _TermsAndConditionViewDesktopState
    extends State<TermsAndConditionViewDesktop> {
  bool isEditing = false;
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
                  Text("Terms & Conditions", style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  Text(
                    "Edit and manage your 96 sooq terms and conditions",
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
                                  flex: 1,
                                  child: Text("Last updated : 21, 2025"),
                                ),
                                Spacer(),
                                Expanded(
                                  flex: 1,
                                  child: CustomButton(
                                    text: isEditing ? "Publish" : "Edit",
                                    onPressed: () {
                                      setState(() => isEditing = true);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 31,
                            horizontal: 38,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Color(0xFFE1E1E1)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 31,
                              horizontal: 38,
                            ),
                            child: TextFormField(
                              initialValue:
                                  "Welcome to our 96 sooq\n"
                                  "These Terms and Conditions ('Terms') govern your use of our marketplace platform.\n"
                                  "1. Acceptance of Terms\n"
                                  "By accessing and using this marketplace, you accept and agree to be bound by these Terms and our Privacy Policy.\n"
                                  "2. User Accounts\n"
                                  "- You must be at least 18 years old to create an account\n"
                                  "- You are responsible for maintaining the confidentiality of your account\n"
                                  "- You agree to provide accurate and complete information\n"
                                  "3. Seller Responsibilities\n"
                                  "- Sellers must provide accurate product descriptions\n"
                                  "- All products must comply with applicable laws\n"
                                  "- Sellers are responsible for order fulfillment and customer service",
                              readOnly: !isEditing,
                              maxLines: null,
                              style: AppThemes.f16w400,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
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
